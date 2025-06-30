# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.tools import validate_placeholders

def test_validate_stub_py_valid():
    with tempfile.TemporaryDirectory() as tmp:
        stub = os.path.join(tmp, "valid__todo.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write("# -*- coding: utf-8 -*-\n# TODO")
        result = validate_placeholders.validate_placeholders(tmp)
        assert any("OK" in r for r in result)

def test_validate_stub_py_invalid():
    with tempfile.TemporaryDirectory() as tmp:
        stub = os.path.join(tmp, "broken__todo.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write("kein header")
        result = validate_placeholders.validate_placeholders(tmp)
        assert any("FEHLER" in r for r in result)
