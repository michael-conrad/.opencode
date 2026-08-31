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

Two additional surfaces must ship with this same effort because they are the enabling mechanisms and enforcement complements of the composite identity form:

- **Label-routing misrouting (label on ROOT vs SUBMODULE):** the `approval-gate` `apply-label` task (and 8 sibling task cards) construct `local-issues {repo}#{N}` commands with an unresolved `<repo>` placeholder and only `{issue_number, authorization_scope}` in dispatch context. Because `local-issues` mutations require the qualified form and bare reads resolve across ALL repos (current first), label writes and read-backs land on the WRONG repo (root) when the spec issue lives in the submodule (`.opencode`). This is the same root split-identity defect, manifesting at runtime dispatch.
- **local-issues composite resolution failure:** the `local-issues` tool (`.opencode/tools/local-issues`) qualifies issue references by **directory basename** (`{repo}#{N}`), not `owner/repo`. The composite `{owner}/{repo}#NNN` parses but fails resolution (`_resolve_repo_path`/`_resolve_qualified` exit with "repo not found"). Until the tool accepts the composite, no consuming sub-agent can issue a `local-issues {owner}/{repo}#{N}` command — the composite identity form is unexecutable at the tool boundary. Surface A is the enabling mechanism for SC-2/SC-6 consumption and for the label-routing fix's command construction.

## Root Cause / Motivation

Issue identity is split across three separate context fields (`issue_number`, `github.owner`, `github.repo`) that can be dropped, reordered, or resolved differently by each consuming hop. Both degenerate forms are live in the deck today (see Definitions): the tri-field form carries the three fields separately; the dropped-field form carries only the bare number and leaves repository identity entirely to re-derivation. Nothing binds the number to its repository at the point of handoff, so correctness depends on every intermediate agent re-deriving repo identity from ambient context. The change is needed now because each new skill copies the split-field contract pattern, and every copy widens the wrong-repository failure class documented in the Problem Statement citations.

The binding must hold at the **runtime dispatch boundary**, not only in persisted source. The static skildeck lint (SC-5) catches bare references that persist in card files at edit/commit time; it cannot see the runtime dispatch context a sub-agent actually receives. The label-routing defect proved that bare numbers still reach sub-agents at dispatch even when source is otherwise qualified — so a runtime pre-flight guard (SC-12) is required in addition to the lint. And the tool boundary must actually consume the composite (Surface A), or the entire convention is dead on arrival.

## Approach Chosen

Introduce a single self-describing issue identity token, `{owner}/{repo}#NNN`, that binds repository identity to the issue number at the point of handoff. Skill-card Context-passed contracts carry the composite (`issue_ref`) instead of split identity fields; sub-agents parse the composite and derive `owner`, `repo`, and `issue_number` locally for artifact-path construction, protected by the derived-variable carve-out. Non-platform task cards stop issuing direct platform API calls carrying bare issue numbers; such calls concentrate in the platform task-card sets and consume the composite. A guideline codifies the parse convention, and the `skildeck` semantic lint enforces it mechanically. Platform resolution remains the responsibility of the platform-aware issue-operations dispatcher — the token deliberately does not carry platform.

Two complementary surfaces complete the convention:

1. **Runtime pre-flight guard (SC-12):** task cards that perform `local-issues {repo}#{N}` mutations (label writes/read-backs, spec/plan label writes, git-workflow-pr reconciliation) gain a `MISSING_REPO_QUALIFIER` pre-flight BLOCK that fires when dispatch context lacks a resolvable repo qualifier. The static lint is not a runtime guard; this BLOCK closes the gap the label-routing defect exposed. Under the composite convention, the contract identity field is `issue_ref` only — the local basename consumed by `local-issues` is a *derived local variable* under SC-4's carve-out, never a standalone split field.
2. **Tool-boundary composite acceptance (SC-7..SC-11):** `local-issues` gains composite-form recognition and resolution so `{owner}/{repo}#NNN` maps to the local repo `Path` (derived from each repo's `origin` remote URL, with basename fallback). All 12 number-consuming subcommands inherit the change through the centralized parse/resolve layer. The basename form `{repo}#{N}` remains valid (backward-compatible with the closed specs #183/#1761 that established it and with `identity_source: local`).

## Alternatives Considered & Why Discarded

1. **Guideline-only discipline with bare numbers retained** — mandate that each hop re-check session-init Repo Information before resolving any `#N`. Discarded: the documented failures occurred precisely when ambient-context re-derivation failed at a hop; the alternative adds procedural memory load without structural binding, and the lessons-learned catalog states (Key Principle 3) that documented lessons without enforcement gates do not prevent recurrence.
2. **Full platform URL as the token** (`https://<host>/<owner>/<repo>/issues/<N>`). Discarded: couples the token to the platform dispatch mechanism and breaks for the `local` platform, where no remote URL exists; the Platform / Routing Note excludes platform from the token.
3. **Static lint alone as the label-routing guard.** Discarded: the skildeck lint (SC-5) flags *persisted source*; it cannot validate the *runtime dispatch context* a sub-agent receives. The label-routing defect showed a bare number reaching a sub-agent at dispatch despite the surrounding convention. A runtime `MISSING_REPO_QUALIFIER` pre-flight BLOCK (SC-12) is the only guard that fires at the point of dispatch.
4. **Requiring `local-issues` to consume only the composite, dropping the basename form.** Discarded: the basename `{repo}#{N}` is the established `local-issues` qualifier (closed specs #183, #1761) and the only valid identity under `identity_source: local` (no remote, Edge Case 5). Breaking it would break existing call sites and fabricate the local identity. The tool accepts both forms, composite as primary, basename retained.

## Key Design Decisions

1. **The composite binds repository identity only, never platform.** Tradeoff: the token stays valid across github/gitbucket/local routing, at the cost of requiring the platform-aware dispatcher to resolve platform separately from the repo.
2. **Derived-variable carve-out instead of an absolute prohibition on local number variables.** Tradeoff: preserves ergonomic artifact-path construction inside sub-agents, at the cost of requiring the SC-5 lint rule to police the carve-out boundary.
3. **Replacement happens at the existing Context-passed boundary, not through a new transport layer.** Tradeoff: drop-in compatibility for every current dispatch site, at the cost of touching every enumerated contract exactly once.
4. **`local-issues` resolves `owner/repo` from git `origin` remote URLs, not session-init injection.** Tradeoff: self-contained and robust (the tool already derives owner/repo from remotes in `_sync_file_in_worktree`), at the cost of requiring a remote to exist — which is exactly the `identity_source: local` no-composite boundary (Edge Case 5). Under `local` the basename form remains the qualifier.
5. **`repo_name` is a derived local basename, not a contract/dispatch identity field.** Tradeoff: preserves the SC-2 composite-only contract shape while giving the sub-agent the basename it needs to construct `local-issues {repo}#{N}` commands, at the cost of requiring sub-agents to derive the basename from the composite or from the pre-flight guard's resolved repo.
6. **The runtime guard is a task-card Entry-Criteria BLOCK, not tool-level or orchestrator-level.** Tradeoff: it fires at the exact dispatch surface where bare numbers historically reached sub-agents, at the cost of being distributed across every mutating task card that the orchestrator must keep BLOCK-consistent (9 mutating cards + 1 conditional).

## User Intent / Original Prompt

The spec originated in the recurring deck-wide failure pattern captured in the Problem Statement citations: systemic cross-repository contamination (session-2026-06-20, issue 1308 incident) and the standing "Wrong repo for spec creation" catalog entry. The motivating request: qualify every issue reference as `owner/repo#NNN` across skill cards, task cards, guidelines, and the skildeck lint so repository identity can no longer be separated from the issue number. This revision adds the two enabling/complementary deliverable surfaces — the `local-issues` composite acceptance (without which the composite never reaches the tool) and the label-routing runtime pre-flight guard (without which a bare number still lands labels on the wrong repo at dispatch) — so all three changes ship as one authoritative spec.

## Not Included

- **Platform dispatch mechanism changes** — the platform-aware issue-operations dispatcher keeps full responsibility for platform selection; the composite deliberately omits platform, so no dispatch-mechanism code changes.
- **Platform sub-skill routing logic changes** — the routing internals of `platforms/github-mcp/`, `platforms/gitbucket-api/`, and `platforms/local/` are untouched; only the identity form crossing into them changes.
- **`local-issues` full-rewrite work (issue #985)** — scoped independently; #985 is a PLAN, not a spec, and the composite acceptance is a tightly-scoped enabling slice, not a rewrite.
- **`.gitmodules` repo-discovery change (issue #2093)** — already implemented in the current tool source (`_discover_all_repos`); the composite resolution builds on it, it does not change it.

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
11. **Composite form / composite identity** — the grammar `{owner}/{repo}#NNN` (two slash-separated segments before `#`) recognized by the deck's identity convention; distinct from the `local-issues` basename qualifier `{repo}#{N}` (Definition 12). The composite is the SC-2 contract identity; the basename is a derived local variable (SC-4 carve-out) consumed by `local-issues`.
12. **Basename qualifier** — the `local-issues` local issue-tracker qualifier `{repo}#{N}` where `{repo}` is the directory basename (root = `os.getcwd()` name; child = `.gitmodules` `path` basename). Source of truth for the basename is the directory name, NOT necessarily `github.repo`. Under the composite convention this is a derived local variable for command construction, not a contract identity field. Under `identity_source: local` (no remote) it is the only valid qualifier (Edge Case 5).
13. **Number-consuming subcommand** — any of the 12 `local-issues` subcommands whose operation targets an issue by number and therefore routes through `_parse_qualified` / `_require_qualified` / `_resolve_qualified`: `create`, `read`, `read-comments`, `read-labels`, `read-sub-issues`, `update`, `comment`, `close`, `delete`, `link`, `renumber`, `promote`. The five subcommands that do not consume a number (`search`, `list`, `init`, `sync`, `sync-file`) are out of Surface A scope.
14. **Origin-URL derivation** — the mapping of a local repo `Path` to an `(owner, repo)` pair by parsing that repo's `origin` remote URL (`git remote get-url origin` → `github.com/<owner>/<repo>`). The tool already does this in `_sync_file_in_worktree` for URL construction; Surface A reuses the mechanism to resolve composite `owner/repo` → local `Path`. When no remote exists (no `origin` URL), no `(owner, repo)` pair is derived — the `identity_source: local` boundary.
15. **MISSING_REPO_QUALIFIER** — the symbolic BLOCK reason a task card returns (`status: BLOCKED`) when a `local-issues {repo}#{N}` mutation (or a single-repo-target read) is required but dispatch context lacks a resolvable repo qualifier. The canonical reason string: `MISSING_REPO_QUALIFIER: local-issues mutations require {repo}#{N}; repo_name was not provided in dispatch context.`

## Affected Files

Glob targets (all verified to resolve live):

- `.opencode/skills/audit/tasks/*.md`
- `.opencode/skills/issue-operations*/**/SKILL.md` and `tasks/*.md`
- `.opencode/skills/spec-creation/**/tasks/*.md`
- `.opencode/skills/writing-plans/**/tasks/*.md`
- `.opencode/guidelines/*.md`
- `.opencode/tools/skildeck`
- `.opencode/tools/local-issues` (Surface A — new)

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

**Surface A — `local-issues` composite acceptance (`SC-7..SC-11`):**

Target: `.opencode/tools/local-issues` (1992 lines). The change is centralized in `_parse_qualified` plus the resolution helpers `_resolve_repo_path`, `_resolve_qualified`, `_resolve_and_validate_repo`; all 12 number-consuming subcommands inherit it without per-command edits. Live-verified current behavior (analysis artifact `tmp/local-issues-composite-analysis.md`):

- `_parse_qualified` (lines 982–987): regex `^(.+?)#(\d+)$` returns `(repo_name, number)`. A composite `michael-conrad/.opencode#2319` parses as `repo_name="michael-conrad/.opencode"`, number=2319 — the slash is silently captured into the repo_name group; it does NOT error but produces a repo_name no resolver recognizes.
- `_require_qualified` (lines 990–997): mutations error on bare `N` with `{repo}#{N}` message.
- `_resolve_qualified` (lines 1026–1053): matches `repo_name_val` against `current_name` (cwd basename) then each child's `.name` (basename). A composite fails the `child.name == repo_name_val` comparison (`.opencode` ≠ `michael-conrad/.opencode`) and exits with "repo not found".
- `_resolve_repo_path` (lines 1000–1013) and `_resolve_repo_name` (lines 1374–1375): basename-only matching.
- `_print_available_repos` (lines 1378–1385): prints each repo's basename and the message "Available qualifiers (use name#N format)".
- `_discover_all_repos` (lines 204–229): root + child repos parsed from `.gitmodules` `path` entries; already implements `.gitmodules`-scoped discovery (spec #2093).
- The tool does NOT read session-init Repo Information; it derives owner/repo from git remote URLs (already does in `_sync_file_in_worktree`, lines 1702–1708). Surface A reuses that origin-URL derivation for composite resolution.

**Number-consuming subcommands (SC-10)** — all route through `_parse_qualified`/`_require_qualified`/`_resolve_qualified`: `create`, `read`, `read-comments`, `read-labels`, `read-sub-issues`, `update`, `comment`, `close`, `delete`, `link`, `renumber`, `promote` (12 of 17). The five non-number-consuming subcommands (`search`, `list`, `init`, `sync`, `sync-file`) are out of scope.

**Surface B — task cards needing the `MISSING_REPO_QUALIFIER` pre-flight BLOCK (`SC-12`):**

Every task card below performs a `local-issues {repo}#{N}` mutation (label write / read-back / issue update) via an unresolved `<repo>` placeholder in dispatch context. Source: `tmp/label-routing-contract-analysis.md` and `tmp/label-routing-spec-review.md`. The BLOCK fires when a task card receives a bare issue number without a resolvable repo qualifier.

| Task card | Operation w/ `{repo}#{N}` | Pre-flight BLOCK |
|---|---|---|
| `.opencode/skills/approval-gate/tasks/apply-label.md` | LOCAL_MUT `update <repo>#<N> --labels approved-for-{scope}` (L17); LOCAL_READ `read-labels --number <repo>#<N>` (L24) | YES — PRIMARY bug site |
| `.opencode/skills/approval-gate/tasks/resolve-scope.md` | none directly; must resolve repo from session-init for downstream apply-label | Conditional — BLOCK only if a named repo cannot be resolved to a known qualifier |
| `.opencode/skills/issue-operations-core/tasks/update-issue.md` | LOCAL (via `platforms/local/update.md`) | YES |
| `.opencode/skills/issue-operations-core/tasks/read-labels.md` | LOCAL_READ `read-labels --number <N>` (L25, currently bare) | YES (when a single repo is required) |
| `.opencode/skills/issue-operations-core/tasks/close.md` | LOCAL_MUT (via `platforms/local/close.md`) | YES |
| `.opencode/skills/spec-creation/tasks/create.md` | LOCAL_MUT `update <repo>#<N> --labels needs-approval,spec-draft` (L82); `read-labels --number <repo>#<N>` (L86) | YES |
| `.opencode/skills/issue-review/tasks/analyze-and-spec.md` | LOCAL_MUT `update <repo>#<N> --labels spec-draft` (L151); `read-labels --number <repo>#<N>` (L155) | YES |
| `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | LOCAL_READ `read --number <repo>#<N>` (L82); LOCAL_MUT `update --number <repo>#<N> --labels approved-for-pr` (L84) | YES |
| `.opencode/skills/git-workflow-pr/tasks/completion.md` | LOCAL_READ `read --number <repo>#<N>` (L33); LOCAL_MUT `update --number <repo>#<N> --labels approved-for-pr` (L35) | YES |
| `.opencode/skills/writing-plans/tasks/create.md` | LOCAL_MUT `update <repo>#<N> --labels spec-cleared` (L64) | YES |

Skill-card dispatch-context sites that must pass the resolved repo so the pre-flight does not fire (from the SC-12 contract analysis): `.opencode/skills/approval-gate/SKILL.md` (TDT L38-39, Invocation L51-52, Standard context L61), `.opencode/skills/issue-operations-core/SKILL.md` (Standard context), `.opencode/skills/issue-operations/SKILL.md` (Standard context L129), `.opencode/skills/spec-creation/SKILL.md` (create/reconcile-push), `.opencode/skills/writing-plans/SKILL.md` (create), `.opencode/skills/git-workflow-pr/SKILL.md` (pr-creation, completion), `.opencode/skills/issue-review/SKILL.md`.

**Named targets:**

- **SC-4 guideline target:** `.opencode/guidelines/118-issue-reference-qualification.md` (new file; the 118 numbering slot is unused in the guidelines index as of this revision).
- **Guideline registration surface:** `.opencode/guidelines/INDEX.md` slot-118 row plus the `.opencode/opencode.jsonc` `instructions`-array tier decision (see Dependencies). Verified live this revision: the index jumps from `117-session-trigger-behavior.md` to `130-authority-source.md` with no 118 entry, and the instructions array currently loads twelve guideline files plus `INDEX.md` (reproducing command recorded against silent drift: `grep -nE '\.opencode/guidelines/[a-z0-9-]+\.md' .opencode/opencode.jsonc`; twelve entries reproduce at lines 79–90, with `INDEX.md` at line 91). Registration is part of Item 1 GREEN so the created guideline actually loads into agent sessions.
- **SC-5 lint surface:** `.opencode/tools/skildeck` `lint` action, implemented in `.opencode/tools/impl/skildeck/skildeck-lint`.
- **SC-7..SC-11 tool surface:** `.opencode/tools/local-issues` — `_parse_qualified`, `_resolve_repo_path`, `_resolve_qualified`, `_resolve_and_validate_repo`, `_print_available_repos`, and the origin-URL derivation helper.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | The composite form `{owner}/{repo}#NNN` is defined in `.opencode/guidelines/118-issue-reference-qualification.md` as the single self-describing issue identity token used for every internal issue-identity handoff whose repository resolves to an owner/repo pair; under `identity_source: local` no owner/repo pair exists, and Edge Case 5 governs the alternative directory-scoped issues-prefix identity form. | structural | Read `.opencode/guidelines/118-issue-reference-qualification.md`; confirm the file exists and designates the token grammar `{owner}/{repo}#NNN` as the sole internal issue identity form for owner/repo-resolvable handoffs, with the local-platform alternative deferred to Edge Case 5. |
| SC-2 | Every split-identity Context-passed contract enumerated in Affected Files carries issue identity only through the single composite field (`issue_ref: "{owner}/{repo}#NNN"`); separate `issue_number`, `spec_issue_number`, `github.owner`, and `github.repo` identity fields no longer appear in those contracts. | behavioral | Behavioral test via `bash .opencode/tests-v2/with-test-home opencode run '<dispatch scenario>'`: stderr shows the dispatched sub-agent receiving and consuming the qualified composite at handoff, and no unqualified issue token crossing a skill boundary. |
| SC-3 | Direct platform API calls carrying bare issue numbers are absent from every non-platform task card enumerated in Affected Files; such calls exist only within the platform task-card set and consume the qualified composite. | behavioral | Behavioral run scenario asserting a non-platform sub-agent routes issue reads through `issue-operations -> read-issue` rather than issuing direct `github_issue_read(issue_number=N)` calls. A static sweep excluding `skills/issue-operations/` (zero `issue_number=` hits outside the platform set) is recorded as RED/GREEN support, never as sole evidence. |
| SC-4 | A guideline rule at `.opencode/guidelines/118-issue-reference-qualification.md` defines the composite parse convention: sub-agents derive `owner`, `repo`, and `issue_number` from `{owner}/{repo}#NNN`. Permitted (derived-variable carve-out): local variables such as `spec_issue_number` used solely for artifact-path construction beneath the resolved issues prefix, and a local basename variable used solely to construct `local-issues {repo}#{N}` commands. Forbidden: any concrete bare issue reference to a real issue without repo qualification, and any split identity field transmitted as a contract/dispatch field. | behavioral | Behavioral variant per incremental-build discipline: `bash .opencode/tests-v2/with-test-home opencode run` with a prompt carrying an unqualified reference alongside a qualified composite; stderr assertions confirm the agent derives owner/repo/number from the composite (and the local basename for `local-issues` command construction) and performs no wrong-repo resolution on the bare token. |
| SC-5 | The skildeck semantic lint (`.opencode/tools/skildeck lint`, implemented in `.opencode/tools/impl/skildeck/skildeck-lint`) flags concrete bare issue references (`#N`, `issue_number=N` call arguments, unconsumed issue tokens) in skill cards and task cards while permitting the derived-variable carve-out. | behavioral | Execute `.opencode/tools/skildeck lint` against a fixture deck containing planted bare references and carved-out derived-variable sites; inspect flag output: every planted violation is listed and every carve-out site is excluded (test execution with output inspection). |
| SC-6 | Task files in the audit, issue-operations, spec-creation, and writing-plans families enumerated in Affected Files consume the composite: instructions, path construction, and API dispatch inside those files start from the qualified token rather than a bare number. | behavioral | Behavioral re-dispatch of one representative flow per family via `bash .opencode/tests-v2/with-test-home opencode run`; stderr evidence confirms task-card steps resolve paths and calls from the composite. |
| SC-7 | `_parse_qualified` in `.opencode/tools/local-issues` recognizes the composite form `{owner}/{repo}#NNN` (two slash-separated segments before `#`) and returns a structured `(owner, repo, number)` triple, while retaining the basename `{repo}#N` (single segment) and bare `N` forms. | behavioral | Behaviorally exercise `_parse_qualified` (via `local-issues` command dispatch) with composite, basename, and bare inputs through `.opencode/tools/local-issues`; confirm the composite produces a resolvable owner/repo/number triple and the basename and bare forms retain their current behavior. |
| SC-8 | A new resolution path in `.opencode/tools/local-issues` maps `owner/repo` → local repo `Path` by deriving owner/repo from each repo's `origin` remote URL (parsing `github.com/<owner>/<repo>`, matching the composite's `repo` slug against the remote-derived slug), falling back to basename matching. `_resolve_repo_path`, `_resolve_qualified`, and `_resolve_and_validate_repo` all route through this new path. | behavioral | Behaviorally dispatch a `local-issues` command with a composite targeting the submodule (e.g. `read --number michael-conrad/.opencode#N`) and the root; confirm both resolve to the correct local `Path` and operation executes on the intended repo, and that an unknown `owner/repo` fails with the established "repo not found" behavior. |
| SC-9 | Under `identity_source: local` (no remote), the composite form in `.opencode/tools/local-issues` hard-fails — no fabricated owner/repo mapping — while the basename form remains the valid qualifier. | behavioral | In a local-only repo (no `origin` remote), dispatch a composite `{owner}/{repo}#N` and the basename `{repo}#N`; confirm the composite fails (no value is fabricated) and the basename operates normally, in alignment with Edge Case 5. |
| SC-10 | All 12 number-consuming subcommands of `local-issues` (create, read, read-comments, read-labels, read-sub-issues, update, comment, close, delete, link, renumber, promote) accept the composite form via the centralized parse/resolve layer, without per-command modifications. | behavioral | Behaviorally exercise each of the 12 subcommands with a composite number through `.opencode/tools/local-issues`; confirm each resolves and operates on the intended repo. The five non-number-consuming subcommands are unaffected. |
| SC-11 | `_print_available_repos` and the `local-issues` error messages document both the composite `{owner}/{repo}#NNN` and basename `{repo}#N` qualifier forms. | structural | Read `_print_available_repos` and the `_require_qualified` / `_resolve_qualified` error-message strings; confirm the available-qualifiers output and error text list both the composite and basename forms. |
| SC-12 | Each task card enumerated in Affected Files that performs a `local-issues {repo}#{N}` mutation (or a single-repo-target read) carries a pre-flight Entry-Criteria BLOCK returning `status: BLOCKED` with reason `MISSING_REPO_QUALIFIER` when dispatch context lacks the resolved repo qualifier, and does not emit an unqualified `local-issues {repo}#{N}` mutation. The contract identity field remains `issue_ref` only; the local basename is a derived local variable under the SC-4 carve-out. | behavioral | Behavioral run scenario dispatching a label-write task (`apply-label`, `spec-creation/create`, `writing-plans/create`, or a git-workflow-pr reconciliation task) without a resolved repo qualifier; stderr assertions confirm the task card returns BLOCKED with `MISSING_REPO_QUALIFIER` before issuing any `local-issues` mutation, and that with a resolved repo the mutation targets the intended repo. |

Evidence-type reconciliation record: SC-2 and SC-6 are classified `behavioral` in both this document and `sc-summary.yaml` (contract-shape replacement alters agent routing at runtime). SC-4 and SC-5 are classified `behavioral` in both documents: the guideline change governs agent parsing behavior (Enforcement Test Mandate applies to guideline changes), and lint-rule verification is test execution with output inspection. SC-1 remains `structural` (definition-site existence and content). The three Surface-A surfaces appended for this revision — SC-7, SC-8, SC-9, SC-10, SC-12 — are classified `behavioral` (they alter tool dispatch resolution and agent routing at runtime); SC-11 remains `structural` (help/output documentation content only). SC-12 is `behavioral` (a runtime guard fires or withholds a mutation).

## Requirements

1. **R-1.** The deck SHALL define `{owner}/{repo}#NNN` as the single self-describing issue identity token for every internal issue-identity handoff whose repository resolves to an owner/repo pair; Edge Case 5 governs the identity form used when no pair exists (`identity_source: local`). (Traces to SC-1.)
2. **R-2.** Skill-card split-identity Context-passed contracts SHALL carry issue identity only as the composite field; separate identity fields SHALL be removed from those contracts, and the consuming task files in the four enumerated families SHALL consume the composite. (Traces to SC-2, SC-6.)
3. **R-3.** Non-platform task cards SHALL NOT contain direct platform API calls carrying bare issue numbers; such calls SHALL appear only in the platform task-card set and SHALL consume the qualified composite. (Traces to SC-3.)
4. **R-4.** The guideline `.opencode/guidelines/118-issue-reference-qualification.md` SHALL define the composite parse convention, including the derived-variable carve-out (which permits a local basename for `local-issues` command construction) and the prohibition on concrete bare issue references and split contract identity fields. (Traces to SC-4.)
5. **R-5.** The skildeck semantic lint SHALL flag concrete bare issue references in skill cards and task cards while permitting the derived-variable carve-out. (Traces to SC-5.)
6. **R-6.** The `local-issues` tool SHALL accept the composite form `{owner}/{repo}#NNN` — parsing it into a structured `(owner, repo, number)` triple, resolving owner/repo to the local repo `Path` via origin-URL derivation with basename fallback, routing all 12 number-consuming subcommands through the centralized parse/resolve layer, and retaining the basename and bare forms — while hard-failing on the composite under `identity_source: local` where no owner/repo mapping exists (Edge Case 5). (Traces to SC-7, SC-8, SC-9, SC-10.)
7. **R-7.** The `local-issues` help/output (`_print_available_repos`) and error messages SHALL document both the composite and basename qualifier forms. (Traces to SC-11.)
8. **R-8.** Every task card that performs a `local-issues {repo}#{N}` mutation (or a single-repo-target read) SHALL carry a pre-flight `MISSING_REPO_QUALIFIER` BLOCK that returns `status: BLOCKED` when dispatch context lacks the resolved repo qualifier, and SHALL emit only qualified commands; the contract identity field remains the composite `issue_ref`, with the local basename derived locally under the SC-4 carve-out. (Traces to SC-12.)

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
- GREEN: Add the parse-convention rule (derivation, carve-out, prohibition) to `.opencode/guidelines/118-issue-reference-qualification.md`; re-run shows derivation from the composite. Include the local-basename derivation for `local-issues` command construction as an explicit carve-out case.
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

### Item 7 (SC-7): `_parse_qualified` composite recognition

- RED: Behaviorally dispatch `local-issues` with a composite `{owner}/{repo}#N`; the tool resolves to "repo not found" (the basename-only parse failure).
- GREEN: Extend `_parse_qualified` to detect the composite form (two slash-separated segments before `#`) and return a structured `(owner, repo, number)` triple, retaining basename `{repo}#N` and bare `N` forms; re-run shows the composite is parsed structurally.
- verify: Behavioral exercise per the SC-7 verification method.
- commit: Parse-layer slice.

### Item 8 (SC-8): owner/repo → path resolution from origin-URL derivation

- RED: Behaviorally dispatch a composite read targeting the submodule; it fails resolution ("repo not found").
- GREEN: Add the resolution path deriving owner/repo from each repo's `origin` remote URL (with basename fallback) and route `_resolve_repo_path`, `_resolve_qualified`, and `_resolve_and_validate_repo` through it; re-run shows the composite resolves to the correct local `Path` and the operation executes on the intended repo.
- verify: Behavioral exercise per the SC-8 verification method.
- commit: Resolve-layer slice.

### Item 9 (SC-9): local-platform no-composite boundary

- RED: In a local-only repo (no `origin` remote), a composite `{owner}/{repo}#N` either fabricates a mapping or is unhandled.
- GREEN: Under `identity_source: local` (no remote-derived owner/repo), the composite form hard-fails (no fabrication) while the basename form remains valid; re-run confirms the hard fail and basename operation, in alignment with Edge Case 5.
- verify: Behavioral exercise per the SC-9 verification method.
- commit: Local-boundary guard slice.

### Item 10 (SC-10): All 12 subcommands inherit composite acceptance

- RED: Behaviorally dispatch a composite through a subcommand that still fails resolution.
- GREEN: Confirm all 12 number-consuming subcommands route through the centralized parse/resolve layer and each accepts the composite; re-run exercises all 12 with composite numbers.
- verify: Behavioral exercise per the SC-10 verification method.
- commit: Subcommand-inheritance verification slice.

### Item 11 (SC-11): Help/output and error-message documentation

- RED: Read `_print_available_repos` and the qualifier error messages; they document only the basename form.
- GREEN: Update `_print_available_repos` output and the `_require_qualified`/`_resolve_qualified` error strings to document both the composite and basename forms.
- verify: Read the output and error strings per the SC-11 verification method.
- commit: Help/output documentation slice.

### Item 12 (SC-12): `MISSING_REPO_QUALIFIER` runtime pre-flight BLOCKs

- RED: Behavioral dispatch of a label-write task (`apply-label`, `spec-creation/create`, `writing-plans/create`, or a git-workflow-pr reconciliation task) without a resolved repo qualifier proceeds and mislabels the root repo (the label-routing defect).
- GREEN: Add the `MISSING_REPO_QUALIFIER` pre-flight Entry-Criteria BLOCK to each mutating task card enumerated in Affected Files (apply-label, update-issue, read-labels, close, spec-creation/create, issue-review/analyze-and-spec, git-workflow-pr/pr-creation, git-workflow-pr/completion, writing-plans/create, plus resolve-scope conditional), ensuring the contract identity field remains `issue_ref` with the basename derived locally; align the skill-card dispatch-context sites to pass the resolved repo so the BLOCK does not fire spuriously; re-run shows BLOCKED-before-mutation on missing qualifier and correct-repo mutation when resolved.
- verify: Behavioral run scenario per the SC-12 verification method.
- commit: Per-task-card BLOCK + skill-card dispatch-context slices.

## Dependencies

| Reference | Relationship | Status |
|---|---|---|
| session-init `## Repo Information` per-repo `owner`/`repo` entries | Authoritative source of the qualification values composed into `{owner}/{repo}#NNN` at handoff | Satisfied (verified this session) |
| `.opencode/guidelines/INDEX.md` slot-118 entry | Registration step making `guidelines/118-issue-reference-qualification.md` discoverable through progressive disclosure; GREEN-phase step of Item 1 — without it SC-4 behavioral verification cannot pass because the guideline never loads into agent sessions | Required (verified absent live this revision: index jumps 117 → 130 with no 118 row) |
| `.opencode/opencode.jsonc` `instructions` array | Tier-assignment decision for `guidelines/118-issue-reference-qualification.md`: Tier 1 upfront load (array entry alongside the twelve currently loaded guidelines plus INDEX.md) or Tier 2 progressive disclosure (INDEX-only); decision recorded during Item 1 GREEN | Decision required at implementation (verified live this revision: twelve guideline entries at lines 79–90 per the reproducing grep recorded in Affected Files) |
| Local model availability through `.opencode/tests-v2/with-test-home` | Runtime precondition for every behavioral verification method in this spec (SC-2, SC-3, SC-4, SC-6, SC-7, SC-8, SC-9, SC-10, SC-12): when no behavioral model is available those methods report FAIL per test-integrity law — substitution with static checks is prohibited | Precondition (harness verified present; model liveness checked at each run) |
| `.opencode/tools/skildeck` `lint` action and `.opencode/tools/impl/skildeck/skildeck-lint` | Extension surface for SC-5 | Satisfied (verified via live `--help` execution) |
| `.opencode/tests-v2/with-test-home` | Mandatory isolation harness for every behavioral verification method in this spec | Satisfied (verified present) |
| `.opencode/reference/spec-structure-standards.md` | Structural template governing this document's required sections | Satisfied (read this revision) |
| `.opencode/tools/local-issues` — `_parse_qualified`, `_resolve_repo_path`, `_resolve_qualified`, `_resolve_and_validate_repo`, `_print_available_repos`, `_discover_all_repos` | Tool-boundary extension surface for SC-7..SC-11 | Satisfied (analyzed live this revision) |
| Git `origin` remote URL on every repo | Source for origin-URL derivation of `(owner, repo)` → local `Path` in SC-8; absent under `identity_source: local`, which is exactly the SC-9 / Edge Case 5 no-composite boundary | Satisfied (present for root and submodule; absent in local-only mode by definition) |
| `.gitmodules`-scoped repo discovery (in `_discover_all_repos`) | Prerequisite mapping for basename fallback resolution in SC-8; already implemented in current tool source (spec #2093) | Satisfied (verified in tool source this revision) |
| Task-card Entry-Criteria BLOCK mechanism (`MISSING_*` / `LOCAL_*` / `UNKNOWN_*` reason family) | Extension surface for the SC-12 `MISSING_REPO_QUALIFIER` runtime guard | Satisfied (canonical pattern in use across the deck) |
| `.opencode/guidelines/118-issue-reference-qualification.md` SC-4 carve-out | Grants the local-basename derivation used by SC-12 task cards to construct `local-issues {repo}#{N}` commands; the contract identity field remains `issue_ref` (SC-2) | Required (specified by SC-1/SC-4; implemented in Item 4) |

## Traceability

| Requirement | SC(s) | Phase(s) |
|---|---|---|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2, SC-6 | Phase 2, Phase 6 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 4 |
| R-5 | SC-5 | Phase 5 |
| R-6 | SC-7, SC-8, SC-9, SC-10 | Phase 7, Phase 8, Phase 9, Phase 10 |
| R-7 | SC-11 | Phase 11 |
| R-8 | SC-12 | Phase 12 |

Phase numbering matches Item numbering 1 through 12 and the `plan_item` mapping in `sc-summary.yaml`. Every requirement traces to at least one SC; every SC traces to at least one requirement; every SC traces back to the Root Cause split-identity mechanism named in the preamble. R-6 (tool acceptance) is the enabling mechanism for SC-2/SC-6 consumption and for the SC-12 command construction; SC-12 (runtime guard) is the enforcement complement of the static lint (SC-5) at the dispatch boundary.

## Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| Remote issue body, issue 2319 (Out-of-scope mirror source) | doc | https://github.com/michael-conrad/.opencode/issues/2319 | Live `gh api` fetch during this revision |
| Lessons-learned catalog, session 2026-06-20 | doc | `.opencode/.issues/lessons-learned/session-2026-06-20/README.md` | Read during this revision (Problem Statement provenance) |
| `.opencode/AGENTS.md` Testing Lessons Learned, "Wrong repo for spec creation" | doc | `.opencode/AGENTS.md` | Read during this revision |
| skildeck CLI actions and modules | code | `.opencode/tools/skildeck`, `.opencode/tools/impl/skildeck/skildeck-lint` | Live `--help` execution and directory listing |
| Contract, task-file, and lint-surface inventories | code | Paths enumerated under Affected Files | Live grep sweeps with counts recorded inline |
| local-issues composite analysis (Surface A) | code | `.opencode/tools/local-issues`; `tmp/local-issues-composite-analysis.md` | Analyzed live this revision (parse/resolve helpers, 12-of-17 subcommands, origin-URL derivation) |
| Label-routing contract analysis (Surface B) | code | `.opencode/skills/approval-gate/tasks/apply-label.md` and sibling task cards; `tmp/label-routing-contract-analysis.md` | Analyzed live this revision (result contracts, pre-flight BLOCK requirements, dispatch-context sites) |
| Label-routing spec re-analysis (partially superseding) | doc | `tmp/label-routing-spec-review.md` | Read this revision (composite reframing of `repo_name` under SC-2/SC-4) |

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
- **SC-7:** Extending `_parse_qualified` to recognize the composite costs one parse-layer change — consequence: the composite becomes a structurally valid tool input instead of a silent mis-parse. Skipping costs every composite command resolving to the wrong or no repository — consequence: the entire convention is unexecutable at the tool boundary.
- **SC-8:** Adding the owner/repo → path resolution path costs one resolve-layer change plus origin-URL derivation reuse — consequence: the composite reaches the intended local repo. Skipping costs every composite read/mutation failing "repo not found" or silently hitting the wrong repo — consequence: consuming tasks cannot issue qualified commands, defeating SC-2/SC-6.
- **SC-9:** Enforcing the no-composite boundary under `identity_source: local` costs one guard — consequence: no fabricated owner/repo mapping ever enters the local tool state. Skipping costs silent fabrication of repository identity where none exists — consequence: an integrity defect (Edge Case 5) that corrupts local issue routing.
- **SC-10:** Confirming all 12 subcommands inherit composite acceptance costs one inheritance-verification pass — consequence: every number-consuming operation is composite-capable through the centralized layer. Skipping costs subcommands that still reject the composite — consequence: a fragmented tool where only some operations honor the convention.
- **SC-11:** Documenting both forms in help/output costs one output pass — consequence: users and agents see the accepted composite form. Skipping costs stale basename-only documentation — consequence: agents infer the composite is unsupported and fall back to bare/basename forms.
- **SC-12:** Adding the runtime pre-flight BLOCKs costs one dispatch-guard pass over ten task cards plus skill-card dispatch-context alignment — consequence: a bare number can no longer reach a `local-issues` mutation. Skipping costs the exact wrong-repo mislabeling the label-routing defect documented — consequence: the static lint (SC-5) passes while the runtime still misroutes labels.

## Edge Cases

1. **Input boundary — token grammar:** Accepted form is `{owner}/{repo}#{digits}`. Bare digits without a repository prefix fail validation at the consumption point. Expected behavior: hard fail identifying the unqualified token and its source contract. Resolution: the dispatching orchestrator re-emits a qualified composite. Under the SC-12 runtime guard, the task card returns BLOCKED (`MISSING_REPO_QUALIFIER`) before any mutation.
2. **Input boundary — degenerate numbers:** Issue number `0`, negative numbers, or non-digit payloads fail validation. Expected behavior: rejection before any path construction or API call.
3. **State transition — renumbering:** Local renumber operations change `N` after composites referencing the old number were emitted. Expected behavior: resolution of a stale composite hard-fails as a dangling reference. Resolution: re-issue the composite from current registry state through the issue tooling; silent rewriting of historical artifacts is prohibited.
4. **Failure mode — unknown repository:** A composite names a repository absent from session-init Repo Information. Expected behavior: hard fail requesting developer guidance; guessing a repository mapping is prohibited by repo-routing law. In `local-issues` (SC-8), an unknown `owner/repo` fails with the established "repo not found" behavior.
5. **Failure mode — local platform:** Under `identity_source: local` there is no remote, so no `owner/repo` pair exists. Expected behavior: composite construction MUST NOT fabricate values; issue identity remains directory-scoped beneath the issues prefix and routes through the `platforms/local/` set. Resolution: the orchestrator supplies the local issues-prefix path identity instead of an owner/repo composite. In `local-issues` (SC-9), no remote-derived `(owner, repo)` mapping exists, so the composite form hard-fails and the basename form `{repo}#{N}` remains the valid qualifier — the basename IS the Edge Case 5 directory-scoped identity.
6. **Concurrency — parallel derivations:** Two sub-agents parse the same composite concurrently. Expected behavior: derivation is a pure read producing independent local variables; no shared mutable state exists, so no race is possible.
7. **Recovery — lint false positive:** A flagged reference that the author judges meaningful. Expected behavior: the flag stands until the reference is rewritten as a qualified composite; silencing or weakening the lint rule to clear a flag is prohibited (test-integrity law). Resolution: convert the reference to the composite form.
8. **Sub-issue references:** Nested sub-issue numbers follow the identical qualification rule; each sub-issue link carries its own composite.
9. **Surface A — `local-issues` token grammar:** Accepted `local-issues` input is the composite `{owner}/{repo}#NNN` (two slash-separated segments before `#`), the basename `{repo}#N` (single segment), or bare `N`. A two-segment `owner/repo` that does not match any repo's origin-URL-derived pair (or basename) fails with the established "repo not found" behavior; no guessing. Under `identity_source: local` the composite (two-segment) form hard-fails per Edge Case 5 (SC-9).
10. **Surface A — no `origin` remote for a child repo:** If a child repo lacks an `origin` remote, its `(owner, repo)` pair cannot be origin-derived, so a composite targeting it fails; its basename form still resolves (SC-8, SC-9). No fabricated mapping.
11. **Surface A — `repo` slug vs directory basename mismatch:** The composite's `repo` slug (e.g. `opencode`) MAY differ from the directory basename (e.g. `.opencode`). SC-8 matches the composite `repo` slug against the origin-URL-derived remote slug, NOT the basename — so the composite resolves correctly regardless of the directory name. The basename remains a separate (derived) qualifier.
12. **Surface B — read vs mutation BLOCK distinction:** `local-issues` reads accept bare `N` (resolving across all repos, current-first) without error, but return the WRONG repo's data when the intent is a single repo. SC-12 BLOCKs a bare-numbered read only when a single-repo target is semantically required (e.g. `apply-label`'s read-back verification); it BLOCKs mutations unconditionally because `_require_qualified` hard-errors on bare. This distinction is encoded per task card.
13. **Surface B — spurious BLOCK on resolved repo:** A skill card that already passes a resolvable repo must not trigger `MISSING_REPO_QUALIFIER`. The SC-12 BLOCK fires only when dispatch context lacks a resolvable qualifier; the skill-card dispatch-context alignment (approval-gate, issue-operations, issue-operations-core, spec-creation, writing-plans, git-workflow-pr, issue-review) ensures the resolved repo/issue_ref flows so the guard does not fire spuriously.
14. **Surface B — contract field is `issue_ref` only:** The SC-12 guard never adds a split `repo_name` identity field to dispatch/result contracts — that would re-instantiate the split-identity shape SC-2 forbids. The local basename is derived from the composite under the SC-4 carve-out at the point of `local-issues` command construction.

## Platform / Routing Note

`owner/repo#NNN` does NOT carry a platform. Platform is resolved by the platform-aware issue-operations dispatcher from the repo. Do not add platform to the token. Under `identity_source: local` no owner/repo pair exists; Edge Case 5 governs the directory-scoped basename identity used by `local-issues` (SC-9).

## Change Control

| Date | Change | Trigger | Authorized By |
|---|---|---|---|
| 2026-08-25 | Restructured per `.opencode/reference/spec-structure-standards.md`: added the six preamble fields, Not Included, Definitions, Requirements, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, and Edge Cases; converted Success Criteria to the four-column table with per-row Evidence Type and Verification Method; enumerated affected contracts and files with live-verified counts; named the SC-4 guideline target and SC-5 lint surface; added Problem Statement provenance citations (session-2026-06-20 lesson 4 / issue 1308 incident; AGENTS.md wrong-repo catalog entry); reconciled evidence types between this document and `sc-summary.yaml` (SC-2/SC-6 behavioral; SC-4/SC-5 uplifted to behavioral with rationale recorded under the SC table). No success criterion was removed or weakened. | Spec-audit verdict DRAFT — 6 of 11 holistic dimensions FAIL (Implementability, Internal Consistency, Completeness, Testability, Provenance, Traceability) with six bidirectional findings in `tmp/issue-2319/artifacts/spec-audit/{verdict,judgment}.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing the DRAFT verdict remediation mandate |
| 2026-08-26 | Spec-audit cycle-2 remediation — four FAIL dimensions addressed: **Provenance** — corrected Definition 1 skill-card count 38 → 51 against a live recount with the extraction command recorded; recorded the dispatch-extent extraction grammar in Affected Files (all ten extents reproduce exactly under the recorded commands: identity-carrying `Context passed:` payloads for workflow cards, identity-carrying TDT context-column rows for trigger-dispatch-table cards); restated the SC-3 inventory predicate to the live-reproducing `github_issue_[a-z_]+` token sweep with documented exclusions (`gh-cli`/`gb-cli` wrapper decks as functional platform surface; `cleanup/issue-closure.md` as dispatcher-routing-only with zero direct calls) and aligned Item 3 RED to the recorded sweep. **Internal Consistency** — amended SC-1 and R-1 to scope the composite over every internal handoff whose repository resolves to an owner/repo pair, cross-referencing Edge Case 5 as the governing rule for `identity_source: local`. **Completeness** — added Definitions 8–10 defining `issues prefix`, `sc-summary.yaml` (with canonical local path `.opencode/.issues/{N}/sc-summary.yaml`), and `RED/GREEN support`; added an SC-2/SC-6 overlap clarification to Affected Files. **Implementability** — added three Dependencies rows (INDEX.md slot-118 registration, `opencode.jsonc` instructions-array tier decision, behavioral-method model-availability precondition) plus matching Item 1 GREEN registration steps and Item 5 fixture-deck lifecycle (`./tmp/issue-2319/lint-fixture/` created and removed within Item 5). No success criterion was removed or weakened. | Spec-audit cycle-2 verdict DRAFT — 4 of 11 holistic dimensions FAIL (Implementability, Internal Consistency, Completeness, Provenance) with four bidirectional findings in `tmp/issue-2319/artifacts/spec-audit/verdict.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing cycle-2 remediation mandate |
| 2026-08-26 | Spec-audit cycle-3 remediation — sole FAIL dimension HOLISTIC-7 Provenance addressed: corrected the `opencode.jsonc` `instructions`-array inventory count ten → twelve in both Named targets (Guideline registration surface bullet) and the Dependencies instructions-array row; recorded the reproducing grep command inline alongside the corrected count so the value cannot silently drift again; re-ran the grep before revision and cited it in this entry — `grep -nE '\.opencode/guidelines/[a-z0-9-]+\.md' .opencode/opencode.jsonc` returns twelve guideline entries at lines 79–90 plus `INDEX.md` at line 91, matching the independent evaluator and validator reproductions in the audit verdict. Inventory observation only: no success criterion text changed; no SC removed or weakened. | Spec-audit cycle-3 verdict DRAFT — 10 of 11 holistic dimensions PASS, sole FAIL Provenance (SPEC_OUTDATED stale ten-count under Verified-live banner at two locations), bidirectional finding in `tmp/issue-2319/artifacts/spec-audit/verdict.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing cycle-3 remediation mandate |
| 2026-08-26 | Spec-audit cycle-4 remediation — sole FAIL criterion SC-13-cost-frame addressed: inserted the two canonical cost-frame preamble lines between the `## Cost Frame` heading and the first per-SC bullet — `Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.` — satisfying cost-model-standards.md §Per-SC Cost-Frame Format and spec-structure-standards.md §10 requirement 4 (dark-prose-007 computation frame plus identity anchor ahead of the per-SC bullets). Per-SC bullet content unchanged; no success criterion removed or weakened. | Spec-audit cycle-4 verdict — 22 of 24 criteria PASS, 1 FAIL (SC-13-cost-frame, bidirectional finding SPEC_INCOMPLETE), 1 N/A, in `tmp/issue-2319/artifacts/spec-audit/verdict.yaml` | Developer-directed remediation dispatch: spec-creation revise task, revision_reason citing cycle-4 remediation mandate |
| 2026-08-31 | Folds the label-routing runtime guard and the local-issues `owner/repo#NNN` composite acceptance into this spec so all three changes ship as one authoritative spec. **Surface A (local-issues composite, SC-7..SC-11, R-6/R-7):** added Definitions 11–14 (composite form, basename qualifier, number-consuming subcommand, origin-URL derivation), a Surface-A Affected-Files inventory with live-verified helper line spans, and Items 7–11 (parse recognition, origin-resolution, local-no-composite boundary, subcommand inheritance, help/output docs). **Surface B (label-routing runtime guard, SC-12, R-8):** added Definition 15 and a Surface-B Affected-Files inventory with the ten mutating task cards (apply-label, update-issue, read-labels, close, spec-creation/create, issue-review/analyze-and-spec, git-workflow-pr/pr-creation, git-workflow-pr/completion, writing-plans/create, resolve-scope conditional) and their skill-card dispatch-context sites, plus Item 12 and six new Edge Cases (9–14) covering the runtime guard's read/mutation distinction, spurious-BLOCK avoidance, and the composite-only contract field. Reframed the prior `repo_name` contract field as a derived local basename under the SC-4 carve-out so it does not reintroduce a split identity field. Updated the SC-4 verification method and carve-out text, Alternatives Considered, Key Design Decisions, Dependencies, Traceability, Cost Frame, and the Problem Statement/Root Cause/Approach to scope the three-surface effort. The six pre-existing SCs (SC-1..SC-6) and all prior Requirements/Items remain intact and unweakened; SCs are appended (SC-7..SC-12), never renumbered or rewritten. | Developer-directed revision dispatch: spec-creation revise task, revision_reason "Fold the label-routing runtime guard and the local-issues owner/repo#NNN composite acceptance into the single governing spec so all three changes ship as one spec." | Developer-authorized scope expansion (revision_reason in dispatch context) |

---

🤖 OpenCode (deepseek-v4-flash) created
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-25 — spec-audit DRAFT remediation
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-26 — spec-audit cycle-2 remediation
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-26 — spec-audit cycle-3 remediation
🤖 OpenCode (opencode/x-preview-f-free) revised 2026-08-26 — spec-audit cycle-4 remediation
🤖 OpenCode (ollama-cloud/deepseek-v4-flash) revised 2026-08-31 — fold label-routing runtime guard + local-issues composite acceptance into the single governing spec
