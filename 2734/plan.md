# Plan — .opencode#2734 eliminate the work-record file mechanism

Spec: `.issues/2734/spec.md` (validated 2026-11-12, PASS zero findings,
round 2). All four SCs are structural — the deliverable is deck instruction
text; instruments are executed greps plus content review over the deck
checkout. No build framework is touched; no behavioral tests are authored.
Every item's RED is the executed instrument showing the current defect text;
GREEN is the edit; verification re-runs the instrument.

## Item 1 — Work card §4: delete the record-file definition; state the stateless carriers (SC-1, SC-2, SC-3, SC-4)

- Deliverable: `skills/work/SKILL.md` rule 4 retitled "The scope statement"
  and rewritten: no record file on any surface (explicit statement — git
  directory, working tree, issue folder); provenance verified live at
  act-time and stated in the PR body's Provenance section (which
  `git-workflow-pr` already requires); scope statement carried by dispatch
  prompts and the session's own state, supplied verbatim at dispatch time;
  on the full path the spec artifact already carries scope — no separate
  record; recorded reasons stated in the surface that acts on them.
  The short-path scope statement remains the spec-stage stand-in (the
  collapsed form), now carried in the dispatches that consume it.
- RED: `grep -rn "git-path work-record\|\.git/work-record" skills/ guidelines/ agents/ floor.md`
  → match at `skills/work/SKILL.md:107`.
- GREEN: the §4 record-file passage (the rule-4 heading's definition
  bullets, lines ~104-110) is deleted; the stateless-carrier text above
  replaces it.
- Verify: same grep → zero matches; content review of §4 — no file located
  in a git directory; carriers named with their content.

## Item 2 — Work card outgrowth passage (SC-3)

- Deliverable: `skills/work/SKILL.md` line ~76 — "extends the scope
  statement in the work record" → extends the scope statement held in the
  session's state and dispatch prompts; outgrown work still takes the full
  path from the earliest missing stage.
- RED: `grep -n "work record" skills/work/SKILL.md` → line 76 match.
- GREEN: reworded to the stateless carrier.
- Verify: grep → no work-record file reference in the outgrowth passage;
  content review — outgrowth function intact.

## Item 3 — git-workflow-branch: trunk-freshness step, per-submodule clause, rule 5 (SC-3)

- Deliverable: `skills/git-workflow-branch/SKILL.md` — trunk-freshness step:
  "state the verified tip in the work record, whose provenance part the
  agent writes at this step" → the verified tip is stated in the card's own
  output at execution time and carried into the PR body's Provenance
  section; per-submodule outcomes are stated in the same executed pass's
  output (recorded-not-remediated outcomes reported), never written to a
  record file. Rule 5 (Provenance): record branch, base tip, and issue by
  stating them in the PR body's Provenance section at PR preparation —
  the surfaces are the executed step's output and the PR body; no-issue
  case: branch and base tip only, boundary preserved.
- RED: `grep -n "work record" skills/git-workflow-branch/SKILL.md` → lines
  52, 67, 136.
- GREEN: three rewrites per the deliverable text.
- Verify: grep → zero record-file references; content review — trunk
  freshness and provenance chain still verifiable (tip verified live,
  chain stated in PR body).

## Item 4 — implement card: short-path inline default (SC-3)

- Deliverable: `skills/implement/SKILL.md` lines 92-95 — "requires a scoped
  reason recorded in the work record" → the scoped reason is stated in the
  dispatch prompt that carries the work to the sub-agent (the reason
  travels with the work it justifies).
- RED: `grep -n "work record" skills/implement/SKILL.md` → line 95.
- GREEN: reworded to the dispatch-prompt carrier.
- Verify: grep → zero; content review — dispatch-reason requirement intact.

## Item 5 — version-manager card: rule 7 numbering authority (SC-3)

- Deliverable: `skills/version-manager/SKILL.md` lines 38-40 — justifications
  "in the work record" → stated in the PR body at version-bump time (the
  persistent surface the cycle already produces).
- RED: `grep -n "work record" skills/version-manager/SKILL.md` → line 39.
- GREEN: reworded to the PR-body carrier.
- Verify: grep → zero; content review — numbering-justification recording
  intact.

## Item 6 — verify card: §1 dispatch (SC-3)

- Deliverable: `skills/verify/SKILL.md` lines 17-19 — short-path primary
  artifact: the scope statement as supplied verbatim in the dispatch prompt
  itself; the dispatch includes the scope statement, not a record path.
- RED: `grep -n "work record" skills/verify/SKILL.md` → line 18.
- GREEN: reworded; the dispatched reviewer reads the scope statement from
  the prompt.
- Verify: grep → zero; content review — short-path primary artifact intact
  and current-by-construction.

## Item 7 — git-workflow-cleanup: description and rule 5 (SC-2, SC-3)

- Deliverable: `skills/git-workflow-cleanup/SKILL.md` — description drops
  "and remove the work record"; rule 5 drops "the work record among them"
  (the scratch-files sentence stays — other scratch may still exist, the
  record no longer does).
- RED: `grep -n "work record" skills/git-workflow-cleanup/SKILL.md` → lines
  3, 56 (line 27's "the branch's work recorded" is the verb phrase
  coincidence — left untouched).
- GREEN: two rewrites.
- Verify: grep → only the line-27 verb phrase remains; content review —
  cleanup function intact.

## Item 8 — Necessity gate and boundary statements (SC-4)

- Deliverable: `skills/work/SKILL.md` §4 gains the R-5 necessity gate: no
  persistent agent-authored mid-cycle file is prescribed unless a
  demonstrated failure shows no existing surface suffices, and only through
  governance with the developer's explicit approval of that specific
  mechanism; a missing carrier is reported, never solved by inventing a
  file. The "never create an issue, or initialize an issue store, to
  satisfy provenance" boundary stays in `git-workflow-branch` rule 5.
- RED: content review — no necessity gate in the deck text today.
- GREEN: gate text added in Item 1's §4 rewrite (single-sourced there).
- Verify: content review — gate present and single-sourced.

## Item 9 — tests-v2 comment currency (conditional)

- Deliverable:
  `tests-v2/behaviors/2557-sc17-supervised-polling.sh` line 10 descriptive
  comment mentions the work record; update it only if the revision leaves
  it inaccurate.
- RED: read the comment against the revised cards.
- GREEN: minimal comment accuracy fix if needed; no scenario logic change.
- Verify: the scenario's assertions unchanged; comment accurate.

## Dependency order

Items 1 and 8 (same file, one rewrite) → Items 2-7 (consumers, independent
of each other) → Item 9 (conditional, after the consumers settle). The
final verification pass (SC-1/SC-2 greps over the full surface + fresh-context
content review) runs after all items, per the spec's instruments.

## Item → SC mapping

| Item | SC |
|------|----|
| 1 | SC-1, SC-2, SC-3, SC-4 |
| 2 | SC-3 |
| 3 | SC-3 |
| 4 | SC-3 |
| 5 | SC-3 |
| 6 | SC-3 |
| 7 | SC-2, SC-3 |
| 8 | SC-4 |
| 9 | (comment currency only) |
