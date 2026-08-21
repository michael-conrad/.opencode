#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2311-sc1-backfill-dependency-contract
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (#2311): `backfill.md` step 4 for `interface-compatibility.yaml` instructs
# the sub-agent to include a `dependency_contract` section (or the research task
# is updated to derive the contract from the existing artifact keys without
# requiring a section that is never produced).
#
# The fixture for issue #2311 injects `.issues/2311/spec.md` into the test repo.
# The spec has success criteria and affected files but NO analytical artifacts —
# it requires retroactive backfill. The prompt is a real-domain backfill task that
# asks the agent to run the writing-plans backfill procedure to generate all 7
# analytical artifacts, including `interface-compatibility.yaml`.
#
# RED STATE: `writing-plans/tasks/backfill.md` step 4 for `interface-compatibility.yaml`
# reads "Check interface boundaries between affected modules" and does NOT instruct
# the sub-agent to include a `dependency_contract` section. So a clean-room sub-agent
# evaluating session.yaml will observe the agent produce an `interface-compatibility.yaml`
# whose `dependency_contract` is at most a placeholder schema template (placeholder
# `"string"` values describing what "should be present after fix") — NOT a real
# populated dependency contract that research.md step 9 could extract into
# dependency-contract.yaml and feed to the solve/plan tools. This SC is RED.
#
# EVALUATION CRITERION (SC-1): the produced `interface-compatibility.yaml` MUST contain
# a `dependency_contract` section populated with CONCRETE dependency data derived from the
# spec's affected files and SCs (real sources, real targets, real type constraints) —
# NOT a placeholder schema template. In the RED state the contract is absent or a
# placeholder template, so the criterion FAILS.
#
# GREEN: backfill.md step 4 instructs the sub-agent to include a `dependency_contract`
# section in the backfilled `interface-compatibility.yaml` (or research.md step 9
# derives the contract from existing keys). The agent produces an
# `interface-compatibility.yaml` that includes a `dependency_contract` section populated
# with concrete dependency data.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the writing-plans backfill task for a retroactive-backfill
# issue to generate the missing analytical artifacts. This is a genuine backfill
# domain task that routes through the writing-plans backfill procedure — NOT a
# prose-recall interview. The prompt does NOT name backfill.md, the
# `dependency_contract` key, or the schema contract, so the agent must execute the
# backfill procedure naturally from the task card.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2311-sc1-backfill-dependency-contract"
SCENARIO_PROMPT="I need to create an implementation plan for issue #2311. The spec in .issues/2311/spec.md was written before the analytical-artifact pipeline existed, so none of the 7 analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) were generated. Please run the writing-plans backfill task to generate all 7 analytical artifacts for this spec, writing each to .issues/2311/artifacts/{name}.yaml, and write the analysis summary. Follow the backfill procedure."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1: backfill produces an interface-compatibility.yaml with a dependency_contract section"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
