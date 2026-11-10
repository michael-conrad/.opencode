# Plan — build-tooling exclusivity resolves the parent/submodule root (.opencode#2728)

Spec: `.opencode/.issues/2728/spec.md`. All items trace to its SCs; item order
follows the spec's Approach dependency order (floor wording is single-sourced
first; surfaces below cite, not duplicate, it).

## Item 1 — floor.md: root resolution, instruction precedence, no-`--recursive` (SC-1, SC-2, SC-3; R-1, R-2, R-3)

- **Deliverable:** extend the `floor.md` Safety "Build-tooling exclusivity"
  bullet (in place, no new bullet) with three sentences per R-1/R-2/R-3.
- **RED (structural, ephemeral):** read shows the bullet as of the trunk tip
  — "root repo" undefined on the parent/submodule axis, no
  submodule-local-instruction-precedence statement, no `--recursive`
  prohibition (`grep -n "recursive" floor.md` returns no Build-tooling hit).
- **GREEN:** add, framework-general in the bullet: (a) for a change targeting
  a submodule of a parent repository the root is the parent repository and
  build/test/verification run exclusively through that root repo's documented
  wrapper/framework; any submodule's own wrapper/framework/distribution is
  never the sanctioned toolchain regardless of delivery location; (b) a
  submodule's own AGENTS.md build/test guidance is never a build instruction
  the agent follows — the root mandate outranks it; (c) any `--recursive`
  submodule command form (`git submodule --recursive` included,
  clone/update/checkout recursion included) is forbidden at the same class —
  no utterance authorizes it — with pointer-discipline flags left to their
  owning cards; Ainglish referent pattern throughout (topology stated before
  relational nouns, "root"/"parent" qualified in the same sentence).
- **Instrument (tier: smoke):** grep/read of `floor.md` post-edit — the three
  stated facts present, severity class matching the existing
  "no utterance authorizes them" phrasing.

## Item 2 — implementation-workflow.md: fix the colliding referent (SC-4; R-4)

- **Deliverable:** rewrite the general-cycle restatement paragraph in the
  Submodule execution boundary section so the parent-with-submodules shape
  resolves to the parent's toolchain; add the instruction-precedence rule and
  cite the floor's owned wording instead of duplicating it.
- **RED (structural, ephemeral):** read shows the L31–34 restatement
  ("the change's repo's own build framework") colliding with the boundary
  paragraph for a submodule-landing change.
- **GREEN:** the restatement names the root (parent) repo's framework for the
  parent-with-submodules shape, keeps the no-foreign-toolchain-on-verified-
  failure clause, and states that submodule-local AGENTS.md build/test
  guidance is never followed (citing the floor's owned wording).
- **Instrument (tier: smoke):** read + grep — the phrase "the change's
  repo's own" is either gone or qualified by the parent/submodule shape;
  precedence rule present with a floor citation.

## Item 3 — gradle/SKILL.md wrapper referent + SC-7 sweep across the card class (SC-5, SC-7; R-5)

- **Deliverable:** the gradle card's Wrapper discipline first bullet resolves
  the wrapper referent per the floor's owned wording; then a grep sweep over
  `.opencode/skills/` for wrapper-referent build-invocation phrasing.
- **RED (structural, ephemeral):** gradle card reads "Invoke builds through
  the wrapper (`./gradlew`) when the repository ships one" — for a
  submodule-targeted change, "the repository" reads as the submodule; the
  sweep phrases ("the repository ships one", "the change's repo's own",
  "root repo") return the unqualified hits the spec records.
- **GREEN:** bullet reads to the effect "when the repository (the root repo
  of the working set — for a submodule-targeted change, the parent
  repository) ships one"; a submodule shipping its own wrapper never selects
  it for a change the root includes. The sweep greps the card class; any
  further deficient card instance found is reported for disposition (the
  gradle card is the only verified instance — others, if found, get filed,
  not silently edited).
- **Instrument (tier: smoke):** read of `gradle/SKILL.md` + the SC-7 grep
  phrase families across `.opencode/skills/`.

## Item 4 — git-workflow-branch: prohibition at the operation surface (SC-6; R-6)

- **Deliverable:** the sync step (rule 2) and the real-work sequence (rule 3)
  carry the no-`--recursive` prohibition at the point where the agent plans
  `git submodule` commands, citing the floor's owned wording (single-sourced).
- **RED (structural, ephemeral):** grep shows no `--recursive` prohibition in
  `git-workflow-branch/SKILL.md` (the ban survives only in `ci-boundary`
  rule 5 and `release-promoter`).
- **GREEN:** one citation sentence placed in the submodule section header or
  rule-2/rule-3 body: all submodule operations are per-path and non-recursive
  by construction; no `--recursive` form of any submodule command (floor's
  Build-tooling exclusivity statement). Note: rule 4's existing remediation
  command `git submodule foreach git submodule deinit --all --force` is not
  recursive (`foreach` on registered top-level entries is per-path) — it
  stays untouched.
- **Instrument (tier: smoke):** grep of the card for `--recursive` hit
  carrying the prohibition and the floor citation.

## Item 5 — behavioral probe over a parent-with-submodule workspace (SC-8; R-7; behavioral tier, on-demand)

- **Deliverable:** a dispatched behavioral probe: the agent plans
  build/test execution for a change targeting a submodule whose own wrapper
  and AGENTS.md prescribe submodule-local tasks; the probe session's plan
  routes the root wrapper with root task paths, plans no recursive submodule
  operation, and does not adopt the submodule-local guidance.
- **RED:** the probe dispatch runs BEFORE item 1's floor edit — evidence is
  captured against the unchanged trunk while the pre-change state exists. The
  RED assertion is one arm: the probe reproduces the spec's documented
  failure class (the session plans the submodule's own wrapper / adopts
  submodule-local build guidance). A floor-text read corroborates but is not
  an alternative pass condition.
- **GREEN:** run the identical probe against the changed deck — the plan
  routes the root wrapper; no recursive submodule ops; no submodule-local
  adoption. Assertion is by session-timeline evidence, not floor-text grep.
- **Instrument (tier: heavy — on-demand):** dispatched behavioral probe via
  the tests-v2 harness per the behavioral-testing card; routed here only for
  this item, never a default-suite run. Evidence recorded in the issue's
  store.

## Verification ordering

Item 5's RED probe executes first, against the unchanged trunk (captured
pre-change evidence); items 1–4 then run in order (each GREEN cites the
single-sourced floor wording from item 1); item 5's GREEN probe runs last,
against the changed deck, with the identical probe script. After all items,
the structural SC-7 sweep output and the suite-green check gate the PR per
the implement card.
