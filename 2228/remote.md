> **Full spec and artifacts: [`.opencode/.issues/2228/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2228)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2228/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent & Executive Summary

- **Problem:** The pre-work task's "Already Implemented" edge case has no structured result contract. The sub-agent closes the issue and HALTs, but yields no structured data to the orchestrator. The orchestrator receives no signal about what happened — indistinguishable from a failure or overflow.
- **Objective:** Add `already_implemented` to the yield-back contract's status enum, add a result contract YAML block to the edge case section, and add a yield-back step to the edge case procedure before HALT.
- **Scope:** Single file: `.opencode/skills/git-workflow-branch/tasks/pre-work.md`. No orchestrator routing changes, no behavioral enforcement tests.
- **Success Criteria:** 3 SCs — SC-1 (string): status enum includes `already_implemented`. SC-2 (structural): YAML result contract block in edge case section. SC-3 (structural): yield-back step before HALT.
- **Key Constraint:** Existing `success` and `failure` status values remain unchanged.
