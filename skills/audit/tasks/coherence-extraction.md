# Task: coherence-extraction

## Purpose

Generate baseline coherence state from guidelines and skills. This task has been split into a DiMo 4-role chain. Each role is a separate file in this directory.

## DiMo Chain Flow

The orchestrator dispatches the 4 roles sequentially:

1. **Generator** (`coherence-extraction/generator.md`) — Scans guidelines and skills, produces `evidence.yaml`
2. **Knowledge Supporter** (`coherence-extraction/knowledge-supporter.md`) — Validates evidence, produces `reasoning.yaml`
3. **Evaluator** (`coherence-extraction/evaluator.md`) — Computes metrics, runs Z3 check, evaluates evidence type mismatches, produces `verdict.yaml`
4. **Path Provider** (`coherence-extraction/path-provider.md`) — Provides recommendations, produces final result contract

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- Baseline not yet generated OR refresh requested
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- Baseline JSON written to `{project_root}/tmp/{issue-N}/artifacts/baseline-coherence.json`
- All rules extracted from guidelines
- All behaviors mapped from skills
- Cross-references validated
- Z3 solve check PASS
- No evidence type mismatches

## Cross-References

- **Generator:** `coherence-extraction/generator.md`
- **Knowledge Supporter:** `coherence-extraction/knowledge-supporter.md`
- **Evaluator:** `coherence-extraction/evaluator.md`
- **Path Provider:** `coherence-extraction/path-provider.md`
