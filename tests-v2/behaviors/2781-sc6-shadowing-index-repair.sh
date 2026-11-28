#!/bin/bash
# Behavioral test: 2781-sc6-shadowing-index-repair
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (.opencode#2781, revised 2026-11-28): an agent under the amended deck,
# presented with a workspace whose store-holding repository's index is
# defective over the `.issues/` store mount (unmerged `.gitignore`; `.issues/`
# paths staged with worktree files absent; no issue store provisioned),
# repairs it on discovery within the same workflow — untracks the staged store
# paths, resolves the conflict, destroys no `.issues/` data — and records the
# disposition, with no developer gate and no report-and-wait halt. Evaluation
# happens in a separate clean-room dispatch against session.yaml plus the
# captured workspace end-state (two-SC pattern).
#
# Re-scope record (.opencode#2665 §3a / R-18 fold-in):
# - attempt 1 (GREEN-ollama-qwen3.8-27b-128k-gguf4): fixture bootstrap created
#   worktree-link side-defects; supervisor §14 signal-4 abort; continue-new-
#   dispatch decision recorded.
# - attempt 2 (resume): worktree links repaired, index conflict never
#   discovered — prompt gave no git-state trigger; clean-room PASS voided by
#   end-state capture.
# - attempt 3 (re-scope: git-state trigger prompt): defect discovered and
#   doctrine-cited, worktree links repaired, but the index repair never
#   executed — recursive read-only recon across 40+ polls; clean-room FAIL.
# - attempt 4 (re-scope: minimal index-only fixture + action-anchored prompt +
#   declared goal artifact): discovery within 4 turns, doctrine-path reading,
#   but the repair still never executed — verdict-confirmed red at poll 26
#   (~45 min). Residual cause: the store-provisioning/divegence surface (the
#   prompt's init/sync step pulls the full remote issues-data = 1829 files)
#   re-opens unbounded analysis before the repair.
# - attempt 5 (this; the spec's SC-6 revised to the focused form): no store
#   provisioning at all — the prompt's task IS the repair and the disposition
#   record. The declared goal artifact is `repair-report.md`.
#
# The fixture (fixtures/setup/2781-sc6-shadowing-index-repair.sh) injects the
# defect class: a conflicted-parent index staging `.issues/` store content
# (worktree-absent blobs) plus an unmerged `.gitignore`.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2781-sc6-shadowing-index-repair"
SCENARIO_PROMPT="This workspace's git state is defective and it should not be — inspect it (git status and the standard checks), then repair per the workspace guide's hygiene mandate and the issues card's store-mount repair doctrine, keeping the .issues store content intact. Finish by writing repair-report.md at the workspace root: the pre-repair state, the repair performed, and the post-repair state (git status and the file checks that show the repair)."

BEHAVIOR_SEMANTIC_MONITOR=1 BEHAVIOR_EXPECTED_ARTIFACT="repair-report.md" \
BEHAVIOR_EXPECTED_ARTIFACT_GREP="repair" BEHAVIOR_GOAL_ACTIONS="shell" \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
