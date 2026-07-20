**Parent Plan:** #1881

# Phase 3 — Split approval-gate

**Concern:** approval-gate → 4 sub-skills (approval-gate-scope, approval-gate-labels, approval-gate-revision, approval-gate-bug-discovery)

**Dependencies:** Phase 1 (dispatcher template exists)

**Summary:** Convert approval-gate/SKILL.md to dispatcher with Trigger Dispatch Table. Create 4 sub-skills: scope (17 task files, 3 enforcement files), labels (thin router), revision (thin router), bug-discovery (thin router). Leave post-implementation.md in place (moved in Phase 4). Update behavioral tests.

Key files:
- `.opencode/skills/approval-gate/SKILL.md` — Converted to dispatcher
- `.opencode/skills/approval-gate-scope/SKILL.md` — New
- `.opencode/skills/approval-gate-labels/SKILL.md` — New (thin router)
- `.opencode/skills/approval-gate-revision/SKILL.md` — New (thin router)
- `.opencode/skills/approval-gate-bug-discovery/SKILL.md` — New (thin router)