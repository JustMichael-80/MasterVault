# Installer test fixtures

Synthetic skill trees covering layouts that MasterVault's own `skills/` folder
does not contain. Without these, `test_install.sh` would pass against a
discovery function that silently skips real-world repos — which is exactly what
happened before they existed.

Each mirrors a layout found in an actual community skills repo:

| Fixture | Mirrors | What it catches |
|---|---|---|
| `dotfolder-repo/.claude/skills/` | nextlevelbuilder/ui-ux-pro-max-skill | Skills nested in a **dotfolder**. A discovery loop that only looks at `<repo>/skills/` finds nothing here and reports success — a silent failure that can leave a whole repo uninstalled while your notes insist it's live. |
| `dotfolder-repo/cli/assets/skills/` | the same repo's CLI asset copies | A vendor-internal duplicate of a skill the repo already ships. Must be skipped, or it collides with the canonical copy. |
| `curated-repo/<skill>/` | anthropics/skills, as vendored under `skills/anthropic/` | Skill directories sitting directly inside the repo folder, with no `skills/` level at all. |
| `dupes-repo/plugins/` | upstash/context7 | The same skill shipped several times for different editors. Only the canonical `skills/` copy should link. |

These are fixtures, not installable skills. Nothing here is linked by
`install.sh` in normal use — it reads `skills/`, or an explicit `--from` path.
The tests point at this directory deliberately.

## Why this exists

The v1.0 test suite had 13 passing tests and could not detect a discovery bug,
because every fixture it ran against used the two layouts the repo happened to
vendor. Green tests attested to "discovery works" when what they established was
"discovery works on the cases we have."

If you add a skill repo with a layout not represented here, add a fixture for it
in the same commit. A test that can't fail against the bug it describes isn't a
test.
