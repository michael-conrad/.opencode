<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: resolve-models (Reference)


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files (passed through for pipeline consistency)
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/resolve-models/`

### Step 1: Judgment Assembly (Reference)

This task reads all upstream artifacts and produces the final judgment:

1. Read `evidence.yaml` (Investigator output) — raw evidence and initial findings
2. Read `reasoning.yaml` (Validator output) — validated evidence with source references
3. Read `verdict.yaml` (Evaluator output) — per-criterion PASS/FAIL verdicts
4. **Self-consistency gate**: For each finding where `result: "PASS"`, inspect the `explanation` field. If it contains any critique/hedging language ("should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally"), downgrade that finding's `result` to `FAIL` and set `self_consistency_downgrade: true` in the finding. A PASS verdict with hedging language is internally inconsistent — the explanation contradicts the result.
5. Write `judgment.yaml` — final judgment with cross-reference summary and `next_step`

### Artifact Output

Write final judgment to `./tmp/{issue-N}/artifacts/resolve-models/judgment.yaml`:

```yaml
overall_verdict: PASS|FAIL
next_step: "proceed|remediate then re-audit"
total_criteria: N
findings:
  - criterion_id: "SC-1"
    result: PASS|FAIL
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    self_consistency_downgrade: false  # true if PASS was downgraded to FAIL by self-consistency gate
```

## Exit Criteria

- `judgment.yaml` written with `overall_verdict`, `next_step`, and per-criterion findings
- Self-consistency gate applied to all PASS verdicts
- Cross-reference summary included in judgment

## Cross-References

- `tasks/cross-validate.md` — Arbiter role implementation
- `tasks/completion.md` — audit workflow completion

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{project_root}/tmp/{issue-N}/artifacts/{chain}/...` | Path to the output artifact file |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `status` | Yes | `DONE | BLOCKED` | Task completion status |
| `summary` | Yes | `string` | 1-3 sentence summary of findings |

The output artifact MUST be written to `artifact_path` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `artifact_path`. The orchestrator reads only this contract — it does NOT re-read the artifact.
