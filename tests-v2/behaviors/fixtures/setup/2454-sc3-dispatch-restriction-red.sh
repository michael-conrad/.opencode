#!/bin/bash
# Per-scenario fixture setup: 2454-sc3-dispatch-restriction-red
# Ensures .issues/2454/plan.md is the MIXED dispatch-mode fixture plan
# (sc1 direct-plan fixture also maps to flat .issues/2454/ during fixture
# injection; this setup overwrites it deterministically so the scenario run
# always executes against the mixed (**direct**)/(**task-card**) plan).
set -euo pipefail
workdir="${1:?usage: setup script <attempt_workdir>}"

src_plan="$(cd "$(dirname "${BASH_SOURCE[0]}")/../issues/2454-sc3-mixed-fixture" && pwd)/plan.md"
src_spec="$(cd "$(dirname "${BASH_SOURCE[0]}")/../issues/2454-sc3-mixed-fixture" && pwd)/spec.md"

mkdir -p "$workdir/.issues/2454"
cp "$src_plan" "$workdir/.issues/2454/plan.md"
cp "$src_spec" "$workdir/.issues/2454/spec.md"
echo "  [setup] 2454-sc3: mixed dispatch-mode plan installed at .issues/2454/plan.md"
