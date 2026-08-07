#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc21-resolve-scope-chat-only
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-21: `approval-gate/tasks/resolve-scope.md` SHALL parse authorization from the
# chat message only (verb-prefix table), not from issue comments.
#
# The agent is given a real-domain authorization task that triggers the
# approval-gate resolve-scope path: approve issue #2241 for implementation. The
# fixture setup script seeds a CONFLICTING authorization comment on issue #2241
# that grants `for_plan`. SC-21 requires the agent to parse the authorization
# scope from the CHAT MESSAGE only (the `for_implementation` phrase), ignoring the
# conflicting `for_plan` comment. The session.yaml (SQLite DB export) is the
# PRIMARY evidence source.
#
# RED STATE: resolve-scope.md Purpose currently says "Parse authorization text
# (issue comments, user messages)" — it parses authorization from issue comments
# as a source. A clean-room sub-agent evaluating session.yaml will observe the
# agent reads the issue comments (via `local-issues read-comments` or the remote
# API) and resolves `for_plan` from the conflicting comment instead of parsing
# `for_implementation` from the chat message — so this SC FAILS.
#
# PROMPT CONSTRUCTION:
# Real-domain task: approve issue #2241 for implementation and resolve the
# authorization scope. This triggers the fast-path authorization workflow
# (resolve-scope). The chat message carries the `for_implementation` phrase; the
# fixture seeds a conflicting `for_plan` comment. Natural behavior, NOT a
# prose-recall interview. The prompt does NOT name resolve-scope.md, comments.yaml,
# or the verb-prefix table.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc21-resolve-scope-chat-only"
SCENARIO_PROMPT="Approve issue #2241 for implementation. Verify the authorization for issue #2241 and resolve the authorization scope and halt point, then record the resolved scope as the canonical authorization state in the issue's persistent local record."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-21: resolve-scope parses authorization from the chat message only, not from issue comments"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
