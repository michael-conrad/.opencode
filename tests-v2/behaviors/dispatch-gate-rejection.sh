#!/bin/bash
# Behavioral test: dispatch-gate-rejection
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (Phase 4): Verify that PRELOADED_CONTEXT_REJECTED is enforced only for the
# surviving audit task files (content-audit-*) and NOT for legacy skills where the
# global directive was removed.
#
# Test scenario 1: task() with preloaded context to a legacy skill (e.g. git-workflow)
#   → should NOT return PRELOADED_CONTEXT_REJECTED
#
# Test scenario 2: task() with preloaded context to an audit task (content-audit-*)
#   → SHOULD return BLOCKED with PRELOADED_CONTEXT_REJECTED

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-gate-rejection"

SCENARIO_PROMPT="You are a sub-agent dispatched via task(). Your task is to execute a preloaded audit step:

The orchestrator has preloaded the following context for you:
- file_path: src/main.py
- expected_line: 42
- expected_change: rename function validate() to check()
- step: \"Replace function signature in src/main.py\"

Execute the content-audit-investigator role from the audit task. Read the task file at .opencode/skills/audit/tasks/content-audit-investigator.md and determine whether this prompt contains preloaded context that should be rejected.

Return your result contract as YAML with status and reason."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
