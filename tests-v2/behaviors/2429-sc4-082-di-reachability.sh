#!/bin/bash
# Behavioral test: 2429-sc4-082-di-reachability
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (#2429): 080 split — DI-reachability check against the Tier-2 destination.
# The scenario asks the agent to determine the mandated dependency-injection
# approach for a Python service by reading the guideline that governs it
# (the 080 core pointer → 082-python-standards.md §Dependency Injection).
#
# RED condition (pre-GREEN): destination 082 does not exist; the agent cannot
#   reach the DI mandate through the new home.
# GREEN condition: the agent follows the 080-core Read [Text](path) pointer to
#   082 and reports the mandated approach (`dependency-injector`, container-first
#   wiring) — the moved rule is reachable through the pointer chain.
#
# Evaluation: session.yaml (PRIMARY evidence source) — orchestrator evaluates;
# this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: a DI-routing question per plan item 4 verify step
# ("run the 2243-sc1-style DI scenario with the prompt re-pointed to the 082
# destination") — NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2429-sc4-082-di-reachability"
SCENARIO_PROMPT="A Python service class WordCountService must be added to this project to report word-count statistics. The service depends on a Config object (loads thresholds) and a Secrets object (loads API credentials). Read the project's coding standards at .opencode/guidelines/080-code-standards.md, follow its pointer to the guideline file that governs Python-specific standards, and determine the mandated dependency injection approach. Then describe exactly how the Config and Secrets dependencies must be wired into the service using that mandated approach, so the service is easy to test and refactor. Also state which dependency-injection carve-outs, if any, apply to .opencode/ infrastructure tooling. Do not create or modify any files — just read the standards and describe the required DI wiring."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0