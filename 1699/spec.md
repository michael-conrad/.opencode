Phase of #1697 (SPEC-FIX): Behavioral test evaluation gate. Adds a `behavioral-test-evaluation` task to the `verification-before-completion` skill that dispatches clean-room sub-agents to evaluate behavioral test artifacts after `behavior_run`. The task reads stdout/stderr/timeline and returns PASS/FAIL per SC. Covers SC-1 (string) and SC-5 (behavioral).

---

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/1697/.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.
