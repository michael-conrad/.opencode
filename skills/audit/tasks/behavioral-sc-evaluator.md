# Task: behavioral-sc-evaluator

## Purpose

Clean-room evaluation of behavioral test artifacts. Reads behavioral test execution output and renders binary PASS/FAIL verdicts per success criterion. This is a clean-room sub-agent — it receives ONLY the artifact directory path and evaluates the output cold, without any orchestrator context or preloaded expectations.

## Entry Context

This task receives an artifact directory path and an SC ID. It evaluates behavioral test artifacts independently, without any preloaded expectations.

**Context:** `{artifact_evidence_dir, sc_id}`

## Entry Criteria

- Artifact directory path is provided (containing `stdout.log` and `stderr.log`)
- Artifact directory exists and is readable

## Procedure

1. Read `stdout.log` from the artifact directory
   - If file does not exist: return FAIL with `MISSING_ARTIFACT: stdout.log`
2. Read `stderr.log` from the artifact directory
   - If file does not exist: return FAIL with `MISSING_ARTIFACT: stderr.log`
3. Parse `stdout.log` for agent output — evaluate whether the agent's actions and decisions satisfy each SC
4. Parse `stderr.log` for tool dispatch evidence — verify skill calls, file operations, and sub-agent dispatches occurred as expected
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
| finding_summary | "Evaluated {N} SCs: {M} PASS, {K} FAIL" |
| artifact_path | ".../artifacts/behavioral-sc-evaluation.yaml" |
| per_sc_verdicts | {SC-1: PASS, SC-2: FAIL, ...} |
| blocker_reason | "SC-2 FAIL: agent did not dispatch approval-gate skill" |
