---
plan_schema_version: "1.0"
issue: 2039
title: "Create the 10 STILL-MISSING task cards + resolve the 2 special-case dangling references"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2039 — Create 10 STILL-MISSING Task Cards + Resolve 2 Special-Case Dangling References

**Goal:** Achieve TDT-reference integrity by creating the 10 confirmed STILL-MISSING task cards and resolving the two special-case dangling references (`route`, `push-artifacts`) so that no Trigger Dispatch Table or Invocation references a non-existent task card.

**Architecture:** The skill deck currently carries 10 genuine dangling TDT references (the other 18 of the original 28 are stale — already existing, obsolete, or renamed/folded, and are out of scope). This plan creates the 10 STILL-MISSING cards as `.md` files in their respective `tasks/` directories, each with entry criteria, inline-only steps, and exit criteria. For the two special cases, the plan applies the recommended resolutions: remove the stale `multimodal-dispatch` `route` TDT row + Invocation (rerouting its triggers to `dispatch`) and create a thin core dispatcher for `issue-operations-core/tasks/push-artifacts.md` that resolves the platform and routes to the platform sub-skill. Phase 3 is a verification-only gate that cross-references every TDT in the deck against the filesystem to confirm no dangling reference remains.

> **Implementation status note:** The deliverables this plan describes have already been produced in the working tree and independently audited (all 10 STILL-MISSING cards present; `multimodal-dispatch/route` resolved via TDT cleanup; `issue-operations-core/tasks/push-artifacts.md` created as a thin core dispatcher). The phases below document the implementation strategy that produces these artifacts. An executing-plans sub-agent follows each phase and verifies against the already-present artifacts.

**Files:**
- `.opencode/skills/brainstorming/tasks/` — `top-down-analysis.md`, `cross-scope.md`
- `.opencode/skills/programming-principles/tasks/` — `check-limits.md`, `decompose.md`
- `.opencode/skills/skill-creator/tasks/` — `init.md`, `package.md`, `fragment-management.md`
- `.opencode/skills/using-git-worktrees/tasks/` — `verify-worktree.md`
- `.opencode/skills/issue-operations-core/tasks/` — `push-artifacts.md`
- `.opencode/skills/issue-operations-core/SKILL.md` — core TDT row for `push-artifacts`
- `.opencode/skills/multimodal-dispatch/SKILL.md` — remove stale `route` TDT row + Invocation, reroute to `dispatch`
- `.opencode/skills/**/SKILL.md` — TDT-reference integrity cross-reference (verification only)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Create the 10 STILL-MISSING task cards | `test-driven-development` | `red`, `green`, `verify` | 10 task cards under `brainstorming`, `programming-principles`, `skill-creator`, `using-git-worktrees`, `issue-operations-core` | SC-1, SC-1.1, SC-2 | — |
| 2 — Resolve the two special-case dangling references | `test-driven-development` | `red`, `green`, `verify` | `multimodal-dispatch/SKILL.md`, `issue-operations-core/SKILL.md`, `issue-operations-core/tasks/push-artifacts.md` | SC-4 | 1 |
| 3 — Verify TDT-reference integrity across the skill deck | `test-driven-development` | `red`, `green`, `verify` | `.opencode/skills/**/SKILL.md` | SC-3 | 1, 2 |

---

## Phase Details

### Phase 1 — Create the 10 STILL-MISSING Task Cards

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | 10 task card `.md` files in their respective `tasks/` directories |
| SCs | SC-1, SC-1.1, SC-2 |
| Depends On | — |

**Context:**
```yaml
issue_number: 2039
deliverables:
  - path: .opencode/skills/brainstorming/tasks/top-down-analysis.md
    sc: SC-1.1
  - path: .opencode/skills/brainstorming/tasks/cross-scope.md
    sc: SC-1.1
  - path: .opencode/skills/programming-principles/tasks/check-limits.md
    sc: SC-1
  - path: .opencode/skills/programming-principles/tasks/decompose.md
    sc: SC-1
  - path: .opencode/skills/skill-creator/tasks/init.md
    sc: SC-1
  - path: .opencode/skills/skill-creator/tasks/package.md
    sc: SC-1
  - path: .opencode/skills/skill-creator/tasks/fragment-management.md
    sc: SC-1
  - path: .opencode/skills/using-git-worktrees/tasks/verify-worktree.md
    sc: SC-1
  - path: .opencode/skills/issue-operations-core/tasks/push-artifacts.md
    sc: SC-1
  - path: .opencode/skills/multimodal-dispatch/tasks/route.md
    sc: SC-1
card_structure: "entry criteria, inline-only steps, exit criteria"
brainstorming_requirement_source: ".opencode/.issues/2039/spec.md §Brainstorming Task Card Requirements"
```

### Phase 2 — Resolve the Two Special-Case Dangling References

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `multimodal-dispatch/SKILL.md`, `issue-operations-core/SKILL.md`, `issue-operations-core/tasks/push-artifacts.md` |
| SCs | SC-4 |
| Depends On | 1 |

**Context:**
```yaml
issue_number: 2039
route_resolution: "remove stale route TDT row + Invocation in multimodal-dispatch/SKILL.md; reroute 'route'/'route task'/'dispatch to model' triggers to dispatch"
push_artifacts_resolution: "create thin core dispatcher at issue-operations-core/tasks/push-artifacts.md that resolves github.platform and routes to the platform sub-skill, capturing artifact_url for spec-creation/tasks/reconcile-push.md"
no_dangling_reference_required: true
```

### Phase 3 — Verify TDT-Reference Integrity Across the Skill Deck

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/skills/**/SKILL.md` |
| SCs | SC-3 |
| Depends On | 1, 2 |

**Context:**
```yaml
issue_number: 2039
integrity_check: "cross-reference every Trigger Dispatch Table and Invocation in .opencode/skills/**/SKILL.md against the task cards on disk; no TDT may reference a non-existent task card"
```

---

## Exit Criteria

- [ ] C1. All 10 STILL-MISSING task card files exist as `.md` files in their respective `tasks/` directories (SC-1), with `multimodal-dispatch/route` resolved per SC-4.
- [ ] C2. The two brainstorming cards (`top-down-analysis.md`, `cross-scope.md`) contain all required procedure per §Brainstorming Task Card Requirements (SC-1.1).
- [ ] C3. Each of the 10 new task cards has entry criteria, inline steps, and exit criteria (SC-2).
- [ ] C4. The two special-case dangling references (`route`, `push-artifacts`) are resolved with no dangling reference remaining (SC-4).
- [ ] C5. No TDT references a non-existent task card across the entire skill deck (SC-3).
