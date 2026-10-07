#!/bin/bash
# Behavioral test: 811-sc5-ollama-web-search-invocation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (.opencode#811): agent invokes the ollama-web-search MCP tools
# (web_search, web_fetch) in a real research task. The MCP entry rides the
# pushed effective commit via .opencode/opencode.jsonc — no config injection.
# The isolated test home carries no API credential; tool results reflect that
# environment fact.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="811-sc5-ollama-web-search-invocation"
SCENARIO_PROMPT="Use the ollama-web-search MCP server's web_search tool to search the web for 'PEP 723 inline script metadata', then use its web_fetch tool to fetch the first result URL. Report the search result titles and what the fetched page is about."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
