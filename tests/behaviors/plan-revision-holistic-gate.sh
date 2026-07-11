#!/bin/bash
# Behavioral test: plan-revision-holistic-gate
# SC-16: Plan revision hard-fails with escalation when revised spec fails holistic gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers plan revision after a spec update that introduces
# holistic gate defects. The revision should hard-fail with escalation listing
# the failed dimensions.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-revision-holistic-gate"
SCENARIO_PROMPT="Revise the implementation plan for this updated spec. The original spec was clean. The revised spec now says: 'The system MUST cache results. Design Options: (A) Redis, (B) Memcached, (C) In-memory HashMap, (D) Database query cache — pick one during implementation. SC-1: Cache must be fast. Use best judgment for eviction policy.' The existing plan has 3 phases for Redis-based caching. Update the plan to match the revised spec."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
