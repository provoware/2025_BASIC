from src.database import setup_schema
from src.gui import run


def main():
    setup_schema()
    run()


if __name__ == "__main__":
    main()
