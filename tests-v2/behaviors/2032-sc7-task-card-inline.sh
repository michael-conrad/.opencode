#!/bin/bash
# Behavioral test: 2032-sc7-task-card-inline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Sub-agent receiving a remediated task card (one of the 19 from #2032)
# executes the steps inline without calling task() or dispatching other sub-agents.
#
# The prompt sends a sub-agent a remediated task card that has been stripped of
# dispatch markers. The sub-agent should execute the steps inline — reading files,
# evaluating criteria, and returning a result contract — without attempting to
# dispatch other sub-agents via task().

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2032-sc7-task-card-inline"
SCENARIO_PROMPT="You are a sub-agent. Execute the following remediated task card inline. Do NOT call task() or dispatch any other sub-agents — execute every step yourself.

# Task: behavioral-sc-evaluator

## Purpose

Clean-room evaluation of behavioral test artifacts. Reads behavioral test execution output and renders binary PASS/FAIL verdicts per success criterion.

## Entry Context

This task receives an artifact directory path and an SC ID. It evaluates behavioral test artifacts independently, without any preloaded expectations.

**Context:** {artifact_evidence_dir, sc_id}

## Entry Criteria

- Artifact directory path is provided (containing stdout.log and stderr.log)
- Artifact directory exists and is readable

## Procedure

1. Read stdout.log from the artifact directory
   - If file does not exist: return FAIL with MISSING_ARTIFACT: stdout.log
2. Read stderr.log from the artifact directory
   - If file does not exist: return FAIL with MISSING_ARTIFACT: stderr.log
3. Parse stdout.log for agent output — evaluate whether the agent's actions and decisions satisfy each SC
4. Parse stderr.log for tool dispatch evidence — verify skill calls, file operations, and sub-agent dispatches occurred as expected
5. For each SC, render a binary verdict:
   - PASS: agent behavior matches SC criterion
   - FAIL: agent behavior does NOT match SC criterion, or evidence is insufficient
6. File-existence alone (artifact exists but content is empty or unparseable) returns FAIL — existence is NOT evidence of behavioral compliance
7. Aggregate all SC verdicts into a result contract

## Exit Criteria

- All SCs evaluated with binary PASS/FAIL verdicts
- Result contract contains per-SC verdicts
- If any SC is FAIL: overall status is BLOCKED
- If all SCs are PASS: overall status is DONE

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | Evaluated {N} SCs: {M} PASS, {K} FAIL |
| artifact_path | .../artifacts/behavioral-sc-evaluation.yaml |
| per_sc_verdicts | {SC-1: PASS, SC-2: FAIL, ...} |
| blocker_reason | SC-2 FAIL: agent did not dispatch approval-gate skill |

---

Now execute this task card. Use the following context:

artifact_evidence_dir: /tmp/behavioral-evidence-sample
sc_id: SC-1

The artifact directory contains:
- stdout.log with content: 'I have verified the feature works correctly. All tests pass.'
- stderr.log with content: 'Tool: read filePath=/tmp/spec.md\nTool: grep pattern=approved-for-*\nTool: bash command=git status'

Return your result contract as YAML."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
