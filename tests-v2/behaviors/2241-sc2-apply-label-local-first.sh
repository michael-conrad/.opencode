#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc2-apply-label-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: `approval-gate/tasks/apply-label.md` SHALL write `approved-for-{scope}`
# to local `{issues_prefix}/{N}/issue.yaml` as canonical source (via
# `local-issues update --labels`); remote write SHALL be best-effort/secondary only.
#
# Fixture issue #2241 has `needs-approval` in its local issue.yaml labels array
# and no approved-for-* label. The agent is given a real-domain authorization task
# that triggers the apply-label path: apply `approved-for-implementation` to the
# issue. SC-2 requires the canonical record to land in the local issue.yaml labels
# array (via `local-issues update --labels`). The session.yaml (SQLite DB export) is
# the PRIMARY evidence source.
#
# RED STATE: apply-label.md currently writes the label to the remote as canonical.
# A clean-room sub-agent evaluating session.yaml will observe the agent does NOT
# write `approved-for-implementation` into the local issue.yaml — so this SC FAILS.
#
# PROMPT CONSTRUCTION:
# Real-domain task: approve issue #2241 for implementation and record the
# authorization label as the canonical persistent state. This triggers the
# fast-path authorization workflow (resolve-scope -> apply-label). Natural behavior,
# NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc2-apply-label-local-first"
SCENARIO_PROMPT="Approve issue #2241 for implementation. Apply the approved-for-implementation label and record it as the canonical authorization state in the issue's persistent local record."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-2: apply-label writes approved-for-{scope} to local issue.yaml as canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
