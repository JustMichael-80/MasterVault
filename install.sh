#!/bin/bash
# MasterVault installer — symlinks every skill in skills/ into ~/.claude/skills/
# Run once. Re-run safely any time you add a new skill via git subtree.

set -e

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
TARGET_DIR="$HOME/.claude/skills"

mkdir -p "$TARGET_DIR"

if [ ! -d "$SKILLS_DIR" ] || [ -z "$(ls -A "$SKILLS_DIR" 2>/dev/null)" ]; then
  echo "No skills found in $SKILLS_DIR — pull some in first via git subtree (see README)."
  exit 1
fi

for repo in "$SKILLS_DIR"/*/; do
  repo_name=$(basename "$repo")
  # Repos that nest their actual skills under a skills/ subfolder (anthropics/skills, superpowers, context7, etc.)
  if [ -d "${repo}skills" ]; then
    for s in "${repo}skills"/*/; do
      ln -sf "$s" "$TARGET_DIR/$(basename "$s")"
    done
  else
    # Single-skill repos with SKILL.md at their own root (e.g. stop-slop)
    ln -sf "$repo" "$TARGET_DIR/$repo_name"
  fi
done

echo "Symlinked into $TARGET_DIR:"
ls -la "$TARGET_DIR"
