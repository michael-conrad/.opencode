---
title: "[SPEC] BEH-EV classification gate + evaluator clean-room dispatch"
status: draft
created: 2026-07-22
updated: 2026-07-22
license: MIT
provenance: AI-generated
issue: 2066
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
supersedes:
  - 2011
---

> **Full spec and artifacts: [`.opencode/.issues/2065/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2065)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2065/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**STATUS:** DRAFT
**CREATED:** 2026-07-22

## Supersession

This spec supersedes #2011. Issue #2011 had 5 SCs; SC-1 and SC-2 failed audit. This spec replaces the original design with corrected implementation targets.

## Problem Statement

Issue #2011 specified two fixes that were never correctly implemented:

### Defect 1: BEH-EV classification gate was deleted with create.md

The BEH-EV classification gate was specified to go in `spec-creation-validation/tasks/create.md`. That file was deleted by #2020's decomposition of spec-creation-validation into 20 task cards. The gate was never migrated to any surviving task card. The classification question ("does this change affect runtime behavior?") is never asked during spec creation.

**Root cause:** The classification gate was specified against a file that was deleted by a concurrent decomposition. No migration step was included in either spec.

**Fix target:** `spec-creation-validation/tasks/decompose.md` step 3 — extend with mandatory BEH-EV classification sub-steps.

### Defect 2: Evaluators evaluate behavioral SCs inline instead of dispatching clean-room

All 9 evaluator tasks (`audit/tasks/*-evaluator.md`) check whether behavioral evidence artifacts exist in the `artifact_evidence_dir`. If files exist, they report PASS — without reading the actual content of stdout.log or stderr.log to determine whether the agent's actions satisfied the SC. No evaluator dispatches a clean-room sub-agent.

The evaluator itself is not a clean-room sub-agent — it receives orchestrator context and cached results. A true clean-room evaluation requires a sub-agent that receives ONLY the artifact directory path, reads the artifacts cold, and renders PASS/FAIL independently.

**Root cause:** The evaluator result contract has no `needs_clean_room` field. The orchestrator has no dispatch step for `behavioral-sc-evaluator`. The arbiter (`cross-validate.md`) receives only the evaluator verdict, not clean-room results.

**Fix target:** Evaluator result contract carries `needs_clean_room` list → orchestrator dispatches `behavioral-sc-evaluator` → arbiter receives both evaluator verdict and clean-room results.

## Goals

- [ ] G1: `spec-creation-validation/tasks/decompose.md` step 3 has mandatory BEH-EV classification sub-steps with presumptive runtime-behavioral file types
- [ ] G2: All 9 evaluator result contracts carry `needs_clean_room` list identifying behavioral SCs
- [ ] G3: Orchestrator dispatches `behavioral-sc-evaluator` for each SC in `needs_clean_room`
- [ ] G4: Arbiter (`cross-validate.md`) receives both evaluator verdict and clean-room results

## Non-Goals

- **Retroactively fixing existing behavioral SC verdicts** — Only newly verified SCs must comply
- **Changing the behavioral test harness** — The harness produces artifacts correctly. Only the evaluation is broken.
- **Cost model formalization** — Covered by #916 (separate spec)
- **Rewriting evaluator internals** — Only the behavioral SC evaluation path and result contract need fixing
- **Creating behavioral-sc-evaluator.md** — Already created by #2064 Phase 4

## Constraints and Scope

### In Scope

| Area | Files | Work Required |
|------|-------|--------------|
| Classification gate | `spec-creation-validation/tasks/decompose.md` | Extend step 3 with BEH-EV classification sub-steps |
| Evaluator result contracts | All 9 `audit/tasks/*-evaluator.md` files | Add `needs_clean_room` field to result contract |
| Orchestrator dispatch | `audit/tasks/behavioral-sc-evaluator.md` | Add orchestrator dispatch step (file exists from #2064) |
| Arbiter | `audit/tasks/cross-validate.md` | Add clean-room result reception and comparison logic |

### Out of Scope

- Behavioral test harness — produces correct artifacts
- Existing SC verdicts — grandfathered
- Cost model formalization — #916
- Creating behavioral-sc-evaluator.md — exists from #2064
- Evaluator investigator/validator/arbiter roles — only evaluator role needs fixing

## Design Decisions (Already Resolved)

| DEC-ID | Decision | Rationale |
|--------|----------|-----------|
| DEC-1 | Classification gate in decompose.md step 3, not a new task card | Step 3 already assigns evidence types. Extending it avoids creating a new file. |
| DEC-2 | Classification question is universal — applies to ALL SCs in ALL specs | The substrate question ("does this change affect runtime behavior?") is independent of file type. Every SC must be classified. |
| DEC-3 | Presumptive file types: SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md — these ALWAYS answer YES | These files control agent behavior at runtime. Any SC modifying them is automatically behavioral. |
| DEC-4 | Evaluator result contract carries `needs_clean_room` list, not inline dispatch | The evaluator is not the orchestrator. It cannot call task(). It reports what needs clean-room evaluation; the orchestrator dispatches. |
| DEC-5 | Arbiter receives both evaluator verdict and clean-room results | The arbiter compares both and reports consensus or conflict. This is the existing cross-validate pattern extended. |

## Safety Considerations

- **No destructive operations** — Only task file modifications
- **No database/schema changes** — Pure enforcement additions
- **Rollback:** `git revert` on affected task files
- **Data loss risk:** None

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| New task card for classification gate | decompose.md step 3 already assigns evidence types. Extending is simpler and avoids file proliferation. |
| Evaluator dispatches clean-room inline | Evaluator is not the orchestrator — it cannot call task(). Only the orchestrator can dispatch sub-agents. |
| Fix in cross-validate only | Cross-validate is downstream. Evaluators should produce correct verdicts. |
| Add guideline instead of task fix | Guidelines are advisory. Task file changes are enforceable. |
| Keep #2011 as active spec | #2011 SC-1 targeted a deleted file. The design must be corrected. |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| create.md was deleted by #2020 decomposition | `ls spec-creation-validation/tasks/` — no create.md |
| decompose.md step 3 assigns evidence types | `read decompose.md` — step 3: "Assign evidence types to each SC" |
| No BEH-EV classification sub-steps in decompose.md | `read decompose.md` — no "runtime behavior" or "BEH-EV" text |
| Evaluators check file existence for behavioral SCs | `read verification-audit-evaluator.md` — find behavioral SC evaluation logic |
| No `needs_clean_room` in any evaluator result contract | `grep` for `needs_clean_room` in all evaluator files — zero matches |
| behavioral-sc-evaluator.md exists from #2064 | `ls audit/tasks/behavioral-sc-evaluator.md` — file exists |
| cross-validate.md has no clean-room result comparison | `read cross-validate.md` — find arbiter logic |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `decompose.md` step 3 has mandatory BEH-EV classification sub-steps: (a) ask "does this change affect runtime behavior?" for each SC, (b) presumptive YES for SKILL.md/tasks/*.md/guidelines/*.md/enforcement/*.md, (c) auto-uplift to behavioral on YES | behavioral | `opencode run` → verify spec-creation agent includes BEH-EV classification when decomposing SCs |
| SC-2 | All 9 evaluator result contracts carry `needs_clean_room: [SC-IDs]` field listing behavioral SCs | behavioral | `opencode run` → verify evaluator result contract includes `needs_clean_room` for behavioral SCs |
| SC-3 | Orchestrator dispatches `behavioral-sc-evaluator` for each SC in `needs_clean_room` list | behavioral | `opencode run` → verify clean-room sub-agent dispatch in stderr for behavioral SCs |
| SC-4 | Arbiter (`cross-validate.md`) receives both evaluator verdict and clean-room results, reports consensus or conflict | behavioral | `opencode run` → verify cross-validate compares both verdicts and reports consensus/conflict |

## Implementation Approach

### Phase 1: BEH-EV classification gate in decompose.md

1. Read current `spec-creation-validation/tasks/decompose.md`
2. Extend step 3 with mandatory BEH-EV classification sub-steps:
   - 3a. For each SC, ask: "Does this change affect runtime behavior?"
   - 3b. Presumptive YES for file types: SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md
   - 3c. If YES: auto-uplift evidence type to `behavioral`
   - 3d. Record classification in decomposition artifact
3. Verify: behavioral test confirms classification step in stderr

### Phase 2: Evaluator result contract + orchestrator dispatch

1. For each of the 9 evaluator tasks: add `needs_clean_room: [SC-IDs]` to result contract
2. Update `behavioral-sc-evaluator.md` (exists from #2064) with orchestrator dispatch entry point
3. Update `cross-validate.md` to receive both evaluator verdict and clean-room results
4. Verify: behavioral test confirms clean-room dispatch and arbiter comparison

## Interdependency

| Issue | Direction | Classification | Description |
|-------|-----------|---------------|-------------|
| [#2011](https://github.com/michael-conrad/.opencode/issues/2011) | upstream | SUPERSEDED_BY | This spec supersedes #2011 with corrected design |
| [#2020](https://github.com/michael-conrad/.opencode/issues/2020) | downstream | DEPENDS_ON | Decomposed task cards — decompose.md exists in new structure |
| [#2032](https://github.com/michael-conrad/.opencode/issues/2032) | downstream | DEPENDS_ON | Task card structure — behavioral-sc-evaluator.md created here |
| [#2009](https://github.com/michael-conrad/.opencode/issues/2009) | downstream | DEPENDS_ON | Behavioral test infrastructure for SC verification |
| [#2064](https://github.com/michael-conrad/.opencode/issues/2064) | downstream | DEPENDS_ON | Created behavioral-sc-evaluator.md — this spec uses it |
| [#916](https://github.com/michael-conrad/.opencode/issues/916) | upstream | RELATED | Cost model formalization — separate concern |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read spec-creation-validation/tasks/decompose.md` | Verify current step 3 content |
| Direct source search | `ls spec-creation-validation/tasks/` | Confirm create.md is absent |
| Direct source search | `read audit/tasks/verification-audit-evaluator.md` | Verify current behavioral SC evaluation logic |
| Direct source search | `ls audit/tasks/*-evaluator.md` | Count evaluator tasks |
| Direct source search | `read audit/tasks/cross-validate.md` | Verify current arbiter logic |
| Existing spec | #2011 spec body | Extract original design and audit findings |
| Existing spec | #2064 spec body | Confirm behavioral-sc-evaluator.md was created |
| Existing spec | #2020 spec body | Confirm decomposition scope |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Classification gate in decompose.md step 3 | Step 3 already assigns evidence types. Extending avoids new file. | MUST | SC-1 |
| DEC-2 | Universal classification question | Substrate question applies to ALL SCs, not just agent-facing files | MUST | SC-1 |
| DEC-3 | Presumptive file types for YES | SKILL.md/tasks/guidelines/enforcement always affect runtime behavior | MUST | SC-1 |
| DEC-4 | needs_clean_room in result contract | Evaluator cannot call task() — only orchestrator can dispatch | MUST | SC-2, SC-3 |
| DEC-5 | Arbiter receives both verdicts | Cross-validate already compares — extending to include clean-room results | MUST | SC-4 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Spec Family Annotation

family: beh-ev-classification-cleanroom-dispatch
selectors:
  - spec: "#2065"
  - spec: glob(pattern: ".opencode/skills/spec-creation-validation/tasks/decompose.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/*-evaluator.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/behavioral-sc-evaluator.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/cross-validate.md")

## Explicit Non-Goals

- **Retroactively fixing existing behavioral SC verdicts** — Only newly verified SCs must comply
- **Changing the behavioral test harness** — The harness produces artifacts correctly
- **Cost model formalization** — Covered by #916 (separate spec)
- **Rewriting evaluator internals** — Only the behavioral SC evaluation path and result contract need fixing
- **Creating behavioral-sc-evaluator.md** — Already created by #2064 Phase 4

## Regression Invariants

- [ ] 1. Existing structural SC evaluation still works
- [ ] 2. Existing string SC evaluation still works
- [ ] 3. Existing semantic SC evaluation still works
- [ ] 4. Existing evaluator result contracts remain backward-compatible (new field is additive)
- [ ] 5. #2011's original intent (behavioral SC enforcement) is preserved

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
