# -*- coding: utf-8 -*-
import os
import json

def validate_placeholders(base_dir="creatoros"):
    results = []
    for root, _, files in os.walk(base_dir):
        for file in files:
            if "__todo." in file:
                path = os.path.join(root, file)
                ext = file.split(".")[-1]
                try:
                    with open(path, "r", encoding="utf-8") as f:
                        content = f.read()
                    if ext == "py":
                        if "# TODO" in content and "# -*- coding: utf-8 -*-" in content:
                            results.append((path, "OK", "Python-Stub gültig"))
                        else:
                            results.append((path, "FEHLER", "Python-Stubs unvollständig"))
                    elif ext == "json":
                        json.loads(content or "{}")
                        results.append((path, "OK", "JSON-Stub gültig"))
                    elif ext in ["yml", "yaml"]:
                        results.append((path, "OK", "YAML erkannt (nicht geprüft)"))
                    elif ext == "db":
                        results.append((path, "OK", "Leere DB-Datei akzeptiert"))
                    else:
                        results.append((path, "WARNUNG", f"Unbekannte Endung: {ext}"))
                except Exception as e:
                    results.append((path, "FEHLER", f"{type(e).__name__}: {e}"))
    return results
