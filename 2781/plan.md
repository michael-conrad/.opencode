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

**Item 0 (deck-governance admission gate — precedes all edits)**

- **Deliverable:** the skill-creator admission-gate pass over the planned
  card and guide edits (deck-governance check; the deck-governance card's
  gate must be passed before the first deck edit of Item 1).
- **RED:** no admission-gate verdict exists in the session for this
  change's planned surfaces (`skills/issues/SKILL.md` §7 extension;
  store-guide hygiene-mandate extension) — the gate has not yet run.
- **GREEN:** run the `skill-creator` card's admission-gate check against
  the planned content; the gate returns admissible (with its grounds).
- **Tier marks:** instrument class: recorded evaluation (the gate's own
  check procedure).
- **Instrument:** the gate check's executed procedure and its stated
  verdict, reported in the completion flow.
- **Position reason:** the gate governs any edit under `skills/` or a
  guide; it cannot run after the edits it governs.

**Item 4 (SC-6 — behavioral scenario, focused form per the 2026-11-28
spec re-scope)**

- **Deliverable:** the behavioral scenario
  `2781-sc6-shadowing-index-repair.sh` in its focused form: the workspace
  carries the index defect and no issue store — the fixture injects only
  the shadowing index (unmerged `.gitignore`; `.issues/` paths staged,
  worktree-absent), the prompt's task is the repair and the disposition
  record, and `repair-report.md` is the declared goal artifact; then one
  clean-room evaluation over the recorded session evidence plus the
  captured workspace end-state.
- **RED:** at item start, no focused-form scenario exists — a listing of
  `behaviors/` for the `2781-` scenario returning the pre-re-scope
  (store-provisioning) form is the failing state; it fails now and at the
  item's execution position.
- **GREEN:** the focused scenario is run through the documented runner
  against the amended deck and one clean-room evaluator returns a verdict
  on the recorded evidence (repair through the card's mechanics: staged
  `.issues/` entries untracked, `.gitignore` resolved, nothing under
  `.issues/` deleted or overwritten; disposition record `repair-report.md`
  present; no gate/wait).
- **Tier marks:** the script is authored as a `behavioral`-tier scenario
  (test-discipline mark-on-creation vocabulary, harness §3); it runs at
  PR-check / verification time, never as default per-cycle smoke.
- **Instrument:** documented runner (`with-test-home` + behavioral script,
  ≥600s Bash timeout, monitored per §14); one clean-room evaluator
  sub-agent over the session artifacts and end-state capture; PASS
  requires: repair performed in-session (staged `.issues/` entries
  untracked, `.gitignore` resolved, nothing under `.issues/` deleted or
  overwritten), disposition record present, no gate-seeking or
  report-and-wait halt.

**Item 5 (structural gates — closes the cycle)**

- **Deliverable:** the structural tier run: the parent repo's canonical
  test commands executed clean against the amended deck
  (`cd .opencode && uv sync`, then `cd .opencode && uv run pytest`).
- **RED:** the unit suite has not been run against the change (no
  recorded run exists for Items 1–3's amended state).
- **GREEN:** run the commands; remediate any failure (a failure whose
  remedy lies outside this change's scope stops the cycle per the
  implementation-workflow escalation rule).
- **Tier marks:** the suite run is the regression tier on the deck's tool
  unit suite; no new unit test authored.
- **Instrument:** the pytest run's captured summary line (real output,
  quoted in the completion flow).
- **Position reason:** the structural baseline must cover both the deck
  content edits and the Item-4 harness artifact, so it runs last.

## Dependency order

Items 1 and 2 are independent content edits but share one branch and the
governance gate; Item 3 depends on Items 1–2 (it mirrors them).
Item 4 depends on Items 1–3 (its RED depends on the amended deck being
committed). Item 0 precedes Item 1 because the deck-governance admission
gate governs any edit under `skills/` or a guide and cannot run after the
edits it governs. Item 5's structural suite runs last so the baseline
covers both the deck edits and the Item-4 harness artifact. Full order:
0 → 1 → 2 → 3 → 4 → 5.

## Traceability

| Item | SC(s) |
|------|-------|
| Item 0 | — (deck-governance gate; spec §7 governance dependency) |
| Item 1 | SC-1, SC-2, SC-3, SC-5 |
| Item 2 | SC-4 |
| Item 3 | — (sibling-store surface; spec §2/§4 maintenance posture) |
| Item 4 | SC-6 |
| Item 5 | — (structural gates; spec §7 governance dependency) |

Every enumerated SC (SC-1 through SC-6) is covered; no item implements an
SC outside the spec.

## Verification summary

- Fact checks: Items 1–3 verify through the spec's own instruments
  (grep/read passages).
- Behavioral: Item 4 verifies through the tests-v2 harness + clean-room
  evaluator (behavioral tier; PR-check time).
- Governance: Item 0 — the skill-creator card's admission gate over the
  planned deck edits.
- Structural: Item 5 — the parent's canonical pytest suite (regression
  tier on the deck's tool unit suite).
- Authored tests: one new behavioral scenario script (Item 4). No unit
  tests authored; scratch observation stays ephemeral.

## Status boundary

No status fields in this body; implementation state lives in the pipeline.

## Adoption posture

This plan is new-authoring against the validated spec (round-3 PASS,
`audit/validation.yaml`) — the standards bind it whole.
