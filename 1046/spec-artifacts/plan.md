# Plan: [#1046](https://github.com/michael-conrad/.opencode/issues/1046) Cleanup Pipeline Ordering Fix

## Overview

The `git-workflow` cleanup pipeline has an ordering defect: `closure-verification` (adversarial audit) is called inside `verify-merge` Step 2 — **before** `issue-closure` ever runs. Since `closure-verification` Step 4 checks `spec["state"] == "closed"` and returns BLOCKED if open, this produces a guaranteed false FAIL on the first post-merge cleanup of every PR.

## Z3 Phase Contract

Contract at `.issues/1046/spec-artifacts/phase-contract.yaml` — 22 variables: 8 domain variables + 14 pipeline gate booleans.

**Dependency chain** (enforced by invariants only — no preconditions):

```
PR_VERIFIED → SC_VERIFIED → ISSUE_CLOSED → AUDIT_PASSED → BRANCHES_CLEANED → DEV_SYNCED → PRUNE_DONE
                                   ↑
                            PHASE_COMPLETE
```

**Pipeline gate invariant**: A domain variable MUST NOT be `True` unless all 14 pipeline gates for that phase are `True`.

**Contract MUST verify**:
- Initial state (all false): SAT
- Defective state (AUDIT_PASSED=true + ISSUE_CLOSED=false + PR_VERIFIED=true): UNSAT — invariant catches audit before close
- Defective state (BRANCHES_CLEANED=true + AUDIT_PASSED=false + ISSUE_CLOSED=true): UNSAT — invariant catches delete before audit
- Postconditions (all domain variables true): SAT only if all pipeline gates also true

## Phase Plan

### Phase 1: Remove closure-verification from verify-merge.md

**File area**: `skills/git-workflow/tasks/cleanup/` (agent discovers filename)

**Pipeline gates**:

| # | Gate | Phase 1 Exit Criterion |
|---|------|------------------------|
| 1 | sc-coherence-gate | SC-1, SC-4, SC-7 align: removal of closure-verification from verify-merge is consistent with "after issue closure" ordering |
| 2 | pre-red-baseline | Current verify-merge.md contains closure-verification call |
| 3 | red-phase | Behavioral test: cleanup prompt → agent MUST NOT dispatch closure-verification during verify-merge. RED = test fails because current verify-merge DOES dispatch it |
| 4 | red-doublecheck | Test failure reason is the closure-verification call in verify-merge, not a broken test harness |
| 5 | green-phase | verify-merge.md MUST contain no Step 2 closure-verification invocation. Steps 3→5 renumbered to Steps 2→4 |
| 6 | checkpoint-commit | State after GREEN committed |
| 7 | structural-checks | Lint/format on modified verify-merge.md passes clean |
| 8 | green-doublecheck | RED test now PASSES — agent no longer dispatches closure-verification during verify-merge |
| 9 | green-vbc | SC-1 verified: grep verify-merge.md for closure-verification returns no matches |
| 10 | adversarial-audit | Dual auditor reviews verify-merge.md for completeness, ordering correctness, residual audit calls |
| 11 | cross-validate | Both auditors agree on PASS |
| 12 | regression-check | Other cleanup pipeline tasks (issue-closure, branch-cleanup) pass their existing tests |
| 13 | review-prep | verify-merge.md entry/exit criteria consistent with removal, no orphaned cross-refs |
| 14 | exec-summary | Phase complete, artifact produced |

**RED condition**: When an agent receives a cleanup prompt for a merged PR, it MUST dispatch `closure-verification` during the wrong pipeline stage (verify-merge instead of branch-cleanup). The behavioral test sends the prompt and inspects stderr for the `closure-verification` dispatch — the test FAILS because the dispatch occurs at the correct verify-merge step (before the fix).

**GREEN condition**: Same test MUST PASS — verify-merge MUST NOT contain any `closure-verification` invocation. The agent discovers the file path and removes Step 2 + renumbers Steps 3→5 to Steps 2→4.

### Phase 2: Add closure-verification as branch-cleanup Step 0

**File area**: `skills/git-workflow/tasks/cleanup/` (agent discovers filename from same subfolder as Phase 1)

**Pipeline gates**:

| # | Gate | Phase 2 Exit Criterion |
|---|------|------------------------|
| 1 | sc-coherence-gate | Adding closure-verification to branch-cleanup is consistent with "after issue closure, before branch deletion" ordering |
| 2 | pre-red-baseline | Current branch-cleanup.md has no closure-verification call |
| 3 | red-phase | Behavioral test: cleanup prompt → agent MUST dispatch closure-verification during branch-cleanup when issue is closed. RED = test fails because branch-cleanup has no audit call |
| 4 | red-doublecheck | Failure reason is missing audit step, not broken harness |
| 5 | green-phase | branch-cleanup.md MUST have Step 0 closure-verification adversarial audit invocation. Entry Criteria MUST include closure-verification. Sub-step ordering: verify-merge → issue-closure → closure-verification → branch-cleanup |
| 6 | checkpoint-commit | State after GREEN committed |
| 7 | structural-checks | Lint/format on modified branch-cleanup.md passes clean |
| 8 | green-doublecheck | RED test now PASSES — stderr contains closure-verification dispatch during branch-cleanup |
| 9 | green-vbc | SC-2 verified: behavioral test confirms closure-verification dispatch. SC-3 verified: Entry Criteria contain closure-verification |
| 10 | adversarial-audit | Dual auditor reviews branch-cleanup.md: Step 0 position, entry criteria, before-branch-operations placement |
| 11 | cross-validate | Both auditors agree on PASS |
| 12 | regression-check | Phase 1 changes (verify-merge removal) and existing cleanup pipeline tests still pass |
| 13 | review-prep | branch-cleanup.md entry/exit criteria consistent with addition |
| 14 | exec-summary | Phase complete, artifact produced |

**RED condition**: When an agent receives a cleanup prompt, stderr MUST NOT contain `closure-verification` dispatch during branch-cleanup (no audit call exists yet). The behavioral test FAILS because the dispatch is absent.

**GREEN condition**: Same test MUST PASS — branch-cleanup MUST invoke `closure-verification` as Step 0, before any branch operations. Entry Criteria MUST reference closure-verification as a prerequisite.

### Phase 3: Update git-workflow SKILL.md cross-ref

**File area**: `skills/git-workflow/` (agent discovers SKILL.md in this folder)

**Pipeline gates**:

| # | Gate | Phase 3 Exit Criterion |
|---|------|------------------------|
| 1 | sc-coherence-gate | SKILL.md cross-ref ordering matches the Z3 contract dependency chain |
| 2 | pre-red-baseline | SKILL.md line 84 says "after PR merge verification" |
| 3 | red-phase | grep SKILL.md for "after PR merge verification" near "closure-verification" — match exists. RED = text is still wrong |
| 4 | red-doublecheck | Match is the specific cross-ref, not a different occurrence |
| 5 | green-phase | SKILL.md cross-ref MUST read: "after issue closure, before branch cleanup" |
| 6 | checkpoint-commit | State after GREEN committed |
| 7 | structural-checks | Lint/format on SKILL.md passes clean |
| 8 | green-doublecheck | RED test now FAILS (text is gone) — grep returns no match for old pattern |
| 9 | green-vbc | SC-4 verified: grep for new pattern returns match |
| 10 | adversarial-audit | Dual auditor reviews SKILL.md cross-ref for semantic correctness: "after issue closure, before branch cleanup" |
| 11 | cross-validate | Both auditors agree on PASS |
| 12 | regression-check | Phases 1-2 changes still working |
| 13 | review-prep | SKILL.md cross-refs consistent with corrected cleanup pipeline ordering |
| 14 | exec-summary | Phase complete, artifact produced |

**RED condition**: grep SKILL.md for `"after PR merge verification"` near `"closure-verification"` — MUST return a match before the fix.

**GREEN condition**: Same grep MUST return no match after the fix. grep for `"after issue closure, before branch cleanup"` MUST return the corrected line.

### Phase 4: Behavioral enforcement tests

**File area**: `tests/behaviors/` (agent discovers filename pattern from existing tests)

**Pipeline gates**:

| # | Gate | Phase 4 Exit Criterion |
|---|------|------------------------|
| 1 | sc-coherence-gate | Behavioral test for SC-2 (branch-cleanup dispatch) must be consistent with the Phase 2 RED condition |
| 2 | pre-red-baseline | No behavioral tests exist for cleanup pipeline ordering |
| 3 | red-phase | 3 behavioral test scripts written — each MUST FAIL because changes from Phases 1-3 are applied (RED phase tests target the already-fixed state, so the tests verify the fix works; RED doublecheck confirms the test harness is correct for future regression detection) |
| 4 | red-doublecheck | Each test fails for the correct reason — verify-merge no longer has closure-verification, branch-cleanup now has closure-verification, SKILL.md cross-ref corrected |
| 5 | green-phase | Tests committed. Tests MUST exist as regression prevention. |
| 6 | checkpoint-commit | All 3 test scripts committed |
| 7 | structural-checks | Behavioral test scripts pass shellcheck/format |
| 8 | green-doublecheck | All 3 tests PASS on the fixed codebase |
| 9 | green-vbc | SC-2 (behavioral), SC-4 (string), SC-5 (behavioral) verified |
| 10 | adversarial-audit | Dual auditor reviews behavioral tests: correct SC mapping, correct RED/GREEN logic, no lobotomized assertions |
| 11 | cross-validate | Both auditors agree on PASS |
| 12 | regression-check | All existing behavioral tests still pass |
| 13 | review-prep | Behavioral tests registered in test index if applicable |
| 14 | exec-summary | Phase complete, all 4 phases acknowledged |

**RED condition**: 3 behavioral tests — each verifies the fix holds (test runs on the already-fixed codebase, so:
- Test 1: grep verify-merge.md for closure-verification — MUST return no match. Test FAILS if match found.
- Test 2: `opencode-cli run` cleanup prompt — stderr MUST contain closure-verification dispatch. Test FAILS if absent.
- Test 3: grep SKILL.md for corrected text — MUST return match. Test FAILS if absent.

**GREEN condition**: Tests committed as regression prevention for the cleanup pipeline ordering fix.

## Dispatch Markers (Blind Routing)

Each phase dispatches via task() with blind dispatch markers (no file paths, no preloaded context):

| Phase | Marker |
|-------|--------|
| 1 | `cleanup-verify-merge-removal` |
| 2 | `cleanup-branch-audit-add` |
| 3 | `cleanup-skill-crossref` |
| 4 | `cleanup-behavioral-tests` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | verify-merge execution MUST NOT dispatch closure-verification | `behavioral` | opencode-cli run with cleanup prompt → stderr MUST NOT contain closure-verification during verify-merge step |
| SC-2 | branch-cleanup execution MUST dispatch closure-verification as Step 0 before any branch operation | `behavioral` | opencode-cli run with cleanup prompt → stderr MUST contain closure-verification dispatch during branch-cleanup phase, before branch deletion |
| SC-3 | branch-cleanup.md Entry Criteria MUST reference closure-verification as a prerequisite | `string` | grep Entry Criteria section of branch-cleanup.md for "closure-verification" |
| SC-4 | SKILL.md cross-ref MUST say "after issue closure, before branch cleanup" | `string` | grep SKILL.md for the corrected phrase |
| SC-5 | Z3 contract MUST be SAT on initial state, UNSAT on audit-before-close defective state | `behavioral` | solve check on initial state (all false) → SAT; solve check on defective state (AUDIT_PASSED=true, ISSUE_CLOSED=false, PR_VERIFIED=true) → UNSAT |
| SC-6 | Pipeline gate booleans MUST exist in Z3 contract (14 per phase, 4 phases = 56 total) | `structural` | Contract YAML must declare pipeline gate variables (P1_p1 through P4_p14) |