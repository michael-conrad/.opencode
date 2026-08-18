#!/bin/bash
# Behavioral test: 2293-sc1-remove-global-prohibition
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: The submodule-only-PR prohibition SHALL be removed from the global guideline
# 020-go-prohibitions.md (the critical-rules-049 block). A submodule repo filing its
# own PR for its own changes SHALL be permitted.
#
# RED STATE: the critical-rules-049 block is still present in
# guidelines/020-go-prohibitions.md with global "NEVER create a submodule-only PR in
# ANY context, for ANY reason" wording. An agent reading this guideline concludes a
# submodule repo may NOT file its own PR — the opposite of the SC-1 target behavior.
# This run's session.yaml therefore shows the agent blocking the submodule repo's own
# PR, so the SC-1 criterion is NOT satisfied and the SC FAILS (RED).
#
# GREEN STATE: the critical-rules-049 block is removed from the global guideline. An
# agent reading the surviving guidance concludes a submodule repo MAY file its own PR
# for its own changes. This run's session.yaml then shows the agent permitting the PR,
# satisfying the SC-1 criterion and the SC PASSES (GREEN).
#
# PROMPT CONSTRUCTION:
# Real-domain task: resolve whether a submodule repo may file its own PR for its own
# changes, in a repo that carries the .opencode submodule and the global prohibition.
# This triggers natural agent behavior — reading the loaded guideline and task cards
# to reach a decision — NOT a prose-recall interview about what the agent would do.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2293-sc1-remove-global-prohibition"
SCENARIO_PROMPT="This repository's .opencode directory is a git submodule (see .gitmodules). The .opencode repo needs to file its own pull request for its own change (a fix to one of its task cards). Is the .opencode submodule repo permitted to file its own PR for its own changes, or does the submodule-only-PR prohibition in the loaded guidelines apply here? Consult the loaded guidelines and task cards to decide, then state whether the .opencode repo may proceed with its own PR."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
