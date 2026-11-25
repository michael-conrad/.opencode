# Plan — .opencode#2768 git-workflow-branch foreclosure of the complete-at-filing reading

## Goal

Implement the spec at `.opencode/.issues/2768/spec.md`: amend `git-workflow-branch` rule 1's scope-boundary passage to foreclose the complete-at-filing reading (a filed-but-unmerged PR leaves its authorization scope unfinished), add the one-line cross-reference to `git-workflow-pr` rule 3's stacked-PR definition, and prove the extended rule's behavior with a tests-v2 behavioral scenario. Artifact surfaces: `skills/git-workflow-branch/SKILL.md` (rule 1 scope-boundary passage + provenance line only) and `tests-v2/behaviors/`.

## Execution surface

Repository: the `.opencode` submodule checkout (upstream `michael-conrad/.opencode`), working branch created from its trunk tip 9b84a7670076bcbf75257162dc9afe4e45b1ad3c (verified at-tip 2026-11-25). The deck is a text corpus with a pytest unit suite under `tests/` and behavioral scenarios under `tests-v2/behaviors/`; build/test vehicle is the composed parent's declared command `cd .opencode && uv run pytest` (build-tooling exclusivity: the parent's documented framework). The behavioral harness for SC-4 is `tests-v2/` (provisions its GitBucket container; governed by the `behavioral-testing` card at implementation time).

## Items

### Item 1 — Amended scope-boundary passage with foreclosure and cross-reference

- **Deliverable**: rule 1's scope-boundary passage in `skills/git-workflow-branch/SKILL.md` extended in place: after the existing extension sentence, the foreclosure sentence(s) stating (a) a filed-but-unmerged pull request leaves its authorization scope unfinished and "PR filed" is not scope closure; (b) the complete-at-filing reading does not govern the rule's "unfinished" predicate; (c) until the scope's PR merges or the developer names a split, a later same-scope work directive is scope-extension — its commits land on the scope's open branch, no new branch opens; (d) the scope's open PR is amended into the stacked-PR shape — one PR carrying one squashed commit per issue in the scope, the body closing every stacked issue — rather than a parallel PR; plus the cross-reference to `git-workflow-pr` rule 3's stacked-PR definition so the term of art binds at branch-extension time (stacked-worded approval read on the branch side means the rule-3 shape), in the canonical cross-reference form `Read [Text](path)`.
- **RED**: reading rule 1 at trunk shows the extension sentence with no foreclosure statement — the passage nowhere states that a filed-but-unmerged PR leaves the scope unfinished; asserting (a)–(d) against the pre-amendment text fails.
- **GREEN**: the minimal text amendment of rule 1's scope-boundary passage stated above; no other clause of the card is touched, and the existing extension sentence survives (the foreclosure extends it, never replaces it).
- **Tier marks**: no authored test; instruments are fact checks (read + grep of the amended text).
- **Instrument**: read the amended rule 1 text; assert elements (a)–(d) are each stated (SC-1) and the cross-reference names `git-workflow-pr` rule 3 and the stacked-PR shape (SC-2). Note: SC-1 and SC-2 assert the same single passage edit — the amendment is one atomic text change carrying one concern (the foreclosure with its term-of-art anchor), so this one item delivers both criteria.

### Item 2 — Confinement: diff discipline and provenance entry

- **Deliverable**: `skills/git-workflow-branch/SKILL.md`'s provenance line gains exactly one new entry citing `#2768`; the diff of the amended card against its pre-amendment trunk state (9b84a7670) has hunks only in rule 1's scope-boundary passage and the provenance line, contains no repository names and no absolute paths, and leaves every other clause byte-identical.
- **RED**: the pre-amendment provenance line carries no #2768 entry; asserting "exactly one provenance entry citing this issue" against trunk fails.
- **GREEN**: add the single provenance entry. Item 1's text amendment is item 2's precondition.
- **Tier marks**: no authored test; instrument is a fact check (git diff + grep sweep).
- **Instrument**: `git diff` the card against 9b84a7670 — assert hunk locations, exactly one provenance addition, and sweep for repository names / absolute paths: none present.

### Item 3 — Behavioral scenario: mid-scope directive rides the open branch and PR

- **Deliverable**: a new `tests-v2/behaviors/` scenario script exercising SC-4's shape: a live opencode run against the harness-provisioned container, given an open PR for a scope's feature branch, a later mid-scope work directive in the same authorization scope, and the terminal token `approved for stacked PR` — asserted end state: the new commits land on the scope's open branch; no new branch opens; the scope's single open PR carries one squashed commit per stacked issue with a body closing every stacked issue; no second branch, no second PR, and no new spec record for the added work exist at run end.
- **RED**: the scenario run against the pre-amendment deck fails — the pre-amendment rule's passage does not bind the branch-side complete-at-filing reading, and the run's session produces (or halts defending) a second-branch/second-PR shape or asserts foreclosure language the card lacks.
- **GREEN**: item 1's amended rule 1 turns the scenario green; the amendment itself is item 1's deliverable (this item authors only the scenario script). The existing fixture `tests-v2/behaviors/2639-sc8-second-directive-rides-open-pr.sh` re-runs unchanged after item 1 as changed-area regression, per the spec's Not-Included 6.
- **Tier marks**: the new scenario script is authored `pr-validation` (this PR's ticket-validation test; runs at PR-check/implementation time, dispositioned at merge). The 2639-sc8 fixture is existing `regression` (default gate).
- **Instrument**: the tests-v2 behavioral harness under the `behavioral-testing` card — artifact capture plus clean-room evaluation from the container's branch/PR API state and the session record, per SC-4's instrument column.

## Dependency order

Item 1 first: the amended text is both SC-1/SC-2's subject and item 2's diff-under-check and item 3's GREEN precondition. Item 2 second: the confinement check runs against the completed amendment state (the diff is over items' combined card edit; item 2's provenance edit rides the same file but its own check is the diff discipline). Item 3 last: the behavioral scenario is meaningful only against the amended rule; per-item RED→GREEN→verify→commit runs in that order.

## Traceability

| Item | SC(s) |
|---|---|
| Item 1 | SC-1, SC-2 (R-1, R-2) |
| Item 2 | SC-3 (R-3) |
| Item 3 | SC-4 (R-1, R-2) |

Every SC is covered; every item traces to the spec — no orphans.

## Verification summary

Tiers relied on: fact checks (read/grep/diff) verify SC-1–SC-3; SC-4 verifies through a harness behavioral run whose authored artifact is the `pr-validation` scenario script (authored in item 3, run at implementation/PR-check time, dispositioned at merge). The existing 2639-sc8 `regression` fixture rides the default gate as changed-area regression. Deck unit suite (`cd .opencode && uv run pytest`) runs smoke-level at cycle time to confirm no structural/governance test regressions. Runs at cycle time: item-level instruments and the suite; at PR-check time: the pr-validation behavioral scenario's final dispositioned run.

## Status boundary

Implementation state lives in the pipeline and the issue's validation record; this body carries no status fields.
