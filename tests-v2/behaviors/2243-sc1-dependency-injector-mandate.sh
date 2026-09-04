#!/bin/bash
# Behavioral test: 2243-sc1-dependency-injector-mandate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (behavioral): A "Dependency Injection" section SHALL be added to
# `.opencode/guidelines/082-python-standards.md` (reached via the 080 core pointer, #2429 SC-8 sweep) covering what DI is, why it is
# required, the mandated library (`dependency-injector`), usage patterns, and
# the carveout for `.opencode/` infrastructure tools.
#
# RED phase: The DI mandate does NOT yet exist in 082-python-standards.md. When the
# agent is asked to write a real-domain Python service with injectable
# dependencies, it must NOT dispatch to / follow a DI mandate — it will fall back
# to manual parameter-passing or arbitrary wiring. This is the RED condition.
#
# GREEN phase: After the DI section is added to 082-python-standards.md, the agent
# writing the same Python service must follow the DI mandate — dispatching to
# `dependency-injector`, structuring wiring through an Injector container, and
# honoring the `.opencode/` carveout.
#
# The prompt is a real-domain task (implement a Python service), NOT a
# prose-recall interview. See .opencode/tests-v2/AGENTS.md §9 Prompt Construction
# Mandate. The session.yaml (SQLite DB export) is the PRIMARY evidence source —
# a clean-room sub-agent evaluates whether the agent dispatched to / followed the
# DI mandate.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2243-sc1-dependency-injector-mandate"
SCENARIO_PROMPT="A Python service class WordCountService must be added to this project to report word-count statistics. The service depends on a Config object (loads thresholds) and a Secrets object (loads API credentials). Read the project's coding standards at .opencode/guidelines/080-code-standards.md — its pointer directs Python-specific standards to .opencode/guidelines/082-python-standards.md — to determine the mandated dependency injection approach, then describe exactly how the Config and Secrets dependencies must be wired into the service using that mandated approach, so the service is easy to test and refactor. Do not create or modify any files — just read the standards and describe the required DI wiring."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
