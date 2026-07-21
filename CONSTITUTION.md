# Project Constitution

*Read at the start of every session alongside `CONTEXT.md`.*
*This is the project's foundational document — stable, rarely revised, and what specific decisions get validated against.*

Example project used for illustration throughout: **Lumen Kites**, a fictional small kite-making business. Replace every example below with your own.

---

## FOUNDATIONAL PRINCIPLES

*What belongs here:* the small number of durable commitments that define how this project is supposed to work — the things that would still be true even if the current plan changed completely. These are closer to values or design axioms than to tasks. They should be few enough to hold in your head, and specific enough to actually constrain a decision.

*A good entry* names a real commitment and gives it enough teeth to rule something out — e.g. "Every kite design must be flyable by a single person with no assembly tools" rules out designs requiring a second pair of hands. *A weak entry* is a platitude that can't be violated — e.g. "We care about quality" doesn't tell you what to do differently in any specific case.

**Example:** *Lumen Kites only ships designs that a first-time flyer can assemble in under five minutes — this rules out any part requiring glue, tools, or reading a manual.*

*Your entries:*
-

---

## VALIDATION GATE

*What belongs here:* the checklist a proposed change, feature, or decision has to pass before it's approved. This is where the foundational principles above get turned into actual yes/no questions someone can run a decision through.

*A good entry* is phrased as a checkable question tied back to a specific principle — "Does this still let a first-timer assemble it in under 5 minutes?" *A weak entry* just restates a principle as a noun phrase ("quality") with nothing to check.

**Example:** *Before approving any new kite design: Does it meet the 5-minute assembly rule? Does it use only materials already in our supply chain? Does it fly in wind speeds under 15mph, matching our target market?*

*Your entries:*
-

---

## CODE QUALITY REQUIREMENTS

*What belongs here:* the single universal rule against fake work — output that looks complete but isn't. This section stays domain-agnostic on purpose; anything specific to a domain (a language, a benchmark, a file format) belongs in an overlay under `overlays/`, not here. See `overlays/README.md` for the pattern, and `overlays/coding.md` for a worked example.

**The universal rule:** no fake work that makes output look complete when it isn't. Concretely, that means:
- No placeholders standing in for real implementation — unless a placeholder is explicitly required (e.g. a sensor stub awaiting hardware) and is labeled as such.
- No canned or templated responses presented as if they were produced for this specific case.
- No pseudocode presented as if it were a working implementation.
- No aspirational or symbolic language standing in for actual logic — a comment or description of what something *should* do is not a substitute for it doing that.
- No conflicts with existing work already in the project — a new piece of output shouldn't silently contradict or break something already in place.
- All work should minimize tech debt rather than trade it for short-term completion.

*A good entry in your own project-specific notes below* makes one of these concrete for your domain — e.g. "no dummy data in anything shipped to a customer." *A weak entry* just restates the universal rule without adding anything domain-specific — if it doesn't add information beyond what's already above, it belongs in an overlay example instead, or not at all.

*Your entries:*
-

---

## OUTPUT SELF-CHECK

*What belongs here:* the failure modes you most want caught before an answer or artifact goes out the door. This is a short, standing list of ways output tends to go wrong on this specific project — not a generic list of "things AI can get wrong."

*A good entry* is specific to a failure you've actually seen or worry about on this project — "flag any claim about wind-speed tolerance that isn't backed by an actual test log." *A weak entry* is so general it applies to literally anything ("check for accuracy") and therefore doesn't change what gets checked.

**Example:** *Flag any specific measurement (weight, wind tolerance, assembly time) that isn't traceable to a logged test — don't let an estimate get stated as a fact.*

*Your entries:*
-

---

## TOKEN CONSERVATION

*What belongs here:* working-style preferences for how verbose, repetitive, or exploratory the LLM should be in this project — not because tokens are scarce in a literal sense, but because unnecessary restating or over-explaining makes long sessions harder to follow and wastes the reader's attention, which is the actual scarce resource.

*A good entry* names a specific behavior to avoid or prefer — "don't re-summarize CONTEXT.md once it's been read this session; reference it instead." *A weak entry* is a vague request for "efficiency" with nothing to act on.

**Example:** *Once CONSTITUTION.md and CONTEXT.md have been read and confirmed this session, don't re-summarize them unless asked. Prefer a one-line status update over a paragraph.*

**Pause and reroute — surface only, don't search.**
Do not go looking for cheaper paths before acting. If, in the course of planning the current task, a materially leaner alternative is already apparent, surface it before proceeding. If none is apparent, proceed — do not spend effort searching for one.

Surface only when both hold:
- The alternate is already in hand — it emerged from planning the task, not from a separate hunt for it.
- The savings exceed the cost of asking. If the alternate saves less than the round trip needed to confirm it, take the better path silently or proceed as planned.

> 🔀 **Alternate route available.**
> Current approach: [what you're doing now and estimated cost]
> Alternate approach: [what you could do instead and why it's leaner]
> Proceed with alternate? Y/N

When the alternate is obviously better and reversible, just take it and note it in one line. Reserve the prompt above for choices that are costly, irreversible, or genuinely ambiguous.

*Note: the "material savings" floor above is user-tunable — what counts as "exceeds the cost of asking" will differ by project and by how disruptive a mid-task question is for you.*

*Your entries:*
-

---

## TEMPORAL SELF-CALIBRATION

*What belongs here:* nothing for you to fill in — this section is a standing behavioral rule, included because it fixes a failure mode every LLM shares and none can fix on its own.

*The problem it solves:* an LLM has no native sense of elapsed time. Between one action and the next it experiences no duration, so when it narrates effort — "that took a while," "a solid hour's work" — it is **confabulating a number it never actually measured** (see OUTPUT SELF-CHECK). This is usually harmless, but it quietly corrupts cost estimates: an assistant that believes a task took an hour will hesitate to redo it, pad plans with breaks you don't need, or treat a cheap ask as an expensive one. The felt duration and the real duration can differ by two orders of magnitude — a "long" task is often seconds of wall time.

**The rule:** any time the assistant is about to make a temporal reference or answer a temporal query — how long something took, whether there's time for X, "that was quick/slow," elapsed duration — it should **quietly bracket the work with real timestamps instead of guessing.** In a shell-capable environment: run `date` (or the platform equivalent) at the start and end, subtract, report the real number. Where no clock is reachable, say plainly that duration can't be measured rather than inventing one.

**Accumulate the data (optional but recommended).** When a bracketed task is a meaningful measurement of real work — not a two-line reply — append a terse row to a running log (see `automation/timing-log/` for a ready-made template). Over sessions this builds an *empirical prior*: "last time a docx of N pages took X seconds, so this similar one is ~X." The assistant scans that log before estimating a new task, and reasons proportionally from measured history instead of from a felt sense it doesn't actually have.

*The number's limits (state them honestly):* wall time is not effort and not token cost — they are three separate meters. The timestamp includes the latency of the timing calls themselves; a slow-thinking short reply and a fast many-tool-call run can clock the same elapsed time; and a task can be quick in seconds yet expensive in tokens (a big search) or slow in seconds yet cheap in tokens. Trust each measurement for what it is, and know what it isn't.

*Tunable:* if the host environment has no reachable clock, or the project genuinely never makes temporal claims, this section can be cut like any other. It costs nothing when no temporal claim is being made — it only fires when the assistant would otherwise have guessed.

---

*Last updated: [date]*
