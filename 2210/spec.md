---
remote_issue: 2210
remote_url: https://github.com/michael-conrad/.opencode/issues/2210
labels: [spec]
---

> **Full spec and artifacts: [`.opencode/.issues/2210/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2210)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2210/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Create canonical reference documents (`reference/spec-structure-standards.md` and `reference/plan-structure-standards.md`) that define the required structure for specs and plans. Update the producer templates (`spec-creation/tasks/create.md` and `writing-plans/tasks/create.md`) to read from these reference docs and include all missing required elements identified during the auditor criteria audit.

This is Spec A of a two-spec split. Spec B (`.opencode#2211`) updates the auditor task files to read from the same reference docs.

## Background

The spec-audit and plan-fidelity auditors check for structural criteria that the producer templates never told the plan writer to include. A brainstorming session identified 39 items of misalignment between what producers produce and what auditors check. This spec addresses the producer side: create the canonical reference docs and update the producer templates to include all missing required elements.

The reference docs serve as the single source of truth that both producers and auditors read via `Read [Text](path)`. When the structure changes, one doc is updated and both sides adjust on their next read.

This spec is aligned with `.opencode#2176` (pipeline ceremony reduction): it adds no new pipeline steps, no YAML schemas, no manifest write/read operations, and no backward-compat handling.

## Not Included

- Changes to auditor task files (handled by `.opencode#2211`)
- Changes to the audit DiMo chain dispatch
- Behavioral enforcement test creation
- Changes to the solve skill or Z3 constraint solver
- Changes to the approval-gate pipeline
- Changes to the implementation-pipeline SKILL.md or state machine

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `reference/spec-structure-standards.md` exists and declares the canonical spec required sections: Objective, Background, Not Included, Success Criteria (with Evidence Type column), Requirements (numbered SHALL), Items (per-SC enumeration), Dependencies, Traceability (Req→SC→Phase), Intent and Executive Summary (6 fields: Problem Statement, Root Cause/Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions, User Intent/Original Prompt), Documentation Sources, Enforcement Gate, Cost Frame (per-SC), Edge Cases | string | diff reference doc sections against the resolved item list from the brainstorming session |
| SC-2 | `reference/plan-structure-standards.md` exists and declares the canonical plan structure: three-tier layout (global pre-steps → per-phase daisy-chained items → global post-steps), per-item RED/GREEN/verify/commit daisy chain, dispatch indicators (inline/sub-agent/clean-room), step format (checklist with sub-bullets, no prescriptive code), admonishments (compliance top-only, one-step-at-a-time, step status, self-remediation, enforcement gate), blast radius section, phase file sections (code path coverage, cross-cutting SCs, interface boundaries, state transitions), prohibited patterns (no dispatch tables, no TBD/TODO, no shared cross-references, no zero-indexed, no line numbers, no multi-dispatch steps, no non-standard indicators, no omitted mandatory gates), cost-frame per phase | string | diff reference doc elements against the resolved item list |
| SC-3 | `spec-creation/tasks/create.md` Step 2 replaces its inline section list with `Read [spec-structure-standards.md](reference/spec-structure-standards.md)` and assembles the spec against it. The preamble (6 fields), Documentation Sources, Enforcement Gate, Cost Frame (per-SC), and Edge Cases are added as required sections. | string | grep for inline section list removed; grep for Read reference; grep for each new required section |
| SC-4 | `writing-plans/tasks/create.md` references `plan-structure-standards.md` for structural expectations. The three-tier layout, per-item daisy chain, admonishments (compliance top-only, one-step-at-a-time, step status, self-remediation, enforcement gate), blast radius section, phase file sections (code path, cross-cutting, interface, state), prohibited patterns, and cost-frame per phase are added as required elements. | string | grep for Read reference; grep for each new required element |
| SC-5 | No new pipeline steps, YAML schemas, manifest write/read operations, or backward-compat handling introduced | string | grep for manifest, schema, backward-compat patterns |

> **Enforcement gate:** All success criteria must pass before this spec is considered complete. Partial implementation is not permitted.

## Requirements

- REQ-1: `reference/spec-structure-standards.md` created with canonical spec structure
- REQ-2: `reference/plan-structure-standards.md` created with canonical plan structure
- REQ-3: `spec-creation/tasks/create.md` references spec-structure-standards and includes all missing required sections
- REQ-4: `writing-plans/tasks/create.md` references plan-structure-standards and includes all missing required elements
- REQ-5: No new pipeline ceremony introduced

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Create `reference/spec-structure-standards.md` |
| 2 | SC-2 | Create `reference/plan-structure-standards.md` |
| 3 | SC-3 | Update `spec-creation/tasks/create.md` |
| 4 | SC-4 | Update `writing-plans/tasks/create.md` |
| 5 | SC-5 | Verify no ceremony added |

## Dependencies

- None — this spec is self-contained within the .opencode submodule

## Traceability

| Requirement | SC | Phase |
|-------------|----|-------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-2 | SC-2 | Phase 2 |
| REQ-3 | SC-3 | Phase 3 |
| REQ-4 | SC-4 | Phase 4 |
| REQ-5 | SC-5 | Phase 5 |

## Phases

### Phase 1 (REQ-1): Create spec-structure-standards.md

Create `reference/spec-structure-standards.md` declaring:

**Required sections:**
1. Objective — What this spec achieves
2. Background — Why this spec exists, context, defects being addressed
3. Not Included — Explicitly excluded scope
4. Success Criteria — Table with ID, Criterion, Evidence Type, Verification Method columns
5. Requirements — Numbered requirements with SHALL language
6. Items — Per-SC item enumeration. Each SC maps to exactly one item. Items numbered sequentially from 1.
7. Dependencies — Prerequisite specs, skills, guidelines
8. Traceability — Table mapping Requirements → SCs → Phases
9. Intent and Executive Summary — Preamble with 6 fields: Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions, User Intent / Original Prompt
10. Documentation Sources — Table with Source, Type, Location, Verification columns
11. Enforcement Gate — All-or-nothing statement: all SCs must pass before completion
12. Cost Frame — Per-SC cost-frame language justifying verification costs relative to defect-discovery cost
13. Edge Cases — Boundary conditions, failure modes, and their resolutions

**SC table column requirements:** ID, Criterion, Evidence Type, Verification Method

**Evidence type taxonomy:**
- `structural` → file existence evidence sufficient
- `string` → grep/pattern evidence sufficient
- `semantic` → sub-agent read + judgment evidence sufficient
- `behavioral` → test execution with output inspection required
- EVIDENCE_TYPE_MISMATCH: declared type `behavioral` with only structural evidence → FAIL
- EVIDENCE_TYPE_MISMATCH: declared type `semantic` with only string evidence → FAIL
- Default to `string` if no evidence type declared

**Prohibited content patterns:**
- Tracking/status language: "implemented", "pending", "confirmed", "viable", "completed" → FAIL
- Only forward-looking "MUST be" language permitted
- Prescriptive code: exact file paths with line numbers, exact import strings, exact assertion code → FAIL
- Spec should use file area references only

**Format requirements:**
- Pipeline gates use canonical checklist format: numbered `- [ ] N.` with dispatch mode indicators
- Gate tables (per-unit or shared cross-reference) → FAIL
- If spec defines plan output format requirements, they must use canonical checklist format
- Dispatch tables, shared cross-references → FAIL

**Affected files:**
- `.opencode/reference/spec-structure-standards.md` — new

### Phase 2 (REQ-2): Create plan-structure-standards.md

Create `reference/plan-structure-standards.md` declaring:

**Three-tier plan structure:**
- Tier 1 (Global): Pre-phase steps (coherence gate, baseline check, pre-regression) + post-phase steps (structural checks, verification, audit, regression check, review-prep, PR creation, completion). Appear once per plan.
- Tier 2 (Per-Phase): Phase sections with metadata and daisy-chained per-item tuples.
- Tier 3 (Per-Item): Each item: RED → GREEN → verify → commit. Items are daisy-chained — item N's commit is precondition for item N+1's RED.

**Plan frontmatter:** plan_schema_version, issue, title, dispatch array

**Plan index sections:**
1. Title with issue URL
2. Goal/Architecture/Files/Dispatch
3. Blast Radius — affected files and impact zones from blast radius artifact
4. Admonishment — compliance requirement blockquote (top only)
5. One-step-at-a-time protocol admonishment — verbatim blockquote
6. Step Status instruction — verbatim blockquote with progress reporting format
7. Enforcement Gate — all-or-nothing SC completion statement
8. Phase table — phase number, name, concern, SCs, dependencies, step range, dispatch
9. Self-remediation protocol admonishment — verbatim blockquote
10. Exit Criteria — numbered checklist C1 through C{N}

**Phase file sections:**
1. Title — `# Phase {NN} — {name}`
2. Phase metadata — Concern, Files, SCs, Dependencies, Entry/Exit conditions
3. Code Path Coverage — per-phase code paths from code path inventory artifact
4. Cross-Cutting SCs — cross-cutting SCs from cross-cutting matrix artifact
5. Interface Boundaries — interface boundaries from interface compatibility artifact
6. State Transitions — state transitions from state analysis artifact
7. Step-by-step — checkbox steps with dispatch indicators, daisy-chained per-item tuples
8. Phase completion block — VbC verification assertions
9. Concern transition — to next phase

**Dispatch indicators:**
- `(**inline**)` — orchestrator executes directly
- `(**sub-agent**)` — dispatch via `task()` with phase context
- `(**clean-room**)` — dispatch via `task()` with routing metadata only

**Step format:**
- Numbered checkbox `- [ ] N.` with at least one sub-bullet containing metadata, SC reference, or command
- No step describes more than one atomic action
- RED/GREEN conditions contain no line numbers, exact code, or file paths
- RED describes "what fails". GREEN describes "what must be true"

**Prohibited patterns:**
- No dispatch tables in plan files
- No TBD/TODO — all file paths, function names, commands must be exact
- No shared cross-references — each phase is self-contained
- No zero-indexed numbering — phases start at 1, steps start at 1
- No line number references — use stable anchors
- No multi-dispatch steps — each step dispatches exactly one sub-agent or executes inline
- No non-standard dispatch indicators — only inline, sub-agent, clean-room
- No omitted mandatory gates — all gates from implementation-workflow reference card are mandatory

**Cost frame:** Per-phase cost-frame language justifying verification costs relative to defect-discovery cost

**Affected files:**
- `.opencode/reference/plan-structure-standards.md` — new

### Phase 3 (REQ-3): Update spec-creation/create.md

Replace the inline section list in Step 2 with:
```
Read [spec-structure-standards.md](reference/spec-structure-standards.md) and assemble the spec against its required sections.
```

The preamble (6 fields), Documentation Sources, Enforcement Gate, Cost Frame (per-SC), and Edge Cases are added as required sections. The existing Objective and Background sections are subsumed by the preamble's Problem Statement and Root Cause fields.

**Affected files:**
- `.opencode/skills/spec-creation/tasks/create.md`

### Phase 4 (REQ-4): Update writing-plans/create.md

Replace the inline plan structure description in Steps 4-8 with a reference to plan-structure-standards.md. The steps still describe the procedure (read artifacts, build frontmatter, build body, write to disk) but the structural expectations come from the reference doc.

The three-tier layout, per-item daisy chain, admonishments (compliance top-only, one-step-at-a-time, step status, self-remediation, enforcement gate), blast radius section, phase file sections (code path, cross-cutting, interface, state), prohibited patterns, and cost-frame per phase are added as required elements.

**Affected files:**
- `.opencode/skills/writing-plans/tasks/create.md`

### Phase 5 (REQ-5): Verify no ceremony added

Verify that no new pipeline steps, YAML schemas, manifest write/read operations, or backward-compat handling were introduced.

**Affected files:**
- Verification only

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Brainstorming session resolutions | Discussion | This session | 39 items discussed and resolved |
| Spec-creation producer template | Task file | `.opencode/skills/spec-creation/tasks/create.md` Step 2 | Read at spec creation time |
| Writing-plans producer template | Task file | `.opencode/skills/writing-plans/tasks/create.md` Steps 4-8 | Read at spec creation time |
| Pipeline ceremony reduction spec | Issue | `.opencode/.issues/2176/spec.md` | Read at spec creation time |
| Auditor criteria audit report | Analysis | Prior session output | 36 hard-coded items identified |

## Files Affected

- `.opencode/reference/spec-structure-standards.md` — new
- `.opencode/reference/plan-structure-standards.md` — new
- `.opencode/skills/spec-creation/tasks/create.md` — update Step 2
- `.opencode/skills/writing-plans/tasks/create.md` — update Steps 4-8

## Risks

1. **Reference doc drift**: If a producer task file is updated but the reference doc is not, the reference doc becomes stale. **Mitigation**: The reference doc is the canonical source — the task file says "Read the reference doc." If the reference doc is wrong, the task file produces wrong output. This is the same risk as the current inline lists, but now there is one place to update instead of 5.

2. **Spec B dependency**: `.opencode#2211` depends on these reference docs existing. If this spec is delayed, the auditor updates are blocked. **Mitigation**: These are sequential phases in the overall plan. Spec A must complete before Spec B begins.

3. **LLM interpretation variance**: Different LLMs may interpret "assemble the spec against its required sections" differently. **Mitigation**: The reference doc provides explicit section definitions with purpose statements. The task file provides explicit instruction to read and follow the reference doc.

## Edge Cases

1. **Reference doc does not exist yet**: The task file references a doc that must be created in Phase 1. If Phase 1 is skipped, all downstream phases fail. **Resolution**: Phase ordering is enforced by the plan.

2. **Existing specs/plans with non-standard structure**: The reference doc defines the canonical structure going forward. Existing artifacts that don't match will fail audit. **Resolution**: This is correct behavior — the audit should catch structural divergence.

3. **Multiple reference docs for different spec types**: If spec types diverge (e.g., SPEC vs SPEC-FIX), a single reference doc may not cover both. **Resolution**: This spec covers the standard spec template. If SPEC-FIX needs different sections, a separate reference doc can be added later.

## Alternatives Considered

1. **Manifest approach** (producer writes YAML manifest, verifier reads it): Rejected — adds write step, read step, YAML schema, backward-compat handling, and drift risk. Violates `.opencode#2176` ceremony reduction intent.

2. **Cross-reference comments in task files**: Rejected — comments are not enforceable and drift silently.

3. **Keep hard-coded criteria but audit them for correctness**: Rejected — the 36-item misalignment proves this doesn't work.

4. **Single monolithic spec**: Rejected — split into Spec A (producer side) and Spec B (auditor side) for manageable scope.

---

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-31 | Initial spec | Created from brainstorming session on 39 items of auditor/producer misalignment | OpenCode (deepseek-v4-flash) |
| 2026-07-31 | Revised to Spec A scope | Split from original monolithic spec into producer-side only. Auditor changes moved to `.opencode#2211`. | OpenCode (deepseek-v4-flash) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
