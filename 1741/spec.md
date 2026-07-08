# Spec: Fix SC-9 Behavioral Test Timeout + Add Pre-PR Gate

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | SC-9 from `.opencode#1421` is FAIL. The behavioral test `gap-fill-cascade-missing-plan.sh` times out at 1200s because it tests the full authorization pipeline end-to-end (load approval-gate, dispatch verify-authorization, which internally dispatches gap-fill-cascade, which checks spec→plan→etc.) before ever reaching the gap-fill-cascade dispatch. The model (deepseek-v4-flash-free) is too slow for this multi-step pipeline. |
| Root Cause / Motivation | The test prompt `"approved for PR: .opencode#100"` triggers the full authorization pipeline, not just gap-fill-cascade. The test should be scoped to test only the gap-fill-cascade behavior, not the entire verify-authorization chain. |
| Approach Chosen | (1) Create a new behavioral test with a direct prompt that invokes gap-fill-cascade without going through the full authorization pipeline. (2) Add a pre-PR gate in the implementation pipeline that blocks PR creation when any SC is FAIL. |
| Alternatives Considered & Why Discarded | (a) Increase timeout — masks the problem, doesn't fix it. (b) Speed up the model — not under our control. (c) Remove the test — loses coverage. (d) Simplify the authorization pipeline — too broad a change, risks breaking other things. |
| Key Design Decisions | The scoped test uses a direct prompt targeting gap-fill-cascade. The pre-PR gate is a new pipeline step between `green-vbc` and `review-prep` that checks all SC verdicts before allowing PR creation. |

## Problem

SC-9 from `.opencode#1421` requires that when the agent receives `for_pr` scope with a missing plan, it dispatches `writing-plans` via the gap-fill cascade's state-verification checklist. The behavioral test `gap-fill-cascade-missing-plan.sh` sends the prompt `"approved for PR: .opencode#100"` (fixture issue with spec but no plan).

The test times out at 1200s because the agent goes through the full authorization pipeline:
1. Load approval-gate skill
2. Dispatch verify-authorization
3. verify-authorization internally dispatches gap-fill-cascade
4. gap-fill-cascade checks spec→plan→etc.

The model (deepseek-v4-flash-free) is too slow for this multi-step pipeline. The test should test only the gap-fill-cascade dispatch, not the entire verify-authorization chain.

Additionally, there is no pre-PR gate that blocks PR creation when any SC is FAIL. The pipeline must block PR creation when any SC is FAIL — this is a separate concern from fixing the test.

## Scope

### In Scope

- Create a new behavioral test that directly triggers gap-fill-cascade without going through the full authorization pipeline
- The test uses a direct prompt (e.g., `"run gap-fill-cascade for .opencode#100 with for_pr scope"`) that invokes the gap-fill-cascade task directly
- Verify the agent dispatches `writing-plans` via `next_action` routing
- Add a pre-PR gate in the implementation pipeline between `green-vbc` and `review-prep` that checks all SC verdicts and blocks PR creation when any SC is FAIL
- The existing test `gap-fill-cascade-missing-plan.sh` is retained but marked as a full-pipeline integration test (not a unit test for gap-fill-cascade)

### Out of Scope

- Changing the authorization pipeline itself
- Changing the gap-fill-cascade task logic
- Changing the verify-authorization task logic
- Removing the existing behavioral test
- Changing timeout values for the existing test
- Any changes to the model selection or inference pipeline

## Affected Files

| File | Change |
|------|--------|
| `tests/behaviors/gap-fill-cascade-missing-plan.sh` | Add comment noting this is a full-pipeline integration test; keep as-is |
| `tests/behaviors/gap-fill-cascade-direct.sh` | **NEW** — scoped test with direct prompt targeting gap-fill-cascade |
| `skills/implementation-pipeline/SKILL.md` | Add `pre-pr-gate` step between `green-vbc` and `review-prep` in Trigger Dispatch Table |

## Design

### Scoped Behavioral Test

The new test `gap-fill-cascade-direct.sh` uses a prompt that directly invokes the gap-fill-cascade task:

```bash
SCENARIO_NAME="gap-fill-cascade-direct"
SCENARIO_PROMPT="run gap-fill-cascade for .opencode#100 with for_pr scope"
```

This prompt skips the full authorization pipeline and directly triggers the gap-fill-cascade task, which checks spec→plan state and routes to `writing-plans` via `next_action` when plan is missing.

The test is an artifact-only generator per the behavioral test harness specification. Evaluation is performed by clean-room sub-agents.

### Pre-PR Gate

A new pipeline step `pre-pr-gate` is added between `green-vbc` and `review-prep` in the implementation pipeline's Trigger Dispatch Table. This step:

1. Reads all SC verdicts from the verification artifacts
2. If any SC is FAIL: BLOCK with report listing all FAIL SCs
3. If all SCs PASS: proceed to `review-prep`

The gate is a sub-task dispatched to `verification-before-completion --task verify` with a scope-limited check that reads the SC verdict summary and returns PASS/FAIL.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation |
|----|-----------|---------------|---------------------|-------------|
| SC-1 | New behavioral test `gap-fill-cascade-direct.sh` exists in `tests/behaviors/` | `structural` | `ls tests/behaviors/gap-fill-cascade-direct.sh` | Create the file |
| SC-2 | New test uses a direct prompt that invokes gap-fill-cascade without going through full authorization pipeline | `string` | `grep -q "run gap-fill-cascade" tests/behaviors/gap-fill-cascade-direct.sh` | Fix the prompt |
| SC-3 | New test is an artifact-only generator (exits 0 unconditionally, no assertion calls) | `string` | `grep -q "exit 0" tests/behaviors/gap-fill-cascade-direct.sh` | Fix script structure |
| SC-4 | New test produces behavioral artifacts when run | `behavioral` | Run `bash tests/behaviors/gap-fill-cascade-direct.sh` and verify `tmp/behavioral-evidence-gap-fill-cascade-direct-*/manifest.yaml` exists | Diagnose and fix harness issues |
| SC-5 | Pre-PR gate step exists in implementation-pipeline Trigger Dispatch Table between `green-vbc` and `review-prep` | `string` | `grep -A1 "green-vbc" skills/implementation-pipeline/SKILL.md \| grep "pre-pr-gate"` | Add the step |
| SC-6 | Pre-PR gate dispatches to `verification-before-completion --task verify` with scope-limited SC verdict check | `string` | `grep "pre-pr-gate" skills/implementation-pipeline/SKILL.md \| grep "verification-before-completion"` | Fix the dispatch target |
| SC-7 | Pre-PR gate blocks PR creation when any SC is FAIL | `behavioral` | Run behavioral test that triggers pipeline with FAIL SC and verify agent does not proceed to review-prep | Implement BLOCK routing in gate |
| SC-8 | Existing test `gap-fill-cascade-missing-plan.sh` is retained with comment noting it is a full-pipeline integration test | `string` | `grep -q "full-pipeline integration test" tests/behaviors/gap-fill-cascade-missing-plan.sh` | Add the comment |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Pre-PR gate runs when no SC verdicts exist yet | BLOCK with "no SC verdicts found" — pipeline state is incomplete |
| Pre-PR gate runs with mixed PASS/FAIL SCs | BLOCK with list of FAIL SCs; do not proceed |
| Pre-PR gate runs with all SCs PASS | Proceed to review-prep |
| New test times out despite scoped prompt | Increase `BEHAVIOR_TIMEOUT` to 600s; if still fails, investigate model availability |
| New test produces empty artifacts | Re-task clean-room sub-agent with same scoped context (max 2 retries) |

## Phases

### Phase 1: Scoped Behavioral Test

1. Create `tests/behaviors/gap-fill-cascade-direct.sh` with direct prompt
2. Add comment to existing test noting it is a full-pipeline integration test
3. Run the new test and verify artifacts are produced
4. Verify SC-1 through SC-4

### Phase 2: Pre-PR Gate

1. Add `pre-pr-gate` step to implementation-pipeline Trigger Dispatch Table between `green-vbc` and `review-prep`
2. Add canonical dispatch string for `pre-pr-gate` in the Invocation section
3. Add step label for `pre-pr-gate` in the Step Labels section
4. Verify SC-5 through SC-7

## Changelog

| Revision | Date | Author | Change |
|----------|------|--------|--------|
| 1 | 2026-07-07 | OpenCode (deepseek-v4-flash) | Initial spec |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1741/plan.md` before implementation begins.

Co-authored with AI: OpenCode (deepseek-v4-flash)
