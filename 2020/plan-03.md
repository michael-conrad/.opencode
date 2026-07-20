---
title: "Phase 3: Fix writing-plans/SKILL.md dispatch classification and related defects"
phase: 3
issue: 2020
status: draft
risk: low
Dispatch: sub-agent
---

## Entry Criteria

- [ ] Phase 2 complete (general Invocation fix applied)
- [ ] Phase 2 Z3 check passed

## Steps

- [ ] 7. Fix TDT classification (D1) (**sub-agent**)

    Change `create`, `retroactive` from `sub-task` to `orchestrator` in writing-plans/SKILL.md Trigger Dispatch Table. Add `completion` entry as `orchestrator`.

- [ ] 8. Fix Invocation table (D2) (**sub-agent**)

    Fix Invocation — `create` is orchestrator-executed, not `task()` dispatched.

- [ ] 9. Fix audit-fidelity.md (D3) (**sub-agent**)

    Remove "with auditor sub-agent type context" from `writing-plans-creation/tasks/audit-fidelity.md`.

- [ ] 10. Fix audit-concern.md (D3) (**sub-agent**)

    Remove "with auditor sub-agent type context" from `writing-plans-creation/tasks/audit-concern.md`.

- [ ] 11. Fix Sub-Agent Routing claims (D6) (**sub-agent**)

    Remove "All tasks run via `task()`" and "No inline work" claims from writing-plans/SKILL.md Sub-Agent Routing section.

- [ ] 12. Add dual pattern explanation (D4) (**sub-agent**)

    Add dual pattern explanation to `.issues/{N}/` references in writing-plans/SKILL.md.

- [ ] 12.5. Fix completion.md path reference (D7) (**sub-agent**)

    Fix `completion.md` path reference: change `completion-core/completion-core.md` to `completion-core/SKILL.md` in `writing-plans-creation/tasks/completion.md`.

- [ ] 13. Z3 check — solve check verify fix output (**sub-agent**)

    Run `.opencode/tools/solve check` with the fix contract.

## Exit Criteria

- [ ] All writing-plans defects (D1-D7) resolved — verify: audit artifact shows all 7 defects marked RESOLVED
- [ ] writing-plans/SKILL.md consistent with general fix from Phase 2 — verify: `grep -c 'orchestrator' .opencode/skills/writing-plans/SKILL.md` > 0
- [ ] Z3 check passes — verify: `.opencode/tools/solve check` exits 0

### Evidence Type Annotations

| SC | Evidence Type | Verification Method |
|----|---------------|---------------------|
| SC-2 | string | audit artifact inspection |
| SC-3 | string | audit artifact inspection |
| SC-4 | string | audit artifact inspection |
| SC-5 | string | audit artifact inspection |
| SC-6 | string | audit artifact inspection |
| SC-7 | string | audit artifact inspection |
| SC-8 | string | `grep` exit code |
| SC-9 | string | `grep` exit code |
| SC-10 | string | audit artifact inspection |
| SC-11 | string | audit artifact inspection |

## SC Coverage

- SC-2 (create classified as orchestrator)
- SC-3 (retroactive classified as orchestrator)
- SC-4 (completion entry as orchestrator)
- SC-5 (Invocation does not dispatch create as task())
- SC-6 (audit-fidelity.md clean)
- SC-7 (audit-concern.md clean)
- SC-8 (no "All tasks run via task()")
- SC-9 (no "No inline work")
- SC-10 (completion.md references correct path)
- SC-11 (dual pattern explanation for .issues/ refs)

## Safety Rollback

```bash
git checkout -- .opencode/skills/writing-plans/SKILL.md .opencode/skills/writing-plans-creation/tasks/
```

## Concern Transition

Phase 3 specific fix must not conflict with Phase 2 general fix. Sequential required.
