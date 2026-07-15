# Inbox Ingestor

A background watcher that converts PDFs dropped into your vault's `_Inbox/` folder into clean markdown, automatically, with zero manual steps.

## What it does

Watches a folder. The moment a `.pdf` lands, it's converted to `.md` via `pymupdf4llm` — fully local, no API key, no network call. The `.md` sits right next to the original `.pdf`.

**What it deliberately does NOT do:** file anything, move anything, or decide where a document belongs. That's a judgment call — left to you, or to an LLM session with access to your vault. This tool solves exactly one problem: turning a PDF into readable text without you doing it by hand.

## Quick start (run manually, no background service)

```bash
pip install --upgrade pymupdf4llm watchdog
python3 inbox_watcher.py "/path/to/your/vault/_Inbox"
```

Leave it running in a terminal tab. Ctrl+C to stop.

## Run it as a background service instead

See `install-macos-service.md` for the `launchd` setup (macOS) — starts on login, restarts on crash, no terminal tab to babysit.

## Files in this folder

- `inbox_watcher.py` — the actual watcher script
- `install-macos-service.md` — background-service setup guide
- `com.yourname.inboxwatcher.plist.template` — the launchd config template referenced in the guide above
