Spec: #1650

## Goal

Replace all 56 `/skill` CLI invocation references across `.opencode/skills/` with proper `skill({name: "..."})` and `task()` syntax. The `/skill` pattern is not a real opencode command and creates confusion.

## Architecture

Four phases matching the spec's scope breakdown, each independently verifiable via content-verification grep.

## Tech Stack

- Language: Markdown (text replacement across SKILL.md and task files)
- Affected modules: 32 SKILL.md files, ~24 task files, 1 enforcement task, 1 YAML dispatch table
- Test infra: `tests/behaviors/`, `opencode-cli run` with `with-test-home` wrapper

## File Structure

| Phase | What | Files | Action |
|-------|------|-------|--------|
| 1 | SKILL.md "CLI equivalent" lines | 32 SKILL.md files | Replace `/skill <name> --task <task>` with `skill({name: "<name>"})` |
| 2 | Task file examples | ~24 task files | Replace `/skill` examples with `skill()` + `task()` patterns |
| 3 | Audit documentation | Audit sections in SKILL.md + task files | Replace `/skill` references in audit context |
| 4 | Remaining references | `brainstorming/tasks/enforcement.md`, `dispatch-table.yaml` | Replace remaining `/skill` prose references |

---

## Phase 1: SKILL.md "CLI Equivalent" Lines

**Concern:** 32 SKILL.md files have a `**CLI equivalent (for human TUI use):** \`/skill <name> --task <task>\`` line. Replace with `skill({name: "<name>"})`.

### Files (32)

| # | File | Current | Replacement |
|---|------|---------|-------------|
| 1 | `skills/writing-plans/SKILL.md` | `/skill writing-plans --task <task>` | `skill({name: "writing-plans"})` |
| 2 | `skills/programming-principles/SKILL.md` | `/skill programming-principles --task <task>` | `skill({name: "programming-principles"})` |
| 3 | `skills/git-workflow/SKILL.md` | `/skill git-workflow --task <task>` | `skill({name: "git-workflow"})` |
| 4 | `skills/changelog-generator/SKILL.md` | `/skill changelog-generator --task <task>` | `skill({name: "changelog-generator"})` |
| 5 | `skills/finishing-a-development-branch/SKILL.md` | `/skill finishing-a-development-branch --task <task>` | `skill({name: "finishing-a-development-branch"})` |
| 6 | `skills/brainstorming/SKILL.md` | `/skill brainstorming --task <task>` | `skill({name: "brainstorming"})` |
| 7 | `skills/research/SKILL.md` | `/skill research --task <task>` | `skill({name: "research"})` |
| 8 | `skills/multimodal-dispatch/SKILL.md` | `/skill multimodal-dispatch --task <task>` | `skill({name: "multimodal-dispatch"})` |
| 9 | `skills/sync-guidelines/SKILL.md` | `/skill sync-guidelines --task <task>` | `skill({name: "sync-guidelines"})` |
| 10 | `skills/verification-before-completion/SKILL.md` | `/skill verification-before-completion --task <task>` | `skill({name: "verification-before-completion"})` |
| 11 | `skills/requesting-code-review/SKILL.md` | `/skill requesting-code-review --task <task>` | `skill({name: "requesting-code-review"})` |
| 12 | `skills/issue-review/SKILL.md` | `/skill issue-review --task <task>` | `skill({name: "issue-review"})` |
| 13 | `skills/receiving-code-review/SKILL.md` | `/skill receiving-code-review --task <task>` | `skill({name: "receiving-code-review"})` |
| 14 | `skills/completeness-gate/SKILL.md` | `/skill completeness-gate --task <task>` | `skill({name: "completeness-gate"})` |
| 15 | `skills/issue-operations/SKILL.md` | `/skill issue-operations --task <task>` | `skill({name: "issue-operations"})` |
| 16 | `skills/spec-creation/SKILL.md` | `/skill spec-creation --task <task>` | `skill({name: "spec-creation"})` |
| 17 | `skills/plan/SKILL.md` | `/skill plan --task <task>` | `skill({name: "plan"})` |
| 18 | `skills/mcp-tool-usage/SKILL.md` | `/skill mcp-tool-usage --task <task>` | `skill({name: "mcp-tool-usage"})` |
| 19 | `skills/pre-analysis/SKILL.md` | `/skill pre-analysis --task <task>` | `skill({name: "pre-analysis"})` |
| 20 | `skills/test-driven-development/SKILL.md` | `/skill test-driven-development --task <name>` | `skill({name: "test-driven-development"})` |
| 21 | `skills/skill-creator/SKILL.md` | `/skill skill-creator --task <task>` | `skill({name: "skill-creator"})` |
| 22 | `skills/skill-creator/reference/routing-only-template.md` | `/skill skill-name --task <task>` | `skill({name: "skill-name"})` |
| 23 | `skills/sre-runbook/SKILL.md` | `/skill sre-runbook --task <task>` | `skill({name: "sre-runbook"})` |
| 24 | `skills/pr-creation-workflow/SKILL.md` | `/skill pr-creation-workflow --task <task>` | `skill({name: "pr-creation-workflow"})` |
| 25 | `skills/verification-enforcement/SKILL.md` | `/skill verification-enforcement --task <task>` | `skill({name: "verification-enforcement"})` |
| 26 | `skills/verification/SKILL.md` | `/skill verification --task <task>` | `skill({name: "verification"})` |
| 27 | `skills/engineering-approach/SKILL.md` | `/skill engineering-approach --task <task>` | `skill({name: "engineering-approach"})` |
| 28 | `skills/executing-plans/SKILL.md` | `/skill executing-plans --task <task>` | `skill({name: "executing-plans"})` |
| 29 | `skills/systematic-debugging/SKILL.md` | `/skill systematic-debugging --task <task>` | `skill({name: "systematic-debugging"})` |
| 30 | `skills/using-git-worktrees/SKILL.md` | `/skill using-git-worktrees --task <task>` | `skill({name: "using-git-worktrees"})` |
| 31 | `skills/conflict-resolution/SKILL.md` | `/skill conflict-resolution --task <task>` | `skill({name: "conflict-resolution"})` |
| 32 | `skills/correspondence/SKILL.md` | `/skill correspondence --task <task>` | `skill({name: "correspondence"})` |

### RED Check

```bash
grep -rn '/skill' --include='SKILL.md' .opencode/skills/ | grep -v 'skills/' | wc -l
```
Must return 32 (all CLI equivalent lines).

### GREEN

Replace each line with `skill({name: "<name>"})` format. Re-run RED check — must return 0.

### SC Coverage

SC-1

---

## Phase 2: Task File Examples

**Concern:** 24 task files and reference files use `/skill` in examples. Replace with `skill()` + `task()` patterns.

### Files (24)

| # | File | Line | Current | Replacement |
|---|------|------|---------|-------------|
| 1 | `skills/git-workflow/tasks/pr-creation/squash-push.md` | 25 | `` `/skill changelog-generator --since-last-release` `` | `` `skill({name: "changelog-generator"})` `` |
| 2 | `skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | 69 | `` `/skill git-workflow --task provenance --mode=dev-push` `` | `` `skill({name: "git-workflow"})` `` |
| 3 | `skills/git-workflow/tasks/cleanup/verify-merge.md` | 61 | `` `/skill git-workflow --task rebase-pending` `` | `` `skill({name: "git-workflow"})` `` |
| 4 | `skills/changelog-generator/tasks/backfill.md` | 85 | `/skill changelog-generator --task backfill` | `skill({name: "changelog-generator"})` |
| 5 | `skills/changelog-generator/tasks/date-range.md` | 48 | `/skill changelog-generator --task date-range "2026-03-01..2026-03-31"` | `skill({name: "changelog-generator"})` |
| 6 | `skills/issue-review/tasks/audit.md` | 49 | `/skill adversarial-audit --task spec-audit --issue N` | `skill({name: "adversarial-audit"})` |
| 7 | `skills/test-driven-development/tasks/red.md` | 9 | `` `/skill test-driven-development --task red` `` | `` `skill({name: "test-driven-development"})` `` |
| 8 | `skills/test-driven-development/tasks/green.md` | 9 | `` `/skill test-driven-development --task green` `` | `` `skill({name: "test-driven-development"})` `` |
| 9 | `skills/test-driven-development/tasks/refactor.md` | 9 | `` `/skill test-driven-development --task refactor` `` | `` `skill({name: "test-driven-development"})` `` |
| 10 | `skills/sre-runbook/reference/proxmox-node-failure-recovery.md` | 16 | `/skill sre-runbook --task generate` | `skill({name: "sre-runbook"})` |
| 11 | `skills/sre-runbook/reference/proxmox-cluster-quorum-loss.md` | 16 | `/skill sre-runbook --task generate` | `skill({name: "sre-runbook"})` |
| 12 | `skills/sre-runbook/tasks/track.md` | 68 | `` `/skill issue-operations --task pre-creation` `` | `` `skill({name: "issue-operations"})` `` |
| 13 | `skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | 13 | `/skill changelog-generator --since-last-release` | `skill({name: "changelog-generator"})` |
| 14 | `skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | 88 | `/skill changelog-generator --since-last-release` | `skill({name: "changelog-generator"})` |
| 15 | `skills/executing-plans/tasks/start.md` | 41 | `/skill implementation-pipeline --task assemble-work` | `skill({name: "implementation-pipeline"})` |
| 16 | `skills/systematic-debugging/tasks/diagnose.md` | 72 | `` `/skill issue-review --issue N --task analyze-and-spec` `` | `` `skill({name: "issue-review"})` `` |
| 17 | `skills/approval-gate/tasks/pre-impl/yield-to-assemble-work.md` | 90 | `/skill implementation-pipeline --task assemble-work` | `skill({name: "implementation-pipeline"})` |
| 18 | `.guidelines/README.md` | 112 | `/skill fragment-manager --task create-fragment` | `skill({name: "fragment-manager"})` |
| 19 | `.guidelines/README.md` | 124 | `/skill fragment-manager --task sync-fragment --fragment-id <id>` | `skill({name: "fragment-manager"})` |
| 20 | `.guidelines/README.md` | 136 | `/skill fragment-manager --task check-drift` | `skill({name: "fragment-manager"})` |
| 21 | `README.md` | 252 | `/skill fragment-manager --task create-fragment` | `skill({name: "fragment-manager"})` |
| 22 | `README.md` | 255 | `/skill fragment-manager --task sync-fragment --fragment-id <id>` | `skill({name: "fragment-manager"})` |
| 23 | `README.md` | 258 | `/skill fragment-manager --task check-drift` | `skill({name: "fragment-manager"})` |
| 24 | `skills/brainstorming/tasks/enforcement.md` | 53 | `/skill brainstorming` | `skill({name: "brainstorming"})` |

### RED Check

```bash
grep -rn '/skill' --include='*.md' .opencode/skills/ .opencode/.guidelines/ .opencode/README.md | grep -v 'SKILL.md' | grep -v 'CHANGELOG'
```
Must return 24 matches.

### GREEN

Replace each `/skill` invocation with `skill({name: "..."})`. Re-run RED check — must return 0.

### SC Coverage

SC-2

---

## Phase 3: Audit Documentation

**Concern:** Audit-related sections in SKILL.md and task files that reference `/skill`. These are covered by Phase 1 (SKILL.md CLI lines) and Phase 2 (task file examples). No standalone audit-specific `/skill` references exist outside those categories.

**No additional files needed** — all audit-related `/skill` references are already captured in Phase 1 (SKILL.md CLI equivalent lines in audit skills like `adversarial-audit`) and Phase 2 (task file examples like `issue-review/tasks/audit.md`).

### SC Coverage

SC-3 (covered by Phase 1 + Phase 2)

---

## Phase 4: Remaining References

**Concern:** The `dispatch-table.yaml` has `/skill` usage documentation that needs updating.

### Files

| # | File | Line | Current | Replacement |
|---|------|------|---------|-------------|
| 1 | `dispatch-table.yaml` | 403 | `- usage: "/skill <skill-name> --task <task-name> for sub-task invocation"` | `- usage: "skill({name: \"<skill-name>\"}) for skill invocation"` |
| 2 | `dispatch-table.yaml` | 404 | `- overview: "/skill <skill-name> (no --task) for skill overview only"` | `- overview: "skill({name: \"<skill-name>\"}) for skill overview"` |

### RED Check

```bash
grep -n '/skill' dispatch-table.yaml
```
Must return 2 matches.

### GREEN

Replace both lines. Re-run RED check — must return 0.

### SC Coverage

SC-3

---

## SC-to-Test Traceability

| SC | Verification Method | Phase | Assertion |
|----|-------------------|-------|-----------|
| SC-1 | `grep -rn '/skill' --include='SKILL.md' .opencode/skills/` returns 0 | 1 | Content-verification |
| SC-2 | `grep -rn '/skill' --include='*.md' .opencode/skills/ .opencode/.guidelines/ .opencode/README.md` (excl. SKILL.md, CHANGELOG) returns 0 | 2 | Content-verification |
| SC-3 | `grep -rn '/skill' .opencode/ --include='*.md' --include='*.yaml' --include='*.yml'` returns 0 (excl. CHANGELOG) | 1-4 | Content-verification |
| SC-4 | Behavioral: agent uses `skill()` syntax, not `/skill`, when describing skill invocation | 4 | `opencode-cli run` with assertion |

## Verification Plan

1. **Content-verification (per phase):** Each phase runs its own `grep` assertions as RED checkpoints
2. **Final content-verification sweep:** After all 4 phases:
   ```bash
   grep -rn '/skill' .opencode/ --include='*.md' --include='*.yaml' --include='*.yml' | grep -v 'CHANGELOG'
   ```
   Must return 0
3. **Behavioral test:** Create RED-phase behavioral test for SC-4, then GREEN after implementation
4. **Enforcement test:** `bash .opencode/tests/with-test-home --clean && bash .opencode/tests/test-enforcement.sh --changed`
5. **Lint:** Markdown lint on modified files

## Sub-Issues

This plan has 4 phases. Single-task plan (one phase) — no sub-issues needed.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)