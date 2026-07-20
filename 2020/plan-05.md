---
title: "Phase 5: Add critical violation to guidelines"
phase: 5
issue: 2020
status: draft
risk: low
Dispatch: sub-agent
---

## Entry Criteria

- [ ] Phase 4 complete
- [ ] Phase 4 Z3 check passed

## Steps

- [ ] 19. Verify SC-16 is not already resolved (**sub-agent**)

    Check `000-critical-rules.md` for existing entry on sub-agent task() dispatch. Research indicates this may already be RESOLVED.

- [ ] 20. Add critical violation entry (if not already present) (**sub-agent**)

    If SC-16 is not already resolved, add new critical-rules-XXX entry to `000-critical-rules.md` for sub-agent task() dispatch prohibition.

- [ ] 21. Z3 check — solve check verify fix output (**sub-agent**)

    Run `.opencode/tools/solve check` with the fix contract.

## Exit Criteria

- [ ] SC-16 verified PASS (either already resolved or newly added) — verify: `grep -c 'sub-agent.*task()\|task().*sub-agent' .opencode/guidelines/000-critical-rules.md` > 0
- [ ] Z3 check passes — verify: `.opencode/tools/solve check` exits 0

### Evidence Type Annotations

| SC | Evidence Type | Verification Method |
|----|---------------|---------------------|
| SC-16 | string | `grep` exit code + `.opencode/tools/solve check` exit code |

## SC Coverage

- SC-16 (critical-rules.md entry)

## Notes

> **Phase 5 may be a no-op.** Research indicates SC-16 is already RESOLVED — `000-critical-rules.md` already has the critical-rules-XXX entry for sub-agent task() dispatch. Verify before executing.

## Safety Rollback

```bash
git checkout -- .opencode/guidelines/000-critical-rules.md
```
