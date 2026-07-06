# Task: behavioral-test-remediation

## Purpose

Remediate behavioral test failures through a structured diagnose → fix → re-run → re-evaluate → confirm PASS loop. This task is dispatched when a behavioral test evaluation returns FAIL.

## Input

- `issue_number`: Issue number for the spec being implemented
- `test_artifact_path`: Path to the behavioral test artifacts directory
- `sc_list`: List of SC IDs that failed evaluation

## Procedure

1. **Diagnose root cause** — Read the evaluation YAML and test artifacts (stdout.log, stderr.log, session.yaml) to determine why each SC failed:
   - Prompt issue (missing authorization, wrong fixture, prose-recall)
   - Implementation issue (change not made, wrong approach)
   - Infrastructure issue (timeout, model unavailable, harness problem)

2. **Fix the root cause** — Apply the appropriate fix:
   - Prompt issue: Update the behavioral test prompt
   - Implementation issue: Return to the implementation pipeline
   - Infrastructure issue: Increase timeout, select alternative model, fix harness

3. **Re-run the test** — Execute the behavioral test again with the fix applied

4. **Re-evaluate** — Dispatch `behavioral-test-evaluation` from `verification-before-completion` to evaluate the new artifacts

5. **Confirm PASS** — Only when clean-room evaluation returns PASS for all behavioral SCs may the task report DONE

## Output

```yaml
status: DONE|BLOCKED
remediation_attempts:
  - attempt: 1
    diagnosis: "Root cause of failure"
    fix_applied: "What was changed"
    result: PASS|FAIL
blocker_reason: "Reason if BLOCKED after max attempts"
```

## Rules

- Maximum 2 remediation attempts before BLOCKED
- Each attempt MUST re-run the test and re-evaluate — no shortcutting
- "Looks fixed" without re-running is NOT valid — only re-run + re-evaluate counts
- If remediation requires implementation changes, dispatch to the implementation pipeline, do NOT inline-fix
