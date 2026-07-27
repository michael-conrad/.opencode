#!/bin/bash
# Behavioral test: 2146-session-timestamp
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: session-init emits a human-readable datetime stamp including date, day of week, time, and timezone (behavioral)
# SC-2: Timestamp appears after Git branch line and before ## CLI Auth Status (string)
# SC-3: Natural English prose format, not structured key:value (string)
# SC-4: Uses datetime.now() at runtime — no hardcoded date (structural)
# SC-5: Local timezone abbreviation (e.g. EDT, IST, CET) — not UTC offset (string)
#
# Issue: .opencode#2146 — Add session timestamp to session-init output

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# ============================================================
# SC-1: Human-readable datetime (behavioral)
# ============================================================
SCENARIO_1="2146-sc1-session-timestamp"
PROMPT_1="Run the session-init tool at .opencode/tools/session-init and verify the output contains a human-readable datetime stamp that includes the date, day of week, time, and timezone abbreviation. Report whether the timestamp is present and well-formed."

echo "=== SC-1: Human-readable datetime ==="
behavior_run "$SCENARIO_1" "$PROMPT_1"

# ============================================================
# SC-2: Timestamp position (string)
# ============================================================
SCENARIO_2="2146-sc2-timestamp-position"
PROMPT_2="Run the session-init tool at .opencode/tools/session-init and check the position of the 'Session started:' line. Verify it appears after the 'Git branch:' line and before the '## CLI Auth Status' section. Report PASS or FAIL."

echo "=== SC-2: Timestamp position ==="
behavior_run "$SCENARIO_2" "$PROMPT_2"

# ============================================================
# SC-3: Natural English prose format (string)
# ============================================================
SCENARIO_3="2146-sc3-prose-format"
PROMPT_3="Run the session-init tool at .opencode/tools/session-init and check the format of the 'Session started:' line. Verify it uses natural English prose (e.g. 'Session started: Saturday, July 25, 2026 at 10:30 PM EDT') — not a structured key:value format like 'timestamp: 2026-07-25T22:30:00'. Report PASS or FAIL."

echo "=== SC-3: Natural English prose format ==="
behavior_run "$SCENARIO_3" "$PROMPT_3"

# ============================================================
# SC-4: Runtime datetime.now() (structural)
# ============================================================
SCENARIO_4="2146-sc4-runtime-datetime"
PROMPT_4="Inspect the source code of .opencode/tools/session-init and verify that the timestamp is generated at runtime using Python's datetime.now() or equivalent call — not a hardcoded date string. Check the main() function for the datetime call. Report PASS or FAIL."

echo "=== SC-4: Runtime datetime.now() ==="
behavior_run "$SCENARIO_4" "$PROMPT_4"

# ============================================================
# SC-5: Local timezone abbreviation (string)
# ============================================================
SCENARIO_5="2146-sc5-timezone-abbreviation"
PROMPT_5="Run the session-init tool at .opencode/tools/session-init and check the timezone portion of the 'Session started:' line. Verify it uses a local timezone abbreviation (e.g. EDT, IST, CET, PST) — not a UTC offset notation (e.g. UTC-4, +05:30, -0400). Report PASS or FAIL."

echo "=== SC-5: Local timezone abbreviation ==="
behavior_run "$SCENARIO_5" "$PROMPT_5"

exit 0
