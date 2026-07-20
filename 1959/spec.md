> **Full spec and artifacts:** [`.opencode/.issues/1959/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1959/) — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1959/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

The `playwright-cli` skill was imported from [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) (commit `38cbd008`, Jun 22) with a full 15-entry Trigger Dispatch Table and all procedure content inline in `SKILL.md`. During the Phase 4+5 bulk migration (commit `bfb0a212`, Jul 9), the dispatch table was collapsed to 2 entries (`browse`, `test`), 420 lines of procedure content were stripped from `SKILL.md`, and the corresponding task files (`tasks/browse.md`, `tasks/test.md`) were **never created**. The skill is currently non-functional for sub-agent dispatch — the dispatch table routes to tasks that don't exist.

Additionally, the 10 reference files in `references/` are stale copies from the initial import and have drifted from the upstream Microsoft repo, which has added new commands (`find`, `--hires`, `--mobile`, `--json`, `npx playwright` invocation) and restructured content (e.g., `test-generation.md` replaces the old `spec-driven-testing.md`).

## Root Cause

The Phase 4+5 migration (`bfb0a212`) applied a one-size-fits-all pattern across 27 skills: strip procedure content from `SKILL.md`, create a `commands-reference.md` task, and collapse the dispatch table. For most skills this worked because they had `operating-protocol.md` task files created in the same commit. For `playwright-cli`, the original had 15 distinct task entries that were all collapsed into `browse` and `test` — and neither task file was ever created. The commit message claimed "SC-ROUTING-7: All task files have proper entry/exit criteria and step definitions" but that was false for this skill.

## Approach

1. **Restore the full 15-entry Trigger Dispatch Table** in `SKILL.md`, adapted to modern opencode skill card structure (Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent/Orchestrator Entry Criteria)
2. **Create all task files** (`tasks/browse.md`, `tasks/eval.md`, `tasks/network.md`, `tasks/storage.md`, `tasks/tracing.md`, `tasks/video.md`, `tasks/session.md`, `tasks/test.md`, `tasks/spec-driven.md`, `tasks/install.md`) with proper Entry Criteria, Exit Criteria, and Procedure steps
3. **Cross-reference against upstream** Microsoft repo and reconcile differences (new commands, changed invocation patterns, restructured references)
4. **Update reference files** to match upstream content where they've diverged
5. **Update `commands-reference.md`** to include new upstream commands (`find`, `--hires`, `--mobile`, `--json`, `npx playwright` invocation)
6. **Update `SKILL.md` YAML frontmatter** to match current conventions (remove `provenance`, add `compatibility`, update `description` to agent-intent pattern)

## Out of Scope

- Creating behavioral enforcement tests for the restored skill (deferred to implementation)
- Modifying the upstream `microsoft/playwright-cli` repository
- Adding new capabilities beyond what upstream provides

## Success Criteria

| SC ID | Criterion | Evidence Type | Verification Method |
|-------|-----------|---------------|---------------------|
| SC-1 | `SKILL.md` Trigger Dispatch Table has 15 entries matching upstream capability domains (open, navigate, interact, input, capture, eval, network, storage, tabs, tracing, video, test, spec-driven, session, install) | string | `grep -c "^|" .opencode/skills/playwright-cli/SKILL.md \| grep -E "(15|16|17)"` — must match at least 15 dispatch rows |
| SC-2 | All 10 task files exist at `tasks/<name>.md` with Entry Criteria, Exit Criteria, and Procedure sections | structural | `for t in browse eval network storage tracing video session test spec-driven install; do test -f .opencode/skills/playwright-cli/tasks/$t.md || echo "MISSING: $t"; done` — must produce no output |
| SC-3 | `commands-reference.md` includes new upstream commands (`find`, `--hires`, `--mobile`, `--json`, `npx playwright` invocation) | string | `grep -c "find\|--hires\|--mobile\|--json\|npx playwright" .opencode/skills/playwright-cli/tasks/commands-reference.md` — must output at least 5 |
| SC-4 | Reference files reconciled with upstream — no content drift on core commands | string | Diff each reference file against upstream; only structural/metadata differences (frontmatter, provenance) are permitted — command content must match |
| SC-5 | `SKILL.md` YAML frontmatter matches current conventions (no `provenance`, has `compatibility`, agent-intent `description`) | string | `grep -c "provenance:" .opencode/skills/playwright-cli/SKILL.md` — must output 0; `grep -c "compatibility:" .opencode/skills/playwright-cli/SKILL.md` — must output 1 |
| SC-6 | `SKILL.md` has Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE sections | string | `grep -c "## Persona\|## Worktree Mode\|## Mandatory Task Discipline\|### DISPATCH_GATE" .opencode/skills/playwright-cli/SKILL.md` — must output 4 |
| SC-7 | `tasks/commands-reference.md` has Entry Criteria and Exit Criteria sections | string | `grep -c "## Entry Criteria\|## Exit Criteria" .opencode/skills/playwright-cli/tasks/commands-reference.md` — must output 2 |

## Edge Cases and Risks

1. **Upstream may have changed since initial import** — The reference files were imported Jun 22; upstream may have added/removed content. Mitigation: fetch upstream fresh and diff before reconciling.
2. **`npx playwright` vs `npx playwright-cli`** — Upstream now uses `npx playwright` (not `npx playwright-cli`). The skill must use the correct invocation.
3. **`spec-driven-testing.md` vs `test-generation.md`** — Upstream renamed this file. Our copy is the old name. Decision needed: rename or keep both.
4. **Task file granularity** — The original 15 dispatch entries map to 10 task files (some consolidation). Each task file must be independently dispatchable.

## Dependencies

- Upstream `microsoft/playwright-cli` repository (public, no access issues)
- `@playwright/cli` npm package availability

## Affected Files

| File | Action | Phase |
|------|--------|-------|
| `.opencode/skills/playwright-cli/SKILL.md` | Rewrite dispatch table, restore sections, update frontmatter | 1 |
| `.opencode/skills/playwright-cli/tasks/commands-reference.md` | Update with new upstream commands | 1 |
| `.opencode/skills/playwright-cli/tasks/browse.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/eval.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/network.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/storage.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/tracing.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/video.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/session.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/test.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/spec-driven.md` | Create | 2 |
| `.opencode/skills/playwright-cli/tasks/install.md` | Create | 2 |
| `.opencode/skills/playwright-cli/references/element-attributes.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/playwright-tests.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/request-mocking.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/running-code.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/session-management.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/storage-state.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/test-generation.md` | Reconcile with upstream (upstream renamed from spec-driven-testing) | 3 |
| `.opencode/skills/playwright-cli/references/tracing.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/video-recording.md` | Reconcile with upstream | 3 |
| `.opencode/skills/playwright-cli/references/spec-driven-testing.md` | Delete (superseded by test-generation.md) | 3 |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan artifacts are at [`.opencode/.issues/1959/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1959/). After creation, `local-issues sync 1959` MUST be run and the result committed to create the local `.opencode/.issues/1959/` entry. The implementation plan will be created in `.opencode/.issues/1959/plan.md` after approval. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.
