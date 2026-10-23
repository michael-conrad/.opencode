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

The short path's predicate is "single-file, developer-specified". Both terms
are satisfied by the fact that the developer mentioned the work. No criterion
separates a one-line wording change from a change that alters behavior, carries
success criteria, touches a governance surface, or requires a product decision
the developer did not state. An agent that characterizes a complicated change as
simple skips the spec requirement the developer holds, and the deck's own text
supplies the rationale for the skip.

### Problem 3 — the escape is unrecorded, and the deck's own tests enforce it

Four cards reference a "work record" or "work state" — `skills/work/SKILL.md`
rule 1, `skills/git-workflow-branch/SKILL.md` rules 2 and 5,
`skills/implement/SKILL.md` rule 9, and `skills/git-workflow-cleanup/SKILL.md`
rule 5 — and the only gloss the deck offers is git-workflow-cleanup's
parenthetical "work files, scratch state". No card names a surface the agent
can write to, so the condition the short path attaches to its escape is
unverifiable and a short-path classification leaves no trace. Two behavioral
scenarios assert the short path's behavior as correct:
`tests-v2/behaviors/2584-sc5-short-path-single-file.sh` asserts that a
developer-specified change takes the short path with "no full-pipeline
machinery beyond it", and `2584-sc4-directed-card-edit-no-archaeology.sh`
asserts that a directed edit completes with no halt for direction. Under
`tests-v2/AGENTS.md` §6b (CM-1), a test survives only if a real defect would
escape without it; these two exist to penalize the pipeline's presence. A fix
that changes the card text and leaves them in place leaves the deck testing
for the escape.

### Problem 4 — the short path has no artifact, so the deck's own rules contradict it

The work card's short route runs `git-workflow-branch` → `implement` →
`verify` → `git-workflow-pr`, and `skills/verify/SKILL.md` rule 1 dispatches a
fresh-context reviewer that "reads the primary artifacts directly — spec/SCs,
the diff, the executed test output". `skills/git-workflow-pr/SKILL.md` rule
2(c) blocks PR creation until a "fresh-context `verify` PASS recorded against
the issue's spec" exists, and rule 2(a) requires "every item assigned to this
PR by the spec" to have an implementation commit. A short-path change has no
spec and no issue, so the PR-readiness gate cannot be satisfied as written.
`skills/work/SKILL.md` rule 4 compounds it: "Missing upstream *artifacts* (no
spec, plan, or branch yet) trigger the pipeline itself: run it from the
earliest missing stage under the granted authorization" — a short-path change
never has a spec artifact, so rule 4 routes it into the full pipeline from the
spec stage. The short path as the deck states it is therefore not a path the
deck's own rules let an agent walk. The deck never says which artifact stands
in for the spec and the plan on the short path, and the agent fills that gap
by whichever reading favours it — which is how a request for a spec came to be
read as a request that already had one.

## Root causes

- **RC-1** — Path selection takes one input: the agent's characterization of
  the change's size. A developer's stated stage request is not an input, and
  the card's wording makes the request read as evidence against the full path.
- **RC-2** — The short path's predicate is a two-word characterization with no
  criteria behind it, so it is self-certifying.
- **RC-3** — "Excess ceremony" names no observable criterion, and it is aimed
  at stages rather than effort, so it operates as an unappealable veto over
  the pipeline and hands the agent a rationale for skipping a requested stage.
- **RC-4** — The escape's condition names a record that no card names as a
  surface the agent can write to, so the classification is unverifiable and
  leaves no trace.
- **RC-5** — Two behavioral scenarios assert the escape's behavior, so the
  escape carries test protection.
- **RC-6** — No card says which artifact the short path produces, so the
  work card's route, its boundary rule, the verify card's reviewer, and the
  PR-readiness gate each read the short path differently, and the agent
  resolves the disagreement in its own favor.

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
  the change alters no behavior, dependency, configuration, credential, or
  security surface; the request leaves no material choice open about what to
  build, and the agent supplies no product decision the developer did not
  state; the change carries no success criteria beyond the request's own
  statement; the change touches no floor, guideline, skill card, or other
  governance surface. A criterion that fails sends the change to the full
  path. Uncertainty about whether a criterion holds also sends the change to
  the full path; the agent raises one open-ended question only when the
  request is ambiguous about what to build.
- **R-4** — Every change records its path and its scope before implementation
  begins. A full-path change's spec artifact carries the scope. A short-path
  change carries it in a scope statement: the agent states, in the working
  session before editing a file, the path taken, the R-3 criteria that
  selected it, and the scope — what changes, what "done" is checked against,
  and what is out of scope. The developer's work order is the authorization
  for the implementation that scope describes: `floor.md`'s authorization
  vocabulary sends an utterance it does not list to default agent judgment,
  and the work card's boundary rule halts for authorization only on genuine
  ambiguity. The agent therefore records the scope and does not ask the
  developer to approve it again. A developer who wants to approve the scope
  before implementation asks for that stage, and R-1 routes the request to the
  full path. The path and the scope appear in the PR body.
- **R-5** — The short path ends when the work outgrows it. If, after the
  short path is taken, the work acquires a second file, a second concern, a
  derived success criterion, or a product decision the developer did not
  state, the agent states the expanded scope, re-applies R-3's criteria, and
  takes the full path from the earliest missing stage — producing that
  stage's artifact — before it makes any further implementation edit. The
  agent never completes a change as a short path when the change no longer
  satisfies R-3.
- **R-6** — The anti-ceremony rule `.opencode#2584` established stays and
  binds effort only: the agent performs no evidence hunt, archaeology, or card
  load that the developer's instruction already satisfied, and the agent does
  not re-ask for what the instruction carries. No stage is waived, and the
  artifact a stage produces may take a collapsed form; a missing artifact is
  produced, cheaply, never waived. The text that prices stage-seeking against
  the developer's request is removed from the deck.
- **R-7** — A developer's directive satisfies a stage's content; it never
  suppresses a stage. No directive, however emphatic and however small the
  change, removes a stage from the pipeline. A directive that names a stage
  runs that stage; a directive that names a scope supplies the scope for the
  stage that scope belongs to.
- **R-8** — The `skill-creator` developer-instruction carve-out is bounded,
  not removed. A developer-directed deck edit carries its own authorization and
  the admission gate's proposal-time evidence hunt does not re-run for it. The
  carve-out does not reach a directed edit whose content leaves a material
  open choice — the agent asks one open-ended question about that choice — and
  it does not reach a request that names a stage.
- **R-9** — The behavioral scenarios are brought in line with the rules:
  `2584-sc5-short-path-single-file` is retired, and
  `2584-sc4-directed-card-edit-no-archaeology` states the anti-archaeology
  property it was written for with the stage-skipping framing removed.
  Scenarios are added covering R-1, R-3, R-4, R-5, and R-6.
- **R-10** — "Short path" resolves to exactly one definition, in
  `skills/work/SKILL.md`; the cards that use the term point to that
  definition. The deck's records are named, and each card's reference names
  the record it means. Three surfaces are distinct: the **scope statement** —
  the path, the R-3 criteria, and the scope — which lives in the working
  session and in the PR body; the **work state** — branch, base tip, and issue
  — which lives in the branch's commit metadata so PR preparation can verify
  the chain; and **work-state artifacts** — working-tree scratch files the
  agent created — which the cleanup card removes. The scope statement is not
  a work-state artifact.
- **R-11** — The scope statement is the short path's spec artifact. It
  discharges the spec stage's function (what changes, how "done" is checked
  against) and, for a one-file change, the plan stage's function (the
  ordering and the verification instrument). `skills/work/SKILL.md` states
  this, and its boundary rule is qualified accordingly: the clause that
  missing upstream artifacts trigger the pipeline applies to a change on the
  full path, and a short-path change is one whose scope statement stands in
  for the spec and plan artifacts. The short route remains
  `git-workflow-branch` → `implement` → `verify` → `git-workflow-pr`.
- **R-12** — The verification and PR-readiness gates read the short path's
  artifact. `skills/verify/SKILL.md` rule 1 reads the scope statement as the
  short path's primary artifact alongside the diff and the executed test
  output, and `skills/git-workflow-pr/SKILL.md` rule 2(a) and 2(c) take the
  scope statement as the assignment and as the verification target, so a
  short-path change can reach a PR.

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
document would otherwise sit. SC-7 holds that win in place under test.

**Risk — a two-file change now takes the full path.** R-3 keeps the
single-file bound the work card already carried, so a change that needs a
second file produces a spec document. That is a cost this spec accepts: the
developer reported complicated work riding the short path, and the single-file
bound is the deck's own existing line between the two paths.

**Risk — the criteria are intent-decidable.** R-3's criteria are judgment
calls, so an agent can still mischaracterize a complicated change. R-4's
recorded scope makes the characterization falsifiable at review rather than
self-certified, and R-5 re-examines it when the work outgrows it.

**Blast radius.** `floor.md`; the `work`, `plan`, `implement`,
`skill-creator`, `verify`, `git-workflow-pr`, `git-workflow-branch`, and
`git-workflow-cleanup` cards; `tests-v2/behaviors/`. The amendments to
`verify`, `git-workflow-pr`, `git-workflow-branch`, and `git-workflow-cleanup`
are one-clause clarifications that name the artifact the card already
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

`skills/work/SKILL.md` states R-1 through R-7 and R-11, and its frontmatter
description names the stage-request trigger so the platform routes a
stage-naming request to the card. The phrases "a developer's direct request is
the spec" and "Excess ceremony on a direct order is a defect signal" appear
nowhere in the deck.

- **Verify:** read the card; each element present. A deck-wide search of
  `skills/`, `guidelines/`, and `floor.md` returns no occurrence of either
  phrase.

### SC-3 (structural) — the carve-out is bounded

`skills/skill-creator/SKILL.md` states the bound in R-8: the carve-out does
not reach a directed edit whose content leaves a material open choice, and it
does not reach a request that names a stage.

- **Verify:** read the card; both clauses present.

### SC-4 (structural) — one definition, and every record reference resolves

"Short path" is defined in exactly one place, `skills/work/SKILL.md`, and the
cards that use the term — `skills/work/SKILL.md`, `skills/plan/SKILL.md`, and
`skills/implement/SKILL.md` — point to it. Every "work record" and "work
state" reference in `skills/work/SKILL.md`,
`skills/git-workflow-branch/SKILL.md`, `skills/implement/SKILL.md`, and
`skills/git-workflow-cleanup/SKILL.md` names which of the three records in
R-10 it means.

- **Verify:** read the five cards; each reference resolves.

### SC-5 (behavioral) — a stated stage request produces that stage and no implementation

An agent given a developer request that names a stage produces that stage's
work and does not implement the change. The scenario's request names a spec,
asks for the developer's approval of the spec before any code, and asks for
the spec to be written to a file, so the stage's artifact is a file the
harness can find.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run;
  clean-room evaluation of `session.yaml` confirms that the run wrote the
  requested spec file with the spec's content, and that the run contains no
  edit to an implementation file.

### SC-6 (behavioral) — a complicated change does not ride the short path

An agent given a one-line request that changes behavior, reads an environment
variable, and touches a safety surface does not modify an implementation file
before it has produced a stage artifact or asked one open-ended question.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the run's first edit to an implementation file
  comes after a stage artifact or an open-ended question.

### SC-7 (behavioral) — the short path is taken in collapsed form

The short path's artifacts are the only artifacts. An agent given a
developer-specified, single-file wording change states the path and the scope
before editing, then edits the file. The run contains no spec document, no
plan document, no spec-validation or plan-validation dispatch, and no halt for
direction. The verify card's fresh-context check is not among the absent
artifacts: the short route requires it.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the scope statement precedes the edit, and
  that the run contains no spec document, no plan document, no spec-validation
  or plan-validation dispatch, and no halt for direction.

### SC-8 (behavioral) — the short path ends when the work outgrows it

An agent whose short-path change acquires a second file states the expanded
scope before it edits that second file, and produces the full path's earliest
missing stage's artifact before it makes any further implementation edit.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation of
  `session.yaml` confirms that the expanded scope statement precedes the
  second file's edit, and that a full-path stage artifact appears between
  that statement and the run's next implementation edit.

### SC-9 (structural) — the scenario set is aligned

`2584-sc5-short-path-single-file.sh` is absent from `tests-v2/behaviors/`.
`2584-sc4-directed-card-edit-no-archaeology.sh` states the anti-archaeology
criterion and no longer frames the absence of a stage as correct. Four new
scenarios exist, one for each of SC-5 through SC-8.

- **Verify:** read `tests-v2/behaviors/`; each named file is present or absent
  as stated, and each new scenario's header states its criterion.

### SC-10 (structural) — the verification and PR-readiness gates read the scope statement

`skills/verify/SKILL.md` rule 1 reads the scope statement as the short path's
primary artifact, and `skills/git-workflow-pr/SKILL.md` rules 2(a) and 2(c)
take the scope statement as the assignment and as the verification target.

- **Verify:** read both cards; each clause present.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Floor carries the stage invariant and the stage-request rule | structural | read `floor.md` |
| SC-2 | Work card carries R-1..R-7 and R-11; removed phrases absent deck-wide | structural | read the card; deck-wide search |
| SC-3 | `skill-creator` carve-out bounded | structural | read the card |
| SC-4 | One "short path" definition; record references resolve | structural | read the five cards |
| SC-5 | A stated stage request produces the stage, no implementation | behavioral | run → clean-room read of `session.yaml` |
| SC-6 | A complicated change does not ride the short path | behavioral | run → clean-room read of `session.yaml` |
| SC-7 | The short path is taken in collapsed form | behavioral | run → clean-room read of `session.yaml` |
| SC-8 | The short path ends when the work outgrows it | behavioral | run → clean-room read of `session.yaml` |
| SC-9 | Scenario set aligned | structural | read `tests-v2/behaviors/` |
| SC-10 | The verify and PR-readiness gates read the scope statement | structural | read both cards |

## Out of scope

- The `skill-creator` admission gate's content standards — frontmatter,
  predicate classification, root-agnostic discipline. R-8 changes only what
  the carve-out reaches, not what the gate requires of written content.
- The developer's authority to direct or waive a stage. A terminal-stage
  approval from the vocabulary in `floor.md` still carries an item through
  every phase it names, and the developer may still direct any stage.
- The `implement` card's dispatch-cost default from `.opencode#2645`. That
  default concerns sub-agent dispatch, not pipeline stages; only its use of
  "short path" re-resolves under R-10.
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
(R-3) so that "complicated" cannot be characterized away, and the
characterization is recorded (R-4) so that it is falsifiable at review rather
than self-certified. When the work outgrows the characterization mid-flight,
the short path ends (R-5).

The floor carries the invariant in one place (R-7): a directive satisfies a
stage's content and never suppresses a stage. The work card carries the
mechanism, and its frontmatter description names the stage-request trigger so
the platform's routing surface reflects it. The scope statement becomes the
short path's spec artifact (R-11), which is what makes the short path a path
the deck's own rules allow: the verify card's reviewer reads it as the
primary artifact, the PR-readiness gate takes it as the assignment and the
verification target (R-12), and the work card's boundary rule stops routing
short-path changes into the full pipeline for want of a spec artifact.

The implement card holds the second, looser definition of "short path" —
"developer-specified small changes with no success-criteria machinery" — and
that definition is what `.opencode#2645` carried in without re-examining it.
The plan card holds no definition at all: one of its two uses of the term
points at `work`, the other names the term without resolving it, and both are
re-pointed at the one definition along with the implement card's. The records
the deck names but never defines are given their three surfaces (R-10), so the
branch card's provenance record, the cleanup card's scratch files, and the
scope statement stop competing for one undefined name. The `skill-creator`
carve-out keeps its anti-archaeology half and gains a bound (R-8).

The scenarios move with the rules. The two that assert the escape's behavior
are retired or re-scoped, and four replace them — one per behavioral
criterion, including SC-7, which holds the anti-ceremony win in place so that
a later agent cannot "fix" the escape by removing the short path altogether.
Retiring `2584-sc5-short-path-single-file.sh` deletes a tracked file from the
deck; the file's content and its removal both remain in the deck's git
history, and the scenario's criterion is preserved in SC-7 rather than
discarded with it.

**Alternatives considered.** *Delete the short path entirely* and send every
change through spec, plan, implement, and PR: rejected, because it makes the
ceremony complaint in `.opencode#2584` worse, and it removes the cheap path
that SC-7 depends on. *Keep the short path as written and bound it with a
recorded classification alone*: rejected, because the classification would
still be the agent's own characterization of the change, which is the failure
the developer reported. *Route a stage-naming request to the stage card
without touching the short path's text*: rejected as insufficient, because the
work card's "a developer's direct request is the spec" and "excess ceremony"
wording would survive to misread the next request. *Restore the short path as
a stage-free path and leave the verify, PR-readiness, and boundary rules as
they are*: rejected, because a short-path change could then not reach a PR at
all — the gate at `git-workflow-pr` rule 2(c) requires a verification target
that the short path does not produce. The chosen approach rewrites the
routing text, adds the criterion set and the record, and states which
artifact discharges which stage, so that each of the four defects has its own
remedy.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
