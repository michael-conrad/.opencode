# Plan — .opencode#2707 — triaged bug reports convert in place into the governing spec

Spec: `.issues/2707/spec.md` (validated, round-3 PASS). All items trace to the
spec's SCs. Repo for all work: `.opencode` (the deck and `tests-v2/` live here).

## Item 1 — Behavioral scenarios authored against un-amended surfaces (RED) (→ SC-6, SC-7)

- **Deliverable:** two scenarios under `tests-v2/behaviors/` —
  `2707-sc1-triage-in-place-spec-conversion.sh` (main conversion path) and
  `2707-sc2-triage-multi-spec-boundary.sh` (multi-spec carve-out), per the
  `behavioral-testing` card's harness path (`bash tests-v2/with-test-home
  opencode run`).
- **RED:** each scenario executed through the harness against the un-amended
  deck shows the agent halting at the verdict report or filing a separate
  spec issue — clean-room evaluation finds no in-place conversion (SC-1/SC-5
  surfaces still carry no mandate).
- **AMENDMENT (2026-11-02, mid-cycle discovery, implement-card rule 4):** the
  RED premise "agent does not convert under the un-amended deck" is
  environmentally unattainable for a diligent agent in this harness — the
  store tool auto-commits record changes to the submodule's pushed
  `issues-data` branch, and the harness clone fetches all remote refs, so
  the governing spec #2707's text is reachable inside every test home
  (observed live: the SC-2 RED run discovered, extracted, and began
  executing the spec; abort record
  `tmp/behavioral-evidence-2707-sc2-triage-multi-spec-boundary-RED-aborted-envleak/abort-record.yaml`).
  Amended RED basis:
  - **SC-6 RED:** stands on the completed run-6 evidence
    (`...-RED-ollama-qwen3.8-27b-128k-gguf4-2/` + clean-room evaluation,
    task ses_e618ec666ffeFo9ofauL3ozpIK): the agent reached and executed the
    full triage disposition with NO in-place conversion and no separate spec
    issue, and its session shows it never consulted the #2707 spec text —
    the deck's triage semantics gave it no work-entry conversion path.
  - **SC-7 RED:** recorded environment-blocked (the abort record above);
    discriminating weight moves to the GREEN evaluation, whose clean-room
    reviewer must verify the conversion behavior traces to the AMENDED DECK
    CARDS (issues §5 / floor / spec / work), not to the store's spec
    document or the scenario file's comments.
- **Verification instrument:** executed scenario output captured; clean-room
  evaluation result recorded.

## Item 2 — Triage semantics: work-entry conversion in the issues card (→ SC-1, SC-2, SC-3)

- **Deliverable:** `skills/issues/SKILL.md` §5 gains the second triage outcome
  class beside the closure-verdict class: the work-entry conversion. Stated
  with actor (the triaging agent), trigger (a triage verdict classifying a
  triaged bug report as actionable work), action (in-place conversion of the
  report's record into the governing spec — title, labels, and body updated
  on every surface the record lives on, reconciled in the same workflow; the
  three repo shapes per the spec's surfaces doctrine), the no-separate-filing
  clause, and the multi-spec carve-out (new issues only when the report
  warrants multiple specs; the original converts into the first spec;
  further specs are new issues linked per §4's hierarchy).
- **GREEN:** scenarios from Item 1 pass.
- **Verification instrument:** grep of `skills/issues/SKILL.md` for actor,
  trigger, action, no-separate-filing, carve-out, and the three-shape
  surfaces doctrine; clean-room read-back.

## Item 3 — Floor doctrine: agent-owned triage→spec conversion clause (→ SC-4)

- **Deliverable:** `floor.md` — the scope/stage doctrine paragraph (§
  "Authorization vocabulary" area, the stage-boundary rule) gains the
  conversion-path clause: the triage→spec conversion and the spec-stage entry
  are agent-owned stage transitions requiring no destination-stage token;
  plan and implementation keep their existing developer gates. The
  whole-card-on-touch writing-discipline conversion rule is retained (floor
  is already converted, #2664/#2665 — the edit holds conformance).
- **Verification instrument:** grep of `floor.md` for the conversion-path
  clause; clean-room read-back confirming both halves (agent-owned
  transition; downstream gates unchanged).

## Item 4 — Spec-stage entry point: converted record accepted as spec artifact (→ SC-5)

- **Deliverable:** `skills/spec/SKILL.md` and `skills/work/SKILL.md` — entry
  text states that a converted triaged-record enters the spec stage as the
  spec artifact, and the spec card's discipline (extraction, SC
  classification, validation) applies to it from there.
- **Verification instrument:** grep + clean-room read-back on each touched
  card.

## Item 5 — Behavioral scenarios GREEN + dependent-test currency (→ SC-6, SC-7, SC-9)

- **Deliverable:** rerun the Item-1 scenarios through the harness against
  the amended deck — both pass; run the preservation set: executed
  `2561-sc1` scenario, `tests-v2/test-cleanroom-eval-contract.sh`,
  `tests-v2/test-skill-deck-completeness.sh`, `tests-v2/test-trunk-hook.sh`,
  and `./.opencode/tools/reference-integrity`.
- **RED (for the GREEN half):** these are the Item-1 RED executions turning
  green; the preservation set must already pass (currency, not new RED).
- **Verification instrument:** captured executed output for each.

## Item 6 — Composition walkthrough (→ SC-8)

- **Deliverable:** one clean-room sub-agent walkthrough dispatch reading the
  amended card texts alone, walking the scenario "a triaged bug report
  proceeds to work" for all three repo shapes (store-holding with tracker,
  remoteless store-holding, pull-only), judged unambiguous and complete.
- **Verification instrument:** the dispatch's verdict, recorded in the
  issue's validation record.

## Order

1 → 2 → 3 → 4 → 5 → 6. Items 2–4 are the GREEN enabling text for Item 1's
scenarios; Item 5 turns them green and proves currency; Item 6 composes.

## Cards in scope at implementation

`behavioral-testing` (scenario authoring + harness), `issues` (store
artifacts), `skill-creator` (deck-governance admission gate applies to the
deck text edits), `programming-principles` (principles layer), `verify`
(fresh-context verification), `git-workflow-commit`, `git-workflow-pr`.
