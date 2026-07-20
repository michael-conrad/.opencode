---
title: "Phase 4: Fix assemble-work.md content completeness"
phase: 4
issue: 2020
status: draft
risk: low
Dispatch: sub-agent
---

## Entry Criteria

- [ ] Phase 3 complete
- [ ] Phase 3 Z3 check passed

## Steps

- [ ] 14. Add entry proof marker (**sub-agent**)

    Add Step 1.5 entry proof marker to `tasks/assemble-work.md` (per `git-workflow/tasks/cleanup/branch-cleanup.md:377`).

- [ ] 15. Add OVERFLOW handling (**sub-agent**)

    Add OVERFLOW handling to `tasks/assemble-work.md` (per `implementation-pipeline/enforcement/overflow-signal.md:18`).

- [ ] 16. Add work state verification (**sub-agent**)

    Add work state verification to `tasks/assemble-work.md` (per `implementation-pipeline/enforcement/work-state-verification.md:5`).

- [ ] 17. Add completion checkpoint (**sub-agent**)

    Add post-sub-agent completion checkpoint with hash mismatch detection to `tasks/assemble-work.md` (per `pre-analysis/tasks/analyze.md:130`).

- [ ] 18. Z3 check — solve check verify fix output (**sub-agent**)

    Run `.opencode/tools/solve check` with the fix contract.

## Exit Criteria

- [ ] All 4 content sections added to assemble-work.md — verify: `grep -c 'entry proof\|OVERFLOW\|work state\|completion checkpoint' .opencode/skills/implementation-pipeline/tasks/assemble-work.md` >= 4
- [ ] Z3 check passes — verify: `.opencode/tools/solve check` exits 0

### Evidence Type Annotations

| SC | Evidence Type | Verification Method |
|----|---------------|---------------------|
| SC-12 | string | `grep` exit code |
| SC-13 | string | `grep` exit code |
| SC-14 | string | `grep` exit code |
| SC-15 | string | `grep` exit code |

## SC Coverage

- SC-12 (entry proof marker)
- SC-13 (OVERFLOW handling)
- SC-14 (work state verification)
- SC-15 (completion checkpoint)

## Safety Rollback

```bash
git checkout -- .opencode/skills/implementation-pipeline/tasks/assemble-work.md
```
