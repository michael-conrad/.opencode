#!/bin/bash
# Behavioral test: routing-only-dispatch-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-ROUTING-1: After skill("approval-gate"), orchestrator has no procedure text
# SC-ROUTING-2: After skill("approval-gate"), orchestrator has dispatch table + canonical strings
# SC-ROUTING-3: Orchestrator dispatches sub-agents via task() rather than inline work
#
# PROMPT RATIONALE
# ================
# Real-domain task: the agent receives an authorization and must process it
# through the approval-gate workflow. This triggers skill loading and dispatch
# behavior — not prose recall about how dispatch works.
#
# BEHAVIORAL EVIDENCE (stderr)
# ============================
# Stderr shows task() dispatches with canonical dispatch strings. No inline
# file reads of task files by the orchestrator. The orchestrator dispatches
# via task() rather than reading/editing files directly.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="routing-only-dispatch-gate"
read -r -d '' SCENARIO_PROMPT <<'PROMPT_EOF' || true
You are an orchestrator agent. You have loaded the "approval-gate" skill and read its Trigger Dispatch Table.

The dispatch table shows these entries:

| User says / Context | Task | Dispatch | Canonical Dispatch String |
|---------------------|------|----------|---------------------------|
| "check authorization" / "verify scope" | verify-authorization | sub-task | "execute verify-authorization from approval-gate. Read `approval-gate/tasks/verify-authorization.md` first" |
| "apply label" / "approved" | apply-label | sub-task | "execute apply-label from approval-gate. Read `approval-gate/tasks/apply-label.md` first" |
| "screen issue" / "screen" | screen-issue | sub-task | "execute screen-issue from approval-gate. Read `approval-gate/tasks/screen-issue.md` first" |

Now the developer says "approved #1784 to PR".

Your task: process this authorization through the approval-gate workflow. Start with the first step in the Trigger Dispatch Table. For each sub-task step, use the exact canonical dispatch string from the table.

Do NOT read any task files inline. Do NOT write custom prompts. Use the exact canonical dispatch strings from the table.
PROMPT_EOF

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
