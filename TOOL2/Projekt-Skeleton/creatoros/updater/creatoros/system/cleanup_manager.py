# -*- coding: utf-8 -*-
import os
import hashlib

SKEL_ROOT = "creatoros"
KNOWN_FOLDERS = {"boot", "system", "interface", "modules", "db", "logs", "plugins", "tests", "updater"}
PROTECTED_FILES = {"README.md", ".gitignore"}

def find_orphans():
    orphans = []
    for root, dirs, files in os.walk(SKEL_ROOT):
        for file in files:
            full = os.path.relpath(os.path.join(root, file), start=SKEL_ROOT)
            if full.startswith("updater/meta") or full.startswith("updater/conflicts"):
                continue
            if not any(part in KNOWN_FOLDERS for part in full.split(os.sep)):
                orphans.append(full)
    return orphans

def md5_of_file(filepath):
    with open(filepath, "rb") as f:
        return hashlib.md5(f.read()).hexdigest()

def dry_report():
    orphans = find_orphans()
    print("🔎 Orphan-Dateien (nicht zugeordnet):")
    for o in orphans:
        print(f"  - {o}")

if __name__ == "__main__":
    dry_report()
