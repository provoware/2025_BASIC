#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

echo "=== Update 36: PanelWidget als QFrame mit Selfheal ==="

# 1) Backup
mkdir -p "$BASE/conflicts"
cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
echo "⚠️ Backup: $GUI → conflicts/"

# 2) Sicherstellen, dass QFrame importiert wird
if ! grep -q "QFrame" "$GUI"; then
  sed -i "s/from PyQt6.QtWidgets import (/& QFrame,/" "$GUI"
  echo "   ✔ QFrame-Import hinzugefügt."
else
  echo "   ✔ QFrame-Import bereits vorhanden."
fi

# 3) Neue PanelWidget-Klasse einfügen (ersetze alte)
awk '
  BEGIN {repl=0}
  /^class PanelWidget/ { 
    repl=1
    print "class PanelWidget(QFrame):"
    print "    def __init__(self, cfg, parent=None):"
    print "        super().__init__(parent)"
    print "        self.cfg = cfg"
    print "        try:"
    print "            self.setFrameShape(QFrame.Shape.StyledPanel)"
    print "        except Exception:"
    print "            pass"
    print "        layout = QVBoxLayout(self)"
    print "        layout.addWidget(QLabel(f\"<b>Typ:</b> {cfg.get('type','–')}\"))"
    print "        layout.addWidget(QLabel(f\"<b>Einstellungen:</b> {cfg.get('config','–')}\"))"
    print "        layout.setContentsMargins(5,5,5,5)"
    next
  }
  /^class MainWindow/ { 
    repl=0
  }
  repl==1 { next }
  { print }
' "$GUI" > "$GUI.tmp" && mv "$GUI.tmp" "$GUI"
echo "   ✔ PanelWidget-Klasse neu implementiert."

# 4) Syntax-Check
echo "▶️ Syntax-Validierung…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler nach Update 36!"
  exit 1
fi

# 5) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_36.txt"
ID: 36
Zeit: $STAMP
Beschreibung: PanelWidget als QFrame neu implementiert, Selfheal-try/except
Dateien:
  - $GUI
EOF
echo "Update 36 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 36 erfolgreich abgeschlossen."
