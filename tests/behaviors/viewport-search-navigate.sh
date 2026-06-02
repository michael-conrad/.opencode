#!/usr/bin/env bash
# viewport-search-navigate.sh — SC-8: Search and navigate workflow
#
# Validates: search:find with scopes, jump-to-text navigation, edit at found location
# Line endings: config.yaml (LF), chapter.md (CRLF), example.py (LF)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

BEHAVIOR="viewport-search-navigate"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers.sh
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_DIR="$(behavior_setup "$BEHAVIOR")"

cat > "$BEHAVIOR_DIR/instruction_card.md" <<'CARD'
# SC-8: Search and Navigate Workflow

You have access to the `viewport-editor` MCP tool with actions: viewport, edit, file, diff, search, regex, clipboard.

**Setup:** Open `fixtures/config.yaml` in a viewport with height 30.

**Task sequence:**
1. Use `viewport` action `open` to open `fixtures/config.yaml` with height 30
2. Use `search` action `find` with pattern `pool` and scope `viewport` to find the connection pool section
3. Use `viewport` action `jump` with target `pool` to navigate to the found line
4. Use `edit` action `replace` to change `max_size: 20` to `max_size: 50` in the pool configuration
5. Use `search` action `find` with pattern `^  \\w+:` and regex `true` to find YAML key lines
6. Use `viewport` action `jump` with target `viewports:` to navigate to the viewports section
7. Use `edit` action `replace` to change `height: 50` to `height: 80` in the viewports defaults
8. Use `diff` action `show` to verify both changes appear in the diff
9. Use `viewport` action `close` to close the viewport

**Success criteria:**
- Both search results return line numbers pointing to the correct sections
- Jump navigates to the target text (not just a line number)
- Both edits are applied and visible in the diff
- The YAML file structure remains valid (correct indentation preserved)
CARD

echo "SC-8 instruction card written to: $BEHAVIOR_DIR/instruction_card.md"
echo "Artifacts: $BEHAVIOR_DIR"