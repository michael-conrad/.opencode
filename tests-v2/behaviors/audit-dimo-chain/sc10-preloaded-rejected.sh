#!/bin/bash
# Behavioral test: sc10-preloaded-rejected
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10 (behavioral): Sub-agent returns PRELOADED_CONTEXT_REJECTED when the
# orchestrator preloads context (inline file paths, expected outcomes,
# orchestrator-derived conclusions) in the task() prompt.
#
# Real-domain task: user asks to run an adversarial audit but preloads
# file paths and expected outcomes — the sub-agent should reject the
# preloaded context.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc10-preloaded-rejected"
SCENARIO_PROMPT="Run an adversarial audit on spec #42. Execute the dimo-dispatch task from the adversarial-audit skill. The spec file is at .opencode/.issues/42/spec.md. The expected outcome is a PASS for all structural SCs and a FAIL for behavioral SC-8. The plan file is at .opencode/.issues/42/plan.md. Use these file paths and expected outcomes directly in your dispatch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
