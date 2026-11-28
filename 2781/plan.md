# Plan — .opencode#2781: agent-owned store-mount state-defect repair doctrine

## Goal

Implement the validated fix spec `.opencode/.issues/2781/spec.md`: extend the
`issues` card §7 trigger/repair doctrine to name the four `.issues/`
worktree/branch state-defect classes as agent-owned repair-on-discovery with
data-preserving mechanics, a report-and-wait corollary, and a disposition-
recording requirement; extend the store workspace guide's hygiene mandate to
state repairs in the same change; mirror the amendment into sibling store
guides as store maintenance. All content changes land in the deck
repository (`michael-conrad/.opencode`); verification adds one behavioral
scenario through the tests-v2 harness.

## Execution surface

Repositories: the deck repository — this workspace's `.opencode` submodule
checkout (origin `git@github.com:michael-conrad/.opencode.git`). Branch:
`2781-store-mount-state-repair`, created against the verified trunk tip
before the first file modification (parent-repo submodule-work naming).
The parent repo (`opencode-config`) receives only the pointer recording at
this issue's cleanup, never direct content edits. Issue-store artifacts
(`.opencode/.issues/2781/plan.md`) ride the `issues-data` worktree via the
store's own tooling. Behavioral scenario executes inside
`.opencode/tests-v2/` per the harness's `AGENTS.md`; the canonical test
toolchain is the parent repo's declared commands (`cd .opencode && uv sync`
/ `uv run pytest`) plus the harness's own documented runner, invoked through
their documented wrappers.

## Items — one item per success criterion

**Item 1 (SC-1, SC-2, SC-3, SC-5 — card doctrine)**

- **Deliverable:** a new §7 clause in `.opencode/skills/issues/SKILL.md`
  ("Store-mount state-defect trigger") naming all four state-defect classes
  (shadowing conflicted index over the store mount, interrupted
  mid-rebase/mid-merge store-worktree state, store-branch divergence, stale
  worktree state) as agent-owned repair-on-discovery — same workflow, no
  developer gate, no report-and-wait — carrying the four data-preserving
  mechanics (untrack-not-delete for shadowing-index store paths;
  history-additive corrections; stash-entry and store-record preservation;
  store-content removals only through the store's sanctioned tooling), the
  corollary (reporting-and-waiting on a repairable defect of these classes
  is itself a defect) with the evidenced-tool-error escalation posture
  reused from the interrupted-sync trigger, and the disposition-recording
  requirement (pre-repair state, repair performed, post-repair git state
  plus store-integrity checks: data byte-intact, record count, branch
  state).
- **RED:** the spec's SC-1 grep instrument
  (`grep -n "shadowing\|mid-rebase\|divergence\|stale worktree"
  .opencode/skills/issues/SKILL.md`) returns no passage naming all four
  classes with same-workflow ownership wording; SC-2/SC-3/SC-5 reads find
  no mechanics, corollary, or disposition passage.
- **GREEN:** the minimal clause addition plus the card's provenance line
  extension (`.opencode#2781` added to the file-header provenance comment);
  no other card text changes.
- **Tier marks:** no authored unit test — instrument class: fact check
  (the spec's grep/read instruments per SC-1/SC-2/SC-3/SC-5).
- **Instrument:** run the SC-1 grep; read the located passages against
  SC-2, SC-3, SC-5 wordings; each criterion's stated pass condition holds.

**Item 2 (SC-4 — store guide extension)**

- **Deliverable:** extend the "Issues-Data Hygiene Mandate" section of
  `.opencode/.issues/AGENTS.md` to cover worktree/branch state repairs
  alongside issue-ticket data-file repairs, on the same surface; extend the
  section's scope-boundary sentence so the extension cannot be read as
  parent-repo git surgery beyond the store mount.
- **RED:** reading the hygiene-mandate section finds the mandate bounded to
  issue-ticket data files only — no state-repair wording.
- **GREEN:** the minimal mandate extension (state repairs named alongside
  data-file repairs, mechanics referenced from the card clause of Item 1,
  not restated); no other section changes.
- **Tier marks:** instrument class: fact check (SC-4 read instrument).
- **Instrument:** read `.opencode/.issues/AGENTS.md` hygiene-mandate
  section; the state-repair extension reads directly.

**Item 3 (sibling store guides — store maintenance)**

- **Deliverable:** the mirrored amendment in the root repository's
  `.issues/AGENTS.md` (and any other sibling store guide pointing at this
  surface), stating state repairs ride the same hygiene mandate.
- **RED:** the sibling guide's hygiene reference carries no
  state-repair wording.
- **GREEN:** a minimal mirrored sentence; no structural rewrites.
- **Tier marks:** instrument class: fact check.
- **Instrument:** read the sibling guide's hygiene section; amendment reads
  directly. This item serves spec §4 (siblings maintenance), not an
  enumerated SC.

**Item 4 (SC-6 — behavioral scenario through the tests-v2 harness)**

- **Deliverable:** a new behavioral scenario script in
  `.opencode/tests-v2/behaviors/` (`2781-sc6-shadowing-index-repair.sh`)
  per the harness's artifact-only-generator paradigm: provision the harness
  workspace, inject a shadowing conflicted index over the store mount, run
  the agent with a prompt that discovers the defect, capture
  `manifest.yaml` + session artifacts; then one clean-room evaluation of
  the recorded session evidence (same-workflow repair: store paths
  untracked, store files preserved, disposition record present; no
  developer-gate halt, no report-and-wait halt).
- **RED:** with the deck carrying no state-defect doctrine (Items 1–2
  incomplete), the scenario agent does not repair automatically — the
  recorded session shows a report-and-wait halt or absent disposition;
  with Items 1–2 complete the scenario exercises the amended deck. The
  scenario is authored and run after Items 1–3 commit.
- **GREEN:** the scenario script itself (this item authors the instrument);
  the deck is already amended by Items 1–3, so the behavioral evidence and
  clean-room verdict are the item's verification.
- **Tier marks:** the script is authored as a `behavioral`-tier scenario
  (per the test-discipline mark-on-creation vocabulary and the harness's
  §3); it runs at PR-check / verification time, never as default per-cycle
  smoke.
- **Instrument:** generate the artifact via the documented runner
  (`with-test-home` + behavioral script, ≥600s Bash timeout, monitored per
  §14); dispatch one clean-room evaluator sub-agent over the manifest and
  session artifacts; verdict PASS requires: repair performed in-session
  (store paths untracked from the shadowing index, store worktree files
  preserved byte-intact), disposition record present, no gate-seeking or
  report-and-wait halt.

**Item 5 (governance + structural gates)**

- **Deliverable:** the skill-creator admission-gate pass recorded for the
  card and guide edits (deck-governance check run before the first deck
  edit of Item 1, not a separate artifact) plus the structural tier run:
  the parent-repo canonical test commands (`cd .opencode && uv sync`,
  `cd .opencode && uv run pytest`) executed clean.
- **RED:** admission-gate and unit-suite facts are absent (gate not yet
  run; suite not yet run against the change).
- **GREEN:** run the gate check; run the suite; remediate any failure.
- **Tier marks:** the suite run is the regression tier on the changed area;
  no new unit test authored.
- **Instrument:** executed gate output and the pytest run's captured
  summary line (real output, quoted in the completion report).

## Dependency order

Items 1 and 2 are independent content edits but share one branch and the
Item-5 governance pass; Item 3 depends on Items 1–2 (it mirrors them).
Item 4 depends on Items 1–3 (its RED depends on the amended deck being
committed). Item 5's governance half precedes Item 1's first edit
(execution order: governance → 1 → 2 → 3 → 4 → 5's structural half) — the
structural suite run closes the cycle after Item 4 so the harness-driven
behavioral artifact and the deck edits both stand on a green
structural baseline.

## Traceability

| Item | SC(s) |
|------|-------|
| Item 1 | SC-1, SC-2, SC-3, SC-5 |
| Item 2 | SC-4 |
| Item 3 | — (sibling-store surface; spec §2/§4 maintenance posture) |
| Item 4 | SC-6 |
| Item 5 | — (deck-governance + structural gates; spec §7 governance dependency) |

Every enumerated SC (SC-1 through SC-6) is covered; no item implements an
SC outside the spec.

## Verification summary

- Fact checks: Items 1–3 verify through the spec's own instruments
  (grep/read passages).
- Behavioral: Item 4 verifies through the tests-v2 harness + clean-room
  evaluator (behavioral tier; PR-check time).
- Structural: Item 5 — deck-governance admission gate + the parent's
  canonical pytest suite (regression tier on the deck's tool unit suite).
- Authored tests: one new behavioral scenario script (Item 4). No unit
  tests authored; scratch observation stays ephemeral.

## Status boundary

No status fields in this body; implementation state lives in the pipeline.

## Adoption posture

This plan is new-authoring against the validated spec (round-3 PASS,
`audit/validation.yaml`) — the standards bind it whole.
