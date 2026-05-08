import sqlite3

from flask import current_app, g


def get_db() -> sqlite3.Connection:
    """Return the SQLite connection for the current application context."""
    if "db" not in g:
        conn = sqlite3.connect(
            current_app.config["DB_PATH"],
            detect_types=sqlite3.PARSE_DECLTYPES,
        )
        conn.row_factory = sqlite3.Row
        g.db = conn
    return g.db


def close_db(exception: BaseException | None = None) -> None:
    """Close the SQLite connection at the end of the application context."""
    db = g.pop("db", None)
    if db is not None:
        db.close()
