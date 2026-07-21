# Phase 1 — Fix trigger routing in git-workflow/SKILL.md

## Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Parent SKILL.md trigger routing — "pr merged" must map to cleanup, not check-pr |
| **Files** | `.opencode/skills/git-workflow/SKILL.md` |
| **SCs** | SC-1 |
| **Dependencies** | None (independent) |
| **Entry** | Phase 1 is independent — no prior phase required |
| **Exit** | "pr merged" removed from check-pr row and added to cleanup row in Trigger Dispatch Table |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Fix trigger routing in git-workflow/SKILL.md — "pr merged" maps to cleanup | 1 | 1, 2, 3 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (text edits only)
- Rollback plan: `git checkout .opencode/skills/git-workflow/SKILL.md`
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `.opencode/skills/git-workflow/SKILL.md` line 35 (check-pr row) | ✅ | Read file — line 35 has `"check pr" / "check prs" / "check merged prs" / "pr merged"` |
| 2 | `.opencode/skills/git-workflow/SKILL.md` line 34 (cleanup row) | ✅ | Read file — line 34 has `"cleanup" / "post-merge cleanup"` |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| check-pr row at line 35 contains "pr merged" | `read(.opencode/skills/git-workflow/SKILL.md)` line 35 | ✅ |
| cleanup row at line 34 does not contain "pr merged" | `read(.opencode/skills/git-workflow/SKILL.md)` line 34 | ✅ |

## Code Path Coverage

| Code Path | Covered By |
|-----------|-----------|
| Trigger Dispatch Table routing — "pr merged" → cleanup | Step 1, Step 2 |

## Cross-Cutting SCs

| SC ID | Applies? | Note |
|-------|----------|------|
| SC-1 | ✅ | Primary SC for this phase |

## Interface Boundaries

| Interface | Relevance |
|-----------|-----------|
| git-workflow/SKILL.md Trigger Dispatch Table | Direct edit target |

## State Transitions

| From | To | Trigger |
|------|----|---------|
| "pr merged" → check-pr | "pr merged" → cleanup | Edit of Trigger Dispatch Table |

## Step-by-Step

- [ ] 1. **Remove "pr merged" from check-pr trigger row (**sub-agent**).** Edit `.opencode/skills/git-workflow/SKILL.md` line 35: change `"check pr" / "check prs" / "check merged prs" / "pr merged"` to `"check pr" / "check prs" / "check merged prs"`. **→ SC-1**

- [ ] 2. **Add "pr merged" to cleanup trigger row (**sub-agent**).** Edit `.opencode/skills/git-workflow/SKILL.md` line 34: change `"cleanup" / "post-merge cleanup"` to `"cleanup" / "post-merge cleanup" / "pr merged"`. **→ SC-1**

- [ ] 3. **Verify the edit (**inline**).** Run `grep -n 'pr merged' .opencode/skills/git-workflow/SKILL.md` and confirm "pr merged" appears ONLY in the cleanup row (line 34), NOT in the check-pr row (line 35). **→ SC-1**

- [ ] 4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/SKILL.md && git commit -m "Phase 1: fix trigger routing in git-workflow/SKILL.md — 'pr merged' maps to cleanup"`

### Phase 1 VbC

- [ ] 4. **VbC (**clean-room**).** Verify: (a) "pr merged" is absent from check-pr row in Trigger Dispatch Table, (b) "pr merged" is present in cleanup row. Evidence: grep output from Step 3. **→ SC-1 (evidence_type: string)**

**Concern transition:** Leaving parent SKILL.md trigger routing → entering cleanup SKILL.md trigger routing. Phase 2 is independent of Phase 1.
