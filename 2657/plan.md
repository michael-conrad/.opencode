# Plan — .opencode#2657: path selection, a stated stage request, and the short path's record

Spec: `.opencode/.issues/2657/spec.md` (fresh-context validation PASS, zero
findings). Branch: `feature/2657-path-selection-short-path`, based on
`feature/2663-harness-cap-hit-resume` (the `.opencode#2663` change, stacked
beneath this one), whose base is `a1fb61c6` — the `.opencode` trunk tip,
verified against `origin/main` at plan time. Repository:
`michael-conrad/.opencode` (the `.opencode` submodule). The PR is a submodule
PR; the parent repo's pointer rides with the next real parent change per the
parent `AGENTS.md`.

The harness change this spec's behavioral criteria depend on is specified by
`.opencode#2663` and travels in its own change, stacked beneath this one. This
plan touches no harness file; the behavioral items run against the stacked
tree, which carries both changes.

## Surfaces touched

| Surface | Change | SCs |
|---------|--------|-----|
| `floor.md` | pipeline invariant; authorization-vocabulary stage-request rule | SC-1 |
| `skills/work/SKILL.md` | path selection, criteria set, scope statement, work record, boundaries | SC-2, SC-4 |
| `skills/skill-creator/SKILL.md` | the carve-out's bound | SC-3 |
| `skills/plan/SKILL.md` | "short path" re-pointed at the one definition | SC-4 |
| `skills/implement/SKILL.md` | "short path" re-pointed; "work state" → work record | SC-4 |
| `skills/verify/SKILL.md` | reads the scope statement; verdict unit; owning card | SC-5 |
| `skills/git-workflow-pr/SKILL.md` | three gates + Provenance read the scope statement | SC-5 |
| `skills/git-workflow-branch/SKILL.md` | provenance written to the work record | SC-4 |
| `skills/git-workflow-cleanup/SKILL.md` | work-state artifacts named | SC-4 |
| `tests-v2/behaviors/2584-sc5-short-path-single-file.sh` | retired (deleted) | SC-11 |
| `tests-v2/behaviors/2584-sc4-directed-card-edit-no-archaeology.sh` | header states the second criterion | SC-11 |
| `tests-v2/behaviors/2657-sc1..sc5-*.sh` | five new scenarios | SC-6..SC-10, SC-11 |
| `tests-v2/behaviors/fixtures/setup/2657-sc1..sc5-*.sh` | five new setup fixtures | SC-11 |

No harness file is in this change: the cap-hit resume, the determination
gate, and the surfaces that state them belong to `.opencode#2663`'s change,
stacked beneath this one.

## The work record's path

R-10 requires the work card to name the work record's path. The plan fixes it:
the path **`git rev-parse --git-path work-record.md` reports**, inside the
repository's own git directory. That path is not a working-tree path, so the
record never appears in the repository's status and needs no ignore-rule
entry, and establishing it touches nothing in the tracked tree — which
matters, because an ignore-rule entry would itself be a tracked-file change
that the short path's own criteria (one file; no surface the developer did
not name) could not hold. One record per repository at a time; a new scope in
the same repository starts the record over — the scope statement's content is
carried into the PR body's Provenance section, so nothing is lost. The record
is scratch: never committed (the commit card stages named files only), removed
by the cleanup card at merge.

## Ordering

1. **Item 1** — the scenario set (SC-11).
2. **Items 2–6** — the card changes (SC-1..SC-5), committed and pushed.
3. **Items 7–12** — the behavioral criteria (SC-6..SC-10, SC-12), each as a
   per-item cycle: RED then GREEN.

The behavioral items' RED runs are executed **pinned to the pre-change deck
tip** `a1fb61c6` through `BEHAVIOR_SUBMODULE_COMMIT`, so a RED observes the
pre-change deck wherever it is captured in the sequence. The pin is verified
against the remote by the harness and is never bypassed. Each behavioral
item's GREEN runs unpinned, against the branch tip that carries the card
changes. This is why the order is acyclic: items 2, 3 and 4 depend on
nothing; items 5 and 6 depend on item 3, because the cards they amend point
at what item 3 defines; items 7–12 depend on items 1–6 and on the stacked
harness change being complete.

The harness's ordered precondition cycle (commit → push → fetch/verify → run,
`tests-v2/AGENTS.md` §4) applies to every run below. A behavioral run
executes with the bash tool's `timeout` at 600000 ms or more, under the
60-second supervision cycle with an in-chat update per poll, and its verdict
comes from a separate clean-room evaluation dispatch reading `session.yaml`
(two-SC pattern, `tests-v2/AGENTS.md` §6a).

A behavioral RED that does not fail is reported to the developer with the
run's evidence and the criterion it did not confirm. It is not absorbed by
reinterpreting the criterion, and the criterion is not weakened to make it
fail (`implement` card rule 3, rule 10).

A behavioral GREEN that does not confirm is handled the same way, and the spec
names the step that follows: the three criteria that turn on a full-path spec
artifact (SC-6, SC-7, SC-9) are re-scoped at the spec — the scenario's
artifact made small enough for the harness's per-turn budget — and the spec
is revised and re-validated before those criteria are judged again. The
implementor does not re-scope the criterion, and does not re-scope the
scenario, to make the GREEN pass: the re-scope is a spec revision, and the
spec card owns it.

## Item 1 — the scenario set (SC-11)

- Deliverable: five new scenario scripts and five matching setup fixtures;
  `2584-sc5-short-path-single-file.sh` deleted; `2584-sc4`'s header states
  the anti-archaeology criterion and the no-full-path-machinery criterion
  beside it. Each scenario is an artifact-only generator: it runs
  `behavior_run`, exits 0, and never evaluates its own output. Each new
  scenario's header states **its own criterion** on a `# .opencode#2657
  SC-N: <criterion>` line, following the deck's per-scenario convention
  (`2584-sc4-directed-card-edit-no-archaeology.sh` and
  `2639-sc7-one-branch-one-pr.sh` carry it) — the `template.sh` block alone
  does not, so the line is written by hand. Every scenario the change
  touches — the five new ones and `2584-sc4` — declares a **goal condition**
  (`BEHAVIOR_EXPECTED_ARTIFACT`, `BEHAVIOR_EXPECTED_ARTIFACT_GREP`,
  `BEHAVIOR_GOAL_ACTIONS`), because a scenario with no goal condition leaves
  the monitor's classifier with no direction anchor: it returns
  "undetermined", the SC-8 determination gate blocks the resume path, and a
  capped run cannot be judged or recover. SC-10's scenario declares goal
  actions alone and names no artifact, because its criterion turns on a
  question in the transcript and naming the edited card would declare as the
  goal the very edit the criterion forbids. Each declared content pattern is
  **discriminating** — absent from its target before the run, so the anchor
  is a condition the run can miss, and a pattern the harness's content check
  can match, so it is one the run can meet: `2584-sc4`'s pattern is the rule
  number its prompt names (`6.`), not the word that rule carries (`byline`),
  which the target card already contains; `2657-sc4`'s is `json`, the flag the
  request names, not `--json`, which the content check would read as an
  option. The fixtures that need the store **bootstrap it in the shape the
  local-issues tool recognises** — a linked worktree of the orphan
  `issues-data` branch whose `.git` is a file, with the injected fixture
  issues inside it and the legacy `open/` and `closed/` directories dropped.
  The harness's fixture-issue injection has already created `.issues/` as a
  staged plain directory, and a linked worktree cannot take over a path the
  index still tracks, so the content is copied aside and untracked first; the
  branch and the worktree are created with the same plumbing the tool uses.
  Each fixture **settles the
  trunk**: the harness commits `init` onto the test project's `main` and the
  fixture commits the seed content on top, so `main` sits ahead of
  `origin/main`; the fixture moves `main` back to the remote tip and leaves
  the seed content staged, so the content is present and the divergence is
  not — the branch card's trunk-tip verification is then unambiguous instead
  of costing the run ten minutes of `git merge-base`.
- RED: `ls tests-v2/behaviors/ | grep 2657` returns nothing (0 of 5 present);
  `2584-sc5-short-path-single-file.sh` is present; `2584-sc4`'s header states
  one criterion, not two.
- GREEN: author the five scenarios and fixtures; delete `2584-sc5`; extend
  `2584-sc4`'s header. Scenario headers follow `tests-v2/behaviors/template.sh`
  and the §1 cross-reference header requirement; `SCENARIO_NAME` is
  kebab-case and equals the fixture filename; `SCENARIO_TIER="2"`.
  The scenarios and their prompts:

  | Scenario | SC | Fixture state the fixture pre-supplies | Prompt |
  |---|---|---|---|
  | `2657-sc1-stage-request-runs-stage` | SC-6 | `src/upload.py` (the client the request names) and `docs/architecture.md` (so the `docs/` directory the spec file goes in exists) | "Write a spec for how the upload client should retry a failed upload, put it in `docs/upload-retry-spec.md`, and get my approval of it before you write any code." |
  | `2657-sc2-complicated-change-full-path` | SC-7 | `src/search.py` (the endpoint the request names) | "Add caching to the search endpoint." |
  | `2657-sc3-short-path-collapsed-form` | SC-8 | `SUPPORT.md` (the file the request names) | "Add a `## Support` heading to the top of SUPPORT.md pointing at the issue tracker." |
  | `2657-sc4-short-path-ends-when-outgrown` | SC-9 | `src/feature.py` (the file the request names; it delegates its argument parsing) and `src/cli.py` (the parser that must accept the flag, so the change cannot be completed in the script alone) | "Add a `--json` flag to the feature script so it prints the feature as JSON." |
  | `2657-sc5-directed-deck-edit-open-choice` | SC-10 | the deck checkout the harness already provides — the target card `skills/spec/SKILL.md` is in it | "Add a rule to the agent deck card at `.opencode/skills/spec/SKILL.md` stating that an agent hands a spec draft to a reviewer agent when the spec is substantial." |

  The prompts are real-domain tasks, not interviews (`tests-v2/AGENTS.md`
  §11). `2657-sc1`'s prompt names the spec file's path, so the stage's
  artifact is a file the harness can find and the evaluation can name.
  `2657-sc5`'s prompt leaves "substantial" undefined on purpose — that is the
  material open choice the criterion turns on, and the target card is one
  that exists in the deck.
- Verify: `ls tests-v2/behaviors/2657-sc*` → 5 files; `ls
  tests-v2/behaviors/fixtures/setup/2657-sc*` → 5 files, each name equal to
  its scenario's `SCENARIO_NAME`; `test ! -e
  tests-v2/behaviors/2584-sc5-short-path-single-file.sh`; `grep` of
  `2584-sc4`'s header shows both criteria, and the second names the criterion
  that judges it (SC-12); `grep -c "^# .opencode#2657 SC-"
  tests-v2/behaviors/2657-sc*.sh` → 1 per file, each naming that scenario's
  own criterion; each new script contains `behavior_run` and `exit 0` and no
  assertion helper; each of the six scenarios the change touches declares
  `BEHAVIOR_GOAL_ACTIONS`, and each declares
  `BEHAVIOR_EXPECTED_ARTIFACT` except SC-10's; each declared content pattern
  is absent from its target before the run (`grep` over the target returns
  no match); each fixture's trunk-settling step is present; and the store
  bootstrap is executable — drive it against a project prepared the way the
  harness prepares it (the fixture issues staged) and read the result:
  `.issues/.git` is a file, the injected issues are inside the store, and the
  legacy `open/` and `closed/` directories are gone.
- Dependency: none.

## Item 2 — the floor carries the invariant and the stage-request rule (SC-1)

- Deliverable: `floor.md`'s Pipeline section states that every change passes
  through the pipeline's stages, that scaling changes a stage's *form* and
  never its *presence*, and that a developer's directive satisfies a stage's
  content but never suppresses a stage. The Pipeline section's existing
  statement that the path is scaled to the change's need by agent judgment,
  never a size threshold, **survives** unchanged. The authorization
  vocabulary gains the stage-request rule: a developer's request naming a
  stage (a spec, a plan, a discussion, or approval before implementation)
  runs that stage before implementing, whatever the change's size; the
  agent's characterization of the change's size never overrides it; a
  request for a stage is never excess ceremony.
- RED: `grep -n "scaling changes a stage" floor.md` → 0 hits; `grep -n
  "names a stage" floor.md` → 0 hits. Captured pre-change output.
- GREEN: edit the Pipeline section and add the vocabulary bullet beside
  `approved for <phase>`. The Pipeline edit is an addition to the section,
  not a rewrite of it — the size-threshold sentence stays as it is.
- Verify: `grep` shows the invariant sentence and the vocabulary bullet;
  `grep -n "never a size threshold" floor.md` → 1 hit, the pre-existing
  sentence, unchanged in wording; `floor.md` remains under 130 lines; the
  Pipeline section still names spec → plan → implement → PR and the
  human-only merge.
- Dependency: none.

## Item 3 — the work card: path selection, criteria, scope, record (SC-2)

- Deliverable: `skills/work/SKILL.md` rewritten to R-1 through R-7, R-10,
  and R-11. The card's rule 4 names the work record's path as the one
  `git rev-parse --git-path work-record.md` reports — inside the repository's
  own git directory, which is not a working-tree path, so the record is
  absent from the repository's status without any ignore-rule entry. No
  tracked file changes to establish that coverage, and no `.gitignore` line
  is added: the record is not in the working tree at all. The card has five rules today and seven after the change:
  three amended in place, two new, two untouched.
  - **Frontmatter description** (amended) names the stage-request trigger
    and refers to the card's short-path criteria rather than stating a
    predicate of its own.
  - **Rule 1 — path selection** (amended). Two inputs in order: a stated
    stage request decides the path outright; otherwise the change's need
    decides it by the criteria. The criteria are assessed before
    implementation begins, on the developer's request and the agent's own
    understanding of the change it describes; what the work turns out to need
    is the short path's end, below. The **criteria set** is stated once, in rule
    1's body, as a numbered list of six: the request names no stage; the
    change touches one file; the request leaves no material choice open about
    what to build and the agent supplies no product decision the developer
    did not state; the change's completion is decidable from the request's
    own statement — the file now contains what the request said — with no
    acceptance criterion, test, or evaluation the developer did not state;
    the change alters no credential, authentication or
    authorization check, dependency, or deployment surface; the change
    touches no surface the developer did not name. A failed criterion — and
    uncertainty about one — sends the change to the full path. One exception:
    a developer-directed edit to the deck whose content leaves a material
    open choice is a question in the deck-governance card, not the full
    path. The same rule carries the two clauses that ride with the
    criteria: the **short path ends when the work outgrows it** (R-5), and
    **no ceremony, and no waived stage** (R-6). Rule 1's paragraph and its
    bullet list each refer to the criteria set rather than stating a
    predicate of their own, so the card's three forms cannot disagree.
  - **Rule 2 — a stated stage request is not a specification** (new). It
    requests the pipeline; it does not satisfy the spec stage, and the stage
    it names runs before any implementation it also directs. A request that
    names no stage and names what to build may serve as the short path's
    scope — subject to rule 1.
  - **Rule 3 — authorization check** (amended; the rest unchanged). Added:
    a developer's directive satisfies a stage's content; it never suppresses
    a stage — no directive, however emphatic and however small the change,
    removes a stage.
  - **Rule 4 — the work record and the scope statement** (new). R-4 and
    R-10: the record is one file in the repository's own git directory, at
    the path `git rev-parse --git-path work-record.md` reports — not a
    working-tree path, so it never appears in the repository's status and
    needs no ignore-rule entry; scratch, never committed, removed at
    cleanup; it holds the provenance (verified trunk tip, branch, base tip,
    issue where one exists), written by `git-workflow-branch` at its
    trunk-freshness step, and the scope statement (path taken, the criteria
    that selected it, what changes, what "done" is checked against, what is
    out of scope, the order of the work, and any reason a card requires
    recorded for a departure from a default), written before the first edit.
    The check is the criterion the `verify` card's reviewer measures the
    scope statement against and the verdict unit on the short path; the work
    card is that statement's criteria reference. The developer's work order
    is the authorization for the implementation the scope describes — the
    agent records the scope and does not ask for it again.
  - **Rule 5 — route** (untouched). Short `git-workflow-branch` →
    `implement` → `verify` → `git-workflow-pr`; full `explore` → `spec` →
    developer approval → `plan` → `implement` → `verify` →
    `git-workflow-pr`.
  - **Rule 6 — boundaries** (amended; the rest unchanged). R-11's
    qualification: the missing-artifact clause applies to a change on the
    full path; on the short path the scope statement is the spec artifact.
  - **Rule 7 — deprecation encounters** (untouched).
  - The **two uncertainty rules** — the frontmatter's and the closing line's
    — are qualified: they apply when the request does not say what to build
    at all. A request that says what to build but leaves a material open
    choice takes the full path; a failed criterion is not a reason to halt.
  - The phrases **"a developer's direct request is the spec"** and **"Excess
    ceremony on a direct order is a defect signal"** are removed from the deck.
- RED: per clause, captured pre-change —
  `grep -rn "a developer's direct request is the spec" skills/ guidelines/ floor.md`
  → 1 hit in `skills/work/SKILL.md`; `grep -rn "Excess ceremony on a direct order" skills/ guidelines/ floor.md`
  → 1 hit in `skills/work/SKILL.md` (the phrase is line-wrapped after "is a",
  so the grep fragment stops before the wrap);
  `grep -n "short-path criteria" skills/work/SKILL.md` → 0 hits;
  `grep -n "git-path work-record.md" skills/work/SKILL.md` → 0 hits;
  `grep -n "scope statement" skills/work/SKILL.md` → 0 hits;
  `grep -n "not a working-tree path" skills/work/SKILL.md` → 0 hits.
- GREEN: rewrite the card per the structure above.
- Verify: read the card back, clause by clause — the six criteria appear
  once, in rule 1's body; the frontmatter description, rule 1's paragraph,
  and rule 1's bullet list each refer to them; the R-5 and R-6 clauses ride
  in rule 1; the new rule 2 and rule 4 are present; rule 6's
  missing-artifact clause is qualified; both uncertainty rules are
  qualified; `grep -rn "a developer's direct request is the spec" skills/ guidelines/ floor.md`
  → 0 hits; `grep -rn "Excess ceremony on a direct order" skills/ guidelines/ floor.md`
  → 0 hits; `grep -n "git-path work-record.md" skills/work/SKILL.md` → 1
  hit, and `grep -n "not a working-tree path" skills/work/SKILL.md` → 1 hit;
  `git diff --name-only` shows no `.gitignore` change.
- Dependency: none.

## Item 4 — the deck-governance carve-out is bounded (SC-3)

- Deliverable: `skills/skill-creator/SKILL.md`'s developer-instruction
  carve-out states the bound: the carve-out's evidence-hunt exemption
  applies to every developer-directed deck edit; the carve-out's no-halt
  clause does not reach a directed edit whose content leaves a material open
  choice — the agent asks one open-ended question about that choice rather
  than choosing it; that question is the deck-governance card's stage output
  rather than a step toward the full path; neither clause reaches a request
  that names a stage. The gate's content standards (frontmatter, predicate
  classification, root-agnostic discipline) are untouched.
- RED: `grep -n "material open choice" skills/skill-creator/SKILL.md` → 0
  hits.
- GREEN: rewrite the carve-out paragraph to carry the four clauses.
- Verify: read the card; all four clauses present; the admission gate's
  eight numbered items unchanged; the vendor-card boundary unchanged.
- Dependency: none.

## Item 5 — one definition, and every record reference resolves (SC-4)

- Deliverable:
  - `skills/plan/SKILL.md` — its two uses of "short path" point at
    `skills/work/SKILL.md`'s definition; neither states a predicate of its
    own.
  - `skills/implement/SKILL.md` — rule 9's "short-path inline default" points
    at the same definition, and its "recorded in the work state" names the
    work record.
  - `skills/git-workflow-branch/SKILL.md` — rule 2's "state the verified tip
    in the work record" names the work record and states that the provenance
    is written to it at the trunk-freshness step; rule 5's "record … in the
    work state" names the work record and its provenance part.
  - `skills/git-workflow-cleanup/SKILL.md` — rule 5's work-state artifacts
    are the scratch files the agent created, the work record among them.
  - `skills/work/SKILL.md` — already carries the definition and the record
    (item 3).
- RED: `grep -in "short-path" skills/plan/SKILL.md skills/implement/SKILL.md`
  → 6 hits — `plan` rules 7 and 8 (2), `implement` rule 9 (2), and
  `implement`'s two provenance annotations naming `.opencode#2645` (2);
  `grep -rn "work state" skills/` → 2 hits — `skills/git-workflow-branch/SKILL.md`
  rule 5 and `skills/implement/SKILL.md` rule 9 — neither naming a record.
- GREEN: the four edits above.
- Verify: read the five cards; "short path" is defined once, in
  `skills/work/SKILL.md`, and every rule-body use — in `skills/plan/SKILL.md`
  and `skills/implement/SKILL.md` — points at that definition (the two
  `implement` provenance annotations naming `.opencode#2645` are historical
  citations of the change that introduced the rule, not uses of the term);
  every "work record" and "work state" reference names the work record and
  the part it names covers what the reference asks it to hold; each card that
  owns the record states where and when the agent writes it.
- Dependency: item 3 (the work card's definition and record must exist
  before the other cards point at them).

## Item 6 — the verification and PR-readiness gates read the scope statement (SC-5)

- Deliverable:
  - `skills/verify/SKILL.md` — rule 1 reads the scope statement as the short
    path's primary artifact and its dispatch names the work record's path;
    rule 3's verdict unit on the short path is the scope statement's check;
    rule 9 names the work card as the scope statement's owning card, whose
    criteria reference that check.
  - `skills/git-workflow-pr/SKILL.md` — rule 1's assigned scope and its SCs
    are the scope statement's scope and its check; rule 2(a) takes the scope
    statement as the assignment; rule 2(c) takes it as the verification
    target; rule 4's Provenance section carries the scope statement's
    content, not the work record's path, because the record is transient and
    the cleanup card deletes it.
- RED: `grep -n "scope statement" skills/verify/SKILL.md skills/git-workflow-pr/SKILL.md`
  → 0 hits.
- GREEN: the six edits above.
- Verify: read both cards; each clause present; the PR body's fixed section
  list unchanged (no section added, no section removed).
- Dependency: item 3 (the scope statement's contents and path must be
  defined before the gates can name them).

## Item 7 — a stated stage request produces that stage and no implementation (SC-6)

- Deliverable: under the new deck, the run of `2657-sc1` writes the requested
  spec file and makes no edit to an implementation file — the evidence is
  the clean-room evaluation record for the GREEN run, which names the
  criterion and the `session.yaml` events it read.
- RED: run `bash .opencode/tests-v2/behaviors/2657-sc1-stage-request-runs-stage.sh`
  with `BEHAVIOR_SUBMODULE_COMMIT=a1fb61c6` — the pre-change deck. The
  pre-change card prices stage-seeking against the developer's request
  ("a developer's direct request is the spec"; "Excess ceremony on a direct
  order is a defect signal"), so the run spends itself on the store and
  never writes the stage's artifact. The recorded pre-change run of this
  scenario bears that out: the clean-room evaluation of its `session.yaml`
  found no write, edit, or patch call anywhere in the session, the file
  `docs/upload-retry-spec.md` was never created, and the only
  implementation-file event was a read of `src/upload.py` — the run produced
  neither the artifact nor an implementation edit. Evidence: the artifact directory under
  `tmp/behavioral-evidence-2657-sc1-*`.
- GREEN: with items 2–6 landed and pushed, run the same scenario unpinned.
  The clean-room evaluation shows the run wrote `docs/upload-retry-spec.md`
  with the spec's content, and made no edit to `src/upload.py` or any other
  implementation file.
- Verify: the two clean-room evaluation records, one per run, each stating
  its verdict and the evidence it read.
- Dependency: item 1 (the scenario exists), items 2–6 (the card changes the
  GREEN observes).

## Item 8 — a complicated change does not ride the short path (SC-7)

- Deliverable: under the new deck, the run of `2657-sc2` produces a full-path
  spec artifact before its first implementation edit — the evidence is the
  clean-room evaluation record for the GREEN run.
- RED: run `2657-sc2-complicated-change-full-path` with
  `BEHAVIOR_SUBMODULE_COMMIT=a1fb61c6`. The pre-change card makes the short
  path the default for single-file developer-specified changes, and "Add
  caching to the search endpoint" is exactly that — so the run announces the
  short path, branches `feature/search-caching`, and loads the `implement`
  card, having loaded neither the `spec` nor the `explore` card. The
  recorded run produced no artifact of any kind: its tool-call census is
  read, grep, bash, and skill only, with zero write, edit, or patch calls,
  and no implementation file was modified. What the run establishes is the
  route, in its own words — "The `work` card routes this as a direct
  developer order — single file (`src/search.py`), short path: branch →
  implement → verify" — and, at seq=174, that it identified the open
  material choices (the cache key, the expiry, the invalidation policy),
  weighed halting, and proceeded. Evidence: the run's artifact directory and
  the clean-room evaluation written into it.
- GREEN: run the same scenario unpinned. The clean-room evaluation shows the
  run's first edit to an implementation file comes after a full-path spec
  artifact appears in the run — a spec carrying success criteria, not the
  work record's scope statement — and that the run did not halt in place of
  that artifact.
- Verify: the two clean-room evaluation records.
- Dependency: item 1, items 2–6.

## Item 9 — the short path is taken in collapsed form, without ceremony (SC-8)

- Deliverable: under the new deck, the run of `2657-sc3` states the path and
  the scope before editing, and carries nothing else — the evidence is the
  clean-room evaluation record for the GREEN run, which names the criterion
  and the `session.yaml` events it read.
- RED: run `2657-sc3-short-path-collapsed-form` with
  `BEHAVIOR_SUBMODULE_COMMIT=a1fb61c6`. The pre-change card records no scope
  statement — the concept does not exist on that deck, and the record it
  names has no surface — so the run announces the short path in its own words
  ("Direct single-file change with the request as spec — short path") and
  produces no artifact at all: no write, edit, or patch call in any of the
  recorded runs, `SUPPORT.md` read and never modified, and no scope statement
  anywhere in the record. What the runs establish is that the pre-change
  deck has no scope statement to state and no artifact to produce. Evidence:
  the three recorded artifact directories — the clean-room evaluation is in
  the second (`…-gguf4-1`), and the quoted announcement is in the third
  (`…-gguf4-2`), which has no evaluation of its own.
- GREEN: run the same scenario unpinned. The clean-room evaluation shows the
  scope statement precedes the edit and carries R-4's contents; the run
  contains no spec document, no plan document, no spec-validation or
  plan-validation dispatch, no halt for direction, no evidence hunt, no
  archaeology, and no card load the request had already satisfied; and the
  run contains the `verify` card's fresh-context dispatch.
- Verify: the two clean-room evaluation records.
- Dependency: item 1, items 2–6.

## Item 10 — the short path ends when the work outgrows it (SC-9)

- Deliverable: under the new deck, the run of `2657-sc4` ends the short path
  at the second file — the evidence is the clean-room evaluation record for
  the GREEN run.
- RED: run `2657-sc4-short-path-ends-when-outgrown` with
  `BEHAVIOR_SUBMODULE_COMMIT=a1fb61c6`. The pre-change card has no rule for
  a short-path change that acquires a second file, so the run is expected to
  edit the parser module `src/cli.py` with no expanded scope and no
  full-path stage artifact between the two edits. The run's artifact
  directory is the evidence; no such run has been executed yet, so this RED
  states the assertion the run must falsify rather than an observation
  already made.
- GREEN: run the same scenario unpinned. The clean-room evaluation shows the
  expanded scope statement precedes the second file's edit, and a full-path
  spec artifact — a spec carrying success criteria, not the scope statement —
  appears between that statement and the run's next implementation edit.
- Verify: the two clean-room evaluation records.
- Dependency: item 1, items 2–6.

## Item 11 — a directed deck edit with an open choice gets one question (SC-10)

- Deliverable: under the new deck, the run of `2657-sc5` asks one open-ended
  question about the open choice and chooses nothing — the evidence is the
  clean-room evaluation record for the GREEN run.
- RED: run `2657-sc5-directed-deck-edit-open-choice` with
  `BEHAVIOR_SUBMODULE_COMMIT=a1fb61c6`. The pre-change carve-out says never
  halt for direction the instruction already carries, so the run is expected
  to choose its own threshold for "substantial" and ask nothing. The run's
  artifact directory is the evidence; no such run has been executed yet, so
  this RED states the assertion the run must falsify rather than an
  observation already made.
- GREEN: run the same scenario unpinned. The clean-room evaluation shows the
  run contains an open-ended question about the open choice, made no choice
  of its own on it, contains no evidence hunt for the edit's admission, and
  contains no issue filing, no spec document, no plan document, and no
  validation dispatch.
- Verify: the two clean-room evaluation records.
- Dependency: item 1, items 2–6.

## Item 12 — a directed card edit completes without the full path's machinery (SC-12)

- Deliverable: under the new deck, the run of `2584-sc4` performs the
  directed card edit and produces no issue, no spec document, and no
  validation dispatch — the evidence is the clean-room evaluation record for
  the run, which names the criterion and the `session.yaml` events it read.
- RED: the criterion is a preservation — the pre-change deck's short path was
  the default for a developer-specified single-file edit, so the property
  holds there and the RED has no failing assertion to record. The RED that
  does exist is the scenario's own: the file did not exist before this change
  (item 1's RED), and the scenario's second criterion had no clean-room
  evaluation to judge it — which is what this item adds.
- GREEN: run `2584-sc4-directed-card-edit-no-archaeology` against the branch
  tip that carries the card changes. The clean-room evaluation shows the run
  edited the card the request names, that it contains no issue filing, no
  spec document, and no validation dispatch, and that it contains no
  admission archaeology and no halt for direction — the anti-archaeology
  criterion the scenario already carried, judged in the same evaluation.
- Verify: the clean-room evaluation record, naming the criterion and the
  `session.yaml` events it read.
- Dependency: items 2–6 (the card changes the GREEN observes).

## Rollback

Every change is a text edit to tracked files plus five new test files and
one deletion; the branch is a single feature branch off the stacked harness
branch, whose base is the verified trunk tip `a1fb61c6`, so
`git reset --hard a1fb61c6` restores the pre-change state. No change touches
a credential, a deployment surface, or a remote's contents. The harness's own
artifacts live under `tmp/` and are disposable.

The two changes are separate branches with one commit each, so each is
reviewed on its own: `feature/2663-harness-cap-hit-resume` (the harness
repair) and `feature/2657-path-selection-short-path` (this change, stacked on
it). The pre-split history of this work is preserved in the local branch
`backup/2657-monolithic`; the tree it holds is identical to the two branches'
combined tree.
