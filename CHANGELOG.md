# Changelog

All notable changes to Arkchive are documented here.

---

## [Unreleased]

### Added
- Initial public release of Arkchive
- Migrated project structure from `web/` subdirectory to repository root
- Connected to [jtvcodes/gmail-to-sqlite](https://github.com/jtvcodes/gmail-to-sqlite) as the sync backend
- `GMAIL_SYNC_MAIN` environment variable via `.env` / `python-dotenv` to configure the sync tool path
- Default database path changed from `data/messages.db` to `.data/messages.db`
- Default server port changed from `8000` to `8001`
- One-command install scripts for Windows (PowerShell), Windows (CMD), and macOS/Linux (bash)
- `CHANGELOG.md` and `ROADMAP.md`

---

## Core Features

### Flask REST API
- `GET /api/messages` — paginated message list with full-text search (FTS5), label, read/unread, outgoing, and deleted filters
- `GET /api/messages/stats` — aggregate counts (total messages, indexed, unsynced)
- `GET /api/messages/<id>` — full message detail including HTML body, plain-text body, recipients, and attachments
- `GET /api/messages/<id>/attachments/by-filename/<filename>/data` — serve attachment bytes by filename with inline preview support
- `GET /api/cid/<content_id>` — resolve `cid:` inline image references in HTML email bodies
- `GET /api/labels` — distinct labels with type classification (`system`, `category`, `label`)
- `GET /api/sync/status` — current sync state with progress label
- `GET /api/sync/stream` — live sync output via Server-Sent Events (SSE) with reconnection support
- `POST /api/sync` — blocking sync trigger
- `POST /api/sync/stop` — kill a running sync process

### Frontend SPA (Vanilla JS, no build step)
- Paginated, sortable message list
- Full-text search with clear button and keyboard trigger (Enter)
- Label filtering via sidebar navigation and dropdown
- Read / Unread filter in sidebar
- Message detail panel with HTML and plain-text body toggle
- Sandboxed `<iframe>` rendering for HTML email bodies
- Inline image rendering via `cid:` rewriting
- Attachment list with download and inline preview
- Split-pane layout with drag-to-resize
- Reading pane modes: right, below, none
- Sidebar with collapsible label tree (slash-separated label hierarchy)
- System, category, and custom label sections with icons
- Light / dark theme toggle, persisted to `localStorage`
- Cozy / compact density toggle
- Toast notification manager
- Command palette (Ctrl/Cmd+K)
- Keyboard shortcuts: J/K navigation, O/Enter to open, R to sync, ? for help
- Sync button with mode dropdown (new, delta, force, test)
- Live sync log console with SSE streaming and stop button
- Sync progress label in log console header and sidebar
- Auto-reconnect to in-progress sync after page refresh
- Launch screen with progress bar
- "No database" prompt with one-click sync trigger
- Responsive layout with off-canvas sidebar on mobile

### Infrastructure
- SQLite connection management via Flask `g` context (`db.py`)
- Thread-safe in-process attachment metadata cache (LRU, 256 entries)
- FTS5 query sanitization to prevent injection
- `SyncSession` class — subprocess lifecycle management with buffered output and SSE tail
- `python-dotenv` for `.env` loading
- Property-based tests via Hypothesis
- Jest frontend tests
