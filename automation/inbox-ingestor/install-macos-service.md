# Running Inbox Ingestor as a background service (macOS)

This makes the watcher start automatically on login and restart if it crashes — you never have to remember to run it manually.

## 1. Edit the plist template

Copy `com.yourname.inboxwatcher.plist.template` in this folder, rename it (drop `.template`), and replace every `REPLACE_ME` placeholder with your actual paths:

- Path to your Python 3 executable (`which python3` to find it)
- Full path to `inbox_watcher.py` (wherever you put this folder)
- Full path to your vault's `_Inbox` folder

## 2. Install it

```bash
cp com.yourname.inboxwatcher.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.yourname.inboxwatcher.plist
```

## 3. Verify it's running

```bash
launchctl list | grep inboxwatcher
```

Logs land at whatever path you set for `StandardOutPath` / `StandardErrorPath` in the plist.

## Uninstalling

```bash
launchctl unload ~/Library/LaunchAgents/com.yourname.inboxwatcher.plist
rm ~/Library/LaunchAgents/com.yourname.inboxwatcher.plist
```

## Linux equivalent

Use a `systemd` user service instead of `launchd` — same idea (run on login, restart on failure), different config format. Not included here since the exact unit file depends on your distro; ask an LLM to adapt the plist's logic to a `.service` file if needed.
