#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

echo "=== Update 37: PanelWidget-Fix mit Patch-Tool ==="

# 1) Backup
mkdir -p "$BASE/conflicts"
cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
echo "⚠️ Backup: $GUI → conflicts/"

# 2) Sicherstellen, dass QFrame importiert wird
echo "▶️ QFrame-Import prüfen/ergänzen..."
if grep -q "from PyQt6.QtWidgets import" "$GUI"; then
  sed -i '/from PyQt6\.QtWidgets import (/ s/)/, QFrame)/' "$GUI"
  echo "   ✔ QFrame importiert."
else
  echo "❌ Import-Zeile nicht gefunden, bitte manuell prüfen."
fi

# 3) Patch PanelWidget-Klasse
echo "▶️ Wende Patch auf PanelWidget an…"
patch "$GUI" << 'EOF'
*** Begin Patch
*** Update File: creatoros/interface/steelcore_dashboard.py
@@
-class PanelWidget(QWidget):
+class PanelWidget(QFrame):
@@
-    def __init__(self,cfg,parent=None):
+    def __init__(self, cfg, parent=None):
@@
-        super().__init__(parent)
-        self.cfg=cfg
-        try:
-            self.setFrameShape(QFrame.Shape.StyledPanel)
-        except Exception:
-            pass
-        layout = QVBoxLayout(self)
-        layout.addWidget(QLabel(f"<b>Typ:</b> {cfg.get(type,–)}"))
-        layout.addWidget(QLabel(f"<b>Einstellungen:</b> {cfg.get(config,–)}"))
-        layout.setContentsMargins(5,5,5,5)
+        super().__init__(parent)
+        self.cfg = cfg
+        # Styled frame mit Auto-Repair
+        try:
+            self.setFrameShape(QFrame.Shape.StyledPanel)
+        except Exception:
+            pass
+        layout = QVBoxLayout(self)
+        layout.addWidget(QLabel(f"<b>Typ:</b> {cfg.get('type','')}"))
+        layout.addWidget(QLabel(f"<b>Einstellungen:</b> {cfg.get('config','')}"))
+        layout.setContentsMargins(5,5,5,5)
*** End Patch
EOF

# 4) Syntax-Check
echo "▶️ Syntax-Validierung…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler nach Patch!"
  exit 1
fi

# 5) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_37.txt"
ID: 37
Zeit: $STAMP
Beschreibung: PanelWidget-Klasse korrigiert (type/config quotes, en-dash entfernt) via patch
Dateien:
  - $GUI
EOF
echo "Update 37 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 37 erfolgreich abgeschlossen."
