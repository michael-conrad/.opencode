# Implementation Plan — [#1817](https://github.com/michael-conrad/.opencode/issues/1817) — Holistic trunk-based development branch name remediation

**Goal:** Complete the trunk-based development migration by fixing all remaining hardcoded `dev`/`main` references, prose/command mismatches, and rewriting `115-branch-naming.md` for trunk-based development. Subsumes #1632.

**Architecture:** Six sequential phases — each phase is a self-contained concern with its own file set, SCs, and RED/GREEN chains. Phases are ordered by dependency: Gate 1 (pre-push) first, then conceptual rewrite (branch naming), then mechanical replacements (root files → guidelines → prose mismatches → main references).

**Files:**
- `.githooks/pre-push` — Gate 1 logic
- `.opencode/guidelines/115-branch-naming.md` — Complete rewrite
- `.opencode/AGENTS.md`, `.opencode/README.md`, `.opencode/.guidelines/branch-first-protocol.md`, `.opencode/commands/submodule-tag-prework.md`
- `.opencode/guidelines/000-critical-rules.md`, `010-approval-gate.md`, `020-go-prohibitions.md`, `060-tool-usage.md`, `116-pair-mode.md`
- 9 skill task files with prose/command mismatches
- 6 skill task files with hardcoded `main`

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed in order. No step may be skipped, combined, or reordered. Each step's dispatch indicator MUST be followed. `(**sub-agent**)` steps MUST dispatch a clean-room sub-agent via `task()`. `(**inline**)` steps MUST be executed by the orchestrator directly. Violations produce defective deliverables that MUST be discarded.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding to the next. Do NOT batch steps. Do NOT parallelize steps with chain dependencies. Sequential ordering is mandatory.

> **Step Status:** Before each step, update `todowrite` to mark the step as `in_progress`. After each step, mark it as `completed`. Before HALT, call `todowrite(todos=[])` to clear state.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Pre-push Gate 1 redesign | Pre-push hook | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1-8 |
| 2 | Rewrite `115-branch-naming.md` | Guideline rewrite | SC-6, SC-7 | None | 9-14 |
| 3 | Fix hardcoded `dev` in root files | Root file cleanup | SC-9, SC-12, SC-13, SC-14 | None | 15-22 |
| 4 | Fix hardcoded `dev` in guidelines | Guideline cleanup | SC-8 | None | 23-30 |
| 5 | Fix prose/command mismatches | Skill task prose | SC-10 | None | 31-42 |
| 6 | Fix hardcoded `main` → `$DEFAULT_BRANCH` | Skill task commands | SC-11, SC-15, SC-16, SC-17, SC-18, SC-19 | None | 43-52 |

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed in order. No step may be skipped, combined, or reordered. Each step's dispatch indicator MUST be followed. `(**sub-agent**)` steps MUST dispatch a clean-room sub-agent via `task()`. `(**inline**)` steps MUST be executed by the orchestrator directly. Violations produce defective deliverables that MUST be discarded.

> **Self-remediation protocol:** If a step fails verification, the orchestrator MUST NOT proceed. Diagnose the root cause, fix the defect, re-verify. Only after PASS may the next step begin. If remediation fails twice, report BLOCKED with both failure artifacts and HALT.

## Exit Criteria

- [ ] C1. Pre-push Gate 1 checks against `origin/$DEFAULT_BRANCH` instead of `origin/dev`
- [ ] C2. Pre-push Gate 1 allows force-push to branches with open PRs against the trunk
- [ ] C3. Pre-push Gate 1 blocks force-push to branches with no open PR whose commits are in the trunk's history
- [ ] C4. No references to `origin/dev` remain in Gate 1 logic
- [ ] C5. No release promotion branch exemption remains in Gate 1 logic
- [ ] C6. `115-branch-naming.md` contains zero references to `dev` as a branch name
- [ ] C7. `115-branch-naming.md` describes trunk-based development
- [ ] C8. All remaining hardcoded `dev` references in `.opencode/guidelines/` replaced
- [ ] C9. All remaining hardcoded `dev` references in root files replaced
- [ ] C10. All prose/command mismatch files have prose updated to say "trunk" or "default branch"
- [ ] C11. All hardcoded `main` references in commands replaced with `$DEFAULT_BRANCH`
- [ ] C12. `AGENTS.md` submodule tracking section uses `$DEFAULT_BRANCH`
- [ ] C13. `branch-first-protocol.md` uses `$DEFAULT_BRANCH` in all commands
- [ ] C14. `submodule-tag-prework.md` uses `$DEFAULT_BRANCH` in all commands
- [ ] C15. `operating-protocol.md` compare URL patterns use `$DEFAULT_BRANCH`
- [ ] C16. `using-git-worktrees` task files use `$DEFAULT_BRANCH` or "trunk"
- [ ] C17. No hardcoded `main` in any `.opencode/guidelines/` file
- [ ] C18. No hardcoded `main` in any `.opencode/skills/` task file
- [ ] C19. No hardcoded `main` in `.opencode/AGENTS.md` or `.opencode/README.md`
