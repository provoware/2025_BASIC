# -*- coding: utf-8 -*-
import shutil
import os
import tempfile
from creatoros.modules import auto_repair

def test_repair_structure_creates_missing_dirs():
    with tempfile.TemporaryDirectory() as tmp:
        base = os.path.join(tmp, "creatoros")
        os.makedirs(os.path.join(base, "system"))  # einer existiert
        result = auto_repair.repair_structure(base_path=tmp)
        required = [f"creatoros/{d}" for d in ["boot", "interface", "modules", "db", "logs", "plugins", "system"]]
        for r in required:
            assert os.path.isdir(os.path.join(tmp, r)), f"{r} fehlt"
        assert "creatoros/system vorhanden" in result
        assert "creatoros/boot angelegt" in result
