# AGENTS.md

**Version:** 1.1.0\
**Last-Updated:** 2025-06-29

---

## 1. Metadaten

- **Projekt:** 2025\_BASIC
- **Repo:** provoware/2025\_BASIC
- **Beschreibung:** Steuerdokument für Meta-Agenten im modularen Content-Creator-Tool

---

## 2. Globale Richtlinien

- **Codestil:** PEP8, automatisiert mit **Black** und **isort** via GitHub Actions.
- **Commit-Format:** Conventional Commits (`feat:`, `fix:`, `chore:`).
- **PR-Vorlage:** Issue-Nummer, Beschreibung, Teststatus (✅) verpflichtend.

---

## 3. Agenten-Definitionen

### 3.1 Agent: DR\_ALLWISSEND\_POPPSEN

- **Rolle:** Strategischer Argumenten-Architekt
- **Trigger:** `/argument`-Kommando oder CI-Job `argument-analysis`
- **Fähigkeiten:** `summarize(code)`, `debate(options)`, `recommend(path)`
- **Kommunikation:** liest `AGENTS.md`, schreibt in `/logs/arguments.log`

### 3.2 Agent: DEBUG-WÄCHTER

- **Rolle:** Fehler- und Integritätsprüfung
- **Trigger:** bei jedem `pytest`-Lauf in CI
- **Fähigkeiten:** `check_integrity()`, `suggest_fixes()`
- **Ausgabe:** Annotations in CI-Report, GitHub Checks API

### 3.3 Agent: DATEIMANAGERIN

- **Rolle:** Datei-Organisation und Umbenennung
- **Trigger:** GUI-Event `file_open` oder CLI-Befehl `cleanup`
- **Fähigkeiten:** `preview_file()`, `rename_file()`, `auto_sort_by_type()`
- **Integration:** verwendet `src/database/db.py` für Archiv-Status

### 3.4 Agent: GitPusher

- **Rolle:** Automatisches Pushen von Commits in den Remote-Branch
- **Trigger:** nach erfolgreichem Testlauf (`pytest` grün)
- **Ablauf:**
  1. `git add .`
  2. `git commit -m "Auto-Commit: Tests grün – $(date +'%Y-%m-%d %H:%M:%S')"`
  3. `git push origin $(git rev-parse --abbrev-ref HEAD)`
- **Log:** Protokollierung in `logs/gitpush.log`

---

## 4. Workflow & Orchestrierung

1. **Formatter** → Pre-commit Hook
2. **Tester** → nach Push
3. **DocGen** → nach Tests
4. **GitPusher** → nach erfolgreichem Push
5. **Release** → per Tag + `release_notes()`

---

## 5. Optimierungsvorschläge für GitPusher

1. **Secure Token-Management**\
   – In GitHub Actions: verwende `${{ secrets.GITHUB_TOKEN }}` mit `ad-m/github-push-action`, statt Klartext-Credentials.
2. **Automatische Changelog-Erzeugung**\
   – Vor Push:
   ```bash
   git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 @^)..@ > CHANGELOG.md
   git add CHANGELOG.md
   ```
3. **Fehlerrobustes Rollback**\
   – Bei Push-Fehlern:
   ```bash
   if ! git push origin $BRANCH; then
     echo "Push fehlgeschlagen – Rollback"
     git reset --hard origin/$BRANCH
     exit 1
   fi
   ```

---

## 6. Automatisierte Validierung

- **Schema-Check:** CI-Job `validate-agents` gegen `agents.schema.json`.
- **Markdown-Lint:** `markdownlint` im CI.

---

## 7. Changelog & Versionierung

- **v1.0.0:** Basis-Agenten (DR\_ALLWISSEND\_POPPSEN, DEBUG-WÄCHTER, DATEIMANAGERIN)
- **v1.1.0:** `GitPusher`-Agent & Optimierungsvorschläge hinzugefügt

---

*Ende des Dokuments*

