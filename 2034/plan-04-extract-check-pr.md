# Phase 4 — Extract Phases 4-5 from check-pr.md (workflow boundary violation)

## Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Workflow boundary violation — remove cleanup actions from check-pr.md (a scanning workflow) |
| **Files** | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` |
| **SCs** | SC-4, SC-5 |
| **Dependencies** | Phase 3 (branch-cleanup.md must be verified first — extracted content routes to it) |
| **Entry** | Phase 3 complete — branch-cleanup.md verified as existing and correct |
| **Exit** | Phases 4-5 removed from check-pr.md; check-pr.md updated to delegate branch cleanup to cleanup workflow |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-4 | Extract Phases 4-5 (cleanup actions) from check-pr.md | 4 | 13, 14 |
| SC-5 | Update check-pr.md to delegate branch cleanup to cleanup workflow | 4 | 15, 16 |

## Safety/Rollback

**Phase 4 — Safety/Rollback:**
- Destructive operations: Removing Phases 4-5 from check-pr.md (file deletion of procedural content)
- Rollback plan: `git checkout .opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- Data loss risk: low (content is being removed from a scanning workflow, not deleted from the repo — it belongs in cleanup workflow)

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 13 | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` lines 108-123 | ✅ | Read file — Phase 4 (Submodule Branch Cleanup) at lines 108-114, Phase 5 (Parent Branch Cleanup) at lines 115-123 |
| 15 | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` Exit Criteria | ✅ | Exit Criteria references submodule and parent branch cleanup |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Phase 4 (Submodule Branch Cleanup) exists at lines 108-114 | `read(.opencode/skills/git-workflow-cleanup/tasks/check-pr.md)` lines 108-114 | ✅ |
| Phase 5 (Parent Branch Cleanup) exists at lines 115-123 | `read(.opencode/skills/git-workflow-cleanup/tasks/check-pr.md)` lines 115-123 | ✅ |
| Exit Criteria references branch cleanup | `read(.opencode/skills/git-workflow-cleanup/tasks/check-pr.md)` lines 25-29 | ✅ |

## Code Path Coverage

| Code Path | Covered By |
|-----------|-----------|
| check-pr.md Phase 4 (Submodule Branch Cleanup) | Step 13 |
| check-pr.md Phase 5 (Parent Branch Cleanup) | Step 13 |
| check-pr.md Exit Criteria (branch cleanup references) | Step 15 |

## Cross-Cutting SCs

| SC ID | Applies? | Note |
|-------|----------|------|
| SC-4 | ✅ | Primary SC — remove Phases 4-5 |
| SC-5 | ✅ | Primary SC — delegate to cleanup workflow |

## Interface Boundaries

| Interface | Relevance |
|-----------|-----------|
| check-pr.md → cleanup workflow | Delegation boundary — check-pr must route to cleanup instead of doing inline work |

## State Transitions

| From | To | Trigger |
|------|----|---------|
| check-pr.md contains Phases 4-5 | check-pr.md delegates to cleanup workflow | Edit of check-pr.md |

## Step-by-Step

- [ ] 13. **Remove Phase 4 (Submodule Branch Cleanup) from check-pr.md (**sub-agent**).** Edit `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`: remove lines 108-114 (Phase 4: Submodule Branch Cleanup). **→ SC-4**

- [ ] 14. **Remove Phase 5 (Parent Branch Cleanup) from check-pr.md (**sub-agent**).** Edit `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`: remove lines 115-123 (Phase 5: Parent Branch Cleanup). **→ SC-4**

- [ ] 15. **Update check-pr.md Exit Criteria to remove branch cleanup references (**sub-agent**).** Edit `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` Exit Criteria (lines 25-29): remove references to submodule branch cleanup and parent branch cleanup. Add a delegation note: "Branch cleanup is delegated to the cleanup workflow." **→ SC-5**

- [ ] 16. **Update check-pr.md Phase 3 to delegate to cleanup workflow (**sub-agent**).** After Phase 3 (Close Linked Issues), add a step: "After issue closure, delegate branch cleanup to the cleanup workflow: `skill({name: "git-workflow-cleanup"})` → `task(..., prompt: "execute cleanup from git-workflow-cleanup")`." **→ SC-5**

- [ ] 17. **Verify the edits (**inline**).** Run `grep -n 'Submodule Branch Cleanup\|Parent Branch Cleanup' .opencode/skills/git-workflow-cleanup/tasks/check-pr.md` and confirm both patterns are absent. **→ SC-4, SC-5**

- [ ] 18. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md && git commit -m "Phase 4: extract Phases 4-5 from check-pr.md — delegate branch cleanup to cleanup workflow"`

### Phase 4 VbC

- [ ] 18. **VbC (**clean-room**).** Verify: (a) "Submodule Branch Cleanup" and "Parent Branch Cleanup" sections are absent from check-pr.md, (b) check-pr.md delegates branch cleanup to cleanup workflow. Evidence: grep output from Step 17. **→ SC-4, SC-5 (evidence_type: string)**

**Concern transition:** Leaving check-pr.md extraction → entering behavioral enforcement test. Phase 5 depends on all prior phases (Phases 1-4 must be complete for the behavioral test to verify the full routing pipeline).
