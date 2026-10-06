# Plan — #2518 + #2525 stacked (verify-bar invariance, pipeline continuation)

**Branch**: `feature/2518-verify-criteria-invariance` (base: `1460807c` = origin/main) · **Spec**: `.opencode/.issues/2518/spec.md`

## Item 1 — SC-1/SC-2/SC-4: verify card criteria-invariance clause

- **Deliverable**: `skills/verify/SKILL.md` gains the criteria-invariance content inside the existing card structure (loop description / churn-rule area — no new top-level sections beyond what the card needs).
- **RED**: `grep -i "criteria" skills/verify/SKILL.md` finds no invariance statement; a re-audit prompt re-authoring the pass condition has no card text contradicting it.
- **GREEN**: Add the clause: same declared criteria set for every audit and re-audit; re-audit prompts restate it verbatim; pass condition never re-authored at dispatch time; post-verdict notes/directives feed the revision step, not a new bar; bar changes go through deck governance; a bar-redefinition directive is a halt-and-clarify trigger.
- **Verify**: grep the clause elements; card reads coherently with the churn rule (which stays noise-suppression-only, never observation-suppression).

## Item 2 — SC-3/SC-4: work card continuation rule

- **Deliverable**: `skills/work/SKILL.md` gains the continuation statement (path-selection or boundaries area).
- **RED**: card text has no rule for terminal authorization + missing upstream artifacts; the #2525 halt path is unguarded.
- **GREEN**: Add: a terminal-stage authorization runs the pipeline from the earliest missing stage under the granted authorization; downstream card gates (e.g. PR readiness) are reached by running the pipeline — they are never reasons to halt; halt only when the authorization's meaning itself is genuinely ambiguous.
- **Verify**: grep the card; read for conflict with the existing "Unsure which path fits? Halt" line — the halt line governs path *selection* uncertainty, not missing artifacts.

## Item 3 — SC-4: floor anchors

- **Deliverable**: `floor.md` authorization vocabulary — at most one semantic line per fix, citing the cards: (a) `audit`/`re-audit` entries note bar changes go through deck governance (`verify` card); (b) `approved for pr` / terminal entries note missing upstream artifacts trigger the pipeline (`work` card). If an existing line already carries an anchor's meaning, edit it rather than adding a line.
- **RED**: vocabulary has no anchor for either hazard.
- **GREEN**: minimal one-line anchors, no verbatim card text.
- **Verify**: floor diff ≤ 1 semantic line per fix; no verbatim duplication with cards.

## Item 4 — SC-5: provenance + commit

- **Deliverable**: provenance lines in the three edited files updated to cite #2518/#2525; single squashed commit per stacked-issue discipline happens at PR creation (`git-workflow-pr`); commit on this branch cites #2518 with #2525 noted stacked.
- **Verify**: `git -C .opencode diff main` shows only the three files; provenance updated.

## Verification instruments (post-implementation)

- Behavioral SC-2/SC-3: `opencode run` scenarios per the behavioral-testing reference, one per SC, capturing real output for the PR body.
- Structural SC-1/SC-4/SC-5: grep + diff checks with captured output.
