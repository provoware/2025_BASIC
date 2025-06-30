# -*- coding: utf-8 -*-
import os
from datetime import datetime

LOGFILE = "creatoros/logs/steelcore.log"

def log(message, level="INFO", logfile=LOGFILE):
    os.makedirs(os.path.dirname(logfile), exist_ok=True)
    timestamp = datetime.now().isoformat()
    with open(logfile, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] [{level}] {message}\n")

def debug(msg): log(msg, "DEBUG")
def info(msg): log(msg, "INFO")
def warn(msg): log(msg, "WARN")
def error(msg): log(msg, "ERROR")
