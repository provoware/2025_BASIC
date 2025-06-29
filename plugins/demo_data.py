from PyQt5 import QtWidgets

from database.db import get_connection


def setup(window):
    """Add a button to insert a demo record into the database."""
    dashboard = window.centralWidget()
    layout = dashboard.layout()
    if layout is None:
        layout = QtWidgets.QVBoxLayout(dashboard)
        dashboard.setLayout(layout)

    button = QtWidgets.QPushButton("Demo-Datensatz einfügen")

    def on_click():
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "CREATE TABLE IF NOT EXISTS demo (id INTEGER PRIMARY KEY AUTOINCREMENT, info TEXT)"
        )
        cursor.execute("INSERT INTO demo (info) VALUES (?)", ("Beispiel",))
        conn.commit()
        conn.close()
        QtWidgets.QMessageBox.information(window, "Info", "Demo-Datensatz gespeichert")

    button.clicked.connect(on_click)
    layout.addWidget(button)
