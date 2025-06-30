# -*- coding: utf-8 -*-
import os

REQUIRED_DIRS = [
    "creatoros/boot",
    "creatoros/system",
    "creatoros/interface",
    "creatoros/modules",
    "creatoros/db",
    "creatoros/logs",
    "creatoros/plugins"
]

def repair_structure(base_path="."):
    results = []
    for d in REQUIRED_DIRS:
        full_path = os.path.join(base_path, d)
        if not os.path.exists(full_path):
            os.makedirs(full_path, exist_ok=True)
            results.append(f"{d} angelegt")
        else:
            results.append(f"{d} vorhanden")
    return results
