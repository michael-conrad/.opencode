#!/bin/bash
# Behavioral test: 1385-sc1-sem-auditor-evaluates-sc-sems
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-1 through SC-6, SC-8: spec-audit auditor evaluates SC-SEM criteria against
# a fixture SKILL.md with a bad description.
# Fixture: fixtures/issues/1385/spec.md (SKILL.md with vague description,
# misaligned dispatch table, optional language, sub-item type violations)
# Behavioral evidence: stderr shows the auditor reading the spec and
# producing structured findings with criteria_id, severity, pass/fail.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc1-sem-auditor-evaluates-sc-sems"
SCENARIO_PROMPT="audit_phase: spec_creation spec_issue_number: 1385 spec_local_dir: fixtures/issues/1385/"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
