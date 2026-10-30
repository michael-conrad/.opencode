<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [PLAN] Validation loop — stop trigger, finding bar, validation record — .opencode#2660

Sources: `.opencode/.issues/2660/spec.md` (approved for PR by the developer,
2026-10-30; validation loop closed at revision 23, clean PASS per
`2660/audit/re-evaluation.yaml` run 5's re-review). Items are grouped by
surface (the spec's §2.1 scope table is the decomposition), and every item
names the SCs it carries; every SC is carried by at least one item; no
padding items. Validation-standards check consumed each SC against the spec
validation-standards reference — reviewer judgment: every SC is
assert-by-read or the SC-9 behavioral dispatch; no criterion reinterprets
its instrument; no BLOCKED. Design decision (7) governs the item shapes:
canonical statement once in `validation-standards.md` §Loop; the plan and
verify locations carry the instance and bind to or carry the canonical
content. The spec's single-sourcing rule is itself the artifact's shape
law — items never restate another item's element lists; the RED/GREEN
element lists defer to the R-n requirements the spec owns. Pre-change
content whose identity SC-6 and SC-10 preserve: `verify/SKILL.md` §2's
churn rule (verbatim), §4's state-decidability paragraph, the
validation-standards references' escalation paragraphs' exit sentences,
and the findings-are-fixed and criteria-invariance passages in both
standards references.

## Items

### Item 1 — the canonical bar and record (SC-5, SC-4, SC-8 in the spec card's reference)

- **Deliverable:** `skills/spec/references/validation-standards.md`
  §Verdict contract carries R-6's class-determined finding bar (defect
  class the criteria source enumerates → finding; factual defect → finding
  regardless of effect size; preference/style/taste/hypothetical
  improvement → never a finding; no third category — a substantive
  observation is a finding; per-round classification stability via the
  validation record) and the spec/plan prong definition ("correctness" for
  a spec or plan = factual accuracy plus impact-enumeration completeness);
  §Loop carries the canonical validation-record statement (R-4, R-5,
  SC-8): the path `.issues/{N}/audit/validation.yaml`, one file per issue,
  one top-level section per artifact under validation, per-round entries
  with the round's findings and every adjudicated class with its
  classification, remediation or outcome reached including the terminal
  cycle, the re-evaluation's outcome and grounds slot, the no-second-copy
  clause (the deliverable's verdict is recorded once — chat or PR
  description; the record is the loop's history), the class exemplars
  (stale citation, wrong count, mis-scoped claim) as entry detail, the
  same-label-per-defect stability clause, the zero-finding round
  definition, the records-never-in-body clause, the no-issue carve-out
  (verdict recorded per the verify card's own recording rule), and the
  judgment-cites-the-record clause.
- **RED:** Read the file against the spec's R-4, R-5, R-6 at check time
  (never an enumeration frozen here): the §Verdict contract states an
  effect-worded anti-churn binding without the class-determined bar and
  without the prong definition, and §Loop states no validation-record
  convention. Assertions fail.
- **GREEN:** Amend §Verdict contract (the anti-churn binding sentence's
  boundary determinant becomes the class rule; the sentence's remaining
  anti-churn content stays) and §Loop (the record block). The churn rule's
  verbatim form is held unchanged per SC-6/SC-10 — the binding's other
  sentences are not rewritten.
- **Instrument:** file-read assertion of R-6's and R-4/R-5's elements
  against the amended text.

### Item 2 — the canonical loop (SC-1, SC-2, SC-3, SC-6 in the spec card's reference)

- **Deliverable:** `skills/spec/references/validation-standards.md` §Loop
  carries R-1's two triggers (the non-convergence judgment: incrementally
  progressing rounds with genuinely new findings and no obvious
  convergence → stop in-place revision, run the structural re-evaluation;
  the count trigger: more than four revisions to address findings → run
  the re-evaluation before any further in-place revision; both are the
  trigger that opens the examination, the examination's verdict is
  judgment, the count mandates and never decides), R-2's canonical factor
  set (repo boundaries; separation of concerns; atomic work-unit
  decomposition; fatness; intent wording/reachability — minimum,
  exemplary and open), R-3's three recorded outcomes and their behaviors
  (Sound: findings recorded, loop resumes on the unchanged artifact;
  Recompose: shape is the defect, split per the issues card's
  recomposition protocol, in-place revision of the pre-split artifact
  superseded; Intent-unreachable: intent statement rewritten, loop
  continues; a re-evaluation counts as a higher-level fixing attempt under
  the escalation rule; the Recompose-precondition clause for the
  protocol-now-implemented state per the spec's R-3), and R-7's bars'
  guard in the count trigger's neighborhood (findings are never
  negotiated away and criteria invariance are never satisfied by a round
  count).
- **RED:** Read §Loop against the spec's R-1, R-2, R-3, R-7 at check time:
  the section carries only the spin judgment; no non-convergence
  judgment, no count trigger, no factor set, no outcomes, no count-satisfies-nothing
  statement. Assertions fail.
- **GREEN:** Amend §Loop: insert the two triggers beside the spin judgment,
  the factor set, the outcomes block, and the guard beside the count
  trigger; the existing spin-judgment text, the findings-are-fixed
  sentences, and the escalation paragraphs (including their exit
  sentences) stand unchanged per SC-6/SC-10, with the triggers added
  around them.
- **Instrument:** file-read assertion of R-1's, R-2's, R-3's, and R-7's
  elements against the amended text.

### Item 3 — the plan instance (SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 in the plan card's reference)

- **Deliverable:** `skills/plan/references/plan-validation-standards.md`
  §Verdict contract carries R-6's bar as the plan criteria source applies
  it (the enumerated defect classes above, the factual-defect clause, the
  two-buckets/no-third-category statement, the classification-stability
  clause) and the prong definition; §Loop carries R-1's two triggers,
  binds to the canonical factor set and the canonical record convention by
  pointing at the spec card's validation-standards reference (carry-or-point),
  and carries R-3's outcomes and R-7's guard in the count trigger's
  neighborhood. The findings-are-fixed sentences, the spin-judgment text,
  the plan-level cause examples, and the escalation paragraphs' exit
  sentences stand unchanged per SC-6/SC-10.
- **RED:** Read the file against the spec's R-1..R-7 at check time: the
  §Loop carries only the spin judgment and the §Verdict contract carries
  no class-determined bar; assertions fail.
- **GREEN:** Amend the two sections as the deliverable states, mirroring
  the canonical content's plan-instance wording and pointing at
  `../spec/references/validation-standards.md` for the factor set and the
  record convention.
- **Instrument:** file-read assertion against the amended text.

### Item 4 — the review instance (SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 in the verify card)

- **Deliverable:** `skills/verify/SKILL.md` §3 carries the class-determined
  finding bar (R-6) and the zero-finding PASS bar, with the recording rule
  reconciled to the validation record per R-5 (the verdict recorded once —
  this card's recording sentence stays, and the loop's round history is
  the owning issue's validation record at `.issues/{N}/audit/validation.yaml`
  where an owning issue in a store exists; no second copy of the verdict in
  the record); §2 and §4 carry R-1's two triggers, R-7's guard, R-3's
  outcomes, and R-2's factor-set pointer (carry-or-point, pointing at the
  spec card's validation-standards reference). Preserved unchanged: §2's
  churn rule verbatim, §4's state-decidability paragraph, the FAIL path's
  existing escalation text and its exit sentence.
- **RED:** Read the card against the spec's R-1..R-7 at check time: §3
  carries the recording rule with no bar and no zero-finding statement; §2
  and §4 carry no triggers, no factor set, no outcomes. Assertions fail.
- **GREEN:** Amend §2/§3/§4 as the deliverable states, keeping every
  preserved passage byte-identical.
- **Instrument:** file-read assertion; diff against the pre-change branch
  point confirming the preserved passages unchanged.

### Item 5 — the stale gloss retired (SC-7)

- **Deliverable:** `skills/implement/references/implementation-workflow.md`
  post-implementation table's verify-pass row binds its purpose to the
  verify card's review loop — the step reaches a zero-finding verdict
  under the verify card's FAIL path — and no longer states a bound of one
  review.
- **RED:** Read the row: the purpose cell states "one bounded review."
  Assertion fails.
- **GREEN:** Replace the purpose cell's bound wording with the
  FAIL-path/zero-finding-verdict statement (R-8).
- **Instrument:** file-read assertion of R-8's elements.

### Item 6 — the single-sourcing discipline (SC-11)

- **Deliverable:** `skills/spec/SKILL.md` §5's self-containment clause
  carries R-9: each operative fact stated once, in the section that owns
  it (surfaces in the scope table; rules in the requirements; checks as
  mappings whose element lists the mapped requirement owns; measured
  history in the evidence; the artifact's own loop history deferred to the
  issue's record where the validation record rule applies — R-5's), every
  other mention pointing at its owner; `skills/plan/SKILL.md` §5 carries
  the parallel clause in plan voice.
- **RED:** Read both §5s against R-9 at check time: neither carries an
  operative-fact-single-sourcing statement. Assertions fail.
- **GREEN:** Add the clause to each §5 in its card's voice.
- **Instrument:** file-read assertion of R-9's elements in both cards.

### Item 7 — preservation scrub (SC-10, remainder of SC-6)

- **Deliverable:** the preserved passages stand byte-identical against the
  pre-change file bodies from the deck repository's git history: §2's
  churn rule in the verify card; the findings-are-fixed and
  criteria-invariance passages in both standards references; the verify
  card's §4 state-decidability paragraph; the escalation paragraphs' exit
  sentences in both standards references; the churn rule's verbatim form
  wherever it appears.
- **RED:** Run the assertions — any drift found makes them fail.
- **GREEN:** Revert any accidental drift in the preserved passages.
  (A scrub-and-assert gate over the composed text; it asserts identity.)
- **Instrument:** `git diff <base>..HEAD -- <files>` compared against the
  pre-change bodies; diff-hunk inspection of every preserved passage.

### Item 8 — the loop behaves (SC-9, behavioral)

- **Deliverable:** a Tier-1 clean-room behavioral dispatch per the
  `behavioral-testing` card: a sub-agent with no prior context runs the
  revised loop rule against two engineered artifacts — one whose rounds
  yield genuinely new shallow findings with no obvious convergence, one
  whose rounds do not — each through at least five revisions. From the
  recorded dispatch evidence (prompt and observed output persisted in the
  owning issue's artifact area, `2660/audit/`) assert: the re-evaluation
  fired in the first run by the judgment (non-convergence); in the second
  run it fired after the fifth revision on the count alone; and the
  dispatch evidence record carries the outcome and its grounds. Modeled on
  `.opencode/.issues/2582/audit/tier1-dispatch-SC15-20261013.yaml`.
- **RED:** No dispatch evidence exists for SC-9 under the amended rule;
  the dispatch's persisted evidence is the artifact produced.
- **GREEN:** The evidence file `2660/audit/tier1-dispatch-SC9-<date>.yaml`
  records the prompt, the sub-agent's observed outputs, and the element
  assertion, judged from the sub-agent's output only. The behavioral test
  writes nothing into the production validation record — an engineered
  run's artifact belongs to no issue in a store, so R-5's carve-out
  applies.
- **Instrument:** the dispatch runs after Items 1–7 are in place; no real
  store mutation by the fixture run.

## Dependency order

Items 1–2 make the canonical statement (1 = verdict contract + record;
2 = the loop); item 3 mirrors it in plan voice; item 4 in review voice
(3 and 4 both follow 1–2, independent of each other); item 5 and 6 are
single-surface edits, independent of the others; item 7 scrubs the
composed text (follows 1–6); item 8 dispatches on the final text (follows
7). Sequence: 1 → 2 → {3, 4, 5, 6} → 7 → 8.

## Verification instruments

Items 1–6: file-read assertions against the amended card texts (each
item's instrument is stated in its RED/GREEN; element lists live in the
spec's R-n requirements at check time). Item 7: git-history diff identity
of the preserved passages. Item 8: the persisted dispatch evidence file,
judged per the `behavioral-testing` card's Tier-1 contract.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)