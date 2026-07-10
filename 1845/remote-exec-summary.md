## Exec Summary

The change-control task (`spec-creation/tasks/change-control.md`) does not mandate re-audit after fixing audit findings. Step 3 asks "Whether the change requires re-audit" as an advisory question — sub-agents can classify fixes as non-substantive and skip re-audit. When a revision is triggered by spec-audit FAILs, re-audit must be mandatory to confirm the fixes actually resolved the findings.

### Cards (dependency order)
1. **Update exit criteria** — Add "All prior audit FAILs resolved to PASS" when revision was audit-triggered
2. **Add mandatory re-audit step** — Insert between Step 3 (Impact Analysis) and Step 4 (HALT)
3. **Verify** — Confirm the change-control task enforces re-audit for audit-triggered revisions

### Key Decisions
- Re-audit is mandatory only when the revision was triggered by spec-audit FAILs, not for all revisions
- The re-audit step dispatches `audit --task spec-audit` and confirms all prior FAILs are now PASS

### Risk Callouts
- None — this is a procedural addition, not a behavioral change
