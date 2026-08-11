#!/bin/bash
# Behavioral test: 2249-sc7-html-css-exclusion
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7 (behavioral): A clean-room sub-agent SHALL evaluate the session.yaml
# artifact and confirm the agent applied the DI mandate, including confirming
# the HTML/CSS exclusion (markup and styling are not programming languages, so
# DI guidance does not apply).
#
# This scenario covers the HTML/CSS EXCLUSION. A real-domain prompt asking the
# agent to structure a markup/styling artifact (HTML page with CSS styling)
# must NOT result in the agent attempting a DI approach — the agent must not
# try to inject dependencies into HTML/CSS. The agent should recognize markup
# and styling are not programming languages.
#
# The prompt is a real-domain task (structure an HTML page with CSS styling),
# NOT a prose-recall interview. See .opencode/tests-v2/AGENTS.md §11 Prompt
# Construction Mandate. The session.yaml (SQLite DB export) is the PRIMARY
# evidence source for clean-room evaluation.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2249-sc7-html-css-exclusion"
SCENARIO_PROMPT="An HTML page with embedded CSS styling must be added to this project to display word-count statistics. Read the project's coding standards at .opencode/guidelines/080-code-standards.md to determine the mandated dependency injection approach, then describe exactly how the HTML markup and CSS styling must be structured. Do not create or modify any files — just read the standards and describe the required structure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
