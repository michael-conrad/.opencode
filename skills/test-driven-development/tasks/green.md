<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: green

## Invocation

Dispatch `test-driven-development` with `task(..., prompt: "execute green task from test-driven-development")`

## Exit Criteria

The GREEN phase implements exactly one SC. Verify the SC's evidence type before declaring PASS.

Implementation written, test PASSES.

## Verification Command

```bash
uv run pytest test/test_module.py::test_<name> -v
# Expected: PASSED

# Confirm no regressions
uv run pytest test/ -v
# Expected: all PASSED
```

## Task Context Schema

```json
{
  "spec_context": "<scope of behavior to implement>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```

## GREEN Persona Enforcement

GREEN-phase sub-agents implement code only — they MUST NOT write or modify test files.

### 🚫 FORBIDDEN

- Writing new test files
- Modifying existing test files
- Editing test fixtures or test configuration
- Creating any file under `test/` or designated test directories

### ✅ PERMITTED

- Writing implementation code in `src/` or designated source directories
- Modifying existing source files
- Running tests to confirm PASS status (read-only execution)
- Reading test files to understand expected behavior

### Violation Handling

The GREEN-phase sub-agent MUST NOT modify any file under `test/`. If `git diff --name-only -- test/` shows changes after GREEN, the orchestrator re-dispatches the GREEN-phase from clean-room state — no inline fallback.

## GREEN Abort Protocol

GREEN defines exactly one normal terminal state: a passing implementation verified against the SC's evidence type. When an irregular condition makes that terminal state unreachable or invalid, the GREEN-phase sub-agent returns a **classified ABORT** as its terminal state. Returning a classified abort IS completing the task correctly — it is task completion, not failure. The sub-agent MUST NOT force the outcome, MUST NOT modify a test to make it pass, and MUST NOT loop between the mandate and reality.

### Abort Terminal State — Result Contract

When the GREEN phase cannot validly produce a passing implementation, the sub-agent returns:

```
status: BLOCKED
blocker_reason: <classification>
```

The `status` field is always `BLOCKED`. The `blocker_reason` field carries exactly one of the classifications enumerated below. This result contract is the abort's only terminal output — no forcing, no test-modification-to-pass, no looping. On abort, the orchestrator routes on `BLOCKED` + classification rather than treating the result as a hard failure.

### GREEN Classifications

The GREEN abort protocol enumerates five classifications. Select exactly one `blocker_reason` value:

| Classification | Meaning |
|----------------|---------|
| `NO_PURPOSE` | The implementation serves no purpose — the SC has no meaningful behavior to implement, so a passing implementation cannot be validly produced |
| `IMPOSSIBLE` | The implementation is impossible — the SC describes behavior that cannot be implemented under current constraints, so a passing implementation cannot be validly produced |
| `CONFLICT` | The implementation conflicts with existing behavior, other tests, or the spec's intent — writing it would be contradictory, so a valid passing implementation cannot be produced |
| `SCOPE_CREEP` | The SC requires un-spec'ed feature removal or behavior outside the approved scope — implementing it would exceed the spec's boundaries, so the GREEN cannot validly proceed |
| `BAD_TEST_NEEDS_REVISION` | The test being implemented against is defective and needs revision — the GREEN SHALL abort via immediate `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION`, shuffling the test back to the RED phase for revision rather than implementing against the defective test |

Select the classification that most precisely describes why the passing-GREEN terminal state is unreachable or invalid. Report the classified abort as the task result; do not proceed to verification with an unverified, forced, or irrelevant passing implementation.

### Immediate-Abort Zero-Further-Analysis Mandate

A sub-agent detecting a BLOCK condition SHALL immediately return a classified abort with ZERO further analysis. No additional reading, no additional analysis, no remediation, and no re-evaluation after detecting the block.

### Orchestrator-Only Remediation

Remediation is exclusively the orchestrator's responsibility — the orchestrator handles remediation by tasking new sub-agents with the needed remediation tasks. The aborting sub-agent does not remediate.

### BAD_TEST_NEEDS_REVISION — Shuffle-to-RED Routing

When the GREEN-phase sub-agent discovers that the test it is implementing against is defective and needs revision, the test is defective — not the SC. The sub-agent SHALL abort via immediate `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION`, shuffling the defective test back to the RED phase for revision. The sub-agent SHALL NOT attempt to implement against the defective test. This is distinct from `NO_PURPOSE` (defective test with no purpose) and `IMPOSSIBLE` (unimplementable SC).

### Post-Abort Orchestrator Routing

On receiving a GREEN classified abort (`status: BLOCKED` + `blocker_reason`), the orchestrator SHALL NOT blindly re-task GREEN from clean-room state. The abort signals an irregular condition rooted in the SC, the spec, or the plan — not a transient failure. The orchestrator SHALL route on the classification:

1. **Cold-reading re-evaluation sub-agent.** The orchestrator dispatches a re-evaluation sub-agent that reads the spec and plan cold (no orchestrator preload, no cached results, no expected outcomes). The re-evaluation sub-agent identifies the defect that made the passing-GREEN terminal state unreachable and routes to `spec-creation --task revise` / `writing-plans --task revise` to adjust the SC so RED/GREEN do not retrigger the abort.
2. **Substantive vs non-substantive classification.** The re-evaluation sub-agent autonomously classifies the adjustment (it does not defer to the developer for non-substantive cases):
   - **Substantive** (new/removed SCs, changed scope, changed implementation approach) — revokes plan approval, requires re-authorization before GREEN resumes.
   - **Non-substantive** (evidence types, verification methods, artifact paths, SC wording that does not alter implementation intent, scope, or SC semantics) — auto-revise via the revise task, no re-authorization.
3. **Retrigger ladder.** Track aborts per classification. After **2 aborts with the same classification**, the orchestrator dispatches a re-decomposition/rework evaluation sub-agent. Escalate to spec-audit ONLY if re-decomposition is NOT the fix — do not escalate to spec-audit prematurely.
