#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: record-authorization-workflow
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: record-authorization task updates spec.md frontmatter with status: approved
# SC-3: record-authorization task appends authorization record to comments.yaml
# SC-4: record-authorization task updates issue.yaml with approved-for-{scope} label
# SC-5: record-authorization task commits .issues/ worktree changes after writing
# SC-9: verify-recording task checks all three files and returns BLOCKED if any missing
#
# PROMPT CONSTRUCTION:
# Real-domain task: verify authorization for an issue, which triggers the
# fast-path workflow (scope-auto-resolve -> record-authorization -> verify-recording -> apply-label -> auto-dispatch)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="record-authorization-workflow"
SCENARIO_PROMPT="Verify authorization for issue #2141. The developer said 'approved for implementation' in chat. Run the verify-authorization fast-path workflow."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
