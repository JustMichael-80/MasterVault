# MasterVault

A free, fillable template that turns Claude into a stacked toolkit — curated skills, symlinked once, loaded automatically whenever they're relevant. Plus one original tool: a background service that watches an inbox folder and converts PDFs to markdown the moment they land, no manual triggering required.

Clone it once. Fill it as you find tools worth keeping.

---

## What's inside

```
mastervault/
├── skills/                  ← vendored third-party + first-party skills (see ATTRIBUTIONS.md)
├── automation/
│   └── inbox-ingestor/      ← original: PDF→markdown watcher, runs as a persistent local service
├── install.sh               ← symlinks everything in skills/ into ~/.claude/skills/
└── ATTRIBUTIONS.md          ← every vendored tool, its author, its license
```

## Quickstart

**1. Clone it**
```bash
git clone https://github.com/[your-username]/mastervault.git
cd mastervault
```

**2. Pull in the skills you want**
```bash
git clone --depth 1 https://github.com/anthropics/skills.git skills/anthropic
git clone --depth 1 https://github.com/obra/superpowers.git skills/superpowers
git clone --depth 1 https://github.com/upstash/context7.git skills/context7
git clone --depth 1 https://github.com/hardikpandya/stop-slop.git skills/stop-slop
```
Add more as you find them. Each one lives in its own subfolder with its original LICENSE intact — see `ATTRIBUTIONS.md`.

**3. Run the installer**
```bash
./install.sh
```
This symlinks every skill folder into `~/.claude/skills/`. Claude Code and Desktop discover them from here on — no re-downloading, no re-priming each session.

**4. Verify**
```bash
ls -la ~/.claude/skills
```
Every entry should be a symlink pointing back into `mastervault/skills/`.

---

## Inbox Ingestor (included, original)

A lightweight background watcher for anyone running an Obsidian-style vault (or any folder-based knowledge base) alongside Claude. Drop a PDF into an `_Inbox/` folder; it gets converted to clean markdown automatically, sitting right next to the original.

- Runs as a persistent local service (`launchd` on macOS, adaptable to `systemd` on Linux) — not a script you have to remember to run
- Uses `pymupdf4llm` for extraction — local, no API calls, no network dependency
- Deliberately does **one job only**: conversion. It does not file, move, or organize anything — that's left to you, or to Claude with vault access, on purpose. Filing decisions (which project something belongs to, how it links to existing notes) need judgment; conversion doesn't.

See `automation/inbox-ingestor/README.md` for setup.

---

## Why symlinks, not copies

Skills only need to exist once. Symlinking into `~/.claude/skills/` means:
- No re-cloning across projects or machines
- Updates to a vendored skill (`git pull` inside its folder) propagate immediately, no re-linking needed
- Your `mastervault/` folder is the single source of truth for every skill you've collected

## Contributing

Found a skill worth adding? Open a PR: fork the vendored repo into `skills/[name]/`, add its entry to `ATTRIBUTIONS.md` with license + link, and make sure its original `LICENSE` file ships intact inside the subfolder. No skill gets vendored here without its license attached.

## License

MasterVault's own structure, scripts, and Inbox Ingestor are MIT licensed — see `LICENSE`. Every vendored skill under `skills/` retains its own original license; see `ATTRIBUTIONS.md` for the full list.
