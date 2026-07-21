# Phase 3 — Verify existing branch-cleanup.md and update cleanup.md reference

## Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Verify cleanup/branch-cleanup.md exists and is correct; update cleanup.md Step 3 description if needed |
| **Files** | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`, `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` |
| **SCs** | SC-3, SC-7 |
| **Dependencies** | None (independent) |
| **Entry** | Phase 3 is independent — no prior phase required |
| **Exit** | branch-cleanup.md verified as existing and correct; cleanup.md Step 3 description matches actual content |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-3 | Verify cleanup/branch-cleanup.md exists and cleanup.md Step 3 reference is correct | 3 | 9, 10, 11 |
| SC-7 | cleanup.md Step 3 description matches actual branch-cleanup.md content | 3 | 10, 11 |

## Safety/Rollback

**Phase 3 — Safety/Rollback:**
- Destructive operations: None (read-only verification; optional text edit)
- Rollback plan: `git checkout .opencode/skills/git-workflow-cleanup/tasks/cleanup.md` (if edited)
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 9 | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | ✅ | File exists at 471 lines with complete branch cleanup logic (Steps 0-6) |
| 10 | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` line 118 | ✅ | Read file — Step 3 routes to `cleanup/branch-cleanup` |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| branch-cleanup.md exists at `tasks/cleanup/branch-cleanup.md` | `glob` + `read` — 471 lines, Steps 0-6 | ✅ |
| cleanup.md Step 3 routes to `cleanup/branch-cleanup` | `read(.opencode/skills/git-workflow-cleanup/tasks/cleanup.md)` line 116 | ✅ |

## Code Path Coverage

| Code Path | Covered By |
|-----------|-----------|
| cleanup.md Step 3 → cleanup/branch-cleanup route | Step 10 |
| branch-cleanup.md content verification | Step 9 |

## Cross-Cutting SCs

| SC ID | Applies? | Note |
|-------|----------|------|
| SC-3 | ✅ | Primary SC — verify file exists and reference is correct |
| SC-7 | ✅ | Primary SC — description matches content |

## Interface Boundaries

| Interface | Relevance |
|-----------|-----------|
| cleanup.md Step 3 → branch-cleanup.md | Route verification |

## State Transitions

| From | To | Trigger |
|------|----|---------|
| Unknown branch-cleanup.md state | Verified correct state | Read + confirm |

## Step-by-Step

- [ ] 9. **Read and verify branch-cleanup.md (**sub-agent**).** Read `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`. Confirm it contains complete branch cleanup logic: closure-verification (Step 0), trunk sync, submodule descent, worktree removal, content verification, checkpoint tag deletion, branch deletion. **→ SC-3**

- [ ] 10. **Read cleanup.md Step 3 and compare description (**sub-agent**).** Read `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` lines 114-118. Compare the Step 3 description ("Switches to dev, syncs with remote, removes feature worktree, deletes merged branches, tasks sub-agent via task() for each submodule, verifies clean state") against actual branch-cleanup.md content. If misaligned, update the description. **→ SC-3, SC-7**

- [ ] 11. **Verify the route target exists (**inline**).** Run `ls .opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` to confirm the file exists. **→ SC-3**

- [ ] 12. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/cleanup.md && git commit -m "Phase 3: verify branch-cleanup.md and update cleanup.md reference"` (only if cleanup.md was edited; otherwise skip commit)

### Phase 3 VbC

- [ ] 12. **VbC (**clean-room**).** Verify: (a) branch-cleanup.md exists and contains complete branch cleanup logic, (b) cleanup.md Step 3 description matches actual branch-cleanup.md content. **→ SC-3, SC-7 (evidence_type: string)**

**Concern transition:** Leaving branch-cleanup.md verification → entering check-pr.md extraction. Phase 4 depends on Phase 3 (extracted content routes to branch-cleanup.md which must be verified first).
