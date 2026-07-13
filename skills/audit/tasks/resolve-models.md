<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: resolve-models (Reference)

> **DiMo Role: Path Provider (reference).** This task is a reference document describing the Path Provider role in the DiMo role chain. The Path Provider reads all upstream artifacts (`evidence.yaml`, `reasoning.yaml`, `verdict.yaml`) and produces the final `judgment.yaml`. Model selection is embedded in the sequential dispatch — no separate `resolve-models` tool invocation is needed.
>
> **The authoritative Path Provider implementation is `tasks/cross-validate.md`.** This file documents the role's contract and output schema for reference. The Path Provider is a synthesizer, not an evaluator — it reads what upstream roles produced and assembles the final picture without second-guessing their work or re-opening their decisions.
>
> - MUST accept Evaluator's per-criterion verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST write `judgment.yaml` as the only output artifact
> 

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files (passed through for pipeline consistency)
- `artifact_evidence_dir`: Directory for evidence artifacts

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/resolve-models/`

### Step 1: Judgment Assembly (Reference)

The Path Provider role (implemented in `cross-validate.md`) is the fourth and final role in the DiMo role chain. It reads all upstream artifacts and produces the final judgment:

1. Read `evidence.yaml` (Generator output) — raw evidence and initial findings
2. Read `reasoning.yaml` (Knowledge Supporter output) — validated evidence with source references
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

## Cross-References

- `tasks/cross-validate.md` — Path Provider role implementation
- `tasks/completion.md` — audit workflow completion

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
