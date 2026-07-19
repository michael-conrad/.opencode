---
title: writing-plans skill holistic remediation — 9 defect categories
status: 1.1 (REVISED - NEEDS APPROVAL)
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 2004
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** 1.1 (REVISED - NEEDS APPROVAL)
**CREATED:** 2026-07-19
**REVISED:** 2026-07-19

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The writing-plans skill (parent dispatcher at `skills/writing-plans/SKILL.md`, sub-skills at `skills/writing-plans-creation/` and `skills/writing-plans-holistic/`) has accumulated 9 categories of structural defects that mirror the #1993 remediation pattern already applied to spec-creation. These defects cause incorrect agent dispatch, dead code, phantom infrastructure references, and drift-prone cross-references.

## Root Cause Analysis

The writing-plans skill was split into sub-skills (writing-plans-creation, writing-plans-holistic) during the Phase 5 restructuring, but the remediation pattern from #1993 (remove fake dispatch entries, move pipeline to SKILL.md, delete operating-protocol.md, fix artifact extensions, remove task()/skill() from task cards) was never applied to writing-plans. The spec-creation skill received the full #1993 treatment; writing-plans retained all 9 defect categories.

## Objectives

Apply the #1993 remediation pattern to writing-plans: remove fake dispatch entries, move pipeline definition to SKILL.md, delete operating-protocol.md, fix artifact extension mismatches, remove task()/skill() calls from task cards, add contract index, fix pipeline numbering, remove orphan handoffs/spec-to-plan dispatch, fix {project_root}/tmp/ references, and replace hard-coded counts with Load [Text](path) references.

## Non-Goals

- **Behavioral changes to the pipeline** — The pipeline steps themselves (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion) remain unchanged. Only their routing and documentation are remediated.
- **Changes to writing-plans-holistic** — The holistic sub-skill is already clean; no changes needed.
- **Changes to plan format or content** — The plan model (index + phase files) is unchanged.

## Alternatives Considered & Why Discarded

- **Full rewrite of writing-plans** — Discarded. The pipeline steps are correct; only the routing infrastructure and documentation need remediation. A full rewrite would introduce unnecessary risk.
- **Defer to a separate spec** — Discarded. All 9 defects share the same root cause (missing #1993 remediation) and are most efficiently fixed in a single pass.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1993](https://github.com/michael-conrad/.opencode/issues/1993) | RELATED | Original spec-creation remediation that established the pattern being applied here |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Trigger Dispatch Table in `writing-plans/SKILL.md` contains only 3 real workflow entry points: `create`, `update`, `holistic-self-check`. Entries for `retroactive`, `handoffs/spec-to-plan`, `pre-plan-readiness`, and `completion` are removed. | `string` | `grep '| \`' skills/writing-plans/SKILL.md | grep -c 'sub-task'` — verify exactly 3 dispatch entries | Remove 4 fake entries; move `completion` to Invocation-only | Phase 1 | `skills/writing-plans/SKILL.md` | #1993 pattern: remove fake dispatch entries | Phase 1 | pre-commit | string | — | — | — | Phase 1 |
| SC-2 | Invocation section in `writing-plans/SKILL.md` contains dispatch strings for all 3 real entry points plus `completion` (4 total). No dispatch strings for removed entries. | `string` | `grep -c 'task(..., prompt:' skills/writing-plans/SKILL.md` — verify exactly 4 dispatch strings | Update Invocation table to match reduced dispatch set | Phase 1 | `skills/writing-plans/SKILL.md` | #1993 pattern: clean Invocation table | Phase 1 | pre-commit | string | — | — | — | Phase 1 |
| SC-3 | No `task()` or `skill()` calls remain in any task card under `writing-plans-creation/tasks/` or `writing-plans-holistic/tasks/`. | `string` | `grep -rn 'task()\|skill()' skills/writing-plans-*/tasks/ --include='*.md'` — verify zero matches | Remove `task()`/`skill()` references from `clean-room.md`, `validate.md`, `write.md` | Phase 1 | `skills/writing-plans-*/tasks/*.md` | #1993 pattern: remove task()/skill() from task cards | Phase 1 | pre-commit | string | — | — | — | Phase 1 |
| SC-4 | Pipeline definition is moved from `create.md` to `writing-plans/SKILL.md`. The SKILL.md contains a Pipeline section with the full step list, dispatch mode, and contract table. | `string` | Verify `skills/writing-plans/SKILL.md` contains a Pipeline section with step list; verify `create.md` references the SKILL.md pipeline | Move pipeline steps 1-22 from `create.md` to SKILL.md; add Pipeline section to SKILL.md | Phase 1 | `skills/writing-plans/SKILL.md`, `skills/writing-plans-creation/tasks/create.md` | #1993 pattern: move pipeline to SKILL.md | Phase 1 | pre-commit | string | — | — | — | Phase 1 |
| SC-5 | `operating-protocol.md` task card is deleted; its content is either moved to SKILL.md or replaced with a Load [Text](path) reference. | `structural` | Verify `operating-protocol.md` no longer exists; verify SKILL.md contains the operating protocol content | Delete `operating-protocol.md`; move content to SKILL.md | Phase 1 | `skills/writing-plans-creation/tasks/operating-protocol.md` | #1993 pattern: delete operating-protocol.md | Phase 1 | pre-commit | structural | — | — | — | Phase 1 |
| SC-6 | 22 contract templates in `contracts/` have an index file (`contracts/INDEX.md`) mapping each template to its consuming pipeline step. | `structural` | Verify `contracts/INDEX.md` exists with entries for all 22 templates | Create `contracts/INDEX.md` with template-to-step mapping | Phase 2 | `skills/writing-plans-creation/contracts/INDEX.md` | #1993 pattern: contract index | Phase 2 | pre-commit | structural | — | — | — | Phase 2 |
| SC-7 | Artifact extension mismatch fixed: `pre-plan-readiness.md` and `handoffs/spec-to-plan.md` reference analytical artifacts as `.yaml` (not `.md`). | `string` | `grep -c '\.yaml' skills/writing-plans-creation/tasks/pre-plan-readiness.md` — verify `.yaml` references for analytical artifacts | Change `blast-radius.md` → `blast-radius.yaml` (and all 6 others) in both files | Phase 2 | `skills/writing-plans-creation/tasks/pre-plan-readiness.md`, `skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md` | Analytical artifacts are stored as `.yaml` by spec-creation | Phase 2 | pre-commit | string | — | — | — | Phase 2 |
| SC-8 | Pipeline numbering is consistent: SKILL.md and create.md both reference the same step count. | `string` | Verify SKILL.md and create.md agree on step count | Change SKILL.md "22-step" to "21-step" (matching create.md's 21-step pipeline) OR update create.md to match SKILL.md | Phase 2 | `skills/writing-plans/SKILL.md`, `skills/writing-plans-creation/tasks/create.md` | #1993 pattern: fix numbering mismatch | Phase 2 | pre-commit | string | — | — | — | Phase 2 |
| SC-9 | `handoffs/spec-to-plan` dispatch entry is removed from Trigger Dispatch Table. The `handoffs/spec-to-plan.md` task card is either deleted or its content merged into `pre-plan-readiness.md`. | `structural` | Verify no dispatch entry for `handoffs/spec-to-plan` in SKILL.md; verify `handoffs/spec-to-plan.md` is deleted or merged | Remove dispatch entry; delete or merge task card | Phase 2 | `skills/writing-plans/SKILL.md`, `skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md` | Duplicates pre-plan-readiness; never dispatched | Phase 2 | pre-commit | structural | — | — | — | Phase 2 |
| SC-10 | No `{project_root}/tmp/` references remain in any task card under `writing-plans-creation/tasks/`. | `string` | `grep -rn '{project_root}/tmp/' skills/writing-plans-*/tasks/ --include='*.md'` — verify zero matches | Replace `{project_root}/tmp/` paths with `.issues/{N}/` paths in `clean-room.md` and `handoffs/spec-to-plan.md` | Phase 2 | `skills/writing-plans-creation/tasks/clean-room.md`, `skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md` | Phantom infrastructure — no tmp/ contract system exists | Phase 2 | pre-commit | string | — | — | — | Phase 2 |
| SC-11 | Hard-coded step counts and contract paths in cross-references are replaced with `Load [Text](path)` references or relative references. | `string` | `grep -rn '21-step\|22-step\|create-output-template' skills/writing-plans-*/tasks/ --include='*.md'` — verify no hard-coded counts | Replace "21-step pipeline" with `Load [Pipeline](skills/writing-plans/SKILL.md)`; replace contract paths with `Load [contracts](contracts/INDEX.md)` | Phase 2 | All task cards under `writing-plans-creation/tasks/` | Hard-coded counts drift when pipeline changes | Phase 2 | pre-commit | string | — | — | — | Phase 2 |
| SC-12 | Behavioral enforcement test exists verifying the agent dispatches only 3 workflow entry points (create, update, holistic-self-check) from writing-plans, not 7. | `behavioral` | `bash .opencode/tests-v2/behaviors/writing-plans-dispatch.sh` — verify PASS | Create behavioral test in `.opencode/tests-v2/behaviors/writing-plans-dispatch.sh` | Phase 3 | `.opencode/tests-v2/behaviors/writing-plans-dispatch.sh` | Behavioral RED/GREEN gate | Phase 3 | pre-commit | behavioral | — | — | — | Phase 3 |
| SC-13 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. | `string` | `git diff HEAD -- skills/writing-plans-*/tasks/ --include='*.md' | grep -E '\-(SC-\d+|behavioral|structural|string)'` — verify no SC body was shortened or evidence type downgraded | N/A — enforced by existing anti-lobotomization guidelines | All phases | N/A | Anti-lobotomization mandate | All phases | pre-commit | string | — | — | — | All phases |
| SC-14 | All cross-references in writing-plans task cards use `Load [Text](path)` format. No bare paths or backtick-only references remain. | `string` | `grep -rn 'skills/\|guidelines/\|contracts/' skills/writing-plans-*/tasks/ --include='*.md' \| grep -v 'Load \['` — verify zero bare-path references | Replace bare paths and backtick references with `Load [Text](path)` format | Phase 2 | All task cards under `writing-plans-creation/tasks/` | Cross-references must use Load [Text](path) per AGENTS.md | Phase 2 | pre-commit | string | — | — | — | Phase 2 |

## Risk and Edge Cases

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Removing dispatch entries breaks existing callers that reference `retroactive` or `completion` by name | Medium | High | Verify no external callers reference removed dispatch names; `completion` remains in Invocation section | SC-1, SC-2 |
| RISK-2 | Pipeline numbering change (22→21) causes confusion if external docs reference "22-step" | Low | Medium | Update all cross-references in the same commit | SC-8, SC-11 |
| RISK-3 | Deleting `handoffs/spec-to-plan.md` loses content that should be merged into `pre-plan-readiness.md` | Medium | Medium | Merge content before deletion; verify no data loss | SC-9 |

## Implementation Approach

### Phase 1: SKILL.md restructuring (SC-1 through SC-5)
- Remove 4 fake dispatch entries from Trigger Dispatch Table
- Update Invocation section
- Remove task()/skill() from task cards
- Move pipeline definition to SKILL.md
- Delete operating-protocol.md

### Phase 2: Artifact and reference cleanup (SC-6 through SC-11, SC-14)
- Create contract index
- Fix artifact extension mismatches
- Fix pipeline numbering
- Remove/handle orphan handoffs/spec-to-plan
- Fix {project_root}/tmp/ references
- Replace hard-coded counts with Load [Text](path)

### Phase 3: Behavioral enforcement (SC-12)
- Create behavioral test verifying reduced dispatch set

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `skills/writing-plans/SKILL.md` | Verify Trigger Dispatch Table entries |
| Direct source search | `skills/writing-plans-creation/tasks/*.md` | Verify task()/skill() calls in task cards |
| Direct source search | `skills/writing-plans-creation/contracts/` | Count contract templates |
| Direct source search | `skills/spec-creation/SKILL.md` | Reference #1993 remediation pattern |

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
