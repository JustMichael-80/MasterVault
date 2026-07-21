# Timing Log — self-calibration dataset (template)

A ready-made companion to the **TEMPORAL SELF-CALIBRATION** rule in `CONSTITUTION.md`. Copy `TIMING_LOG.md` (in this folder) into wherever your assistant keeps working notes, point the constitution rule at it, and let it fill over time.

## The idea

An LLM can't feel how long anything takes, so it guesses — usually badly. This log replaces the guess with data. Every time the assistant brackets a task with real timestamps (per the constitution rule), it appends one terse row. After a handful of sessions the tables stop being empty and start being a lookup: *"a multi-file code scan ran ~2 min last three times, so budget ~2 min."*

The assistant scans the relevant table **before** estimating a new task, and reasons proportionally from the closest past measurements rather than from a felt sense it doesn't have.

## How to use

1. Keep `TIMING_LOG.md` somewhere the assistant reads (a `_meta/` folder, the vault root — wherever fits your layout).
2. In `CONSTITUTION.md`'s TEMPORAL SELF-CALIBRATION section, point at that path.
3. Trigger: any time the assistant makes a temporal claim, it brackets with `date` (start/end) and, if the task was real work, appends a row.
4. Organize rows by **task type** (tables in the log) and always note the **scale driver** — file size, line count, number of tool calls, number of files — so estimates scale with size instead of just averaging to one number.

## The three-meter caveat (read once)

Wall time, effort, and token cost are **three different meters** and this log only measures the first:

- **Wall time** (what `date` gives you) includes the latency of the timing calls themselves and every tool round-trip. Dominated by I/O, not thinking.
- **Effort** isn't captured — a slow-thinking short reply and a fast forty-tool-call run can clock the same wall time.
- **Token cost** is orthogonal — a single web search can be quick in seconds but expensive in tokens; a long careful edit can be slow but cheap.

So: use this log to answer "how many wall-clock seconds will this take," not "how much will it cost" or "how hard is it." Note token-heavy tasks in the Notes column when you spot the divergence.

## Timezone note

If your assistant's shell runs in a different timezone than you (e.g. a UTC container while you're local), the **elapsed delta is still correct** — subtraction is timezone-independent. Only convert when the absolute wall-clock time itself matters to you.

---

*Bundled with MasterVault Template. `TIMING_LOG.md` ships with illustrative seed rows from the template author's own environment — **delete them and start fresh**, since one machine's tool latencies are not yours.*
