---
title: "[SPEC] Fix audit skill DiMo chain — arbiter fragmentation, mis-dispatch, and cross-chain dependency"
status: draft
created: 2026-07-17
license: MIT
provenance: AI-generated
issue: 1987
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-17

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Problem

The audit skill's DiMo (Dispatch-Modular) chain has three structural defects that produce incorrect audit results. These defects were discovered through a deep audit of the skill's task files and dispatch protocol.

### Defect 1: Arbiter Role Fragmentation

`cross-validate.md` line 7 declares: "This file is the sole Arbiter (Arbiter) in the audit skill. No other file owns this role. No other file produces `judgment.yaml`."

This claim is false. Nine other task files also produce `judgment.yaml`:

- `spec-audit-arbiter.md`
- `plan-fidelity-arbiter.md`
- `verification-audit-arbiter.md`
- `concern-separation-arbiter.md`
- `coherence-maintenance-arbiter.md`
- `guideline-audit-arbiter.md`
- `drift-detection-arbiter.md`
- `test-quality-audit-arbiter.md`
- `content-audit-arbiter.md`

Additionally, `completion.md` also writes `judgment.yaml`. Each per-chain arbiter accepts the Evaluator's verdicts as final and produces its own `judgment.yaml`. The `cross-validate.md` task never receives upstream verdicts — each chain short-circuits at its own arbiter, bypassing the cross-validation gate entirely.

**Verified by:** `grep -r "judgment.yaml" .opencode/skills/audit/tasks/` — 10 files produce `judgment.yaml` (9 per-chain arbiters + completion.md), contradicting cross-validate.md's sole-arbiter claim.

### Defect 2: No Mis-Dispatch Protection

Three mis-dispatch patterns produce incorrect results:

**Pattern 1 — Orchestrator dispatches entire audit as single `task()`:** The sub-agent runs all 4 roles internally. Investigator, Validator, Evaluator, and Arbiter are the same agent with shared context. No clean-room separation. The chain collapses into a self-review.

**Pattern 2 — Orchestrator dispatches SKILL.md to sub-agent:** The sub-agent receives orchestrator-level routing metadata (Trigger Dispatch Table, DISPATCH_GATE protocol). It cannot call `task()` — sub-agents don't have that tool. The audit never runs.

**Pattern 3 — Orchestrator dispatches with preloaded context:** The orchestrator includes file paths, expected outcomes, or reasoning in the `task()` prompt. Sub-agent findings are contaminated by orchestrator bias.

**Verified by:** `grep -r "PRELOADED_CONTEXT_REJECTED" .opencode/skills/audit/tasks/` — only 4 files (content-audit-arbiter, content-audit-evaluator, content-audit-investigator, content-audit-validator) have PRELOADED_CONTEXT_REJECTED gates. The remaining 40+ task files have no protection.

### Defect 3: No Cross-Chain Dependency

Spec-audit SC-7 claims to check "Fidelity maintained" but only checks structural alignment (phase coverage, step numbering). It does NOT check whether the plan's verification methods deliver the spec's declared evidence types. That check is `PF-STRUCTURAL-FAIL` in the plan-fidelity evaluator — a completely separate chain that may or may not run.

**Verified by:** `grep -n "SC-7\|plan.fidelity\|plan_fidelity\|plan-fidelity" .opencode/skills/audit/tasks/spec-audit-evaluator.md` — SC-7 is defined in spec-audit-evaluator.md line 239 as a structural check only. No dependency gate between spec-audit and plan-fidelity chains exists. The orchestrator can run spec-audit alone, get a PASS, and proceed to implementation without ever running plan-fidelity.

## Root Cause Analysis

The root cause is a design-level failure in the audit skill's DiMo chain architecture:

1. **No centralized arbiter contract:** The skill was designed with per-chain arbiters that each produce `judgment.yaml`, but `cross-validate.md` was written with the assumption it was the sole arbiter. The per-chain arbiters were added incrementally without updating the cross-validate contract or removing the old arbiters.

2. **No dispatch protocol enforcement:** The SKILL.md describes the DiMo chain (Investigator → Validator → Evaluator → Arbiter) but does not explicitly forbid the orchestrator from dispatching the entire chain as a single `task()`, dispatching the SKILL.md itself, or preloading context. Task files lack entry criteria gates for preloaded context.

3. **No cross-chain dependency model:** Each DiMo chain operates independently. The spec-audit chain's SC-7 duplicates (incompletely) a check that belongs in the plan-fidelity chain. There is no mechanism for one chain to require results from another.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Rewrite the entire DiMo chain architecture from scratch | Out of scope — the 4-role chain (Investigator/Validator/Evaluator/Arbiter) is sound; only the arbiter consolidation and dispatch protocol need fixing |
| Keep per-chain arbiters but have them forward to cross-validate | Adds indirection without benefit — each arbiter produces a judgment that cross-validate would override; simpler to stop at Evaluator |
| Add cross-chain dependency via a shared state file | The verdict.yaml files already serve as shared state; the dependency is a check at the Evaluator level, not a new artifact |
| Add PRELOADED_CONTEXT_REJECTED only to high-risk task files | All task files are equally vulnerable to preloaded context; partial coverage creates a false sense of security |

## Constraints and Scope

**In scope:**
- Consolidate Arbiter role to `cross-validate.md` only — remove all 9 per-chain `*-arbiter.md` files
- Each chain stops at Evaluator (produces `verdict.yaml` only)
- `cross-validate.md` becomes the sole Arbiter — reads all `verdict.yaml` files from all chains
- Add `PRELOADED_CONTEXT_REJECTED` gate to every task file's entry criteria
- Add cross-chain dependency: spec-audit evaluator checks for plan-fidelity `verdict.yaml` before producing verdict
- Update SKILL.md with explicit orchestrator dispatch protocol (MUST NOT dispatch skill, MUST dispatch each role separately)
- Update `resolve-models.md` to reference `cross-validate.md` as sole Arbiter
- Update `completion.md` to read from `cross-validate` judgment.yaml
- Add behavioral enforcement tests for the fix

**Out of scope:**
- Rewriting the DiMo chain architecture from scratch
- Changing the Investigator/Validator/Evaluator role contracts
- Non-audit skill changes
- Changes to `spec-summary/` or `closure-verification/` or `coherence-extraction/` sub-directory arbiters (these are separate sub-skills, not per-chain arbiters)

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [.opencode#1987](https://github.com/michael-conrad/.opencode/issues/1987) | SELF | This spec |

## Implementation Approach

1. Remove all 9 per-chain `*-arbiter.md` files
2. Each chain stops at Evaluator (produces `verdict.yaml` only)
3. `cross-validate.md` becomes the sole Arbiter — update to accept multiple `verdict.yaml` inputs from all chains
4. Add `PRELOADED_CONTEXT_REJECTED` gate to every remaining task file's entry criteria
5. Add cross-chain dependency: spec-audit evaluator checks for plan-fidelity `verdict.yaml` before producing verdict; remove SC-7 from spec-audit evaluator
6. Update SKILL.md with explicit dispatch protocol (MUST NOT dispatch skill, MUST dispatch each role as separate `task()` call)
7. Update `resolve-models.md` to reference `cross-validate.md` as sole Arbiter
8. Update `completion.md` to read from `cross-validate` judgment.yaml
9. Add behavioral enforcement tests

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1987/plan.md` before implementation begins.

## Plan Format Requirements

Every dispatch step in the implementation plan MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form. Plan steps MUST NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards. The full implementation pipeline must be enumerated with no skipped or combined steps: coherence gate, pre-red-baseline, RED/GREEN per item, VbC, audit, cross-validate, regression check, finishing checklist, review-prep, cleanup.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Remove per-chain arbiters instead of converting to forwarders | Each arbiter produces a judgment that cross-validate would override; stopping at Evaluator eliminates the indirection | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | PRELOADED_CONTEXT_REJECTED in every task file entry criteria | All task files are equally vulnerable; partial coverage creates false security | MUST | SC-4 |
| DEC-3 | Cross-chain dependency at spec-audit evaluator level | The evaluator is the natural gate — it reads upstream artifacts before producing verdict | MUST | SC-5 |
| DEC-4 | Behavioral tests use stderr-based assertions | Prose-recall prompts produce stdout prose, not behavioral evidence | MUST | SC-8, SC-9, SC-10 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Removing arbiter files breaks cross-references in other task files | High | Medium | Update all cross-references in remaining task files to point to cross-validate.md | SC-1 |
| RISK-2 | PRELOADED_CONTEXT_REJECTED gate causes false positives on legitimate dispatches | Low | Low | Gate checks for specific preload patterns (file paths, expected outcomes, orchestrator reasoning) | SC-4 |
| RISK-3 | Plan-fidelity chain not run before spec-audit, causing spec-audit to block | Medium | Low | Spec-audit evaluator checks for plan-fidelity verdict.yaml; if absent, returns BLOCKED with clear reason | SC-5 |
| RISK-4 | Behavioral tests flake due to model availability | Medium | High | Use timeout configuration and alternative model selection per remediation-first protocol | SC-8, SC-9, SC-10 |

## Files Affected

- `.opencode/skills/audit/SKILL.md` — update dispatch protocol
- `.opencode/skills/audit/tasks/cross-validate.md` — update to accept multiple `verdict.yaml` inputs
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` — add cross-chain dependency check, remove SC-7
- `.opencode/skills/audit/tasks/spec-audit-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/plan-fidelity-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/verification-audit-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/concern-separation-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/coherence-maintenance-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/guideline-audit-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/drift-detection-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/test-quality-audit-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/content-audit-arbiter.md` — DELETE
- `.opencode/skills/audit/tasks/resolve-models.md` — update to reference `cross-validate.md` as sole Arbiter
- `.opencode/skills/audit/tasks/completion.md` — update to read from `cross-validate` judgment.yaml
- All remaining task files — add `PRELOADED_CONTEXT_REJECTED` to entry criteria
- `.opencode/tests-v2/behaviors/audit-dimo-chain/` — new behavioral test files

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 9 per-chain `*-arbiter.md` files removed | `glob pattern="**/*-arbiter.md" path=.opencode/skills/audit/tasks/` returns only `cross-validate.md` (and sub-skill arbiters in `spec-summary/`, `closure-verification/`, `coherence-extraction/`) | Restore deleted files and re-verify | pre-commit | `.opencode/skills/audit/tasks/` | Defect 1 — Arbiter fragmentation | Phase 1 | pre-commit | sequential | arbiter-consolidation | null | `audit-dimo-chain/sc1-arbiters-removed.sh` | Phase 1 |
| SC-2 | `cross-validate.md` is the sole file producing `judgment.yaml` (excluding `completion.md` and sub-skill arbiters) | `grep -rl "judgment.yaml" .opencode/skills/audit/tasks/` returns only `cross-validate.md`, `completion.md`, and sub-skill files (`spec-summary/`, `closure-verification/`, `coherence-extraction/`) | Re-check all task files for residual judgment.yaml references | pre-commit | `.opencode/skills/audit/tasks/` | Defect 1 — Arbiter fragmentation | Phase 1 | pre-commit | sequential | arbiter-consolidation | null | `audit-dimo-chain/sc2-sole-arbiter.sh` | Phase 1 |
| SC-3 | Each chain stops at Evaluator (produces `verdict.yaml` only, no `judgment.yaml`) | For each chain's evaluator task file: `grep "judgment.yaml"` returns no matches. Each evaluator's output artifact is `verdict.yaml` only | Update evaluator task files to remove judgment.yaml references | pre-commit | `.opencode/skills/audit/tasks/` | Defect 1 — Arbiter fragmentation | Phase 1 | pre-commit | sequential | arbiter-consolidation | null | `audit-dimo-chain/sc3-evaluator-only.sh` | Phase 1 |
| SC-4 | `PRELOADED_CONTEXT_REJECTED` gate present in every remaining task file's entry criteria | For each `.md` file in `.opencode/skills/audit/tasks/` (excluding deleted arbiters and sub-skill dirs): `grep "PRELOADED_CONTEXT_REJECTED"` returns a match in the entry criteria section | Add PRELOADED_CONTEXT_REJECTED gate to entry criteria of any task file missing it | pre-commit | `.opencode/skills/audit/tasks/` | Defect 2 — No mis-dispatch protection | Phase 2 | pre-commit | sequential | dispatch-protection | null | `audit-dimo-chain/sc4-preloaded-rejected.sh` | Phase 2 |
| SC-5 | Spec-audit evaluator checks for plan-fidelity `verdict.yaml` before producing verdict | `grep "plan-fidelity.*verdict.yaml\|plan_fidelity.*verdict" .opencode/skills/audit/tasks/spec-audit-evaluator.md` returns a match in the entry criteria or procedure section | Add plan-fidelity verdict.yaml dependency check to spec-audit evaluator entry criteria | pre-commit | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` | Defect 3 — No cross-chain dependency | Phase 2 | pre-commit | sequential | cross-chain | null | `audit-dimo-chain/sc5-cross-chain.sh` | Phase 2 |
| SC-6 | SKILL.md explicitly states orchestrator MUST NOT dispatch skill to sub-agent | `grep "MUST NOT.*dispatch\|must not.*dispatch" .opencode/skills/audit/SKILL.md` returns a match | Add explicit prohibition to SKILL.md dispatch protocol section | pre-commit | `.opencode/skills/audit/SKILL.md` | Defect 2 — No mis-dispatch protection | Phase 2 | pre-commit | sequential | dispatch-protection | null | `audit-dimo-chain/sc6-skill-dispatch-prohibition.sh` | Phase 2 |
| SC-7 | SKILL.md explicitly states orchestrator MUST dispatch each role as separate `task()` call | `grep "MUST dispatch each role\|must dispatch each.*task()" .opencode/skills/audit/SKILL.md` returns a match | Add per-role dispatch mandate to SKILL.md | pre-commit | `.opencode/skills/audit/SKILL.md` | Defect 2 — No mis-dispatch protection | Phase 2 | pre-commit | sequential | dispatch-protection | null | `audit-dimo-chain/sc7-per-role-dispatch.sh` | Phase 2 |
| SC-8 | Behavioral enforcement test verifies orchestrator dispatches each role separately | `bash .opencode/tests-v2/behaviors/audit-dimo-chain/sc8-separate-dispatch.sh` passes. Test sends real-domain prompt ("audit spec #N") and asserts stderr shows 4 separate `task()` dispatches (Investigator, Validator, Evaluator, Arbiter) | If test fails: diagnose stderr output, check model availability, increase timeout, re-run | post-implementation | `.opencode/tests-v2/behaviors/audit-dimo-chain/sc8-separate-dispatch.sh` | Defect 2 — No mis-dispatch protection | Phase 3 | post-implementation | sequential | behavioral-tests | null | `audit-dimo-chain/sc8-separate-dispatch.sh` | Phase 3 |
| SC-9 | Behavioral enforcement test verifies cross-validate receives all verdicts | `bash .opencode/tests-v2/behaviors/audit-dimo-chain/sc9-cross-validate-verdicts.sh` passes. Test sends real-domain prompt and asserts stderr shows cross-validate reading multiple `verdict.yaml` files | If test fails: diagnose stderr output, check model availability, increase timeout, re-run | post-implementation | `.opencode/tests-v2/behaviors/audit-dimo-chain/sc9-cross-validate-verdicts.sh` | Defect 1 — Arbiter fragmentation | Phase 3 | post-implementation | sequential | behavioral-tests | null | `audit-dimo-chain/sc9-cross-validate-verdicts.sh` | Phase 3 |
| SC-10 | Behavioral enforcement test verifies PRELOADED_CONTEXT_REJECTED on preloaded prompt | `bash .opencode/tests-v2/behaviors/audit-dimo-chain/sc10-preloaded-rejected.sh` passes. Test sends preloaded prompt (includes file paths, expected outcomes) and asserts stderr shows `PRELOADED_CONTEXT_REJECTED` | If test fails: diagnose stderr output, check model availability, increase timeout, re-run | post-implementation | `.opencode/tests-v2/behaviors/audit-dimo-chain/sc10-preloaded-rejected.sh` | Defect 2 — No mis-dispatch protection | Phase 3 | post-implementation | sequential | behavioral-tests | null | `audit-dimo-chain/sc10-preloaded-rejected.sh` | Phase 3 |
| SC-11 | `resolve-models.md` updated to reference `cross-validate.md` as sole Arbiter | `grep "cross-validate" .opencode/skills/audit/tasks/resolve-models.md` returns a match; `grep -E "spec-audit-arbiter|plan-fidelity-arbiter|verification-audit-arbiter|concern-separation-arbiter|coherence-maintenance-arbiter|guideline-audit-arbiter|drift-detection-arbiter|test-quality-audit-arbiter|content-audit-arbiter" .opencode/skills/audit/tasks/resolve-models.md` returns no matches | Update resolve-models.md to remove references to deleted arbiters | pre-commit | `.opencode/skills/audit/tasks/resolve-models.md` | Defect 1 — Arbiter fragmentation | Phase 1 | pre-commit | sequential | arbiter-consolidation | null | `audit-dimo-chain/sc11-resolve-models.sh` | Phase 1 |
| SC-12 | `completion.md` reads from `cross-validate` judgment.yaml | `grep "cross-validate.*judgment.yaml" .opencode/skills/audit/tasks/completion.md` returns a match | Update completion.md to reference cross-validate judgment.yaml path | pre-commit | `.opencode/skills/audit/tasks/completion.md` | Defect 1 — Arbiter fragmentation | Phase 1 | pre-commit | sequential | arbiter-consolidation | null | `audit-dimo-chain/sc12-completion.sh` | Phase 1 |
| SC-13 | No SC weakened, deferred, or reclassified to lower evidence type | Audit of all SC evidence types against spec declarations. Each SC's evidence type matches the substrate classification: runtime-behavioral changes (SC-8, SC-9, SC-10) are `behavioral`; structural changes (SC-1 through SC-7, SC-11, SC-12) are `structural` | If any SC has wrong evidence type, reclassify and re-verify | pre-approval-gate | `.opencode/.issues/1987/spec.md` | Anti-Lobotomization | Phase 1 | pre-approval-gate | sequential | quality-gate | null | `audit-dimo-chain/sc13-evidence-type-audit.sh` | Phase 1 |
| SC-14 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Behavioral test: `bash .opencode/tests-v2/behaviors/audit-dimo-chain/sc14-no-lobotomy.sh` passes. Test verifies that all SCs maintain their declared evidence type through implementation | If test fails: restore original SC evidence types, re-implement | post-implementation | `.opencode/tests-v2/behaviors/audit-dimo-chain/sc14-no-lobotomy.sh` | Anti-Lobotomization | Phase 3 | post-implementation | sequential | behavioral-tests | null | `audit-dimo-chain/sc14-no-lobotomy.sh` | Phase 3 |

## SC-to-Root-Cause Traceability Table

| SC ID | Root Cause Element | What It Tests |
|-------|-------------------|---------------|
| SC-1 | No centralized arbiter contract | All per-chain arbiters removed |
| SC-2 | No centralized arbiter contract | Only cross-validate.md produces judgment.yaml |
| SC-3 | No centralized arbiter contract | Each chain stops at Evaluator |
| SC-4 | No dispatch protocol enforcement | PRELOADED_CONTEXT_REJECTED gates in all task files |
| SC-5 | No cross-chain dependency model | Spec-audit evaluator requires plan-fidelity verdict.yaml |
| SC-6 | No dispatch protocol enforcement | SKILL.md prohibits dispatching skill to sub-agent |
| SC-7 | No dispatch protocol enforcement | SKILL.md mandates per-role dispatch |
| SC-8 | No dispatch protocol enforcement | Behavioral: orchestrator dispatches each role separately |
| SC-9 | No centralized arbiter contract | Behavioral: cross-validate receives all verdicts |
| SC-10 | No dispatch protocol enforcement | Behavioral: PRELOADED_CONTEXT_REJECTED on preloaded prompt |
| SC-11 | No centralized arbiter contract | resolve-models.md references cross-validate as sole Arbiter |
| SC-12 | No centralized arbiter contract | completion.md reads from cross-validate judgment.yaml |
| SC-13 | Quality assurance | Evidence type audit |
| SC-14 | Anti-lobotomization | No SC weakened |

## Risk and Edge Cases

- **Cross-reference breakage:** Removing 9 arbiter files may break cross-references in other task files. Each remaining task file that references a deleted arbiter MUST be updated to reference `cross-validate.md` instead.
- **Sub-skill arbiters:** The `spec-summary/`, `closure-verification/`, and `coherence-extraction/` sub-directories have their own `arbiter.md` files. These are separate sub-skills, NOT per-chain arbiters, and MUST NOT be deleted. The spec's SC-1 and SC-2 explicitly exclude these.
- **completion.md judgment.yaml:** `completion.md` produces its own `judgment.yaml` as a workflow completion artifact. This is distinct from the audit chain's judgment. SC-2 explicitly allows `completion.md` as an exception.
- **Behavioral test flakiness:** Behavioral tests (SC-8, SC-9, SC-10) depend on model availability and may flake. The remediation-first protocol applies: increase timeout, try alternative model, diagnose root cause before reporting FAIL.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "judgment.yaml" .opencode/skills/audit/tasks/` | Verify which files produce judgment.yaml |
| Direct source search | `grep -r "PRELOADED_CONTEXT_REJECTED" .opencode/skills/audit/tasks/` | Verify which files have preloaded context gates |
| Direct source search | `grep -rn "SC-7\|plan.fidelity" .opencode/skills/audit/tasks/spec-audit-evaluator.md` | Verify SC-7 scope and cross-chain dependency |
| Direct source search | `glob pattern="**/*-arbiter.md" path=.opencode/skills/audit/tasks/` | List all per-chain arbiter files |
| Direct source search | `grep "dispatch\|MUST NOT\|task()" .opencode/skills/audit/SKILL.md` | Verify current dispatch protocol |
| Direct source search | `grep "judgment.yaml\|arbiter\|Arbiter" .opencode/skills/audit/tasks/resolve-models.md` | Verify resolve-models references |
| Direct source search | `grep "judgment.yaml" .opencode/skills/audit/tasks/completion.md` | Verify completion.md judgment.yaml reference |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
