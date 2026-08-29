---
plan_schema_version: "1.0"
issue: 2039
title: "Create the 10 STILL-MISSING task cards + resolve the 2 special-case dangling references"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Implementation Plan — #2039 — Create 10 STILL-MISSING Task Cards + Resolve 2 Special-Case Dangling References

**Goal:** Achieve TDT-reference integrity by creating the 10 confirmed STILL-MISSING task cards and resolving the two special-case dangling references (`route`, `push-artifacts`) so that no Trigger Dispatch Table or Invocation references a non-existent task card.

**Architecture:** The skill deck currently carries 10 genuine dangling TDT references (the other 18 of the original 28 are stale — already existing, obsolete, or renamed/folded, and are out of scope). Two concern groups drive the phases. **CONCERN-1 (Card Creation)** creates the 10 STILL-MISSING cards as `.md` files in their respective `tasks/` directories, each with entry criteria, inline-only steps, and exit criteria, and with the two brainstorming cards carrying full procedure content per §Brainstorming Task Card Requirements. **CONCERN-2 (TDT Reference Integrity)** applies the recommended resolutions for the two special cases — remove the stale `multimodal-dispatch` `route` TDT row + Invocation (rerouting its triggers to `dispatch`) and create a thin core dispatcher for `issue-operations-core/tasks/push-artifacts.md` that resolves the platform and routes to the platform sub-skill — then runs a verification-only gate that cross-references every TDT in the deck against the filesystem to confirm no dangling reference remains. CONCERN-2 maps to a single phase boundary: card creation must complete before special-case resolution and deck-wide integrity verification.

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
| 2 — Resolve special-case references + verify TDT integrity | `test-driven-development` | `red`, `green`, `verify` | `multimodal-dispatch/SKILL.md`, `issue-operations-core/SKILL.md`, `issue-operations-core/tasks/push-artifacts.md`, `.opencode/skills/**/SKILL.md` | SC-4, SC-3 | 1 |

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

**Procedure:**
- [ ] 1. **Pre-regression (**sub-agent**).** Execute the `pre-regression` step from the implementation-workflow reference card to establish the baseline for the string-evidence verification of task card existence. **→ baseline before RED**
- [ ] 2. **Pre-regression verify (**clean-room**).** Verify the pre-regression results. **→ baseline verified**
- [ ] 3. **RED — SC-1 (**clean-room**).** Execute `red` from test-driven-development: write a failing enforcement test asserting each of the 10 STILL-MISSING task card `.md` files exists (evidence type `string`). **→ SC-1**
- [ ] 4. **GREEN — SC-1 (**clean-room**).** Execute `green`: create the 10 STILL-MISSING task card files in their respective `tasks/` directories so the RED test passes. **→ SC-1**
- [ ] 5. **Post-regression (**clean-room**).** Run regression test patterns after GREEN to confirm no regression. **→ post-GREEN regression clean**
- [ ] 6. **Verify — SC-1 (**clean-room**).** Execute `verify` from verification-before-completion: confirm each of the 10 task card `.md` files exists on disk. **→ SC-1**
- [ ] 7. **Commit — SC-1 (**inline**).** Stage and commit the 10 task card files with their enforcement test as one atomic slice. **→ SC-1 committed**
- [ ] 8. **RED — SC-1.1 (**clean-room**).** Execute `red`: write a failing enforcement test asserting `top-down-analysis.md` and `cross-scope.md` contain all required procedure per §Brainstorming Task Card Requirements. **→ SC-1.1**
- [ ] 9. **GREEN — SC-1.1 (**clean-room**).** Execute `green`: populate the two brainstorming cards with the full procedure content from §Brainstorming Task Card Requirements. **→ SC-1.1**
- [ ] 10. **Post-regression (**clean-room**).** Run regression test patterns after GREEN. **→ post-GREEN regression clean**
- [ ] 11. **Verify — SC-1.1 (**clean-room**).** Execute `verify`: confirm both brainstorming card files exist and contain the required sections. **→ SC-1.1**
- [ ] 12. **Commit — SC-1.1 (**inline**).** Stage and commit the two brainstorming cards with their enforcement test as one atomic slice. **→ SC-1.1 committed**
- [ ] 13. **RED — SC-2 (**clean-room**).** Execute `red`: write a failing enforcement test asserting each of the 10 new task cards has entry criteria, inline-only steps, and exit criteria. **→ SC-2**
- [ ] 14. **GREEN — SC-2 (**clean-room**).** Execute `green`: normalize all 10 new task cards to the canonical structure so the RED test passes. **→ SC-2**
- [ ] 15. **Post-regression (**clean-room**).** Run regression test patterns after GREEN. **→ post-GREEN regression clean**
- [ ] 16. **Verify — SC-2 (**clean-room**).** Execute `verify`: sample-audit the 10 new task cards for entry criteria, inline steps, and exit criteria. **→ SC-2**
- [ ] 17. **Commit — SC-2 (**inline**).** Stage and commit the structure normalization with its enforcement test as one atomic slice. **→ SC-2 committed**
- [ ] 18. **VbC (**clean-room**).** Verify SC-1, SC-1.1, SC-2 all PASS against the present deliverables. Any non-clean verdict coerces to FAIL per the reference card's Coercion Rules. **→ SC-1, SC-1.1, SC-2**

### Phase 2 — Resolve Special-Case References + Verify TDT Integrity

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `multimodal-dispatch/SKILL.md`, `issue-operations-core/SKILL.md`, `issue-operations-core/tasks/push-artifacts.md`, `.opencode/skills/**/SKILL.md` |
| SCs | SC-4, SC-3 |
| Depends On | 1 |

**Context:**
```yaml
issue_number: 2039
route_resolution: "remove stale route TDT row + Invocation in multimodal-dispatch/SKILL.md; reroute 'route'/'route task'/'dispatch to model' triggers to dispatch"
push_artifacts_resolution: "create thin core dispatcher at issue-operations-core/tasks/push-artifacts.md that resolves github.platform and routes to the platform sub-skill, capturing artifact_url for spec-creation/tasks/reconcile-push.md"
integrity_check: "cross-reference every Trigger Dispatch Table and Invocation in .opencode/skills/**/SKILL.md against the task cards on disk; no TDT may reference a non-existent task card"
no_dangling_reference_required: true
```

**Procedure:**
- [ ] 19. **Pre-regression (**sub-agent**).** Execute `pre-regression` to establish the baseline for the SC-4 string-evidence verification. **→ baseline before RED**
- [ ] 20. **Pre-regression verify (**clean-room**).** Verify the pre-regression results. **→ baseline verified**
- [ ] 21. **RED — SC-4 (**clean-room**).** Execute `red`: write a failing enforcement test asserting the `route` TDT row + Invocation in `multimodal-dispatch/SKILL.md` either reference an existing card or are removed, and that the `push-artifacts` core card routes correctly. **→ SC-4**
- [ ] 22. **GREEN — SC-4 (**clean-room**).** Execute `green`: apply the two resolutions — remove the stale `route` TDT row + Invocation and reroute its triggers to `dispatch`; finalize `issue-operations-core/tasks/push-artifacts.md` as a thin core dispatcher routing by `github.platform` and capturing `artifact_url`. **→ SC-4**
- [ ] 23. **Post-regression (**clean-room**).** Run regression test patterns after GREEN. **→ post-GREEN regression clean**
- [ ] 24. **Verify — SC-4 (**clean-room**).** Execute `verify`: confirm the `route` and `push-artifacts` TDT rows/Invocation reference an existing card or are removed, with no dangling reference remaining. **→ SC-4**
- [ ] 25. **Commit — SC-4 (**inline**).** Stage and commit the two special-case resolutions with their enforcement test as one atomic slice. **→ SC-4 committed**
- [ ] 26. **Pre-regression (**sub-agent**).** Execute `pre-regression` to establish the baseline for the SC-3 string-evidence verification. **→ baseline before RED**
- [ ] 27. **Pre-regression verify (**clean-room**).** Verify the pre-regression results. **→ baseline verified**
- [ ] 28. **RED — SC-3 (**clean-room**).** Execute `red`: write a failing enforcement test that cross-references all TDTs and Invocations in `.opencode/skills/**/SKILL.md` against the task cards on disk, asserting no TDT references a non-existent task card. **→ SC-3**
- [ ] 29. **GREEN — SC-3 (**clean-room**).** Execute `green`: reconcile any remaining dangling references surfaced by the RED test (expected to be none after the SC-4 resolutions). **→ SC-3**
- [ ] 30. **Post-regression (**clean-room**).** Run regression test patterns after GREEN. **→ post-GREEN regression clean**
- [ ] 31. **Verify — SC-3 (**clean-room**).** Execute `verify`: cross-reference all TDTs against the filesystem and confirm no TDT references a non-existent task card. **→ SC-3**
- [ ] 32. **Commit — SC-3 (**inline**).** Stage and commit the integrity gate (and any reconciliation) with its enforcement test as one atomic slice. **→ SC-3 committed**
- [ ] 33. **VbC (**clean-room**).** Verify SC-4 and SC-3 PASS against the present deliverables: no dangling `route` reference remains, `push-artifacts` is a thin core dispatcher, and cross-referencing all TDTs against the filesystem finds no reference to a non-existent task card. Any non-clean verdict coerces to FAIL. **→ SC-4, SC-3**

---

## Exit Criteria

- [ ] C1. All 10 STILL-MISSING task card files exist as `.md` files in their respective `tasks/` directories (SC-1), with `multimodal-dispatch/route` resolved per SC-4.
- [ ] C2. The two brainstorming cards (`top-down-analysis.md`, `cross-scope.md`) contain all required procedure per §Brainstorming Task Card Requirements (SC-1.1).
- [ ] C3. Each of the 10 new task cards has entry criteria, inline steps, and exit criteria (SC-2).
- [ ] C4. The two special-case dangling references (`route`, `push-artifacts`) are resolved with no dangling reference remaining (SC-4).
- [ ] C5. No TDT references a non-existent task card across the entire skill deck (SC-3).

---

## Lifecycle Events

| Timestamp (UTC) | Event | Detail |
|------------------|-------|--------|
| 2026-08-29T06:37:37Z | `plan_created` | Plan file: `.opencode/.issues/2039/plan.md`; phase count: 2 |
