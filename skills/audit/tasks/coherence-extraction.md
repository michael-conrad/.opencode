# Task: coherence-extraction

## Purpose

Generate baseline coherence state from guidelines and skills.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- Baseline not yet generated OR refresh requested
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- Baseline JSON written to `{project_root}/tmp/{issue-N}/artifacts/baseline-coherence.json`
- All rules extracted from guidelines
- All behaviors mapped from skills
- Cross-references validated
- Z3 solve check PASS
- No evidence type mismatches

## Cross-References

- **Investigator:** `coherence-extraction/investigator.md`
- **Validator:** `coherence-extraction/validator.md`
- **Evaluator:** `coherence-extraction/evaluator.md`
- **Arbiter:** `coherence-extraction/arbiter.md`

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
