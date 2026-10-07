# SPEC-FIX: test-contract currency — behavior changes update dependent tests; suite-green at the PR boundary

Date: 2026-10-07 · Filed from the developer's regression report on PR #2552
("PR was created with failing test suite"). Stacked onto
`feature/2548-issues-store-friction` / PR #2552.

---

## Why

The trunk suite in `.opencode` has been red since before this branch started:

- **`8f59c96b` (#2546, issue #2543)** removed `.counter`/`_next_number`
  per its spec ("per-repo numbering: … .counter/_next_number removed incl.
  doctor marker") but left `tests/test_local_issues/test_counter_targeting.py`
  in the suite — 3 assertion failures against behavior that no longer exists
  by spec'd design.
- **`6dbac1ae` (#2490 deck rip)** attic'd
  `skills/skill-creator/scripts/validate_skill_cards.py`, leaving
  `tests/test_skill_creator/test_condensation_gate.py` — a self-described
  RED-phase test for a condensation gate that was never implemented — as 10
  collection errors (import of the missing script).
- `tests/test_local_issues/test_validate_yaml_scoped.py::
  test_scoped_fail_fast_on_absent_target` asserts the pre-#2543 fail-fast
  contract; the tool now honors the #2543 contract ("scoped validate on
  absent target exits 0 with no-local-records") and prints exactly that.

Observed consequence: PR #2552 was created with 4 failed / 10 errors, passed
off as "pre-existing." The `git-workflow-pr` invariant ("the full test suite
ran this session with captured output") was satisfied by *running* a red
suite — no card requires the suite to be **green**, nor that a behavior
change update the tests that contract on the changed behavior. The defect is
systemic: two merged PRs each left stale tests behind.

## What

- **C1 — Test-contract currency in the implement card.**
  `skills/implement/references/implementation-workflow.md` gains the rule:
  a behavior change updates its dependent tests in the same cycle (tests
  contract on behavior; when the behavior is spec-removed, the stale tests
  are removed/updated with the same commit chain), and post-implementation
  includes suite-green: any failure is remediated or dispositioned by a
  filed fix — never passed through as "pre-existing."
- **C2 — Suite-green at the PR boundary.** `skills/git-workflow-pr/SKILL.md`
  item 2(b) tightened: the full suite ran **green** this session; red output
  blocks PR creation until remediated or dispositioned via a filed fix issue.
- **C3 — Stale tests fixed.** (a) delete
  `tests/test_local_issues/test_counter_targeting.py` (tests spec-removed
  `.counter` semantics, #2543 SC-3/4/6); (b) delete
  `tests/test_skill_creator/test_condensation_gate.py` (RED test for a
  never-implemented, attic'd script — mechanism retirement is deck
  governance, not this fix); (c) update
  `test_scoped_fail_fast_on_absent_target` to assert exit 0 + stdout
  `no-local-records: <qualifier>#<N>` per the #2543 contract.

Deck-card edits (C1, C2) pass the skill-creator governance gate: observed
failure = this regression (evidence: PR #2552, commits `8f59c96b`,
`6dbac1ae`); consumer = implement/PR agents; mechanism = card text read at
cycle start and PR-boundary check.

## Success criteria

| ID | Criterion | Evidence type | Verification instrument |
|----|-----------|---------------|-------------------------|
| SC-1 | The full `.opencode` test suite exits 0 with zero failures and zero errors. | behavioral | `.venv/bin/python -m pytest tests/ -q` from `.opencode` → exit 0, no FAILED/ERROR lines. |
| SC-2 | The implementation-workflow reference states that a behavior change updates dependent tests in the same cycle and that the suite must be green (or dispositioned via a filed fix) before the cycle completes. | structural | `grep -n "dependent tests" .opencode/skills/implement/references/implementation-workflow.md` → ≥1 match. |
| SC-3 | The PR card states the suite must be green — not merely run — before PR creation. | structural | `grep -n "green" .opencode/skills/git-workflow-pr/SKILL.md` → ≥1 match in the pre-create checklist. |
| SC-4 | No test in the suite contracts on removed behavior: no test references `.counter` or `validate_skill_cards.py`. | structural | `grep -rn "\.counter\|validate_skill_cards" .opencode/tests/` → no matches. |

## Out of scope

- Reimplementing the condensation gate or `.counter` autonumbering — both
  removed by merged, spec'd decisions (#2490, #2543); resurrecting either is
  new feature work.
- CI wiring to enforce suite-green mechanically — deck change with its own
  admission gate; the card rule is intent-decidable guidance here.
- The 4 pre-existing failures' root causes beyond what C3 already covers
  (all four are the stale-contract cases enumerated above).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
