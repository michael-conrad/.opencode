#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2413-sc3-research-dependency-contract
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (#2413): research.md step 9 auto-backfills `dependency_contract` from
# existing `interfaces`, `removed_interfaces`, and `breaking_changes` keys when
# `interface-compatibility.yaml` lacks a `dependency_contract` section.
#
# RED STATE: research.md step 9 hard-blocks with `DEPENDENCY_CONTRACT_NOT_FOUND`
# when `interface-compatibility.yaml` has no `dependency_contract` section.
# The agent reports BLOCKED and halts.
#
# GREEN STATE: research.md step 9 detects the missing `dependency_contract`
# section and auto-backfills it from existing keys. The agent generates the
# dependency-contract.yaml from the backfilled data and proceeds with solve/plan.
#
# PROMPT CONSTRUCTION:
# Real-domain task: generate the dependency contract for issue #2413's spec by
# running the writing-plans research task. The analytical artifacts (including
# interface-compatibility.yaml without dependency_contract) exist in the fixtures.
# The agent must run the research procedure — not describe it.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2413-sc3-research-dependency-contract"
SCENARIO_PROMPT="I need to generate the dependency contract for issue #2413 from the writing-plans research task. The analytical artifacts have already been generated — find them in .issues/2413/artifacts/ and run the research procedure to produce the dependency-contract.yaml at .issues/2413/dependency-contract.yaml. Use the interface-compatibility.yaml from artifacts to generate the contract."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3: research.md step 9 auto-backfills dependency_contract when section is missing"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
