# Plan Input Verification Ledger — .opencode#2444

Generated 2026-09-13 by writing-plans/tasks/create. All input facts verified once
below; downstream steps re-read THIS ledger, not the sources.

## Issue State (from issue.yaml, read 2026-09-13)

- Issue: .opencode#2444
- Title: `spec-creation validate task BLOCKED: 4 canonical reference files missing from skill deck`
- Status: open
- Labels: [approved-for-pr] (authorization scope: for_pr → pr_strategy: stacked)
- Spec: .opencode/.issues/2444/spec.md (passed spec-audit rounds 4-5, retroactively imported)

## SC List with Evidence Types (from spec.md Success Criteria table + testability-assessment.yaml)

| SC | Criterion (summary) | Evidence Type |
|---|---|---|
| SC-1 | tasks/validate.md contains no reference link resolving to a nonexistent path (4 corrected references verified by filesystem check) | structural |
| SC-2 | validate-task dispatch's reference-deck integrity check locates all 4 canonical files at paths stated in validate.md — via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`, run passes gate without `reference-deck-integrity: FAIL` | behavioral |
| SC-3 | No file in .opencode/skills/spec-creation/ references `reference/` or `audit/reference/` paths that fail resolution — full grep audit | structural |

## Structure Artifact Phase/SC Mappings (from structure.yaml)

- Phase A — Structural reference-path corrections — SCs: SC-1, SC-3 — Depends: —
  - Item 1 (SC-1): validate.md 4 reference paths corrected (lines 24, 28, 30, 72, 97)
  - Item 2 (SC-3): create.md sibling fix (lines 43, 45) + full-directory grep audit
  - Internal order: Item 1 → Item 2 (SC-3's audit passes only after SC-1's fix)
  - Cycle: pre-regression → red → green → post-regression → verify → commit-inline
- Phase B — Behavioral validation — SCs: SC-2 — Depends: A
  - Item 3 (SC-2): isolated behavioral validate dispatch passes reference-deck gate
  - GREEN n/a (re-verification; fixes landed in Phase A) — step stays assigned in Phase B
  - Behavioral ordering per 091: COMMIT + PUSH + fresh git fetch (effective commit contained
    in a remote ref) BEFORE the behavioral run; bash timeout >= 600000 ms
- DAG: A → B (single edge, no cycles)
- Triplet colocation verified (no SC split across phases); no cross-phase RED dependencies

## Skill+Task Dispatch Strings (from implementation-workflow reference card, read this session)

- pre-regression → task(..., prompt: "execute phase-0 task from test-driven-development")
- pre-regression-verify → task(..., prompt: "execute verify task from verification-before-completion")
- red → task(..., prompt: "execute red task from test-driven-development")
- green → task(..., prompt: "execute green task from test-driven-development")
- post-regression → task(..., prompt: "execute phase-4 task from test-driven-development")
- verify → task(..., prompt: "execute verify task from verification-before-completion")
- commit-inline → orchestrator direct: git add <files> && git commit -m "<message>"
- audit → task(..., prompt: "execute verification-audit DiMo investigator from audit. Read `audit/tasks/verification-audit-investigator.md` first") — followed by validator, evaluator, arbiter in sequence
- z3-check → orchestrator direct: .opencode/tools/solve check --state-path ... --contract-path ...
- structural-checks → task(..., prompt: "execute checklist task from finishing-a-development-branch")
- pre-pr-gate → task(..., prompt: "execute verify task from verification-before-completion") — reads all SC verdicts, BLOCKs if any FAIL
- regression-check → task(..., prompt: "execute phase-4 task from test-driven-development")
- review-prep → task(..., prompt: "execute review-prep from git-workflow-pr. Read `git-workflow-pr/tasks/review-prep.md` first")
- create-pr → task(..., prompt: "execute create task from git-workflow-pr")
- exec-summary → task(..., prompt: "execute completion task from completion-core")

## CLI Surface Flags (verified live this session)

- `local-issues update --number <N-or-repo#N> --labels <LABELS...>` — labels are
  space-separated variadic; REPLACES the entire labels array (pinned convention #11)
- Canonical local label write required: `./.opencode/tools/local-issues update --number .opencode#2444 --labels approved-for-pr spec-cleared`
  (existing label approved-for-pr + new spec-cleared — full array, no omission)
- Remote label write: best-effort secondary; failure logs and continues, never blocks

## Analytical Artifacts (all 7 present, backfilled 2026-09-13)

blast-radius.yaml, code-path-inventory.yaml, concern-map.yaml, cross-cutting-matrix.yaml,
interface-compatibility.yaml, state-analysis.yaml, testability-assessment.yaml — all
verified present in artifacts/ this session.

## Key Facts for Plan Composition (settled — do not re-verify)

- Fix idiom: ../../../ prefix (tasks → spec-creation → skills → .opencode)
- 7 link instances: validate.md lines 24, 28, 30, 72, 97; create.md lines 43, 45
- 4 canonical targets: .opencode/reference/{holistic-dimensions.yaml,
  spec-structure-standards.md, cost-model-standards.md}, .opencode/audit/reference/decomposition-criteria.md
- Affected files: .opencode/skills/spec-creation/tasks/{validate.md, create.md} (.opencode submodule)
- Global invariants: no reference-file content changes, no new files, parent-repo submodule
  pointer rides along with next real parent-repo change (never standalone)
- SC-2 harness preconditions: with-test-home isolation MANDATORY, standalone binary cached at
  .tools/opencode/opencode, bash timeout >= 600s, `rm -f tmp/.behavior-run.lock` before re-runs
- SC-2 substitution prohibited (critical-rules-060): cannot execute → FAIL, never grep substitute
- Pre-fix behavioral evidence: 2026-09-12 blocked run, NewSRX-Tech-LLC/Butter#346 (reference-deck-integrity: FAIL)
