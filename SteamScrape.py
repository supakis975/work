#!/usr/bin/env python3
# steamscrape.py
import requests
from bs4 import BeautifulSoup
import mysql.connector
import time
import re
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from urllib.parse import urljoin

# --- ตั้งค่า ---
STEAM_API_KEY = "20F643E9758380A2E5E35F18DDDB6E37"
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "info_games",
    "charset": "utf8mb4"
}

# Session with retries
session = requests.Session()
retries = Retry(total=3, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504])
session.mount("https://", HTTPAdapter(max_retries=retries))
session.headers.update({"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})

# --- Helpers DB: ensure steam_games has extra columns we need (if missing) ---
def ensure_columns(cur):
    # columns to ensure: steam_appid, review_percent, review_count, last_scraped
    # use INFORMATION_SCHEMA to check
    table = 'steam_games'
    needed = {
        "steam_appid": "VARCHAR(50)",
        "review_percent": "INT",
        "review_count": "INT",
        "last_scraped": "DATETIME"
    }
    for col, coltype in needed.items():
        cur.execute("""
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s AND COLUMN_NAME = %s
        """, (DB_CONFIG['database'], table, col))
        exists = cur.fetchone()[0]
        if not exists:
            # add column (nullable)
            sql = f"ALTER TABLE `{table}` ADD COLUMN `{col}` {coltype} NULL"
            try:
                cur.execute(sql)
                print(f"[DB] Added column `{col}` to `{table}`")
            except Exception as e:
                print(f"[DB] Failed to add column {col}: {e}")

# --- ฟังก์ชันดึงจำนวนผู้เล่น (current players) ---
def get_current_players(appid):
    if not appid:
        return "N/A"
    try:
        url = f"https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid={appid}&key={STEAM_API_KEY}"
        r = session.get(url, timeout=10)
        if r.status_code == 200:
            j = r.json()
            pc = j.get("response", {}).get("player_count")
            if pc is not None:
                return str(pc)
    except Exception as e:
        print(f"[players] appid {appid}: {e}")
    return "N/A"

# --- ฟังก์ชันดึงรายละเอียดจากหน้าเกม (release_date, genre, reviews) ---
def scrape_game_details(game_url):
    release_date = "N/A"
    genre = "N/A"
    review_percent = None
    review_count = None

    try:
        r = session.get(game_url, timeout=15)
        if r.status_code != 200:
            print(f"[detail] cannot fetch {game_url} status {r.status_code}")
            return release_date, genre, review_percent, review_count

        soup = BeautifulSoup(r.text, "html.parser")

        # release date
        date_div = soup.select_one("div.release_date div.date") or soup.select_one("div.date")
        if date_div:
            release_date = date_div.get_text(strip=True)

        # genre links
        genre_links = soup.select("a[href*='genre/']")
        if genre_links:
            genre = ", ".join([g.get_text(strip=True) for g in genre_links])

        # user review block - try to get English Reviews row first
        user_reviews_div = soup.find("div", id="userReviews")
        target = None
        if user_reviews_div:
            anchors = user_reviews_div.find_all("a", class_="user_reviews_summary_row")
            # prefer English Reviews row
            for a in anchors:
                subtitle = a.find("div", class_="subtitle")
                subtitle_text = subtitle.get_text(strip=True) if subtitle else ""
                if "English" in subtitle_text or "English Reviews" in subtitle_text:
                    target = a
                    break
            if not target and anchors:
                # fallback to first anchor (recent or aggregated)
                target = anchors[0]

            if target:
                # try span.nonresponsive_hidden.responsive_reviewdesc
                desc_span = target.select_one("span.nonresponsive_hidden.responsive_reviewdesc")
                if desc_span:
                    txt = desc_span.get_text(" ", strip=True)
                    # find percent
                    m = re.search(r"(\d{1,3})\s*%", txt)
                    if m:
                        try:
                            review_percent = int(m.group(1))
                        except:
                            review_percent = None
                    # find count like 10,464
                    mcount = re.search(r"([\d,]{1,20})", txt)
                    if mcount:
                        try:
                            review_count = int(mcount.group(1).replace(",", ""))
                        except:
                            review_count = None
                # fallback: meta tags
                if review_count is None:
                    meta_count = target.find("meta", {"itemprop": "reviewCount"})
                    if meta_count and meta_count.has_attr("content"):
                        try:
                            review_count = int(meta_count["content"])
                        except:
                            review_count = None
                if review_percent is None:
                    # try .game_review_summary text for a percent pattern
                    gs = target.select_one("span.game_review_summary")
                    if gs:
                        m2 = re.search(r"(\d{1,3})\s*%", gs.get_text(strip=True))
                        if m2:
                            try:
                                review_percent = int(m2.group(1))
                            except:
                                review_percent = None

    except Exception as e:
        print(f"[detail] error scraping {game_url}: {e}")

    return release_date, genre, review_percent, review_count

# --- ฟังก์ชันหลักดึงหน้ารายการและรายละเอียด ---
def scrape_steam(pages=2):
    base_url = "https://store.steampowered.com/search/?sort_by=Reviews_DESC&supportedlang=english&filter=topsellers&page="
    results = []

    for page in range(1, pages + 1):
        print(f"\n[list] Loading search page {page} ...")
        url = base_url + str(page)
        try:
            r = session.get(url, timeout=15)
            if r.status_code != 200:
                print(f"[list] failed to load {url} status {r.status_code}")
                continue
            soup = BeautifulSoup(r.text, "html.parser")
            games = soup.select("a.search_result_row")
            if not games:
                print("[list] no game rows found on page")
                continue

            for g in games:
                try:
                    title = g.select_one("span.title").get_text(strip=True) if g.select_one("span.title") else "N/A"

                    # price
                    price = "N/A"
                    price_el = g.select_one("div.discount_final_price")
                    if price_el:
                        price = price_el.get_text(strip=True)
                    else:
                        p2 = g.select_one("div.search_price")
                        if p2:
                            price = p2.get_text(" ", strip=True)

                    # discount
                    discount = "0%"
                    discount_block = g.select_one("div.discount_block.search_discount_block")
                    if discount_block and discount_block.has_attr("data-discount"):
                        discount = discount_block["data-discount"] + "%"

                    # url (absolute)
                    game_url = g.get("href")
                    if game_url and game_url.startswith("/"):
                        game_url = urljoin("https://store.steampowered.com", game_url)

                    # image
                    image_el = g.select_one("div.search_capsule img")
                    image_url = image_el.get("src") if image_el and image_el.has_attr("src") else None

                    # appid
                    appid = None
                    m = re.search(r'/app/(\d+)', game_url or "")
                    if m:
                        appid = m.group(1)

                    # players via API
                    players = get_current_players(appid) if appid else "N/A"

                    # detail: release_date, genre, reviews
                    release_date, genre, review_percent, review_count = scrape_game_details(game_url or "")

                    results.append({
                        "appid": appid,
                        "title": title,
                        "release_date": release_date,
                        "genre": genre,
                        "price": price,
                        "discount": discount,
                        "players": players,
                        "url": game_url,
                        "image_url": image_url,
                        "review_percent": review_percent,
                        "review_count": review_count
                    })

                    print(f"[item] {title} | review%={review_percent} | reviews={review_count}")
                    time.sleep(1.2)

                except Exception as e:
                    print("[list] per-game error:", e)
                    continue

            time.sleep(2)

        except Exception as e:
            print("[list] fetch page error:", e)
            continue

    return results

# --- Save to DB: update if exists (match by steam_appid if available, else by url) ---
def save_to_db(games):
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cur = conn.cursor()
        ensure_columns(cur)

        for g in games:
            try:
                # first try to find existing row by steam_appid (if present)
                found_id = None
                if g.get("appid"):
                    cur.execute("SELECT id FROM steam_games WHERE steam_appid = %s LIMIT 1", (g["appid"],))
                    r = cur.fetchone()
                    if r:
                        found_id = r[0]

                # fallback: find by URL
                if not found_id and g.get("url"):
                    cur.execute("SELECT id FROM steam_games WHERE url = %s LIMIT 1", (g["url"],))
                    r = cur.fetchone()
                    if r:
                        found_id = r[0]

                if found_id:
                    # UPDATE existing row
                    update_sql = """
                        UPDATE steam_games SET
                            title = %s,
                            release_date = %s,
                            genre = %s,
                            price = %s,
                            discount = %s,
                            players = %s,
                            image_url = %s,
                            steam_appid = %s,
                            review_percent = %s,
                            review_count = %s,
                            last_scraped = NOW()
                        WHERE id = %s
                    """
                    cur.execute(update_sql, (
                        g.get("title"),
                        g.get("release_date"),
                        g.get("genre"),
                        g.get("price"),
                        g.get("discount"),
                        g.get("players"),
                        g.get("image_url"),
                        g.get("appid"),
                        g.get("review_percent"),
                        g.get("review_count"),
                        found_id
                    ))
                    conn.commit()
                    print(f"[db] Updated id={found_id} title='{g.get('title')}'")
                else:
                    # INSERT new row
                    insert_sql = """
                        INSERT INTO steam_games
                        (title, release_date, genre, price, discount, players, url, image_url, steam_appid, review_percent, review_count, last_scraped)
                        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NOW())
                    """
                    cur.execute(insert_sql, (
                        g.get("title"),
                        g.get("release_date"),
                        g.get("genre"),
                        g.get("price"),
                        g.get("discount"),
                        g.get("players"),
                        g.get("url"),
                        g.get("image_url"),
                        g.get("appid"),
                        g.get("review_percent"),
                        g.get("review_count")
                    ))
                    conn.commit()
                    print(f"[db] Inserted title='{g.get('title')}'")
            except Exception as e:
                print("[db] per-row error:", e)
                conn.rollback()

        cur.close()
        conn.close()
        print(f"[db] Done saving {len(games)} items.")
    except Exception as e:
        print("[db] connection error:", e)

# --- main ---
if __name__ == "__main__":
    pages_to_scrape = 2   # ปรับตามต้องการ
    scraped = scrape_steam(pages=pages_to_scrape)
    if scraped:
        save_to_db(scraped)
    else:
        print("No data scraped.")
