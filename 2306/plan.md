---
plan_schema_version: "1.0"
issue: 2306
title: "Bound submodule-sync task card scope to direct pointers and forbid recursion"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2306 — Bound submodule-sync task card scope to direct pointers and forbid recursion

**Goal:** Modify the `submodule-sync.md` task card so it bounds scope to the parent repo's direct submodule pointers, forbids recursion and `git submodule foreach`, mirrors the standing no-`--recursive` guideline, directs explicit per-submodule operations, documents false-pointer-flag avoidance, and preserves the existing `--ff-only` divergence handling unchanged.

**Architecture:** This is a documentation/instruction fix on a single file — `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`. No runtime code changes. Each success criterion is a string-evidence content-presence assertion verified by reading the task card. The authoritative no-`--recursive` wording is mirrored verbatim from `.opencode/guidelines/060-tool-usage.md` §4. The existing `--ff-only` divergence block is preserved byte-identical.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` (modify)
- `.opencode/guidelines/060-tool-usage.md` §4 (read-only reference source, unchanged)

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**clean-room**).** Verify the structure artifact, spec, and this plan are mutually coherent: all 7 SCs map to exactly one phase, no item covers multiple SCs, and the phase DAG (Phase 1 → Phase 2) has no circular dependency.
- [ ] 2. **Baseline check (**clean-room**).** Capture the pre-change state of `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`, recording the exact bytes of the `--ff-only` divergence block (lines 15-39) so SC-7 can assert byte-identical preservation. Confirm the feature branch exists and the working tree is clean.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Bound scope and forbid recursion | `test-driven-development` | `red` | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | SC-1, SC-2, SC-3, SC-4, SC-5 | — |
| 2 — False-flag avoidance and divergence preservation | `test-driven-development` | `red` | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | SC-6, SC-7 | 1 |

---

## Phase Details

### Phase 1 — Bound scope and forbid recursion

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-5 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-branch/tasks/submodule-sync.md
sc_ids: [SC-1, SC-2, SC-3, SC-4, SC-5]
scope_bound: "parent repo direct submodule pointers passed in submodule_paths"
recursion_forbidden: true
foreach_forbidden: true
no_recursive_mirror_source: ".opencode/guidelines/060-tool-usage.md §4"
per_submodule_directive: "explicit git -C <path> operations"
```

### Phase 2 — False-flag avoidance and divergence preservation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` |
| SCs | SC-6, SC-7 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-branch/tasks/submodule-sync.md
sc_ids: [SC-6, SC-7]
false_flag_note: "syncing a submodule to its own trunk tip must not be reported as a parent pointer change"
divergence_block: "preserve byte-identical from pre-change baseline"
```

---

## Exit Criteria

- [ ] C1. The task card explicitly bounds scope to the parent repo's direct submodule pointers passed in `submodule_paths` (SC-1).
- [ ] C2. The task card explicitly forbids recursion into nested submodules (SC-2).
- [ ] C3. The task card explicitly forbids `git submodule foreach` for the sync operation (SC-3).
- [ ] C4. The task card mirrors the standing no-`--recursive` guideline from `060-tool-usage.md` §4 (SC-4).
- [ ] C5. The task card directs explicit per-submodule `git -C <path>` operations (SC-5).
- [ ] C6. The task card documents that syncing a submodule to its own trunk tip must not be reported as a parent pointer change (SC-6).
- [ ] C7. The existing `--ff-only` divergence handling is preserved byte-identical to the pre-change state (SC-7).
