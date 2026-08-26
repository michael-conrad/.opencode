---
title: '[SPEC] Qualify issue references as `owner/repo#NNN` across the agent deck'
remote_issue: 2319
remote_url: https://github.com/michael-conrad/.opencode/issues/2319
promoted_at: '2026-08-24T21:54:00+00:00'
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2319/

## Problem Statement

The agent passes issue numbers between skills and sub-agents in unqualified, bare form (`#N`, `issue_number`, `spec_issue_number`). A bare number carries no repository identity, so every consuming sub-agent resolves the repository itself from ambient session context — and the resolution fails on record. Observed failures (provenance citations):

1. Lessons-learned catalog `session-2026-06-20`, lesson 4 — "Cross-repo context contamination — started work in wrong repo before reading plan," classified ✅ Systemic. The catalog's Key Principle 4 records the concrete incident: the plan at `.opencode/.issues/1308-spec-clean-up-session-enforcement-ts/plan.md` belongs to the `.opencode` submodule repository, not the root `opencode-config` repo, and the agent started work in the wrong repository because the plan reference carried no repo binding.
2. The `.opencode/AGENTS.md` Testing Lessons Learned catalog carries a standing "Wrong repo for spec creation" entry: agents defaulting issue filings to the root repo produce issues in the wrong repository.

When identity is not bound to the token, the consumer guesses — and has guessed wrong on record.

## Root Cause / Motivation

Issue identity is split across three separate context fields (`issue_number`, `github.owner`, `github.repo`) that can be dropped, reordered, or resolved differently by each consuming hop. Both degenerate forms are live in the deck today (see Definitions): the tri-field form carries the three fields separately; the dropped-field form carries only the bare number and leaves repository identity entirely to re-derivation. Nothing binds the number to its repository at the point of handoff, so correctness depends on every intermediate agent re-deriving repo identity from ambient context. The change is needed now because each new skill copies the split-field contract pattern, and every copy widens the wrong-repository failure class documented in the Problem Statement citations.

## Approach Chosen

Introduce a single self-describing issue identity token, `{owner}/{repo}#NNN`, that binds repository identity to the issue number at the point of handoff. Skill-card Context-passed contracts carry the composite (`issue_ref`) instead of split identity fields; sub-agents parse the composite and derive `owner`, `repo`, and `issue_number` locally for artifact-path construction, protected by the derived-variable carve-out. Non-platform task cards stop issuing direct platform API calls carrying bare issue numbers; such calls concentrate in the platform task-card sets and consume the composite. A guideline codifies the parse convention, and the `skildeck` semantic lint enforces it mechanically. Platform resolution remains the responsibility of the platform-aware issue-operations dispatcher — the token deliberately does not carry platform.

## Alternatives Considered & Why Discarded

1. **Guideline-only discipline with bare numbers retained** — mandate that each hop re-check session-init Repo Information before resolving any `#N`. Discarded: the documented failures occurred precisely when ambient-context re-derivation failed at a hop; the alternative adds procedural memory load without structural binding, and the lessons-learned catalog states (Key Principle 3) that documented lessons without enforcement gates do not prevent recurrence.
2. **Full platform URL as the token** (`https://<host>/<owner>/<repo>/issues/<N>`). Discarded: couples the token to the platform dispatch mechanism and breaks for the `local` platform, where no remote URL exists; the Platform / Routing Note excludes platform from the token.

## Key Design Decisions

1. **The composite binds repository identity only, never platform.** Tradeoff: the token stays valid across github/gitbucket/local routing, at the cost of requiring the platform-aware dispatcher to resolve platform separately from the repo.
2. **Derived-variable carve-out instead of an absolute prohibition on local number variables.** Tradeoff: preserves ergonomic artifact-path construction inside sub-agents, at the cost of requiring the SC-5 lint rule to police the carve-out boundary.
3. **Replacement happens at the existing Context-passed boundary, not through a new transport layer.** Tradeoff: drop-in compatibility for every current dispatch site, at the cost of touching every enumerated contract exactly once.

## User Intent / Original Prompt

The spec originated in the recurring deck-wide failure pattern captured in the Problem Statement citations: systemic cross-repository contamination (session-2026-06-20, issue 1308 incident) and the standing "Wrong repo for spec creation" catalog entry. The motivating request: qualify every issue reference as `owner/repo#NNN` across skill cards, task cards, guidelines, and the skildeck lint so repository identity can no longer be separated from the issue number.

## Not Included

- **Platform dispatch mechanism changes** — the platform-aware issue-operations dispatcher keeps full responsibility for platform selection; the composite deliberately omits platform, so no dispatch-mechanism code changes.
- **Platform sub-skill routing logic changes** — the routing internals of `platforms/github-mcp/`, `platforms/gitbucket-api/`, and `platforms/local/` are untouched; only the identity form crossing into them changes.

## Definitions

These definitions bind every term used by the success criteria. All populations were enumerated by live grep sweep during this revision (counts recorded in Affected Files).

1. **Agent deck (the deck)** — the population of skill cards (`.opencode/skills/**/SKILL.md`) and task cards (`tasks/*.md`) maintained in the `.opencode` repository. Verified live this revision: 51 skill cards (`find .opencode/skills -name SKILL.md | wc -l`; supersedes the earlier 38-card claim, which did not reproduce under independent recount).
2. **Split-identity Context-passed contract** — any skill-card `Context passed:` payload or trigger-dispatch-table context column that carries issue identity as unbound separate fields: `issue_number` or `spec_issue_number` with repository identity either omitted (dropped-field form) or carried as separate `github.owner` / `github.repo` entries (tri-field form). Both forms instantiate the Root Cause split; both are in scope for replacement.
3. **Non-platform task card** — any `tasks/*.md` outside `.opencode/skills/issue-operations/**/tasks/`.
4. **Platform task-card set** — `.opencode/skills/issue-operations/**/tasks/*.md`, including the `platforms/github-mcp/`, `platforms/gitbucket-api/`, and `platforms/local/` subsets.
5. **Concrete bare issue reference** — `#N`, an `issue_number=N` argument to a platform API call, or prose `#N` naming a real issue, in each case without repository qualification.
6. **Derived-variable carve-out** — a locally scoped variable (for example `spec_issue_number`) assigned by parsing a qualified composite and used solely to construct artifact paths beneath the resolved issues prefix; never transmitted across a skill boundary as identity.
7. **Unconsumed issue token** — a concrete bare issue reference appearing in a card with no corresponding composite derivation or carve-out in scope; flagged by the SC-5 lint rule.
8. **Issues prefix** — the per-repo resolved issues-directory prefix from the session-init `## Repo Information` table, formed as `{path}/.issues/{N}/` for repo entry `path` and issue `N`. The root-repo entry (`path: .`) resolves beneath `.issues/{N}/`; the `.opencode` submodule entry resolves beneath `.opencode/.issues/{N}/`. The derived-variable carve-out (Definition 6) constructs artifact paths only beneath this resolved prefix.
9. **sc-summary.yaml** — the analytical artifact enumerating each success criterion's evidence type and `plan_item` mapping, generated by the spec-creation pipeline. Canonical local path for this deck's specs: `.opencode/.issues/{N}/sc-summary.yaml` (issue root, outside the `artifacts/` directory). It is regenerated whenever analytical artifacts are regenerated; evidence-type reconciliation statements in this spec reference that file at this canonical local path.
10. **RED/GREEN support** — auxiliary static sweep evidence recorded alongside a behavioral RED→GREEN verification cycle. RED/GREEN support is admissible only as corroboration of a passing behavioral run; it is never sole evidence and never a substitute when the behavioral method cannot execute (test-integrity law). SC-3's static sweep is classified RED/GREEN support under this definition.

## Affected Files

Glob targets (all verified to resolve live):

- `.opencode/skills/audit/tasks/*.md`
- `.opencode/skills/issue-operations*/**/SKILL.md` and `tasks/*.md`
- `.opencode/skills/spec-creation/**/tasks/*.md`
- `.opencode/skills/writing-plans/**/tasks/*.md`
- `.opencode/guidelines/*.md`
- `.opencode/tools/skildeck`

Enumerated inventories (live-verified this revision):

**Split-identity Context-passed contract sites (SC-2):**

| Site | Form | Extent |
|---|---|---|
| `.opencode/skills/writing-plans/SKILL.md` | `{issue_number, project_root, issues_prefix}` | 19 dispatch rows |
| `.opencode/skills/spec-creation/SKILL.md` | `{issue_number, ...}` | 7 dispatch rows |
| `.opencode/skills/approval-gate/SKILL.md` | `{issue_number, issues_prefix, project_root}` | 3 dispatch rows |
| `.opencode/skills/completion-core/SKILL.md` | `{workflow_state, issue_number}` | 1 row |
| `.opencode/skills/audit/SKILL.md` | `{spec_issue_number, github.owner, ...}` | 4 dispatch rows |
| `.opencode/skills/programming-principles/SKILL.md` | `{issue_number, ..., github.owner, github.repo}` | 1 row |
| `.opencode/skills/issue-operations-core/SKILL.md` | TDT context column `{issue_number, ...}` | 10 rows |
| `.opencode/skills/issue-operations-sync/SKILL.md` | TDT context column `{issue_number}` | 2 rows |
| `.opencode/skills/issue-operations-comments/SKILL.md` | TDT context column | 1 row |
| `.opencode/skills/issue-operations-sub-issues/SKILL.md` | TDT context column | 1 row |

Extent extraction grammar (recorded so every count above reproduces): workflow-contract cards count `Context passed:` payload lines carrying an issue-identity field — `grep -cE 'Context [Pp]assed:.*(issue_number|spec_issue_number)' SKILL.md` (writing-plans 19/19 payloads, spec-creation 7/7, approval-gate 3/3, completion-core 1/1, audit 4/4); trigger-dispatch-table cards count data rows in the `## Trigger Dispatch Table` section whose context column carries an issue-identity field (awk over the section, rows matching `issue_number|spec_issue_number`, excluding header and delimiter rows; io-core 10 of 16 rows, io-sync 2 of 3, io-comments 1 of 1, io-sub-issues 1 of 2); programming-principles carries a single workflow-line contract whose `pre-analysis` payload is `{issue_number, task_description, audit_phase, github.owner, github.repo}`. All ten extents were re-derived live under these commands during this revision.

Scope relationship to SC-6: the SC-2 table enumerates card-level contract surfaces (SKILL.md); the SC-6 families enumerate consuming task files beneath four skill families, which include the task files belonging to the four `issue-operations-*` card sites listed above. A site appearing in both lists receives one contract change (card) and one consumption change (task files) — they are not double-counted work items.

**Non-platform task cards carrying direct platform API calls with bare issue numbers (SC-3)** — GitHub MCP family. Enumeration predicate (recorded, live-reproducing): task cards containing GitHub MCP issue-tool tokens (`github_issue_[a-z_]+`) outside the platform set and outside the `gh-cli`/`gb-cli` platform-CLI wrapper decks — extraction command: `find .opencode/skills -name '*.md' -path '*/tasks/*' | grep -v '/issue-operations' | grep -vE '/(gh-cli|gb-cli)/' | xargs grep -lE 'github_issue_[a-z_]+'`. The command reproduces exactly the 21 files below (18 carry inline call syntax `github_issue_*(`; 3 — plan-fidelity-investigator, correspondence/draft, git-workflow-branch/pre-work — reference GitHub MCP issue tools in instruction/routing text and are in scope as identity-bearing instruction sites). Supersedes the earlier characterization sweep for literal `issue_number=` arguments, which matched only 10 files and did not reproduce this enumeration. Documented exclusions: (a) `gh-cli`/`gb-cli` task cards are dedicated platform-CLI instruction decks whose purpose is direct CLI operation on dispatched arguments — they are functional platform surface, not non-platform callers; (b) `git-workflow-cleanup/tasks/cleanup/issue-closure.md` matches a literal `issue_number=` text search but contains zero direct platform API calls — its hits are `issue-operations ->` dispatcher-routing pseudocode — so it is out of R-3 scope.

1. `.opencode/skills/audit/tasks/drift-detection-investigator.md`
2. `.opencode/skills/audit/tasks/plan-fidelity-investigator.md`
3. `.opencode/skills/audit/tasks/plan-fidelity-validator.md`
4. `.opencode/skills/brainstorming/tasks/enforcement.md`
5. `.opencode/skills/conflict-resolution/tasks/classify-and-resolve.md`
6. `.opencode/skills/correspondence/tasks/draft.md`
7. `.opencode/skills/engineering-approach/tasks/verify-understanding.md`
8. `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
9. `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`
10. `.opencode/skills/git-workflow-cleanup/tasks/cleanup/issue-closure-sweep.md`
11. `.opencode/skills/git-workflow-cleanup/tasks/cleanup/verify-merge.md`
12. `.opencode/skills/git-workflow-conflict/tasks/rebase-pending.md`
13. `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`
14. `.opencode/skills/issue-review/tasks/analyze-and-spec.md`
15. `.opencode/skills/issue-review/tasks/audit.md`
16. `.opencode/skills/issue-review/tasks/qa.md`
17. `.opencode/skills/pre-analysis/tasks/analyze.md`
18. `.opencode/skills/sre-runbook/tasks/track.md`
19. `.opencode/skills/sync-guidelines/tasks/sync-pull.md`
20. `.opencode/skills/sync-guidelines/tasks/sync-push.md`
21. `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`

**Consuming task-file families (SC-6):**

| Family | Files consuming unqualified issue numbers |
|---|---|
| `audit/tasks/` | 27 files referencing `issue_number` / `spec_issue_number` |
| `spec-creation/tasks/` | 5 files |
| `writing-plans/tasks/` | 8 of 9 files construct paths via `issues_prefix` from the dispatched number |
| `issue-operations-core/tasks/` | 7 files |
| `issue-operations-comments/tasks/` | 1 file |
| `issue-operations-sub-issues/tasks/` | 2 files |
| `issue-operations-sync/tasks/` | 2 files |

**Named targets:**

- **SC-4 guideline target:** `.opencode/guidelines/118-issue-reference-qualification.md` (new file; the 118 numbering slot is unused in the guidelines index as of this revision).
- **Guideline registration surface:** `.opencode/guidelines/INDEX.md` slot-118 row plus the `.opencode/opencode.jsonc` `instructions`-array tier decision (see Dependencies). Verified live this revision: the index jumps from `117-session-trigger-behavior.md` to `130-authority-source.md` with no 118 entry, and the instructions array currently loads twelve guideline files plus `INDEX.md` (reproducing command recorded against silent drift: `grep -nE '\.opencode/guidelines/[a-z0-9-]+\.md' .opencode/opencode.jsonc`; twelve entries reproduce at lines 79–90, with `INDEX.md` at line 91). Registration is part of Item 1 GREEN so the created guideline actually loads into agent sessions.
- **SC-5 lint surface:** `.opencode/tools/skildeck` `lint` action, implemented in `.opencode/tools/impl/skildeck/skildeck-lint`.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | The composite form `{owner}/{repo}#NNN` is defined in `.opencode/guidelines/118-issue-reference-qualification.md` as the single self-describing issue identity token used for every internal issue-identity handoff whose repository resolves to an owner/repo pair; under `identity_source: local` no owner/repo pair exists, and Edge Case 5 governs the alternative directory-scoped issues-prefix identity form. | structural | Read `.opencode/guidelines/118-issue-reference-qualification.md`; confirm the file exists and designates the token grammar `{owner}/{repo}#NNN` as the sole internal issue identity form for owner/repo-resolvable handoffs, with the local-platform alternative deferred to Edge Case 5. |
| SC-2 | Every split-identity Context-passed contract enumerated in Affected Files carries issue identity only through the single composite field (`issue_ref: "{owner}/{repo}#NNN"`); separate `issue_number`, `spec_issue_number`, `github.owner`, and `github.repo` identity fields no longer appear in those contracts. | behavioral | Behavioral test via `bash .opencode/tests-v2/with-test-home opencode run '<dispatch scenario>'`: stderr shows the dispatched sub-agent receiving and consuming the qualified composite at handoff, and no unqualified issue token crossing a skill boundary. |
| SC-3 | Direct platform API calls carrying bare issue numbers are absent from every non-platform task card enumerated in Affected Files; such calls exist only within the platform task-card set and consume the qualified composite. | behavioral | Behavioral run scenario asserting a non-platform sub-agent routes issue reads through `issue-operations -> read-issue` rather than issuing direct `github_issue_read(issue_number=N)` calls. A static sweep excluding `skills/issue-operations/` (zero `issue_number=` hits outside the platform set) is recorded as RED/GREEN support, never as sole evidence. |
| SC-4 | A guideline rule at `.opencode/guidelines/118-issue-reference-qualification.md` defines the composite parse convention: sub-agents derive `owner`, `repo`, and `issue_number` from `{owner}/{repo}#NNN`. Permitted (derived-variable carve-out): local variables such as `spec_issue_number` used solely for artifact-path construction beneath the resolved issues prefix. Forbidden: any concrete bare issue reference to a real issue without repo qualification. | behavioral | Behavioral variant per incremental-build discipline: `bash .opencode/tests-v2/with-test-home opencode run` with a prompt carrying an unqualified reference alongside a qualified composite; stderr assertions confirm the agent derives owner/repo/number from the composite and performs no wrong-repo resolution on the bare token. |
| SC-5 | The skildeck semantic lint (`.opencode/tools/skildeck lint`, implemented in `.opencode/tools/impl/skildeck/skildeck-lint`) flags concrete bare issue references (`#N`, `issue_number=N` call arguments, unconsumed issue tokens) in skill cards and task cards while permitting the derived-variable carve-out. | behavioral | Execute `.opencode/tools/skildeck lint` against a fixture deck containing planted bare references and carved-out derived-variable sites; inspect flag output: every planted violation is listed and every carve-out site is excluded (test execution with output inspection). |
| SC-6 | Task files in the audit, issue-operations, spec-creation, and writing-plans families enumerated in Affected Files consume the composite: instructions, path construction, and API dispatch inside those files start from the qualified token rather than a bare number. | behavioral | Behavioral re-dispatch of one representative flow per family via `bash .opencode/tests-v2/with-test-home opencode run`; stderr evidence confirms task-card steps resolve paths and calls from the composite. |

Evidence-type reconciliation record: SC-2 and SC-6 are classified `behavioral` in both this document and `sc-summary.yaml` (contract-shape replacement alters agent routing at runtime). SC-4 and SC-5 are classified `behavioral` in both documents: the guideline change governs agent parsing behavior (Enforcement Test Mandate applies to guideline changes), and lint-rule verification is test execution with output inspection. SC-1 remains `structural` (definition-site existence and content).

## Requirements

1. **R-1.** The deck SHALL define `{owner}/{repo}#NNN` as the single self-describing issue identity token for every internal issue-identity handoff whose repository resolves to an owner/repo pair; Edge Case 5 governs the identity form used when no pair exists (`identity_source: local`). (Traces to SC-1.)
2. **R-2.** Skill-card split-identity Context-passed contracts SHALL carry issue identity only as the composite field; separate identity fields SHALL be removed from those contracts, and the consuming task files in the four enumerated families SHALL consume the composite. (Traces to SC-2, SC-6.)
3. **R-3.** Non-platform task cards SHALL NOT contain direct platform API calls carrying bare issue numbers; such calls SHALL appear only in the platform task-card set and SHALL consume the qualified composite. (Traces to SC-3.)
4. **R-4.** The guideline `.opencode/guidelines/118-issue-reference-qualification.md` SHALL define the composite parse convention, including the derived-variable carve-out and the prohibition on concrete bare issue references. (Traces to SC-4.)
5. **R-5.** The skildeck semantic lint SHALL flag concrete bare issue references in skill cards and task cards while permitting the derived-variable carve-out. (Traces to SC-5.)

## Items

### Item 1 (SC-1): Canonical composite token definition

- RED: Definition-site absence check — reading `.opencode/guidelines/118-issue-reference-qualification.md` finds no `{owner}/{repo}#NNN` designation.
- GREEN: Add the definition designating `{owner}/{repo}#NNN` as the single self-describing internal issue identity token; in the same slice register the guideline so it loads into agent sessions — add the slot-118 row to `.opencode/guidelines/INDEX.md` (trigger pattern, tier) and record the `.opencode/opencode.jsonc` `instructions`-array decision (Tier 1 upfront-load entry vs Tier 2 progressive disclosure via INDEX).
- verify: Read the file; token grammar present, designated as sole internal form for owner/repo-resolvable handoffs; slot-118 row present in INDEX.md; instructions-array decision recorded.
- commit: Guideline definition slice.

### Item 2 (SC-2): Composite-only Context-passed contracts

- RED: Behavioral dispatch scenario shows a sub-agent receiving split identity fields (`issue_number` without repo binding) at handoff.
- GREEN: Replace each enumerated contract with the composite field; re-run scenario showing composite consumption.
- verify: Behavioral stderr assertions per the SC-2 verification method.
- commit: Enumerated SKILL.md contract sites in one slice.

### Item 3 (SC-3): Bare-numbered direct calls removed from non-platform cards

- RED: The recorded enumeration sweep (`github_issue_[a-z_]+` tokens per the Affected Files predicate) lists GitHub MCP issue-tool sites in the 21 enumerated non-platform task files.
- GREEN: Rewrite those instruction sites to route through `issue-operations -> read-issue` consuming the composite; behavioral scenario confirms routed behavior.
- verify: Behavioral run scenario plus supporting static sweep (support only).
- commit: Non-platform task-card slice.

### Item 4 (SC-4): Composite parse convention guideline

- RED: Behavioral run with an unqualified reference shows the agent resolving repo from ambient context (wrong-repo hazard).
- GREEN: Add the parse-convention rule (derivation, carve-out, prohibition) to `.opencode/guidelines/118-issue-reference-qualification.md`; re-run shows derivation from the composite.
- verify: Behavioral stderr assertions per the SC-4 verification method.
- commit: Guideline rule slice.

### Item 5 (SC-5): skildeck bare-reference lint rule

- RED: `.opencode/tools/skildeck lint` on a fixture deck with planted bare references reports no violations; the fixture deck is created under `./tmp/issue-2319/lint-fixture/`.
- GREEN: Implement the rule in `.opencode/tools/impl/skildeck/skildeck-lint`; lint lists planted violations and excludes carve-out sites.
- verify: Fixture execution with output inspection per the SC-5 verification method.
- commit: Lint rule plus fixtures slice; fixture deck removed from `./tmp/issue-2319/lint-fixture/` at item completion (project tmp discipline — created and removed within Item 5).

### Item 6 (SC-6): Consuming task files qualify identity

- RED: Representative per-family flows show path construction and API dispatch starting from bare numbers.
- GREEN: Update the enumerated task files to derive from the composite; re-run shows qualified consumption.
- verify: Behavioral re-dispatch evidence per the SC-6 verification method.
- commit: Per-family task-file slices.

## Dependencies

| Reference | Relationship | Status |
|---|---|---|
| session-init `## Repo Information` per-repo `owner`/`repo` entries | Authoritative source of the qualification values composed into `{owner}/{repo}#NNN` at handoff | Satisfied (verified this session) |
| `.opencode/guidelines/INDEX.md` slot-118 entry | Registration step making `guidelines/118-issue-reference-qualification.md` discoverable through progressive disclosure; GREEN-phase step of Item 1 — without it SC-4 behavioral verification cannot pass because the guideline never loads into agent sessions | Required (verified absent live this revision: index jumps 117 → 130 with no 118 row) |
| `.opencode/opencode.jsonc` `instructions` array | Tier-assignment decision for `guidelines/118-issue-reference-qualification.md`: Tier 1 upfront load (array entry alongside the twelve currently loaded guidelines plus INDEX.md) or Tier 2 progressive disclosure (INDEX-only); decision recorded during Item 1 GREEN | Decision required at implementation (verified live this revision: twelve guideline entries at lines 79–90 per the reproducing grep recorded in Affected Files) |
| Local model availability through `.opencode/tests-v2/with-test-home` | Runtime precondition for every behavioral verification method in this spec (SC-2, SC-3, SC-4, SC-6): when no behavioral model is available those methods report FAIL per test-integrity law — substitution with static checks is prohibited | Precondition (harness verified present; model liveness checked at each run) |
| `.opencode/tools/skildeck` `lint` action and `.opencode/tools/impl/skildeck/skildeck-lint` | Extension surface for SC-5 | Satisfied (verified via live `--help` execution) |
| `.opencode/tests-v2/with-test-home` | Mandatory isolation harness for every behavioral verification method in this spec | Satisfied (verified present) |
| `.opencode/reference/spec-structure-standards.md` | Structural template governing this document's required sections | Satisfied (read this revision) |

## Traceability

| Requirement | SC(s) | Phase(s) |
|---|---|---|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2, SC-6 | Phase 2, Phase 6 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 4 |
| R-5 | SC-5 | Phase 5 |

Phase numbering matches Item numbering 1 through 6 and the `plan_item` mapping in `sc-summary.yaml`. Every requirement traces to at least one SC; every SC traces to at least one requirement; every SC traces back to the Root Cause split-identity mechanism named in the preamble.

## Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| Remote issue body, issue 2319 (Out-of-scope mirror source) | doc | https://github.com/michael-conrad/.opencode/issues/2319 | Live `gh api` fetch during this revision |
| Lessons-learned catalog, session 2026-06-20 | doc | `.opencode/.issues/lessons-learned/session-2026-06-20/README.md` | Read during this revision (Problem Statement provenance) |
| `.opencode/AGENTS.md` Testing Lessons Learned, "Wrong repo for spec creation" | doc | `.opencode/AGENTS.md` | Read during this revision |
| skildeck CLI actions and modules | code | `.opencode/tools/skildeck`, `.opencode/tools/impl/skildeck/skildeck-lint` | Live `--help` execution and directory listing |
| Contract, task-file, and lint-surface inventories | code | Paths enumerated under Affected Files | Live grep sweeps with counts recorded inline |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Writing the canonical definition costs one documentation pass — consequence: a single authority for what qualifies an issue reference. Skipping costs every consumer an independent interpretation of qualification — consequence: divergent token dialects surface only when a handoff misroutes.
- **SC-2:** Replacing the enumerated contracts costs one contract-shape pass over ten card sites — consequence: repository identity travels bound to the number. Skipping costs each future dispatch a fresh chance to drop or reorder identity fields — consequence: wrong-repository implementations surface at PR review or later.
- **SC-3:** Sweeping bare-numbered direct calls costs one mechanical pass over 21 enumerated task files — consequence: platform traffic concentrates behind the dispatcher. Skipping costs every non-platform card a standing wrong-repository hazard — consequence: cross-repo contamination recurs despite the documented lessons.
- **SC-4:** Codifying the parse convention costs one guideline unit plus its behavioral enforcement test — consequence: derivation is enforced, not advisory. Skipping costs reliance on per-hop memory — consequence: recurrence of exactly the failure class the lessons-learned catalog predicts for unenforced documentation.
- **SC-5:** Extending the lint costs rule implementation plus fixture verification — consequence: regression protection fires at commit time. Skipping costs discovery of newly introduced bare references until a human notices misrouted work — consequence: defect-discovery latency stretches across entire delivery cycles.
- **SC-6:** Updating the consuming task files costs one edit pass per family — consequence: downstream steps inherit qualified identity by construction. Skipping costs mixed old and new conventions across families — consequence: the first unqualified hop defeats qualification everywhere downstream.

## Edge Cases

1. **Input boundary — token grammar:** Accepted form is `{owner}/{repo}#{digits}`. Bare digits without a repository prefix fail validation at the consumption point. Expected behavior: hard fail identifying the unqualified token and its source contract. Resolution: the dispatching orchestrator re-emits a qualified composite.
2. **Input boundary — degenerate numbers:** Issue number `0`, negative numbers, or non-digit payloads fail validation. Expected behavior: rejection before any path construction or API call.
3. **State transition — renumbering:** Local renumber operations change `N` after composites referencing the old number were emitted. Expected behavior: resolution of a stale composite hard-fails as a dangling reference. Resolution: re-issue the composite from current registry state through the issue tooling; silent rewriting of historical artifacts is prohibited.
4. **Failure mode — unknown repository:** A composite names a repository absent from session-init Repo Information. Expected behavior: hard fail requesting developer guidance; guessing a repository mapping is prohibited by repo-routing law.
5. **Failure mode — local platform:** Under `identity_source: local` there is no remote, so no `owner/repo` pair exists. Expected behavior: composite construction MUST NOT fabricate values; issue identity remains directory-scoped beneath the issues prefix and routes through the `platforms/local/` set. Resolution: the orchestrator supplies the local issues-prefix path identity instead of an owner/repo composite.
6. **Concurrency — parallel derivations:** Two sub-agents parse the same composite concurrently. Expected behavior: derivation is a pure read producing independent local variables; no shared mutable state exists, so no race is possible.
7. **Recovery — lint false positive:** A flagged reference that the author judges meaningful. Expected behavior: the flag stands until the reference is rewritten as a qualified composite; silencing or weakening the lint rule to clear a flag is prohibited (test-integrity law). Resolution: convert the reference to the composite form.
8. **Sub-issue references:** Nested sub-issue numbers follow the identical qualification rule; each sub-issue link carries its own composite.

## Platform / Routing Note

`owner/repo#NNN` does NOT carry a platform. Platform is resolved by the platform-aware issue-operations dispatcher from the repo. Do not add platform to the token.

## Change Control

| Date | Change | Trigger | Authorized By |
|---|---|---|---|
| 2026-08-25 | Restructured per `.opencode/reference/spec-structure-standards.md`: added the six preamble fields, Not Included, Definitions, Requirements, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, and Edge Cases; converted Success Criteria to the four-column table with per-row Evidence Type and Verification Method; enumerated affected contracts and files with live-verified counts; named the SC-4 guideline target and SC-5 lint surface; added Problem Statement provenance citations (session-2026-06-20 lesson 4 / issue 1308 incident; AGENTS.md wrong-repo catalog entry); reconciled evidence types between this document and `sc-summary.yaml` (SC-2/SC-6 behavioral; SC-4/SC-5 uplifted to behavioral with rationale recorded under the SC table). No success criterion was removed or weakened. | Spec-audit verdict DRAFT — 6 of 11 holistic dimensions FAIL (Implementability, Internal Consistency, Completeness, Testability, Provenance, Traceability) with six bidirectional findings in `tmp/issue-2319/artifacts/spec-audit/{verdict,judgment}.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing the DRAFT verdict remediation mandate |
| 2026-08-26 | Spec-audit cycle-2 remediation — four FAIL dimensions addressed: **Provenance** — corrected Definition 1 skill-card count 38 → 51 against a live recount with the extraction command recorded; recorded the dispatch-extent extraction grammar in Affected Files (all ten extents reproduce exactly under the recorded commands: identity-carrying `Context passed:` payloads for workflow cards, identity-carrying TDT context-column rows for trigger-dispatch-table cards); restated the SC-3 inventory predicate to the live-reproducing `github_issue_[a-z_]+` token sweep with documented exclusions (`gh-cli`/`gb-cli` wrapper decks as functional platform surface; `cleanup/issue-closure.md` as dispatcher-routing-only with zero direct calls) and aligned Item 3 RED to the recorded sweep. **Internal Consistency** — amended SC-1 and R-1 to scope the composite over every internal handoff whose repository resolves to an owner/repo pair, cross-referencing Edge Case 5 as the governing rule for `identity_source: local`. **Completeness** — added Definitions 8–10 defining `issues prefix`, `sc-summary.yaml` (with canonical local path `.opencode/.issues/{N}/sc-summary.yaml`), and `RED/GREEN support`; added an SC-2/SC-6 overlap clarification to Affected Files. **Implementability** — added three Dependencies rows (INDEX.md slot-118 registration, `opencode.jsonc` instructions-array tier decision, behavioral-method model-availability precondition) plus matching Item 1 GREEN registration steps and Item 5 fixture-deck lifecycle (`./tmp/issue-2319/lint-fixture/` created and removed within Item 5). No success criterion was removed or weakened. | Spec-audit cycle-2 verdict DRAFT — 4 of 11 holistic dimensions FAIL (Implementability, Internal Consistency, Completeness, Provenance) with four bidirectional findings in `tmp/issue-2319/artifacts/spec-audit/verdict.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing cycle-2 remediation mandate |
| 2026-08-26 | Spec-audit cycle-3 remediation — sole FAIL dimension HOLISTIC-7 Provenance addressed: corrected the `opencode.jsonc` `instructions`-array inventory count ten → twelve in both Named targets (Guideline registration surface bullet) and the Dependencies instructions-array row; recorded the reproducing grep command inline alongside the corrected count so the value cannot silently drift again; re-ran the grep before revision and cited it in this entry — `grep -nE '\.opencode/guidelines/[a-z0-9-]+\.md' .opencode/opencode.jsonc` returns twelve guideline entries at lines 79–90 plus `INDEX.md` at line 91, matching the independent evaluator and validator reproductions in the audit verdict. Inventory observation only: no success criterion text changed; no SC removed or weakened. | Spec-audit cycle-3 verdict DRAFT — 10 of 11 holistic dimensions PASS, sole FAIL Provenance (SPEC_OUTDATED stale ten-count under Verified-live banner at two locations), bidirectional finding in `tmp/issue-2319/artifacts/spec-audit/verdict.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing cycle-3 remediation mandate |
| 2026-08-26 | Spec-audit cycle-4 remediation — sole FAIL criterion SC-13-cost-frame addressed: inserted the two canonical cost-frame preamble lines between the `## Cost Frame` heading and the first per-SC bullet — `Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.` — satisfying cost-model-standards.md §Per-SC Cost-Frame Format and spec-structure-standards.md §10 requirement 4 (dark-prose-007 computation frame plus identity anchor ahead of the per-SC bullets). Per-SC bullet content unchanged; no success criterion removed or weakened. | Spec-audit cycle-4 verdict — 22 of 24 criteria PASS, 1 FAIL (SC-13-cost-frame, bidirectional finding SPEC_INCOMPLETE), 1 N/A, in `tmp/issue-2319/artifacts/spec-audit/verdict.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing cycle-4 remediation mandate |

---

🤖 OpenCode (deepseek-v4-flash) created
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-25 — spec-audit DRAFT remediation
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-26 — spec-audit cycle-2 remediation
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-26 — spec-audit cycle-3 remediation
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-26 — spec-audit cycle-4 remediation
