## Problem

When regression checks (`test-enforcement.sh` or behavioral tests) produce FAIL, MISSING, or error output, agents currently have no rule requiring them to file a bug report. This means:

1. Pre-existing test failures accumulate silently across sessions — no agent files a bug, so no fix is ever scheduled
2. New regressions introduced by a change may go unreported if the agent proceeds past the failure
3. The only record of a regression is the terminal output, which is lost when the session ends
4. There is no audit trail connecting a regression to a known defect

## Root Cause

`000-critical-rules.md` has no rule governing agent behavior when regression checks fail. The existing rules cover verification honesty (065), hard failure discipline, and test integrity — but none mandate filing a bug report as a follow-up action. The gap is at the boundary between "a test failed" and "a bug is tracked."

## Required Actions

### 1. Add new critical rule to `000-critical-rules.md`

- **File:** `.opencode/guidelines/000-critical-rules.md`
- **Change:** Add a new Tier 2 rule with ID `critical-rules-regression-bug-report`
- **Rule text:**

> ### [critical-rules-regression-bug-report] Regression check failures require bug reports — no exceptions
>
> When any regression check (`test-enforcement.sh` or behavioral test) produces FAIL, MISSING, or error output, the agent MUST file a bug report as a spec issue in the `.opencode` repo before proceeding with any other work.
>
> #### Bug Report Requirements
>
> The bug report issue MUST include:
> - **Failing test name** — the exact test scenario or test file that failed
> - **Failure output/evidence** — the relevant stderr/stdout output showing the failure
> - **Classification** — whether the failure is pre-existing (present before the agent's changes) or a new regression (introduced by the agent's changes)
> - **Root cause** — if identifiable, the likely root cause of the failure
>
> #### Pre-Existing Failures Are NOT Exempt
>
> A pre-existing failure (one that was present before the agent made any changes) MUST still be filed as a bug. The classification field distinguishes pre-existing from new regressions, but both require a bug report.
>
> #### Exception: Infrastructure-Only Failures
>
> Transient, non-reproducible infrastructure failures (model unavailable, network timeout, disk full) are exempt from the bug report requirement. The agent MUST document the infrastructure failure in chat output with the evidence of transience (e.g., re-run output showing the test passes on retry).
>
> #### Filing Procedure
>
> 1. Create a spec issue in the `.opencode` repo with label `BUG` and `SPEC-FIX`
> 2. Include all required fields from Bug Report Requirements above
> 3. Proceed with the current task only after the bug report is filed
> 4. If the failure is a new regression caused by the agent's changes, the agent MUST fix the regression before proceeding — filing the bug report is the first step, not a substitute for fixing

### 2. Behavioral enforcement test

- **File:** `.opencode/tests/behaviors/regression-bug-report.sh`
- **Change:** New behavioral test that sends a prompt simulating a regression check failure and verifies the agent files a bug report

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `000-critical-rules.md` contains the new `critical-rules-regression-bug-report` rule with all required sections | structural |
| SC-2 | Agent files a bug report (creates a spec issue in `.opencode` repo) when a regression check produces FAIL | behavioral |

## Non-Goals

- Does NOT change how regression checks are run or reported
- Does NOT change the hard failure discipline (FAIL is still a hard gate)
- Does NOT change the test integrity mandate (no lobotomizing tests)
- Does NOT add new regression check infrastructure — only the agent's response to existing failures
- Does NOT require filing bugs for linter warnings, type errors, or other non-regression-check failures
- Does NOT change the existing exception for infrastructure-only failures in verification-honesty rules

## Regression Invariants

1. All existing critical rules remain unchanged — this is an additive change only
2. Existing behavioral tests continue to pass without modification
3. Existing content-verification tests continue to pass without modification
4. The hard failure discipline (critical-rules-hard-fail) is preserved — filing a bug report does not replace remediation
5. The test integrity mandate (critical-rules-test-integrity) is preserved — filing a bug report does not authorize lobotomizing tests

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)