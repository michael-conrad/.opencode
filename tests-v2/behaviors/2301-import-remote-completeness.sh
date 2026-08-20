#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2301-import-remote-completeness
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (#2301): A folder that exists without `spec.md` is COMPLETED (spec.md
# materialized) rather than HALTED on directory existence alone.
#
# The completeness gate (SC-1, committed in 84cce89d) is already implemented in
# import-remote.md Step 4. Per the TDD Enforcement Test Mandate, the skill/task
# change (import-remote.md) requires a BEHAVIORAL enforcement test as the PRIMARY
# gate. SC1's content-verification test only proves the gate text is present;
# SC-2's behavioral test proves the gate actually MATERIALIZES spec.md at runtime.
#
# Fixture: `fixtures/setup/2301-import-remote-completeness.sh` deletes the
# injected spec.md from `.issues/2301/` so the local issue directory exists as a
# partial mirror (metadata present, spec.md absent). This is the exact condition
# that previously caused import-remote to HALT with "issue already imported" and
# never materialize spec.md.
#
# PROMPT CONSTRUCTION:
# Real-domain task: retroactively import a pre-existing remote issue (issue
# #2301) into the local .issues/ directory, on a repo where the local folder
# #2301 already exists but is missing spec.md. This triggers the import-remote
# completeness gate. The prompt is a genuine domain task (import a remote issue),
# NOT a prose-recall interview — it does NOT name import-remote.md, the
# completeness gate, or spec.md. Natural behavior: the agent must route to the
# issue-operations-sync skill -> import-remote task and materialize the missing
# spec.md rather than halting.
#
# The default local platform (no BEHAVIOR_NEEDS_REMOTE) exercises the
# "directory exists without spec.md" path: import-remote Step 4 runs the
# completeness gate and materializes the missing file. Clean-room sub-agent
# evaluates session.yaml for: (1) the agent wrote/created spec.md (write
# tool / local-issues), (2) it did NOT halt on directory existence alone.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2301-import-remote-completeness"
SCENARIO_PROMPT="Retroactively import issue #2301 into the local .issues/ directory. The local folder .issues/2301/ already exists with issue.yaml, but the required mirror file spec.md is missing. The remote content is already synced and the needed data is present locally. Complete the local import by materializing the missing spec.md from the existing local issue data. Do not halt just because the folder exists — materialize the missing file."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-2: folder that exists without spec.md is completed (spec.md materialized), not halted"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
