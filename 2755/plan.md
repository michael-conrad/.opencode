# Plan — .opencode#2755

**Goal.** Implement spec `.opencode/.issues/2755/spec.md`: the issues card's
on-discovery repair doctrine gains an artifact-content-defect trigger
(validate-yaml findings repaired in-workflow, mechanically repaired via
dispatch, sweep counted and re-verified); the validate-yaml CLI-reference row
binds the disposition; the spec card's validation-record contract gains
emission-side quoting guidance; a tier-2 behavioral scenario proves an agent
repairs rather than reports. Surfaces: `skills/issues/SKILL.md` (§7),
`skills/issues/references/local-issues-cli.md`,
`skills/spec/references/validation-standards.md` (record contract),
`tests-v2/behaviors/` (new scenario).

**Execution surface.** Deck repository `michael-conrad/.opencode`, branch
`feature/2753-release-composition-and-2755-repair-trigger`, trunk tip
`e237255c0` (verified at branch time). Structural edits are card text;
behavioral item runs the `tests-v2` harness per the behavioral-testing card.

## Items

### Item 1 — SC-5: emission quoting guidance (record contract half)

- **Deliverable:** in `skills/spec/references/validation-standards.md`'s
  validation-record contract section: prose scalars carrying embedded
  `key:`-pattern text are emitted as quoted or folded scalars so the record
  parses.
- **RED:** read the record contract section → no emission quoting guidance.
- **GREEN:** add the emission rule to the record contract section.
- **Tier marks:** no authored test; instrument fact check.
- **Instrument:** grep the section for the quoting rule; fails if absent.

### Item 2 — SC-1: the artifact-content-defect trigger exists, no report-and-wait

- **Deliverable:** a new paragraph in `skills/issues/SKILL.md` §7 (beside the
  Interrupted-sync trigger) naming the artifact-content-defect trigger:
  record-content defects the store's own validator (`local-issues
  validate-yaml`) names in a store-holding repo are repaired on discovery in
  the same workflow (agent-owned store maintenance); no clause on that path
  permits reporting the findings to the developer and waiting. The paragraph
  cross-references item 1's quoting guidance. At this item's execution the
  paragraph is exactly this content — no procedure sentence, no
  completeness sentence.
- **RED:** grep `skills/issues/SKILL.md` → no trigger binds `validate-yaml`
  findings to in-workflow repair; §7 names only mirror-absence and
  interrupted-sync.
- **GREEN:** add the trigger paragraph with the cross-reference (this item's
  commit only).
- **Tier marks:** no authored test; instrument fact check.
- **Instrument:** grep `validate-yaml` in the card names the trigger; no
  report-and-wait phrasing on the trigger path; the trigger's
  cross-reference to item 1's quoting guidance is present (SC-5's
  card-side half, verified here since the cross-reference is part of this
  paragraph's Green content).

### Item 3 — SC-2: the trigger's repair procedure clause

- **Deliverable:** one appended sentence in item 2's trigger paragraph,
  committed alone in item 3's own commit: mechanical content repairs (the
  validator's whole named taxonomy — `invalid-yaml`,
  `malformed-frontmatter`, `schema-violation`) dispatch per file to a
  sub-agent under the dispatch-scope doctrine; each repair preserves the
  record's content byte-exactly except the defect itself (syntax-only
  rewrites — quoted/folded scalars, separator removal, shape dedent —
  asserted against pre-repair captured text); the discovering session —
  never the repair sub-agent alone — re-verifies the full store sweep clean
  (`validate-yaml` exit 0) at the store's synced HEAD and records the
  disposition with the work that discovered the findings. A repair failing on
  evidenced tool error is a report-with-halt scoped to that store, matching
  §7's existing posture.
- **RED:** confirmed at item 3's execution point — item 2's commit has
  landed, so the trigger paragraph exists on disk but its text carries no
  dispatch, preservation, re-verification, or recording clause; the read
  check against those clauses fails. (The check fails because the clause is
  absent from the paragraph as item 2 committed it — not because the trigger
  is absent.)
- **GREEN:** append the procedure sentence (own commit).
- **Tier marks:** no authored test; instrument fact check.
- **Instrument:** read the paragraph after the commit; dispatch, byte-exact
  preservation, discovering-session re-verification, and disposition
  recording are present.

### Item 4 — SC-3: the trigger's sweep-completeness clause

- **Deliverable:** one appended sentence in the trigger paragraph, committed
  alone in item 4's own commit: the discovering session counts the
  validator's full output and verifies the count before repairing; a sampled
  or tail-truncated view of the findings is never the repair dispatch's
  premise.
- **RED:** confirmed at item 4's execution point — the paragraph after item
  3's commit carries the procedure clause but no full-output counting duty;
  the read check for the counting clause fails.
- **GREEN:** append the completeness sentence (own commit).
- **Tier marks:** no authored test; instrument fact check (read).
- **Instrument:** read the paragraph; the full-output counting duty is
  present.

### Item 5 — SC-4: validator row disposition

- **Deliverable:** the `validate-yaml` row in
  `skills/issues/references/local-issues-cli.md` gains a disposition
  sentence: the validator's findings are the evidence instrument of the
  issues card §7 artifact-content-defect trigger and are repaired on
  discovery per that trigger.
- **RED:** read the row → only sweep/exit semantics, no disposition.
- **GREEN:** append the disposition sentence naming the §7 trigger.
- **Tier marks:** no authored test; instrument fact check.
- **Instrument:** grep the row for the trigger reference; fails if the
  disposition is absent.

### Item 6 — SC-6: behavioral scenario

- **Deliverable:** a tier-2 scenario (`tests-v2/behaviors/2755-repair-on-
discovery.sh` + fixture store) seeding the field defect shapes (prose scalars
  carrying embedded `key:`-pattern text; a stray document separator) and a
  session flow whose sweep surfaces the findings; clean-room evaluation
  asserts the session dispatched the repairs, re-verified the full sweep
  clean, and recorded the disposition instead of reporting findings as
  out-of-scope.
- **RED:** an executed supervised run against the pre-GREEN deck state
  (before items 2–4 land) produces a manifest showing the session reporting
  findings without repair. The executed RED is required — the SC-6 instrument
  is the harness; the field reproduction (2026-11-18) is corroboration in the
  spec only and never substitutes for the executed run. For this RED state to
  exist on the branch, item 6 runs split: the scenario script and fixture
  store are authored and committed, and the RED run executed, before item
  2's commit; the evaluation (GREEN) runs after items 2–4.
- **GREEN:** after items 2–4, the evaluation asserts the repaired
  disposition; the artifact generator runs and exits 0; evaluation is the
  clean-room dispatch's job.
- **Tier marks:** tier-2 behavioral (heavy — supervised cycle-time run,
  never a default suite run).
- **Instrument:** executed scenario manifest + clean-room evaluation dispatch
  verdict per the behavioral-testing card.

## Dependency order

Item 1 first: item 2's cross-reference names item 1's surface, so the
guidance exists before the trigger lands. Item 6's RED executes against the
pre-card deck state pinned via `BEHAVIOR_SUBMODULE_COMMIT` (the harness's
sanctioned pin, verified against the remote) — the scenario script authored
on this branch runs host-side while the run agent's cloned deck comes from
the pinned pre-trigger commit; this reachable-state mechanism replaces a
reordered commit sequence, whose only purpose the pin serves directly. Items
2, 3, 4 execute strictly in
order, each with its own commit against the paragraph's then-current state:
item 2 commits the trigger named (SC-1); item 3's RED runs on that committed
state (paragraph present, procedure clauses absent) and appends the
procedure sentence; item 4's RED runs on item 3's committed state
(procedure present, counting clause absent) and appends the completeness
sentence. No later item's RED or GREEN rewrites an earlier clause. Item 5's
commit lands after item 4's commit (the row names the delivered §7 trigger).
Item 6's evaluation (GREEN) runs last, after items 2–4.

## Traceability

| Item | SCs |
|------|-----|
| 1 | SC-5 |
| 2 | SC-1, SC-5 |
| 3 | SC-2 |
| 4 | SC-3 |
| 5 | SC-4 |
| 6 | SC-6 |

## Verification summary

- Items 1–5: fact checks (grep/read of card text) at cycle time, one per SC.
- Item 6: tier-2 behavioral scenario — fixture store + executed supervised
  RED run + clean-room evaluation dispatch; heavy, run once this cycle,
  on demand thereafter.
- Suite: the deck tool unit suite (`cd .opencode && uv run pytest`, through
  the parent's declared commands) runs at PR-check time.

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
