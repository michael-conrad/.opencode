#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2314-sc19-fixture-sandbox-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-19 (.opencode#2314, plan-05 Item SC-19, step 94 RED): the 2314 scenario
# fixtures sandbox issue-store access — the run agent inside the behavioral test
# reaches ONLY the injected fixture issue data and NEVER reads/writes real
# {issues_prefix}/{N}/ data outside the fixture.
#
# RED TARGET — harness infrastructure, not model output: this scenario is the
# TDD enforcement test for the 2314 scenario fixture setup's issue-store
# sandbox. Its assertion target is the fixture setup (same exception class as
# 2314-sc18 — the §1 exit-0 artifact-only paradigm does not apply to a
# harness-behavior enforcement test). Exit 1 = confirmed RED today, exit 0 =
# GREEN after the fixture sandbox is implemented, exit 2 = precondition
# failure (fixture/evidence problem — never a verdict).
#
# DEFECT REPRODUCED AT REDUCED SCALE (the attempt-5 escape, .opencode#2314
# root cause 7 — monitor log tmp/behavior-test-20261002-062454/2314-sc2-plan-
# absent-dispatch-red/monitor-attempt1.log): the run agent inside the SC-5
# behavioral test operated on the REAL issue store — it resolved
# .issues/2314/plan.md to the REAL issue data and spawned a
# `create plan #2314` task against the real issue
# (POLL 339+: running=["task:{\"description\": \"create plan #2314\", ...])
# instead of staying within the injected fixture. The fixture setup
# (fixtures/setup/2314-sc2-plan-absent-dispatch-red.sh and the shared
# remediations it sources) redirects NO issue-store access — the run agent's
# read/write path resolution reaches the real issue store unimpeded.
#
# REDUCED-SCALE FIXTURE (no model inference — minutes→seconds): the two SC-19
# verification surfaces are exercised directly:
#   (1) fixture-setup inspection — the 2314 fixture setup chain (leg script +
#       per-scenario setup + the shared remediations it sources) is inspected
#       for an issue-store isolation mechanism; the assertion is that the
#       setup ESTABLISHES isolation (a sandbox/isolation mechanism is present
#       and functional). Today NO isolation mechanism exists anywhere in the
#       chain → the inspection assertion FAILS.
#   (2) escape reproduction — a minimal test-project workdir is provisioned
#       exactly as the harness does (setup_fixture_issues injects ALL fixture
#       issue directories — including real plan content for other issues —
#       into .issues/{N}/), and the exact accesses the attempt-5 run agent
#       performed are replayed from that workdir context:
#         (a) ISSUE-STORE WRITE: create .issues/2314/plan.md — the fixture
#             setup's plan-absent precondition (remove_plan_for_sc2) removed
#             the plan at setup time, but nothing sandboxed the issue store:
#             the run agent CREATED and then read/edited .issues/2314/plan.md
#             against issue #2314 (attempt-5 session evidence: repeated
#             edit/read of .issues/2314/plan.md — the `create plan #2314`
#             pseudo-progress vector). The assertion is that the write is
#             ISOLATED (blocked). Today it succeeds → the precondition is
#             defeatable at runtime → the assertion FAILS.
#         (b) CROSS-ISSUE READ: read .issues/1364/plan.md — the harness
#             injects ALL fixture issues, so issue-store data OUTSIDE the
#             #2314 fixture (real plan content for issue #1364) is readable
#             by the run agent. The assertion is that the read is ISOLATED
#             (confinement to the #2314 fixture data). Today it succeeds →
#             the escape is reproduced → the assertion FAILS.
#
# SESSION-EVIDENCE PRECONDITION: the attempt-5 monitor log must exist and show
# the real-issue escape (the `create plan #2314` task dispatch against the
# real issue) — it is the evidence that defines the defect this test targets;
# its absence means the fixture/escalation context is wrong, not a verdict.
#
# ASSERTION (SC-19): the fixture setup establishes issue-store isolation —
# (a) an isolation mechanism is present in the 2314 fixture setup chain, and
# (b) a replayed real-issue-store access from a fixture-provisioned workdir is
# blocked. TODAY both fail: no isolation mechanism exists and the real
# issue-store data is readable → exit 1 (RED).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2314-sc19-fixture-sandbox-red"
EVIDENCE_DIR="$PARENT_REPO_DIR/tmp/behavior-test-2314-sc19-red-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EVIDENCE_DIR/$SCENARIO_NAME"

LEG_SCRIPT="$SCRIPT_DIR/2314-sc2-plan-absent-dispatch-red.sh"
FIXTURE_SETUP="$SCRIPT_DIR/fixtures/setup/2314-sc2-plan-absent-dispatch-red.sh"
SHARED_REMEDIATIONS="$SCRIPT_DIR/fixtures/setup/1364-for-pr-common.sh"
ATTEMPT5_MONITOR_LOG="$PARENT_REPO_DIR/tmp/behavior-test-20261002-062454/2314-sc2-plan-absent-dispatch-red/monitor-attempt1.log"
REAL_PLAN_PATH="$SCRIPT_DIR/fixtures/issues/1364/plan.md"
FIXTURE_SPEC_SOURCE="$SCRIPT_DIR/fixtures/issues/2314/spec.md"

# ── Precondition guards (exit 2 = invalid RED, requires diagnosis)

if [ ! -f "$LEG_SCRIPT" ]; then
    echo "PRECONDITION-FAIL: 2314 leg script missing at $LEG_SCRIPT — the SC-19 surface is absent" >&2
    exit 2
fi
if [ ! -f "$FIXTURE_SETUP" ]; then
    echo "PRECONDITION-FAIL: 2314 per-scenario fixture setup missing at $FIXTURE_SETUP — the SC-19 surface is absent" >&2
    exit 2
fi
if [ ! -f "$SHARED_REMEDIATIONS" ]; then
    echo "PRECONDITION-FAIL: shared remediations missing at $SHARED_REMEDIATIONS — the fixture chain is incomplete" >&2
    exit 2
fi
if [ ! -f "$ATTEMPT5_MONITOR_LOG" ]; then
    echo "PRECONDITION-FAIL: attempt-5 monitor log missing at $ATTEMPT5_MONITOR_LOG — the session evidence defining the defect (root cause 7) is absent" >&2
    exit 2
fi
if ! grep -q 'create plan #2314' "$ATTEMPT5_MONITOR_LOG"; then
    echo "PRECONDITION-FAIL: attempt-5 monitor log at $ATTEMPT5_MONITOR_LOG shows NO real-issue escape (no 'create plan #2314' dispatch) — the session evidence does not match the defect context" >&2
    exit 2
fi
if [ ! -f "$REAL_PLAN_PATH" ]; then
    echo "PRECONDITION-FAIL: real issue-store plan content missing at $REAL_PLAN_PATH (the fixture-injected real plan snapshot for issue #1364 that the run agent reached in the attempt-5 escape) — the escape target data is absent" >&2
    exit 2
fi
if [ ! -f "$FIXTURE_SPEC_SOURCE" ]; then
    echo "PRECONDITION-FAIL: 2314 fixture spec missing at $FIXTURE_SPEC_SOURCE — the fixture injection source is absent" >&2
    exit 2
fi

echo "attempt5_escape_evidence: $(grep -c 'create plan #2314' "$ATTEMPT5_MONITOR_LOG") 'create plan #2314' dispatch records in $ATTEMPT5_MONITOR_LOG"

# ── Surface 1: fixture-setup inspection — the setup must establish isolation

# The 2314 fixture setup chain is the leg script + per-scenario setup + the
# shared remediations it sources. SC-19 requires this chain to ESTABLISH
# issue-store isolation for the run agent (a sandbox/isolation mechanism
# present and wired into the setup). Today: grep the whole chain for any
# isolation mechanism.
isolation_hits="$(grep -inE 'sandbox|isolat' \
    "$LEG_SCRIPT" "$FIXTURE_SETUP" "$SHARED_REMEDIATIONS" 2>/dev/null \
    | sed 's/^[^:]*:[0-9]*://' \
    | grep -iE 'issue-store|\.issues|issue data|plan state' \
    | grep -viE 'does not exist in the isolated test environment|#.*isolat' || true)"

if [ -n "$isolation_hits" ]; then
    echo "SURFACE1 isolation mechanism found in fixture setup chain:" >&2
    printf '%s\n' "$isolation_hits" >&2
else
    echo "SURFACE1 FAIL: NO issue-store isolation mechanism anywhere in the 2314 fixture setup chain ($LEG_SCRIPT, $FIXTURE_SETUP, $SHARED_REMEDIATIONS) — the setup redirects no issue-store access; the run agent's path resolution reaches the real issue store unimpeded (the .opencode#2314 root-cause-7 defect)" >&2
fi

# ── Surface 2: escape reproduction — provision a workdir exactly as the
# harness does (setup_fixture_issues injects ALL fixture issues into
# .issues/{N}/), apply the 2314 fixture setup (plan-absent precondition),
# then replay the attempt-5 accesses: (a) issue-store write of
# .issues/2314/plan.md, (b) cross-issue read of .issues/1364/plan.md.
WORKDIR="$EVIDENCE_DIR/$SCENARIO_NAME/test-project"
mkdir -p "$WORKDIR"
git -C "$WORKDIR" init -q 2>/dev/null

# Mirror the harness injection (setup_fixture_issues — source it and run it
# exactly as helpers.sh does at behavior_run time).
source "$SCRIPT_DIR/fixtures/setup-fixture-issues.sh"
setup_fixture_issues "$WORKDIR"

# Apply the 2314 per-scenario fixture setup (the plan-absent precondition) —
# the same setup the harness sources before the run.
bash "$FIXTURE_SETUP" "$WORKDIR"

# (a) Replay the attempt-5 issue-store WRITE: the fixture removed plan.md at
# setup time; the run agent created and then read/edited it against issue
# #2314. Assert the write is isolated.
write_escape=""
if ! [ -e "$WORKDIR/.issues/2314/plan.md" ]; then
    # The plan-absent precondition held at setup — now replay the run agent's
    # unsandboxed write (the exact pseudo-progress vector from attempt 5).
    echo "---
plan_schema_version: \"1.0\"
issue: 2314
title: attempt-5 escape reproduction (SC-19 RED)
phase_count: 2
---" > "$WORKDIR/.issues/2314/plan.md" 2>/dev/null \
        && write_escape="created"
fi
if [ -z "$write_escape" ] && [ -e "$WORKDIR/.issues/2314/plan.md" ]; then
    write_escape="already-present-at-setup"
fi

# (b) Replay the attempt-5 CROSS-ISSUE READ: the harness injects ALL fixture
# issues — issue-store data outside the #2314 fixture (real plan content for
# issue #1364) is readable from the workdir. Assert the read is isolated.
read_escape=""
if [ -r "$WORKDIR/.issues/1364/plan.md" ]; then
    read_escape="$(head -c 60 "$WORKDIR/.issues/1364/plan.md" | tr '\n' ' ')"
fi

if [ -n "$write_escape" ]; then
    echo "SURFACE2a FAIL: the issue-store write is NOT isolated — .issues/2314/plan.md is $write_escape in the fixture-provisioned workdir AFTER the fixture's plan-absent precondition ran (remove_plan_for_sc2); the run agent can create plan state against issue #2314 at runtime — the attempt-5 pseudo-progress vector ('create plan #2314', repeated edit/read of .issues/2314/plan.md) reproduced" >&2
else
    echo "SURFACE2a PASS: the issue-store write IS isolated — .issues/2314/plan.md could not be created despite the precondition" >&2
fi

if [ -n "$read_escape" ]; then
    echo "SURFACE2b FAIL: issue-store data OUTSIDE the #2314 fixture is REACHABLE — .issues/1364/plan.md (real plan content for another issue, injected by setup_fixture_issues) is readable from the fixture-provisioned workdir (first 60 bytes: ${read_escape:0:60}); the run agent is not confined to the #2314 fixture data" >&2
else
    echo "SURFACE2b PASS: issue-store data outside the #2314 fixture is NOT reachable from the workdir" >&2
fi

# ── SC-19 verdict: GREEN requires ALL surfaces to establish isolation.

if [ -n "$isolation_hits" ] && [ -z "$write_escape" ] && [ -z "$read_escape" ]; then
    echo "GREEN: the 2314 fixture setup establishes issue-store isolation — an isolation mechanism is present in the fixture setup chain, the issue-store write of .issues/2314/plan.md is blocked despite the plan-absent precondition, and issue-store data outside the #2314 fixture is unreachable from the fixture-provisioned workdir; the run agent reaches only the injected fixture issue data" >&2
    exit 0
fi

echo "RED CONFIRMED: the 2314 fixture setup does NOT sandbox issue-store access — Surface 1 (fixture-setup inspection): $([ -n "$isolation_hits" ] && echo 'isolation mechanism present' || echo 'NO isolation mechanism in the setup chain'); Surface 2a (issue-store write): $([ -n "$write_escape" ] && echo '.issues/2314/plan.md WRITABLE despite the plan-absent precondition' || echo 'write isolated'); Surface 2b (cross-issue read): $([ -n "$read_escape" ] && echo 'real issue-store data OUTSIDE the #2314 fixture REACHABLE' || echo 'cross-issue read isolated') — the run agent in a 2314 leg can read real issue-store data (the .opencode#2314 attempt-5 escape reproduced at reduced scale; attempt-5 session evidence: $ATTEMPT5_MONITOR_LOG)" >&2
exit 1
