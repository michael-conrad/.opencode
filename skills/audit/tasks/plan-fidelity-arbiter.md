---
name: plan-fidelity-path-provider
description: "Arbiter role for the plan-fidelity DiMo chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: plan-fidelity-path-provider

## Purpose

Arbiter role for the plan-fidelity DiMo chain. Reads all upstream artifacts — `evidence.yaml` (Investigator), `reasoning.yaml` (Validator), `verdict.yaml` (Evaluator) — and produces the final `judgment.yaml` with final judgment and `next_step`. This is the fourth and final role in the DiMo 4-role chain. It synthesizes, not evaluates.

> **DiMo Role: Arbiter.** This task produces the final judgment for plan-fidelity audit by cross-referencing all upstream artifacts. Reads `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, writes `judgment.yaml`.
>
> You are the Arbiter. You are a synthesizer, not an evaluator. Your job is to read what upstream roles produced and assemble the final picture. You do not second-guess their work. You do not re-open their decisions. You take their outputs and produce the final judgment.
>
> - MUST accept Evaluator's per-criterion verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST write `judgment.yaml` as the only output artifact
>
> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts — contains `evidence.yaml` from Investigator, `reasoning.yaml` from Validator, and `verdict.yaml` from Evaluator
- `github.owner`, `github.repo` available

## Entry Criteria

- `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml` — produced by the Investigator role
- `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml` — produced by the Validator role
- `verdict.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml` — produced by the Evaluator role
- `spec_local_dir` is present and non-empty — contains at minimum `spec.md`
- Write access to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/`

## Exit Criteria

- All three upstream artifacts read and cross-referenced
- Evaluator's per-criterion verdicts accepted as final — no re-evaluation
- Self-consistency gate applied — PASS verdicts with hedging language downgraded to FAIL
- Verdict monotonic non-increasing invariant enforced — no FAIL → PASS reclassification
- `judgment.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/judgment.yaml`
- Result contract includes `next_step` field: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove `judgment.yaml` if it exists from a prior run: `rm -f {project_root}/tmp/{issue-N}/artifacts/plan-fidelity/judgment.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml`
- [ ] 2. Verify `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml`
- [ ] 3. Verify `verdict.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml`
- [ ] 4. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 5. If `evidence.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for plan-fidelity-path-provider. The Investigator role must produce evidence.yaml before the Arbiter can produce judgment."
```

- [ ] 6. If `reasoning.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for plan-fidelity-path-provider. The Validator role must produce reasoning.yaml before the Arbiter can produce judgment."
```

- [ ] 7. If `verdict.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "verdict.yaml is required for plan-fidelity-path-provider. The Evaluator role must produce verdict.yaml before the Arbiter can produce judgment."
```

- [ ] 8. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for plan-fidelity-path-provider. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Read Upstream Artifacts

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml` — raw evidence from Investigator
- [ ] 2. Read `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml` — validated evidence from Validator
- [ ] 3. Read `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml` — per-criterion PASS/FAIL verdicts from Evaluator
- [ ] 4. Build a cross-reference map: for each criterion in `verdict.yaml`, locate the corresponding evidence in `evidence.yaml` and validation in `reasoning.yaml`
- [ ] 5. Identify any criteria present in `evidence.yaml` that are missing from `verdict.yaml` — these are unjudged criteria

### Step 3: Accept Evaluator Verdicts

The Arbiter does NOT re-evaluate. It accepts the Evaluator's per-criterion verdicts as final:

- [ ] 1. For each criterion in `verdict.yaml.per_criterion`, accept the `result` field as-is
- [ ] 2. Do NOT re-examine evidence to second-guess a PASS or FAIL
- [ ] 3. Do NOT re-validate evidence that the Validator already validated
- [ ] 4. If a criterion is present in `evidence.yaml` but missing from `verdict.yaml`, treat it as unjudged — record as FAIL with explanation `"MISSING_VERDICT"`

### Step 4: Self-Consistency Gate — Verdict Integrity Check

Before finalizing judgment, run the self-consistency gate on every criterion from the Evaluator's verdict:

- [ ] 1. For each criterion where `result: "PASS"`, inspect `explanation` for critique/hedging language:
  - Hedging patterns: "mostly", "largely", "generally", "for the most part", "minor issues", "some concerns", "slight", "mostly correct", "functionally equivalent", "close enough", "with caveats", "with notes", "should be", "needs", "missing", "could improve"
  - If ANY hedging pattern is found, downgrade `result` to `FAIL` and set `remediation` to `"Self-consistency gate: PASS verdict contradicted by hedging in explanation"`
- [ ] 2. If `result: "FAIL"` and `explanation` contains no hedging or critique, the verdict stands — no upgrade to PASS
- [ ] 3. Log the self-consistency check result in the judgment YAML under `self_consistency_gate: { triggered: true|false, downgraded_criteria: ["<criterion IDs>"] }`

### Step 5: Monotonic Non-Increasing Invariant

Enforce the monotonic non-increasing invariant — verdicts must never increase in PASSness at the Arbiter stage:

| Direction | Allowed? | Mechanism |
|---|---|---|
| FAIL → FAIL | Yes | Stays |
| PASS → FAIL | Yes | Self-consistency gate downgrade |
| FAIL → PASS | No | FORBIDDEN — only a fresh audit cycle can produce a new verdict |
| PASS → PASS | Yes | Stays |

- [ ] 1. Verify no FAIL verdict from the Evaluator has been reclassified to PASS
- [ ] 2. If any FAIL → PASS reclassification is detected, self-correct to FAIL
- [ ] 3. Document any self-corrections in `self_corrections` array

### Step 6: Cross-Reference Summary

Synthesize a cross-reference summary from all three upstream artifacts:

- [ ] 1. **Evidence coverage** — for each criterion, confirm evidence exists in `evidence.yaml` and validation exists in `reasoning.yaml`
- [ ] 2. **Discrepancy summary** — aggregate all discrepancies from `verdict.yaml.discrepancy_classification`
- [ ] 3. **Bidirectional findings** — summarize `verdict.yaml.bidirectional_findings`
- [ ] 4. **Gap analysis** — summarize `verdict.yaml.gap_analysis`
- [ ] 5. **Scope creep** — summarize `verdict.yaml.scope_creep`
- [ ] 6. **Scope narrowness** — summarize `verdict.yaml.scope_narrowness`
- [ ] 7. **Cross-reference completeness** — summarize `verdict.yaml.cross_reference_completeness`
- [ ] 8. **Blast radius** — summarize `verdict.yaml.blast_radius`

### Step 7: Compute Aggregate Judgment

- [ ] 1. `overall_verdict = PASS` iff ALL criteria have `result: "PASS"` after self-consistency gate
- [ ] 2. Any single FAIL cascades to `overall_verdict = FAIL`
- [ ] 3. No severity-based exceptions — all FAILs cascade regardless of severity
- [ ] 4. `next_step = "proceed"` when `overall_verdict == PASS`
- [ ] 5. `next_step = "remediate then re-audit"` when `overall_verdict == FAIL`

### Step 8: Write judgment.yaml

Write the final judgment to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/judgment.yaml`:

```yaml
generated_at: "<ISO timestamp>"
judger_model: "<model>"
evidence_source: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml"
reasoning_source: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml"
verdict_source: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml"
overall_verdict: PASS | FAIL
next_step: "proceed" | "remediate then re-audit"
total_criteria: <N>
pass_count: <N>
fail_count: <N>
per_criterion:
  - criterion_id: "PF-1"
    result: "PASS" | "FAIL"
    evidence: "<reference to reasoning.yaml item>"
    explanation: "<synthesized from Evaluator verdict>"
    remediation: ""
    next_step: "proceed" | "remediate"
gap_analysis:
  plan_completeness:
    status: "PASS" | "FAIL"
    findings: []
scope_creep:
  plan_scope_boundary:
    status: "PASS" | "FAIL"
    findings: []
scope_narrowness:
  plan_root_cause_depth:
    status: "PASS" | "FAIL"
    findings: []
cross_reference_completeness:
  plan_reference_integrity:
    status: "PASS" | "FAIL"
    findings: []
blast_radius:
  plan_scope_verification:
    status: "PASS" | "FAIL"
    findings: []
  impact_trace:
    status: "PASS" | "FAIL"
    findings: []
discrepancy_classification:
  - finding_type: "<MISSING_PHASE|EXTRA_PHASE|MISSING_STEP|EXTRA_STEP|APPROACH_DIFFERENCE|MISSING_EDGE_CASE|DEPENDENCY_REVERSAL|MISSING_TDD_CHECKPOINT>"
    classification: "<auto-fix|FAIL>"
    description: "<text>"
bidirectional_findings:
  direction: "<PLAN_INCOMPLETE|PLAN_OVERSCOPED|PLAN_DRIFT>"
  description: "<text>"
  revision_options: ["<option>"]
self_consistency_gate:
  triggered: true | false
  downgraded_criteria: ["<criterion IDs>"]
self_corrections:
  - criterion_id: "<criterion ID>"
    detection_signal: "<description of what triggered the correction>"
    original_verdict: PASS | FAIL
    corrected_verdict: FAIL
all_criteria_pass: true | false
remediation_required: true | false
auto_fixes_applied: []
exec_summary: "Plan fidelity: X/Y criteria PASS. N discrepancies found. Next step: <proceed|remediate then re-audit>."
```

### Step 9: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/judgment.yaml"
summary: "Plan fidelity judgment: {pass_count}/{total_criteria} criteria PASS. {fail_count} FAIL. Next step: {next_step}."
overall_verdict: PASS | FAIL
next_step: "proceed" | "remediate then re-audit"
all_criteria_pass: true | false
remediation_required: true | false
```

## Error Handling

| Error | Action |
|-------|--------|
| `evidence.yaml` missing | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| `reasoning.yaml` missing | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| `verdict.yaml` missing | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| `spec_local_dir` missing or empty | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| Criterion in `evidence.yaml` but missing from `verdict.yaml` | Treat as FAIL with `MISSING_VERDICT` |
| Self-consistency gate triggers downgrade | Downgrade PASS to FAIL, record in `self_consistency_gate` |
| FAIL → PASS reclassification detected | Self-correct to FAIL, record in `self_corrections` |
| Write permission denied | Return BLOCKED — cannot write judgment |

## Cross-References

- `tasks/plan-fidelity-investigator.md` — Investigator role (produces `evidence.yaml` consumed by this task)
- `tasks/plan-fidelity-validator.md` — Validator role (produces `reasoning.yaml` consumed by this task)
- `tasks/plan-fidelity-evaluator.md` — Evaluator role (produces `verdict.yaml` consumed by this task)
- `tasks/plan-fidelity.md` — Main task file (orchestrator-level plan-fidelity audit)
- `tasks/cross-validate.md` — Sole Arbiter for verification-audit (reference implementation)
- `tasks/resolve-models.md` — Arbiter role reference documentation
- `audit/SKILL.md` — DiMo chain dispatch (Investigator → Validator → Evaluator → Arbiter)
- `writing-plans` skill — clean-room plan generation
- `guidelines/000-critical-rules.md` — critical-rules-020 (soft-passing prohibition), critical-rules-hard-fail, critical-rules-034 (inline work prohibition)
- `guidelines/065-verification-honesty.md` — hard failure discipline, self-consistency gate

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
