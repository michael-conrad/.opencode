#!/bin/bash
# Behavioral test: sc8-audit-touchpoint-writing-plans
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Agent invokes audit during plan creation — the writing-plans pipeline
#       dispatches an audit sub-agent to verify plan fidelity against the spec
#       before persisting the plan.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc8-audit-touchpoint-writing-plans"

# Create a temporary spec file for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc8-XXXXXX.md)
cat > "$TMP_SPEC" << 'SPECEOF'
# Spec: Add dark mode support

## Problem
The application only supports light mode, causing eye strain for users in low-light environments.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Theme toggle button appears in the header | behavioral | pytest test_theme_toggle_exists |
| SC-2 | Toggling theme switches CSS class on `<body>` | behavioral | pytest test_theme_class_switches |
| SC-3 | Dark mode persists across page reloads | behavioral | pytest test_theme_persists_localstorage |
| SC-4 | All components render correctly in dark mode | behavioral | playwright test_dark_mode_components |

## Implementation Notes
- Add `data-theme` attribute to `<body>` element
- Store preference in localStorage under key `theme`
- Default to system preference via `prefers-color-scheme`
- Update all component CSS to use CSS custom properties
SPECEOF

SCENARIO_PROMPT="Create an implementation plan from the approved spec at $TMP_SPEC. The plan should break the work into phases with clear dependencies. After writing the plan, run an audit to verify the plan is faithful to the spec."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
exit 0
