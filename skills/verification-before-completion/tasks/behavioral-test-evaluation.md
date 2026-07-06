# Task: behavioral-test-evaluation

## Purpose

Evaluate behavioral test artifacts produced by `behavior_run` via clean-room sub-agents. This task MUST be dispatched after every behavioral test run — "artifact generated" is NOT a valid PASS verdict for behavioral SCs.

## Input

- `artifact_dir`: Directory containing behavioral test artifacts (stdout.log, stderr.log, session.yaml, timeline)
- `sc_list`: List of SC IDs to evaluate, with their evidence type and verification method

## Procedure

1. **Read artifacts** — Read stdout.log, stderr.log, and session.yaml from `artifact_dir`
2. **Dispatch clean-room sub-agent** — For each behavioral SC, dispatch a clean-room sub-agent (different model, no context preloading) to evaluate whether the agent's behavior matches the SC criterion
3. **Collect verdicts** — Collect PASS/FAIL verdicts per SC with evidence citations
4. **Produce evidence artifact** — Write evaluation results to `{artifact_dir}/evaluation-{timestamp}.yaml`

## Output

```yaml
status: DONE|BLOCKED
evaluations:
  - sc_id: SC-N
    verdict: PASS|FAIL
    evidence: "Clean-room sub-agent confirmed agent behavior matches criterion"
    artifact_path: "{artifact_dir}/evaluation-{timestamp}.yaml"
blocker_reason: "Reason if BLOCKED"
```

## Rules

- Clean-room sub-agents MUST be a different model from the producing agent
- Clean-room sub-agents MUST receive NO context about expected outcomes
- "Artifact generated" is NEVER a valid PASS verdict — only clean-room evaluation counts
- If any behavioral SC returns FAIL, the overall status is BLOCKED with remediation required
