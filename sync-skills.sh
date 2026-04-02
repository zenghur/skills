#!/bin/bash
# Sync skills from ~/.claude/skills to local repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$HOME/.claude/skills"
TARGET_DIR="$SCRIPT_DIR"

echo "Syncing skills from $SOURCE_DIR to $TARGET_DIR"
echo ""

for skill in "$SOURCE_DIR"/*/SKILL.md; do
  if [ -f "$skill" ]; then
    skill_name=$(basename "$(dirname "$skill")")
    target="$TARGET_DIR/$skill_name/SKILL.md"

    if [ -f "$target" ]; then
      cp "$skill" "$target"
      echo "✓ Synced $skill_name"
    else
      echo "⚠ Skipped $skill_name (not found in target)"
    fi
  fi
done

echo ""
echo "Done."
