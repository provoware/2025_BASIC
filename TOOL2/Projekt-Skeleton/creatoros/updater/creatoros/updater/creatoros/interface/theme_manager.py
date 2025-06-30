# -*- coding: utf-8 -*-
import json
import os

THEME_FILE = "creatoros/system/theme.json"
VALID_THEMES = ["hell", "dunkel", "barrierefrei"]

def get_current_theme(path=THEME_FILE):
    if not os.path.exists(path):
        return "hell"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data.get("theme", "hell")

def set_theme(name, path=THEME_FILE):
    if name not in VALID_THEMES:
        raise ValueError(f"Ungültiges Theme: {name}")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump({"theme": name}, f)
