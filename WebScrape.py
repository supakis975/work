# webscrape.py
import os
import re
import time
import json
import requests
import pandas as pd
import mysql.connector
from bs4 import BeautifulSoup
from mysql.connector import Error
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from urllib.parse import urljoin
import html

# ---- CONFIG ----
BASE_URL = "https://www.metacritic.com"
LIST_TEMPLATE = "https://www.metacritic.com/browse/game/pc/all/all-time/userscore/?releaseYearMin=2020&releaseYearMax=2025&platform=pc&page={page}"
HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0 Safari/537.36"}
OUTPUT_FOLDER = "output"
PAGES = 2  # ปรับจำนวนหน้า

# MySQL config
MYSQL_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "info_games",
}

# ---- DB ----
CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS metacritic_games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(512) UNIQUE,
    Release_Date VARCHAR(255),
    Metascore VARCHAR(50),
    User_Score VARCHAR(50),
    User_Review VARCHAR(50),
    Genre VARCHAR(512),
    URL TEXT,
    Image_url TEXT,
    last_scraped DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"""

def init_db():
    conn = mysql.connector.connect(**MYSQL_CONFIG)
    cur = conn.cursor()
    cur.execute(CREATE_TABLE_SQL)
    conn.commit()
    cur.close()
    return conn

# ---- Session ----
session = requests.Session()
retries = Retry(total=3, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504])
session.mount("https://", HTTPAdapter(max_retries=retries))
session.headers.update(HEADERS)

def safe_get(url, timeout=15):
    try:
        return session.get(url, timeout=timeout)
    except Exception as e:
        print(f"[safe_get] Error fetching {url}: {e}")
        return None

def ensure_folder(path):
    os.makedirs(path, exist_ok=True)

# ---- Image helper ----
def extract_image_url_from_card(card):
    img_tag = card.select_one("picture img") or card.select_one("img")
    if not img_tag:
        return None
    candidates = []
    for attr in ("src", "data-src", "srcset", "data-srcset"):
        val = img_tag.get(attr)
        if val:
            if "srcset" in attr and "," in val:
                parts = [p.strip() for p in val.split(",")]
                last = parts[-1].split()[0]
                candidates.append(last)
            else:
                candidates.append(val)
    for raw in candidates:
        if not raw: continue
        raw = html.unescape(raw.strip())
        if raw.startswith("//"): raw = "https:" + raw
        if raw.startswith("/"): raw = urljoin(BASE_URL, raw)
        if raw.startswith("http"): return raw
    return None

# ---- Listing ----
def parse_listing_for_games(list_html):
    soup = BeautifulSoup(list_html, "html.parser")
    cards = soup.find_all("div", class_="c-finderProductCard")
    results = []
    for card in cards:
        try:
            title_div = card.find("div", class_="c-finderProductCard_title")
            title = title_div["data-title"].strip() if title_div and title_div.has_attr("data-title") else None
            a = card.find("a", href=True)
            url = urljoin(BASE_URL, a['href']) if a else None

            release_date = "N/A"
            meta_div = card.find("div", class_="c-finderProductCard_meta")
            if meta_div:
                date_span = meta_div.find("span", class_="u-text-uppercase")
                if date_span:
                    release_date = date_span.get_text(strip=True)

            image_url = extract_image_url_from_card(card)

            results.append({
                "title": title or "N/A",
                "url": url or "N/A",
                "release_date": release_date,
                "image_url": image_url
            })
        except Exception as e:
            print("[parse_listing] card parse error:", e)
            continue
    return results

# ---- Detail ----
def parse_detail_page(html, page_url):
    soup = BeautifulSoup(html, "html.parser")

    metascore = "N/A"
    try:
        el = soup.select_one("div.c-productScoreInfo_scoreNumber span")
        if el: metascore = el.get_text(strip=True)
    except: pass

    userscore = "N/A"
    try:
        el = soup.select_one("div.c-productScoreInfo_scoreNumber.u-float-right span")
        if el: userscore = el.get_text(strip=True)
    except: pass

    genre = "N/A"
    try:
        genre_ul = soup.find("ul", class_="c-genreList")
        if genre_ul:
            items = genre_ul.find_all("span", class_="c-globalButton_label")
            if items: genre = ", ".join([it.get_text(strip=True) for it in items])
    except: pass

    # ดึง user_review %
    user_review = "N/A"
    try:
        stats = soup.select_one("div.c-reviewsStats.u-grid.u-text-center")
        if stats:
            pos = stats.select_one("div.c-reviewsStats_positiveStats span.g-text-bold")
            if pos:
                text = pos.get_text(strip=True)  # เช่น "96% Positive"
                if "%" in text:
                    user_review = text.split()[0]  # "96%"
    except Exception as e:
        print("[parse_detail] user_review error:", e)

    return metascore, userscore, genre, user_review

# ---- Main ----
def run_scrape(pages=PAGES):
    ensure_folder(OUTPUT_FOLDER)

    conn = init_db()
    cur = conn.cursor()

    all_results = []

    for page in range(pages):
        list_url = LIST_TEMPLATE.format(page=page)
        print(f"\n--- Loading list page: {list_url}")
        r = safe_get(list_url)
        if not r or r.status_code != 200:
            continue

        listing_games = parse_listing_for_games(r.text)
        print(f"[run_scrape] Found {len(listing_games)} games on page {page}")

        for item in listing_games:
            title = item['title']
            url = item['url']
            release_date = item['release_date']
            image_url = item['image_url']

            metascore = userscore = genre = user_review = "N/A"
            if url and url != "N/A":
                dr = safe_get(url)
                if dr and dr.status_code == 200:
                    metascore, userscore, genre, user_review = parse_detail_page(dr.text, url)

            # INSERT or UPDATE
            try:
                sql = """
                INSERT INTO metacritic_games
                (Title, Release_Date, Metascore, User_Score, User_Review, Genre, URL, Image_url)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
                ON DUPLICATE KEY UPDATE
                  Release_Date=VALUES(Release_Date),
                  Metascore=VALUES(Metascore),
                  User_Score=VALUES(User_Score),
                  User_Review=VALUES(User_Review),
                  Genre=VALUES(Genre),
                  URL=VALUES(URL),
                  Image_url=VALUES(Image_url)
                """
                cur.execute(sql, (title, release_date, metascore, userscore, user_review, genre, url, image_url))
                conn.commit()
                print(f"✔ Saved: {title} ({user_review})")
            except Exception as e:
                print(f"[DB error] {title}: {e}")
                conn.rollback()

            all_results.append({
                "Title": title,
                "Release Date": release_date,
                "Metascore": metascore,
                "User Score": userscore,
                "User Review": user_review,
                "Genre": genre,
                "URL": url,
                "Image_url": image_url
            })
            time.sleep(1)

    # Export
    df = pd.DataFrame(all_results)
    csv_p = os.path.join(OUTPUT_FOLDER, "metacritic_pc_games.csv")
    json_p = os.path.join(OUTPUT_FOLDER, "metacritic_pc_games.json")
    df.to_csv(csv_p, index=False, encoding="utf-8-sig")
    with open(json_p, "w", encoding="utf-8") as f:
        json.dump(all_results, f, ensure_ascii=False, indent=2)

    print(f"\nSaved CSV: {csv_p}\nSaved JSON: {json_p}")
    cur.close()
    conn.close()

if __name__ == "__main__":
    run_scrape(pages=PAGES)
