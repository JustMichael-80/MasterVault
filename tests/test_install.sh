#!/usr/bin/env bash
# Regression tests for install.sh
#
# Two classes of test live here, and both exist because of a real bug:
#
#   1. Idempotency (test 5) — the v1.0 installer wrote a self-referential
#      symlink inside the vendored source tree on any second run.
#   2. Discovery (tests 14-18) — the v1.0 installer only recognized two of the
#      four skill-repo layouts in the wild, and silently found nothing in the
#      others. The repo's own skills/ folder can't exercise that, so these use
#      fixtures. See tests/fixtures/README.md.
#
# Run: ./tests/test_install.sh

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO_DIR/install.sh"
SANDBOX="$(mktemp -d)"
export CLAUDE_SKILLS_DIR="$SANDBOX/skills"

PASS=0
FAIL=0

trap 'rm -rf "$SANDBOX"' EXIT

ok()   { printf '  \033[32mPASS\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
reset() { rm -rf "$SANDBOX/skills"; }

# macOS ships shasum, not md5sum; Linux usually has both.
hash_tree() {
  if command -v shasum >/dev/null 2>&1; then
    find "$1" -maxdepth 1 2>/dev/null | sort | shasum
  else
    find "$1" -maxdepth 1 2>/dev/null | sort | md5sum
  fi
}

echo "install.sh regression tests"
echo "sandbox: $SANDBOX"
echo

# 1. Fail closed: no arguments installs nothing.
reset
if "$INSTALL" >/dev/null 2>&1; then
  bad "no-args should not install"
else
  [ -d "$SANDBOX/skills" ] && bad "no-args created target dir" || ok "no-args installs nothing"
fi

# 2. --list installs nothing.
reset
"$INSTALL" --list >/dev/null 2>&1
[ -d "$SANDBOX/skills" ] && bad "--list created target dir" || ok "--list installs nothing"

# 3. --dry-run installs nothing.
reset
"$INSTALL" --dry-run >/dev/null 2>&1
[ -d "$SANDBOX/skills" ] && bad "--dry-run created target dir" || ok "--dry-run installs nothing"

# 4. First run links skills.
reset
"$INSTALL" --all >/dev/null 2>&1
N1=$(find "$SANDBOX/skills" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
[ "$N1" -gt 0 ] && ok "first run linked $N1 skill(s)" || bad "first run linked nothing"

# 5. IDEMPOTENCY — the v1.0 bug. Second run must not change anything.
BEFORE=$(hash_tree "$SANDBOX/skills")
"$INSTALL" --all >/dev/null 2>&1
AFTER=$(hash_tree "$SANDBOX/skills")
[ "$BEFORE" = "$AFTER" ] && ok "second run produces identical links" || bad "second run changed the target"

# 6. Second run must not write inside the source tree.
STRAY=$(find "$REPO_DIR/skills" -type l 2>/dev/null | wc -l | tr -d ' ')
[ "$STRAY" -eq 0 ] && ok "no symlinks created inside skills/" || {
  bad "stray symlink(s) inside source tree:"
  find "$REPO_DIR/skills" -type l
}

# 7. No filesystem loops.
if find -L "$REPO_DIR/skills" -maxdepth 4 2>&1 | grep -q 'loop'; then
  bad "filesystem loop detected in source tree"
else
  ok "no filesystem loops"
fi

# 8. Refuse to overwrite a real directory.
reset
mkdir -p "$SANDBOX/skills/stop-slop"
echo "user's own work" > "$SANDBOX/skills/stop-slop/SKILL.md"
"$INSTALL" --skill stop-slop >/dev/null 2>&1
if grep -q "user's own work" "$SANDBOX/skills/stop-slop/SKILL.md" 2>/dev/null; then
  ok "refuses to clobber a real directory"
else
  bad "overwrote a real directory"
fi

# 9. Refuse to overwrite a real file.
reset
mkdir -p "$SANDBOX/skills"
echo "not a skill" > "$SANDBOX/skills/stop-slop"
"$INSTALL" --skill stop-slop >/dev/null 2>&1
if [ -f "$SANDBOX/skills/stop-slop" ] && grep -q "not a skill" "$SANDBOX/skills/stop-slop"; then
  ok "refuses to clobber a real file"
else
  bad "overwrote a real file"
fi

# 10. Selective install links only what was asked for.
reset
"$INSTALL" --skill stop-slop >/dev/null 2>&1
N=$(find "$SANDBOX/skills" -maxdepth 1 -type l | wc -l | tr -d ' ')
[ "$N" -eq 1 ] && ok "--skill links exactly one skill" || bad "--skill linked $N (expected 1)"

# 11. Unknown skill name fails loudly.
reset
if "$INSTALL" --skill definitely-not-a-real-skill >/dev/null 2>&1; then
  bad "unknown skill did not fail"
else
  ok "unknown skill exits non-zero"
fi

# 12. A stale link pointing elsewhere gets repointed.
reset
mkdir -p "$SANDBOX/skills"
ln -s /tmp/some-old-path "$SANDBOX/skills/stop-slop"
"$INSTALL" --skill stop-slop >/dev/null 2>&1
TARGET="$(readlink "$SANDBOX/skills/stop-slop")"
case "$TARGET" in
  "$REPO_DIR"/skills/stop-slop) ok "stale link repointed to current source" ;;
  *) bad "stale link not repaired (-> $TARGET)" ;;
esac

# 13. Every linked skill resolves to a real SKILL.md.
reset
"$INSTALL" --all >/dev/null 2>&1
BROKEN=0
for l in "$SANDBOX"/skills/*; do
  [ -e "$l/SKILL.md" ] || BROKEN=$((BROKEN+1))
done
[ "$BROKEN" -eq 0 ] && ok "all links resolve to a SKILL.md" || bad "$BROKEN broken link(s)"

# 14. claude-math keeps its nested upstream layout.
reset
OUT_CM="$("$INSTALL" --list 2>/dev/null || true)"
if echo "$OUT_CM" | grep -q '^math-unicode.*claude-math/skills/math-unicode'; then
  ok "finds claude-math from its upstream nested skill layout"
else
  bad "MISSED claude-math nested skill layout"
fi

# 15. claude-math retains its upstream MIT license.
if [ -f "$REPO_DIR/skills/claude-math/LICENSE" ] && grep -q 'MIT License' "$REPO_DIR/skills/claude-math/LICENSE"; then
  ok "claude-math retains its upstream MIT license"
else
  bad "claude-math is missing its upstream MIT license"
fi

# --- Discovery across real-world layouts ----------------------------------
# The repo's own skills/ only contains layouts 1 and 3. Without these fixtures
# a discovery bug in layout 2 or 4 passes silently — which is exactly how a
# whole skill repo can sit uninstalled while the docs claim it's live.

FIX="$REPO_DIR/tests/fixtures"

# 16. Dotfolder layout: <repo>/.claude/skills/<name>/
reset
OUT="$("$INSTALL" --from "$FIX" --list 2>/dev/null || true)"
if echo "$OUT" | grep -q '^alpha-skill' && echo "$OUT" | grep -q '^beta-skill'; then
  ok "finds skills nested in .claude/skills/ (dotfolder layout)"
else
  bad "MISSED dotfolder layout — the silent-skip bug"
fi

# 17. Curated layout: <repo>/<name>/SKILL.md with no skills/ level
if echo "$OUT" | grep -q '^gamma-skill' && echo "$OUT" | grep -q '^delta-skill'; then
  ok "finds skills in a curated repo folder (no skills/ level)"
else
  bad "MISSED curated layout"
fi

# 18. Vendor-internal duplicates are skipped, not collided on.
if echo "$OUT" | grep -q '^epsilon-skill'; then
  ok "canonical copy of a duplicated skill is found"
else
  bad "canonical skill lost among vendor duplicates"
fi

# 19. The CLI-asset duplicate must NOT produce a second entry.
N_ALPHA=$(echo "$OUT" | grep -c '^alpha-skill' || true)
[ "$N_ALPHA" -eq 1 ] && ok "cli/assets duplicate skipped (no collision)" \
                     || bad "cli/assets duplicate not skipped (alpha-skill x$N_ALPHA)"

# 20. plugins/ duplicates must not produce extra entries.
N_EPS=$(echo "$OUT" | grep -c '^epsilon-skill' || true)
[ "$N_EPS" -eq 1 ] && ok "plugins/ duplicates skipped" \
                   || bad "vendor duplicates not skipped (epsilon-skill x$N_EPS)"

# --- Verify mode ----------------------------------------------------------

# 21. --verify installs nothing.
reset
"$INSTALL" --verify >/dev/null 2>&1 || true
[ -d "$SANDBOX/skills" ] && bad "--verify created target dir" || ok "--verify installs nothing"

# 22. --verify reports a clean tree after --all.
reset
"$INSTALL" --all >/dev/null 2>&1
if "$INSTALL" --verify >/dev/null 2>&1; then
  ok "--verify passes on a fully linked tree"
else
  bad "--verify failed on a tree it just linked"
fi

# 23. --verify DETECTS a missing skill and exits non-zero.
#     This is the check whose absence let a whole repo go missing unnoticed.
rm -f "$SANDBOX/skills/stop-slop"
if "$INSTALL" --verify >/dev/null 2>&1; then
  bad "--verify did NOT detect a missing skill"
else
  OUT2="$("$INSTALL" --verify 2>&1 || true)"
  echo "$OUT2" | grep -q 'MISSING   stop-slop' \
    && ok "--verify names the missing skill and exits non-zero" \
    || bad "--verify exited non-zero but did not name the missing skill"
fi

# 24. --verify detects a stale link pointing at the wrong place.
reset
"$INSTALL" --all >/dev/null 2>&1
rm -f "$SANDBOX/skills/stop-slop"
ln -s /tmp/wrong-place "$SANDBOX/skills/stop-slop"
OUT3="$("$INSTALL" --verify 2>&1 || true)"
echo "$OUT3" | grep -q 'STALE' && ok "--verify detects a stale link" || bad "--verify missed a stale link"

# 25. --verify reports orphans (linked, but no longer in source).
reset
"$INSTALL" --all >/dev/null 2>&1
ln -s /tmp/nowhere "$SANDBOX/skills/some-removed-skill"
OUT4="$("$INSTALL" --verify 2>&1 || true)"
echo "$OUT4" | grep -q 'ORPHAN    some-removed-skill' \
  && ok "--verify reports orphaned links" || bad "--verify missed an orphan"

echo
echo "passed: $PASS   failed: $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
