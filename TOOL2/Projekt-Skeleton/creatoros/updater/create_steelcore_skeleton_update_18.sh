    #!/usr/bin/env bash
    set -euo pipefail

    BASE=creatoros/updater
    META=$BASE/meta/changes
    TOOLS=creatoros/tools
    CONFLICT=$BASE/conflicts
    LOGS=creatoros/logs
    TARGET=$TOOLS/smart_mover.py
    WRAP=start_smart_sortfix.sh

    mkdir -p "$META" "$CONFLICT" "$LOGS" "$TOOLS"

    if [ -f "$TARGET" ]; then
      mv "$TARGET" "$CONFLICT/smart_mover.py.bak.$(date +%s)"
      echo "[WARNUNG] Bestehendes smart_mover.py nach conflicts/ verschoben"
    fi

    cat <<'EOF' > "$TARGET"
    # -*- coding: utf-8 -*-
import os
import shutil

ROOT = "creatoros"
CONFLICTS = os.path.join(ROOT, "updater", "conflicts")
TARGETS = {
    "create_steelcore_skeleton_update_": os.path.join(ROOT, "updater", "scripts"),
    "create_steelcore_skeleton_re-update_": os.path.join(ROOT, "updater", "scripts"),
    "start_debug.py": ROOT,
}

def log(msg):
    with open(os.path.join(ROOT, "logs", "smart_mover.log"), "a") as f:
        f.write(msg + "\n")
    print(msg)

def ensure_dirs():
    os.makedirs(CONFLICTS, exist_ok=True)
    for dst in TARGETS.values():
        os.makedirs(dst, exist_ok=True)

def scan_and_move():
    ensure_dirs()
    for root, dirs, files in os.walk(ROOT):
        for name in files:
            full = os.path.join(root, name)
            rel = os.path.relpath(full, ROOT)
            moved = False
            for key, dest in TARGETS.items():
                if name.startswith(key) or name == key:
                    if os.path.abspath(dest) not in os.path.abspath(full):
                        shutil.move(full, os.path.join(dest, name))
                        log(f"[AUTO-MOVE] {rel} → {os.path.join(dest, name)}")
                        moved = True
                        break
            if not moved and root == ROOT:
                shutil.move(full, os.path.join(CONFLICTS, name))
                log(f"[UNSORTED] {rel} → conflicts")

if __name__ == "__main__":
    scan_and_move()
EOF

    cat <<'EOF' > "$WRAP"
    #!/usr/bin/env bash
set -euo pipefail
python3 creatoros/tools/smart_mover.py
EOF

    chmod +x "$WRAP"

    TIMESTAMP=$(date --iso-8601=seconds)
    echo -e "ID: 18\nZeit: $TIMESTAMP\nBeschreibung: Intelligentes Struktur-Sortierwerkzeug (smart_mover)\nDateien:\n  - $TARGET\n  - $WRAP" > "$META/change_18.txt"
    echo "Update 18 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
    md5sum "$TARGET" "$WRAP" >> "$BASE/CHECKSUMS.txt"

    echo "✅ Update 18 erfolgreich abgeschlossen."
