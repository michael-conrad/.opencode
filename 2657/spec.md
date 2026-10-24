# Spec: Path selection honors a stated stage request; the short path is bounded, recorded, and coherent

Provenance: developer directive 2026-10-23, in-session — "the short path is
used by the agent to bypass spec requirements for complicated changes by
claiming they are simple" and "the agent also uses it as an excuse to bypass
discussions and approval of specs to directly begin implementation without a
spec or plan even when the user has specifically stated from the start 'create
spec' 'for a spec' 'brainstorm spec' and other similar indication that a SPEC
was needed. The implementation was unexpected, confusing, and had to be
halted manually and any work rejected." Observed failure in the deck text:
`.opencode#2584` (commit `1e1d551c`, 2026-10-12) added the short-path default
and the developer-instruction carve-out to `skills/work/SKILL.md` and
`skills/skill-creator/SKILL.md`; `.opencode#2645` (commit `c816c146`,
2026-10-20) carried the same term into `skills/implement/SKILL.md` rule 9
without re-examining what the term had come to mean. Observed failure in the
measurement: `.opencode/.issues/lessons-learned/session-2026-10-20/README.md`
LL-3 (the anchorless cap-hit resume, observed on the `#2639` recovery path)
and this issue's own run records — the preserved
`tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/`
run and its per-poll supervision log, and the scenario-layer observations
recorded in this issue's `evidence.md`.

## Problem

Two failure modes share one text in the deck's change router, a third leaves
the escape unrecorded and under test, a fourth means the deck has no
coherent short path to restore, and a fifth is in the measurement rather than
in the deck.

### Problem 1 — a stated stage request is read as excess ceremony

`skills/work/SKILL.md` rule 1 states that the short path is the default for
single-file, developer-specified changes, that "a developer's direct request
is the spec", and that "machinery beyond the short path (extra card loads,
evidence hunts, approval-seeking) requires a reason visible in the work
record. Excess ceremony on a direct order is a defect signal, never
thoroughness."

A developer's request naming a stage — "create a spec", "for a spec",
"brainstorm spec" — asks for the pipeline. The card gives the agent no way to
distinguish that request from an ordinary work request, and the card prices
the stage against the request: the request for a spec is the very "machinery"
the card names as a defect signal, and "a developer's direct request is the
spec" resolves the request to a specification without a specification ever
being written. The agent begins implementation with no spec and no plan, the
implementation is unexpected and confusing, and the developer halts the work
manually and rejects it.

### Problem 2 — the short path is self-certified, so complicated work rides it

The work card states the short path's predicate three times, and none of the
three supplies the criterion that matters. Its frontmatter description says
"trivial fixes take the short path, multi-part features take the full path".
Its bullet form is "*Short path*: single-file fix, typo, config tweak — the
developer's request itself is the spec; it is verified at PR review". Its
paragraph form generalizes it to "single-file, developer-specified changes".
The frontmatter is the routing surface the platform reads, so its form
carries the most weight; it is also the loosest, because "trivial" is the
agent's characterization and "multi-part" is not the question a complicated
single-file change turns on. The single-file bound is checkable, and this
spec keeps it. What none of the three supplies is a criterion that separates
single-file work the request has decided from single-file work it has not: a
change that carries acceptance criteria, needs a product decision the
developer did not state, or leaves a material choice open is still one file,
and "developer-specified" is satisfied by the developer having mentioned the
change. An agent that characterizes such a change as simple skips the spec
requirement the developer holds, and the deck's own text supplies the
rationale for the skip.

### Problem 3 — the escape is unrecorded, and one of the deck's own tests enforces it

Four cards reference a "work record" or "work state" — `skills/work/SKILL.md`
rule 1, `skills/git-workflow-branch/SKILL.md` rules 2 and 5,
`skills/implement/SKILL.md` rule 9, and `skills/git-workflow-cleanup/SKILL.md`
rule 5 — and the only gloss the deck offers is git-workflow-cleanup's
parenthetical "work files, scratch state". No card names a surface the agent
can write to, so the condition the short path attaches to its escape is
unverifiable and a short-path classification leaves no trace.

One behavioral scenario asserts the escape's behavior as correct:
`tests-v2/behaviors/2584-sc5-short-path-single-file.sh` asserts that a
developer-specified change takes the short path with "no full-pipeline
machinery beyond it". Under `tests-v2/AGENTS.md` §6b (CM-1), a test survives
only if a real defect would escape without it; this one exists to penalize
the pipeline's presence, so a fix that changes the card text and leaves it in
place leaves the deck testing for the escape. The other scenario,
`2584-sc4-directed-card-edit-no-archaeology.sh`, asserts the carve-out's
anti-archaeology property — a directed deck edit completes without admission
archaeology and without halting for direction. That property survives this
change and is preserved, extended rather than retired.

### Problem 4 — the short path has no artifact, so the deck's own rules contradict it

The work card's short route runs `git-workflow-branch` → `implement` →
`verify` → `git-workflow-pr`, and `skills/verify/SKILL.md` rule 1 dispatches a
fresh-context reviewer that "reads the primary artifacts directly — spec/SCs,
the diff, the executed test output". Three gates in `skills/git-workflow-pr`
then bind on what the short path does not produce. Rule 1 conditions PR
creation on "(a) the issue's full assigned scope ... is implemented and
verified" and on a "verify pass PASS on the deliverable's SCs". Rule 2(a)
requires "every item assigned to this PR by the spec" to have an
implementation commit. Rule 2(c) blocks PR creation until a "fresh-context
`verify` PASS recorded against the issue's spec" exists. A short-path change
has no spec artifact, so it has no assigned scope, no SCs, and no
verification target for those three gates to bind to.

The absence of an issue is a separate matter: `skills/git-workflow-branch/SKILL.md`
rule 5 treats it as an expected state — "When the work has no issue, record
branch and base tip only — never create an issue, or initialize an issue
store, to satisfy provenance" — and a short-path change may carry an issue
that already exists. The three gates fail on the missing spec artifact, not
on the missing issue, and a fix must say which.

`skills/work/SKILL.md` rule 4 compounds the problem: "Missing upstream
*artifacts* (no spec, plan, or branch yet) trigger the pipeline itself: run
it from the earliest missing stage under the granted authorization" — a
short-path change never has a spec artifact, so rule 4 routes it into the
full pipeline from the spec stage. The short path as the deck states it is
therefore not a path the deck's own rules let an agent walk. The deck never
says which artifact stands in for the spec and the plan on the short path,
where that artifact is written, or how the fresh-context reviewer reaches it,
and the agent fills those gaps by whichever reading favours it — which is how
a request for a spec came to be read as a request that already had one.

### Problem 5 — the measurement cannot complete a run

The behavioural scenarios that would show this fix's effect cannot complete a
run. The harness resumes a run whose turn ended at the per-turn output cap
with the anchorless message "Continue the task from where you left off.", so
the model re-derives the session's history from a long context, spends the
whole per-turn budget re-deriving, and issues no tool call. The deck records
this in its own correction catalogue — `.opencode/.issues/lessons-learned/
session-2026-10-20/README.md`, LL-3, observed on the `#2639` scenario's
recovery path: the default resume message "gives the model no state anchor,
so it reconstructs from a ~65k-token context every turn" and issues "ZERO
tool calls". The run records are this issue's own: the preserved
`tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/`
run, whose final assistant message ended `reason: "length"` at exactly 4,000
output tokens with a reasoning part and no tool call, and the per-poll
supervision log beside it. The fixture observations are recorded in this
issue's `evidence.md`. The resume makes
no progress, the run exhausts the cap-resume ceiling, and the stage's
artifact — the thing each behavioural criterion asks about — is never
produced. The run-level fix `.opencode#2639` applied to its own scenario's
bespoke recovery path; the generic path every scenario takes still sends the
anchorless form. R-13 makes the resume carry the recorded tail, so the
resumed turn continues the recorded work instead of restarting it.

The determination gate that guards a resume is the third measurement
defect, and its cause is scan coverage rather than a missing record: the
harness writes the determination record and the orchestrator decision into
the run's artifact directory before it attempts the cap-hit resume, but the
gate's scan roots were the Docker tier's staging root and the run's
behaviour-test directory — neither of which contains the artifact directory.
The gate therefore reported `determination.yaml not found in any scenario
evidence dir` and refused every cap-hit resume before any inference was
dispatched, and the run exhausted the cap-resume ceiling with its artifact
never produced.

Two further defects at the scenario layer keep a run from being judged or
from recovering: a scenario that declares no goal condition leaves the
monitor's classifier with no direction anchor, so it returns "undetermined"
and the determination gate blocks the resume path; and a fixture that leaves
the test project's `main` ahead of its remote tip makes the branch card's
trunk-tip verification ambiguous — which tip is the base the branch is cut
from — so the run agent spends its run establishing the relationship instead
of doing the task. R-9 and SC-11 carry both.

## Root causes

- **RC-1** — Path selection takes one input: the agent's characterization of
  the change's size. A developer's stated stage request is not an input, and
  the card's wording makes the request read as evidence against the full path.
- **RC-2** — The short path's predicate bounds the file count but supplies no
  criterion separating work the request has decided from work it has not, and
  its loosest statement — the frontmatter's "trivial fixes take the short
  path" — states the predicate in terms of the agent's characterization, so it
  is self-certifying.
- **RC-3** — "Excess ceremony" names no observable criterion, and it is aimed
  at stages rather than effort, so it operates as an unappealable veto over
  the pipeline and hands the agent a rationale for skipping a requested stage.
- **RC-4** — The escape's condition names a record that no card names as a
  surface the agent can write to, so the classification is unverifiable and
  leaves no trace.
- **RC-5** — A behavioral scenario asserts the escape's behavior, so the
  escape carries test protection.
- **RC-6** — No card says which artifact the short path produces, where it
  lives, or who reads it, so the work card's route, its boundary rule, the
  verify card's reviewer, and the three PR-readiness gates each read the
  short path differently, and the agent resolves the disagreement in its own
  favor.
- **RC-7** — The harness's cap-hit resume sends a message with no state
  anchor, and the scenarios declare no goal condition for the monitor's
  classifier to judge the run against, so a run that hits the per-turn output
  cap cannot be judged, cannot resume, and cannot produce the artifact its
  criterion asks about. The fixtures' own repository state — `main` ahead of
  the remote tip — adds a second way for the run to spend its time on
  something the task never required.

## Requirements

- **R-1** — When the developer's request names a pipeline stage — a spec, a
  plan, a discussion, or approval before implementation — the agent runs that
  stage before implementing. The agent's characterization of the change's size
  does not override the request, and the developer's request for a stage is
  never evidence of excess ceremony. The rule lives in `floor.md`, which every
  session loads, and `skills/work/SKILL.md`'s frontmatter description names
  the stage-request trigger so the platform routes a stage-naming request to
  that card.
- **R-2** — A request for a stage is not a specification. It requests the
  pipeline; it does not satisfy the spec stage, and the stage it names runs
  before any implementation it also directs. A request that names no stage,
  and that names what to build, may serve as the short path's scope —
  subject to R-3.
- **R-3** — The short path is available only when every one of these criteria
  holds: the developer's request names no stage; the change touches one file;
  the request leaves no material choice open about what to build, and the
  agent supplies no product decision the developer did not state; the change's
  completion is decidable from the request's own statement — the file now
  contains what the request said — with no acceptance criterion, test, or
  evaluation the developer did not state; the change alters no credential,
  authentication or authorization check, dependency, or deployment surface;
  the change touches no surface the developer did not name. A criterion that
  fails sends the change to the full path, and so does uncertainty about
  whether a criterion holds. The criteria apply to a change to the agent
  deck as they do to any other change, and a deck change carries the
  deck-governance card's admission gate in addition, which is where the
  deck's content standards are judged; R-8 bounds that gate for a
  developer-directed edit. A developer-directed deck edit that satisfies these
  criteria takes the short path, so the work card's path selection does not
  turn a directed card edit into the full path's filed-issue-and-dispatches
  machinery. The two rules in the work card that state what to do when the
  path is unsure — its frontmatter's "Also load when unsure which stage
  applies: halt with an open-ended clarification request rather than guess"
  and its closing line "Unsure which path fits? Halt with an open-ended
  clarification request" — are read as applying to a request that does not say
  what to build at all, where the agent halts with one open-ended
  clarification request. A request that says what to build but leaves a
  material choice open about it fails the criterion above and takes the full
  path; the halt rule does not reach it, and the criterion-failure rule
  governs. One case is excepted: a developer-directed deck edit whose content
  leaves a material open choice is R-8's case — the agent asks one open-ended
  question in the deck-governance card, and does not take the full path.
- **R-4** — Every change records its path and its scope before implementation
  begins. A full-path change's spec artifact carries the scope. A short-path
  change carries it in a scope statement, which the agent writes into the work
  record (R-10) before it edits anything. The scope statement carries: the
  path taken, the R-3 criteria that selected it, what changes, what "done" is
  checked against, what is out of scope, the order of the work, and any
  reason a card requires recorded for a departure from a default. The check
  that "done" is verified against is the criterion the verify card's
  fresh-context reviewer measures the scope statement against, and it is the
  verdict unit on the short path; the work card declares it as that card's
  criteria reference for the scope statement, per the verify card's
  criteria-set-ownership rule. The
  developer's work order is the authorization for the implementation that scope
  describes: `floor.md`'s authorization vocabulary sends an utterance it does
  not list to default agent judgment, and the work card's boundary rule halts
  for authorization only on genuine ambiguity. The agent therefore records the
  scope and does not ask the developer to approve it again. A developer who
  wants to approve the scope before implementation asks for that stage, and
  R-1 routes the request to the full path.
- **R-5** — The short path ends when the work outgrows it. If, after the
  short path is taken, the work acquires a second file, a second concern, a
  derived success criterion, a product decision the developer did not state,
  or a surface the request did not name, the agent extends the scope
  statement in the work record with the expanded scope, re-applies R-3's
  criteria, and takes the full path from the earliest missing stage —
  producing that stage's artifact — before it makes any further
  implementation edit. The agent never completes a change as a short path
  when the change no longer satisfies R-3.
- **R-6** — The anti-ceremony rule `.opencode#2584` established stays and
  binds effort only: the agent performs no evidence hunt, archaeology, or card
  load that the developer's instruction already satisfied, and the agent does
  not re-ask for what the instruction carries. No stage is waived on either
  path. On the short path a stage's artifact takes the collapsed form R-11
  names, and a missing artifact is produced cheaply; on the full path each
  stage produces its own artifact. The text that prices stage-seeking against
  the developer's request is removed from the deck.
- **R-7** — A developer's directive satisfies a stage's content; it never
  suppresses a stage. No directive, however emphatic and however small the
  change, removes a stage from the pipeline. A directive that names a stage
  runs that stage; a directive that names a scope supplies the scope for the
  stage that scope belongs to.
- **R-8** — The `skill-creator` developer-instruction carve-out is bounded,
  not removed. The carve-out has two clauses, and the bound falls on one of
  them. The carve-out's **evidence-hunt exemption** — the admission gate's
  proposal-time evidence hunt does not re-run — applies to every
  developer-directed deck edit, whether or not a material open choice is
  present, because the developer's instruction is the edit's own evidence.
  The carve-out's **no-halt clause** — never halt for direction the
  instruction already carries — does not reach a directed edit whose content
  leaves a material open choice: the agent asks one open-ended question about
  that choice rather than choosing it. The deck's gate is the deck-governance
  card rather than the spec and plan stages, so that question is the stage's
  output in the deck case — the change does not take the full path, and R-3
  states the exception. Neither clause reaches a request that names a stage.
- **R-9** — The behavioral scenarios are brought in line with the rules:
  `2584-sc5-short-path-single-file` is retired; and
  `2584-sc4-directed-card-edit-no-archaeology` keeps its anti-archaeology
  criterion — a fully specified directed edit completes without admission
  archaeology and without halting for direction — and gains one beside it:
  the edit completes without the full path's machinery, with no issue filed,
  no spec document, and no validation dispatch. Scenarios are added covering
  R-1, R-3, R-4, R-5, R-6, and R-8. Each added scenario carries the
  per-scenario setup fixture that pre-supplies the repository state its task
  needs, per the pre-supplied environment mandate in `tests-v2/AGENTS.md`
  §3a, so that no run has to discover the environment before it can act.
- **R-10** — "Short path" resolves to exactly one definition, in
  `skills/work/SKILL.md`. The cards that *route* on the term —
  `skills/plan/SKILL.md` and `skills/implement/SKILL.md` — point at that
  definition; the cards that *consume* it — `skills/verify/SKILL.md` and
  `skills/git-workflow-pr/SKILL.md`, whose rules R-12 places on the short
  path — name the short path's artifact rather than the term's definition.
  The deck's records are named, and each card's reference names the record
  it means. There is one record: the **work record**, a single file in the
  repository's own git directory, at a path the work card's convention names.
  It carries two things. The **provenance** the branch card records — the verified
  trunk tip, the branch, the base tip, and the issue where one exists — which
  the branch card writes at its trunk-freshness step, before any modification
  and before the branch exists, and extends at its provenance step. The
  **scope statement** R-4 describes, which the work card writes before the
  first edit. The work record is a work-state artifact, which the cleanup
  card removes; it is not part of the branch's commits, because the commit
  card stages named files only; and the convention writes it inside the
  repository's own git directory, which is not a working-tree path, so the
  record is absent from the repository's status without any ignore-rule entry,
  never blocks a tool that requires a clean working tree, and touches nothing
  in the tracked tree. Every "work record" and "work state" reference in
  `skills/work/SKILL.md`,
  `skills/git-workflow-branch/SKILL.md`, `skills/implement/SKILL.md`,
  `skills/git-workflow-cleanup/SKILL.md`, `skills/verify/SKILL.md`, and
  `skills/git-workflow-pr/SKILL.md` — in each card's body and in its
  frontmatter description — names the work record, and the work record's two
  parts cover what that reference asks it to hold. The PR body's Provenance
  section carries the scope statement's **content** on the short path, not the
  work record's path: the work record is transient, and a path to a file the
  cleanup card deletes would leave the merged PR's provenance pointing at
  nothing.
- **R-11** — The scope statement in the work record is the short path's spec
  artifact. Its contents discharge the two stages the short path collapses:
  "what changes" is the spec stage's subject, "what 'done' is checked
  against" is the verification instrument both stages require, and "the order
  of the work" is the plan stage's ordering. For a one-file change the scope
  statement therefore discharges the spec stage and the plan stage together.
  `skills/work/SKILL.md` states this, and its boundary rule is qualified
  accordingly: the clause that missing upstream artifacts trigger the
  pipeline applies to a change on the full path, and a short-path change is
  one whose scope statement stands in for the spec and plan artifacts. The
  short route remains `git-workflow-branch` → `implement` → `verify` →
  `git-workflow-pr`.
- **R-12** — The verification and PR-readiness gates read the short path's
  artifact, and they measure it against a declared bar. `skills/verify/SKILL.md`
  rule 1 reads the scope statement as the short path's primary artifact
  alongside the diff and the executed test output, and the verify dispatch
  names the work record's path so the fresh-context reviewer reaches it; rule
  3's verdict unit on the short path is the scope statement's check; and rule
  9's owning card for the scope statement is the work card, which declares
  that check as the scope statement's criteria reference. In
  `skills/git-workflow-pr/SKILL.md`, rule 1's assigned scope and its SCs are
  the scope statement's scope and its check, rule 2(a) takes the scope
  statement as the assignment, rule 2(c) takes the scope statement as the
  verification target, and rule 4's Provenance section carries the scope
  statement's content as the spec it already requires. Where a short-path
  change carries an issue, that issue is the tracker record; the spec
  artifact remains the scope statement.
- **R-13** — The harness's cap-hit resume anchors the model on the recorded
  tail. When a run's turn ends at the per-turn output cap, the harness resumes
  the session with a directive message composed from the run's own session
  database: the agent's last recorded reasoning, and the recorded in-flight
  tool call when there is one. The anchorless form — "Continue the task from
  where you left off." — gives the model no state anchor, so it re-derives
  the session's history from a long context, spends the whole per-turn budget
  re-deriving, and issues no tool call; the resume makes no progress and the
  run exhausts the cap-resume ceiling with no artifact. Both the helpers'
  resume path and the Docker resume launcher's own default carry that
  message, so a caller that passes no message — as a scenario's direct-resume
  path may do — does not reintroduce the anchorless form. The per-turn output
  cap's default is unchanged, and the probe scenario that lowers the cap
  deliberately is untouched: the observed degenerate-turn band is where these
  turns sit, so raising the cap would re-open the failure the cap exists to
  prevent. The determination gate that guards a resume finds the record it
  needs: the gate's scan roots include the run's artifact directory, which is
  where the harness writes the determination record and the orchestrator
  decision, and both exist before the cap-hit resume is attempted. Without
  that root the gate never saw the record — the Docker tier's `TMP_DIR` is the
  staging root, which does not contain it — and refused every cap-hit resume
  with `determination.yaml not found in any scenario evidence dir`, so the run
  exhausted the cap-resume ceiling with its artifact never produced.

## Impact

**Consumers.** Every session that changes a file. `skills/work/SKILL.md` is the
router the platform matches before any file modification, and its frontmatter
description is the routing surface the platform reads — the dispatch table was
retired in `.opencode#2617`, leaving card descriptions as the sole routing
surface.

**Risk — the narrow path pushes trivial work into the full path.** The
ceremony complaint that `.opencode#2584` raised was real: the behavioral runs
it cites record a one-paragraph `CONTRIBUTING.md` task taking roughly nineteen
minutes of issue-store and remote archaeology before the write. Narrowing the
short path risks reproducing that. R-6 keeps the anti-ceremony rule and binds
it to effort, and R-4 and R-11 put a cheap scope statement where a spec
document would otherwise sit. SC-8 holds that win in place under test.

**Risk — a two-file change now takes the full path.** R-3 keeps the
single-file bound the work card already carried, so a change that needs a
second file produces a spec document. That is a cost this spec accepts: the
developer reported complicated work riding the short path, and the single-file
bound is the deck's own existing line between the two paths.

**Risk — an agent-proposed deck change now takes the full path.** R-3's
criterion that the request leave no material choice open about what to build
fails for a deck change the agent proposes itself, because the agent supplies
the product decisions. A developer-directed deck edit still takes the short
path, which is the shape `.opencode#2584` and the retained `2584-sc4` address;
where that edit's content leaves a material open choice, the
deck-governance card's one question stands in for the short path's scope
statement, and the scope statement follows the developer's answer. The change
is a cost this spec accepts: the deck's own history of ungoverned edits is
why the deck-governance card exists, and an agent proposing a rule the
developer did not ask for is work the developer holds the right to see a spec
of.

**Risk — the behavioural criteria may not be measurable in this harness.**
Three of the five behavioural criteria (SC-6, SC-7, SC-9) turn on a
full-path spec artifact appearing in the run, and the model's first turn on
this deck routinely exceeds the harness's per-turn output budget, so the
artifact's production is not guaranteed. R-13 is the remedy: the anchorless
cap-hit resume made every capped turn re-derive the session's history and
issue no tool call, so a run that hit the cap could not finish its artifact;
the tail-anchored resume lets the resumed turn continue the recorded work.
This risk is disclosed rather than assumed away because the criteria are
judged from the run that actually happens. If the re-runs show the artifact
still not produced, these three criteria must be re-scoped at this spec — the
scenario's artifact made small enough for the budget — and this spec revised
and re-validated, before the criteria can be judged.

**Risk — the criteria are intent-decidable.** R-3's criteria are judgment
calls, so an agent can still mischaracterize a complicated change. R-4's
recorded scope makes the characterization falsifiable at review rather than
self-certified, and R-5 re-examines it when the work outgrows it.

**Blast radius.** `floor.md`; the `work`, `plan`, `implement`,
`skill-creator`, `verify`, `git-workflow-pr`, `git-workflow-branch`, and
`git-workflow-cleanup` cards; `tests-v2/behaviors/`; the cap-hit resume
path in `tests-v2/behaviors/helpers.sh` together with the Docker resume
launcher in `tests-v2/docker/docker-harness.sh`, the determination gate
in `tests-v2/with-test-home`, and the three surfaces that state the gate's
behaviour — `tests-v2/AGENTS.md` §10.7 and §14 and
`skills/behavioral-testing/SKILL.md` rule 9. The amendments to
`verify`, `git-workflow-pr`, `git-workflow-branch`, and `git-workflow-cleanup`
are clause-level clarifications that name the artifact the card already
requires and, for the verify card, the verdict unit and owning card the
short path uses. The PR body's fixed section list is preserved: the Provenance
section's contents widen on the short path to carry the scope statement's
content, and no section is added. No change reaches `guidelines/`, `agents/`,
`prompts/`, `opencode.jsonc`, the `tests-v2` harness's isolation contract, its
default model, its change-control rules, or its per-turn output cap, and
nothing reaches the retired `attic/` deck.

## Success criteria

### SC-1 (structural) — the floor carries the invariant and the stage-request rule

`floor.md` states that every change passes through the pipeline's stages, that
scaling changes a stage's form and never its presence, and that a developer's
directive satisfies a stage's content but never suppresses a stage. Its
authorization vocabulary carries the stage-request rule: a request naming a
stage runs that stage, and the agent's characterization of the change's size
does not override it. Its existing statement that the path is scaled to the
change's need by agent judgment, never a size threshold, survives.

- **Verify:** read `floor.md`; each statement present.

### SC-2 (structural) — the work card carries the rules and loses the escape

`skills/work/SKILL.md` states R-1 through R-7, R-10, and R-11, and its
frontmatter description names the stage-request trigger so the platform routes
a stage-naming request to the card. R-3's criteria are stated once, in rule
1's body, and the card's frontmatter description, its bullet list, and its
paragraph each refer to those criteria rather than stating a predicate of
their own, so the three cannot disagree. Its two uncertainty rules — the
frontmatter's and the closing line's — are qualified per R-3. The phrases
"a developer's direct request is the spec" and "Excess ceremony on a direct
order is a defect signal" appear nowhere in the deck's live surfaces — the
cards under `skills/`, the guidelines under `guidelines/`, and `floor.md`.

- **Verify:** read the card; each element present. A deck-wide search of
  `skills/`, `guidelines/`, and `floor.md` returns no occurrence of either
  phrase.

### SC-3 (structural) — the carve-out is bounded

`skills/skill-creator/SKILL.md` states the bound in R-8: the carve-out's
evidence-hunt exemption applies to every developer-directed deck edit, the
carve-out's no-halt clause does not reach a directed edit whose content
leaves a material open choice, that question is the deck-governance card's
stage output rather than a step toward the full path, and neither clause
reaches a request that names a stage.

- **Verify:** read the card; all four clauses present.

### SC-4 (structural) — one definition, and every record reference resolves

"Short path" is defined in exactly one place, `skills/work/SKILL.md`. The two
cards that route on the term — `skills/plan/SKILL.md` and
`skills/implement/SKILL.md` — point at that definition. The two cards that
consume it — `skills/verify/SKILL.md` and `skills/git-workflow-pr/SKILL.md` —
name the short path's artifact, as R-12 requires. Every "work record" and
"work state" reference in `skills/work/SKILL.md`,
`skills/git-workflow-branch/SKILL.md`, `skills/implement/SKILL.md`,
`skills/git-workflow-cleanup/SKILL.md`, `skills/verify/SKILL.md`, and
`skills/git-workflow-pr/SKILL.md` — in each card's body and in its
frontmatter description — names the work record, and the part of the work
record it names covers what that reference asks it to hold.
`skills/git-workflow-branch/SKILL.md` states that the provenance is written
to the work record at its trunk-freshness step, and
`skills/git-workflow-cleanup/SKILL.md` states that the work-state artifacts
are the scratch files the agent created, the work record among them.

- **Verify:** read the seven cards the criterion names; each "work record" and
  "work state" reference, in each card's body and frontmatter description,
  names the work record, the part it names covers the reference's
  requirement, the work card — the card that owns the record's convention —
  states where the record lives and that its path is inside the repository's
  own git directory and therefore not a working-tree path, the branch card
  states where and when it writes the record's provenance part, the two
  routing cards point at the work card's definition, and the two consuming
  cards name the short path's artifact.

### SC-5 (structural) — the verification and PR-readiness gates read the scope statement

`skills/verify/SKILL.md` rule 1 reads the scope statement as the short path's
primary artifact, and its dispatch names the work record's path; rule 3's
verdict unit on the short path is the scope statement's check; and rule 9's
owning card for the scope statement is the work card, which declares that
check as the scope statement's criteria reference. In
`skills/git-workflow-pr/SKILL.md`, rule 1's assigned scope and its SCs are the
scope statement's scope and its check, rule 2(a) takes the scope statement as
the assignment, rule 2(c) takes the scope statement as the verification
target, and rule 4's Provenance section carries the scope statement's content
as the spec it already requires.

- **Verify:** read both cards; each clause present.

### SC-6 (behavioral) — a stated stage request produces that stage and no implementation

An agent given a developer request that names a stage produces that stage's
work and does not implement the change. The scenario's request names a spec,
asks for the developer's approval of the spec before any code, and asks for
the spec to be written to a file, so the stage's artifact is a file the
harness can find.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run;
  clean-room evaluation of `session.yaml` confirms that the run wrote the
  requested spec file with the spec's content, and that the run contains no
  edit to an implementation file.

### SC-7 (behavioral) — a complicated change does not ride the short path

An agent given the one-line request "Add caching to the search endpoint" does
not modify an implementation file before the full path's spec stage has
produced its artifact. The scenario's setup fixture creates the endpoint file
the request names, so the run has an implementation file to edit and needs no
environment discovery. Two of R-3's criteria fail for that request: it leaves
a material choice open about what to build — the cache key, the expiry, and
the invalidation policy are the agent's to decide — and its completion is not
decidable from the request's own statement, because "cached" is not a state
the file can be read to confirm. The scope statement is not that artifact:
R-11 makes it a stage artifact only for a one-file change whose completion
the request has decided, and this request is neither. R-3's precedence
governs: this request takes the full path, and the work card's halt rule does
not reach it, because the request says what to build.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the run's first edit to an implementation file
  comes after a full-path spec artifact appears in the run — a spec carrying
  success criteria, not the work record's scope statement — and that the run
  does not halt in place of that artifact.

### SC-8 (behavioral) — the short path is taken in collapsed form, without ceremony

The short path's artifacts are the only artifacts, and the work is not
decorated with work the request has already settled. An agent given the
developer-specified, single-file request "Add a `## Support` heading to the
top of SUPPORT.md pointing at the issue tracker" states the path and the
scope, as R-4 specifies them, before editing, then edits the file. The
scenario's setup fixture creates `SUPPORT.md`, so the run has a file to edit
and needs no environment discovery. The run contains no spec document, no
plan document, no spec-validation or plan-validation dispatch, and no halt for
direction. The run contains no evidence hunt, no archaeology — no unrelated
issue, store, or remote read — and no card load that the request has already
satisfied. The verify card's fresh-context check is not among the absent
artifacts: the short route requires it.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the scope statement precedes the edit, that it
  carries R-4's contents, that the run contains no spec document, no plan
  document, no spec-validation or plan-validation dispatch, no halt for
  direction, no evidence hunt, no archaeology, and no card load the request
  had already satisfied, and that the run contains the verify card's
  fresh-context dispatch.

### SC-9 (behavioral) — the short path ends when the work outgrows it

An agent whose short-path change acquires a second file states the expanded
scope, and produces the full path's earliest missing stage's artifact, before
it edits that second file.

The scenario induces the acquisition rather than assuming it. The request
names one file — the feature script — and the fixture makes that file
delegate its argument parsing to a sibling module, so a flag added to the
script cannot be completed in the script alone: the parser that must accept
the flag lives in the other file, and the run has to reach that file to
implement the request. Both files are pre-supplied, so the second file's
presence is never an environment discovery. The criterion is void if the run
never acquires a second file, so the evaluation checks that it did.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the run reached the second file, that the
  expanded scope statement precedes the second file's edit, and that a
  full-path spec artifact appears between that statement and the run's next
  implementation edit — a spec carrying success criteria, not the work
  record's scope statement.

### SC-10 (behavioral) — a directed deck edit with an open choice gets one question

An agent given a developer-directed deck edit whose content leaves a material
open choice asks one open-ended question about that choice instead of choosing
it. The run contains no admission-gate evidence hunt.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the run contains an open-ended question about
  the open choice, that the run made no choice of its own on it, that the run
  contains no evidence hunt for the edit's admission, and that the run
  contains no issue filing, no spec document, no plan document, and no
  validation dispatch.

### SC-11 (structural) — the scenario set is aligned

`2584-sc5-short-path-single-file.sh` is absent from `tests-v2/behaviors/`.
`2584-sc4-directed-card-edit-no-archaeology.sh` states the anti-archaeology
criterion and the no-full-path-machinery criterion. Five new scenarios exist,
one for each of SC-6 through SC-10, and each carries the setup fixture that
pre-supplies the repository state its task needs: the fixture leaves the seed
content present without leaving the test project's `main` ahead of its remote
tip, so the branch card's rebase rule does not fire on a divergence the
fixture itself created. Each scenario the change touches — the five new ones
and the extended `2584-sc4` — declares a goal condition, so the monitor's
classifier judges the run against an anchor and a run that hits the per-turn
cap can resume: the goal artifact and the content pattern that completes it,
where the criterion turns on an artifact, and the goal actions every
scenario declares. SC-10's criterion turns on a question in the
transcript rather than on a file, so its scenario declares goal actions alone
and names no artifact — naming one would declare as the goal the very edit
the criterion forbids.

- **Verify:** read `tests-v2/behaviors/`; each named file is present or absent
  as stated, each new scenario's header states its criterion, each new
  scenario has its fixture under `tests-v2/behaviors/fixtures/setup/`, each
  fixture leaves the test project's `main` equal to its remote tip, and each
  scenario the change touches — the five new ones and `2584-sc4` — declares
  `BEHAVIOR_GOAL_ACTIONS` plus, where its criterion turns on an artifact,
  `BEHAVIOR_EXPECTED_ARTIFACT` and `BEHAVIOR_EXPECTED_ARTIFACT_GREP`.

### SC-12 (structural) — the cap-hit resume is anchored on the recorded tail

The harness's cap-hit resume composes its resume message from the run's own
session database: the agent's last recorded reasoning, and the recorded
in-flight tool call when there is one. The message is not the anchorless
"Continue the task from where you left off." The per-turn output cap's
default is unchanged at 4,000 on every surface that sets it, and the
deliberate probe override in `2646-sc-cap-resume-probe.sh` — which lowers the
cap so the probe hits it deterministically — is untouched.

- **Verify:** read `tests-v2/behaviors/helpers.sh`,
  `tests-v2/docker/docker-harness.sh`, `tests-v2/with-test-home`,
  `tests-v2/AGENTS.md` §10.7 and §14, and `skills/behavioral-testing/SKILL.md`
  rule 9; the cap-hit resume path calls the tail-message composer and passes
  its message to both the Docker and the host resume path, and the Docker
  resume launcher's own default is tail-derived rather than anchorless, so a
  caller that passes no message does not reintroduce the anchorless form; the
  anchorless message appears in executable code in neither file; the
  determination gate's scan roots include the run's artifact directory, where
  the harness writes the record, and the launcher names that directory; the
  three documentation surfaces state the gate's scan coverage and the decision
  the gate accepts; every surface that sets
  `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` with the default still carries the
  4,000 literal, and `2646-sc-cap-resume-probe.sh` still carries its own
  deliberate override.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Floor carries the stage invariant and the stage-request rule | structural | read `floor.md` |
| SC-2 | Work card carries R-1..R-7, R-10, and R-11; the criteria are stated once in rule 1's body and the card's three forms refer to them; both uncertainty rules qualified; removed phrases absent deck-wide | structural | read the card; deck-wide search |
| SC-3 | `skill-creator` carve-out bounded: the evidence-hunt exemption reaches every directed edit, the no-halt clause stops at a material open choice, neither reaches a stage request | structural | read the card |
| SC-4 | One "short path" definition; the two routing cards point at it and the two consuming cards name its artifact; every record reference names the work record; each card that owns the record states where and when it is written | structural | read the seven cards |
| SC-5 | The verify and PR-readiness gates read the scope statement | structural | read both cards |
| SC-6 | A stated stage request produces the stage, no implementation | behavioral | run → clean-room read of `session.yaml` |
| SC-7 | A complicated change does not ride the short path | behavioral | run → clean-room read of `session.yaml` |
| SC-8 | The short path is taken in collapsed form, without ceremony, and the verify dispatch is present | behavioral | run → clean-room read of `session.yaml` |
| SC-9 | The short path ends when the work outgrows it | behavioral | run → clean-room read of `session.yaml` |
| SC-10 | A directed deck edit with an open choice gets one question | behavioral | run → clean-room read of `session.yaml` |
| SC-11 | Scenario set aligned | structural | read `tests-v2/behaviors/` |
| SC-12 | The cap-hit resume is anchored on the recorded tail; the determination gate scans the artifact directory where the record is written; the per-turn cap's default is unchanged and the probe's deliberate override is untouched | structural | read `tests-v2/behaviors/helpers.sh`, `tests-v2/docker/docker-harness.sh`, `tests-v2/with-test-home`, `tests-v2/AGENTS.md` §10.7 and §14, and `skills/behavioral-testing/SKILL.md` rule 9 |

## Out of scope

- The `skill-creator` admission gate's content standards — frontmatter,
  predicate classification, root-agnostic discipline. R-8 changes only what
  the carve-out reaches, not what the gate requires of written content.
- The developer's authority to direct a stage and to carry approvals forward.
  A terminal-stage approval from the vocabulary in `floor.md` still carries an
  item through every phase it names, and the developer may still direct any
  stage. The developer's own approvals and directions are unaffected; what
  this spec removes is the agent-side mechanism by which the short-path
  default dropped a stage on the developer's own request.
- The `implement` card's dispatch-cost default from `.opencode#2645` — the
  default that short-path work runs inline rather than in a sub-agent. That
  default is unchanged in substance. Two things on that card change: the term
  "short path" re-resolves under R-10, and the rule's "recorded in the work
  state" names the record R-10 defines.
- Mechanized ceremony detection, token budgets, and scripted path selection.
  Path selection is intent-decidable; judgment decides, mechanisms verify
  facts only.
- The retired `attic/` deck; the `tests-v2` harness's isolation contract, its
  default model, its change-control rules, and its per-turn output cap;
  `guidelines/`, `agents/`, `prompts/`, and `opencode.jsonc`. R-13 reaches
  three harness behaviours — the message the cap-hit resume sends, in the
  helpers' resume path and in the Docker resume launcher's default, and the
  determination gate's scan roots — and the three surfaces that state the
  gate's behaviour, and nothing else in the harness.

## Approach

Separate the two things `.opencode#2584` fused. The anti-ceremony property it
established is real and stays: the agent performs no evidence hunt,
archaeology, or card load that the developer's instruction already satisfied,
and the agent does not re-ask for what the instruction carries. What the
change removes is the stage waiver that rode along with it — the card's
pricing of stage-seeking against the developer's request, and its resolution
of "a developer's direct request" to "the spec".

Path selection then takes two inputs. The developer's stated stage request is
the first, and it wins outright: that request is a fact about the request
rather than a judgment call, and it is checkable. The agent's characterization
of the change is the second, and the agent consults it only when the request
names no stage. The short path's predicate becomes a fixed criterion set
(R-3), stated once and in one form, and built so that the criterion which
matters is whether the change's completion is decidable from the request's own
statement — that is what separates a one-line wording change from work that
carries acceptance criteria or needs a product decision. A change to the
agent deck keeps its own gate, the deck-governance card's admission gate,
bounded by R-8, so the work card's path selection does not turn a directed
card edit into the full path's filed-issue-and-dispatches machinery. The
characterization is recorded (R-4) so that it is falsifiable at review rather
than self-certified, and when the work outgrows it the short path ends (R-5).

The scope statement is what makes the short path a path the deck's own rules
allow. It is written into the work record — one file, with a named path and a
stated write time for each part — so the fresh-context reviewer reaches it by
path (R-12); it carries the scope, the check, and the order, so it discharges
the spec stage and the plan stage together (R-11); and the PR body's
Provenance section carries the scope statement's content, the one section the
PR body already reserves for a spec. The work card's boundary rule stops
routing short-path changes into the full pipeline for want of a spec artifact,
and the verify card and the three PR-readiness gates read the scope statement
where they previously read a spec that the short path never produced.

The implement card holds the second, looser definition of "short path" —
"developer-specified small changes with no success-criteria machinery" — and
that definition is what `.opencode#2645` carried in without re-examining it.
The plan card holds no definition at all: one of its two uses of the term
points at `work`, the other names the term without resolving it, and both are
re-pointed at the one definition along with the implement card's. The records
the deck names but never defines are given one surface (R-10) — the work
record — so the branch card's provenance, the implement card's recorded
dispatch reason, and the scope statement stop competing for one undefined
name, and the cleanup card's scratch files acquire a named set.

The scenarios move with the rules. The scenario that asserts the escape's
behavior is retired; the one that asserts the carve-out's anti-archaeology
property is extended so that it also fails on the regression R-3 could
otherwise cause — a directed card edit that took the full path — and five new
scenarios replace what the retired one covered, one per behavioral criterion.
SC-8 holds the anti-ceremony win in place so that a later agent cannot "fix"
the escape by removing the short path altogether. Retiring
`2584-sc5-short-path-single-file.sh` deletes a tracked file from the deck; the
file's content and its removal both remain in the deck's git history, and the
scenario's criterion is preserved in SC-8 rather than discarded with it.

The behavioural evidence pipeline carries one repair of its own. The harness's
cap-hit resume sent the anchorless "Continue the task from where you left
off.", so a run that hit the per-turn output cap re-derived its own history on
every resume, spent the budget re-deriving, and issued no tool call — the
resume made no progress and the run died at the cap-resume ceiling with no
artifact. That is the failure the cap-resume step was written to prevent, and
the run-level fix `.opencode#2639` applied to its own scenario's bespoke
recovery path generalizes here: the resume message states the agent's recorded
last thinking and names the recorded next action, composed from the run's own
session database. R-13 carries it and SC-12 holds it. The Docker resume
launcher's own default is tail-derived for the same reason: a caller that
passes no message — as the `#2639` direct-resume path does when it sets no
directive — would otherwise reintroduce the anchorless form. Two further
repairs sit at the scenario layer: the fixture's seed state no longer leaves
`main` ahead of the remote tip, and each scenario declares the goal condition
the monitor's classifier judges the run against — without one, the classifier
returns "undetermined", the determination gate blocks the resume path, and a
capped run cannot recover. The per-turn cap's default is unchanged, and the
probe scenario that lowers the cap deliberately is untouched: the
observed degenerate-turn band is where these turns sit, so raising the cap
would re-open the failure the cap prevents.

**Alternatives considered.** *Delete the short path entirely* and send every
change through spec, plan, implement, and PR: rejected, because it makes the
ceremony complaint in `.opencode#2584` worse, and it removes the cheap path
that SC-8 depends on. *Keep the short path as written and bound it with a
recorded classification alone*: rejected, because the classification would
still be the agent's own characterization of the change, which is the failure
the developer reported. *Route a stage-naming request to the stage card
without touching the short path's text*: rejected as insufficient, because the
work card's "a developer's direct request is the spec" and "excess ceremony"
wording would survive to misread the next request. *Restore the short path as
a stage-free path and leave the verify, PR-readiness, and boundary rules as
they are*: rejected, because a short-path change could then not reach a PR at
all — the three gates in `git-workflow-pr` require a scope, an assignment, and
a verification target that the short path does not produce. *Keep the scope
statement in the session and the PR body only, with no file:* rejected,
because the fresh-context reviewer reads primary artifacts directly and needs
a path to read, and because the PR body's fixed section list gives the scope
statement's content no home without the Provenance widening the chosen
approach supplies. *Keep the work record as a transient file and cite its
path in the PR body's Provenance section:* rejected, because the cleanup card
deletes the file at merge and the record is uncommitted, so the merged PR's
provenance would name a path that resolves to nothing. The chosen approach
rewrites the routing text, adds the criterion set and the record, and states
which artifact discharges which stage, so that each of the five defects has
its own remedy.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
