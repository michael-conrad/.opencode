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

1. **Agent deck (the deck)** — the population of skill cards (`.opencode/skills/**/SKILL.md`) and task cards (`tasks/*.md`) maintained in the `.opencode` repository. Verified live: 38 skills carry skill cards.
2. **Split-identity Context-passed contract** — any skill-card `Context passed:` payload or trigger-dispatch-table context column that carries issue identity as unbound separate fields: `issue_number` or `spec_issue_number` with repository identity either omitted (dropped-field form) or carried as separate `github.owner` / `github.repo` entries (tri-field form). Both forms instantiate the Root Cause split; both are in scope for replacement.
3. **Non-platform task card** — any `tasks/*.md` outside `.opencode/skills/issue-operations/**/tasks/`.
4. **Platform task-card set** — `.opencode/skills/issue-operations/**/tasks/*.md`, including the `platforms/github-mcp/`, `platforms/gitbucket-api/`, and `platforms/local/` subsets.
5. **Concrete bare issue reference** — `#N`, an `issue_number=N` argument to a platform API call, or prose `#N` naming a real issue, in each case without repository qualification.
6. **Derived-variable carve-out** — a locally scoped variable (for example `spec_issue_number`) assigned by parsing a qualified composite and used solely to construct artifact paths beneath the resolved issues prefix; never transmitted across a skill boundary as identity.
7. **Unconsumed issue token** — a concrete bare issue reference appearing in a card with no corresponding composite derivation or carve-out in scope; flagged by the SC-5 lint rule.

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

**Non-platform task cards carrying direct platform API calls with bare issue numbers (SC-3)** — GitHub MCP family, verified by grep sweep for `issue_number=` call arguments outside `skills/issue-operations/`:

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
- **SC-5 lint surface:** `.opencode/tools/skildeck` `lint` action, implemented in `.opencode/tools/impl/skildeck/skildeck-lint`.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | The composite form `{owner}/{repo}#NNN` is defined in `.opencode/guidelines/118-issue-reference-qualification.md` as the single self-describing issue identity token used for all internal issue-identity handoffs across the agent deck. | structural | Read `.opencode/guidelines/118-issue-reference-qualification.md`; confirm the file exists and designates the token grammar `{owner}/{repo}#NNN` as the sole internal issue identity form. |
| SC-2 | Every split-identity Context-passed contract enumerated in Affected Files carries issue identity only through the single composite field (`issue_ref: "{owner}/{repo}#NNN"`); separate `issue_number`, `spec_issue_number`, `github.owner`, and `github.repo` identity fields no longer appear in those contracts. | behavioral | Behavioral test via `bash .opencode/tests-v2/with-test-home opencode run '<dispatch scenario>'`: stderr shows the dispatched sub-agent receiving and consuming the qualified composite at handoff, and no unqualified issue token crossing a skill boundary. |
| SC-3 | Direct platform API calls carrying bare issue numbers are absent from every non-platform task card enumerated in Affected Files; such calls exist only within the platform task-card set and consume the qualified composite. | behavioral | Behavioral run scenario asserting a non-platform sub-agent routes issue reads through `issue-operations -> read-issue` rather than issuing direct `github_issue_read(issue_number=N)` calls. A static sweep excluding `skills/issue-operations/` (zero `issue_number=` hits outside the platform set) is recorded as RED/GREEN support, never as sole evidence. |
| SC-4 | A guideline rule at `.opencode/guidelines/118-issue-reference-qualification.md` defines the composite parse convention: sub-agents derive `owner`, `repo`, and `issue_number` from `{owner}/{repo}#NNN`. Permitted (derived-variable carve-out): local variables such as `spec_issue_number` used solely for artifact-path construction beneath the resolved issues prefix. Forbidden: any concrete bare issue reference to a real issue without repo qualification. | behavioral | Behavioral variant per incremental-build discipline: `bash .opencode/tests-v2/with-test-home opencode run` with a prompt carrying an unqualified reference alongside a qualified composite; stderr assertions confirm the agent derives owner/repo/number from the composite and performs no wrong-repo resolution on the bare token. |
| SC-5 | The skildeck semantic lint (`.opencode/tools/skildeck lint`, implemented in `.opencode/tools/impl/skildeck/skildeck-lint`) flags concrete bare issue references (`#N`, `issue_number=N` call arguments, unconsumed issue tokens) in skill cards and task cards while permitting the derived-variable carve-out. | behavioral | Execute `.opencode/tools/skildeck lint` against a fixture deck containing planted bare references and carved-out derived-variable sites; inspect flag output: every planted violation is listed and every carve-out site is excluded (test execution with output inspection). |
| SC-6 | Task files in the audit, issue-operations, spec-creation, and writing-plans families enumerated in Affected Files consume the composite: instructions, path construction, and API dispatch inside those files start from the qualified token rather than a bare number. | behavioral | Behavioral re-dispatch of one representative flow per family via `bash .opencode/tests-v2/with-test-home opencode run`; stderr evidence confirms task-card steps resolve paths and calls from the composite. |

Evidence-type reconciliation record: SC-2 and SC-6 are classified `behavioral` in both this document and `sc-summary.yaml` (contract-shape replacement alters agent routing at runtime). SC-4 and SC-5 are classified `behavioral` in both documents: the guideline change governs agent parsing behavior (Enforcement Test Mandate applies to guideline changes), and lint-rule verification is test execution with output inspection. SC-1 remains `structural` (definition-site existence and content).

## Requirements

1. **R-1.** The deck SHALL define `{owner}/{repo}#NNN` as the single self-describing issue identity token for all internal issue-identity handoffs. (Traces to SC-1.)
2. **R-2.** Skill-card split-identity Context-passed contracts SHALL carry issue identity only as the composite field; separate identity fields SHALL be removed from those contracts, and the consuming task files in the four enumerated families SHALL consume the composite. (Traces to SC-2, SC-6.)
3. **R-3.** Non-platform task cards SHALL NOT contain direct platform API calls carrying bare issue numbers; such calls SHALL appear only in the platform task-card set and SHALL consume the qualified composite. (Traces to SC-3.)
4. **R-4.** The guideline `.opencode/guidelines/118-issue-reference-qualification.md` SHALL define the composite parse convention, including the derived-variable carve-out and the prohibition on concrete bare issue references. (Traces to SC-4.)
5. **R-5.** The skildeck semantic lint SHALL flag concrete bare issue references in skill cards and task cards while permitting the derived-variable carve-out. (Traces to SC-5.)

## Items

### Item 1 (SC-1): Canonical composite token definition

- RED: Definition-site absence check — reading `.opencode/guidelines/118-issue-reference-qualification.md` finds no `{owner}/{repo}#NNN` designation.
- GREEN: Add the definition designating `{owner}/{repo}#NNN` as the single self-describing internal issue identity token.
- verify: Read the file; token grammar present and designated as sole internal form.
- commit: Guideline definition slice.

### Item 2 (SC-2): Composite-only Context-passed contracts

- RED: Behavioral dispatch scenario shows a sub-agent receiving split identity fields (`issue_number` without repo binding) at handoff.
- GREEN: Replace each enumerated contract with the composite field; re-run scenario showing composite consumption.
- verify: Behavioral stderr assertions per the SC-2 verification method.
- commit: Enumerated SKILL.md contract sites in one slice.

### Item 3 (SC-3): Bare-numbered direct calls removed from non-platform cards

- RED: Static sweep lists `issue_number=` hits in the 21 enumerated non-platform task files.
- GREEN: Rewrite those instruction sites to route through `issue-operations -> read-issue` consuming the composite; behavioral scenario confirms routed behavior.
- verify: Behavioral run scenario plus supporting static sweep (support only).
- commit: Non-platform task-card slice.

### Item 4 (SC-4): Composite parse convention guideline

- RED: Behavioral run with an unqualified reference shows the agent resolving repo from ambient context (wrong-repo hazard).
- GREEN: Add the parse-convention rule (derivation, carve-out, prohibition) to `.opencode/guidelines/118-issue-reference-qualification.md`; re-run shows derivation from the composite.
- verify: Behavioral stderr assertions per the SC-4 verification method.
- commit: Guideline rule slice.

### Item 5 (SC-5): skildeck bare-reference lint rule

- RED: `.opencode/tools/skildeck lint` on a fixture deck with planted bare references reports no violations.
- GREEN: Implement the rule in `.opencode/tools/impl/skildeck/skildeck-lint`; lint lists planted violations and excludes carve-out sites.
- verify: Fixture execution with output inspection per the SC-5 verification method.
- commit: Lint rule plus fixtures slice.

### Item 6 (SC-6): Consuming task files qualify identity

- RED: Representative per-family flows show path construction and API dispatch starting from bare numbers.
- GREEN: Update the enumerated task files to derive from the composite; re-run shows qualified consumption.
- verify: Behavioral re-dispatch evidence per the SC-6 verification method.
- commit: Per-family task-file slices.

## Dependencies

| Reference | Relationship | Status |
|---|---|---|
| session-init `## Repo Information` per-repo `owner`/`repo` entries | Authoritative source of the qualification values composed into `{owner}/{repo}#NNN` at handoff | Satisfied (verified this session) |
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

---

🤖 OpenCode (deepseek-v4-flash) created
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-25 — spec-audit DRAFT remediation
