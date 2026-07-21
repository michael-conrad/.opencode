# Phase 2 — Fix trigger routing in git-workflow-cleanup/SKILL.md

## Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Cleanup SKILL.md trigger routing — "pr merged" must map to cleanup, not check-pr |
| **Files** | `.opencode/skills/git-workflow-cleanup/SKILL.md` |
| **SCs** | SC-2 |
| **Dependencies** | None (independent) |
| **Entry** | Phase 2 is independent — no prior phase required |
| **Exit** | "pr merged" removed from check-pr row and added to cleanup row in git-workflow-cleanup/SKILL.md Trigger Dispatch Table |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-2 | Fix trigger routing in git-workflow-cleanup/SKILL.md — "pr merged" maps to cleanup | 2 | 5, 6, 7 |

## Safety/Rollback

**Phase 2 — Safety/Rollback:**
- Destructive operations: None (text edits only)
- Rollback plan: `git checkout .opencode/skills/git-workflow-cleanup/SKILL.md`
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 5 | `.opencode/skills/git-workflow-cleanup/SKILL.md` line 19 (check-pr row) | ✅ | Read file — line 19 has `"check pr" / "check prs" / "check merged prs" / "pr merged"` |
| 6 | `.opencode/skills/git-workflow-cleanup/SKILL.md` line 18 (cleanup row) | ✅ | Read file — line 18 has `"cleanup" / "post-merge cleanup"` |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| check-pr row at line 19 contains "pr merged" | `read(.opencode/skills/git-workflow-cleanup/SKILL.md)` line 19 | ✅ |
| cleanup row at line 18 does not contain "pr merged" | `read(.opencode/skills/git-workflow-cleanup/SKILL.md)` line 18 | ✅ |

## Code Path Coverage

| Code Path | Covered By |
|-----------|-----------|
| Trigger Dispatch Table routing — "pr merged" → cleanup | Step 5, Step 6 |

## Cross-Cutting SCs

| SC ID | Applies? | Note |
|-------|----------|------|
| SC-2 | ✅ | Primary SC for this phase |

## Interface Boundaries

| Interface | Relevance |
|-----------|-----------|
| git-workflow-cleanup/SKILL.md Trigger Dispatch Table | Direct edit target |

## State Transitions

| From | To | Trigger |
|------|----|---------|
| "pr merged" → check-pr | "pr merged" → cleanup | Edit of Trigger Dispatch Table |

## Step-by-Step

- [ ] 5. **Remove "pr merged" from check-pr trigger row (**sub-agent**).** Edit `.opencode/skills/git-workflow-cleanup/SKILL.md` line 19: change `"check pr" / "check prs" / "check merged prs" / "pr merged"` to `"check pr" / "check prs" / "check merged prs"`. **→ SC-2**

- [ ] 6. **Add "pr merged" to cleanup trigger row (**sub-agent**).** Edit `.opencode/skills/git-workflow-cleanup/SKILL.md` line 18: change `"cleanup" / "post-merge cleanup"` to `"cleanup" / "post-merge cleanup" / "pr merged"`. **→ SC-2**

- [ ] 7. **Verify the edit (**inline**).** Run `grep -n 'pr merged' .opencode/skills/git-workflow-cleanup/SKILL.md` and confirm "pr merged" appears ONLY in the cleanup row (line 18), NOT in the check-pr row (line 19). **→ SC-2**

- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/SKILL.md && git commit -m "Phase 2: fix trigger routing in git-workflow-cleanup/SKILL.md — 'pr merged' maps to cleanup"`

### Phase 2 VbC

- [ ] 8. **VbC (**clean-room**).** Verify: (a) "pr merged" is absent from check-pr row in Trigger Dispatch Table, (b) "pr merged" is present in cleanup row. Evidence: grep output from Step 7. **→ SC-2 (evidence_type: string)**

**Concern transition:** Leaving cleanup SKILL.md trigger routing → entering branch-cleanup.md verification. Phase 3 is independent of Phase 2.
