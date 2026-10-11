#!/bin/bash
# Behavioral test: 2567-sc5-visual-design-unpinned-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Real-domain design-generation task: the run agent must dispatch the
# visual-design-agent subagent (which pins no model — it inherits the invoking
# session's provider/model) and the dispatch must complete with the pinned
# options accepted by the provider.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2567-sc5-visual-design-unpinned-dispatch"
SCENARIO_PROMPT="Dispatch the visual-design-agent subagent to produce a single-file HTML/CSS landing-page mockup for a fictional coffee roastery named Ember & Oak. The page needs a hero section with the roastery name and tagline, three product cards (light, medium, dark roast) with prices, and a footer with contact info. Save the finished artifact to landing-page.html in the project root. Report which subagent handled the work and what model it ran on."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
