#!/bin/bash
# Behavioral test: plan-dispatch-modes
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests/AGENTS.md §9 Prompt Construction Mandate for the full specification.
#
# Covers SC-6 through SC-10 from spec #1844 (Plan Phase Dispatch Modes).
# Each SC gets its own behavior_run call producing independent artifacts.
# RED phase: tests should FAIL because implementation changes don't exist yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-6: Plan auditor catches dispatch marking defects
# Prompt: ask agent to audit a plan that has dispatch defects
SCENARIO_NAME="1844-sc6-auditor-catches-dispatch-defects"
SCENARIO_PROMPT="Audit the plan at .opencode/.issues/1844/plan.md for dispatch marking defects. The plan has a phase with Dispatch: inline but all steps are marked (**sub-agent**). Report whether the plan auditor catches: (1) missing Dispatch declaration, (2) inline phase with only sub-agent steps, (3) sub-agent-clean-room phase with (**inline**) steps."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-7: Orchestrator correctly routes inline phases
# Prompt: ask agent to execute an inline phase plan
SCENARIO_NAME="1844-sc7-orchestrator-routes-inline-phases"
SCENARIO_PROMPT="Execute Phase 1 from the plan at .opencode/.issues/1844/plan.md. The phase has Dispatch: inline. Execute the (**inline**) steps directly and dispatch the (**sub-agent**) steps via task(). Show the routing decisions in stderr."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-8: Backward compatibility (existing plans without Dispatch column still work)
# Prompt: ask agent to execute a plan without Dispatch column
SCENARIO_NAME="1844-sc8-backward-compatibility"
SCENARIO_PROMPT="Execute the plan at .opencode/.issues/1844/plan.md but ignore the Dispatch column. Treat the plan as if it has no Dispatch column at all. Dispatch the entire phase to a sub-agent as before (default to sub-agent-with-context)."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-9: RED state before implementation
# Prompt: ask agent to write behavioral tests before implementation
SCENARIO_NAME="1844-sc9-red-state-before-implementation"
SCENARIO_PROMPT="Write behavioral enforcement tests for spec #1844 (Plan Phase Dispatch Modes) at .opencode/tests/behaviors/plan-dispatch-modes.sh. The tests must verify SC-6 (auditor catches dispatch defects), SC-7 (orchestrator routes inline phases), SC-8 (backward compatibility), SC-9 (RED state), and SC-10 (no SC weakening). Run the tests and confirm they FAIL (RED) because the implementation changes don't exist yet."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-10: No SC weakening
# Prompt: ask agent to cross-reference SC evidence types
SCENARIO_NAME="1844-sc10-no-sc-weakening"
SCENARIO_PROMPT="Cross-reference the SC evidence types in spec #1844 (.opencode/.issues/1844/spec.md) against the implementation evidence. Verify that no SC has been weakened, deferred, or reclassified to a lower evidence type. Report any downgrades found."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
