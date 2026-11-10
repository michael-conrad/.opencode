# Build-tooling exclusivity resolves the parent/submodule root — submodule-local build guidance and recursive submodule ops bound

Source: bug report `.opencode#2728` (developer-filed 2026-11-10), observed 2026-11-09 in the Clarivate-XmlLoader/doaj multi-repo workspace (work on doaj#100); the developer corrected the agent twice in session — "never fucking use any gradle besides the root repo's gradlew"; "root submodules get synced. never fucking recurse submodules." — and assessed the behavior as a regression: the agent planned the submodule's own gradle wrapper and ran broad `git submodule` loops against nested checkouts until interrupted. Defect texts below verified by direct read this session (2026-11-10); quotations verbatim.

## Problem

The deck's build-toolchain ruling fails to bind when the change lands in a submodule of a parent repository — three verified surfaces leave the agent a route to "the submodule's own gradlew", and two related protections are absent from the work-cycle surfaces:

1. `implement/references/implementation-workflow.md` carries an internal referent collision. The submodule execution boundary (provenance `.opencode#2563`) states: "In a parent repo with submodules, build, test, and verification runs through the parent repo's own build framework. The agent does not execute a submodule's own build tooling (its test runner, gates, or quality bars) directly" — correct. Four lines later the general-cycle restatement states: "whichever repo shape the change lands in: the change's repo's own build framework (its documented wrapper/framework — for Gradle repos, the `./gradlew` wrapper) is the exclusive build toolchain" — for a change landing in a submodule, "the change's repo's own" reads as the submodule's own framework, contradicting the boundary paragraph above it. The observed agent (post-#2563, 2026-11-09) resolved exactly that reading.
2. `floor.md` Safety, Build-tooling exclusivity: "build and test run only through the root repo's own build framework — its `./gradlew` wrapper for Gradle repos, or the repo's documented wrapper/framework generally" — "root repo" is defined nowhere on the parent/submodule axis, and the sentence immediately shifts referent to "the repo's documented wrapper". An agent working in a submodule checkout has a legitimate reading of "root" as the submodule's git root. In the same session the agent had read the submodule's own AGENTS.md ("use ./gradlew wrapper, never bare gradle") per the pre-implementation card-loading path and planned the submodule's wrapper from it.
3. `gradle/SKILL.md` Wrapper discipline: "Invoke builds through the wrapper (`./gradlew`) when the repository ships one" — no parent-routing exception; for a submodule-targeted change, "the repository" ships its own wrapper.
4. Absent rules (grep-verified this session): no active-deck surface states that a submodule's own AGENTS.md build/test guidance is never a build instruction the agent follows over the root mandate; and no active-deck work-cycle surface carries the absolute no-`--recursive` prohibition — the blanket ban survives only inside `ci-boundary` rule 5 ("Never perform a recursive submodule checkout in any form", CI-scoped frame) and `release-promoter`'s protocol; the pre-rip general rule (`attic/guidelines/060-tool-usage.md`: "NEVER use `--recursive` with any git submodule command") was not restored to any work-cycle surface during the restructure.

Cost-of-pattern precedent on file: [the Ainglish writing discipline](../../guidelines/ainglish-writing-discipline.md) (its lines 81–93 record the `.opencode#2592` misbinding — an unqualified relational noun that survived three fresh-context audits — and prescribe the fix pattern: name the referent directly, state the topology before relational nouns, qualify "parent"/"root" explicitly in the same sentence).

## Scope

Targeted text edits, each in the surface's already-owned section (no new cards, no restructuring):

| Surface | Owned section | Change |
|---------|---------------|--------|
| `floor.md` | Safety — Build-tooling exclusivity bullet | parent/submodule root resolution + submodule-local instruction precedence + absolute no-`--recursive` statement |
| `implement/references/implementation-workflow.md` | Submodule execution boundary section | remove the restatement's colliding referent; state the instruction-precedence rule; cite the floor's owned wording |
| `gradle/SKILL.md` | Wrapper discipline | wrapper-referent aligned to the floor's owned wording under R-5 (verified deficient instance; R-5's requirement is the card class in general) |
| `git-workflow-branch/SKILL.md` | submodule sync step (rules 2–3) | carry the no-`--recursive` prohibition at the operation surface (citation of the owned wording) |

`ci-boundary/SKILL.md` is consistent as written (rule 5's blanket no-recursive-checkout ban, rule 6's agent execution boundary) and is touched only by the consistency sweep, not rewritten. All four edited files live in this repository; scope and filing home coincide.

## Requirements

- R-1 (structural): the floor's Build-tooling exclusivity bullet SHALL resolve the parent/submodule axis: for a change targeting a submodule of a parent repository, the root is the parent repository — build, test, and verification run exclusively through the root (parent) repo's documented wrapper/framework, invoked from the root's own build surface; a submodule's own wrapper, documented framework, documentation, or ad-hoc distribution is never the sanctioned build toolchain for the change, regardless of the change's delivery location. The directive states this in framework-general terms — it is not scoped to any one build system, and any toolchain instance the floor names sits subordinate to the stated general rule.
- R-2 (structural): the floor SHALL state the instruction precedence: a submodule's own AGENTS.md build/test guidance is never a build instruction the agent follows — the root mandate above outranks every submodule-local build/test directive, however the submodule's own docs word them.
- R-3 (structural): the floor SHALL state, at the same severity class as the build-tooling exclusivity sentence (no utterance authorizes it): `git submodule --recursive` — and every other recursive form (`git clone --recursive`, recursive checkout configurations, `--remote`) — is absolutely forbidden in work on a repository consumed as (or by) a submodule; submodule operations are per-path and non-recursive by construction.
- R-4 (structural): the implementation-workflow reference SHALL no longer imply the submodule's own build framework for a submodule-targeted change: the general-cycle restatement's referent is fixed to read the root (parent) toolchain in the parent-with-submodules shape; the submodule execution boundary section states the instruction-precedence rule (R-2's rule, named at the reference that routes submodule AGENTS.md loading into build planning) and cites the floor's owned wording rather than duplicating it.
- R-5 (structural): each language/toolchain card's build-invocation guidance that names the repository owning the invoked wrapper SHALL resolve that referent per the floor's owned wording — for a change targeting a submodule of a parent repository, the invoked wrapper is the root (parent) repo's; a submodule shipping its own wrapper never selects it for a change the root includes. The requirement is over the card class in general; `gradle/SKILL.md`'s wrapper discipline is the verified deficient instance (Problem item 3) and is aligned under it — the requirement's scope is not gradle.
- R-6 (structural): the git-workflow-branch card's submodule sync/real-work steps SHALL place the no-`--recursive` prohibition at the operation surface where the agent plans `git submodule` commands, citing the floor's owned wording (single-sourcing: the floor owns the wording; per-surface steps own their placement).
- R-7 (behavioral): in a dispatched implementation-cycle probe over a parent-with-submodule workspace (parent ships `./gradlew`; submodule ships its own wrapper and an AGENTS.md prescribing submodule-local build/test tasks), the agent SHALL plan build/test execution through the root repo's wrapper with root task paths, SHALL NOT plan recursive submodule operations, and SHALL NOT adopt the submodule-local build/test guidance as its execution plan.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | floor Build-tooling exclusivity bullet resolves the parent/submodule axis in framework-general terms: root = parent repo for a change in a submodule; build/test/verification through the root's own build surface; submodule wrapper/framework/distribution excluded | structural | read `floor.md` — fact-decidable content check |
| SC-2 | floor states the instruction-precedence rule (submodule-local AGENTS.md build/test guidance never followed as a build instruction) | structural | read `floor.md` |
| SC-3 | floor states the absolute no-`--recursive` prohibition at the build-tooling sentence's severity class | structural | read `floor.md` |
| SC-4 | implementation-workflow general-cycle restatement binds the root (parent) toolchain in the parent-with-submodules shape; boundary section states the precedence rule and cites, not duplicates, the floor's wording — the L30–32 referent collision is gone | structural | read `implementation-workflow.md` |
| SC-5 | toolchain cards' wrapper-referent build-invocation guidance resolves to the root repo's framework per the floor's owned wording (verified instance: gradle card's wrapper discipline); R-5's requirement scope is the card class, not gradle | structural | read `gradle/SKILL.md` + grep `.opencode/skills/` for wrapper-referent build-invocation phrasing |
| SC-6 | git-workflow-branch submodule sync step carries the prohibition at the operation surface, citing the owned wording | structural | read `git-workflow-branch/SKILL.md` |
| SC-7 | no active-deck surface's surviving text implies a submodule's own wrapper/tooling as the build toolchain for a change targeting a submodule of a parent; the four surfaces state the owned facts once and cite otherwise | structural | grep the active deck (`.opencode/floor.md`, `.opencode/skills/`) for the phrase families ("the change's repo's own", "the repository ships one", "root repo") and read the four files |
| SC-8 | probe over a parent-with-submodule workspace: build/test plan routes the root wrapper with root task paths; no recursive submodule operations planned; submodule-local build/test guidance not adopted | behavioral | dispatched behavioral probe (tests-v2 harness) |

## Out of scope

- `ci-boundary/SKILL.md` content — rule 5's blanket no-recursive-checkout ban and rule 6's agent execution boundary are already correct; only the SC-7 consistency sweep touches it (and only if the sweep finds a contradiction).
- `release-promoter` operating protocol (its FORBIDDEN wording already correct).
- The gradle card's packaging references, the `java` card, and other language cards.
- The floor's authorization vocabulary and any other Safety bullet.
- New skill cards, harness capability expansion, or mechanical enforcement (the rule is intent-adjacent fact text; no script classifies a "which repo is root" judgment).

## Approach

Per-surface edit of the owned sections:

1. **floor.md** — extend the Build-tooling exclusivity bullet with: the parent/submodule root definition (R-1), the instruction-precedence sentence (R-2), and the no-`--recursive` sentence (R-3). The floor is the only always-injected surface — the report's "above any submodule-local instruction" places the owned statements here; cards cite them.
2. **implementation-workflow.md** — rewrite the general-cycle restatement so the parent-with-submodules shape resolves to the parent's toolchain (R-4); the boundary section gains the precedence rule in the same paragraph pair it already owns.
3. **Language/toolchain cards** — the gradle card's wrapper-discipline bullet (verified deficient instance) gains the root-framework referent per R-5; the SC-7 sweep surfaces any other card whose wrapper-referent text would misroute.
4. **git-workflow-branch** — the sync step and real-work sequence gain the prohibition placement (R-6).

Authoring rule throughout: [the Ainglish writing discipline's](../../guidelines/ainglish-writing-discipline.md) referent pattern — qualify "root"/"parent" in the same sentence that uses them, state the topology before relational nouns. Implementation routes through deck governance (these are `skills/`/floor edits — admission gate applies) and this repository's PR process.

## Impact

- Consumers: every implementation session in a parent-with-submodules workspace (build routing now unambiguous); language/toolchain-card users; git-workflow sessions performing submodule ops; deck governance (four-file edit workload).
- Risk: low — text-only edits to already-owned sections; no procedure or vocabulary change; the parent-routing outcome matches the developer's standing mandate; the directive is stated framework-generally (developer directive this session), with toolchain instances subordinate.
- Blast radius: the four files plus the SC-7 sweep cover every deck surface carrying a competing toolchain referent (grep-verified this session: `ci-boundary` and `release-promoter` wording is already consistent; the attic copies are loaded by nothing and stay out of scope). The tests-v2 behavioral suite is unaffected: `2654-sc6-build-framework-exclusivity.sh` evaluates by session-timeline assertion rather than floor-text grep, and its quoted phrase ("the repo's documented wrapper/framework generally") survives R-1's in-bullet addition.
