**Parent Plan:** #1881

# Phase 4 — Split git-workflow

**Concern:** git-workflow → 5 sub-skills (git-workflow-branch, git-workflow-commit, git-workflow-pr, git-workflow-cleanup, git-workflow-conflict)

**Dependencies:** Phase 1 (dispatcher template exists)

**Summary:** Convert git-workflow/SKILL.md to dispatcher with Trigger Dispatch Table. Create 5 sub-skills: branch (3 + 3 submodule task files), commit (3 task files), pr (3 + 1 received task files — post-implementation.md moved from approval-gate), cleanup (3 task files), conflict (1 task file). Update behavioral tests.

Key files:
- `.opencode/skills/git-workflow/SKILL.md` — Converted to dispatcher
- `.opencode/skills/git-workflow-branch/SKILL.md` — New
- `.opencode/skills/git-workflow-commit/SKILL.md` — New
- `.opencode/skills/git-workflow-pr/SKILL.md` — New
- `.opencode/skills/git-workflow-cleanup/SKILL.md` — New
- `.opencode/skills/git-workflow-conflict/SKILL.md` — New
- `.opencode/skills/approval-gate/tasks/post-implementation.md` — MOVED to git-workflow-pr/tasks/