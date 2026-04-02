#!/bin/bash
# Sync skills from local repository to ~/.claude/skills

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"
TARGET_DIR="$HOME/.claude/skills"

echo "Syncing skills from $SOURCE_DIR to $TARGET_DIR"
echo ""

# Delete existing skills in target
rm -rf "$TARGET_DIR"/*/SKILL.md

for skill in "$SOURCE_DIR"/*/SKILL.md; do
  if [ -f "$skill" ]; then
    skill_name=$(basename "$(dirname "$skill")")
    target_dir="$TARGET_DIR/$skill_name"
    target="$target_dir/SKILL.md"

    mkdir -p "$target_dir"
    cp "$skill" "$target"
    echo "✓ Synced $skill_name"
  fi
done

echo ""
echo "Done."
