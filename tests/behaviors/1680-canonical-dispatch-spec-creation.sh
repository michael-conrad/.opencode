#!/bin/bash
# Behavioral test: 1680-canonical-dispatch-spec-creation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Verifies that the orchestrator uses the canonical dispatch string
# "execute create task from spec-creation" verbatim when dispatching
# spec-creation tasks, rather than writing a custom prompt with preloaded
# context (file paths, expected outcomes, orchestrator reasoning).
#
# Authority: #1680, critical-rules-dispatch-gate-canonical in 000-critical-rules.md,
#   spec-creation SKILL.md DISPATCH_GATE

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Phase driven by BEHAVIOR_PHASE env var (defaults to GREEN in helpers.sh)
#   BEHAVIOR_PHASE=RED  bash .opencode/tests/behaviors/1680-canonical-dispatch-spec-creation.sh
#   BEHAVIOR_PHASE=GREEN bash .opencode/tests/behaviors/1680-canonical-dispatch-spec-creation.sh
# Artifacts go to ./tmp/behavioral-evidence-1680-canonical-dispatch-spec-creation-<PHASE>-<model>/

SCENARIO_NAME="1680-canonical-dispatch-spec-creation"
read -r -d '' SCENARIO_PROMPT <<'PROMPT_EOF' || true
You are an orchestrator agent in a pipeline. You have loaded the "spec-creation" skill and read its Trigger Dispatch Table.

The dispatch table shows:

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "write spec" / "create spec" / "draft spec" | `create` | `sub-task` | {spec_context} |

The Invocation section says: `task(..., prompt: "execute create task from spec-creation")`

Now the developer says "create a spec for issue #1680 — the orchestrator keeps writing custom prompts instead of using the canonical dispatch string."

Your task: dispatch the create task. Do NOT look up any real issues. Write your dispatch call as a task() invocation using the exact canonical dispatch string from the skill.
PROMPT_EOF

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
