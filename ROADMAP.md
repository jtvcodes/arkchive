# Roadmap

Planned features and improvements for Arkchive, roughly ordered by priority.

Items marked 🔄 are in progress. Items marked ✅ are complete (see [CHANGELOG](CHANGELOG.md)).

---

## Near-term

### UX & Reading Experience
- [ ] Thread view — group messages by `thread_id` and display as a conversation
- [ ] Mark as read / unread from the message list and detail panel
- [ ] Star / unstar messages
- [ ] Keyboard shortcut to archive or delete a message
- [ ] Infinite scroll or "load more" as an alternative to pagination
- [ ] Message list column customization (show/hide sender, date, labels)
- [ ] Resizable sidebar width (drag handle)

### Search
- [ ] Search suggestions / autocomplete based on senders and subjects
- [ ] Advanced search filters (date range, has attachment, from, to)
- [ ] Search result highlighting — bold matched terms in the message list
- [ ] Saved searches / bookmarks

### Sync
- [ ] Scheduled / automatic background sync (configurable interval)
- [ ] Sync status notifications (desktop notification on completion)
- [ ] Per-label sync — sync only specific labels
- [ ] Sync history log — persistent record of past sync runs with timestamps and counts

---

## Medium-term

### Attachments
- [ ] Attachment gallery view per message
- [ ] Global attachment search — find all messages with a specific filename or type
- [ ] Bulk attachment export

### Labels & Organization
- [ ] Create and apply custom local labels (stored separately from Gmail)
- [ ] Bulk label operations from the message list
- [ ] Label color customization

### Performance
- [ ] Virtual scrolling for large message lists (10k+ messages)
- [ ] Lazy-load message bodies — avoid fetching raw on list view
- [ ] Service Worker for offline reading of already-loaded messages

### Accessibility
- [ ] Full keyboard navigation across all interactive elements
- [ ] ARIA live regions for sync status updates
- [ ] High-contrast theme option
- [ ] Screen reader audit

---

## Long-term / Exploratory

- [ ] Multi-account support — switch between multiple Gmail archives
- [ ] Export to formats: PDF, EML, MBOX
- [ ] Full-text search across attachment content (PDF, DOCX indexing)
- [ ] Plugin / extension system for custom views and actions
- [ ] Mobile app wrapper (PWA or native shell)
- [ ] Self-hosted Docker image for easy deployment
- [ ] End-to-end encryption for the local database at rest

---

## Won't Do (for now)

- Sending email — Arkchive is a read-only archive viewer
- Cloud sync or remote hosting — intentionally local-first
- Real-time Gmail push notifications — out of scope for an offline archive
