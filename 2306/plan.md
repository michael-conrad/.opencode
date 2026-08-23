---
plan_schema_version: "1.0"
issue: 2306
title: "Bound submodule-sync task card scope to direct pointers and forbid recursion"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2306 — Bound submodule-sync task card scope to direct pointers and forbid recursion

**Goal:** Modify the `submodule-sync.md` task card so it bounds scope to the parent repo's direct submodule pointers, forbids recursion into nested submodules while permitting explicit per-submodule operations including non-recursive `git submodule foreach`, mirrors the standing no-`--recursive` guideline verbatim from `.opencode/guidelines/060-tool-usage.md` §4, directs explicit per-submodule operations, documents false-pointer-flag avoidance, and preserves the existing `--ff-only` divergence handling unchanged.

**Architecture:** This is a documentation/instruction fix on a single file — `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`. No runtime code changes. Success criteria SC-1..SC-6 are behavioral evidence type verified by `opencode run` real-domain prompts with stderr assertions. SC-7 is string evidence type verified by byte-identical comparison. The authoritative no-`--recursive` wording is mirrored verbatim from `.opencode/guidelines/060-tool-usage.md` §4. Explicit per-submodule operations — including `git submodule foreach` without `--recursive` — are permitted under guideline §4 and MUST NOT be blanket-forbidden. The existing `--ff-only` divergence block is preserved byte-identical.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` (modify)
- `.opencode/guidelines/060-tool-usage.md` §4 (read-only reference source, unchanged)

---

## Pre-Implementation

- [ ] 1. **Coherence gate (clean-room).** Verify the structure artifact, spec, and this plan are mutually coherent: all 7 SCs map to exactly one phase, no item covers multiple SCs, and the phase DAG (Phase 1 → Phase 2) has no circular dependency.
- [ ] 2. **Baseline check (clean-room).** Capture the pre-change state of `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`, recording the exact bytes of the `--ff-only` divergence block (lines 15-39) so SC-7 can assert byte-identical preservation. Confirm the feature branch exists and the working tree is clean.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Bound scope, forbid recursion, permit non-recursive foreach, mirror no-`--recursive` verbatim | `test-driven-development` | `red` | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | SC-1, SC-2, SC-3, SC-4, SC-5 | — |
| 2 — False-flag avoidance and divergence preservation | `test-driven-development` | `red` | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | SC-6, SC-7 | 1 |

---

## Phase Details

### Phase 1 — Bound scope, forbid recursion, permit non-recursive foreach, mirror no-`--recursive` verbatim

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
explicit_per_submodule_permitted: true
non_recursive_foreach_permitted: "git submodule foreach without --recursive"
blanket_foreach_prohibition_forbidden: true
no_recursive_mirror_source: ".opencode/guidelines/060-tool-usage.md §4"
no_recursive_mirror_verbatim: "NEVER use --recursive with any git submodule command (e.g., git submodule update --init --recursive, git clone --recursive). The --recursive flag can pull in unintended nested submodules, cause unexpected network traffic, break reproducibility by implicitly resolving submodule chains, and conflict with explicit submodule management. Always use git submodule update --init (without --recursive) or explicit per-submodule operations."
per_submodule_directive: "explicit git -C <path> operations"
evidence_type_sc1_sc5: "behavioral"
evidence_type_sc7: "string"
```

**Procedure:**
- [ ] 3. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing behavioral enforcement test via `opencode run` real-domain prompt asserting the agent does NOT perform explicit per-submodule operations on `submodule_paths` without recursion. **→ SC-1**
- [ ] 4. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Add the scope-bound statement to Step 2 of the task card. **→ SC-1**
- [ ] 5. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-1.
- [ ] 6. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing behavioral enforcement test via `opencode run` real-domain prompt asserting the agent does NOT refuse to recurse into nested submodules. **→ SC-2**
- [ ] 7. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Add the recursion prohibition to Step 2 of the task card. **→ SC-2**
- [ ] 8. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-2.
- [ ] 9. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing behavioral enforcement test via `opencode run` real-domain prompt asserting the agent does NOT permit explicit per-submodule operations including non-recursive `git submodule foreach`, or contains a blanket `foreach` prohibition. **→ SC-3**
- [ ] 10. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Add a statement permitting explicit per-submodule operations, including `git submodule foreach` without `--recursive`, and remove any blanket `foreach` prohibition. **→ SC-3**
- [ ] 11. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-3.
- [ ] 12. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing behavioral enforcement test via `opencode run` real-domain prompt asserting the task card lacks the verbatim no-`--recursive` constraint from guideline §4. **→ SC-4**
- [ ] 13. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Add the verbatim no-`--recursive` constraint from `060-tool-usage.md` §4. **→ SC-4**
- [ ] 14. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-4.
- [ ] 15. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing behavioral enforcement test via `opencode run` real-domain prompt asserting the task card does NOT direct explicit per-submodule operations. **→ SC-5**
- [ ] 16. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Add an explicit per-submodule `git -C <path>` operation directive to the task card. **→ SC-5**
- [ ] 17. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-5.
- [ ] 18. **VbC (clean-room).** Dispatch `execute verify task from verification-before-completion`. Read the task card and assert all five Phase 1 SCs (SC-1..SC-5) are satisfied via behavioral verification. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

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
evidence_type_sc6: "behavioral"
evidence_type_sc7: "string"
```

**Procedure:**
- [ ] 19. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing behavioral enforcement test via `opencode run` real-domain prompt asserting the task card does NOT document false-pointer-flag avoidance. **→ SC-6**
- [ ] 20. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Add a note that syncing a submodule to its own trunk tip must not be reported as a parent pointer change. **→ SC-6**
- [ ] 21. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-6.
- [ ] 22. **RED (sub-agent).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the `--ff-only` divergence block differs from the pre-change baseline. **→ SC-7**
- [ ] 23. **GREEN (sub-agent).** Dispatch `execute green task from test-driven-development`. Ensure the divergence block is unchanged (no-op if already preserved). **→ SC-7**
- [ ] 24. **Checkpoint commit (inline).** Stage and commit the task card text change for SC-7 (or no-op if already preserved).
- [ ] 25. **VbC (clean-room).** Dispatch `execute verify task from verification-before-completion`. Read the task card and assert both Phase 2 SCs (SC-6, SC-7) are satisfied. **→ SC-6, SC-7**

---

## Post-Implementation

- [ ] 26. **Structural checks (sub-agent).** Dispatch `execute checklist task from finishing-a-development-branch`. Run the finishing checklist (lint, typecheck, format) on the modified task card and confirm no regressions.
- [ ] 27. **Verification (clean-room).** Dispatch `execute verify task from verification-before-completion`. Read all SC verdicts (SC-1..SC-7); BLOCK if any FAIL. Confirm all 7 SCs pass with appropriate evidence (behavioral for SC-1..SC-6, string for SC-7).
- [ ] 28. **Audit (clean-room).** Dispatch `execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first`, followed by validator, evaluator, arbiter in sequence. Adversarially audit the task card change against the spec.
- [ ] 29. **Cross-validate (clean-room).** Independently re-verify the deliverable against the spec's success criteria, confirming SC-7's divergence block is byte-identical to the pre-change baseline.
- [ ] 30. **Review-prep (sub-agent).** Dispatch `execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first`. Prepare PR review context.
- [ ] 31. **Create PR (sub-agent).** Dispatch `execute create task from git-workflow-pr`. Create the pull request for the task card change.
- [ ] 32. **Completion (sub-agent).** Dispatch `execute completion task from completion-core`. Generate the completion executive summary.

---

## Exit Criteria

- [ ] C1. The task card explicitly bounds scope to the parent repo's direct submodule pointers passed in `submodule_paths` (SC-1).
- [ ] C2. The task card explicitly forbids recursion into nested submodules (SC-2).
- [ ] C3. The task card permits explicit per-submodule operations, including `git submodule foreach` without `--recursive`, with no blanket `foreach` prohibition (SC-3).
- [ ] C4. The task card mirrors the standing no-`--recursive` guideline from `060-tool-usage.md` §4 verbatim (SC-4).
- [ ] C5. The task card directs explicit per-submodule `git -C <path>` operations (SC-5).
- [ ] C6. The task card documents that syncing a submodule to its own trunk tip must not be reported as a parent pointer change (SC-6).
- [ ] C7. The existing `--ff-only` divergence handling is preserved byte-identical to the pre-change state (SC-7).

---

## Lifecycle Events

- **2026-08-23T18:58:00Z** — `plan_created` — Plan file: `.opencode/.issues/2306/plan.md`, Phase count: 2