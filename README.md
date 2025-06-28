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
