# Task Timing Log

*Companion to the TEMPORAL SELF-CALIBRATION rule in `CONSTITUTION.md`. See `README.md` in this folder for the why and how.*
*Append-only. Keep rows terse. Note the **scale driver** so estimates scale, not just average.*

> **⚠️ SEED ROWS BELOW ARE ILLUSTRATIVE — DELETE THEM.**
> The rows in the "EXAMPLE" block are measurements from the template author's environment (a specific Claude instance in a specific container). Your tool latencies are different. They're here only to show the shape of a filled-in row. **Delete the EXAMPLE block and start recording your own.** Until you have several of your own rows per task type, treat any estimate as rough.

---

## Vault / file edits (read, write, edit)

| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| | | | | |

## Multi-file code work (scans, refactors, multi-edit)

| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| | | | | |

## Conversational replies

| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| | | | | |

## Document generation (docx / pptx / xlsx / pdf)

| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| | | | | |

## Web / search / fetch

| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| | | | | |

## Code execution / bash / data analysis

| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| | | | | |

---

## Rules of thumb

*Revise as your own data accumulates. Start empty; fill from your tables, not from anyone else's numbers.*

-

---

<!-- ============================================================= -->
<!-- EXAMPLE BLOCK — DELETE ALL OF THIS. Author-environment seed    -->
<!-- rows, shown only to illustrate row shape and the scale-driver  -->
<!-- discipline. These numbers do not apply to your machine.        -->
<!-- ============================================================= -->

### EXAMPLE — Vault / file edits
| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| 2026-07-20 | Add a section to a ~230-line rules file + 3 dir searches + tool-load | 1 read + 1 edit + 3 searches | ~1m 26s | Search/tool-load round-trips were most of it. |
| 2026-07-20 | Multi-step: recursive inbox tree + folder move + 2 dir creates + write log + 1 edit | ~9 tool round-trips | ~2m 04s | First real multi-step measurement. Cost tracked tool-call count, not thinking. |

### EXAMPLE — Conversational replies
| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| 2026-07-20 | Two-paragraph reflection + 2 `date` calls | 2 tool calls, no file I/O | ~10s | Mostly the two `date` round-trips. Reasoning ≈ free. |
| 2026-07-20 | Reflection reply + 2 `date` calls | 2 tool calls | ~12s | Consistent. Pure chat ≈ 10–12s, dominated by tool latency. |

### EXAMPLE — Web / search
| Date | Task | Scale driver | Elapsed | Notes |
|------|------|-------------|---------|-------|
| 2026-07-20 | 2 registry/tool searches (schema dumps) | 2 searches + 2 `date` | ~38s | **Quick in seconds, expensive in tokens** — the schema dumps were large. The clearest example of time ≠ tokens. |

### EXAMPLE — Rules of thumb (author environment, illustrative only)
- Pure conversational reply: ~10–12s, almost all tool-call latency. Thinking effectively free.
- Single vault edit (read + one edit): seconds; add a few seconds per extra search/read round-trip.
- **Dominant cost is tool round-trips, not reasoning.** Estimate by counting tool calls, not problem difficulty.
- Time, tokens, and effort are three separate meters — a fast search can be token-heavy; a slow edit can be token-light.

<!-- ============ END EXAMPLE BLOCK — DELETE TO HERE ============ -->
