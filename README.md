# MasterVault Template (v1.1)

A blank, reusable scaffold for orienting an LLM into a project's context at the start of every session.

This repo contains no real project content. It's a frame — three working files plus a protocol — that you copy into any project and fill with your own information. Everything here is illustrative, built around a fictional example project (a small business called **Lumen Kites**, a fictional kite-making company) so the pattern is visible without being tied to any real domain.

---

## The problem this solves

Every new session with an LLM starts cold. If your project has any real depth — history, decisions made and revisited, people involved, technical constraints — you either re-explain it every time, or you write it down somewhere and ask the LLM to read that first.

The second approach works, but it has a quiet failure mode: **the file you wrote six weeks ago doesn't know it's six weeks old.** It reads exactly as confidently as a file you updated this morning. Nothing about the document itself signals that the world has moved on since you wrote it. A stale paragraph about "the current plan" looks identical to an accurate one. You, or the LLM reading it, has no built-in reason to doubt it — until something contradicts it and you realize the file was wrong for weeks.

This is worse than having no file at all. No file means the LLM asks questions. A stale file means it confidently acts on outdated ground truth, and the failure is silent until it isn't.

This template exists to make that failure loud instead of silent, and to separate the kind of information that goes stale slowly from the kind that goes stale the moment you make a decision.

---

## The three files, and how they relate

### `CONSTITUTION.md` — what rarely changes
This is the project's foundational layer: principles, standards, and validation criteria that any specific decision gets checked against. It's written once and revisited rarely — think of it as the thing other files answer *to*, not the thing that gets updated week to week. If you find yourself editing this file often, that's a signal the project's foundations are still being figured out, which is fine, but worth noticing.

### `CONTEXT.md` — what changes, split by why it changes
This is the living session file — the one thing an LLM reads to get up to speed. It is deliberately split into two halves, and that split is the actual design idea in this template:

- **Derived** information is transcribed from a source that exists somewhere else — a ticket system, a codebase, a set of accounts, a calendar. If it goes stale, that's a **sync problem**: the source of truth moved and this file didn't follow. It's fixable mechanically — re-check the source, update the transcription.
- **Judgment** information is stuff only the project owner can supply — current priorities, which of two options you're leaning toward, whether a relationship with a collaborator or vendor is still active. If this goes stale, that's not a sync problem — it's a **signal**. It means a decision needs to be made or revisited, not just copied from somewhere else.

Conflating these two is the actual root of the silent-staleness problem. A sync problem and a pending decision look identical if they're written in the same undifferentiated paragraph. Separating them means the reader (human or LLM) knows *what kind of action* an out-of-date entry calls for — go re-check a source, versus go make a call.

### `_orientation.md` — the protocol that ties them together
This is what an LLM reads first, every session, before touching anything else. It's short by design: read the constitution, read the context, check the context file's age against a tunable threshold, and flag it explicitly if it's stale. It doesn't contain project content itself — it just names the procedure, so you're not re-explaining "read these two files and check the date" by hand every time.

The staleness check is the mechanism that makes the silent failure loud. A file's age, compared against a threshold you set, is the one piece of information a document can't lie about just by reading confidently.

### `overlays/` — domain-specific extensions to the constitution
`CONSTITUTION.md` stays universal on purpose. Anything specific to a particular kind of work — what "fake work" looks like for code versus for legal drafting versus for design — goes in its own file under `overlays/` instead, so the base file stays short and stable. See `overlays/README.md` for the pattern and `overlays/coding.md` for a worked example.

---

## How to instantiate this for a new project

1. Copy this whole folder into your project (or clone it fresh per project — don't fork the repo itself unless you're contributing back to the template).
2. Fill in `CONSTITUTION.md` first. It changes least, so get the foundations down before the moving parts.
3. Fill in `CONTEXT.md`, sorting each fact into **Derived** (note its source) or **Judgment** (your own call). When in doubt, ask: "if this turns out wrong next month, is that because a source changed, or because I changed my mind?" That answer tells you which half it belongs in.
4. Point your LLM tool at `_orientation.md` at the start of a session — either by naming it directly, or by setting it as a standing instruction (e.g. a saved preference) so you don't have to name it every time.
5. Adjust the staleness threshold in `_orientation.md` if 14 days doesn't fit your project's pace — a fast-moving effort might want 3 days; a slow one might want 30.

---

## When token conservation earns its keep

`CONSTITUTION.md` includes a TOKEN CONSERVATION section — rules about not re-summarizing, batching similar work, and surfacing (not hunting for) leaner alternatives. It's worth being deliberate about when to actually turn this on, rather than including it by default in every project.

**It earns its keep when:**
- Sessions are long and agentic — many turns, many tool calls, state accumulating that would be wasteful to keep re-explaining.
- Tool loops are expensive — each round trip (a search, an API call, a file read) has real latency or cost, so avoiding redundant ones actually matters.
- Context is large — enough prior material in play that restating it is a meaningful chunk of the conversation, not a throwaway line.

**It's overhead when:**
- The exchange is short — a few turns, done.
- It's a one-shot question — there's nothing to conserve tokens *across*, since there's no second turn to carry savings into.
- The project is early and exploratory — you're still figuring out what the constitution should even say, and optimizing verbosity before that settles is premature.

Treat this section as tunable, not gospel. If you copy this template into a small project and the token-conservation rules make responses feel clipped or unhelpfully terse for no real benefit, cut the section — it's not doing its job there. The point is leaner sessions where leanness is actually worth something, not verbosity-avoidance as a reflex.

---

## What this template is not

- Not a memory system. It doesn't persist anything on its own — it's a convention for organizing files you maintain yourself.
- Not a guarantee of freshness. It can't stop `CONTEXT.md` from going stale, and it does not detect stale *content* — it checks one file's modified timestamp. Editing a single line resets that clock for every entry in the file, and copying or restoring the file can reset it without anything being reviewed. Treat it as a coarse file-age prompt to re-read, not a guarantee that stale facts get caught.
- Not tied to any particular LLM tool. The protocol just assumes something capable of reading files and checking a modified timestamp — adapt the mechanics to whatever environment you're in.

---

## Part two: the skills stack + Inbox Ingestor

Everything above is the orientation protocol — how an LLM gets up to speed on *your* project. This second half is a separate, complementary layer: a curated set of Claude skills, already inside this repo, plus one original tool.

```
MasterVault/
├── CONSTITUTION.md, CONTEXT.md, _orientation.md   ← the protocol (see above)
├── overlays/                                       ← domain-specific constitution extensions
├── skills/                                         ← vendored skills (copied snapshots)
├── automation/
│   └── inbox-ingestor/                             ← original: PDF→markdown watcher
├── install.sh                                      ← links skills/ into ~/.claude/skills/
├── tests/                                          ← installer regression suite + layout fixtures
└── Attributions/ATTRIBUTIONS.md                    ← every vendored skill, author, license
```

### What's vendored

Every skill in `skills/` is a **copied snapshot** of its upstream repo, committed directly here — not a submodule, not a subtree. One `git clone` gets you everything, no second init step.

Because they're snapshots, there is no automatic update path: refreshing a skill means re-copying it from upstream and committing the result. The snapshots were taken July 2026; upstream has moved on since, and this repo does not track exact upstream commits. If you need a specific upstream version, go to the source repo rather than trusting this copy.

See `Attributions/ATTRIBUTIONS.md` for the full list, authors, and confirmed licenses. Every vendored source ships its original license file.

### Setup

```bash
git clone https://github.com/JustMichael-80/MasterVault.git
cd MasterVault
```

`install.sh` does **not** install anything by default. Start here:

```bash
./install.sh --list      # what's in the repo, and which skills ship executable scripts
./install.sh --dry-run   # what would be linked, without touching anything
```

Then link what you actually want:

```bash
./install.sh --skill systematic-debugging
./install.sh --all       # if you've reviewed them and want the lot
```

Re-running is safe: the installer replaces only symlinks it can verify, refuses to overwrite real files or directories, and never writes inside `skills/`.

Then confirm it actually worked:

```bash
./install.sh --verify
```

`--verify` is the one that matters. Documentation can claim a skill is
installed; only `--verify` checks. It reports missing links, stale links
pointing somewhere else, real files blocking a link, and orphans (linked, but
gone from the source), and exits non-zero if anything is wrong. Run it after any
change, and any time you're about to trust a claim about what's installed.

It also works against a skills collection kept somewhere else:

```bash
./install.sh --from ~/path/to/my-skills --verify
./install.sh --from ~/path/to/my-skills --all
```

**Read this before `--all`:** these are third-party skills. A skill is instructions Claude follows, and many ship shell/Python scripts it can execute. `--list` flags which. Anthropic's own guidance is to audit less-trusted skills and their bundled scripts before installing. I vendored these because I use them; that is not a security review, and you should not treat it as one. Link what you've looked at.

**Claude Code** discovers personal skills at `~/.claude/skills/` and follows directory symlinks as of **v2.1.203+**. Claude Desktop and claude.ai have their own skill mechanisms — the symlink approach here is verified for Claude Code only.

**A note on layouts.** Skill repos don't agree on where skills live. The
installer handles four arrangements: `<repo>/skills/<name>/`,
`<repo>/.claude/skills/<name>/` (a dotfolder), `<repo>/SKILL.md` for
single-skill repos, and `<repo>/<name>/SKILL.md` for a curated folder. It also
skips vendor-internal duplicates — repos that ship the same skill several times
under `plugins/`, `packages/`, or `cli/assets/` for different editors. Miss
either and the failure is silent: the installer reports success having linked
nothing, which is how a repo can sit "installed" for days while none of its
skills are actually available. `tests/fixtures/` has an example of each.

### Inbox Ingestor

A background watcher for anyone running an Obsidian-style vault (or any folder-based knowledge base) alongside Claude. Drop a PDF into an `_Inbox/` folder; it gets converted to markdown alongside the original.

**Known limits (current):** it handles file-creation events only, so PDFs that arrive by rename/atomic-move — which is how many sync clients and browsers write files — may not be picked up until the next restart. It waits a fixed 2s for copies to settle, which large or network-copied files can exceed. A failed conversion is logged once and not retried. If a `.md` of the same name already exists it skips unconditionally, so replacing a PDF leaves the old markdown in place. Extraction quality depends on the document; scanned PDFs without OCR produce little. Hardening this is the main open work — see the roadmap below.

- Runs as a persistent local service (`launchd` on macOS, adaptable to `systemd` on Linux) — not a script you have to remember to run.
- Uses `pymupdf4llm` for extraction — local, no API calls, no network dependency.
- Does **one job only**: conversion. It does not file, move, or organize anything — that's left to you, or to Claude with vault access, on purpose. Filing decisions need judgment; conversion doesn't.

Setup instructions live in `automation/inbox-ingestor/README.md`.

### Why symlinks, not copies, for the skills layer

Skills only need to exist once. Symlinking into `~/.claude/skills/` means re-copying a skill from upstream propagates without re-linking, and this repo stays the one place your collected skills live.

### Contributing a skill

Copy it into `skills/[name]/` with its LICENSE file intact, add a row to `Attributions/ATTRIBUTIONS.md` with author + confirmed license + link, and run `./tests/test_install.sh`. Open the license file and confirm it — don't assume MIT.

---

## Known limitations and roadmap

This repo was independently audited in July 2026 and the findings were, in the
main, correct. v1.1 fixed the defects that could damage a user's machine or
misrepresent what's here. What remains is tracked honestly rather than papered
over:

**Fixed in v1.1**
- Installer wrote self-referential symlinks into the vendored source tree on any
  second run, creating filesystem loops and dirtying the checkout. Fixed, with a
  regression test that fails against v1.0.
- Installer linked all 23 skills globally with no review step. Now installs
  nothing by default; `--list`, `--dry-run`, and `--skill` added.
- Installer only recognized two of the four skill-repo layouts in the wild. It
  silently found nothing in repos nesting skills under `.claude/skills/`, and
  collided on repos shipping vendor-internal duplicate copies. Both now handled,
  with fixtures covering all four — the first pass at the test suite passed
  against the broken discovery, because this repo's own tree doesn't exercise it.
- Added `--verify`: compares what's linked against what actually exists, and
  exits non-zero on missing/stale/orphaned links. Nothing in the project could
  previously answer "is this actually installed?"
- Added `--from DIR` so the installer can manage a skills collection kept
  outside this repo.
- README claimed `git subtree` provenance the history doesn't support. Now
  described accurately as copied snapshots.
- ATTRIBUTIONS listed four projects that aren't in the tree, left placeholder
  author fields, and marked an already-vendored license unverified. Rebuilt from
  the actual tree with confirmed licenses.
- Freshness and Claude Desktop claims narrowed to what's actually verified.

**Still open**
- **Inbox Ingestor hardening** — atomic writes, `on_moved` handling, stability
  polling instead of a fixed sleep, bounded retries, regenerating stale markdown,
  resource limits. Limits are documented above; the fix is the next work item.
- **Provenance manifest** — per-skill upstream commit SHA and content hash, so
  vendored copies can be verified against their source.
- **CI** — the installer suite (23 tests) runs locally; it should run on every
  push, on Linux and macOS.
- **Dependency pinning** — the watcher asks for unpinned `pymupdf4llm` and
  `watchdog`.
- **Entry-level freshness** — per-entry `verified_at` metadata would make the
  staleness check mean what the README originally implied.

## Credit

The July 2026 audit that prompted v1.1 was thorough and specific, and this repo
is better for it. Finding a real defect in someone's work and writing it up
clearly is a favor, not an attack.
