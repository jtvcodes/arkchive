<div align="center"><img src="static/logo-dark-horizontal.png" alt="Arkchive logo" width="300px"></div>

A Flask-based web application that provides a browser UI for reading Gmail messages stored in a local SQLite database produced by the [gmail-to-sqlite](https://github.com/jtvcodes/gmail-to-sqlite) sync tool.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Server](#running-the-server)
- [Project Structure](#project-structure)
- [REST API Reference](#rest-api-reference)
  - [GET /api/messages](#get-apimessages)
  - [GET /api/messages/stats](#get-apimessagesstats)
  - [GET /api/messages/\<message\_id\>](#get-apimessagesmessage_id)
  - [GET /api/messages/\<message\_id\>/attachments/by-filename/\<filename\>/data](#get-apimessagesmessage_idattachmentsby-filenamefilenamedata)
  - [GET /api/cid/\<content\_id\>](#get-apicidcontent_id)
  - [GET /api/labels](#get-apilabels)
  - [GET /api/sync/status](#get-apisyncstatus)
  - [GET /api/sync/stream](#get-apisyncstream)
  - [POST /api/sync](#post-apisync)
- [Frontend Architecture](#frontend-architecture)
- [Database Connection](#database-connection)
- [Running Tests](#running-tests)

---

## Overview

Arkchive is a single-page application (SPA) backed by a Flask REST API. It reads directly from the SQLite database that the [gmail-to-sqlite](https://github.com/jtvcodes/gmail-to-sqlite) sync tool populates and exposes:

- A paginated, filterable message list
- Full message detail with HTML and plain-text body views
- Attachment download and inline preview
- A one-click sync button that triggers the sync tool from the browser

---

## Prerequisites

- Python 3.8+
- A clone of [jtvcodes/gmail-to-sqlite](https://github.com/jtvcodes/gmail-to-sqlite) — required for syncing messages
- `credentials.json` in the gmail-to-sqlite repo root (required for syncing and on-demand attachment fetching)

---

## Installation

### One-command setup

Pick the script for your platform and run it from the arkchive repo root. It will check dependencies, clone [gmail-to-sqlite](https://github.com/jtvcodes/gmail-to-sqlite), install all packages, and create your `.env` automatically.

| Platform             | Script                 | How to run                                                      |
|----------------------|------------------------|-----------------------------------------------------------------|
| Windows (PowerShell) | `scripts/install.ps1`  | `powershell -ExecutionPolicy Bypass -File scripts/install.ps1`  |
| Windows (CMD)        | `scripts/install.bat`  | `scripts\install.bat`                                           |
| macOS / Linux        | `scripts/install.sh`   | `bash scripts/install.sh`                                       |

Each script will:
1. Verify Python and Git are installed
2. Install Arkchive's Python dependencies (`requirements.txt`)
3. Clone `jtvcodes/gmail-to-sqlite` to a location you choose
4. Install gmail-to-sqlite's dependencies
5. Create `.env` with the correct `GMAIL_SYNC_MAIN` path
6. Create the `.data/` directory for the database
7. Remind you to add `credentials.json` if it's missing

### Manual setup

**1. Clone this repo**

```bash
git clone https://github.com/jtvcodes/arkchive.git
cd arkchive
```

**2. Clone the sync tool**

```bash
git clone https://github.com/jtvcodes/gmail-to-sqlite.git
```

**3. Install dependencies**

```bash
pip install -r requirements.txt
```

For development and testing:

```bash
pip install -r requirements-dev.txt
```

| File                   | Packages                                    |
|------------------------|---------------------------------------------|
| `requirements.txt`     | `flask`, `flask-cors`, `python-dotenv`      |
| `requirements-dev.txt` | `pytest`, `pytest-flask`, `hypothesis`      |

---

## Configuration

Copy `.env.example` to `.env` and set the path to your local `gmail-to-sqlite` clone:

```bash
cp .env.example .env
```

Then edit `.env`:

```env
# Path to the gmail-to-sqlite main.py entry point
GMAIL_SYNC_MAIN=C:\path\to\gmail-to-sqlite\main.py
```

On macOS/Linux:

```env
GMAIL_SYNC_MAIN=/path/to/gmail-to-sqlite/main.py
```

This is required for the Sync button in the UI to work. Without it, the server will still run and display messages from an existing database, but syncing will fail.

---

## Running the Server

```bash
python server.py
```

Then open [http://localhost:8001](http://localhost:8001) in your browser.

### CLI Options

| Flag        | Default              | Description                           |
|-------------|----------------------|---------------------------------------|
| `--port`    | `8001`               | Port the server listens on            |
| `--db-path` | `.data/messages.db`  | Path to the SQLite database file      |

**Examples:**

```bash
# Custom port
python server.py --port 5000

# Custom database path
python server.py --db-path /path/to/messages.db
```

---

## Project Structure

```
arkchive/
├── server.py               # Application factory and CLI entry point
├── db.py                   # SQLite connection management (Flask g context)
├── requirements.txt        # Runtime dependencies
├── requirements-dev.txt    # Development/test dependencies
├── .env                    # Local environment config (gitignored)
├── .env.example            # Template for .env
├── .data/
│   └── messages.db         # SQLite database (gitignored)
├── api/
│   ├── __init__.py
│   ├── messages.py         # /api/messages endpoints
│   ├── labels.py           # /api/labels endpoint
│   └── sync.py             # /api/sync endpoints
├── static/
│   ├── index.html          # SPA shell
│   ├── app.js              # State management and bootstrap
│   ├── api.js              # Fetch wrappers for the REST API
│   ├── attachments.js      # Attachment icon and previewability helpers
│   ├── commandPalette.js   # Keyboard-triggered command palette overlay
│   ├── filters.js          # Search input and label dropdown component
│   ├── messageDetail.js    # Message detail panel component
│   ├── messageList.js      # Paginated message table component
│   ├── paneResizer.js      # Drag-to-resize handler for the split pane
│   ├── readingPane.js      # Reading pane rendering and mode switching
│   ├── sidebar.js          # Sidebar navigation and label filtering
│   ├── themeManager.js     # Theme (light/dark) and density manager
│   ├── toastManager.js     # Toast notification manager
│   └── style.css           # Application styles
└── tests/
    ├── test_web_messages.py
    ├── test_web_labels.py
    ├── test_web_properties.py
    └── ...
```

---

## REST API Reference

All endpoints are served under the `/api` prefix. Responses are JSON unless noted.

---

### GET /api/messages

Returns a paginated list of message summaries.

**Query Parameters**

| Parameter         | Type    | Default | Description                                                                 |
|-------------------|---------|---------|-----------------------------------------------------------------------------|
| `page`            | integer | `1`     | Page number (must be ≥ 1)                                                   |
| `page_size`       | integer | `50`    | Results per page (1–200)                                                    |
| `q`               | string  | —       | Full-text search across `subject`, `sender`, and `body` (case-insensitive) |
| `label`           | string  | —       | Filter by exact label name                                                  |
| `is_read`         | boolean | —       | `true` or `false`                                                           |
| `is_outgoing`     | boolean | —       | `true` or `false`                                                           |
| `include_deleted` | boolean | `false` | Include soft-deleted messages when `true`                                   |
| `sort_dir`        | string  | `desc`  | Sort by timestamp: `asc` or `desc`                                          |

**Response**

```json
{
  "messages": [
    {
      "message_id": "18f3a...",
      "thread_id": "18f3a...",
      "sender": { "name": "Alice", "email": "alice@example.com" },
      "labels": ["INBOX", "UNREAD"],
      "subject": "Hello",
      "timestamp": "2024-01-15T10:30:00",
      "is_read": false,
      "is_outgoing": false,
      "is_deleted": false
    }
  ],
  "total": 142,
  "page": 1,
  "page_size": 50
}
```

**Error Responses**

| Status | Condition                                     |
|--------|-----------------------------------------------|
| `400`  | Invalid `page`, `page_size`, or boolean param |
| `503`  | Database not yet populated (missing table)    |
| `500`  | Unexpected database error                     |

---

### GET /api/messages/stats

Returns aggregate counts for the message database.

**Response**

```json
{
  "total_messages": 1420,
  "total_indexed": 1380,
  "total_unsynced": 40
}
```

---

### GET /api/messages/\<message_id\>

Returns the full detail for a single message, including body, recipients, and attachments.

**Response** — all summary fields plus:

| Field         | Type   | Description                                                              |
|---------------|--------|--------------------------------------------------------------------------|
| `body`        | string | Plain-text body                                                          |
| `body_html`   | string | HTML body (with `cid:` references rewritten to `/api/cid/...`)          |
| `recipients`  | object | `{ "to": [...], "cc": [...], "bcc": [...] }`                             |
| `attachments` | array  | List of attachment metadata objects                                      |

**Error Responses**

| Status | Condition                 |
|--------|---------------------------|
| `404`  | Message not found         |
| `503`  | Database not ready        |
| `500`  | Unexpected database error |

---

### GET /api/messages/\<message_id\>/attachments/by-filename/\<filename\>/data

Serves the raw bytes of an attachment looked up by filename.

**Query Parameters**

| Parameter | Type  | Description                                                   |
|-----------|-------|---------------------------------------------------------------|
| `preview` | `"1"` | Sets `Content-Disposition: inline` so the browser renders it |

**Error Responses**

| Status | Condition                              |
|--------|----------------------------------------|
| `404`  | No attachment with that filename found |
| `500`  | Unexpected error                       |

---

### GET /api/cid/\<content_id\>

Resolves a `cid:` inline image reference used in HTML email bodies.

**Query Parameters**

| Parameter | Type   | Description                                          |
|-----------|--------|------------------------------------------------------|
| `msg`     | string | Message ID — scopes the lookup and avoids collisions |

---

### GET /api/labels

Returns a sorted list of all distinct labels with their type.

**Response**

```json
[
  { "label": "INBOX", "label_type": "system" },
  { "label": "work",  "label_type": "label" }
]
```

---

### GET /api/sync/status

Returns the current state of the background sync session.

**Response**

```json
{ "running": false }
```

```json
{ "running": true, "mode": "delta", "progress_label": "Syncing messages 42 of 200…" }
```

---

### GET /api/sync/stream

Server-Sent Events (SSE) endpoint that streams live output from a running sync session.

**Query Parameters**

| Parameter    | Type    | Description                                                     |
|--------------|---------|-----------------------------------------------------------------|
| `mode`       | string  | Sync mode: `new`, `delta`, `force`, or `test`                   |
| `from`       | integer | Resume from this line index (for reconnection after disconnect) |
| `workers`    | integer | Number of parallel worker threads (default `20`, max `30`)      |
| `test_limit` | integer | Max messages to sync in `test` mode (default `10000`)           |

Each line of output is sent as an SSE `data` event. A final `event: done` carries the exit code.

---

### POST /api/sync

Triggers a sync by running `gmail-to-sqlite` as a subprocess. Blocks until complete (up to 5 minutes).

**Request Body**

```json
{ "mode": "delta", "workers": 20 }
```

| Field        | Type    | Default  | Description                                              |
|--------------|---------|----------|----------------------------------------------------------|
| `mode`       | string  | required | One of `new`, `delta`, `force`, `test`                   |
| `workers`    | integer | `20`     | Parallel worker threads (1–30)                           |
| `test_limit` | integer | `10000`  | Max messages in `test` mode                              |

**Response**

```json
{ "ok": true, "output": "Synced 12 new messages." }
```

| Status | Condition                          |
|--------|------------------------------------|
| `500`  | `main.py` not found or sync failed |
| `504`  | Sync timed out after 5 minutes     |

---

## Frontend Architecture

The SPA is built with vanilla JavaScript — no framework or build step required.

| File               | Responsibility                                                                        |
|--------------------|---------------------------------------------------------------------------------------|
| `app.js`           | Global `state` object, loading overlay, error banner, bootstrap on `DOMContentLoaded` |
| `api.js`           | Thin `fetch` wrappers (`fetchMessages`, `fetchMessage`, `fetchLabels`)                |
| `attachments.js`   | Shared `attachmentIcon` and `isPreviewable` helpers                                   |
| `commandPalette.js`| Keyboard-triggered command palette overlay                                            |
| `filters.js`       | Search input and label `<select>` component                                           |
| `messageList.js`   | Sortable, paginated message table                                                     |
| `messageDetail.js` | Detail panel — HTML/text toggle, attachment preview                                   |
| `paneResizer.js`   | Drag-to-resize handler for the split pane                                             |
| `readingPane.js`   | Reading pane rendering and mode switching (right/below/none)                          |
| `sidebar.js`       | Sidebar navigation, label filtering, read/unread filter                               |
| `themeManager.js`  | Theme (light/dark) and density (cozy/compact), persisted to `localStorage`            |
| `toastManager.js`  | Toast notification manager                                                            |

---

## Database Connection

`db.py` manages the SQLite connection using Flask's application context (`g`):

- `get_db()` — opens a connection on first call within a request, reuses it on subsequent calls. Rows are accessible by column name via `sqlite3.Row`.
- `close_db()` — registered as a teardown handler; closes the connection at the end of each request.

The database path is set once via `--db-path` (default `.data/messages.db`) and never changes at runtime.

---

## Running Tests

```bash
# Run all tests
pytest tests/

# Run a specific file
pytest tests/test_web_messages.py

# Verbose
pytest tests/ -v
```

| File                                      | What it covers                                              |
|-------------------------------------------|-------------------------------------------------------------|
| `test_web_messages.py`                    | Message list and detail endpoint behaviour                  |
| `test_web_labels.py`                      | Labels endpoint                                             |
| `test_web_properties.py`                  | Property-based tests for the messages API                   |
| `test_web_sync.py`                        | Sync status endpoint behaviour                              |
| `test_sync_properties.py`                 | Property-based tests for the sync API                       |
| `test_sync_frontend_properties.test.js`   | Frontend property-based tests for the sync UI               |
| `test_message_html_view.py`               | HTML/text body rendering logic                              |
| `test_message_html_view_properties.py`    | Property-based tests for body rendering                     |
| `test_messageDetail.test.js`              | Frontend tests for the message detail panel                 |
| `test_messageList.test.js`                | Frontend property-based tests for the message list          |
| `test_raw_body_storage_web_properties.py` | Raw body storage round-trip properties                      |
| `test_preservation_properties.py`         | Data preservation invariants                                |
| `test_recipient_formatting.py`            | Recipient object formatting                                 |
| `test_bug_condition.py`                   | Regression / bug condition tests                            |
