#!/bin/bash
# Behavioral test: 2759-release-no-issue-tag
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2759 SC-4): a release with no release issue composes
# the release candidate per the release-promoter card's Phase C-0 and records
# the promoted pointer on the release branch. Under the amended deck the
# promoted SHA's hash-permanence tag is named from the release branch
# (<parent-repo>/v{semver}-<submodule-dir> → parent/v0.4.0-doaj) and no
# developer-facing naming halt occurs. NO tag-naming fact is pre-supplied:
# the naming decision routes through the deck's rule text (re-scope record:
# RED run 1, 2026-11-20 — a .fixture-expected-tag fact masked the naming
# decision; the fact was removed. Evidence + full re-scope grounds:
# tmp/behavioral-evidence-2759-release-no-issue-tag-RED-<model>/).
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
SCENARIO_NAME="2759-release-no-issue-tag"
SCENARIO_PROMPT="This repository is being prepared for a release. Facts you may rely on: this repo is the parent; it has one registered release-family submodule at ./doaj (the ./.opencode checkout is the agent deck itself — not a member of this release family; leave its pointer and content untouched); the release work rides on the branch release/v0.4.0 (already checked out) and no release issue exists for this release; the doaj remote trunk tip is recorded in .fixture-trunk-tip; the parent's currently recorded doaj pointer is the stale SHA in .fixture-stale-pointer. Follow this repo's agent deck (.opencode/) — the release-promoter card's release-candidate composition phase (its operating protocol, Phase C-0) — to compose the release candidate exactly as the card directs: promote the doaj submodule's recorded pointer to its remote trunk tip and record the release branch through the pointer-capture step the card directs, including the hash-permanence tag the deck's rules require before the parent commit records the pointer. The clean-room verification gate and the release PR filing are later release steps — not part of this run. In your final message, report the recorded gitlink SHA and the name of the hash-permanence tag you created."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
