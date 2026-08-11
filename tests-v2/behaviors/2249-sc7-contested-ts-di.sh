#!/bin/bash
# Behavioral test: 2249-sc7-contested-ts-di
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7 (behavioral): A clean-room sub-agent SHALL evaluate the session.yaml
# artifact and confirm the agent applied the DI mandate (selected a DI approach
# rather than hand-rolling manual wiring), covering at least one "Clear
# standard" language (see 2249-sc6) and one "Contested"/"Non-idiomatic"
# language, and confirming the HTML/CSS exclusion (see 2249-sc7-html-css).
#
# This scenario covers a CONTESTED-tier language: TypeScript. The framework
# table lists TypeScript under the "Contested" tier with tsyringe/InversifyJS
# as idiomatic options. A real-domain prompt asking the agent to design a
# TypeScript service with injectable dependencies must result in the agent
# selecting a DI approach appropriate to code/spec context (a Contested-tier
# framework or a justified context-driven choice) rather than hand-rolling
# manual wiring or applying a fixed pin.
#
# The prompt is a real-domain task (design a TypeScript service with injectable
# dependencies), NOT a prose-recall interview. See .opencode/tests-v2/AGENTS.md
# §11 Prompt Construction Mandate. The session.yaml (SQLite DB export) is the
# PRIMARY evidence source for clean-room evaluation.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2249-sc7-contested-ts-di"
SCENARIO_PROMPT="A TypeScript service class WordCountService must be added to this project to report word-count statistics. The service depends on a Config object (loads thresholds) and a Secrets object (loads API credentials). The project's coding standards at .opencode/guidelines/080-code-standards.md contain a generic multi-language Dependency Injection mandate with a per-language framework table. Read that file to find the framework tier assigned to TypeScript and the framework(s) listed for it, then describe exactly how the Config and Secrets dependencies must be wired into WordCountService using the DI approach the standards designate for TypeScript, so the service is easy to test and refactor. Do not create or modify any files — just read the standards and describe the required DI wiring for TypeScript."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
