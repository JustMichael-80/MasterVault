# Orientation Protocol

*Read this file first, every session. It replaces manually naming `CONSTITUTION.md` and `CONTEXT.md` — this single file tells any LLM instance what to do.*

---

## Steps, in order

1. **Read `CONSTITUTION.md`** (project root). This is the project's foundational document — principles, standards, and validation criteria that specific decisions get checked against. It does not change often and is not to be modified under any circumstance during ordinary session work.

2. **Read `CONTEXT.md`** (project root). This is the living session-context file — current state, priorities, and open decisions, split into Derived and Judgment halves (see `CONTEXT.md` itself for what that split means).

3. **Check `CONTEXT.md`'s staleness.** Call `get_file_info` (or your environment's equivalent) on it and compare the `modified` timestamp against the current date.
   - **Threshold: 14 days.** *(User-tunable — change this number to whatever fits your project's pace. A fast-moving project might want 3 days; a slow one might want 30. There is nothing special about 14; it's a starting default.)*
   - If the file is **at or beyond the threshold**: flag this explicitly before proceeding with any other work this session. State the flag plainly — for example: "CONTEXT.md was last modified N days ago — flagging in case anything's stale before we continue." Don't bury it in other output.
   - If under the threshold: no flag needed, proceed normally.
   - **This check is read-only.** Do not write timestamps, "last checked" notes, or any staleness metadata into project files. The check happens fresh every session; nothing about it gets persisted.

4. **Do not restate context back to the project owner** once both files are read. Orient silently, then proceed to the actual task.

5. **When the task at hand could benefit from a specialized skill** (frontend/UI work, debugging workflows, docs lookup, etc.), check `skills/` and `Attributions/ATTRIBUTIONS.md` for a vendored skill that might apply before improvising from scratch. `ATTRIBUTIONS.md` lists what's vendored, by source and name; if a name looks like a plausible match, read that skill's own `SKILL.md` (under `skills/<source>/<name>/`) for its actual description and instructions before proceeding.
   - This step matters most for LLM environments that don't natively auto-discover skills the way Claude Code does (e.g. this protocol being read directly in a chat interface, or by a different LLM tool entirely). If your environment already auto-discovers skills on its own, this step is redundant — skip it.
   - Don't hand-read every skill's full `SKILL.md` up front. Check names/sources first; only open the full file for a genuine candidate match.

---

## What this file is NOT

- Not a replacement for `CONSTITUTION.md` or `CONTEXT.md` themselves — both still need to be read in full each session; this just names the procedure so the project owner doesn't have to specify both files by name every time.
- Not a place to log session summaries, decisions, or anything else — this is protocol only. Session-specific content belongs in `CONTEXT.md` or the relevant project file.
