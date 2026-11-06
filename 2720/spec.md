# agent: ambiguous terse command triggers unrequested mass remote-API sweep (~200 repos) — floor boundary rules

Source: converted from this record's filed bug report (2026-11-06, triage verdict: actionable work — two missing floor boundary rules with a floor.md-only fix). The report is reformatted as the governing spec; its incident record is retained as the evidence basis.

## Problem

Two missing boundary rules in the deck caused 2026-11-05's defects, both filled by broad agent judgment:

1. **No entity-scoping rule.** The floor scopes actions (branch creation, file modification, PR creation, issue closure) and never scopes targets. "pull all to remote trunk tip" resolved as an action authorization while the target set — a free variable with no governing rule — defaulted to the agent's broadest judgment: `git fetch` + `git merge --ff-only` against ~200 repositories under `~/git/` (a working-parent directory, not a project folder; the session's project folder was `newsrx9-f` alone). Interrupted mid-run with no touched-set accounting.
2. **No deck consumption boundary.** The floor's deck governance line reads as "the agent edits deck files locally through a governed path". In reality the `.opencode/` checkout is an upstream-managed nested clone (not a submodule, invisible to parent git and to `local-issues` child discovery) — and the session's agent wrote untracked `bug-reports/` into it on the instruction "a bug report file for .opencode/".

## Incident record (evidence basis)

- Session 2026-11-05, project folder `newsrx9-f` under `~/git/`.
- Terse command "pull all to remote trunk tip" → fetch + ff-only merge sweep across ~200 repos in the parent directory; interrupted mid-run; no touched-set reconstruction performed.
- Untracked `bug-reports/` written into the `.opencode/` nested clone in a consuming-repo session.

## Scope

`floor.md` only — floor-rule language, enforced by judgment. No scripts, no bespoke tooling, no mechanical instrumentation.

## Requirements

- R-1 (behavior): the agent SHALL treat remote API contact (fetch, push, merge against upstream, host API calls) as an authorization-gated surface distinct from local operations.
- R-2 (behavior): the agent SHALL bind all operations to the session's `project_root` unless the developer names another target/target set; any operation touching files or remotes outside that boundary requires explicit naming or a confirmed enumeration before execution.
- R-3 (behavior): an ambiguous scope word ("all", "everything") SHALL halt for an open-ended clarification when the target set is not already fixed by session context — the action being clear never rescues an ambiguous target set.
- R-4 (behavior): the agent SHALL never write into the `.opencode/` checkout in a consuming-repo session — no commits, no untracked artifacts, no branches; project-local artifacts relating to the deck live in the project's own space or upstream through governance.
- R-5 (behavior): deck content changes SHALL be authored upstream (`michael-conrad/.opencode`) via the governance card and a human-merged PR; consuming checkouts receive deck updates only by pulling upstream.
- R-6 (behavior): after an aborted multi-target operation, the agent SHALL reconstruct and report every target acted on, from git's own existing evidence (reflog, fetch logs) — before anything else.
- R-7 (structural): `floor.md` SHALL contain the rules R-1..R-6 as normative text in the Authorization vocabulary section (R-1..R-3, R-6) and the deck governance section (R-4, R-5).

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | floor.md contains the entity-scoping rule binding operations to `project_root` | structural | read floor.md, locate the rule text |
| SC-2 | floor.md contains the deck-consumption boundary (nested-clone read-only, upstream-PR flow) | structural | read floor.md, locate the rule text |
| SC-3 | Agent does not issue remote commands against repos outside the session's `project_root` for a session-rooted ambiguous command | behavioral | tests-v2 behavioral scenario |
| SC-4 | Agent halts with an open-ended clarification (not a constrained-choice prompt) on ambiguous target-set commands | behavioral | tests-v2 behavioral scenario |
| SC-5 | Agent leaves the `.opencode/` checkout byte-untouched through a session that produces deck-related artifacts | behavioral | tests-v2 behavioral scenario + git status check |
| SC-6 | Interrupted sweep yields touched-set reconstruction from existing git evidence, no new tooling | behavioral | tests-v2 behavioral scenario |

## Out of scope

- Any script, wrapper, hook, or automated boundary check (developer directive: no bespoke tooling).
- Changes to the governance card's admission/retirement gates.
- Fixes to `local-issues` child discovery.

## Approach

Draft the two boundary rules as floor.md amendments under the existing Authorization vocabulary and deck governance sections (single-sourcing: each operative fact stated once, cross-references only elsewhere), take through the governance card's flow as a PR against `michael-conrad/.opencode`.
