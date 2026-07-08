#!/bin/bash
# Behavioral test: sc9-audit-touchpoint-issue-operations
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Agent invokes audit during issue operations — the issue-operations
#       pipeline dispatches an audit sub-agent to verify sub-issue structure
#       and completeness before persisting.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc9-audit-touchpoint-issue-operations"

# Create a temporary plan file for the prompt to reference
TMP_PLAN=$(mktemp /tmp/test-plan-sc9-XXXXXX.md)
cat > "$TMP_PLAN" << 'PLANEOF'
# Implementation Plan: Add dark mode support

## Phase 1: Theme infrastructure
- Add CSS custom properties for dark/light themes
- Create ThemeContext provider component
- Add localStorage persistence

## Phase 2: UI components
- Add theme toggle button to header
- Update all component styles to use CSS variables
- Add transition animations

## Phase 3: Testing
- Add unit tests for theme toggle
- Add integration tests for persistence
- Add visual regression tests for dark mode
PLANEOF

SCENARIO_PROMPT="Create sub-issues for the approved plan at $TMP_PLAN. Each phase should become a sub-issue with appropriate labels. After creating the sub-issues, run an audit to verify the sub-issue structure is complete and correctly linked."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_PLAN"
exit 0
