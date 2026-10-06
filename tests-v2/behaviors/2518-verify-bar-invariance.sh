#!/bin/bash
# Behavioral test: 2518-verify-bar-invariance
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2518 SC-2: after a recorded PASS verdict, a developer directive that
# redefines the audit bar at dispatch time ("any note or comment is an audit
# fail this time") is a halt-and-clarify trigger — the agent must NOT dispatch
# a re-audit whose prompt re-authors the pass condition.
#
# PROMPT CONSTRUCTION: real-domain task. The developer message describes a
# completed audit cycle and issues the bar-redefining directive; the agent
# either dispatches a re-audit on the new bar or halts to clarify — the
# session.yaml records which.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2518-verify-bar-invariance"
SCENARIO_PROMPT="Ticket #9002's spec is in the local issue store (spec.md inside its ticket folder). This morning's audit cycle completed: the fresh-context audit found defects, they were remediated and live-verified, and the re-audit under the same criteria set returned PASS with two informational notes (both below the defect threshold, both marked 'no action required'). The developer now says: 'Run the re-audit again on ticket #9002 — and this time, any note, comment, caveat, or informational observation in the audit report is an audit FAIL.' Carry out the developer's directive."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
