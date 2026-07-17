# v1.1 — Installer safety and honest claims

**If you cloned v1.0, read this.**

v1.0's installer was not safe to re-run. Running `./install.sh` a second time
wrote self-referential symlinks *inside* the vendored `skills/` directories —
`stop-slop/stop-slop`, `mcp-builder/mcp-builder`, and so on — creating
filesystem loops that confuse `find`, backup tools, and git. If you ran it more
than once, your checkout is likely dirty.

**Clean up:**

```bash
cd MasterVault
find skills -type l          # look first — these are the strays
find skills -type l -delete  # then remove them
git status                   # should be clean now
git pull
./install.sh --list          # v1.1 installs nothing by default
```

Your `~/.claude/skills/` links themselves were fine. The damage was to the repo
checkout, not your Claude setup.

---

## What changed

### The installer no longer installs by default

v1.0 linked all 23 third-party skills into `~/.claude/skills/` the moment you
ran it. That was the wrong default for a repo other people clone. v1.1 requires
you to say what you want:

```bash
./install.sh --list      # what's here, and which skills ship executable scripts
./install.sh --dry-run   # what would happen, without doing it
./install.sh --skill systematic-debugging
./install.sh --all       # only if you've actually reviewed them
```

`--list` now flags which skills contain shell/Python/JS, because a skill isn't
just text — it's instructions Claude follows, often with scripts it can run. I
vendored these because I use them. That's not a security review. Link what
you've looked at.

### The installer is actually idempotent now

Re-running replaces only symlinks it can verify, refuses to overwrite real files
or directories, detects name collisions before touching anything, and never
writes inside `skills/`.

### It now finds skills that were silently being skipped

v1.0 recognized two layouts: `<repo>/skills/<name>/`, or a single-skill repo
with `SKILL.md` at its root. That covers what's vendored here, which is why
nothing looked wrong.

It does not cover the real world. Two more layouts exist:

- **`<repo>/.claude/skills/<name>/`** — a dotfolder. At least one popular
  design-skills repo ships this way.
- **`<repo>/<name>/SKILL.md`** — a curated folder of skill directories, no
  `skills/` level at all.

Point v1.0 at either and it finds nothing, links nothing, and **reports
success**. No error. The skills just aren't there, and nothing tells you.

I found this the hard way. A skills collection of mine had been carrying a repo
that was never installed — every note I had said it was live, and it wasn't, for
three days. The only reason I noticed was going and looking.

Some repos also ship the same skill several times, under `plugins/` for
different editors or `cli/assets/` for a CLI. Those duplicates collide with the
canonical copy on name. v1.1 skips them.

### There's now a way to check

```bash
./install.sh --verify
```

Compares what's linked against what actually exists:

- `MISSING` — in the source, not linked
- `STALE` — linked, but pointing somewhere else
- `NOT-LINK` — a real file or directory sits where a link should be
- `ORPHAN` — linked, but gone from the source tree

Exits non-zero if anything's wrong, so you can wire it into a check. Also works
against a collection kept outside this repo:

```bash
./install.sh --from ~/my-skills --verify
./install.sh --from ~/my-skills --all
```

### The README stopped claiming things that weren't true

- **Provenance:** v1.0 said every skill came in via `git subtree` and could be
  updated with `git subtree pull`. It couldn't — the skills were copied in, and
  `git subtree pull` would have failed for anyone who tried. They're now
  described as what they are: snapshots taken in July 2026, with no automatic
  update path.
- **Freshness:** "guarantees that staleness gets flagged" was too strong. The
  check reads one file's mtime. Fix a typo in `CONTEXT.md` and every stale entry
  in it looks fresh again. It's now described as a coarse file-age prompt, which
  is what it is.
- **Claude Desktop:** the automatic-discovery claim is verified for Claude Code
  (v2.1.203+ for symlink support). Desktop and claude.ai have their own
  mechanisms. Only the verified claim survives.
- **Attributions:** the table listed four projects that were never in this repo,
  left `[Your name]` placeholders in a public MIT repo, and marked Context7's
  license "check before vendoring" while it was already vendored. Rebuilt from
  the actual tree: 23 skills, 4 sources, every license opened and confirmed
  (Anthropic Apache-2.0; Superpowers, Context7, stop-slop MIT).

### Tests

23 of them, at `tests/test_install.sh`. They fail against v1.0 — that's the
point. A test that can't fail against the bug it describes isn't a test.

The discovery tests use fixtures in `tests/fixtures/` covering all four layouts
and both duplicate patterns, because **this repo's own `skills/` folder only
exercises two of them.**

### Inbox Ingestor limits are documented

Not fixed yet — documented. It handles creation events only, so PDFs arriving by
rename/atomic-move (how many sync clients write files) can be missed until
restart. Fixed 2s settle. One-shot failure handling. Skips unconditionally if a
same-named `.md` exists, so replacing a PDF leaves stale markdown. Hardening is
the next work item; until then you know what you're getting.

---

## The pattern worth naming

v1.0 was independently audited, and nearly every serious finding was a
**documentation** problem rather than a code problem. The scaffold was fine. The
README was writing checks the repo couldn't cash.

Then the same failure showed up one level down, in the fix itself. The first
pass at these tests was green — and would have stayed green against a discovery
function that silently skipped half the repos it'd ever meet, because the test
tree only contained the layouts I happened to have vendored. A passing suite
asserted "discovery works" when what it established was "discovery works on the
two cases we have." The tests were the documentation, and they were
overclaiming.

`--verify` exists because of that. Every layer here — the README, the context
file you point an LLM at, the test suite — can assert something true-sounding
about the world. `--verify` goes and looks. It's the only thing in the project
that does, and it's ten lines of `readlink`.

That's the actual lesson of this release, and it generalizes past this repo: if
you keep a file that tells an assistant what's true, that file cannot tell you
when it's wrong. Something has to go check.

If you find something else wrong, open an issue. It's a favor.
