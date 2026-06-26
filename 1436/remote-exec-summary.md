> **Full spec and artifacts:** [`.opencode/.issues/1436/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1436/)

## Exec Summary

The plan-fidelity auditor embeds expected values directly in its evaluation criteria instead of reading them dynamically from authoritative skill cards. This causes false FAIL verdicts when the authoritative source changes but the auditor's hard-coded values don't.

### Cards (dependency order)
1. **PF-DISPATCH-MODE fix** — Change hard-coded `(**clean-room**) or (**inline**)` to dynamic reference to `writing-plans/tasks/write.md` §Dispatch Indicators
2. **PF-Z3-CONTRACT fix** — Change hard-coded `P1_I1_G1` format to reference the `solve` skill's actual contract schema, or remove if no authoritative source defines a naming convention
3. **General principle** — Add note to evaluation criteria section stating criteria MUST reference authoritative skill cards
4. **Full review** — Scan all other criteria for hard-coded values that should be dynamic

### Key Decisions
- **Dynamic references over hard-coded values**: The PF-SEQUENCE-MATCHES criterion already demonstrates the correct pattern — read dynamically, not hardcoded. All criteria should follow this pattern.

### Risk Callouts
- **Low risk**: Changing criterion descriptions does not affect audit logic, only the expected values the auditor checks against. The auditor sub-agent reads the task file independently, so the change takes effect on next dispatch.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1436/`.
After creation, `local-issues sync 1436` MUST be run and the result committed to create the local `.opencode/.issues/1436/` entry.
The implementation plan will be created in `.opencode/.issues/1436/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
