#!/usr/bin/env bash
set -euo pipefail

mkdir -p creatoros/scripts creatoros/tools creatoros/updater/conflicts creatoros/logs creatoros/snapshots

for d in creatoros creatoros/modules creatoros/updater creatoros/logs creatoros/tools creatoros/scripts creatoros/snapshots; do
  echo "__pycache__/
*.pyc
*.pyo
*.log
*.db
*.sqlite
*.zip
.mypy_cache/
" > "$d/.gitignore"
  echo "# Ordnerbeschreibung

Diese Datei dient als Platzhalter zur Dokumentation dieses Moduls." > "$d/README.md"
done

# Startskripte verschieben
mv start.sh creatoros/scripts/start.sh || true
mv Steel-Core_MAX_v2.sh creatoros/scripts/Steel-Core_MAX_v2.sh || true

# Cleanup-Tool fix
echo '# -*- coding: utf-8 -*-
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
' > creatoros/tools/fix_mypy_cache.py
echo '#!/usr/bin/env bash
set -euo pipefail
python3 creatoros/tools/fix_mypy_cache.py
' > start_fix_mypy.sh
chmod +x start_fix_mypy.sh

# Protokoll
STAMP=$(date --iso-8601=seconds)
echo -e "ID: 19\nZeit: $STAMP\nBeschreibung: Struktur-Fix + Schnellreparatur (mypy_cache, .gitignore)\nDateien:\n  - .gitignore in Kernordnern\n  - README.md in Kernordnern\n  - start_fix_mypy.sh\n  - fix_mypy_cache.py\n  - start.sh verschoben\n  - Steel-Core_MAX_v2.sh verschoben" > creatoros/updater/meta/changes/change_19.txt
echo "Update 19 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum creatoros/scripts/start.sh creatoros/scripts/Steel-Core_MAX_v2.sh start_fix_mypy.sh creatoros/tools/fix_mypy_cache.py >> creatoros/updater/CHECKSUMS.txt

echo "✅ Update 19 erfolgreich abgeschlossen."
