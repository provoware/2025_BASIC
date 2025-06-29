import inspect
from gui.app import run

def test_run_ist_callable():
    assert inspect.isfunction(run) and callable(run)
