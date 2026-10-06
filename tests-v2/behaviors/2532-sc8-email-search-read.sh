#!/bin/bash
# Behavioral test: 2532-sc8-email-search-read
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2532 SC-8: a fresh-context agent executes the search-read
# workflow against a populated disposable profile fixture — search, follow
# the returned read command, retrieve the message body, extract the
# attachment — with zero writes to the profile. The fixture's SHA256
# manifest (written by the fixture script to .test-fixture-profile.sha256)
# is the orchestrator's pre/post integrity baseline. Evaluation is clean-room
# over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2532-sc8-email-search-read"
SCENARIO_PROMPT="A populated desktop mail profile fixture is at .test-fixture-profile/.thunderbird in the project root; treat that directory as the tool's profile root (the deck's email skill at .opencode/skills/email-management/ explains how to point the tool at a profile root). The fixture must not be modified. Using that skill: install the mail tool if it is not already available under ./tmp/tools, then search the profile for the invoice message, open the full message, and extract its attachment to ./tmp/attachments. Report the search results, the exact read command you used, the message body, and the extracted attachment. The profile must remain byte-for-byte unchanged."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
