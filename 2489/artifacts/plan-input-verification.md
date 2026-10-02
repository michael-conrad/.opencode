# Plan Input Verification Ledger — .opencode#2489

Written once 2026-10-02. All subsequent plan-composition steps re-read THIS ledger, not the sources.

## Issue state + labels (from issue.yaml)

- status: open
- labels: `[approved-for-pr]` (single label — label writes must preserve it and append `spec-cleared`)
- remote: git@github.com:michael-conrad/.opencode.git (platform github, owner michael-conrad, repo .opencode)
- title: [SPEC-FIX] Holistic submodule pointer discipline: remove pre-commit stale-pointer gate, consolidate tag canon, repair dead references

## Authorization

- authorization_scope: for_pr (user context) → frontmatter `authorization_scope: for_pr`, `pr_strategy: stacked`
- HALT after pr_created.

## Authoritative SC list (from spec.md SC table — 13 SCs; sc-summary.yaml is STALE at 8 SCs, ignored)

| SC | Criterion (short) | Evidence type |
|----|-------------------|---------------|
| SC-1 | Gate 2 + SKIP hatch removed from pre-commit hook | behavioral |
| SC-2 | Gate 1 trunk-branch block unchanged (exit 1) | behavioral |
| SC-3 | Five dependent gate tests deleted | structural |
| SC-4 | No orphaned runners in tests-v2 | string |
| SC-5 | Advisory text free of stale-pointer/SKIP wording | string |
| SC-6 | Advisory text references PR-time gates (Steps 0/0.5/0.75) | string |
| SC-7 | Six tag rules present in operating-protocol.md "Tag Convention (Canonical)" | string |
| SC-8 | Zero refs to git-workflow/SKILL.md §Tag Convention | string |
| SC-9 | Zero refs to nonexistent AGENTS.md sections | string |
| SC-10 | Repaired links use inline Read [Text](path) form | semantic |
| SC-11 | Six Tag-Format Site Inventory sites carry suffixed form | string |
| SC-12 | Reference-integrity check fails on deliberate broken probe | behavioral |
| SC-13 | Reference-integrity check passes on repaired repo | behavioral |

## Coordination mandates (outside SC table)

- CM-1 (was R-9): ceremony-test retirement policy recorded in retire path (test card header / tests-v2 AGENTS note); policy audit reads recorded text for both clauses. Depends on SC-3.
- CM-2 (was R-8): #2431 handover comment + #2258 superseded-with-rationale annotation; API read of both threads; branch states confirmed. Depends on SC-1. API-only, no code commit.

## Structure artifact mappings (structure.yaml)

- Phases: 1 hook gate removal (SC-1, SC-2; CM-2) → 2 test retirement + ceremony policy (SC-3, SC-4; CM-1) → 3 advisory rewrite (SC-5, SC-6) → 4 integrity check build (SC-12) → 5 reference repair (SC-8, SC-9, SC-10) → 6 integrity verification + tag format (SC-13, SC-11).
- Phase DAG edges: 1→2 (SC-1→SC-3), 1→3 (SC-1→SC-5), 4→5 (SC-12→SC-8/9/10), 5→6 (SC-8/9/10→SC-13), 2→4 (ordering only). Acyclic, no cycles.
- Triplet colocation: PASS (all RED/GREEN/COMMIT steps in a single phase; SC-13 verification-only, no commit).
- Evidence types per phase: p1 behavioral, p2 structural/string, p3 string, p4 behavioral, p5 string/semantic, p6 behavioral/string.

## Spec dependency DAG (spec.md §Dependencies / dependency-contract.yaml)

SC-12 → SC-8/SC-9/SC-10 → SC-13 → SC-11; SC-1 → SC-3, SC-5, CM-2; SC-3 → SC-4, CM-1; SC-5 → SC-6; SC-2 → SC-1.

## Key fixed mappings (do not re-derive)

- Dead-Reference → Live-Target Mapping (spec §R-5): 15 sites — 6 SKILL.md §Tag Convention → operating-protocol.md "Tag Convention (Canonical)"; 7 AGENTS.md-section refs (§Tag Layers ×4, §Tag-Based Hash Permanence ×2, §Idempotent Tag-if-Untagged ×1) → same canonical section; pre-work.md "Skipping Git Pre-Check" ref → git-workflow-branch/SKILL.md §[critical-rules-005]; pre-work.md enforcement/halt-conditions.md ref → git-workflow/enforcement/halt-conditions.md "observe/ Branch Discard Enforcement".
- Tag-Format Site Inventory (closed, 6 sites, phrase-anchored, all in .opencode/skills/git-workflow-branch/tasks/): pre-work.md Step 3 item 5 tag line; pre-work.md Step 4 commit-message template; provenance.md "Tag-based provenance (Tier 3)" paragraph; provenance.md tier-table Pre-work row; pre-work.md Step 5 rebase command; pre-work.md Step 5 checkout command. trunk-push-provenance.md trunk-push tagging step EXCLUDED (already suffixed).
- Tag-Rule Inventory (closed, 6 rules for SC-7): suffix rule, hash-permanence tag, checkpoint tag, release tag, idempotent tag-if-untagged, hash permanence replaces dependency-sync PRs.
- Five dependent tests to delete: tests-v2/test-2264-sc3-different-trunk-submodule.sh, test-2264-sc4-shared-trunk-submodule.sh, test-2264-sc6-two-submodule-verification.sh, test-2264-sc7-bug-only-override-uses.sh, behaviors/2219-sc16-stale-pointer-block.sh.
- branch-cleanup.md lives at .opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md (analyze note).

## CLI surface flags needed

- `.opencode/tools/local-issues update .opencode#2489 --labels spec-cleared,approved-for-pr` — update REPLACES the labels array; must include all existing labels (approved-for-pr) plus spec-cleared.
- Behavioral instrument: `bash .opencode/tests-v2/with-test-home opencode run '<message>'` (>=600s bash timeout; R-10 forbids structural substitutes for SC-1/SC-2/SC-12/SC-13).
- Z3 check: `.opencode/tools/solve check --state-path ... --contract-path ...` with dependency-contract.yaml.

## Dispatch reference (implementation-workflow.md, verified)

- Pre: pre-regression (tdd phase-0), pre-regression-verify (vbc verify)
- Per-SC: red, green, post-regression (tdd phase-4), verify (vbc), commit-inline (orchestrator direct)
- Post: audit, z3-check (orchestrator direct), structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary
- Coercion rules: DONE_WITH_CONCERNS → FAIL; EVIDENCE_TYPE_MISMATCH → FAIL.

## No plan.md exists yet at .opencode/.issues/2489/plan.md (verified via ls)
