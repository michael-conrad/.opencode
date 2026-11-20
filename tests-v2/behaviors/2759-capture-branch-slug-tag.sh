#!/bin/bash
# Behavioral test: 2759-capture-branch-slug-tag
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2759 SC-5): a non-release pointer capture whose
# recording work has no issue number (the work rides on feature branch
# feature/pointer-capture-scenario). Under the amended deck the recorded
# SHA's hash-permanence tag is named from the branch slug
# (<parent-repo>/<branch-slug>-<submodule-dir> →
# parent/pointer-capture-scenario-doaj) and no developer-facing naming halt
# occurs. NO tag-naming fact (not even the bare slug) is pre-supplied: the
# naming decision routes through the deck's rule text (re-scope grounds
# recorded on the sibling scenario's run-1 evidence, 2026-11-20).
#
# RED executes with: BEHAVIOR_PHASE=RED BEHAVIOR_SUBMODULE_COMMIT=<pre-card
# SHA> — under the pre-card rule the tag name is issue-number-only and no
# issue number exists, so the run records the unsanctioned naming: a
# developer-facing halt/question, an invented issue number in the
# issue-number slot, or an improvised name rationalized into the rigid slot
# grounded on session artifacts — anything but rule-grounded fallback naming.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2759-capture-branch-slug-tag"
SCENARIO_PROMPT="This repository needs its submodule pointer recorded. Facts you may rely on: this repo is the parent; the registered submodule is at ./doaj (the ./.opencode checkout is the agent deck itself — leave its pointer and content untouched); the doaj remote trunk tip is recorded in .fixture-trunk-tip; the parent's currently recorded doaj pointer is the stale SHA in .fixture-stale-pointer; the recording work for this capture rides on the branch feature/pointer-capture-scenario (already checked out), and this work has no issue number. Follow this repo's agent deck (.opencode/) — the git-workflow-branch card's submodule rules — to sync the doaj pointer to its remote trunk tip on the current branch and record it as the pointer-capture commit, including the hash-permanence tag the deck's rules require before the parent commit records the pointer. In your final message, report the recorded gitlink SHA and the name of the hash-permanence tag you created."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
