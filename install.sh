#!/usr/bin/env bash
# MasterVault installer — links skills from skills/ into ~/.claude/skills/
#
# Safe to re-run: replaces only symlinks it can verify, never writes inside
# the vendored source tree, and refuses to clobber real files or directories.
#
# Usage:
#   ./install.sh --list                  # show what's available, install nothing
#   ./install.sh --dry-run               # show what WOULD be linked
#   ./install.sh --verify                # compare what's linked vs what exists
#   ./install.sh --all                   # link every skill
#   ./install.sh --skill NAME [--skill NAME ...]
#
# Options:
#   --from DIR    read skills from DIR instead of ./skills
#
# Requires bash 3.2+ (stock macOS bash is fine).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

MODE=""
SELECTED=()

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --list)    MODE="list"; shift ;;
    --dry-run) MODE="dry"; shift ;;
    --verify)  MODE="verify"; shift ;;
    --all)     MODE="all"; shift ;;
    --from)    [ $# -ge 2 ] || die "--from needs a DIR"
               SKILLS_DIR="${2%/}"; shift 2 ;;
    --skill)   [ $# -ge 2 ] || die "--skill needs a NAME"
               [ -z "$MODE" ] && MODE="select"; SELECTED+=("$2"); shift 2 ;;
    -h|--help) usage 0 ;;
    *)         die "unknown option: $1 (try --help)" ;;
  esac
done

[ -n "$MODE" ] || { echo "Nothing selected. This installer does not install by default."; echo; usage 1; }
[ -d "$SKILLS_DIR" ] || die "no skills directory at $SKILLS_DIR"

# --- Discover -------------------------------------------------------------
# A skill is a directory containing SKILL.md. Real repos use four layouts:
#   1. <repo>/skills/<name>/          — superpowers, context7, marketingskills
#   2. <repo>/.claude/skills/<name>/  — ui-ux-pro-max-skill (a DOTFOLDER; missing
#                                       this silently skips every skill in the repo)
#   3. <repo>/SKILL.md                — stop-slop (single-skill repo)
#   4. <repo>/<name>/SKILL.md         — a curated folder of skill dirs
#
# Some repos also ship duplicate copies of their own skills for other editors
# or as CLI assets. Those are vendor-internal and must be skipped, or they
# collide with the canonical copy. See tests/fixtures/ for all four.

NAMES=()
PATHS=()

is_vendor_internal() {
  case "$1" in
    */cli/assets/skills/*|*/plugins/*|*/packages/*|*/node_modules/*|*/.git/*) return 0 ;;
    *) return 1 ;;
  esac
}

add_skill() {
  name="$1"; path="$2"
  if [ "${#NAMES[@]}" -gt 0 ]; then
    for i in "${!NAMES[@]}"; do
      if [ "${NAMES[$i]}" = "$name" ]; then
        die "duplicate skill name '$name'
  already from: ${PATHS[$i]}
  also from:    $path
Two skills cannot share one name in $TARGET_DIR. Resolve before installing."
      fi
    done
  fi
  NAMES+=("$name")
  PATHS+=("$path")
}

for repo in "$SKILLS_DIR"/*/; do
  [ -d "$repo" ] || continue
  repo="${repo%/}"
  found=0

  # Layouts 1 and 2
  for root in "$repo/skills" "$repo/.claude/skills"; do
    [ -d "$root" ] || continue
    for s in "$root"/*/; do
      [ -d "$s" ] || continue
      s="${s%/}"
      [ -f "$s/SKILL.md" ] || continue
      is_vendor_internal "$s" && continue
      add_skill "$(basename "$s")" "$s"
      found=1
    done
  done

  # Layout 3
  if [ "$found" -eq 0 ] && [ -f "$repo/SKILL.md" ]; then
    add_skill "$(basename "$repo")" "$repo"
    found=1
  fi

  # Layout 4
  if [ "$found" -eq 0 ]; then
    for s in "$repo"/*/; do
      [ -d "$s" ] || continue
      s="${s%/}"
      [ -f "$s/SKILL.md" ] || continue
      is_vendor_internal "$s" && continue
      add_skill "$(basename "$s")" "$s"
      found=1
    done
  fi
done

[ "${#NAMES[@]}" -gt 0 ] || die "no skills found (looked for SKILL.md under $SKILLS_DIR)"

exec_flag() {
  if find "$1" -type f \( -name '*.sh' -o -name '*.py' -o -name '*.js' -o -name '*.ts' \) -print -quit 2>/dev/null | grep -q .; then
    echo "scripts"
  else
    echo "text-only"
  fi
}

if [ "$MODE" = "list" ]; then
  printf '%-34s %-10s %s\n' "SKILL" "CONTENT" "SOURCE"
  for i in "${!NAMES[@]}"; do
    printf '%-34s %-10s %s\n' "${NAMES[$i]}" "$(exec_flag "${PATHS[$i]}")" "${PATHS[$i]#"$SKILLS_DIR"/}"
  done
  echo
  echo "${#NAMES[@]} skill(s). Nothing installed — use --all or --skill NAME."
  echo "Skills marked 'scripts' ship code Claude may execute. Review before enabling."
  exit 0
fi

# --- Verify ---------------------------------------------------------------
# Answers "is what I think is installed actually installed?" — a question no
# amount of reading the docs can answer.
if [ "$MODE" = "verify" ]; then
  echo "Source: $SKILLS_DIR"
  echo "Target: $TARGET_DIR"
  echo
  missing=0; stale=0; ok=0
  for i in "${!NAMES[@]}"; do
    n="${NAMES[$i]}"; src="${PATHS[$i]}"; dest="$TARGET_DIR/$n"
    if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "  MISSING   $n"
      missing=$((missing+1))
    elif [ -L "$dest" ]; then
      cur="$(readlink "$dest")"
      if [ "${cur%/}" = "$src" ]; then
        ok=$((ok+1))
      else
        echo "  STALE     $n -> $cur"
        stale=$((stale+1))
      fi
    else
      echo "  NOT-LINK  $n (a real file/dir is in the way)"
      stale=$((stale+1))
    fi
  done
  orphan=0
  if [ -d "$TARGET_DIR" ]; then
    for dest in "$TARGET_DIR"/*; do
      [ -e "$dest" ] || [ -L "$dest" ] || continue
      bn="$(basename "$dest")"
      known=0
      for n in "${NAMES[@]}"; do [ "$n" = "$bn" ] && { known=1; break; }; done
      if [ "$known" -eq 0 ]; then
        echo "  ORPHAN    $bn (linked, but not in this source tree)"
        orphan=$((orphan+1))
      fi
    done
  fi
  echo
  echo "linked ok: $ok   missing: $missing   stale: $stale   orphan: $orphan"
  echo "source has ${#NAMES[@]} skill(s)."
  [ "$missing" -eq 0 ] && [ "$stale" -eq 0 ] || exit 1
  exit 0
fi

# --- Resolve selection ----------------------------------------------------
INSTALL_IDX=()
if [ "$MODE" = "all" ]; then
  for i in "${!NAMES[@]}"; do INSTALL_IDX+=("$i"); done
elif [ "$MODE" = "select" ]; then
  for want in "${SELECTED[@]}"; do
    found=""
    for i in "${!NAMES[@]}"; do
      if [ "${NAMES[$i]}" = "$want" ]; then INSTALL_IDX+=("$i"); found=1; break; fi
    done
    [ -n "$found" ] || die "no such skill: $want (try --list)"
  done
else
  # dry-run with no explicit selection = preview everything
  if [ "${#SELECTED[@]}" -gt 0 ]; then
    for want in "${SELECTED[@]}"; do
      for i in "${!NAMES[@]}"; do
        [ "${NAMES[$i]}" = "$want" ] && INSTALL_IDX+=("$i")
      done
    done
  else
    for i in "${!NAMES[@]}"; do INSTALL_IDX+=("$i"); done
  fi
fi

# --- Link -----------------------------------------------------------------
link_one() {
  name="$1"; src="$2"; dest="$TARGET_DIR/$name"

  if [ -L "$dest" ]; then
    cur="$(readlink "$dest")"
    if [ "${cur%/}" = "$src" ]; then
      echo "  ok       $name (already linked)"
      return
    fi
    if [ "$MODE" = "dry" ]; then echo "  relink   $name  ($cur -> $src)"; return; fi
    rm -- "$dest"
  elif [ -e "$dest" ]; then
    die "refusing to overwrite non-symlink: $dest
Move or remove it yourself, then re-run."
  fi

  if [ "$MODE" = "dry" ]; then echo "  link     $name -> $src"; return; fi

  # -n: never dereference an existing dir symlink. src has no trailing slash.
  ln -sfn -- "$src" "$dest"
  echo "  linked   $name"
}

if [ "$MODE" = "dry" ]; then
  echo "Dry run — no changes. Target: $TARGET_DIR"
else
  mkdir -p "$TARGET_DIR"
  echo "Linking into $TARGET_DIR"
fi

for i in "${INSTALL_IDX[@]}"; do
  link_one "${NAMES[$i]}" "${PATHS[$i]}"
done

echo
if [ "$MODE" = "dry" ]; then
  echo "Dry run complete. Re-run with --all or --skill NAME to apply."
else
  echo "Done. ${#INSTALL_IDX[@]} skill(s) linked."
  echo "Verify with: $0 --verify"
  echo "Claude Code discovers these automatically (v2.1.203+ required for symlink support)."
fi
