---
title: "SPEC-FIX: Remediate audit findings from #2020/#2032 — task card section headers, pipeline documents, missing behavioral-sc-evaluator.md"
status: draft
created: 2026-07-22
updated: 2026-07-22
license: MIT
provenance: AI-generated
issue: 2064
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

> **Full spec and artifacts: [`.opencode/.issues/2064/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2064)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2064/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**STATUS:** DRAFT
**CREATED:** 2026-07-22

## Supersession

This spec does NOT supersede any open issue. It remediates audit findings from #2020 (SC-5, SC-7, SC-10) and #2032 (SC-4).

## Core Principle

**Task cards are self-contained inline procedures for sub-agents.** They contain:
- `## Entry Criteria` — what must be true before execution
- `## Procedure` — inline-only steps (no dispatch markers, no `task()` calls)
- `## Exit Criteria` — what the sub-agent produces
- `## Result Contract` — structured return format

**SKILL.md files hold the enumerated workflow entry points** (Trigger Dispatch Table + Invocation). The Pipeline section pattern has been superseded by the TDT + Invocation — these are the enumerated lists the orchestrator uses.

## Problem

An implementation audit of #2020 and #2032 revealed 4 categories of defects:

### Defect A: Missing `## Result Contract` sections (15 + 4 task cards)

The spec required all 4 section headers (`## Entry Criteria`, `## Procedure`, `## Exit Criteria`, `## Result Contract`). Most task cards have the first 3 but are missing `## Result Contract`.

**writing-plans-creation/tasks/ (15 files):**
`artifact-validation.md`, `audit-concern.md`, `audit-fidelity.md`, `clean-room.md`, `completion.md`, `operating-protocol.md`, `pre-plan-readiness.md`, `readiness.md`, `research.md`, `retroactive.md`, `revisit.md`, `solve.md`, `structure.md`, `update.md`, `write.md`

**spec-creation-validation/tasks/ (4 files):**
`completion.md`, `pipeline-readiness-gate.md`, `risk.md`, `traceability.md`

### Defect B: Pipeline documents in task cards (retroactive.md)

`retroactive.md` is a 21-step pipeline document containing `(**sub-agent**)` dispatch markers and `task()` calls. A sub-agent receiving this file cannot execute it — it describes orchestrator-level dispatching. This is the exact pattern #2020 was designed to eliminate.

### Defect C: Dispatch markers in task cards (completion.md, write.md, update.md, audit-concern.md, audit-fidelity.md, solve.md)

These task cards contain `(**sub-agent**)` markers, "Auditor sub-agent" references, or "Sub-agents are leaf nodes" language — all dispatch-level content that belongs in SKILL.md, not in task cards.

### Defect D: Missing behavioral-sc-evaluator.md (#2032 SC-4)

The file `audit/tasks/behavioral-sc-evaluator.md` (file #19 in the 19-file #2032 scope) does not exist on disk. It was specified in #2011 but never created. This is a missing task card that must be created.

### Defect E: Missing Pipeline sections (SC-10)

Neither `writing-plans/SKILL.md` nor `spec-creation/SKILL.md` has a `## Pipeline` section. The #2020 spec assumed these existed. The TDT + Invocation have superseded the Pipeline section pattern — the enumerated entry points are sufficient. This defect is **NOT remediated** — the Pipeline section is intentionally absent and the SC-10 criterion is superseded by the current architecture.

## Scope

### In scope

| Area | Files | Work Required |
|------|-------|--------------|
| Add Result Contract sections | 15 writing-plans-creation + 4 spec-creation-validation task cards | Add `## Result Contract` section to each |
| Fix retroactive.md | `writing-plans-creation/tasks/retroactive.md` | Strip pipeline structure, make self-contained task card |
| Fix dispatch markers | `completion.md`, `write.md`, `update.md`, `audit-concern.md`, `audit-fidelity.md`, `solve.md` | Remove `(**sub-agent**)` markers, "Auditor sub-agent" refs, "leaf nodes" language |
| Create behavioral-sc-evaluator.md | `audit/tasks/behavioral-sc-evaluator.md` | New task card — clean-room evaluation of behavioral test artifacts |
| Verify Pipeline section absence | `writing-plans/SKILL.md`, `spec-creation/SKILL.md` | Confirm TDT + Invocation are sufficient (no Pipeline section needed) |

### Out of scope

- Behavioral tests for the remediated SCs (covered by #2020 SC-25/26/27/28)
- Any changes to SKILL.md Trigger Dispatch Tables or Invocation sections
- Any changes outside the task card files listed above

## Approach

### Phase 1: Add `## Result Contract` sections to 19 task cards

For each of the 15 writing-plans-creation and 4 spec-creation-validation task cards missing `## Result Contract`, append a standard Result Contract section at the end of the file. The section follows the same format used by task cards that already have it:

```markdown
## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/<task-name>.yaml" |
| blocker_reason | "..." |
```

Each task card's Result Contract should reflect the specific artifact it produces (e.g., `artifacts/readiness.yaml`, `artifacts/research.yaml`).

### Phase 2: Fix retroactive.md — strip pipeline structure

Replace the 21-step pipeline with a self-contained procedure. The sub-agent reads the existing spec body, creates a plan, and writes it to disk. No `task()` calls, no `(**sub-agent**)` markers, no Z3 check steps.

### Phase 3: Fix dispatch markers in 6 task cards

For each affected file:
- `completion.md`: Replace `(**sub-agent**)` holistic self-check step with inline procedure
- `write.md`: Replace `(**sub-agent**)` steps with inline procedure descriptions
- `update.md`: Replace `(**sub-agent**)` holistic spec evaluation with inline procedure
- `audit-concern.md`: Remove "Auditor sub-agent type used" language
- `audit-fidelity.md`: Remove "Auditor sub-agent type used" and "clean-room sub-agent" language
- `solve.md`: Remove "Sub-agents are leaf nodes" language

### Phase 4: Create behavioral-sc-evaluator.md

Create `audit/tasks/behavioral-sc-evaluator.md` — a clean-room evaluation task card that:
- Receives only an artifact directory path
- Reads `stdout.log` and `stderr.log` from behavioral test execution
- Renders binary PASS/FAIL per SC
- File-existence alone returns FAIL

### Phase 5: Verify Pipeline section absence

Confirm that `writing-plans/SKILL.md` and `spec-creation/SKILL.md` have no `## Pipeline` section, and that the TDT + Invocation are the correct enumerated entry points. This is a verification-only phase — no file modifications.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 15 writing-plans-creation task cards have `## Result Contract` section | `string` | grep each file — 15/15 present |
| SC-2 | All 4 spec-creation-validation task cards have `## Result Contract` section | `string` | grep each file — 4/4 present |
| SC-3 | `retroactive.md` has no `(**sub-agent**)` markers, no `task()` calls, no Z3 check steps | `string` | grep — 0 matches for all 3 patterns |
| SC-4 | `retroactive.md` has `## Entry Criteria`, `## Procedure`, `## Exit Criteria`, `## Result Contract` | `string` | grep — all 4 sections present |
| SC-5 | `completion.md` has no `(**sub-agent**)` markers | `string` | grep — 0 matches |
| SC-6 | `write.md` has no `(**sub-agent**)` markers | `string` | grep — 0 matches |
| SC-7 | `update.md` has no `(**sub-agent**)` markers | `string` | grep — 0 matches |
| SC-8 | `audit-concern.md` has no "Auditor sub-agent" or "sub-agent type" language | `string` | grep — 0 matches |
| SC-9 | `audit-fidelity.md` has no "Auditor sub-agent", "sub-agent type", or "clean-room sub-agent" language | `string` | grep — 0 matches |
| SC-10 | `solve.md` has no "Sub-agents are leaf nodes" language | `string` | grep — 0 matches |
| SC-11 | `audit/tasks/behavioral-sc-evaluator.md` exists | `string` | `ls` confirms file exists |
| SC-12 | `behavioral-sc-evaluator.md` has `## Entry Criteria`, `## Procedure`, `## Exit Criteria`, `## Result Contract` | `string` | grep — all 4 sections present |
| SC-13 | `behavioral-sc-evaluator.md` receives only artifact directory path (no spec context) | `string` | grep for "artifact" or "artifact_dir" in Entry Criteria — present; grep for "spec" or "issue_number" — 0 matches in Entry Criteria |
| SC-14 | `writing-plans/SKILL.md` has no `## Pipeline` section | `string` | grep — 0 matches (intentional — TDT + Invocation are the entry points) |
| SC-15 | `spec-creation/SKILL.md` has no `## Pipeline` section | `string` | grep — 0 matches (intentional — TDT + Invocation are the entry points) |

## Dependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| #2020 | Parent spec — audit findings remediated here | Implement after #2020 phases complete |
| #2032 | Parent spec — SC-4 remediated here (Phase 4) | Implement after #2032 phases complete |
| #2011 | Specified behavioral-sc-evaluator.md — created here (Phase 4) | Coordinate — #2011 may have additional requirements |

## Labels

`[SPEC-FIX]`, `skill`, `task-card`, `remediation`
