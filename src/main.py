import psycopg2
from psycopg2.extras import RealDictCursor
import pathlib
from tabulate import tabulate  


DB_CONFIG = {
    "dbname": "otp_analysis",
    "user": "postgres",
    "password": "ваш_пароль",   
    "host": "localhost",
    "port": 5432
}


QUERIES_FILE = pathlib.Path(__file__).resolve().parent.parent / "sql" / "queries.sql"

def load_queries(path):
    """Загружает все запросы из файла и делит их по ';'"""
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    return [q.strip() for q in text.split(";") if q.strip()]

def run_queries(conn, queries):
    """Выполняет все запросы и печатает красиво"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        for i, q in enumerate(queries, 1):
            print(f"\n=== Query {i} ===")
            cur.execute(q)
            rows = cur.fetchall()
            if not rows:
                print("Нет данных")
                continue
            
            print(tabulate(rows[:10], headers="keys", tablefmt="psql"))
            if len(rows) > 10:
                print(f"... {len(rows)-10} more rows")

def main():
    queries = load_queries(QUERIES_FILE)
    print(f"Загружено {len(queries)} SQL-запросов из {QUERIES_FILE}")

    with psycopg2.connect(**DB_CONFIG) as conn:
        run_queries(conn, queries)  

if __name__ == "__main__":
    main()
