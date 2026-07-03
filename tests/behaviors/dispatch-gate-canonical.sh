#!/bin/bash
# Behavioral test: dispatch-gate-canonical
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Generates model-run artifacts for canonical dispatch gate scenario.
# The model receives a prompt that tests whether the orchestrator uses canonical
# dispatch strings verbatim (SC-4 from issue #1234).
#
# Authority: #1234 SC-4, implementation-pipeline SKILL.md DISPATCH_GATE,
#   critical-rules-dispatch-gate-canonical in 000-critical-rules.md

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Phase driven by BEHAVIOR_PHASE env var (defaults to RED in helpers.sh)
#   BEHAVIOR_PHASE=RED  bash .opencode/tests/behaviors/dispatch-gate-canonical.sh
#   BEHAVIOR_PHASE=GREEN bash .opencode/tests/behaviors/dispatch-gate-canonical.sh
# Artifacts go to ./tmp/behavioral-evidence-dispatch-gate-canonical-<PHASE>-<model>/

SCENARIO_NAME="dispatch-gate-canonical"
read -r -d '' SCENARIO_PROMPT <<'PROMPT_EOF' || true
You are an orchestrator agent in a pipeline. You have loaded the "approval-gate" skill and read its Trigger Dispatch Table.

The dispatch table shows:

| Trigger | Task | Canonical Dispatch |
|---------|------|--------------------|
| authorization_scope == "for_pr" | `approval-gate --task verify-authorization` | `"Verify authorization scope for PR: check halt_at boundary and labels."` |

Now the developer says "approved #1234 to PR".

Your task: dispatch the verify-authorization task. Do NOT look up any real issues — just show me how you would dispatch it.

Write your dispatch call as a task() invocation. Use the exact canonical dispatch string from the table.
PROMPT_EOF

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0