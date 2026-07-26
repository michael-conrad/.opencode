> **Full spec and artifacts:** [`.opencode/.issues/2155/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2155) — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2155/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Fix analytical-artifacts gate — remediation-first before halt

## Intent and Executive Summary

- **Problem Statement:** The audit SKILL.md's analytical-artifact gate blocks spec-audit when artifacts are missing, without attempting remediation (retroactive artifact generation). This creates a self-defeating circular dependency.
- **Root Cause:** The TDT has 7 hardcoded HALT rows that check for file existence at the orchestrator level, violating both remediation-first (065) and orchestrator-context-lean (000) principles.
- **Approach Chosen:** Retroactive artifact generation via the existing `writing-plans/tasks/backfill.md` task, triggered by a TDT catch-all row. The orchestrator routes — it does not check files inline.
- **Alternatives Considered:** (1) Remove gate entirely — rejected: artifacts are valuable audit input; (2) Make artifacts optional at spec level — rejected: would require SKILL.md changes in two skills; (3) Lazy generation at audit time — rejected: adds latency to every audit; (4) Retroactive generation via existing backfill task — chosen: leverages existing infrastructure, minimal TDT change.
- **Key Design Decisions:** Remediation is routed via the sub-agent contract (REMEDIATION_REQUIRED status), not via orchestrator-level logic. The orchestrator learns about missing artifacts FROM the sub-agent, not from its own file checks.

## Problem

The audit SKILL.md (§Mandatory Task Discipline item 5) requires all 7 analytical artifacts before spec-audit can proceed. When artifacts are missing, the Trigger Dispatch Table has 7 hardcoded HALT rows — one per artifact type. This creates three defects:

1. **Self-defeating gate**: The quality check that would detect missing artifacts cannot run, because it requires those same artifacts as a precondition.
2. **Remediation-first violation**: `065-verification-honesty.md` mandates remediation before halt. The audit gate halts immediately without attempting retroactive artifact generation.
3. **Orchestrator inline work**: The 7 HALT rows in the TDT are orchestrator-level file-existence checks — the orchestrator checks for files instead of dispatching to a sub-agent.

`writing-plans/tasks/backfill.md` already provides retroactive artifact generation (mode: retroactive), so the remediation path exists but the audit gate does not use it.

Additionally, `guidelines/010-approval-gate.md` references `spec-creation/tasks/analytical-artifacts.md` which does not exist — the analytical-artifacts task lives within `tasks/analyze.md` Step 5 (Generate the 7 analytical artifacts), writing to `{project_root}/tmp/{issue_number}/artifacts/`.

**Scope note:** The 010-approval-gate.md reference fix (Approach 4 in Items) is enabling infrastructure cleanup discovered during investigation, not a core defect fix. It is documented in Phase 4 as auxiliary cleanup, separate from the 3 core defects (gate, remediation, inline work).

## Background

The analytical artifacts gate was added to the audit SKILL.md to ensure spec-audit has all the context it needs. However, the implementation created a chicken-and-egg problem: you need the artifacts to run the audit that would tell you the artifacts are missing. The `writing-plans/tasks/backfill.md` task was later added to solve exactly this problem via retroactive generation, but the audit gate was never updated to use it.

## Documentation Sources

| File | Verification |
|------|-------------|
| `.opencode/skills/audit/SKILL.md` | ✅ Verified — 7 HALT rows at lines 65-71 |
| `.opencode/skills/spec-creation/tasks/analyze.md` | ✅ Verified — Step 5 (lines 52-64) generates 7 analytical artifacts |
| `.opencode/skills/writing-plans/tasks/backfill.md` | ✅ Verified — exists with retroactive generation mode |
| `.opencode/guidelines/010-approval-gate.md` | ✅ Verified — Line ~216 references nonexistent `analytical-artifacts.md` |
| `.opencode/skills/spec-creation/tasks/create.md` | ✅ Verified — No Step 12.5 (artifacts generated in analyze.md, not create.md) |
| `.opencode/guidelines/065-verification-honesty.md` | ✅ Verified — remediation-first protocol established |

## Not Included

- Changes to the individual spec-audit sub-tasks (investigator, evaluator, validator, arbiter) — only the TDT routing and contract schema are in scope
- Behavioral changes to the backfill task itself — only dispatch documentation
- Changes to `065-verification-honesty.md` — only the audit SKILL.md needs to conform to it

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | 7 hardcoded HALT rows removed from audit SKILL.md TDT. Failure to implement: the self-defeating gate persists — spec-audit cannot execute for any spec without pre-generated artifacts | string | grep for absence of 'HALT' adjacent to missing-artifact triggers in TDT |
| SC-2 | Single catch-all analytical-artifacts-missing row added to TDT. Failure to implement: every missing-artifact scenario still results in HALT instead of remediation | string | grep for 'analytical artifacts missing' or 'generate_first' in TDT |
| SC-3 | REMEDIATION_REQUIRED status documented in sub-agent contract schema. **Root Cause:** without a REMEDIATION_REQUIRED status, sub-agents have no way to signal "I found a problem and here's how to fix it" — they can only BLOCKED/halt. Failure to implement: sub-agents have no way to signal 'problem found, here's how to fix' — they must BLOCKED/halt | string | grep for 'REMEDIATION_REQUIRED' in audit SKILL.md |
| SC-4 | §Mandatory Task Discipline item 5 SHALL distinguish three artifact-missing scenarios: (a) missing at orchestration level → route to retroactive generation, (b) missing discovered by sub-agent → return REMEDIATION_REQUIRED, (c) stale artifacts → HALT. Failure to implement: the skill documentation continues to mandate halt before remediation, violating 065 | string | grep for 'remediation_action' in audit SKILL.md |
| SC-5 | 010-approval-gate.md reference fixed (no broken path to analytical-artifacts.md). **Root Cause:** 010-approval-gate.md references analytical-artifacts.md which was moved into analyze.md — it's a stale reference from an earlier spec-creation pipeline layout. Note: this is enabling cleanup discovered during investigation, not causally required by the 3 core defects. Failure to implement: downstream agents hit a dead file reference, causing confusion and wasted investigation | string | grep for 'analytical-artifacts.md' in 010-approval-gate.md returns empty |
| SC-6 | Orchestrator does not perform inline file-existence checks for artifacts. Failure to implement: orchestrator continues to violate context-lean principle, performing inline file-existence checks | behavioral | Behavioral test: prompt spec audit on spec without artifacts; assert stderr shows sub-agent dispatch, not HALT |
| SC-7 | backfill.md SHALL accept a `mode: retroactive` parameter and generate artifacts when dispatched standalone with {issue_number, project_root} context. **Root Cause:** backfill.md exists but the audit gate never dispatches it — the TDT halts before reaching any dispatch logic. Failure to implement: the remediation path is documented but unreachable — the gate halts before any dispatch | structural | Read backfill.md; confirm dispatch contract accepts mode parameter |
| SC-8 | A spec audit of a spec WITH artifacts SHALL complete the full DiMo chain (Investigator → Validator → Evaluator → Arbiter) and produce a PASS/FAIL verdict. The audit SHALL NOT be aborted or redirected due to artifact presence. Failure to implement: no regression protection — a future change could reintroduce the same self-defeating gate pattern | behavioral | Behavioral test: verify spec audit of a spec WITH artifacts proceeds normally |

### Enforcement Gate

**All SCs (SC-1 through SC-8) MUST pass for the implementation to be considered complete.** Partial implementation does not satisfy this spec. Any SC that cannot be satisfied must be reported as BLOCKED with root cause — the SC must not be removed or weakened.

### Edge Cases

(a) **backfill.md standalone dispatch failure**: If `writing-plans/tasks/backfill.md` does not support the `mode: retroactive` parameter or standalone dispatch with `{issue_number, project_root}` context, this is a BLOCKED upstream dependency. The implementation must HALT and report the blocker — not attempt workarounds.

(b) **Behavioral test harness unavailable**: If the behavioral test harness (`with-test-home` wrapper, standalone `opencode` binary) is not available, SC-6 and SC-8 cannot be executed. This is a pre-condition failure — implementation of those phases must be deferred and reported. The structural/string SCs (SC-1 through SC-5, SC-7) can proceed without behavioral test execution.

(c) **Partial SC failure during implementation**: Per the Enforcement Gate, if any SC cannot be satisfied during any phase, the phase must be reported as BLOCKED with root cause. No SC may be removed or weakened.

## Requirements

1. The audit SKILL.md SHALL replace the 7 individual HALT rows for missing analytical artifacts with a single catch-all that routes to retroactive generation.
2. The audit SKILL.md SHALL define `REMEDIATION_REQUIRED` as a valid status in its sub-agent contract schema.
3. The sub-agent contract SHALL include `remediation_action` and `remediation_context` fields alongside `REMEDIATION_REQUIRED`.
4. §Mandatory Task Discipline item 5 SHALL distinguish missing-at-orchestration (route to retroactive) from missing-at-sub-agent (REMEDIATION_REQUIRED) from stale (HALT).
5. `guidelines/010-approval-gate.md` SHALL fix the reference from `spec-creation/tasks/analytical-artifacts.md` to `writing-plans/tasks/backfill.md`.
6. A behavioral enforcement test SHALL verify that a spec audit with missing artifacts does NOT halt and DOES dispatch retroactive generation.

## Items

1. Replace 7 HALT rows in TDT with single catch-all (SC-1, SC-2)
2. Add REMEDIATION_REQUIRED to contract schema (SC-3)
3. Update Mandatory Task Discipline item 5 (SC-4)
4. Fix 010-approval-gate.md reference — auxiliary cleanup, not core defect (SC-5)
5. Add behavioral test for missing-artifact routing (SC-6)
6. Verify backfill.md standalone dispatch support (SC-7)
7. Add behavioral test for existing-artifact flow (SC-8)

## Dependencies

- `writing-plans/tasks/backfill.md` must be confirmed to support standalone dispatch (SC-7)
- Behavioral test harness (`with-test-home` wrapper) — required for SC-6 and SC-8 behavioral verification

## Traceability

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| R1 — Replace HALT rows | SC-1, SC-2 | 1 |
| R2 — REMEDIATION_REQUIRED status | SC-3 | 2 |
| R3 — Contract schema fields | SC-3 | 2 |
| R4 — Update Mandatory Task Discipline (artifact generation) | SC-4, SC-7 | 3 |
| R5 — Fix approval-gate reference | SC-5 | 4 |
| R6 — Behavioral test | SC-6, SC-8 | 5 |


## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-26 | Added SC-7 to Traceability table (R4 row) | Validation FAIL: SC-7 missing from Traceability table — no requirement maps to it and no phase covers it | Pipeline validation gate |
| 2026-07-26 | Fixed Problem section: analytical-artifacts task location from `tasks/create.md` Step 12.5 to `tasks/analyze.md` Step 5 | Validation FAIL on correctness — actual location verified by reading `tasks/analyze.md` lines 54-64 | Pipeline revision gate |
| 2026-07-26 | Full spec revision: added Executive Summary, Documentation Sources, Cost Frame, Enforcement Gate, root-cause traceability on SC-3/5/7, determinism fixes on SC-4/7/8, behavioral test harness dependency, scope-creep note on approach 4 | Spec audit FAIL — 6 narrow criteria failed — apply ALL 10 bidirectional remediation findings | Pipeline revision gate (spec-creation --task revise) |
| 2026-07-26 | Moved cost-frame prose from standalone section into each SC's criterion text; removed standalone Cost Frame section | Final re-audit FAIL on SC-13: cost-frame prose centralized in separate section instead of embedded per SC | Pipeline revision gate (spec-creation --task revise) |
| 2026-07-26 | Added Edge Cases subsection documenting backfill.md dispatch failure, behavioral test harness unavailability, and partial SC failure edge cases | Audit analytical finding edge_case_discovery: FAIL — spec lacked edge case documentation | Pipeline revision gate (spec-creation --task revise) |
Co-authored with AI: OpenCode (opencode/deepseek-v4-free)
