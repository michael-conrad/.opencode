#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# Behavioral test: 2456-sc14-full-semantic-check-per-poll-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-14 (.opencode#2456, plan-06 phase-6 item, RED): every poll of a monitored
# run performs a FULL SEMANTIC CHECK of progress so far — the classification
# is derived from the run's message parts, reasoning parts, and tool calls in
# the session export. Activity/uptime/tool-call COUNTS are inadmissible as
# evidence of correct operation; an ACTIVITY-ONLY classification is defective.
#
# BASELINE (known gap): the SC-14 admissible-evidence rule exists in
# helpers.sh (~546-547 comment: excerpts derived ONLY from message parts,
# reasoning parts, and tool calls; activity counters are never the
# classification basis) and the __classify_run_state digest does carry
# message_parts_recent / reasoning_tails_recent / tool_calls_recent — but NO
# enforcement scenario asserts the per-poll full-semantic-check predicate.
# This scenario is that enforcement.
#
# EXERCISE SURFACE — the already-enforced SC-2 classification dispatch on a
# monitored run. The fixture: a HIGH-ACTIVITY, NO-GOAL-PROGRESS run. The
# scenario declares NO verifiable goal condition (no BEHAVIOR_EXPECTED_ARTIFACT,
# no BEHAVIOR_EXPECTED_ARTIFACT_GREP, no BEHAVIOR_GOAL_ACTIONS) — the empty
# goal_condition makes undetermined the classifier's only direction-anchored
# answer, and the run's high tool-call activity (heartbeat cycles) is exactly
# the INADMISSIBLE counter-evidence an activity-only classifier would lean on.
#
# SC-14 SINGLE-ASSERTION TARGET: the classifier's digest (persisted in the
# classifier-session export's classifier prompt) must CARRY the run's
# message/reasoning/tool-call parts — content evidence, never activity
# counters alone.
#   - REQUIRED (green): the classifier session export's embedded digest carries
#     message_parts_recent AND reasoning_tails_recent AND tool_calls_recent
#     populated from the run's session DB — a full semantic check input.
#   - DEFECTIVE (red #1): classification produced with NO content parts in the
#     digest (all three content fields absent or empty) — an activity-only
#     classification input.
#   - DEFECTIVE (red #2): no classifier session export at all — no semantic
#     check performed.
#   - DEFECTIVE (red #3): the classification record (determination.yaml) does
#     not cite the content-evidence dispatch (no CLASSIFY line in the poll log
#     referencing the classifier export) — an unverifiable classification.
#
# RED condition (known gap, recorded honestly): helpers.sh ALREADY populates
# the digest with content parts — if the current harness satisfies the
# predicate the run is ALREADY_GREEN (exit 3, classified abort with zero
# further analysis, recorded as the item's genuine outcome). If the digest
# carries no content parts, or no classification dispatch fires, the scenario
# exits 1 (RED confirmed — the predicate is unenforced/absent).
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the scenario evidence directory with session.yaml, monitor.log,
# and classifier-session.yaml must exist; the run must complete naturally or
# reach a classified checkpoint (a MONITOR-COMPLETE or MONITOR-HALTED marker
# in monitor.log) so a classification digest was produced. Without these the
# SC-14 assertion surface is absent (not a RED verdict).
#
# ACTIVITY-ONLY ADVERSARIAL INPUT: the classifier prompt must NOT have carried
# shell activity counters (ev=/tools=/completed= poll-line counters) as
# classification input. The poll log's POLL lines are shell evidence, never
# classification input — the scenario asserts the classifier prompt in the
# classifier session export carries content parts (positive requirement); the
# activity-only DEFECT is the absence of content parts, which red #1 detects.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc14-full-semantic-check-per-poll-red.sh
# with the bash tool timeout >= 600000ms per supervision poll (supervised
# run, §14 mandate — launched once detached/setsid, polled every <=290s with
# a full semantic check of the run's SQLite session DB).
#
# Ordered precondition cycle (§4/SC-16): commit → push → fresh fetch/verify
# → run. NEVER --no-verify.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc14-full-semantic-check-per-poll-red"
# §11 real-domain prompt: the fully-specified heartbeat protocol loop (same
# shape as the sc13 fixture — distinct lines, one write per cycle, bounded
# count, explicit stop) so the run produces RICH content evidence (message
# parts, reasoning parts, many tool calls) while completing naturally inside
# the monitor budget. High tool-call activity with the run's own declared
# log-writing goal — the run IS its own activity generator, and the declared
# NO goal_condition (below) is what makes activity counters the tempting
# inadmissible substitute for direction.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged / run 04: cycle logged / run 05: cycle logged / run 06: cycle logged. After all six lines are appended, the protocol loop is complete — stop."

# SC-14 monitored run (opt-in flags per spec — fresh invocations without the
# flags are unchanged; backward compat preserved). Same shape as the
# already-enforced 2456-sc6/sc7/sc13 undetermined fixture.
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=60
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=900
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT

# DELIBERATELY NO goal-condition declaration (see EXERCISE SURFACE above).

# Harness stderr capture — the durable precondition surface.
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
harness_stderr_capture="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" 2> "$harness_stderr_capture" || true

# ── Precondition guards ──────────────────────────────────────────────────
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
monitor_log="$artifact_dir/monitor.log"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict; harness stderr capture: $harness_stderr_capture" >&2
    exit 2
fi
for required in session.yaml classifier-session.yaml monitor.log; do
    if [ ! -f "$artifact_dir/$required" ]; then
        echo "PRECONDITION-FAIL: $required missing from $artifact_dir — run produced incomplete evidence; not a RED verdict" >&2
        exit 2
    fi
done
if ! grep -qE "MONITOR-COMPLETE|MONITOR-HALTED" "$monitor_log"; then
    echo "PRECONDITION-FAIL: monitor.log carries neither MONITOR-COMPLETE nor MONITOR-HALTED — the monitor never reached a classified checkpoint, so no classification digest was produced; not a RED verdict" >&2
    exit 2
fi
if ! grep -q "^CLASSIFY\[" "$monitor_log"; then
    echo "PRECONDITION-FAIL: no CLASSIFY dispatch in $monitor_log — the classification checkpoint never fired, so the SC-14 per-poll full-semantic-check assertion surface is absent; not a RED verdict" >&2
    exit 2
fi

# ── SC-14 assertion: the classifier's digest carries CONTENT evidence ────
# The classifier session export contains the classifier's OWN session (its
# prompt embeds the digest JSON produced by __classify_run_state). The SC-14
# predicate: that digest carries message_parts_recent, reasoning_tails_recent,
# and tool_calls_recent populated from the run's session DB.
digest_content_ok=1
missing_parts=""
for part_key in message_parts_recent reasoning_tails_recent tool_calls_recent; do
    # The digest JSON is embedded (possibly escaped) in the classifier prompt
    # inside the export. The key must be present AND carry at least one
    # non-empty entry (a '[' opening followed by a quoted entry, not an
    # immediately-closing empty list for ALL THREE at once).
    if ! grep -q "$part_key" "$artifact_dir/classifier-session.yaml"; then
        digest_content_ok=0
        missing_parts="${missing_parts}${part_key}(absent) "
    fi
done

if [ "$digest_content_ok" -eq 0 ]; then
    echo "RED CONFIRMED: the classification digest carries NO content evidence — ${missing_parts}all absent from $artifact_dir/classifier-session.yaml; the classification (if any) was produced from ACTIVITY COUNTERS ALONE, the inadmissible input SC-14 closes (activity/uptime/tool-call counts are never evidence of correct operation; an activity-only classification is defective)" >&2
    exit 1
fi

# Content keys present — verify at least the tool-call part carries actual
# entries (a digest with keys but empty content lists for all three is still
# an activity-only classification input). tool_calls_recent entries look like
# "bash[completed] {...}" in the embedded JSON.
tool_entries=$(grep -oE '(bash|read|write|edit|list|glob|grep|task)\[(pending|running|completed|error)\]' "$artifact_dir/classifier-session.yaml" | wc -l || echo 0)
if [ "${tool_entries:-0}" -eq 0 ]; then
    echo "RED CONFIRMED: the classification digest carries the content-part keys but NO populated tool-call entries in $artifact_dir/classifier-session.yaml — the classification input had no message/reasoning/tool-call content (an empty-content classification is activity-only in effect)" >&2
    exit 1
fi

# ── SC-14 second gate: the classification record cites content evidence ──
# The poll log's CLASSIFY line must reference the classifier session export —
# the classification record's provenance is the content-evidence dispatch,
# not a shell counter evaluation.
if ! grep -E '^CLASSIFY\[' "$monitor_log" | grep -q "classifier-session"; then
    echo "RED CONFIRMED: the CLASSIFY record in $monitor_log does not cite the classifier session export (content-evidence provenance absent) — the classification cannot be traced to a full semantic check of the run's message/reasoning/tool-call parts" >&2
    exit 1
fi

# ── Terminal: the predicate already holds — ALREADY_GREEN classified abort ─
echo "RED ABORT — ALREADY_GREEN: the per-poll classification digest in $artifact_dir/classifier-session.yaml carries message_parts_recent, reasoning_tails_recent, and tool_calls_recent populated from the run's session DB (${tool_entries} tool-call entries), and the poll-log CLASSIFY record cites the classifier export — the SC-14 full-semantic-check predicate is already enforced by the current harness (__classify_run_state digest; helpers.sh SC-14 admissible-evidence rule), so a failing RED test cannot be validly produced" >&2
exit 3