# 2025_BASIC

Dies ist ein Beispielprojekt. 

## Konfiguration

Lege eine Datei `config.ini` im Projektverzeichnis an. Darin werden u.a. folgende Werte eingetragen:

```
[database]
path = pfad/zur/datenbank.db
user = benutzername
password = geheim
```

Eine Vorlage findest du in `config.example.ini`. Kopiere sie zu `config.ini` und passe die Werte an deine Umgebung an. So bleiben Zugangsdaten aus dem Quellcode heraus.

Trage `config.ini` zudem in deine `.gitignore` ein, damit diese Datei nicht versehentlich versioniert wird.

Falls beim Datenbankzugriff etwas schiefgeht, gib dem Nutzer eine klare Meldung aus, z.B. "Verbindung fehlgeschlagen" oder "Eintrag konnte nicht gespeichert werden".

## Dashboard mit Notizfeld

Das Skript `dashboard.py` startet ein kleines Fenster mit einem Textfeld und
einem "Speichern"-Knopf. Notizen werden in der Datei gespeichert, die in
`config.ini` unter `[notes]` angegeben ist.

### Ausprobieren

1. `config.example.ini` kopieren und als `config.ini` anlegen.
2. Bei Bedarf den Pfad unter `[notes]` anpassen (Standard: `notizen.txt`).
3. `python dashboard.py` ausführen.

Die eingegebenen Notizen landen in der angegebenen Datei und können dort später
weiterbearbeitet werden.
