#!/usr/bin/env bash
# MasterVault installer — links skills from skills/ into ~/.claude/skills/
#
# Safe to re-run: replaces only symlinks it can verify, never writes inside
# the vendored source tree, and refuses to clobber real files or directories.
#
# Usage:
#   ./install.sh --list                  # show what's available, install nothing
#   ./install.sh --dry-run               # show what WOULD be linked
#   ./install.sh --all                   # link every skill
#   ./install.sh --skill NAME [--skill NAME ...]
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
  sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --list)    MODE="list"; shift ;;
    --dry-run) MODE="dry"; shift ;;
    --all)     MODE="all"; shift ;;
    --skill)   [ $# -ge 2 ] || die "--skill needs a NAME"
               [ -z "$MODE" ] && MODE="select"; SELECTED+=("$2"); shift 2 ;;
    -h|--help) usage 0 ;;
    *)         die "unknown option: $1 (try --help)" ;;
  esac
done

[ -n "$MODE" ] || { echo "Nothing selected. This installer does not install by default."; echo; usage 1; }
[ -d "$SKILLS_DIR" ] || die "no skills/ directory at $SKILLS_DIR"

# --- Discover -------------------------------------------------------------
# A skill is a directory containing SKILL.md, at skills/<repo>/ or
# nested at skills/<repo>/skills/<name>/.

NAMES=()
PATHS=()

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
  if [ -d "$repo/skills" ]; then
    for s in "$repo"/skills/*/; do
      [ -d "$s" ] || continue
      s="${s%/}"
      [ -f "$s/SKILL.md" ] || continue
      add_skill "$(basename "$s")" "$s"
    done
  elif [ -f "$repo/SKILL.md" ]; then
    add_skill "$(basename "$repo")" "$repo"
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
    printf '%-34s %-10s %s\n' "${NAMES[$i]}" "$(exec_flag "${PATHS[$i]}")" "${PATHS[$i]#"$REPO_DIR"/}"
  done
  echo
  echo "${#NAMES[@]} skill(s). Nothing installed — use --all or --skill NAME."
  echo "Skills marked 'scripts' ship code Claude may execute. Review before enabling."
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
  echo "Claude Code discovers these automatically (v2.1.203+ required for symlink support)."
fi
