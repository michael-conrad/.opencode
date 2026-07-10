# Plan: change-control task must mandate re-audit after fixing audit findings

**Plan for:** [SPEC-FIX #1845](https://github.com/michael-conrad/.opencode/issues/1845)
**Created:** 2026-07-10
**Authorization:** for_pr (halt_at: pr_created)

## Goal

Add mandatory re-audit step to the change-control task when revision was triggered by spec-audit FAILs, and update exit criteria to require all prior audit FAILs resolved to PASS.

## Architecture

Single-file change to `.opencode/skills/spec-creation/tasks/change-control.md`:
- Add exit criterion for audit-triggered revisions
- Insert mandatory re-audit step between Step 3 (Impact Analysis) and Step 4 (HALT)
- Re-audit is conditional — only required when revision was triggered by spec-audit FAILs

## Files

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/tasks/change-control.md` | Add exit criterion, insert re-audit step |

## Phases

| Phase | Concern | SCs | Steps |
|-------|---------|-----|-------|
| 1 | Update change-control task | SC-1, SC-2, SC-3, SC-4 | 1-4 |

## Exit Criteria

- All 4 SCs verified PASS
- change-control.md updated with mandatory re-audit step
- change-control.md exit criteria updated for audit-triggered revisions
- No SC lobotomization

## Admonishments

- **No lobotomizing tests.** Removing or weakening a behavioral test assertion is a CRITICAL VIOLATION.
- **Single concern per commit.** Each SC gets its own RED/GREEN/COMMIT cycle.
- **Re-audit is conditional.** Only required when revision was triggered by spec-audit FAILs — non-audit-triggered revisions preserve existing behavior.

## Self-Review Evidence

- [ ] Plan covers all 4 SCs from spec
- [ ] Plan addresses the root cause (advisory re-audit question)
- [ ] Plan preserves existing behavior for non-audit-triggered revisions
- [ ] Plan follows single-concern-per-commit discipline

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
