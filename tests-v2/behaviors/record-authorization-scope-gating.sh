#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: record-authorization-scope-gating
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: record-authorization task updates spec.md frontmatter with status: approved
# when scope is for_implementation or higher, and does NOT set it for scopes below
# for_implementation.
#
# PROMPT CONSTRUCTION:
# Real-domain task: verify authorization for an issue with for_implementation scope,
# which triggers the fast-path workflow (scope-auto-resolve -> record-authorization ->
# verify-recording -> apply-label -> auto-dispatch). The agent must dispatch
# record-authorization which should set status: approved in spec.md frontmatter.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="record-authorization-scope-gating"
SCENARIO_PROMPT="Verify authorization for issue #2141. The developer said 'approved for implementation' in chat. Run the verify-authorization fast-path workflow."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  SC-2: record-authorization scope gating (for_implementation -> status: approved)"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
