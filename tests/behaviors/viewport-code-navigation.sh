#!/usr/bin/env bash
# viewport-code-navigation.sh — SC-9: Code and config navigation
#
# Validates: jump to function/class definitions, regex pattern search, 
#            search-in-viewport scope, edit within function body
# Line endings: example.py (LF — code navigation with def/class targets)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

BEHAVIOR="viewport-code-navigation"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers.sh
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_DIR="$(behavior_setup "$BEHAVIOR")"

cat > "$BEHAVIOR_DIR/instruction_card.md" <<'CARD'
# SC-9: Code and Config Navigation

You have access to the `viewport-editor` MCP tool with actions: viewport, edit, file, diff, search, regex, clipboard.

**Setup:** Open `fixtures/example.py` in a viewport with height 30.

**Task sequence:**
1. Use `viewport` action `open` to open `fixtures/example.py` with height 30
2. Use `viewport` action `jump` with target `def apply_edit` to navigate to the apply_edit function
3. Use `search` action `find` with pattern `class ` and scope `viewport` to find all class definitions
4. Use `viewport` action `jump` with target `class SessionManager` to navigate to SessionManager class
5. Use `regex` action `test` with pattern `def \\w+\\(` and text `def apply_edit` to verify the regex matches function definitions
6. Use `regex` action `escape` with pattern `file.txt` to get the escaped version
7. Use `edit` action `replace` to change `max_sessions: int = 10` to `max_sessions: int = 25` in SessionManager.__init__
8. Use `edit` action `replace` to change `"session {session_id} already exists"` to `"session {session_id} already exists — duplicate rejected"` in the same class
9. Use `viewport` action `jump` with target `VERSION` to navigate to the module-level constant
10. Use `edit` action `replace` to change `VERSION = "0.1.0"` to `VERSION = "0.2.0"`
11. Use `diff` action `show` to verify all three changes appear in the diff
12. Use `file` action `save` to write changes to disk
13. Use `viewport` action `close` to close the viewport

**Success criteria:**
- `jump` with `def apply_edit` navigates to the function definition line
- `jump` with `class SessionManager` navigates to the class definition line
- `jump` with `VERSION` navigates to the module-level constant
- Search returns correct line numbers for class definitions
- Regex test confirms pattern matches function definitions
- All three edits appear in the diff output
- Saved file on disk has all three edits applied
CARD

echo "SC-9 instruction card written to: $BEHAVIOR_DIR/instruction_card.md"
echo "Artifacts: $BEHAVIOR_DIR"