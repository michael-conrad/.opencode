<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: red

## Invocation

Dispatch `test-driven-development` with `task(..., prompt: "execute red task from test-driven-development")`

## Exit Criteria

Test written and confirmed FAILING (or ERROR if function doesn't exist yet).

## RED != FALSE Clause

RED is the event of writing an enforcement test, executing it, and observing it FAIL (non-zero exit). RED is not the absence of a feature. If there is no test file and no test run, there is no RED — there is only FALSE.

### Prohibited Patterns (FALSE, not RED)

The following patterns do NOT constitute RED:

- `grep | wc -l` — a count is not a test execution
- `grep -c` — same, a filter count is not a test
- `ls` — file existence does not verify behavior
- `"observe that X does not exist yet"` — observation without execution is not a test
- Any information query that does not produce a non-zero exit code

These are FALSE — they describe the absence of a feature, not the event of a test failing.

## Required RED Structure

The RED phase targets exactly one SC from the spec. Reference the SC-ID in the test file path or test name.

| Field | Description |
|-------|-------------|
| Test file path | Permanent test storage path |
| Execution command | Command that produces exit code |
| Expected on FAIL | Exit code N (non-zero) |
| Artifact output | `{project_root}/tmp/{issue-N}/artifacts/{phase}-test-output.log` |

### Test Placement — Owning-Repo Principle

Determine test file placement by resolving the repo owning the code under test, then placing per that repo's conventions. Do NOT default to `.issues/` and do NOT default to the root repo's test path when the code under test lives in another repo.

1. Resolve the repo owning the code under test using the `## Repo Information` section from session-init (match the affected file path prefix).
2. Place the test file per that repo's conventions (e.g., `.opencode/tests-v2/` for `.opencode` code, `test/` for root repo code).
3. Only when the owning repo's convention is indeterminate, fall back to the configured test storage path.

Test output artifacts (exit code, stdout, stderr) go to `{project_root}/tmp/{issue-N}/artifacts/` for auditor consumption. Auditors inspect artifacts, they do NOT re-run tests.

## Task Context Schema

```json
{
  "spec_context": "<scope of behavior to test>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```

## RED Persona Enforcement

RED-phase sub-agents write tests only — they MUST NOT modify `src/` or any implementation files.

### 🚫 FORBIDDEN

- Modifying any file under `src/`
- Writing implementation code of any kind
- Editing configuration files that change program behavior
- Creating or modifying files outside the designated test path

### ✅ PERMITTED

- Writing test files in the designated test path
- Modifying existing test files
- Creating test fixture files in `test/` or designated test directories
- Reading any source file for test design

### Violation Handling

The RED-phase sub-agent MUST NOT modify any file under `src/`. If `git diff --name-only -- src/` shows changes after RED, the orchestrator re-dispatches the RED-phase from clean-room state — no inline fallback.

## RED Abort Protocol

RED defines exactly one normal terminal state: a confirmed-failing enforcement test. When an irregular condition makes that terminal state unreachable or invalid, the RED-phase sub-agent returns a **classified ABORT** as its terminal state. Returning a classified abort IS completing the task correctly — it is task completion, not failure. The sub-agent MUST NOT force the outcome, MUST NOT modify a test to make it fail, and MUST NOT loop between the mandate and reality.

### Abort Terminal State — Result Contract

When the RED phase cannot validly produce a confirmed-failing test, the sub-agent returns:

```
status: BLOCKED
blocker_reason: <classification>
```

The `status` field is always `BLOCKED`. The `blocker_reason` field carries exactly one of the classifications enumerated below. This result contract is the abort's only terminal output — no forcing, no test-modification-to-fail, no looping.

### RED Classifications

The RED abort protocol enumerates four classifications. Select exactly one `blocker_reason` value:

| Classification | Meaning |
|----------------|---------|
| `ALREADY_GREEN` | The enforcement test already passes — the expected-failing behavior is already implemented, so a failing RED test cannot be validly produced |
| `FALSE_PREMISE` | The test is based on a false premise — the scenario the SC describes does not correspond to actual system state, so the test would be invalid |
| `NOT_RELEVANT` | The test is not relevant to the code path under test — it targets behavior outside the SC's scope, so the SC's test cannot validly target the intended path |
| `CONFLICT` | The test conflicts with existing behavior, other tests, or the spec's intent — writing it would be contradictory, so a valid RED test cannot be produced |

Select the classification that most precisely describes why the confirmed-failing RED terminal state is unreachable or invalid. Report the classified abort as the task result; do not proceed to GREEN with an unconfirmed, forced, or irrelevant failing test.

### Immediate-Abort Zero-Further-Analysis Mandate

A sub-agent detecting a BLOCK condition SHALL immediately return a classified abort with ZERO further analysis. No additional reading, no additional analysis, no remediation, and no re-evaluation after detecting the block.

### Orchestrator-Only Remediation

Remediation is exclusively the orchestrator's responsibility — the orchestrator handles remediation by tasking new sub-agents with the needed remediation tasks. The aborting sub-agent does not remediate.

### Post-Abort Orchestrator Routing

On receiving a RED classified abort (`status: BLOCKED` + `blocker_reason`), the orchestrator SHALL NOT blindly re-task RED from clean-room state. The abort signals an irregular condition rooted in the SC, the spec, or the plan — not a transient failure. The orchestrator SHALL route on the classification:

1. **Cold-reading re-evaluation sub-agent.** The orchestrator dispatches a re-evaluation sub-agent that reads the spec and plan cold (no orchestrator preload, no cached results, no expected outcomes). The re-evaluation sub-agent identifies the defect that made the confirmed-failing RED terminal state unreachable and routes to `spec-creation --task revise` / `writing-plans --task revise` to adjust the SC so RED does not retrigger the abort.
2. **Substantive vs non-substantive classification.** The re-evaluation sub-agent autonomously classifies the adjustment (it does not defer to the developer for non-substantive cases):
   - **Substantive** (new/removed SCs, changed scope, changed implementation approach) — revokes plan approval, requires re-authorization before GREEN resumes.
   - **Non-substantive** (evidence types, verification methods, artifact paths, SC wording that does not alter implementation intent, scope, or SC semantics) — auto-revise via the revise task, no re-authorization.
3. **Retrigger ladder.** Track aborts per classification. After **2 aborts with the same classification**, the orchestrator dispatches a re-decomposition/rework evaluation sub-agent. Escalate to spec-audit ONLY if re-decomposition is NOT the fix — do not escalate to spec-audit prematurely.
