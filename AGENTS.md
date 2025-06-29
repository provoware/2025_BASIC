# AGENTS.md

## 1. Metadaten & Versionierung
- **Projekt:** <Projektname>
- **Repo:** GitHub:provoware/2025_BASIC
- **Version:** 1.2.3
- **Last-Updated:** YYYY-MM-DD

## 2. Globale Richtlinien
- **Codestyle:** `black` + `isort` via CI
- **Linting:** `flake8`, `mypy`
- **PR-Vorlage:** Issue-Referenz, Screenshots, Tests (✅)

## 3. Agenten-Definitionen

### 3.1 Agent: Formatter
- **Rolle:** Formatieren von Code-Dateien
- **Trigger:** Pre-commit
- **Fähigkeit:** `format_code(path)`
- **Ausgabe:** schreibt `formatter.log`

### 3.2 Agent: Tester
- **Rolle:** Ausführen von Unit- & Integrationstests
- **Trigger:** nach Formatter
- **Fähigkeit:** `run_tests()`
- **Integration:** GitHub Checks API für Status

### 3.3 Agent: DocGen
- **Rolle:** Generierung technischer Dokumentation
- **Trigger:** nach erfolgreichem Test
- **Fähigkeit:** `generate_docs()` (liefert HTML/PDF)

## 5. Workflow-Orchestrierung
1. **Formatter** → Pre-commit
2. **Tester** → nach Push
3. **DocGen** → nach Tests

## 6. Automatisierte Validierung

## 7. Changelog
