from src.gui import Application
from src.database.connection import init_db


def main() -> None:
    init_db()
    app = Application()
    app.mainloop()


if __name__ == "__main__":
    main()
