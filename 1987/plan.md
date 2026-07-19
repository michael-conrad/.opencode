---
title: "[PLAN] Fix audit skill DiMo chain — arbiter consolidation, dispatch protection, cross-chain dependency"
status: draft
created: 2026-07-18
license: MIT
provenance: AI-generated
issue: 1987
parent_spec: spec.md
---

**STATUS:** DRAFT
**CREATED:** 2026-07-18

## Phase Table

| Phase | Name | Description | Dispatch Mode | SCs |
|-------|------|-------------|---------------|-----|
| 1 | Arbiter Consolidation | Remove 9 per-chain arbiter files, update cross-validate.md to accept multiple verdict.yaml inputs, update resolve-models.md and completion.md, update evaluator task files to stop at verdict.yaml | sub-agent | SC-1, SC-2, SC-3, SC-11, SC-12, SC-13 |
| 2 | Dispatch Protection + Cross-Chain | Add PRELOADED_CONTEXT_REJECTED gates to all remaining task files, add cross-chain dependency to spec-audit-evaluator.md, update SKILL.md with explicit dispatch protocol | sub-agent | SC-4, SC-5, SC-6, SC-7 |
| 3 | Behavioral Tests | Create behavioral enforcement tests for separate dispatch, cross-validate verdicts, PRELOADED_CONTEXT_REJECTED, and no-lobotomy | sub-agent | SC-8, SC-9, SC-10, SC-14 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | All 9 per-chain `*-arbiter.md` files removed | 1 | 1.1, 1.2 |
| SC-2 | `cross-validate.md` is sole file producing `judgment.yaml` (excluding completion.md and sub-skill arbiters) | 1 | 1.3, 1.4 |
| SC-3 | Each chain stops at Evaluator (produces `verdict.yaml` only, no `judgment.yaml`) | 1 | 1.5 |
| SC-4 | `PRELOADED_CONTEXT_REJECTED` gate in every remaining task file's entry criteria | 2 | 2.1 |
| SC-5 | Spec-audit evaluator checks for plan-fidelity `verdict.yaml` before producing verdict | 2 | 2.2 |
| SC-6 | SKILL.md explicitly states orchestrator MUST NOT dispatch skill to sub-agent | 2 | 2.3 |
| SC-7 | SKILL.md explicitly states orchestrator MUST dispatch each role as separate `task()` call | 2 | 2.3 |
| SC-8 | Behavioral test: orchestrator dispatches each role separately | 3 | 3.1 |
| SC-9 | Behavioral test: cross-validate receives all verdicts | 3 | 3.2 |
| SC-10 | Behavioral test: PRELOADED_CONTEXT_REJECTED on preloaded prompt | 3 | 3.3 |
| SC-11 | `resolve-models.md` updated to reference `cross-validate.md` as sole Arbiter | 1 | 1.6 |
| SC-12 | `completion.md` reads from `cross-validate` judgment.yaml | 1 | 1.7 |
| SC-13 | Evidence type audit — no SC weakened, deferred, or reclassified | 1 | 1.8 |
| SC-14 | Behavioral test: no SC weakened/deferred/reclassified | 3 | 3.4 |

## Item Decomposition

### Phase 1: Arbiter Consolidation (SC-1, SC-2, SC-3, SC-11, SC-12, SC-13)

**Item 1.1 — Delete 9 per-chain arbiter files**
- `git rm` the following files:
  - `.opencode/skills/audit/tasks/spec-audit-arbiter.md`
  - `.opencode/skills/audit/tasks/plan-fidelity-arbiter.md`
  - `.opencode/skills/audit/tasks/verification-audit-arbiter.md`
  - `.opencode/skills/audit/tasks/concern-separation-arbiter.md`
  - `.opencode/skills/audit/tasks/coherence-maintenance-arbiter.md`
  - `.opencode/skills/audit/tasks/guideline-audit-arbiter.md`
  - `.opencode/skills/audit/tasks/drift-detection-arbiter.md`
  - `.opencode/skills/audit/tasks/test-quality-audit-arbiter.md`
  - `.opencode/skills/audit/tasks/content-audit-arbiter.md`
- **SC:** SC-1
- **RED:** `glob pattern="**/*-arbiter.md" path=.opencode/skills/audit/tasks/` returns only `cross-validate.md` (and sub-skill arbiters in `spec-summary/`, `closure-verification/`, `coherence-extraction/`)
- **GREEN:** Execute `git rm` on all 9 files
- **Rollback:** `git restore --source=HEAD -- <file>` for each deleted file

**Item 1.2 — Update cross-references in remaining task files**
- Search all remaining task files for references to deleted arbiter files (e.g., `spec-audit-arbiter.md`, `plan-fidelity-arbiter.md`, etc.)
- Replace each reference with `cross-validate.md`
- **SC:** SC-1 (cross-reference integrity)
- **RED:** `grep -r "spec-audit-arbiter\|plan-fidelity-arbiter\|verification-audit-arbiter\|concern-separation-arbiter\|coherence-maintenance-arbiter\|guideline-audit-arbiter\|drift-detection-arbiter\|test-quality-audit-arbiter\|content-audit-arbiter" .opencode/skills/audit/tasks/` returns matches
- **GREEN:** Replace all references with `cross-validate.md`
- **Rollback:** `git checkout -- <file>` for each modified file

**Item 1.3 — Update cross-validate.md to accept multiple verdict.yaml inputs**
- Modify `cross-validate.md` to read `verdict.yaml` from all chains (spec-audit, plan-fidelity, verification-audit, concern-separation, coherence-maintenance, guideline-audit, drift-detection, test-quality-audit, content-audit) instead of a single chain
- Update entry criteria to require all chain verdict.yaml files
- Update the judgment synthesis step to cross-reference across all chains
- **SC:** SC-2
- **RED:** `grep "verdict.yaml" .opencode/skills/audit/tasks/cross-validate.md` shows single-chain references
- **GREEN:** Update to multi-chain verdict.yaml consumption
- **Rollback:** `git checkout -- .opencode/skills/audit/tasks/cross-validate.md`

**Item 1.4 — Remove judgment.yaml references from evaluator task files**
- For each evaluator task file (spec-audit-evaluator, plan-fidelity-evaluator, verification-audit-evaluator, concern-separation-evaluator, coherence-maintenance-evaluator, guideline-audit-evaluator, drift-detection-evaluator, test-quality-audit-evaluator, content-audit-evaluator):
  - Remove any step that writes `judgment.yaml`
  - Ensure output artifact is `verdict.yaml` only
- **SC:** SC-2, SC-3
- **RED:** `grep "judgment.yaml" .opencode/skills/audit/tasks/*-evaluator.md` returns matches
- **GREEN:** Remove judgment.yaml references from all evaluator files
- **Rollback:** `git checkout -- <file>` for each modified evaluator

**Item 1.5 — Update each chain's evaluator to stop at verdict.yaml**
- Verify each evaluator's output section declares `verdict.yaml` as the only output artifact
- Remove any Arbiter-dispatch instructions from evaluator files
- **SC:** SC-3
- **RED:** `grep "Arbiter\|arbiter" .opencode/skills/audit/tasks/*-evaluator.md` shows arbiter dispatch references
- **GREEN:** Remove arbiter dispatch instructions from evaluators
- **Rollback:** `git checkout -- <file>` for each modified evaluator

**Item 1.6 — Update resolve-models.md**
- Replace references to deleted per-chain arbiters with `cross-validate.md`
- Update the Arbiter role description to reference `cross-validate.md` as sole Arbiter
- **SC:** SC-11
- **RED:** `grep -E "spec-audit-arbiter|plan-fidelity-arbiter|verification-audit-arbiter|concern-separation-arbiter|coherence-maintenance-arbiter|guideline-audit-arbiter|drift-detection-arbiter|test-quality-audit-arbiter|content-audit-arbiter" .opencode/skills/audit/tasks/resolve-models.md` returns matches
- **GREEN:** Replace with `cross-validate.md` references
- **Rollback:** `git checkout -- .opencode/skills/audit/tasks/resolve-models.md`

**Item 1.7 — Update completion.md**
- Update `completion.md` to read `judgment.yaml` from `cross-validate` path instead of per-chain paths
- **SC:** SC-12
- **RED:** `grep "cross-validate.*judgment.yaml" .opencode/skills/audit/tasks/completion.md` returns no match
- **GREEN:** Add cross-validate judgment.yaml reference
- **Rollback:** `git checkout -- .opencode/skills/audit/tasks/completion.md`

**Item 1.8 — Evidence type audit**
- Verify all 14 SCs have correct evidence type declarations matching substrate classification
- SC-8, SC-9, SC-10, SC-14 must be `behavioral`; all others `structural`
- **SC:** SC-13
- **RED:** Audit reveals any SC with wrong evidence type
- **GREEN:** Fix any misclassified evidence types
- **Rollback:** `git checkout -- .opencode/.issues/1987/spec.md`

### Phase 2: Dispatch Protection + Cross-Chain (SC-4, SC-5, SC-6, SC-7)

**Item 2.1 — Add PRELOADED_CONTEXT_REJECTED to all remaining task files**
- For each `.md` file in `.opencode/skills/audit/tasks/` (excluding deleted arbiters and sub-skill dirs):
  - Add to entry criteria: "If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`."
  - Add error-handling table entry mapping preloaded context to BLOCKED
- **SC:** SC-4
- **RED:** `grep -rl "PRELOADED_CONTEXT_REJECTED" .opencode/skills/audit/tasks/` returns only 4 files (content-audit-*)
- **GREEN:** All remaining task files have PRELOADED_CONTEXT_REJECTED gate
- **Rollback:** `git checkout -- <file>` for each modified file

**Item 2.2 — Add cross-chain dependency to spec-audit-evaluator.md**
- Add entry criteria: "plan-fidelity `verdict.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml` — MUST be confirmed before producing verdict"
- Remove SC-7 from spec-audit evaluator's criteria table (SC-7 is a structural check that belongs to plan-fidelity chain)
- **SC:** SC-5
- **RED:** `grep "plan-fidelity.*verdict.yaml\|plan_fidelity.*verdict" .opencode/skills/audit/tasks/spec-audit-evaluator.md` returns no match
- **GREEN:** Add plan-fidelity verdict.yaml dependency check
- **Rollback:** `git checkout -- .opencode/skills/audit/tasks/spec-audit-evaluator.md`

**Item 2.3 — Update SKILL.md with explicit dispatch protocol**
- Add section: "Orchestrator MUST NOT dispatch the SKILL.md to a sub-agent"
- Add section: "Orchestrator MUST dispatch each role as a separate `task()` call (Investigator, Validator, Evaluator, Arbiter)"
- **SC:** SC-6, SC-7
- **RED:** `grep "MUST NOT.*dispatch\|must not.*dispatch" .opencode/skills/audit/SKILL.md` returns no match; `grep "MUST dispatch each role\|must dispatch each.*task()" .opencode/skills/audit/SKILL.md` returns no match
- **GREEN:** Add both prohibitions to SKILL.md
- **Rollback:** `git checkout -- .opencode/skills/audit/SKILL.md`

### Phase 3: Behavioral Tests (SC-8, SC-9, SC-10, SC-14)

**Item 3.1 — Behavioral test: separate dispatch**
- Create `.opencode/tests-v2/behaviors/audit-dimo-chain/sc8-separate-dispatch.sh`
- Test sends real-domain prompt ("audit spec #N") and asserts stderr shows 4 separate `task()` dispatches (Investigator, Validator, Evaluator, Arbiter)
- **SC:** SC-8
- **RED:** Test fails (behavior not yet implemented)
- **GREEN:** Test passes after Phase 1 + Phase 2 implementation
- **Rollback:** `git checkout -- .opencode/tests-v2/behaviors/audit-dimo-chain/sc8-separate-dispatch.sh`

**Item 3.2 — Behavioral test: cross-validate receives all verdicts**
- Create `.opencode/tests-v2/behaviors/audit-dimo-chain/sc9-cross-validate-verdicts.sh`
- Test sends real-domain prompt and asserts stderr shows cross-validate reading multiple `verdict.yaml` files
- **SC:** SC-9
- **RED:** Test fails
- **GREEN:** Test passes after Phase 1 implementation
- **Rollback:** `git checkout -- .opencode/tests-v2/behaviors/audit-dimo-chain/sc9-cross-validate-verdicts.sh`

**Item 3.3 — Behavioral test: PRELOADED_CONTEXT_REJECTED**
- Create `.opencode/tests-v2/behaviors/audit-dimo-chain/sc10-preloaded-rejected.sh`
- Test sends preloaded prompt (includes file paths, expected outcomes) and asserts stderr shows `PRELOADED_CONTEXT_REJECTED`
- **SC:** SC-10
- **RED:** Test fails
- **GREEN:** Test passes after Phase 2 implementation
- **Rollback:** `git checkout -- .opencode/tests-v2/behaviors/audit-dimo-chain/sc10-preloaded-rejected.sh`

**Item 3.4 — Behavioral test: no lobotomy**
- Create `.opencode/tests-v2/behaviors/audit-dimo-chain/sc14-no-lobotomy.sh`
- Test verifies that all SCs maintain their declared evidence type through implementation
- **SC:** SC-14
- **RED:** Test fails
- **GREEN:** Test passes
- **Rollback:** `git checkout -- .opencode/tests-v2/behaviors/audit-dimo-chain/sc14-no-lobotomy.sh`

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: Deleting 9 arbiter files (`git rm`), modifying cross-validate.md, evaluator files, resolve-models.md, completion.md
- Rollback plan: `git restore --source=HEAD -- <file>` for each deleted/modified file. All changes are file-level and fully reversible via git checkout.
- Data loss risk: none (git history preserved)

**Phase 2 — Safety/Rollback:**
- Destructive operations: Modifying 40+ task files to add PRELOADED_CONTEXT_REJECTED gates, modifying spec-audit-evaluator.md, modifying SKILL.md
- Rollback plan: `git checkout -- <file>` for each modified file. Each file change is independent and reversible.
- Data loss risk: none (git history preserved)

**Phase 3 — Safety/Rollback:**
- Destructive operations: Creating new test files (no destructive operations)
- Rollback plan: `git rm` new test files
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | 9 `*-arbiter.md` files in `.opencode/skills/audit/tasks/` | ✅ | `glob` returned all 9 files |
| 1.2 | Cross-references to deleted arbiters in remaining task files | ✅ | `grep` confirmed references exist in multiple files |
| 1.3 | `cross-validate.md` exists at `.opencode/skills/audit/tasks/cross-validate.md` | ✅ | `glob` confirmed file exists |
| 1.4 | Evaluator task files exist (9 files matching `*-evaluator.md`) | ✅ | `glob` confirmed all evaluator files exist |
| 1.5 | Evaluator files contain `judgment.yaml` references | ✅ | `grep` confirmed judgment.yaml references in evaluator files |
| 1.6 | `resolve-models.md` exists at `.opencode/skills/audit/tasks/resolve-models.md` | ✅ | `glob` confirmed file exists |
| 1.7 | `completion.md` exists at `.opencode/skills/audit/tasks/completion.md` | ✅ | `glob` confirmed file exists |
| 2.1 | Only 4 files have PRELOADED_CONTEXT_REJECTED (content-audit-*) | ✅ | `grep` confirmed only 4 files have the gate |
| 2.2 | `spec-audit-evaluator.md` exists, SC-7 at line 239 | ✅ | `grep` confirmed SC-7 is structural only |
| 2.3 | `SKILL.md` exists at `.opencode/skills/audit/SKILL.md` | ✅ | `glob` confirmed file exists |
| 3.1-3.4 | Behavioral test directory `.opencode/tests-v2/behaviors/audit-dimo-chain/` | ✅ | Directory will be created during Phase 3 |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 9 per-chain arbiter files exist | `glob pattern="**/*-arbiter.md" path=.opencode/skills/audit/tasks/` | ✅ |
| Only 4 files have PRELOADED_CONTEXT_REJECTED | `grep -rl "PRELOADED_CONTEXT_REJECTED" .opencode/skills/audit/tasks/` | ✅ |
| SC-7 in spec-audit-evaluator.md is structural only | `grep -n "SC-7" .opencode/skills/audit/tasks/spec-audit-evaluator.md` line 239 | ✅ |
| cross-validate.md claims sole arbiter role | `grep "sole Arbiter" .opencode/skills/audit/tasks/cross-validate.md` line 7 | ✅ |
| completion.md writes judgment.yaml | `grep "judgment.yaml" .opencode/skills/audit/tasks/completion.md` | ✅ |
| resolve-models.md references arbiter role | `grep "Arbiter" .opencode/skills/audit/tasks/resolve-models.md` | ✅ |
| SKILL.md has dispatch protocol section | `grep "dispatch\|MUST NOT\|task()" .opencode/skills/audit/SKILL.md` | ✅ |
| Sub-skill arbiters exist (spec-summary, closure-verification, coherence-extraction) | `glob pattern="**/arbiter.md" path=.opencode/skills/audit/tasks/` | ✅ |

## Dependency Graph

```
Phase 1 (Arbiter Consolidation)
  ├── Item 1.1: Delete 9 arbiter files
  ├── Item 1.2: Update cross-references
  ├── Item 1.3: Update cross-validate.md (multi-verdict)
  ├── Item 1.4: Remove judgment.yaml from evaluators
  ├── Item 1.5: Stop evaluators at verdict.yaml
  ├── Item 1.6: Update resolve-models.md
  ├── Item 1.7: Update completion.md
  └── Item 1.8: Evidence type audit
       │
       ▼
Phase 2 (Dispatch Protection + Cross-Chain)
  ├── Item 2.1: PRELOADED_CONTEXT_REJECTED gates
  ├── Item 2.2: Cross-chain dependency (spec-audit → plan-fidelity)
  └── Item 2.3: SKILL.md dispatch protocol
       │
       ▼
Phase 3 (Behavioral Tests)
  ├── Item 3.1: SC-8 separate dispatch test
  ├── Item 3.2: SC-9 cross-validate verdicts test
  ├── Item 3.3: SC-10 PRELOADED_CONTEXT_REJECTED test
  └── Item 3.4: SC-14 no-lobotomy test
```

**Dependency rules:**
- Phase 1 MUST complete before Phase 2 (arbiter files must be removed before adding dispatch protection)
- Phase 2 MUST complete before Phase 3 (dispatch protection must exist before behavioral tests verify it)
- Within Phase 1: Items 1.1-1.5 are sequential (delete first, then update references, then update cross-validate, then clean evaluators). Items 1.6, 1.7, 1.8 are independent of each other but depend on 1.1-1.5.
- Within Phase 2: Items 2.1, 2.2, 2.3 are independent of each other.
- Within Phase 3: Items 3.1-3.4 are independent of each other.

## Pipeline Gate Sequence

Each phase follows the full pipeline: coherence gate → pre-red-baseline → RED/GREEN per item → VbC → audit → cross-validate → regression check → finishing checklist → review-prep → cleanup.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
