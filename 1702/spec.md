Phase of #1697 (SPEC-FIX): Behavioral test evaluation gate. Adds a `behavioral-test-remediation` step to the Trigger Dispatch Table in the `implementation-pipeline` skill. When a behavioral test evaluation returns FAIL, the orchestrator MUST: diagnose root cause → fix → re-run test → re-evaluate → confirm PASS before proceeding. Covers SC-4 (string).

---

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/1697/.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.
