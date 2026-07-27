#!/bin/bash
# Behavioral test: verify-auth-step5d
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Step 5d readiness checks in verify-authorization chain
#
# SC-9: Agent approves an already-completed issue (merged PR exists) → agent auto-closes
#        instead of proceeding to implementation
# SC-10: Agent approves a stale spec (superseded by later issue) → agent halts with
#        superseding report
# SC-11: Agent approves an issue with blocking dependencies → agent halts with blocker
#        report
#
# Issue #1187: Restore pre-implementation readiness checks to verify-authorization chain
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# ============================================================
# SC-9: Already-completed issue → auto-close
# ============================================================
SCENARIO_9="verify-auth-step5d-sc9"
PROMPT_9="approved #999 for implementation — the spec for adding a 'version' field to config schema. The issue has label 'spec' and a merged PR #42 already implements it."

echo "=== SC-9: Already-completed issue → auto-close ==="
behavior_run "$SCENARIO_9" "$PROMPT_9"

# ============================================================
# SC-10: Stale spec → halt with superseding report
# ============================================================
SCENARIO_10="verify-auth-step5d-sc10"
PROMPT_10="approved #999 for implementation — the spec for adding a 'version' field to config schema. Issue #1001 is a later spec that supersedes #999 with a different approach."

echo "=== SC-10: Stale spec → halt with superseding report ==="
behavior_run "$SCENARIO_10" "$PROMPT_10"

# ============================================================
# SC-11: Blocking dependencies → halt with blocker report
# ============================================================
SCENARIO_11="verify-auth-step5d-sc11"
PROMPT_11="approved #999 for implementation — the spec for adding a 'version' field to config schema. Issue #1002 is a blocking dependency that is still open."

echo "=== SC-11: Blocking dependencies → halt with blocker report ==="
behavior_run "$SCENARIO_11" "$PROMPT_11"

exit 0
