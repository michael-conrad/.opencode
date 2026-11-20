# Plan — .opencode#2753

**Goal.** Implement spec `.opencode/.issues/2753/spec.md`: the release
candidate composition promotes every registered submodule to its resolvable
remote trunk tip (branch field, else `refs/remotes/origin/HEAD` — never the
checkout's current branch), unresolvable or unfetchable tips halt
composition, pointer recording is plumbing-first with a mandatory
post-commit `git ls-tree` assertion, `DRIFT_FAIL` triage gains the
composition-defect/candidate-defect distinction, and the
`git-workflow-branch` rule-2 release carve-out cross-references the mandate.
Surfaces: `skills/release-promoter/SKILL.md` (rule 0),
`skills/release-promoter/references/operating-protocol.md` (Phase C-0,
drift assertion), `skills/git-workflow-branch/SKILL.md` (the **Release
carve-out (.opencode#2750)** paragraph in rule 2),
`tests-v2/behaviors/` (new scenarios).

**Execution surface.** Deck repository `michael-conrad/.opencode`, branch
`feature/2753-release-composition-and-2755-repair-trigger`, trunk tip
`e237255c0` (verified at branch time). Behavioral items run the `tests-v2`
harness per the behavioral-testing card.

## Items

### Item 1 — SC-1: trunk-tip mandate in SKILL.md rule 0

- **Deliverable:** rewrite `skills/release-promoter/SKILL.md` rule 0: the
  trunk tip resolves through the `.gitmodules` `submodule.<name>.branch`
  field, else the submodule remote's default branch (`refs/remotes/origin/HEAD`,
  existence guarded) — never the checkout's current checked-out branch;
  `no-remote-tip` no longer exists as a recorded-and-continue outcome on the
  release path — a registered submodule whose remote trunk tip cannot be
  resolved or fetched halts composition for developer direction; composition
  is done when the executed comparison returns `at-tip` for every registered
  submodule, and that outcome is the success evidence. The capture clause
  gains the plumbing-first recording and post-capture assertion named in
  item 3.
- **RED:** grep rule 0 → "`no-remote-tip` is synced when a branch resolves,
  else recorded" present; the chain names no branch-field→`origin/HEAD`
  order.
- **GREEN:** replace the rule-0 text with the mandate and blocking
  disposition.
- **Tier marks:** no authored test; instrument fact check.
- **Instrument:** grep rule 0 — the recorded-and-continue phrasing is gone;
  the chain, the halt, and the `at-tip`-for-every-registered-submodule
  success evidence are present.

### Item 2 — SC-1: trunk-tip mandate in Phase C-0 steps 2–3

- **Deliverable:** rewrite `operating-protocol.md` Phase C-0 steps 2–3:
  step 2's resolution chain drops the checkout's-current-branch fallback
  (branch field, else `refs/remotes/origin/HEAD` with existence guard) and
  records `at-tip` / `behind` / unresolvable instead of `no-remote-tip`; step
  3 promotes every registered submodule and states that an unresolvable or
  unfetchable trunk tip halts composition for developer direction — the
  "else recorded as the instrument's own outcome" sentence is deleted; step
  4's unreachable-remote halt stays, now subsumed by the resolution-side
  halt.
- **RED:** read steps 2–3 → the current-branch fallback and the
  "else recorded" sentence are present.
- **GREEN:** replace both steps' text.
- **Tier marks:** no authored test; instrument fact check (read/grep).
- **Instrument:** grep the protocol — no recorded-and-continue language
  remains anywhere on the release composition path; the chain and blocking
  disposition state as written.
- Item 2 lands after item 1: the rule (SKILL.md rule 0) is the card's head
  surface the protocol paragraph points to; delivering the card surface
  first keeps the two consistent if the cycle pauses between them.

### Item 3 — SC-4, SC-5: plumbing-first capture with post-commit assertion

- **Deliverable:** extend `operating-protocol.md` Phase C-0 step 8
  (recording mechanism and assertion) and SKILL.md rule 0's capture clause
  (one-line statement): pointer recording never passes through
  `git add <submodule-path>` when the submodule checkout's HEAD differs from
  the promoted SHA; recording uses index plumbing (`git rm --cached` +
  `git update-index --add --cacheinfo`) or checks out the promoted SHA
  first; a mandatory post-capture assertion — `git ls-tree HEAD <path>` ==
  promoted SHA for every promoted submodule — gates the capture commit
  before push; a mismatching assertion aborts the capture, names the
  mismatching submodule, and no push occurs.
- **RED:** read step 8 and rule 0's capture clause → no recording mechanism,
  no post-capture assertion.
- **GREEN:** add the mechanism, the prohibition, and the pre-push assertion.
- **Tier marks:** no authored test; instrument fact check (read).
- **Instrument:** read both surfaces; fails if mechanism, prohibition, or
  assertion is absent.

### Item 4 — SC-6: DRIFT_FAIL two-class triage

- **Deliverable:** the Phase A drift-assertion step's failure handling names
  two classes: a pinned SHA not fetchable from the submodule's remote
  ("Server does not allow request for unadvertised object") is a composition
  defect → recompose; a fetchable-but-mismatched pointer is a candidate
  defect → release blocked. The gate's no-retry rule is unchanged.
- **RED:** read the drift-assertion step → `DRIFT_FAIL` carries no class
  distinction.
- **GREEN:** add the two-class triage to the `DRIFT_FAIL` handling text.
- **Tier marks:** no authored test; instrument fact check (read).
- **Instrument:** read the triage; fails if the classes are unnamed or
  assigned the same route.

### Item 5 — SC-7: carve-out cross-reference

- **Deliverable:** extend the **Release carve-out (.opencode#2750)** paragraph
  in `skills/git-workflow-branch/SKILL.md` rule 2 (the standalone
  "**Release carve-out**" paragraph following rule 2(c)'s deferral rule): it
  names the composition phase's mandate — all registered repos at remote
  trunk tips in a release PR, always; unresolvable tips block composition for
  developer direction — and the release path's resolution chain (branch
  field, else `refs/remotes/origin/HEAD`), deliberately diverging from this
  rule's general chain, which permits the checkout's current branch. The
  bounded recorded-not-remediated posture stays scoped to the general branch
  path.
- **RED:** read the carve-out paragraph → it references the composition
  phase's executed comparison without the blocking disposition or the
  divergent release-path chain.
- **GREEN:** extend the carve-out paragraph.
- **Tier marks:** no authored test; instrument fact check (read).
- **Instrument:** read the carve-out paragraph; fails if the cross-reference
  lacks the blocking disposition or names the general chain for the release
  path.
- Item 5 lands after items 1–2: it cross-references the mandate those items
  deliver, so the referenced text exists before the reference.

### Item 6 — SC-2: behavioral scenario, promotion to trunk tip

- **Deliverable:** tier-2 scenario `tests-v2/behaviors/2753-promote-trunk-tip`
  with fixture parent+submodule repos (recorded pointer behind
  `origin/HEAD`; checkout on a no-remote-tip feature branch with dirty
  worktree); clean-room evaluation asserts the composed parent's recorded
  gitlink SHA == the submodule's remote trunk-tip SHA.
- **RED:** an executed supervised run against the pre-GREEN deck state shows
  the recorded `no-remote-tip` outcome and the stale pointer composed; the
  field reproduction (.opencode#2753, 2026-11-19, `0ce8954b` composed) is
  corroboration only — the executed run is required because SC-2's instrument
  is the harness.
- **GREEN:** after items 1–2, evaluation asserts the promoted gitlink;
  generator exits 0; evaluation is the clean-room dispatch's job.
- **Tier marks:** tier-2 behavioral (heavy, supervised cycle-time run).
- **Instrument:** executed manifest + clean-room evaluation verdict.

### Item 7 — SC-3: behavioral scenario, unresolvable tip halts composition

- **Deliverable:** scenario `tests-v2/behaviors/2753-unresolvable-tip-halt`
  with a fixture registered submodule carrying no `.gitmodules` branch field
  and no `origin/HEAD` default ref; evaluation asserts the composition
  aborts with the named halt outcome for developer direction and no release
  branch or PR exists.
- **RED:** executed supervised run on pre-GREEN deck state composes past the
  unresolvable tip (recorded outcome) — corroboration: the field run's
  recorded `no-remote-tip`; the executed run is required.
- **GREEN:** after items 1–2, evaluation asserts the halt with no release
  branch/PR; generator exits 0.
- **Tier marks:** tier-2 behavioral (heavy, supervised cycle-time run).
- **Instrument:** executed manifest + clean-room evaluation verdict.

### Item 8 — SC-4: behavioral scenario, capture records the promoted SHA

- **Deliverable:** scenario
  `tests-v2/behaviors/2753-capture-assertion-happy` — dirty foreign-HEAD
  submodule checkout; the session performs the revised card's capture step;
  evaluation asserts `git ls-tree HEAD <path>` == the promoted SHA.
- **RED:** executed supervised run on pre-GREEN deck state records the
  checkout HEAD instead of the promoted SHA via `git add` — corroboration:
  the field run's commit `888d664`; the executed run is required.
- **GREEN:** after item 3, evaluation asserts the promoted SHA recorded;
  generator exits 0.
- **Tier marks:** tier-2 behavioral (heavy, supervised cycle-time run).
- **Instrument:** executed manifest + clean-room evaluation verdict.

### Item 9 — SC-5: behavioral scenario, tampered candidate fails the assertion

- **Deliverable:** scenario
  `tests-v2/behaviors/2753-capture-assertion-tamper` — tampered candidate
  (recorded gitlink ≠ promoted SHA); the session runs the revised card's
  capture step, whose mandatory assertion gates the push; evaluation asserts
  a non-zero exit naming the mismatching submodule and that no push occurred.
- **RED:** executed supervised run on pre-GREEN deck state pushes the
  tampered capture without an assertion — the executed run is required (no
  field corroboration exists for the tamper shape).
- **GREEN:** after item 3, evaluation asserts the non-zero mismatch exit and
  no push; generator exits 0.
- **Tier marks:** tier-2 behavioral (heavy, supervised cycle-time run).
- **Instrument:** executed manifest + clean-room evaluation verdict.

## Dependency order

Items 1 → 2 → 3 → 4 → 5 → 6/7/8/9. Item 1 delivers the card's head surface
(rule 0); item 2 aligns the protocol paragraph that points to it; item 3
lands with or after item 2 (it extends the same two surfaces); item 4 edits
the Phase A text independently but lands after item 2 so the triage's
"composition defect → recompose" route references the delivered promotion
step; item 5 cross-references the mandate items 1–2 deliver and must follow
them. Items 6–9 are the behavioral set: their RED runs execute against the
pre-card deck state pinned via `BEHAVIOR_SUBMODULE_COMMIT` (the harness's
sanctioned pin, verified against the remote) — the scenario scripts authored
on this branch run host-side while the run agent's cloned deck comes from
the pinned pre-card commit; among them they are independent scenarios against
the same fixture family, executed in any order; their GREEN evaluation
depends on items 1–3.

## Traceability

| Item | SCs |
|------|-----|
| 1 | SC-1 |
| 2 | SC-1 |
| 3 | SC-4, SC-5 |
| 4 | SC-6 |
| 5 | SC-7 |
| 6 | SC-2 |
| 7 | SC-3 |
| 8 | SC-4 |
| 9 | SC-5 |

## Verification summary

- Items 1–5: fact checks (grep/read of card text) at cycle time, mapped to
  their SCs above.
- Items 6–9: tier-2 behavioral scenarios — fixture family + executed
  supervised RED runs + clean-room evaluation dispatches; heavy, run once
  this cycle, on demand thereafter.
- Suite: the deck tool unit suite (`cd .opencode && uv run pytest`, through
  the parent's declared commands) runs at PR-check time.

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
