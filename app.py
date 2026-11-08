import sqlite3
from pathlib import Path
from flask import Flask
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)

# Yksi Nginx edessä -> luota yhteen arvoon kustakin otsakkeesta
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

DATABASE = Path(__file__).with_name("visits.db")

def init_db():
    conn = sqlite3.connect(DATABASE)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS visits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

    init_db()

@app.route("/")
def home():
    conn = sqlite3.connect(DATABASE)

    conn.execute("INSERT INTO visits DEFAULT VALUES")
    conn.commit()

    count = conn.execute(
        "SELECT COUNT(*) FROM visits"
    ).fetchone()[0]

    conn.close()

    return f"""
    <h1>Viikko 2 - Python-verkkosovellus</h1>

    <p>Tervetuloa palvelimelle!</p>

    <h2>Kävijälaskuri</h2>

    <p>Täällä on käyty {count} kertaa.</p>

    <h2>Toteutus: </h2>

    <p>Sivu on toteutettu Pythonilla ja siinä on käytetty Flask-
     verkkosovelluskehystä.</p>

    <p>Jokainen sivuilla käynti tallennetaan tietokantaan omana rivinään. Tietokantana on SQLite.</p>

    <p>Käyntimäärä säilyy palvelimen uudelleenkäynnistyksen
    jälkeen ja tiedot tallennetaan pysyvästi tietokantatiedostoon.</p>

    <p>Uudelleenkäynnistys onnistui:
    tämä käynnistyi automaattisesti ja kävijälaskuri
    jatkoi laskemista edellisestä luvusta.</p>
    <h2>Lähdekoodi</h2>
    <p>

    <a href="https://github.com/neamariah/Linux">
    Repo täällä!
        </a>
        </p>
    </body>
    </html>
    """

if __name__ == "__main__":
    app.run()

