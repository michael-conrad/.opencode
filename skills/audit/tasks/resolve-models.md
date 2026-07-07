<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: resolve-models (Path Provider — Reference)

> **DiMo Role: Path Provider (reference).** This task is a reference document for the Path Provider role in the DiMo role chain. The Path Provider reads all upstream artifacts (`evidence.yaml`, `reasoning.yaml`, `verdict.yaml`) and produces the final `judgment.yaml`. Model selection is embedded in the sequential dispatch — no separate `resolve-models` tool invocation is needed.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files (passed through for pipeline consistency)
- `artifact_evidence_dir`: Directory for evidence artifacts

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/resolve-models/`

### Step 1: Path Provider (Judger)

The Path Provider role is the fourth and final role in the DiMo role chain. It reads all upstream artifacts and produces the final judgment:

1. Read `evidence.yaml` (Generator output) — raw evidence and initial findings
2. Read `reasoning.yaml` (Knowledge Supporter output) — validated evidence with source references
3. Read `verdict.yaml` (Evaluator output) — per-criterion PASS/FAIL verdicts
4. Write `judgment.yaml` — final judgment with cross-reference summary and `next_step`

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
```

## Cross-References

- `tasks/cross-validate.md` — Path Provider (Judger) role implementation
- `tasks/completion.md` — audit workflow completion

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
