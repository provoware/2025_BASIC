# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.modules import database

def test_sqlite_db_lifecycle():
    with tempfile.TemporaryDirectory() as tmp:
        db_path = os.path.join(tmp, "test.sqlite3")
        database.init_db(db_path)
        database.insert_eintrag("Test", "KategorieA", db_path)
        result = database.get_all_eintraege(db_path)
        assert len(result) == 1
        assert result[0][0] == "Test"
