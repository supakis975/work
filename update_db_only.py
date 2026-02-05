#!/usr/bin/env python3
# update_db_only.py
# อัพเดตข้อมูลในตาราง metacritic_games และ steam_games
# ไม่แตะ image_url และไม่ใส่ last_scraped

import re
import time
import json
import requests
from bs4 import BeautifulSoup
import mysql.connector
from mysql.connector import Error

# ====== CONFIG ======
MYSQL_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "info_games",
    "charset": "utf8mb4",
    "use_unicode": True,
}

HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
session = requests.Session()
session.headers.update(HEADERS)

SLEEP_BETWEEN = 0.8   # หน่วงระหว่าง request (gentle)
VERBOSE = True        # ถ้าอยากให้เงียบ ตั้งเป็น False

# ====== DB helper ======
def db_connect():
    return mysql.connector.connect(**MYSQL_CONFIG)

# ====== Date helpers ======
_date_regex = re.compile(
    r'([A-Za-z]{3,}\s+\d{1,2},\s*\d{4}|'      # Feb 25, 2022
    r'\d{1,2}\s+[A-Za-z]{3,}\s+\d{4}|'        # 25 Feb 2022
    r'\d{4}-\d{2}-\d{2})'                     # 2022-02-25
)

def extract_date_from_text(text):
    if not text:
        return None
    m = _date_regex.search(text)
    return m.group(1).strip() if m else None

def try_jsonld_for_date(soup):
    # หา datePublished / releaseDate ใน script[type="application/ld+json"]
    scripts = soup.select('script[type="application/ld+json"]')
    for s in scripts:
        try:
            data = json.loads(s.string or "{}")
        except Exception:
            continue
        items = data if isinstance(data, list) else [data]
        for it in items:
            if not isinstance(it, dict):
                continue
            for key in ("datePublished", "releaseDate", "dateCreated"):
                if key in it and it[key]:
                    d = extract_date_from_text(str(it[key]))
                    if d:
                        return d
            if "mainEntity" in it and isinstance(it["mainEntity"], dict):
                for key in ("datePublished", "releaseDate"):
                    if key in it["mainEntity"]:
                        d = extract_date_from_text(str(it["mainEntity"][key]))
                        if d:
                            return d
    return None

def find_label_sibling_date(soup):
    # หา "Release Date" / "Released" แล้วดูข้อความใกล้เคียง
    label_patterns = re.compile(r'\bRelease Date\b|\bReleased\b|\bInitial release\b', re.I)
    texts = soup.find_all(string=label_patterns)
    for t in texts:
        parent = t.parent
        if not parent:
            continue
        # next sibling
        nxt = parent.find_next_sibling()
        if nxt:
            d = extract_date_from_text(nxt.get_text(" ", strip=True))
            if d:
                return d
        # parent's own text
        d = extract_date_from_text(parent.get_text(" ", strip=True))
        if d:
            return d
        # parent's parent next sibling
        pp = parent.parent
        if pp:
            nxt2 = pp.find_next_sibling()
            if nxt2:
                d = extract_date_from_text(nxt2.get_text(" ", strip=True))
                if d:
                    return d
    return None

# ====== Metacritic parsing ======
def parse_metacritic_detail(html):
    soup = BeautifulSoup(html, "html.parser")

    # Metascore
    metascore = "N/A"
    try:
        el = soup.select_one("div.c-productScoreInfo_scoreNumber span")
        if el and el.get_text(strip=True):
            metascore = el.get_text(strip=True)
    except Exception:
        pass

    # User score
    userscore = "N/A"
    try:
        el = soup.select_one("div[data-testid='user-score-info'] div.c-productScoreInfo_scoreNumber span")
        if el and el.get_text(strip=True):
            userscore = el.get_text(strip=True)
        else:
            el2 = soup.select_one("div.c-productScoreInfo_scoreNumber.u-float-right span")
            if el2 and el2.get_text(strip=True):
                userscore = el2.get_text(strip=True)
    except Exception:
        pass

    # Genre
    genre = "N/A"
    try:
        genre_ul = soup.find("ul", class_="c-genreList")
        if genre_ul:
            items = genre_ul.find_all("span", class_="c-globalButton_label")
            if items:
                vals = [it.get_text(strip=True) for it in items if it.get_text(strip=True)]
                if vals:
                    genre = ", ".join(vals)
        if genre == "N/A":
            # fallback: หา string ที่มี 'Genre'
            cand = soup.find_all(string=re.compile(r'\bGenre[s]?\b', re.I))
            for c in cand:
                p = c.parent
                if not p:
                    continue
                nxt = p.find_next_sibling()
                if nxt:
                    text = nxt.get_text(" ", strip=True)
                    if text:
                        genre = text
                        break
                txt = p.get_text(" ", strip=True)
                m = re.search(r'Genre[s]?:\s*(.+)', txt, re.I)
                if m:
                    genre = m.group(1).strip()
                    break
    except Exception:
        pass

    # Release date (prioritized)
    release_date = "N/A"
    try:
        # 1) exact selector you provided
        try:
            span_sel = soup.select_one("span.g-outer-spacing-left-medium-fluid.g-color-gray70.u-block")
            if span_sel:
                txt = span_sel.get_text(" ", strip=True)
                d = extract_date_from_text(txt)
                if d:
                    release_date = d
        except Exception:
            pass

        # 2) partial class match (class order may vary)
        if release_date == "N/A":
            for sp in soup.find_all("span", class_=True):
                cls_list = sp.get("class") or []
                cls_join = " ".join(cls_list)
                if ("g-outer-spacing-left-medium-fluid" in cls_join) or ("g-outer-spacing-left" in cls_join) or ("g-color-gray70" in cls_join and "u-block" in cls_join):
                    txt = sp.get_text(" ", strip=True)
                    d = extract_date_from_text(txt)
                    if d:
                        release_date = d
                        break

        # 3) common selectors
        if release_date == "N/A":
            selectors = [
                "li.summary_detail.release_data .data",
                "li.release_data .data",
                "li.summary_detail.release_date .data",
                "div.c-productDetails_releaseDate",
                "div.release_date span",
                "span.release_date",
                "li.summary_detail.release_data span",
                "div.product_data span[class*=release]",
            ]
            for sel in selectors:
                el = soup.select_one(sel)
                if el:
                    txt = el.get_text(" ", strip=True)
                    d = extract_date_from_text(txt)
                    if d:
                        release_date = d
                        break
                    # if looks like date-like text, accept it
                    if txt and any(ch.isalpha() for ch in txt):
                        maybe = extract_date_from_text(txt) or txt.strip()
                        if maybe:
                            release_date = maybe
                            break

        # 4) time/meta tags
        if release_date == "N/A":
            t = soup.find("time")
            if t:
                dt = t.get("datetime") or t.get_text(" ", strip=True)
                d = extract_date_from_text(dt)
                if d:
                    release_date = d
        if release_date == "N/A":
            meta_el = soup.find("meta", {"itemprop": "datePublished"}) or soup.find("meta", {"name": "date"})
            if meta_el:
                mval = meta_el.get("content") or meta_el.get("value") or meta_el.get("datetime", "")
                d = extract_date_from_text(mval)
                if d:
                    release_date = d

        # 5) JSON-LD
        if release_date == "N/A":
            d = try_jsonld_for_date(soup)
            if d:
                release_date = d

        # 6) label-sibling fallback
        if release_date == "N/A":
            d = find_label_sibling_date(soup)
            if d:
                release_date = d

        # 7) last fallback: first date-like anywhere on page
        if release_date == "N/A":
            full_text = soup.get_text(" ", strip=True)
            d = extract_date_from_text(full_text)
            if d:
                release_date = d

    except Exception:
        pass

    return metascore or "N/A", userscore or "N/A", genre or "N/A", release_date or "N/A"

# ====== Steam helpers (kept simple) ======
def parse_steam_store_page(html):
    soup = BeautifulSoup(html, "html.parser")
    price = "N/A"
    discount = "0%"
    genre = "N/A"
    try:
        disc = soup.select_one("div.discount_block")
        if disc:
            d_attr = disc.get("data-discount")
            if d_attr and d_attr.strip() != "0":
                discount = f"-{d_attr}%"
            fin = disc.select_one("div.discount_final_price")
            if fin and fin.get_text(strip=True):
                price = fin.get_text(strip=True)
            else:
                fin2 = disc.select_one(".discount_final_price, .game_purchase_price, .price")
                if fin2 and fin2.get_text(strip=True):
                    price = fin2.get_text(strip=True)
        else:
            el = soup.select_one("div.game_purchase_price, div.discount_final_price, .game_area_purchase_game .price")
            if el and el.get_text(strip=True):
                price = el.get_text(strip=True)
            free = soup.find(text=re.compile(r'\bFree\b|\bFree To Play\b', re.I))
            if free and price == "N/A":
                price = "Free"

        # genre
        genre_links = soup.select("a[href*='/genre/'], a[href*='genre/']")
        if genre_links:
            genre = ", ".join(sorted({g.get_text(strip=True) for g in genre_links if g.get_text(strip=True)}))
        else:
            for row in soup.select("div.details_block, .glance_ctn_responsive_left, .game_area_details_specs"):
                txt = row.get_text(" ", strip=True)
                if "Genre" in txt or "Genres" in txt:
                    m = re.search(r'Genre[s]?:\s*(.+?)(?:\s{2,}|\n|$)', txt, re.I)
                    if m:
                        genre = m.group(1).strip()
                        break
    except Exception:
        pass

    if isinstance(price, str):
        price = " ".join(price.split())
    if not discount:
        discount = "0%"

    return price or "N/A", discount or "0%", genre or "N/A"

# ====== Update functions ======
def update_metacritic_rows():
    conn = db_connect()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT id, title, url FROM metacritic_games")
    rows = cur.fetchall()
    if VERBOSE: print(f"Metacritic: {len(rows)} rows to update")
    for r in rows:
        id_ = r.get('id')
        title = r.get('title')
        url = r.get('url')
        if not url:
            if VERBOSE: print(" - skip (no url):", title)
            continue
        try:
            resp = session.get(url, timeout=20)
            if resp.status_code != 200:
                if VERBOSE: print(" - fetch failed:", title, resp.status_code)
                continue
            metascore, userscore, genre, release_date = parse_metacritic_detail(resp.text)

            # Update DB (do not touch Image_url, do not set last_scraped)
            upd = conn.cursor()
            try:
                upd.execute("""
                    UPDATE metacritic_games
                    SET Metascore=%s, User_Score=%s, Genre=%s, Release_Date=%s
                    WHERE id=%s
                """, (metascore, userscore, genre, release_date, id_))
                conn.commit()
                print(" + updated (metacritic):", title, "| Release_Date:", release_date)
            except Exception as e:
                print(" ! db update failed (metacritic):", title, e)
                conn.rollback()
            finally:
                upd.close()

        except Exception as e:
            print(" ! error (metacritic):", title, e)
        time.sleep(SLEEP_BETWEEN)
    cur.close()
    conn.close()

def update_steam_rows():
    conn = db_connect()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT id, title, url FROM steam_games")
    rows = cur.fetchall()
    if VERBOSE: print(f"Steam: {len(rows)} rows to update")
    for r in rows:
        id_ = r.get('id')
        title = r.get('title')
        url = r.get('url')
        if not url:
            if VERBOSE: print(" - skip (no url):", title)
            continue
        try:
            resp = session.get(url, timeout=20)
            if resp.status_code != 200:
                if VERBOSE: print(" - fetch failed (steam):", title, resp.status_code)
                continue
            price, discount, genre = parse_steam_store_page(resp.text)

            upd = conn.cursor()
            try:
                upd.execute("""
                    UPDATE steam_games
                    SET price=%s, discount=%s, genre=%s
                    WHERE id=%s
                """, (price, discount, genre, id_))
                conn.commit()
                if VERBOSE: print(" + updated (steam):", title)
            except Exception as e:
                print(" ! db update failed (steam):", title, e)
                conn.rollback()
            finally:
                upd.close()

        except Exception as e:
            print(" ! error (steam):", title, e)
        time.sleep(SLEEP_BETWEEN)
    cur.close()
    conn.close()

# ====== Main ======
if __name__ == "__main__":
    print("Start update_db_only.py (will update existing tables, won't touch images)")
    try:
        update_metacritic_rows()
    except Exception as e:
        print("Metacritic update error:", e)
    try:
        update_steam_rows()
    except Exception as e:
        print("Steam update error:", e)
    print("Done.")
