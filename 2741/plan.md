# Plan — .opencode#2741 (git-workflow-pr not-done default)

**Spec:** `.opencode/.issues/2741/spec.md` (validated PASS, zero findings).
**Target:** `skills/git-workflow-pr/SKILL.md` rule 1 (PR-completion invariant) — deck repository.

## Item 1 — Restate rule 1 with the not-done default and complete/resume framing (SC-1, SC-3 scope guard)

- **Deliverable:** Rule 1's text at `.opencode/skills/git-workflow-pr/SKILL.md` states that on PR-boundary authorization the agent assumes the work is NOT completed and determines actual state from evidence (commits, test records, verify records); the two operations are complete-the-remaining-workflow or resume-it-from-the-record; "already complete" is entered only as a check outcome. Provenance line records the change (`.opencode#2741`). All other gates (verification, verify-PASS, structural checks, merge boundary) restated unchanged.
- **RED:** Grep rule 1's current text for the not-done-default statement — absent (`git-workflow-pr/SKILL.md` lines 14–27 carry the (a)-or-(b) framing with no default state), which is the observed failure the developer reported.
- **GREEN:** Edit rule 1's opening paragraph: lead with the not-done default, evidence-first state determination, and the complete/resume operations; keep branches (a)/(b) as check outcomes.
- **Instrument:** `grep` the rule-1 section for the not-done-default sentence and the complete/resume framing (SC-1); then `git diff` the card file against the trunk — the diff touches only rule 1 + provenance (SC-3).
- **Tier:** no authored test file — verification is structural instrument output recorded in the PR's Evidence section.

## Item 2 — Verification of the stated default (SC-2)

- **Deliverable:** Recorded clean-room verification that the revised rule-1 text establishes the not-done default and routes an `approved for pr` session whose post-spec work is absent to performing or resuming the remaining workflow before PR prep.
- **Instrument (revised mid-cycle, implement card §4):** the plan originally named the tests-v2 behavioral harness; the change's deliverable is a one-card wording change — tier-1 eligible by the behavioral-testing card's own judgment class ("simple card changes"), and the granularity rule (test-discipline §1) pushes verification down the tiers when a lower tier reaches the behavior. Evidence is the recorded tier-1 clean-room dispatch (prompt, criterion judged, verdict persisted into the issue's audit artifacts) — no harness run required.
- **RED/GREEN:** RED (pre-edit text, confirmed at Item 1's RED step): the (a)-or-(b) framing with no default state yields the assumed-complete failure mode. GREEN: the committed rule-1 text states the not-done default, the complete/resume operations, and already-complete as an outcome-only state.
- **Tier:** tier-1 clean-room dispatch (not an authored test file; verdict record persisted).

## Dependencies

Item 2 depends on Item 1's text change (behavior verifies the new default). SC-3's instrument executes at Item 1's close and is re-confirmed at PR-prep time on the final diff.

## Traceability

| Item | SC |
|------|-----|
| 1 | SC-1, SC-3 |
| 2 | SC-2 |

## Documentation Sources

- `git-workflow-pr/SKILL.md` (target card)
- `.opencode/.issues/2741/spec.md` (criteria source)

## Enforcement Gate

Rule 1's revised text governs the PR-boundary invocation; the human merge boundary in the same card is untouched and out of scope.

## Cost Frame

One file edited (rule-1 paragraph + provenance line); one behavioral harness run.

## Edge Cases

- Session context may already record executed test/verify output from the same session — the evidence-first determination reads the session's own record; "not done" remains the checked default, not a forced redo.
- Short-path work (no spec artifact) — rule 1's short-path sentence stays; the not-done default applies identically to it.

## Not Included

Authorization vocabulary (floor), PR-body contract, merge/approval gate, `work` card stage gates — per spec's out-of-scope section.
