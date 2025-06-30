# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.system import logger

def test_logging_creates_file_and_writes():
    with tempfile.TemporaryDirectory() as tmp:
        log_path = os.path.join(tmp, "log.txt")
        logger.log("Test-Eintrag", level="DEBUG", logfile=log_path)
        assert os.path.isfile(log_path)
        with open(log_path) as f:
            content = f.read()
            assert "Test-Eintrag" in content
