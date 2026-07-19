---
title: "[SPEC-FIX] writing-plans workflow defects: missing TDT, contract paths, orphaned tasks, dispatch routing"
status: draft
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 1962
authors:
  - OpenCode (nemotron-3-ultra-free)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-19

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The `writing-plans` skill and its sub-skill `writing-plans-creation` have multiple structural defects that prevent correct workflow execution:

1. **`writing-plans-creation` missing Trigger Dispatch Table** — 11 pipeline steps in `create.md` have no TDT entries, making them undispatchable via `skill()`/`task()`
2. **`writing-plans` parent TDT incomplete** — Only 3 high-level entries (`create`, `update`, `holistic-self-check`) but `create.md` defines 11+ pipeline steps needing individual dispatch
3. **Contract paths incorrect** — `create.md` references `.opencode/skills/writing-plans/contracts/` but actual contracts are at `.opencode/skills/writing-plans-creation/contracts/`
4. **Orphaned task** — `pre-plan-readiness.md` exists in task list but not in any TDT
5. **`retroactive.md` not directly dispatchable** — Has its own pipeline but no TDT entry
6. **`clean-room.md` only reachable via audit skill** — No direct dispatch path
7. **Missing canonical dispatch strings** — `writing-plans` Invocation section lacks step-level dispatch strings per DISPATCH_GATE protocol

Additionally, issue #1962 requires `create` to dispatch through `plan-creation-pipeline` with Z3 gates instead of bare inspection — this fix must be incorporated.

## Root Cause Analysis

The dispatcher pattern (parent skill routes, sub-skill contains tasks) was implemented incompletely:

- `spec-creation` skill correctly has parent `spec-creation` with TDT routing to sub-skills (`spec-creation-validation`, `spec-creation-decomposition`, etc.)
- `writing-plans` skill adopted the pattern but **failed to complete it**: parent TDT only has high-level entries, sub-skill `writing-plans-creation` has **zero** TDT entries
- `implementation-pipeline` skill demonstrates the correct pattern: 29 step-level TDT entries with canonical dispatch strings

The contract path error stems from copying the `spec-creation` pattern where contracts live in the sub-skill (`spec-creation-decomposition/contracts/`), but the `create.md` references were never updated to the correct sub-skill path.

## Goals

- [ ] G1: `writing-plans` TDT has entries for all 11 pipeline steps from `create.md`
- [ ] G2: `writing-plans-creation` has complete TDT with all 16 tasks
- [ ] G3: All contract paths in `create.md` resolve to existing files
- [ ] G4: `create` task dispatches to `plan-creation-pipeline` with Z3 gates (per #1962)
- [ ] G5: `pre-plan-readiness` has `solve` readiness gate (per #1962)
- [ ] G6: `retroactive.md` and `clean-room.md` have TDT entries
- [ ] G7: All canonical dispatch strings follow DISPATCH_GATE format

## Non-Goals

- **Rewriting pipeline logic** — Pipeline step procedures in `create.md`, `retroactive.md` remain unchanged except for contract paths and #1962 fixes
- **Modifying task file internals** — Only dispatch routing and contract paths change
- **Changing skill boundaries** — `writing-plans`, `writing-plans-creation`, `writing-plans-holistic` remain as-is

## Constraints and Scope

**In Scope:**
- `writing-plans/SKILL.md` — TDT and Invocation sections
- `writing-plans-creation/SKILL.md` — Add TDT and Invocation sections
- `writing-plans-creation/tasks/create.md` — Contract path fixes, #1962 integration
- `writing-plans-creation/tasks/pre-plan-readiness.md` — Add solve readiness gate

**Out of Scope:**
- Other writing-plans-creation task files (no code changes needed)
- writing-plans-holistic skill (already correct)
- Implementation-pipeline skill (reference pattern only)

## Safety Considerations

- **No destructive operations** — Only skill metadata and task file references modified
- **No database/schema changes** — Pure configuration/routing updates
- **Rollback:** `git revert` on the three skill files if issues arise
- **Data loss risk:** None — no data files modified

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Move contracts to `writing-plans/contracts/` for backward compatibility | Directory doesn't exist; creates phantom infrastructure; violates "contracts live in task-owning skill" pattern |
| Merge `writing-plans-creation` into `writing-plans` | Breaks dispatcher pattern; violates single-responsibility; contradicts `spec-creation` architecture |
| Add TDT to `writing-plans` only (skip sub-skill TDT) | Sub-skill needs its own TDT for direct dispatch capability; pattern requires both |
| Use symlinks for contract paths | Symlinks break in containers/CI; not portable; violates explicit path principle |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| `writing-plans-creation` has 16 task files, 0 TDT entries | `ls .opencode/skills/writing-plans-creation/tasks/` + `read(SKILL.md)` |
| Contract files at `writing-plans-creation/contracts/` | `ls .opencode/skills/writing-plans-creation/contracts/` |
| `create.md` references `writing-plans/contracts/` | `grep "writing-plans/contracts" create.md` (11 matches) |
| `implementation-pipeline` has 29 TDT entries | `read(SKILL.md)` lines 45-78 |
| `spec-creation` parent routes to sub-skills | `read(SKILL.md)` lines 30-40 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `writing-plans` TDT has entries for all 11 pipeline steps | structural | `read` SKILL.md → count TDT rows matching create.md steps | Add missing TDT rows | spec-creation | `.opencode/skills/writing-plans/SKILL.md` | G1 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-2 | `writing-plans-creation` TDT has entries for all 16 tasks | structural | `read` SKILL.md → count TDT rows | Add TDT section to SKILL.md | spec-creation | `.opencode/skills/writing-plans-creation/SKILL.md` | G2 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-3 | All 11 contract paths in `create.md` resolve to existing files | structural | `bash` check each path exists | Fix paths in create.md | spec-creation | `.opencode/skills/writing-plans-creation/tasks/create.md` | G3 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-4 | `create` task dispatches to `plan-creation-pipeline` with Z3 gates | behavioral | `opencode run` → verify skill dispatch in stderr | Update TDT create entry | spec-creation | `.opencode/skills/writing-plans/SKILL.md` | G4, #1962 | single-task | pre-approval-gate | sub-agent | writing-plans | spec-creation | N/A | Phase 1 |
| SC-5 | `pre-plan-readiness` has `solve` readiness gate | structural | `read` pre-plan-readiness.md → find solve check | Add solve check step | spec-creation | `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` | G5, #1962 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-6 | `retroactive.md` has TDT entry for "retroactive plan" trigger | structural | `read` writing-plans-creation SKILL.md → find retroactive row | Add TDT row | spec-creation | `.opencode/skills/writing-plans-creation/SKILL.md` | G6 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-7 | `clean-room.md` has TDT entry for "clean-room plan" trigger | structural | `read` writing-plans-creation SKILL.md → find clean-room row | Add TDT row | spec-creation | `.opencode/skills/writing-plans-creation/SKILL.md` | G6 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-8 | All canonical dispatch strings follow DISPATCH_GATE format | structural | `read` both SKILL.md Invocation sections → verify format | Fix format in Invocation | spec-creation | Both SKILL.md files | G7 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-9 | No orphaned tasks in `writing-plans-creation/tasks/` | structural | `ls tasks/` vs TDT entries → diff empty | Add missing TDT entries | spec-creation | Both SKILL.md files | G1, G2, G6 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |

## Cross-Cutting SCs

SC-1, SC-2, SC-3, SC-8, SC-9 — Verified once in Phase 1, applies to all subsequent phases.

## Risk and Edge Cases

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Contract path fix breaks existing Z3 checks | Low | High | Run `solve check` on all contracts after fix | SC-3 |
| RISK-2 | TDT entries conflict with existing high-level entries | Low | Medium | Use distinct trigger phrases for step-level vs high-level | SC-1, SC-2 |
| RISK-3 | `plan-creation-pipeline` dispatch changes create behavior | Medium | High | Behavioral test per SC-4 before implementation | SC-4 |
| RISK-4 | Missing `solve` readiness gate causes pipeline to proceed without validation | Medium | High | Add explicit solve check step in pre-plan-readiness | SC-5 |

## Implementation Approach

**Phase 1 (single spec, single plan):**
1. Update `writing-plans/SKILL.md` — TDT with 11 step entries + 3 high-level, Invocation with canonical strings
2. Update `writing-plans-creation/SKILL.md` — Add TDT with 16 entries, Invocation with canonical strings  
3. Update `writing-plans-creation/tasks/create.md` — Fix 11 contract paths, replace feasibility step with plan-creation-pipeline dispatch, add solve gate reference
4. Update `writing-plans-creation/tasks/pre-plan-readiness.md` — Add solve readiness gate
5. Run `local-issues sync` after each file change
6. Run `solve check` on all affected contracts
7. Self-review per spec-creation-validation Step 33-35

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1962](https://github.com/michael-conrad/.opencode/issues/1962) | SUPERSEDES | This spec supersedes #1962 by incorporating its fixes plus comprehensive workflow remediation |
| [#1311](https://github.com/michael-conrad/.opencode/issues/1311) | RELATED | Plan writer must dispatch to implementation skills — related dispatch pattern |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("writing-plans")` | Locate skill files |
| Direct source search | `grep -r "writing-plans/contracts" .opencode/skills/` | Find contract path references |
| Local docs | `.opencode/skills/implementation-pipeline/SKILL.md` | Reference TDT pattern |
| Local docs | `.opencode/skills/spec-creation/SKILL.md` | Reference dispatcher pattern |
| Live verification | `ls .opencode/skills/writing-plans-creation/contracts/` | Verify contract directory exists |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Fix contract paths in create.md (not symlink) | Explicit paths required; symlinks non-portable | MUST | SC-3 |
| DEC-2 | Add TDT to both parent and sub-skill | Dispatcher pattern requires both | MUST | SC-1, SC-2 |
| DEC-3 | Step-level TDT entries use distinct triggers | Prevent conflict with high-level entries | MUST | SC-1, SC-2 |
| DEC-4 | clean-room classified as clean-room dispatch | Task bypasses approval, no existing plan reference | MUST | SC-7 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Spec Family Annotation

family: writing-plans-workflow-fix
selectors:
  - spec: #1962
  - spec: glob(pattern: ".opencode/skills/writing-plans*/SKILL.md")

## Explicit Non-Goals

- **Rewriting pipeline step logic** — Pipeline procedures unchanged except contract paths and #1962 integration
- **Modifying other skills** — Only writing-plans and writing-plans-creation skills affected
- **Changing skill boundaries** — Three-skill structure maintained

## Regression Invariants

- [ ] 1. Existing `create`, `update`, `holistic-self-check` high-level triggers still work
- [ ] 2. `writing-plans-holistic` skill unaffected
- [ ] 3. `implementation-pipeline` skill dispatch patterns unchanged
- [ ] 4. `spec-creation` dispatcher pattern unchanged

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)