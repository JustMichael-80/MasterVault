# Overlays

`CONSTITUTION.md` holds only what's universal — rules that apply no matter what kind of project this is. That's deliberate: the base file is meant to stay short and stay stable, so it's worth actually reading in full every session.

Anything domain-specific — the particular ways *this kind* of project tends to fake completeness, or the particular checks that only make sense for one type of work — goes in an overlay instead.

**The pattern:**
- The base rule states a principle in domain-neutral terms.
- An overlay takes that principle and shows what it looks like in one specific domain — concrete failure modes, concrete checks, concrete examples.
- An overlay never contradicts or loosens the base rule. It only makes it more specific.

`coding.md` in this folder is the worked example: it takes the base constitution's "no fake work that makes output look complete" rule and shows what that looks like specifically for code and ML work — benchmark-faking, dummy metrics, and so on. It's illustrative, not load-bearing; if your project isn't a coding project, you probably don't need it at all.

**When to add a new overlay:** if you notice yourself repeatedly adding the same domain-specific caveat to the base constitution's sections, that's the signal to split it into its own `overlays/<domain>.md` instead — keep the base file universal, push the specifics out.
