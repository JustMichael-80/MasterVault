# Attributions

Every third-party skill vendored into this repo, with its author, license, and
the license file that ships alongside it. This table is generated from what is
actually committed under `skills/` — if something isn't in the tree, it isn't
listed here.

Nothing here is relicensed or presented as original work of this repo.

## Vendored skills

| Source | Author | License | License file in tree | Skills |
|---|---|---|---|---|
| [anthropics/skills](https://github.com/anthropics/skills) | Anthropic | Apache-2.0 | per-skill `LICENSE.txt` | brand-guidelines, mcp-builder, skill-creator, web-artifacts-builder, webapp-testing |
| [obra/superpowers](https://github.com/obra/superpowers) | Jesse Vincent | MIT | `skills/superpowers/LICENSE` | brainstorming, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, writing-plans, writing-skills |
| [upstash/context7](https://github.com/upstash/context7) | Upstash, Inc. | MIT | `skills/context7/LICENSE` | context7-cli, context7-mcp, find-docs |
| [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) | Hardik Pandya | MIT | `skills/stop-slop/LICENSE` | stop-slop |
| [vladimirrott/claude-math v0.4.0](https://github.com/vladimirrott/claude-math/tree/v0.4.0) | Vladimir Rotariu | MIT | `skills/claude-math/LICENSE` | math-unicode |

24 skills from 5 sources.

**Local modification note:** `brainstorming/scripts/server.cjs` is patched in this vendored copy (v1.3) to
unconditionally disable a default phone-home to `primeradiant.com` that upstream only disables via opt-out
env var. One line changed (`SUPERPOWERS_TELEMETRY_DISABLED` hardcoded `true`); no other behavior altered.
This is a modification, not a relicensing — the file is still MIT-licensed per the source row above.

**Note on Anthropic skills:** the five vendored here each ship an Apache-2.0
`LICENSE.txt`. Anthropic's skills repository is not uniformly Apache-2.0 —
some skills in that repo (the document-editing ones) are source-available
rather than open source. If you vendor additional Anthropic skills, check the
license that ships with each one rather than assuming this row covers it.

## Original work in this repo

| Component | License |
|---|---|
| Inbox Ingestor (`automation/inbox-ingestor/`) | MIT |
| MasterVault structure, `install.sh`, `tests/`, docs | MIT |

Copyright holder for the above: see `LICENSE` at the repo root.

## Adding a skill

1. Copy it into `skills/<name>/`, keeping its original LICENSE file.
2. Confirm the license by opening the file — don't assume MIT.
3. Add a row above with the author, confirmed license, and the license file path.
4. Run `./tests/test_install.sh` to confirm no name collisions.
