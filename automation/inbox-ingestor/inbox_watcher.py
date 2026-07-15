#!/usr/bin/env python3
"""
Persistent PDF watcher for your vault's _Inbox folder.

Watches _Inbox continuously. The moment a .pdf appears, it's converted
to markdown (fully local, via pymupdf4llm — no API key, no rate limits,
no network call) and the .md is written alongside it in _Inbox.

This does NOT move PDFs or file them anywhere — it only solves the
"give me readable text instead of a broken PDF" problem. Filing
(deciding what a document is, moving it to the right folder, updating
links) still needs a session with an LLM that has access to your vault —
just tell it "process the inbox" once files are here.

Setup:
    pip install --upgrade pymupdf4llm watchdog

Usage:
    python3 inbox_watcher.py "/path/to/your/vault/_Inbox"

Leave this running in a Terminal tab, or set it up as a background
service — see install-macos-service.md in this folder for the launchd
version that starts automatically on login.
"""

import sys
import time
import logging
from pathlib import Path

import pymupdf4llm
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
log = logging.getLogger("inbox_watcher")

SETTLE_SECONDS = 2  # brief pause in case the file is still being copied/synced


def convert(pdf_path: Path):
    md_path = pdf_path.with_suffix(".md")
    if md_path.exists():
        log.info(f"Already converted, skipping: {pdf_path.name}")
        return
    try:
        log.info(f"Converting: {pdf_path.name}")
        markdown = pymupdf4llm.to_markdown(str(pdf_path))
        md_path.write_text(markdown, encoding="utf-8")
        log.info(f"Wrote: {md_path.name} ({len(markdown)} chars)")
    except Exception as e:
        log.error(f"Failed to convert {pdf_path.name}: {e}")


class InboxHandler(FileSystemEventHandler):
    def on_created(self, event):
        if event.is_directory:
            return
        path = Path(event.src_path)
        if path.suffix.lower() != ".pdf":
            return
        time.sleep(SETTLE_SECONDS)
        if path.exists():
            convert(path)


def sweep_existing(inbox: Path):
    existing = sorted(inbox.glob("*.pdf"))
    if existing:
        log.info(f"Found {len(existing)} PDF(s) already waiting, converting...")
    for pdf in existing:
        convert(pdf)


def main():
    if len(sys.argv) != 2:
        print('Usage: python3 inbox_watcher.py "/path/to/your/vault/_Inbox"')
        sys.exit(1)

    inbox = Path(sys.argv[1]).expanduser().resolve()
    if not inbox.exists():
        print(f"ERROR: folder not found: {inbox}")
        sys.exit(1)

    sweep_existing(inbox)

    handler = InboxHandler()
    observer = Observer()
    observer.schedule(handler, str(inbox), recursive=False)
    observer.start()
    log.info(f"Watching {inbox} for new PDFs. Ctrl+C to stop.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    main()
