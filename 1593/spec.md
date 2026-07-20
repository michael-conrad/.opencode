> **Full spec and artifacts: [`.opencode/.issues/{N}/`](https://github.com/michael-conrad/.opencode/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

When a pipeline gate (e.g., SC-coherence gate) detects a spec defect and the orchestrator revises the spec to fix it (e.g., updating an unverifiable SC's evidence type or verification method), `approval-gate-006` fires: "Spec revision revokes linked plan approvals." This forces a HALT and requires the user to re-approve the plan — even though the revision was automatic and non-substantive (fixing a verification method, not changing implementation intent).

This creates unnecessary friction: the user already approved the implementation scope, the pipeline found a spec defect autonomously, fixed it, and should be able to continue without re-authorization.

## Root Cause

`010-approval-gate.md` §Revision Revokes Approval (rule `approval-gate-006`) has no carveout for pipeline-initiated non-substantive revisions. The only existing exception is `approval-gate-008` (audit auto-fix for GitHub Issue body formatting), which is too narrow — it covers only `fix_target == 'github-issue-body'` and `fix_non_substantive == true`.

The pipeline executor's remediation routing (pipeline-executor.md) detects spec defects but has no step to auto-revise the spec and auto-update the plan. The writing-plans skill has no `update` task that can diff a revised spec against an existing plan and update only affected sections while preserving approval state.

## Fix

### 1. Add `approval-gate-015` — Pipeline-Initiated Non-Substantive Revision Exception

Add a new rule to `010-approval-gate.md`:

```yaml
- id: approval-gate-015
  tier: 2
  title: "Pipeline-initiated non-substantive spec revisions auto-update plan without re-authorization"
  conditions:
    all:
      - "spec_revised == true"
      - "revision_source == 'pipeline_gate'"
      - "revision_classification == 'non_substantive'"
      - "has_linked_plan == true"
  actions:
    - HALT
    - AUTO_UPDATE_PLAN(writing-plans --task update)
    - PROCEED
```

**Non-substantive** means: changes to evidence types, verification methods, artifact paths, or SC wording that do NOT alter the implementation intent, scope, or success criteria semantics. Substantive changes (new SCs, removed SCs, changed scope, changed implementation approach) still require re-authorization.

Update the prose in §Revision Revokes Approval to add a carveout paragraph.

### 2. Add Plan Update Task to Writing-Plans Skill

Add a new task `update` to `writing-plans/SKILL.md` that:
- Reads the revised spec from the issue body
- Diffs the revised SCs against the existing plan's SCs
- Updates only affected sections (SC verification methods, evidence types, artifact paths)
- Preserves existing approval state (does NOT clear approval markers)
- Returns a result contract with `status: DONE` and `finding_summary`

### 3. Update Pipeline Executor Remediation Routing

In `implementation-pipeline/tasks/pipeline-executor.md`, add a step in the remediation routing section:
- When coherence gate finds a non-substantive spec defect: orchestrator revises spec → auto-updates plan via `writing-plans --task update` → continues pipeline (no HALT for re-authorization)
- When coherence gate finds a substantive spec defect: HALT and report (existing behavior)

### 4. Update Cascade Documentation

In `approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md`, add a note in Step 5b.3 that cascade revocation has an exception for pipeline-initiated non-substantive revisions.

## Affected Files

- `.opencode/guidelines/010-approval-gate.md` — add `approval-gate-015` rule + prose carveout
- `.opencode/skills/writing-plans/SKILL.md` — add `update` task to trigger dispatch table
- `.opencode/skills/writing-plans/tasks/update.md` — new task file for plan update
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` — add auto-revision routing step
- `.opencode/skills/approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md` — add exception note

## Scope

### In Scope
- New `approval-gate-015` rule in guidelines
- New `update` task in writing-plans skill
- Pipeline executor remediation routing update
- Cascade documentation update

### Out of Scope
- Behavioral enforcement tests for the new rule (separate spec)
- Changes to any other pipeline gates beyond the coherence gate
- Changes to the approval-gate skill's dispatch table
- Any behavioral changes to existing approval-gate-006 behavior for substantive revisions

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `010-approval-gate.md` contains `approval-gate-015` rule with pipeline-initiated non-substantive revision exception | `string` | `grep 'approval-gate-015' .opencode/guidelines/010-approval-gate.md` returns a match |
| SC-2 | `010-approval-gate.md` prose §Revision Revokes Approval contains carveout paragraph for pipeline-initiated non-substantive revisions | `string` | `grep -i 'pipeline.initiated\|non.substantive' .opencode/guidelines/010-approval-gate.md` returns a match |
| SC-3 | `writing-plans/SKILL.md` trigger dispatch table includes `update` task | `string` | `grep '"update"' .opencode/skills/writing-plans/SKILL.md` returns a match |
| SC-4 | `writing-plans/tasks/update.md` exists and contains plan update procedure that preserves approval state | `structural` | `ls .opencode/skills/writing-plans/tasks/update.md` succeeds |
| SC-5 | `pipeline-executor.md` contains auto-revision routing step for non-substantive spec defects | `string` | `grep -i 'non.substantive\|auto.revision\|auto.update' .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` returns a match |
| SC-6 | `spec-to-plan-cascade.md` contains exception note for pipeline-initiated non-substantive revisions | `string` | `grep -i 'pipeline.initiated\|non.substantive' .opencode/skills/approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md` returns a match |
| SC-7 | No other files modified beyond the 5 affected files | `string` | `git diff --name-only -- .opencode/` shows exactly 5 files changed |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Non-substantive classification uses intent-based test | Changes to evidence types, verification methods, artifact paths, or SC wording that don't alter implementation intent are non-substantive. New/removed SCs or changed scope are substantive. | MUST | SC-1, SC-2 |
| DEC-2 | Plan update preserves approval state rather than clearing it | The revision is automatic and non-substantive — the user already approved the implementation scope. Clearing approval would force unnecessary re-authorization. | MUST | SC-3, SC-4 |
| DEC-3 | Pipeline executor routes auto-revision, not the coherence gate | The coherence gate detects and reports; the pipeline executor (orchestrator-level) decides whether to auto-revise or HALT. Keeps detection and remediation separate. | MUST | SC-5 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Non-substantive classification is subjective and may be misapplied | Medium | Medium | Clear definition in rule prose; adversarial audit can flag misclassification | SC-1 |
| RISK-2 | Plan update task may introduce inconsistencies between spec and plan | Low | Medium | Task diffs revised SCs against plan SCs; only updates affected sections | SC-4 |
| RISK-3 | Existing approval-gate-006 behavior may be accidentally weakened | Low | High | New rule is additive (carveout), not a replacement; substantive revisions still require re-authorization | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |

## Decomposition Classification

| Classification | Value |
| -------------- | ----- |
| Type | multi-task |
| Number of Phases | 4 |
| Sub-Issue Requirements | Per-phase |
| PR Strategy | stacked |

## Phases

### Phase 1 — guideline-exception
**Concern:** Add `approval-gate-015` rule and prose carveout to `010-approval-gate.md`.
**Files:** `.opencode/guidelines/010-approval-gate.md`
**SCs:** SC-1, SC-2

### Phase 2 — plan-update-task
**Concern:** Add `update` task to writing-plans skill with plan update procedure that preserves approval state.
**Files:** `.opencode/skills/writing-plans/SKILL.md`, `.opencode/skills/writing-plans/tasks/update.md`
**SCs:** SC-3, SC-4

### Phase 3 — pipeline-executor-routing
**Concern:** Add auto-revision routing step to pipeline executor remediation section.
**Files:** `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`
**SCs:** SC-5

### Phase 4 — cascade-docs
**Concern:** Add exception note to spec-to-plan-cascade.md.
**Files:** `.opencode/skills/approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md`
**SCs:** SC-6, SC-7

## Regression Invariants

1. Substantive spec revisions (new/removed SCs, changed scope) MUST still trigger `approval-gate-006` and require re-authorization.
2. The existing `approval-gate-008` (audit auto-fix) exception MUST remain unchanged.
3. All existing plan approval state MUST be preserved during non-substantive plan updates.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source read | `010-approval-gate.md` §Revision Revokes Approval | Confirm `approval-gate-006` rule text and prose |
| Direct source read | `approval-gate/SKILL.md` dispatch table | Confirm no existing exception for pipeline-initiated revisions |
| Direct source read | `implementation-pipeline/tasks/pipeline-executor.md` remediation routing | Confirm no auto-revision step exists |
| Direct source read | `writing-plans/SKILL.md` trigger dispatch table | Confirm no `update` task exists |
| Direct source read | `approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md` | Confirm no exception note exists |
| Live observation | SC-coherence gate on #1585 | Confirmed the gap: coherence gate found SC-2 defect, spec was revised, plan approval revoked, user had to re-approve |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)