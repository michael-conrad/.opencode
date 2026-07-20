## Summary

PR #1174 (spec #1063) added dispatch routing entries for 3 pipeline enforcement gates but **never committed the corresponding task files**. The SKILL.md references `implementation-pipeline --task post-red-enforcement`, `--task post-green-enforcement`, and `--task pre-red-baseline`, but none of these task files exist in git history.

## Affected SCs

| SC | Type | Status | Missing Artifact |
|----|------|--------|------------------|
| SC-1 | behavioral | FAIL | `skills/implementation-pipeline/tasks/post-red-enforcement.md` |
| SC-2 | behavioral | FAIL | `skills/implementation-pipeline/tasks/post-green-enforcement.md` |
| SC-8 | behavioral | FAIL | `skills/implementation-pipeline/tasks/pre-red-baseline.md` (exists untracked on disk) |
| SC-12 | behavioral | FAIL | `skills/implementation-pipeline/tasks/pre-red-baseline.md` (same file) |

## Root Cause

The PR author created the task files locally during development, staged and committed the SKILL.md routing updates, but forgot to stage the task files themselves. The `pre-red-baseline.md` file has been sitting untracked since `2026-06-22`. The `post-red-enforcement.md` and `post-green-enforcement.md` files were never created at all.

## Remediation

1. Create `skills/implementation-pipeline/tasks/post-red-enforcement.md` — structural gate: `git diff --name-only -- src/ | wc -l`
2. Create `skills/implementation-pipeline/tasks/post-green-enforcement.md` — structural gate: `git diff --name-only -- test/ | wc -l`
3. Commit pre-existing `skills/implementation-pipeline/tasks/pre-red-baseline.md` — doc-source-currency + SC-ID traceability
4. Update `skills/implementation-pipeline/tasks/pipeline-executor.md` — expand 14-step table to 16-step with enforcement steps

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)