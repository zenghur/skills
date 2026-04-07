#!/bin/bash
# Sync skills from local repository to Claude and/or CodeBuddy skills directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"

# Default targets
CLAUDE_DIR="$HOME/.claude/skills"
CODEBUDDY_DIR="$HOME/.codebuddy/skills"

# Parse arguments
SYNC_CLAUDE=false
SYNC_CODEBUDDY=false

if [ $# -eq 0 ]; then
    # No arguments: sync to both
    SYNC_CLAUDE=true
    SYNC_CODEBUDDY=true
    echo "Syncing to both Claude and CodeBuddy..."
else
    for arg in "$@"; do
        case $arg in
            claude|--claude|-c)
                SYNC_CLAUDE=true
                ;;
            codebuddy|--codebuddy|-b)
                SYNC_CODEBUDDY=true
                ;;
            all|--all|-a)
                SYNC_CLAUDE=true
                SYNC_CODEBUDDY=true
                ;;
            *)
                echo "Unknown argument: $arg"
                echo "Usage: $0 [claude|codebuddy|all]"
                echo "  no args  - sync to both (default)"
                echo "  claude   - sync to ~/.claude/skills only"
                echo "  codebuddy - sync to ~/.codebuddy/skills only"
                echo "  all      - sync to both"
                exit 1
                ;;
        esac
    done
fi

sync_skills() {
    local target_dir="$1"
    local target_name="$2"
    
    echo ""
    echo "=== Syncing to $target_name ==="
    echo "Target: $target_dir"
    echo ""
    
    # Create target directory if not exists
    mkdir -p "$target_dir"
    
    local count=0
    for skill in "$SOURCE_DIR"/*/SKILL.md; do
        if [ -f "$skill" ]; then
            skill_name=$(basename "$(dirname "$skill")")
            source_skill_dir="$SOURCE_DIR/$skill_name"
            target_skill_dir="$target_dir/$skill_name"
            
            # Delete existing skill in target
            rm -rf "$target_skill_dir"
            
            # Copy entire skill directory
            cp -r "$source_skill_dir" "$target_skill_dir"
            echo "✓ Synced $skill_name"
            count=$((count + 1))
        fi
    done
    
    echo ""
    echo "$target_name: Synced $count skill(s)"
}

# Perform sync
if [ "$SYNC_CLAUDE" = true ]; then
    sync_skills "$CLAUDE_DIR" "Claude"
fi

if [ "$SYNC_CODEBUDDY" = true ]; then
    sync_skills "$CODEBUDDY_DIR" "CodeBuddy"
fi

echo ""
echo "Done."
