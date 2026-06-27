import os
import requests
from datetime import date, timedelta
from dotenv import load_dotenv
import snowflake.connector

load_dotenv()

SNOWFLAKE_CONFIG = {
    "account":   os.getenv("SNOWFLAKE_ACCOUNT"),
    "user":      os.getenv("SNOWFLAKE_USER"),
    "password":  os.getenv("SNOWFLAKE_PASSWORD"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
    "database":  "ECOMMERCE_BRONZE_DB",
    "schema":    "FRANKFURTER",
    "role":      "ECOMMERCE_ENGINEER",
}

BASE     = "BRL"
TARGET   = "USD"
API_URL  = "https://api.frankfurter.app"


def get_last_loaded_date(conn):
    cur = conn.cursor()
    cur.execute("SELECT MAX(rate_date) FROM EXCHANGE_RATES_RAW")
    result = cur.fetchone()[0]
    cur.close()
    # If table is empty, start from 2022-01-01
    return result if result else date(2016, 1, 1)


def fetch_rates(start: date, end: date) -> list[dict]:
    url = f"{API_URL}/{start}..{end}?from={BASE}&to={TARGET}"
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    data = response.json()

    rows = []
    for rate_date, currencies in data["rates"].items():
        rows.append({
            "rate_date":       rate_date,
            "base_currency":   BASE,
            "target_currency": TARGET,
            "rate":            currencies[TARGET],
        })
    return rows


def insert_rates(conn, rows: list[dict]):
    if not rows:
        print("No new rows to insert.")
        return

    cur = conn.cursor()
    cur.executemany(
        """
        INSERT INTO EXCHANGE_RATES_RAW (rate_date, base_currency, target_currency, rate)
        VALUES (%s, %s, %s, %s)
        """,
        [(r["rate_date"], r["base_currency"], r["target_currency"], r["rate"]) for r in rows],
    )
    conn.commit()
    cur.close()
    print(f"Inserted {len(rows)} rows.")


def run():
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)

    conn.cursor().execute(f"USE WAREHOUSE {SNOWFLAKE_CONFIG['warehouse']}")
    
    last_date = get_last_loaded_date(conn)
    start     = last_date + timedelta(days=1)
    end       = date.today() - timedelta(days=1)  # up to yesterday

    if start > end:
        print(f"Already up to date. Last loaded: {last_date}")
        conn.close()
        return

    print(f"Fetching rates from {start} to {end}...")
    rows = fetch_rates(start, end)
    insert_rates(conn, rows)
    conn.close()


if __name__ == "__main__":
    run()