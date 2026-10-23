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
without re-examining what the term had come to mean.

## Problem

Two failure modes share one text in the deck's change router, a third leaves
the escape unrecorded and under test, and a fourth means the deck has no
coherent short path to restore.

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

The work card states the short path's predicate twice, and neither form
supplies the criterion that matters. Its bullet form is "*Short path*:
single-file fix, typo, config tweak — the developer's request itself is the
spec; it is verified at PR review"; its paragraph form generalizes it to
"single-file, developer-specified changes". The single-file bound is
checkable, and this spec keeps it. What neither form supplies is a criterion
that separates single-file work the request has decided from single-file work
it has not: a change that carries acceptance criteria, needs a product
decision the developer did not state, or leaves a material choice open is
still one file, and "developer-specified" is satisfied by the developer having
mentioned the change. An agent that characterizes such a change as simple
skips the spec requirement the developer holds, and the deck's own text
supplies the rationale for the skip.

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

## Root causes

- **RC-1** — Path selection takes one input: the agent's characterization of
  the change's size. A developer's stated stage request is not an input, and
  the card's wording makes the request read as evidence against the full path.
- **RC-2** — The short path's predicate bounds the file count but supplies no
  criterion separating work the request has decided from work it has not, and
  its paragraph form states the predicate in terms of the developer's having
  mentioned the change, so it is self-certifying.
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
  pipeline; it does not satisfy the spec stage and it never authorizes
  implementation. A request that names no stage, and that names what to
  build, may serve as the short path's scope — subject to R-3.
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
  clarification request" — are read as applying to ambiguity in the request
  about what to build, not to the classification itself.
- **R-4** — Every change records its path and its scope before implementation
  begins. A full-path change's spec artifact carries the scope. A short-path
  change carries it in a scope statement, which the agent writes into the work
  record (R-10) before it edits anything. The scope statement carries: the
  path taken, the R-3 criteria that selected it, what changes, what "done" is
  checked against, what is out of scope, the order of the work, and any
  reason a card requires recorded for a departure from a default. The
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
  that choice rather than choosing it. Neither clause reaches a request that
  names a stage.
- **R-9** — The behavioral scenarios are brought in line with the rules:
  `2584-sc5-short-path-single-file` is retired; and
  `2584-sc4-directed-card-edit-no-archaeology` keeps its anti-archaeology
  criterion — a fully specified directed edit completes without admission
  archaeology and without halting for direction — and gains one beside it:
  the edit completes without the full path's machinery, with no issue filed,
  no spec document, and no validation dispatch. Scenarios are added covering
  R-1, R-3, R-4, R-5, R-6, and R-8.
- **R-10** — "Short path" resolves to exactly one definition, in
  `skills/work/SKILL.md`; the cards that use the term point to that
  definition. The deck's records are named, and each card's reference names
  the record it means. There is one record: the **work record**, a single file
  in the working tree, at a path the work card's convention names. It carries
  two things. The **provenance** the branch card records — the verified
  trunk tip, the branch, the base tip, and the issue where one exists — which
  the branch card writes at its trunk-freshness step, before any modification
  and before the branch exists, and extends at its provenance step. The
  **scope statement** R-4 describes, which the work card writes before the
  first edit. The work record is a work-state artifact, which the cleanup
  card removes; it is not part of the branch's commits, because the commit
  card stages named files only. Every "work record" and "work state" reference
  in `skills/work/SKILL.md`, `skills/git-workflow-branch/SKILL.md`,
  `skills/implement/SKILL.md`, and `skills/git-workflow-cleanup/SKILL.md`
  names the work record, and the work record's two parts cover what each
  reference asks it to hold.
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
  artifact. `skills/verify/SKILL.md` rule 1 reads the scope statement as the
  short path's primary artifact alongside the diff and the executed test
  output, and the verify dispatch names the work record's path so the
  fresh-context reviewer reaches it. In `skills/git-workflow-pr/SKILL.md`,
  rule 1's assigned scope and its SCs are the scope statement's scope and
  its check, rule 2(a) takes the scope statement as the assignment, rule
  2(c) takes the scope statement as the verification target, and rule 4's
  Provenance section takes the work record's path as the spec path it
  already requires. Where a short-path change carries an issue, that issue is
  the tracker record; the spec artifact remains the scope statement.

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
path, which is the shape `.opencode#2584` and the retained `2584-sc4` address.
The change is a cost this spec accepts: the deck's own history of
ungoverned edits is why the deck-governance card exists, and an agent
proposing a rule the developer did not ask for is work the developer holds
the right to see a spec of.

**Risk — the criteria are intent-decidable.** R-3's criteria are judgment
calls, so an agent can still mischaracterize a complicated change. R-4's
recorded scope makes the characterization falsifiable at review rather than
self-certified, and R-5 re-examines it when the work outgrows it.

**Blast radius.** `floor.md`; the `work`, `plan`, `implement`,
`skill-creator`, `verify`, `git-workflow-pr`, `git-workflow-branch`, and
`git-workflow-cleanup` cards; `tests-v2/behaviors/`. The amendments to
`verify`, `git-workflow-pr`, `git-workflow-branch`, and `git-workflow-cleanup`
are clause-level clarifications that name the artifact the card already
requires. No change reaches `guidelines/`, `agents/`, `prompts/`,
`opencode.jsonc`, the `tests-v2` harness, or the retired `attic/` deck.

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
a stage-naming request to the card. Its two statements of the short path's
predicate — the bullet list and the paragraph — state R-3's criteria and
agree with each other. Its two uncertainty rules — the frontmatter's and the
closing line's — are qualified per R-3. The phrases "a developer's direct
request is the spec" and "Excess ceremony on a direct order is a defect
signal" appear nowhere in the deck.

- **Verify:** read the card; each element present. A deck-wide search of
  `skills/`, `guidelines/`, and `floor.md` returns no occurrence of either
  phrase.

### SC-3 (structural) — the carve-out is bounded

`skills/skill-creator/SKILL.md` states the bound in R-8: the carve-out's
evidence-hunt exemption applies to every developer-directed deck edit, the
carve-out's no-halt clause does not reach a directed edit whose content
leaves a material open choice, and neither clause reaches a request that
names a stage.

- **Verify:** read the card; all three clauses present.

### SC-4 (structural) — one definition, and every record reference resolves

"Short path" is defined in exactly one place, `skills/work/SKILL.md`, and the
cards that use the term — `skills/work/SKILL.md`, `skills/plan/SKILL.md`, and
`skills/implement/SKILL.md` — point to it. Every "work record" and "work
state" reference in `skills/work/SKILL.md`,
`skills/git-workflow-branch/SKILL.md`, `skills/implement/SKILL.md`, and
`skills/git-workflow-cleanup/SKILL.md` names the work record, and the part of
the work record it names covers what that reference asks it to hold.
`skills/git-workflow-branch/SKILL.md` states that the provenance is written
to the work record at its trunk-freshness step, and
`skills/git-workflow-cleanup/SKILL.md` states that the work-state artifacts
are the working-tree scratch files the agent created, the work record among
them.

- **Verify:** read the five cards; each reference names the work record, the
  part it names covers the reference's requirement, and each card that owns
  the record states where and when the agent writes it.

### SC-5 (structural) — the verification and PR-readiness gates read the scope statement

`skills/verify/SKILL.md` rule 1 reads the scope statement as the short path's
primary artifact, and its dispatch names the work record's path. In
`skills/git-workflow-pr/SKILL.md`, rule 1's assigned scope and its SCs are the
scope statement's scope and its check, rule 2(a) takes the scope statement as
the assignment, rule 2(c) takes the scope statement as the verification
target, and rule 4's Provenance section takes the work record's path as the
spec path.

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

An agent given a one-line request that changes behavior, reads an environment
variable, and touches a safety surface does not modify an implementation file
before the full path's spec stage has produced its artifact. The scope
statement is not that artifact: R-11 makes it a stage artifact only for a
one-file change whose completion the request has decided, and this request is
neither.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the run's first edit to an implementation file
  comes after a full-path spec artifact appears in the run — a spec carrying
  success criteria, not the work record's scope statement.

### SC-8 (behavioral) — the short path is taken in collapsed form, without ceremony

The short path's artifacts are the only artifacts, and the work is not
decorated with work the request has already settled. An agent given a
developer-specified, single-file wording change states the path and the scope,
as R-4 specifies them, before editing, then edits the file. The run contains
no spec document, no plan document, no spec-validation or plan-validation
dispatch, and no halt for direction. The run contains no evidence hunt, no
archaeology — no unrelated issue, store, or remote read — and no card load
that the request has already satisfied. The verify card's fresh-context check
is not among the absent artifacts: the short route requires it.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the scope statement precedes the edit, that it
  carries R-4's contents, and that the run contains no spec document, no plan
  document, no spec-validation or plan-validation dispatch, no halt for
  direction, no evidence hunt, no archaeology, and no card load the request
  had already satisfied.

### SC-9 (behavioral) — the short path ends when the work outgrows it

An agent whose short-path change acquires a second file states the expanded
scope before it edits that second file, and produces the full path's earliest
missing stage's artifact before it makes any further implementation edit.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the expanded scope statement precedes the
  second file's edit, and that a full-path stage artifact appears between
  that statement and the run's next implementation edit.

### SC-10 (behavioral) — a directed deck edit with an open choice gets one question

An agent given a developer-directed deck edit whose content leaves a material
open choice asks one open-ended question about that choice instead of choosing
it. The run contains no admission-gate evidence hunt.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the run contains an open-ended question about
  the open choice, that the run made no choice of its own on it, and that the
  run contains no evidence hunt for the edit's admission.

### SC-11 (structural) — the scenario set is aligned

`2584-sc5-short-path-single-file.sh` is absent from `tests-v2/behaviors/`.
`2584-sc4-directed-card-edit-no-archaeology.sh` states the anti-archaeology
criterion and the no-full-path-machinery criterion. Five new scenarios exist,
one for each of SC-6 through SC-10.

- **Verify:** read `tests-v2/behaviors/`; each named file is present or absent
  as stated, and each new scenario's header states its criterion.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Floor carries the stage invariant and the stage-request rule | structural | read `floor.md` |
| SC-2 | Work card carries R-1..R-7 and R-11; both predicate forms state the criteria; both uncertainty rules qualified; removed phrases absent deck-wide | structural | read the card; deck-wide search |
| SC-3 | `skill-creator` carve-out bounded | structural | read the card |
| SC-4 | One "short path" definition; record references resolve to a record that can hold them | structural | read the five cards |
| SC-5 | The verify and PR-readiness gates read the scope statement | structural | read both cards |
| SC-6 | A stated stage request produces the stage, no implementation | behavioral | run → clean-room read of `session.yaml` |
| SC-7 | A complicated change does not ride the short path | behavioral | run → clean-room read of `session.yaml` |
| SC-8 | The short path is taken in collapsed form | behavioral | run → clean-room read of `session.yaml` |
| SC-9 | The short path ends when the work outgrows it | behavioral | run → clean-room read of `session.yaml` |
| SC-10 | A directed deck edit with an open choice gets one question | behavioral | run → clean-room read of `session.yaml` |
| SC-11 | Scenario set aligned | structural | read `tests-v2/behaviors/` |

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
- The retired `attic/` deck; the `tests-v2` harness, its isolation contract,
  its default model, and its change-control rules; `guidelines/`, `agents/`,
  `prompts/`, and `opencode.jsonc`.

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
the spec stage and the plan stage together (R-11); and the work record's path
is named in the PR body's Provenance section, the one section the PR body
already reserves for a spec path. The work card's boundary rule stops routing
short-path changes into the full pipeline for want of a spec artifact, and the
verify card and the three PR-readiness gates read the scope statement where
they previously read a spec that the short path never produced.

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
a path to read, and because the PR body's fixed contract has no section for
the scope statement's content. The chosen approach rewrites the routing text,
adds the criterion set and the record, and states which artifact discharges
which stage, so that each of the four defects has its own remedy.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
