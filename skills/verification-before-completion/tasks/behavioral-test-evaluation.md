# Task: behavioral-test-evaluation

## Purpose

Evaluate behavioral test artifacts produced by `behavior_run` via clean-room sub-agents. This task MUST be dispatched after every behavioral test run — "artifact generated" is NOT a valid PASS verdict for behavioral SCs.

## Input

- `artifact_dir`: Directory containing behavioral test artifacts (stdout.log, stderr.log, session.yaml, timeline)
- `sc_list`: List of SC IDs to evaluate, with their evidence type and verification method

## Procedure

1. **Read artifacts** — Read stdout.log, stderr.log, and session.yaml from `artifact_dir`
2. **Evaluate each behavioral SC** — For each behavioral SC, evaluate whether the agent's behavior matches the SC criterion. The sub-agent performs this evaluation directly — no further sub-agent dispatch is needed.
3. **Detect test type** — Read the test source file and apply the detection logic from Read [Test-Type Annotation Detection](skills/verification-before-completion/tasks/collect.md) (scan for infrastructure patterns, classify the test type, default to `(unit)` if no pattern matches)
4. **Collect verdicts** — Collect PASS/FAIL verdicts per SC with evidence citations, including the detected test-type annotation
5. **Produce evidence artifact** — Write evaluation results to `{artifact_dir}/evaluation-{timestamp}.yaml`

## Output

```yaml
status: DONE|BLOCKED
evaluations:
  - sc_id: SC-N
    verdict: PASS|FAIL
    evidence: "Clean-room sub-agent confirmed agent behavior matches criterion"
    artifact_path: "{artifact_dir}/evaluation-{timestamp}.yaml"
    test_type: "live DB"|"unit"|"mock"|"integration"
    test_function: "test_function_name"
blocker_reason: "Reason if BLOCKED"
```

### Test-Type Annotation Values

| Value | Meaning |
| -- | -- |
| `live DB` | Test connects to a live database |
| `unit` | Pure unit test with no external dependencies |
| `mock` | Test uses mocked external dependencies |
| `integration` | Test exercises multiple components together |

The `test_type` field MUST be populated by inspecting the test infrastructure usage patterns (Read [Test-Type Annotation Detection](skills/verification-before-completion/tasks/collect.md)). The `test_function` field MUST contain the exact test function name (e.g., `test_verify_creates_vbc_table`).

## Rules

- The sub-agent performing this evaluation IS the clean-room evaluator — no further sub-agent dispatch is needed
- "Artifact generated" is NEVER a valid PASS verdict — only clean-room evaluation counts
- If any behavioral SC returns FAIL, the overall status is BLOCKED with remediation required
