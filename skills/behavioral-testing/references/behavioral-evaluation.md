<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: restored from pre-rip verification-before-completion/tasks/behavioral-test-evaluation.md; .opencode#2538 -->

# Clean-Room Behavioral Evaluation

Dispatched after every behavioral run (card rule 5). This sub-agent IS the
clean-room evaluator — no further sub-agent dispatch is needed. It receives
ONLY the artifact directory and the SC criteria list — no orchestrator
context, no expected outcomes, no cached results.

## Input

- `artifact_dir`: directory containing the run's artifacts (`manifest.yaml`,
  `stdout.log`, `stderr.log`, `exit_code`, `session.yaml`)
- `sc_list`: the behavioral SC IDs to evaluate, with each criterion text

For an early-concluded run (Evidence-Sufficiency Early Exit, tests-v2 §14),
`session.yaml` from the §10.5 export is the primary input; missing secondary
artifacts are acceptable when the run's sufficiency judgment is recorded
alongside them. A missing `session.yaml` with `source_db: MISSING` remains a
hard FAIL regardless.

## Procedure

1. **Read artifacts** — `session.yaml` (the SQLite DB export of the `event`
   table) is the PRIMARY and only reliable evidence source for agent actions.
   `stdout.log` is prose only; `stderr.log` is diagnostics only — neither is
   a reliable source for tool-dispatch verification.
2. **Evaluate each behavioral SC** — judge whether the agent's recorded tool
   calls, reasoning, and decisions satisfy the SC criterion.
3. **Detect test type** — inspect the test source for infrastructure usage
   patterns and classify: `live DB` | `unit` | `mock` | `integration`
   (default `unit` when no pattern matches).
4. **Collect verdicts** — PASS/FAIL per SC with evidence citations, including
   the detected test-type annotation.
5. **Produce the evaluation artifact** — write the results to
   `{artifact_dir}/evaluation-{timestamp}.yaml` and return the same record as
   the dispatch result.

## Output (YAML)

```yaml
status: DONE|BLOCKED
evaluations:
  - sc_id: SC-N
    verdict: PASS|FAIL
    evidence: "what the recorded behavior shows, with citations"
    artifact_path: "{artifact_dir}/evaluation-{timestamp}.yaml"
    test_type: "live DB"|"unit"|"mock"|"integration"
    test_function: "test_function_name"
blocker_reason: "reason if BLOCKED"
```

## Rules

- "Artifact generated" is NEVER a valid PASS verdict — only clean-room
  evaluation counts.
- Grep/string/file-existence evidence is never behavioral evidence — the
  evaluator reads and understands `session.yaml`, it does not pattern-match.
- If `session.yaml` contains `source_db: MISSING`, the run environment is
  broken — that is a hard FAIL; do NOT hunt for the DB elsewhere, substitute
  stderr/stdout greps, or synthesize data.
- Any behavioral FAIL makes the overall status BLOCKED with remediation
  required — never proceed past an unremediated FAIL.
