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
