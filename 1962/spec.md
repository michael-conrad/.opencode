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

1. **`writing-plans-creation` missing Trigger Dispatch Table** — Pipeline steps in `create.md` have no TDT entries, making them undispatchable via `skill()`/`task()`
2. **`writing-plans` parent TDT incomplete** — Only 3 high-level entries but `create.md` defines 11+ pipeline steps needing individual dispatch
3. **Contract paths incorrect** — `create.md` references `.opencode/skills/writing-plans/contracts/` but actual contracts are at `.opencode/skills/writing-plans-creation/contracts/`
4. **Orphaned task** — `pre-plan-readiness.md` exists in task list but not in any TDT
5. **`retroactive.md` not directly dispatchable** — Has its own pipeline but no TDT entry
6. **`clean-room.md` only reachable via audit skill** — No direct dispatch path
7. **Missing canonical dispatch strings** — `writing-plans` Invocation section lacks step-level dispatch strings per DISPATCH_GATE protocol
8. **`writing-plans-creation` description implies direct dispatchability** — The SKILL.md description says "Load via skill() when creating an implementation plan..." but it is a task container, not a dispatchable skill. Task containers should describe what they CONTAIN, not how to invoke them.

Additionally, the `create` workflow must dispatch through `plan-creation-pipeline` with Z3 gates instead of bare inspection — this fix must be incorporated.

## Root Cause Analysis

The dispatcher pattern (parent skill routes, sub-skill contains tasks) was implemented incompletely:

- `spec-creation` skill correctly has parent `spec-creation` with TDT routing to sub-skills (`spec-creation-validation`, `spec-creation-decomposition`, etc.)
- `writing-plans` skill adopted the pattern but **failed to complete it**: parent TDT only has high-level entries, sub-skill `writing-plans-creation` has **zero** TDT entries
- `implementation-pipeline` skill demonstrates a different pattern (orchestrator with step-level TDT) — not the dispatcher pattern

The contract path error stems from copying the `spec-creation` pattern where contracts live in the sub-skill (`spec-creation-decomposition/contracts/`), but the `create.md` references were never updated to the correct sub-skill path.

## Goals

- [ ] G1: `writing-plans` TDT has exactly 4 user-facing workflow entries (`create`, `update`, `retroactive`, `holistic-self-check`)
- [ ] G2: `writing-plans` Pipeline section documents all workflows with step-level dispatch classification
- [ ] G3: `writing-plans-creation` is a task card (not a skill card) — no YAML frontmatter, no "Skill:" header, no TDT, no Invocation. Plain markdown file listing tasks.
- [ ] G4: All contract paths in `create.md`, `update.md`, `retroactive.md` resolve to existing files
- [ ] G5: `create` workflow dispatches to `plan-creation-pipeline` with Z3 gates
- [ ] G6: `pre-plan-readiness` has `solve` readiness gate
- [ ] G7: All canonical dispatch strings follow DISPATCH_GATE format in Invocation
- [ ] G8: No orphaned tasks in `writing-plans-creation/tasks/`

## Non-Goals

- **Rewriting pipeline logic** — Pipeline step procedures in `create.md`, `update.md`, `retroactive.md` remain unchanged except for contract paths and plan-creation-pipeline integration
- **Modifying task file internals** — Only dispatch routing and contract paths change
- **Changing skill boundaries** — `writing-plans`, `writing-plans-creation`, `writing-plans-holistic` remain as-is

## Constraints and Scope

**In Scope:**
- `writing-plans/SKILL.md` — TDT (4 entries), Pipeline section (4 workflows), Invocation (4 entries)
- `writing-plans-creation/SKILL.md` — Convert from skill card to task card: remove YAML frontmatter, remove "Skill:" header, remove Contracts section, keep plain task list
- `writing-plans-creation/tasks/create.md` — Contract path fixes, plan-creation-pipeline integration
- `writing-plans-creation/tasks/update.md` — Contract path fixes
- `writing-plans-creation/tasks/retroactive.md` — Contract path fixes
- `writing-plans-creation/tasks/pre-plan-readiness.md` — Add solve readiness gate

**Out of Scope:**
- Other writing-plans-creation task files (no code changes needed)
- writing-plans-holistic skill (already correct)
- spec-creation-decomposition/SKILL.md (separate issue — same defect, different skill)
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
| Add TDT to `writing-plans-creation` | Sub-skill is a task container; parent orchestrator reads Pipeline section; pattern requires no TDT |
| Use symlinks for contract paths | Symlinks break in containers/CI; not portable; violates explicit path principle |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| `writing-plans-creation` has 16 task files, 0 TDT entries | `ls .opencode/skills/writing-plans-creation/tasks/` + `read(SKILL.md)` |
| Contract files at `writing-plans-creation/contracts/` | `ls .opencode/skills/writing-plans-creation/contracts/` |
| `create.md` references `writing-plans/contracts/` | `grep "writing-plans/contracts" create.md` (11 matches) |
| `spec-creation` parent routes to sub-skills with 3 TDT entries | `read(SKILL.md)` lines 30-40 |
| `spec-creation-decomposition` has no TDT | `read(SKILL.md)` — Tasks list only |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `writing-plans` TDT has exactly 4 user-facing workflow entries (`create`, `update`, `retroactive`, `holistic-self-check`) | structural | `read` SKILL.md → count TDT rows = 4 | Replace TDT with 4 entries | spec-creation | `.opencode/skills/writing-plans/SKILL.md` | G1 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-2 | `writing-plans` Pipeline section documents 4 workflows (`create`, `update`, `retroactive`, `holistic-self-check`) with step-level dispatch classification | structural | `read` SKILL.md → find Pipeline section with 4 workflows | Add Pipeline section | spec-creation | `.opencode/skills/writing-plans/SKILL.md` | G2 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-3 | `writing-plans-creation` is a task card (not a skill card) — no YAML frontmatter, no "Skill:" header, no TDT, no Invocation | structural | `read` SKILL.md → no YAML frontmatter, no "Skill:" header | Convert SKILL.md to plain task card | spec-creation | `.opencode/skills/writing-plans-creation/SKILL.md` | G3 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-4 | All contract paths in `create.md`, `update.md`, `retroactive.md` resolve | structural | `bash` check each path exists | Fix paths to writing-plans-creation/contracts/ | spec-creation | `.opencode/skills/writing-plans-creation/tasks/*.md` | G4 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-5 | `create` workflow dispatches to `plan-creation-pipeline` with Z3 gates | behavioral | `opencode run` → verify skill dispatch in stderr | Add plan-creation-pipeline step to create workflow | spec-creation | `.opencode/skills/writing-plans-creation/tasks/create.md` | G5 | single-task | pre-approval-gate | sub-agent | writing-plans | spec-creation | N/A | Phase 1 |
| SC-6 | `pre-plan-readiness` has `solve` readiness gate | structural | `read` pre-plan-readiness.md → find solve check | Add solve check step | spec-creation | `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` | G6 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-7 | All canonical dispatch strings follow DISPATCH_GATE format | structural | `read` Invocation sections → verify format | Fix format in Invocation | spec-creation | Both SKILL.md files | G7 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |
| SC-8 | No orphaned tasks in `writing-plans-creation/tasks/` | structural | `ls tasks/` vs Pipeline task refs → diff empty | Add missing task refs to Pipeline | spec-creation | Both SKILL.md files | G8 | single-task | pre-approval-gate | inline | writing-plans | spec-creation | N/A | Phase 1 |

## Pipeline / Workflows

Per `spec-creation` pattern, the `writing-plans` skill defines FOUR user-facing workflows in its Pipeline section. The TDT has exactly 4 entries. Pipeline steps are documented for the orchestrator — they are NOT TDT entries.

### Workflow 1: `create` — Full Plan Creation Pipeline (22 steps)

```
 1. [inline]  local-issues sync                          # ensure issues-data current
 2. [sub-task] verify-spec-approved                      # check spec approval (pre-plan-readiness)
 3. [sub-task] research                                   # gather evidence (research.md)
 4. [inline]  solve check                                 # verify research output contract
 5. [sub-task] artifact-validation                        # validate 7 analytical artifacts
 6. [sub-task] readiness                                  # pipeline-readiness gate (readiness.md)
 7. [inline]  solve check                                 # verify readiness output contract
 8. [sub-task] structure                                  # define phase structure (structure.md)
 9. [inline]  solve check                                 # verify structure output contract
10. [sub-task] solve                                     # Z3 constraint solving (solve.md)
11. [inline]  solve check                                 # verify solve output contract
12. [sub-task] plan-creation-pipeline                    # Z3 phase solvability (plan-creation-pipeline skill)
13. [inline]  solve check                                 # verify pipeline output contract
14. [sub-task] write                                     # write plan files (write.md)
15. [inline]  solve check                                 # verify write output contract
16. [sub-task] revisit                                   # resolve unverified claims (revisit.md)
17. [inline]  solve check                                 # verify revisit output contract
18. [sub-task] validate                                  # validate plan (validate.md)
19. [inline]  solve check                                 # verify validate output contract
20. [sub-task] audit-fidelity                            # fidelity audit (audit skill)
21. [inline]  solve check                                 # verify audit-fidelity output contract
22. [sub-task] audit-concern                             # concern audit (audit skill)
23. [inline]  solve check                                 # verify audit-concern output contract
24. [sub-task] completion                                # lifecycle event (completion.md)
25. [inline]  solve check                                 # verify completion output contract
```

### Workflow 2: `update` — Plan Update for Non-Substantive Spec Revisions (6 steps)

```
 1. [inline]  local-issues sync
 2. [sub-task] verify-spec-approved                      # holistic spec evaluation
 3. [sub-task] read-revised-spec                         # extract changed SCs
 4. [sub-task] read-existing-plan                        # locate corresponding sections
 5. [sub-task] diff-scs                                  # identify only metadata changes
 6. [sub-task] update-plan                               # edit plan file, preserve approval
 7. [sub-task] verify-plan                               # confirm valid YAML/markdown
 8. [inline]  solve check                                 # verify output contract
 9. [sub-task] completion                                # lifecycle event
10. [inline]  solve check                                 # verify completion contract
```

### Workflow 3: `retroactive` — Retroactive Plan Creation (20 steps)

Same pipeline as `create` but without artifact-validation (spec already exists) and without plan-creation-pipeline (no Z3 phase solvability for existing specs). Research step loads existing spec body as evidence source.

```
 1. [inline]  local-issues sync
 2. [sub-task] verify-spec-exists                        # check spec file exists
 3. [sub-task] research                                   # load existing spec body (research.md)
 4. [inline]  solve check                                 # verify research output contract
 5. [sub-task] readiness                                  # pipeline-readiness gate (readiness.md)
 6. [inline]  solve check                                 # verify readiness output contract
 7. [sub-task] structure                                  # define phase structure (structure.md)
 8. [inline]  solve check                                 # verify structure output contract
 9. [sub-task] solve                                      # Z3 constraint solving (solve.md)
10. [inline]  solve check                                 # verify solve output contract
11. [sub-task] write                                      # write plan files (write.md)
12. [inline]  solve check                                 # verify write output contract
13. [sub-task] revisit                                    # resolve unverified claims (revisit.md)
14. [inline]  solve check                                 # verify revisit output contract
15. [sub-task] validate                                   # validate plan (validate.md)
16. [inline]  solve check                                 # verify validate output contract
17. [sub-task] audit-fidelity                             # fidelity audit (audit skill)
18. [inline]  solve check                                 # verify audit-fidelity output contract
19. [sub-task] audit-concern                              # concern audit (audit skill)
20. [inline]  solve check                                 # verify audit-concern output contract
21. [sub-task] completion                                 # lifecycle event (completion.md)
22. [inline]  solve check                                 # verify completion output contract
```

### Workflow 4: `holistic-self-check` — Plan Quality Verification (1 step)

```
 1. [sub-task] holistic-self-check                       # 11-dimension evaluation (writing-plans-holistic)
 2. [inline]  solve check                                 # verify output contract
```

### Sub-task Step Contract

Every sub-task step follows the frugal contract pattern. The orchestrator passes only `{issue_number}` or workflow-specific context — no preloaded context, no file paths, no expected outcomes. The sub-agent reads its input from disk, writes its output to disk, and returns a frugal result contract.

## Implementation Approach

**Phase 1 (single spec, single plan):**
1. Update `writing-plans/SKILL.md` — TDT with 4 entries (`create`, `update`, `retroactive`, `holistic-self-check`), Pipeline section with 4 workflows, Invocation with 4 canonical strings. Document `clean-room` as internal/referenced task (not a TDT entry).
2. Update `writing-plans-creation/SKILL.md` — Convert from skill card to task card: remove YAML frontmatter, remove "Skill:" header, remove Contracts section, keep plain task list
3. Update `writing-plans-creation/tasks/create.md` — Fix 11 contract paths, add plan-creation-pipeline dispatch step, update chain refs
4. Update `writing-plans-creation/tasks/update.md` — Fix contract paths
5. Update `writing-plans-creation/tasks/retroactive.md` — Fix contract paths
6. Update `writing-plans-creation/tasks/pre-plan-readiness.md` — Add solve readiness gate (already done)
7. Run `local-issues sync` after each file change
8. Run `solve check` on all affected contracts
9. Self-review per spec-creation-validation Step 33-35

## Interdependency

| Issue | Direction | Classification | Description |
|-------|-----------|---------------|-------------|
| [#2008](https://github.com/michael-conrad/.opencode/issues/2008) | upstream | SUPERSEDES | This spec supersedes #2008 (old approach: add TDT to writing-plans-creation) with corrected architecture (task card, no TDT). |
| [#1311](https://github.com/michael-conrad/.opencode/issues/1311) | upstream | RELATED | Plan writer must dispatch to implementation skills — related dispatch pattern |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("writing-plans")` | Locate skill files |
| Direct source search | `grep -r "writing-plans/contracts" .opencode/skills/` | Find contract path references |
| Local docs | `.opencode/skills/spec-creation/SKILL.md` | Reference dispatcher pattern |
| Local docs | `.opencode/skills/spec-creation-decomposition/SKILL.md` | Reference task-container pattern |
| Live verification | `ls .opencode/skills/writing-plans-creation/contracts/` | Verify contract directory exists |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Fix contract paths in create.md (not symlink) | Explicit paths required; symlinks non-portable | MUST | SC-4 |
| DEC-2 | writing-plans TDT has exactly 4 workflow entries (`create`, `update`, `retroactive`, `holistic-self-check`) | Dispatcher pattern: parent routes user triggers; retroactive added as 4th workflow per spec review | MUST | SC-1 |
| DEC-3 | writing-plans-creation has NO TDT | Task container pattern: parent reads Pipeline | MUST | SC-3 |
| DEC-4 | Pipeline section documents dispatch classification | Orchestrator needs inline/sub-agent/clean-room per step | MUST | SC-2 |

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

- **Rewriting pipeline step logic** — Pipeline procedures unchanged except contract paths and plan-creation-pipeline integration
- **Modifying other skills** — Only writing-plans and writing-plans-creation skills affected
- **Changing skill boundaries** — Three-skill structure maintained

## Regression Invariants

- [ ] 1. Existing `create`, `update`, `holistic-self-check` high-level triggers still work
- [ ] 2. `writing-plans-holistic` skill unaffected
- [ ] 3. `implementation-pipeline` skill dispatch patterns unchanged
- [ ] 4. `spec-creation` dispatcher pattern unchanged

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)