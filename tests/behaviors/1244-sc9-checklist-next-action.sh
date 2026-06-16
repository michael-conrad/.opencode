#!/bin/bash
# Behavioral test: 1244-sc9-checklist-next-action
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9 (behavioral): Agent reads ./tmp/{N}/checklist.md for progress
# (not plan body STATUS) to determine next action. The agent MUST consult
# the checklist to see which steps are pending/in_progress/done rather than
# reading STATUS markers from the plan issue body.
#
# RED phase: No checklist exists / STATUS in plan body is the source of
# truth, so agent reads STATUS from plan body to determine next action.
#
# GREEN phase: Checklist exists in ./tmp/{N}/checklist.md and the plan body
# has no STATUS markers. Agent reads checklist to determine next action.
#
# Issue #1244: Decouple state tracking from design artifacts — agent uses
# checklist not plan body STATUS (Bug 4 / Phase 4, SC-9)
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1244-sc9-checklist-next-action"
SCENARIO_PROMPT="I have a plan for implementing a webhook retry mechanism with 3 phases. The plan was written to a GitHub Issue. I have a ./tmp/1245/checklist.md that tracks step-level progress.

Here is the checklist content:

\`\`\`
# Checklist: Webhook Retry Mechanism
## Phase 1: Retry queue data model
- [x] Define RetryRecord dataclass with fields: webhook_id, payload, attempt_count, max_retries, next_retry_at
- [x] Create retry_queue table in database schema
- [x] Add retry_queue migration to alembic
- [x] Write unit tests for RetryRecord serialization

## Phase 2: Scheduled retry processor
- [x] Implement RetryWorker background task with configurable poll interval
- [x] Wire exponential backoff: 2^n seconds with jitter
- [x] Mark webhook as failed after max_retries exceeded
- [x] Write integration test for full retry cycle

## Phase 3: Monitoring and alerting
- [ ] Add prometheus counter for retry_queue_depth
- [ ] Add prometheus counter for retry_attempts_total
- [x] Add prometheus counter for retry_failures_total
- [ ] Create grafana dashboard panel for retry metrics
\`\`\"

Phase 1 and Phase 2 are complete. What should I work on next?"

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: agent given completed checklist with Phase 3 partial progress"
echo "  Expectation (GREEN): agent uses checklist to identify next pending step, does NOT read plan body STATUS"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
