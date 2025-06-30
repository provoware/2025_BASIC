#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

echo "=== Update 38: Self-Heal für Unicode & f-Strings ==="

# 1) Backup
mkdir -p "$BASE/conflicts"
cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
echo "⚠️ Backup: $GUI → conflicts/"

# 2) Präfix Self-Heal-Code einfügen
echo "▶️ Self-Heal-Routine einfügen…"
SELFHEAL=$(cat << 'PYCODE'
# ──────────────────────────────────────────────
# Self-Heal: Sanitize En-Dash & korrigiere f-Strings
# Wird vor allem für PanelWidget angewandt
import re, os
def _steelcore_self_heal(path):
    try:
        text = open(path, "r", encoding="utf-8").read()
        new = text
        # Unicode En-Dash → ASCII Hyphen
        new = new.replace("–", "-")
        # korrigiere fehlerhafte cfg.get(...) Patterns
        new = re.sub(r"cfg\.get\(\s*type\s*,\s*-\s*\)", "cfg.get('type','')", new)
        new = re.sub(r"cfg\.get\(\s*config\s*,\s*-\s*\)", "cfg.get('config','')", new)
        if new != text:
            open(path, "w", encoding="utf-8").write(new)
    except Exception:
        pass

# Anwenden bei jedem Start
_steelcore_self_heal(__file__)
# ──────────────────────────────────────────────
PYCODE
)

# Präfix nur einfügen, falls nicht schon vorhanden
if ! grep -q "_steelcore_self_heal" "$GUI"; then
  tmp=$(mktemp)
  echo "$SELFHEAL" > "$tmp"
  cat "$GUI" >> "$tmp"
  mv "$tmp" "$GUI"
  echo "   ✔ Self-Heal-Routine hinzugefügt."
else
  echo "   ✔ Self-Heal-Routine bereits vorhanden."
fi

# 3) Entferne verbleibende fehlerhafte Zeichen direkt nach Self-Heal
echo "▶️ Direkte Korrektur prüfen…"
sed -i "s/`printf '\u2013'`/-/g" "$GUI"      # En-Dash → Hyphen
sed -i "s/cfg\.get(type,-)/cfg.get('type','')/g" "$GUI"
sed -i "s/cfg\.get(config,-)/cfg.get('config','')/g" "$GUI"
echo "   ✔ Direkte Korrekturen durchgeführt."

# 4) Syntax-Validierung
echo "▶️ Syntax-Validierung…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler nach Self-Heal."
else
  echo "❌ Syntax-Fehler bleiben! Bitte Code manuell prüfen."
  exit 1
fi

# 5) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_38.txt"
ID: 38
Zeit: $STAMP
Beschreibung: Self-Heal für En-Dash und f-String-Patterns in steelcore_dashboard.py
Dateien:
  - $GUI
EOF

echo "Update 38 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 38 erfolgreich abgeschlossen."
