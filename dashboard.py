from configparser import ConfigParser
import tkinter as tk
from tkinter import messagebox

config = ConfigParser()
config.read('config.ini')

notes_file = config.get('notes', 'path', fallback='notes.txt')


def save_note():
    note = text_entry.get("1.0", tk.END).strip()
    if not note:
        messagebox.showwarning("Leer", "Bitte eine Notiz eingeben.")
        return
    try:
        with open(notes_file, 'a') as f:
            f.write(note + "\n")
        text_entry.delete("1.0", tk.END)
        messagebox.showinfo("Gespeichert", "Notiz gespeichert.")
    except Exception as exc:
        messagebox.showerror("Fehler", f"Speichern fehlgeschlagen: {exc}")


root = tk.Tk()
root.title('Notiz-Dashboard')

text_entry = tk.Text(root, width=40, height=10)
text_entry.pack(padx=10, pady=10)

save_button = tk.Button(root, text='Speichern', command=save_note)
save_button.pack(pady=(0, 10))

root.mainloop()
