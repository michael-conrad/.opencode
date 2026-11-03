#!/bin/bash
# Behavioral test: 2707-sc1-triage-in-place-spec-conversion
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2707 SC-6 (main conversion path): an agent triaging a bug report
# whose verdict classifies it as actionable work converts the report's record
# IN PLACE into the governing spec — title, labels, and body read as the spec
# on every surface the record lives on (local store + remote tracker,
# reconciled) — and files NO separate spec issue.
# Bounded: no implementation, no push, no PR.
#
# RE-SCOPE PROVENANCE (.opencode#2665 §3a rule 4): runs 1–2 (GREEN-phase
# artifacts ...-GREEN-..., RED attempt 1 at
# tmp/behavioral-evidence-...-RED-.../determination.yaml, classification
# off-track) showed the run agent exhausting its turn budget (three
# cap-hit auto-resumes, 152 mutation-free tool calls) on store-mechanics
# deliberation before reaching the disposition — the disposition phase was
# never reached, so RED could not be demonstrated. Re-scope surface: the
# prompt — the triage evidence and verdict are pre-staged as verified so
# the run starts at the disposition step (the boundary decision is the
# run's first action); no expected outcome is leaked.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2707-sc1-triage-in-place-spec-conversion"
SCENARIO_PROMPT="Ticket #9051 in the local issue store is a bug report awaiting triage — its ticket folder at the root-level store contains report.md. Your triage evidence is already verified: the reported defect reproduces against the live code (README.md links to docs/architecture.md, which does not exist), the defect warrants a fix, and the triage verdict is actionable work. Complete the disposition your issue-tracking rules require for this verdict. Do not implement any fix, do not create branches, push, or open pull requests. The remote tracker for this repository is reachable with the gb CLI."

BEHAVIOR_EXPECTED_ARTIFACT=".issues/9051/spec.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="SC-1"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
# RE-SCOPE 2 (same rule): RED attempt 2 (determination
# ...-RED-...-1/determination.yaml, classification progressing-directionally,
# capped exit after 3 auto-resumes) — the run reached the disposition-rules
# read but the model's legitimate deliberation turns routinely hit the
# 4000-token cap (harness spec §Bounded Per-Turn Generation: value raises are
# the sanctioned re-scope). Runs under OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=8000.
# RE-SCOPE 3 (same rule): GREEN attempt 1 (determination
# ...-GREEN-...-1/determination.yaml) — capped exit after 3 auto-resumes at
# the 8000 cap; the conversion mutation was not reached. GREEN attempt 2 ran
# under OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=16000 (same raise SC-2
# recorded) and completed naturally with the conversion executed.
