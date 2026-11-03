#!/bin/bash
# Behavioral test: 2707-sc2-triage-multi-spec-boundary
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2707 SC-7 (multi-spec boundary): when a triaged bug report
# warrants multiple specs, the agent converts the original record into the
# FIRST spec and files the further specs as NEW issues linked to the
# converted record — not as detached tickets.
# Bounded: no implementation, no push, no PR.
#
# RE-SCOPE PROVENANCE (.opencode#2665 §3a rule 4): the sibling SC-6
# scenario's runs 1–2 (see 2707-sc1-triage-in-place-spec-conversion.sh)
# showed the run agent exhausting its turn budget on store-mechanics
# deliberation before reaching the disposition; the same prompt re-scope
# applies here — the triage evidence and verdict are pre-staged as verified
# (two independent defects, each warranting its own fix) so the run starts
# at the disposition step; no expected outcome is leaked.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2707-sc2-triage-multi-spec-boundary"
SCENARIO_PROMPT="Ticket #9052 in the local issue store is a bug report awaiting triage — its ticket folder at the root-level store contains report.md. Your triage evidence is already verified: both reported defects reproduce against the live code (README.md links to docs/architecture.md and to docs/onboarding.md, neither of which exists), each defect is independent and warrants its own fix, and the triage verdict is actionable work. Complete the disposition your issue-tracking rules require for this verdict. Do not implement any fix, do not create branches, push, or open pull requests. The remote tracker for this repository is reachable with the gb CLI."

BEHAVIOR_EXPECTED_ARTIFACT=".issues/9052/spec.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="SC-1"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
# RE-SCOPE 2 (same rule): RED attempt 1 (determination
# ...-RED-.../determination.yaml, classification progressing-directionally,
# capped exit after 3 auto-resumes at the 8000 cap) — the run reached deep
# disposition research (~372k reasoning chars) but the disposition phase was
# not reached; legitimate turns routinely exceed 8000 tokens. Runs under
# OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=16000.
