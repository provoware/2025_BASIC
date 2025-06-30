# -*- coding: utf-8 -*-
import sqlite3
import os

DB_PATH = "creatoros/db/steelcore.sqlite3"

def init_db(path=DB_PATH):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS eintrag (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titel TEXT NOT NULL,
            kategorie TEXT NOT NULL
        );
    """)
    conn.commit()
    conn.close()

def insert_eintrag(titel, kategorie, path=DB_PATH):
    conn = sqlite3.connect(path)
    conn.execute("INSERT INTO eintrag (titel, kategorie) VALUES (?, ?)", (titel, kategorie))
    conn.commit()
    conn.close()

def get_all_eintraege(path=DB_PATH):
    conn = sqlite3.connect(path)
    cur = conn.execute("SELECT titel, kategorie FROM eintrag")
    results = cur.fetchall()
    conn.close()
    return results
