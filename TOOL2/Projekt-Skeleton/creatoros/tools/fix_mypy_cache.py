# -*- coding: utf-8 -*-
import os
import shutil

def move_mypy_cache():
    src = ".mypy_cache"
    dst = "creatoros/updater/conflicts/mypy_cache"
    if os.path.exists(src):
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.move(src, dst)
        print(f"[FIX] .mypy_cache verschoben nach {dst}")
    else:
        print("✅ .mypy_cache nicht gefunden (bereits sauber)")

if __name__ == "__main__":
    move_mypy_cache()

