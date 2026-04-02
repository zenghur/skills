#!/bin/bash
# Sync skills from local repository to ~/.claude/skills

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"
TARGET_DIR="$HOME/.claude/skills"

echo "Syncing skills from $SOURCE_DIR to $TARGET_DIR"
echo ""

for skill in "$SOURCE_DIR"/*/SKILL.md; do
  if [ -f "$skill" ]; then
    skill_name=$(basename "$(dirname "$skill")")
    source_dir="$SOURCE_DIR/$skill_name"
    target_dir="$TARGET_DIR/$skill_name"

    # Delete existing skill in target
    rm -rf "$target_dir"

    # Copy entire skill directory
    cp -r "$source_dir" "$target_dir"
    echo "✓ Synced $skill_name"
  fi
done

echo ""
echo "Done."
