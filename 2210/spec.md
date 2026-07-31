---
remote_issue: 2210
remote_url: https://github.com/michael-conrad/.opencode/issues/2210
labels: [spec]
---

> **Full spec and artifacts: [`.opencode/.issues/2210/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2210)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2210/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Extract hard-coded structural criteria from spec-audit and plan-fidelity auditor task files into canonical reference documents that both producers and consumers read via `Read [Text](path)`. This eliminates the 36-item misalignment between auditor criteria and pipeline producer templates without adding pipeline ceremony.

## Background

The spec-audit evaluator (Step 5a) hard-codes 14 criteria (SC-1 through SC-14) that check for sections like "Problem statement", "Preamble", "Documentation Sources", "Phases", and "Steps" — but the spec-creation pipeline (`create.md` Step 2) defines a completely different required section set (Objective, Background, Not Included, Requirements, Items, Traceability). The plan-fidelity evaluator hard-codes criteria for admonishments, cost-frame prose, SC gate language, one-step protocol, and delegation — concepts that exist in neither the spec-creation nor writing-plans pipeline definitions.

The root cause is that both the producer task files and the verifier task files define their structural expectations independently. When one changes, the other silently diverges. The fix is to move the canonical definitions into reference documents that both sides read.

This spec is aligned with `.opencode#2176` (pipeline ceremony reduction): it adds no new pipeline steps, no YAML schemas, no manifest write/read operations, and no backward-compat handling. It replaces inline hard-coded lists with a single `Read [Text](path)` directive in each task file.

## Not Included

- Changes to the audit DiMo chain dispatch (investigator → validator → evaluator → arbiter)
- Behavioral enforcement test creation (handled by implementation plan)
- Changes to the solve skill or Z3 constraint solver
- Changes to the approval-gate pipeline
- Changes to the implementation-pipeline SKILL.md or state machine

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `reference/spec-structure-standards.md` exists and declares the canonical spec required sections matching `spec-creation/tasks/create.md` Step 2 | string | diff reference doc sections against create.md Step 2 list |
| SC-2 | `reference/plan-structure-standards.md` exists and declares the canonical plan structure elements matching `writing-plans/tasks/create.md` Steps 4-8 | string | diff reference doc elements against create.md Steps 4-8 |
| SC-3 | `spec-creation/tasks/create.md` Step 2 replaces its inline section list with `Read [spec-structure-standards.md](reference/spec-structure-standards.md)` and assembles the spec against it | string | grep for inline section list removed; grep for Read reference |
| SC-4 | `writing-plans/tasks/create.md` replaces its inline plan structure description (Steps 4-8) with `Read [plan-structure-standards.md](reference/plan-structure-standards.md)` and assembles the plan against it | string | grep for inline structure removed; grep for Read reference |
| SC-5 | `spec-audit/tasks/spec-audit-evaluator.md` Step 5a replaces the hard-coded SC-1 through SC-14 table with `Read [spec-structure-standards.md](reference/spec-structure-standards.md)` and derives criteria from its required sections | string | grep for SC-1 through SC-14 table removed; grep for Read reference |
| SC-6 | `spec-audit/tasks/spec-audit-investigator.md` Step 3 replaces hard-coded section names (Intent and Executive Summary, Documentation Sources, STATUS marker) with `Read [spec-structure-standards.md](reference/spec-structure-standards.md)` and collects evidence against its sections | string | grep for hard-coded section names removed; grep for Read reference |
| SC-7 | `plan-fidelity/tasks/plan-fidelity-evaluator.md` Step 3 replaces hard-coded PF criteria (PF-4, PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-DELEGATION, PF-PRESCRIPTIVE-CODE) with `Read [plan-structure-standards.md](reference/plan-structure-standards.md)` and derives criteria from its elements | string | grep for removed PF criteria; grep for Read reference |
| SC-8 | `plan-fidelity/tasks/plan-fidelity-investigator.md` Steps 2-5 replaces hard-coded evidence collection items (phase descriptions, cross-references, delegation, scope boundary, admonishments, plan scope, gate sequence, verification instructions, Z3 contracts, prescriptive content, cost-frame prose, SC gate language) with `Read [plan-structure-standards.md](reference/plan-structure-standards.md)` and collects evidence against its elements | string | grep for removed evidence collection items; grep for Read reference |
| SC-9 | No new pipeline steps, YAML schemas, manifest write/read operations, or backward-compat handling introduced | string | grep for manifest, schema, backward-compat patterns |
| SC-10 | All 36 hard-coded items from the audit report are removed from the 4 task files | string | grep each of the 36 items across the 4 task files — expect 0 matches |

> **Enforcement gate:** All success criteria must pass before this spec is considered complete. Partial implementation is not permitted.

## Requirements

- REQ-1: `reference/spec-structure-standards.md` created with canonical spec required sections
- REQ-2: `reference/plan-structure-standards.md` created with canonical plan structure elements
- REQ-3: `spec-creation/tasks/create.md` references spec-structure-standards instead of inline section list
- REQ-4: `writing-plans/tasks/create.md` references plan-structure-standards instead of inline structure
- REQ-5: `spec-audit/tasks/spec-audit-evaluator.md` references spec-structure-standards instead of hard-coded SC-1..14
- REQ-6: `spec-audit/tasks/spec-audit-investigator.md` references spec-structure-standards instead of hard-coded section names
- REQ-7: `plan-fidelity/tasks/plan-fidelity-evaluator.md` references plan-structure-standards instead of hard-coded PF criteria
- REQ-8: `plan-fidelity/tasks/plan-fidelity-investigator.md` references plan-structure-standards instead of hard-coded evidence collection
- REQ-9: No new pipeline ceremony introduced

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1, SC-2 | Create `reference/spec-structure-standards.md` and `reference/plan-structure-standards.md` |
| 2 | SC-3 | Update `spec-creation/tasks/create.md` to reference spec-structure-standards |
| 3 | SC-4 | Update `writing-plans/tasks/create.md` to reference plan-structure-standards |
| 4 | SC-5 | Update `spec-audit/tasks/spec-audit-evaluator.md` to reference spec-structure-standards |
| 5 | SC-6 | Update `spec-audit/tasks/spec-audit-investigator.md` to reference spec-structure-standards |
| 6 | SC-7 | Update `plan-fidelity/tasks/plan-fidelity-evaluator.md` to reference plan-structure-standards |
| 7 | SC-8 | Update `plan-fidelity/tasks/plan-fidelity-investigator.md` to reference plan-structure-standards |
| 8 | SC-9, SC-10 | Verify no ceremony added and all 36 hard-coded items removed |

## Dependencies

- None — this spec is self-contained within the .opencode submodule

## Traceability

| Requirement | SC | Phase |
|-------------|----|-------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-2 | SC-2 | Phase 1 |
| REQ-3 | SC-3 | Phase 2 |
| REQ-4 | SC-4 | Phase 3 |
| REQ-5 | SC-5 | Phase 4 |
| REQ-6 | SC-6 | Phase 5 |
| REQ-7 | SC-7 | Phase 6 |
| REQ-8 | SC-8 | Phase 7 |
| REQ-9 | SC-9, SC-10 | Phase 8 |

## Phases

### Phase 1 (REQ-1, REQ-2): Create reference documents

Create `reference/spec-structure-standards.md` and `reference/plan-structure-standards.md`.

**`reference/spec-structure-standards.md`** declares:
- Required sections: Objective, Background, Not Included, Success Criteria (with Evidence Type column), Requirements (numbered SHALL statements), Items (per-SC enumeration), Dependencies, Traceability (Req→SC→Phase table)
- Each section's purpose (one sentence)
- The SC table column requirements (ID, Criterion, Evidence Type, Verification Method)

**`reference/plan-structure-standards.md`** declares:
- Plan frontmatter fields (plan_schema_version, issue, title, dispatch array)
- Plan body structure: phase headings with concern and SC coverage, per-task per-step enumeration from implementation-workflow reference card
- Step format: numbered checkbox with dispatch indicator, context sub-bullets, SC-ID binding
- Pre-implementation steps (coherence gate, baseline check)
- Post-implementation steps (structural checks, verification, audit, cross-validate, review-prep, PR creation, completion)
- Dispatch indicator values and meanings
- Global numbering requirement

**Affected files:**
- `.opencode/reference/spec-structure-standards.md` — new
- `.opencode/reference/plan-structure-standards.md` — new

### Phase 2 (REQ-3): Update spec-creation/create.md

Replace the inline section list in Step 2 (lines 41-48) with:
```
Read [spec-structure-standards.md](reference/spec-structure-standards.md) and assemble the spec against its required sections.
```

**Affected files:**
- `.opencode/skills/spec-creation/tasks/create.md`

### Phase 3 (REQ-4): Update writing-plans/create.md

Replace the inline plan structure description in Steps 4-8 with a reference to the plan-structure-standards doc. The steps still describe the procedure (read artifacts, build frontmatter, build body, write to disk) but the structural expectations (what sections, what format, what dispatch indicators) come from the reference doc.

**Affected files:**
- `.opencode/skills/writing-plans/tasks/create.md`

### Phase 4 (REQ-5): Update spec-audit-evaluator.md

Replace the hard-coded SC-1 through SC-14 table in Step 5a with:
```
Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, check that the spec has that section with the correct content. For each SC in the spec's SC table, verify it has a verification method (SC-2 equivalent), that dependencies are documented (SC-5 equivalent), and that SCs are deterministic (SC-9 equivalent).
```

The three criteria that are not section-presence checks (verification methods, dependencies, determinism) remain as explicit instructions because they are behavioral checks, not structural presence checks.

**Affected files:**
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md`

### Phase 5 (REQ-6): Update spec-audit-investigator.md

Replace the hard-coded section names in Step 3 items 3.5 (Intent and Executive Summary), 3.6 (Documentation Sources), and 3.7 (STATUS marker) with:
```
Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure. Record what is found — do not infer or assume.
```

**Affected files:**
- `.opencode/skills/audit/tasks/spec-audit-investigator.md`

### Phase 6 (REQ-7): Update plan-fidelity-evaluator.md

Replace the hard-coded PF criteria that derive from plan structure (PF-4, PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-DELEGATION, PF-PRESCRIPTIVE-CODE) with:
```
Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, verify the plan has that element with the correct format. The following criteria are not structure-presence checks and remain as explicit instructions: PF-1 (phase coverage), PF-2 (phase ordering), PF-3 (SC coverage), PF-5 (approach consistency), PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-CHECKLIST-FORMAT, PF-DISPATCH-MODE, PF-DISPATCH-DEFECTS, PF-SUBSTEP-EXPAND, PF-GLOBAL-NUMBERING, PF-SEQUENCE-MATCHES.
```

**Affected files:**
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`

### Phase 7 (REQ-8): Update plan-fidelity-investigator.md

Replace the hard-coded evidence collection items in Steps 2-5 that reference non-canonical concepts (phase descriptions, cross-references, delegation, scope boundary, admonishments, plan scope, gate sequence, verification instructions, Z3 contracts, prescriptive content, cost-frame prose, SC gate language) with:
```
Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, collect evidence about its presence, content, and format. Record what is found — do not infer or assume.
```

**Affected files:**
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md`

### Phase 8 (REQ-9): Verify no ceremony added

Verify that no new pipeline steps, YAML schemas, manifest write/read operations, or backward-compat handling were introduced. Verify all 36 hard-coded items from the audit report are removed from the 4 task files.

**Affected files:**
- All 4 task files (verification only)

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Spec-audit evaluator hard-coded criteria | Task file | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` Step 5a | Read at spec creation time |
| Spec-audit investigator hard-coded section names | Task file | `.opencode/skills/audit/tasks/spec-audit-investigator.md` Step 3 | Read at spec creation time |
| Plan-fidelity evaluator hard-coded criteria | Task file | `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` Step 3 | Read at spec creation time |
| Plan-fidelity investigator hard-coded items | Task file | `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` Steps 2-5 | Read at spec creation time |
| Spec-creation producer template | Task file | `.opencode/skills/spec-creation/tasks/create.md` Step 2 | Read at spec creation time |
| Writing-plans producer template | Task file | `.opencode/skills/writing-plans/tasks/create.md` Steps 4-8 | Read at spec creation time |
| Pipeline ceremony reduction spec | Issue | `.opencode/.issues/2176/spec.md` | Read at spec creation time — ensures alignment with ceremony reduction intent |

## Files Affected

- `.opencode/reference/spec-structure-standards.md` — new
- `.opencode/reference/plan-structure-standards.md` — new
- `.opencode/skills/spec-creation/tasks/create.md` — update Step 2
- `.opencode/skills/writing-plans/tasks/create.md` — update Steps 4-8
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` — update Step 5a
- `.opencode/skills/audit/tasks/spec-audit-investigator.md` — update Step 3
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` — update Step 3
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` — update Steps 2-5

## Risks

1. **Reference doc drift**: If a producer task file is updated but the reference doc is not, the reference doc becomes stale. **Mitigation**: The reference doc is the canonical source — the task file says "Read the reference doc." If the reference doc is wrong, the task file produces wrong output. This is the same risk as the current inline lists, but now there is one place to update instead of 5.

2. **Over-correction**: Removing too many criteria from the auditor could reduce audit coverage. **Mitigation**: The spec explicitly preserves criteria that are not structure-presence checks (verification methods, determinism, dependencies, phase coverage, SC coverage, approach consistency, structural fail, Z3 contracts, checklist format, dispatch mode, dispatch defects, sub-step expansion, global numbering, sequence matches).

3. **LLM interpretation variance**: Different LLMs may interpret "derive criteria from the reference doc" differently. **Mitigation**: The task files provide explicit instructions for what to do with the reference doc content ("for each required section, check that the spec has that section"). This is not pseudo-code — it is a natural language directive.

## Edge Cases

1. **Reference doc does not exist yet**: The task file references a doc that must be created in Phase 1. If Phase 1 is skipped, all downstream phases fail. **Resolution**: Phase ordering is enforced by the plan — Phase 1 must complete before any other phase begins.

2. **Existing specs/plans with non-standard structure**: The reference doc defines the canonical structure. Existing artifacts that don't match will fail audit. **Resolution**: This is correct behavior — the audit should catch structural divergence. No backward-compat handling needed.

3. **Multiple reference docs for different spec types**: If spec types diverge (e.g., SPEC vs SPEC-FIX), a single reference doc may not cover both. **Resolution**: This spec covers the standard spec template. If SPEC-FIX needs different sections, a separate reference doc can be added later.

## Alternatives Considered

1. **Manifest approach** (producer writes YAML manifest, verifier reads it): Rejected — adds write step, read step, YAML schema, backward-compat handling, and drift risk. Violates `.opencode#2176` ceremony reduction intent.

2. **Cross-reference comments in task files** (add "if you change this, update the auditor" comments): Rejected — comments are not enforceable and drift silently.

3. **Keep hard-coded criteria but audit them for correctness**: Rejected — the 36-item misalignment proves this doesn't work. Hard-coded criteria in 4 files will diverge again.

4. **Do nothing**: Rejected — the 36-item misalignment is a real defect that causes false PASS verdicts on structurally defective artifacts.

---

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-31 | Initial spec | Created from analysis of 36 hard-coded items across spec-audit and plan-fidelity auditors | OpenCode (deepseek-v4-flash) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
