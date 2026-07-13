---
name: concern-separation-path-provider
description: "Path Provider role for the concern-separation DiMo chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: concern-separation-path-provider

## Purpose

Path Provider role for the concern-separation DiMo chain. Reads all upstream artifacts — `evidence.yaml` (Generator), `reasoning.yaml` (Knowledge Supporter), `verdict.yaml` (Evaluator) — and produces the final `judgment.yaml` with final judgment and `next_step`. Synthesizes upstream outputs into a single authoritative judgment. Does NOT re-evaluate, re-validate, or second-guess upstream roles.

> **DiMo Role: Path Provider.** This task produces the final judgment for the concern-separation audit by synthesizing all upstream artifacts. Reads `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, writes `judgment.yaml`.
>
> You are the Path Provider. You are a synthesizer, not an evaluator. Your job is to read what upstream roles produced and assemble the final picture. You do not second-guess their work. You do not re-open their decisions. You take their outputs and produce the final judgment.
>
>
> - MUST accept Evaluator's per-criterion verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST write `judgment.yaml` as the only output artifact
> - MUST synthesize all three upstream artifacts into a single coherent judgment
>

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from upstream roles are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts (contains `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`)

## Entry Criteria

- `evidence.yaml` present at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`
- `reasoning.yaml` present at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml`
- `verdict.yaml` present at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml`
- `spec_local_dir` present and non-empty
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- All three upstream artifacts read and synthesized
- Per-criterion verdicts accepted from Evaluator without re-evaluation
- Self-consistency gate applied — any PASS with hedging language downgraded to FAIL
- Evidence type consistency verified across the chain
- `judgment.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/judgment.yaml`
- Result contract includes `next_step` field: `"remediate then re-audit"` for FAIL, `"proceed"` for PASS

## Non-Recovery Gates

The following states are **terminal BLOCKED states** with no fallback or recovery paths. When encountered, the Path Provider MUST return `status: BLOCKED` immediately — no re-task, no retry, no workaround.

| Gate | Condition | Error Code | Action |
|------|-----------|------------|--------|
| MISSING_INPUT | `spec_local_dir` missing or empty, or no .md files readable | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }` |
| MISSING_EVIDENCE | `evidence.yaml` not found in artifact directory | `MISSING_EVIDENCE` | Return `{ status: "BLOCKED", error: "MISSING_EVIDENCE" }` |
| MISSING_REASONING | `reasoning.yaml` not found in artifact directory | `MISSING_REASONING` | Return `{ status: "BLOCKED", error: "MISSING_REASONING" }` |
| MISSING_VERDICT | `verdict.yaml` not found in artifact directory | `MISSING_VERDICT` | Return `{ status: "BLOCKED", error: "MISSING_VERDICT" }` |
| ARTIFACT_UNREADABLE | Upstream YAML artifact file cannot be read or parsed | `ARTIFACT_UNREADABLE` | Return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }` |

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `{project_root}/tmp/{issue-N}/artifacts/concern-separation/judgment.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. Verify `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`
- [ ] 3. Verify `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml`
- [ ] 4. Verify `verdict.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml`
- [ ] 5. If any criterion fails, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "<field_name>"
remediation: "<field_name> is required for concern-separation-path-provider. The orchestrator must ensure all upstream DiMo roles have completed."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load Upstream Artifacts

Read all three upstream artifacts from disk:

```python
evidence = read_yaml(f"{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml")
reasoning = read_yaml(f"{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml")
verdict = read_yaml(f"{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml")
```

Extract key sections from each artifact:

**From `evidence.yaml`:**
- `phases` — phase structure data
- `symbol_evidence` — symbol-level callers/callees/dependents
- `cross_phase_overlaps` — shared files and symbols between phases
- `blast_radius` — dependency impact chains
- `dependency_order` — declared dependency ordering
- `sc_orthogonality` — SC independence data
- `routing_evidence` — routing table references

**From `reasoning.yaml`:**
- `phase_validation` — validated phase structure
- `symbol_validation` — validated symbol data
- `cross_phase_validation` — validated cross-phase overlaps
- `blast_radius_validation` — validated blast radius
- `dependency_order_validation` — validated dependency order
- `sc_orthogonality_validation` — validated SC orthogonality
- `routing_validation` — validated routing evidence
- `evidence_items_total`, `evidence_items_validated`, `evidence_items_unverified`, `evidence_items_contradicted`

**From `verdict.yaml`:**
- `per_criterion` — per-criterion PASS/FAIL verdicts (CS-1 through CS-6, CS-ROUTING)
- `separation_of_concerns` — SC orthogonality and cross-concern overlap results
- `scope_creep` — cross-concern overlap and scope boundary verification results
- `self_consistency` — any downgraded criteria from the Evaluator's self-check
- `findings` — classified findings with types and recommendations
- `verdict` — overall PASS/FAIL
- `all_criteria_pass` — boolean
- `remediation_required` — boolean
- `exec_summary` — executive summary

### Step 3: Load Spec Files

Load spec files for context during synthesis:

```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
for f in spec_files:
    read(filePath=f)
```

### Step 4: Synthesize Evidence Chain Integrity

Verify the evidence chain is intact across all three upstream roles. This is synthesis, not re-validation — check that each role's output references the correct upstream artifact:

- [ ] 1. Verify `reasoning.evidence_source` matches the path to `evidence.yaml`
- [ ] 2. Verify `verdict.evidence_source` matches the path to `evidence.yaml`
- [ ] 3. Verify `verdict.reasoning_source` matches the path to `reasoning.yaml`
- [ ] 4. Record any chain breaks in the judgment:

```yaml
chain_integrity:
  evidence_to_reasoning: "INTACT|BROKEN"
  reasoning_to_verdict: "INTACT|BROKEN"
  evidence_to_verdict: "INTACT|BROKEN"
  breaks: []
```

### Step 5: Synthesize Validation Coverage

Cross-reference the Knowledge Supporter's validation statistics against the Evaluator's verdicts to produce a coverage summary:

- [ ] 1. Extract `evidence_items_total`, `evidence_items_validated`, `evidence_items_unverified`, `evidence_items_contradicted` from `reasoning.yaml`
- [ ] 2. Count per-criterion verdicts from `verdict.yaml`
- [ ] 3. Identify any criteria where the Evaluator's verdict relies on UNVERIFIED or CONTRADICTED evidence
- [ ] 4. Record coverage gaps:

```yaml
validation_coverage:
  total_evidence_items: <N>
  validated: <N>
  unverified: <N>
  contradicted: <N>
  criteria_with_unverified_evidence: ["<criterion_id>", ...]
  criteria_with_contradicted_evidence: ["<criterion_id>", ...]
```

### Step 6: Accept Evaluator Verdicts

Accept the Evaluator's per-criterion verdicts as final. Do NOT re-evaluate. Do NOT second-guess. The Evaluator is the sole authority on PASS/FAIL for each criterion.

For each criterion in `verdict.per_criterion`:

- [ ] 1. Accept `result` as-is — do not modify
- [ ] 2. Accept `explanation` as-is — do not rewrite
- [ ] 3. Accept `remediation` as-is — do not supplement
- [ ] 4. Accept `next_step` as-is — do not override

```yaml
accepted_verdicts:
  - criterion_id: "CS-1"
    evaluator_result: "PASS|FAIL"
    accepted: true
  - criterion_id: "CS-2"
    evaluator_result: "PASS|FAIL"
    accepted: true
  - criterion_id: "CS-3"
    evaluator_result: "PASS|FAIL"
    accepted: true
  - criterion_id: "CS-4"
    evaluator_result: "PASS|FAIL"
    accepted: true
  - criterion_id: "CS-5"
    evaluator_result: "PASS|FAIL"
    accepted: true
  - criterion_id: "CS-6"
    evaluator_result: "PASS|FAIL"
    accepted: true
  - criterion_id: "CS-ROUTING"
    evaluator_result: "PASS|FAIL"
    accepted: true
```

### Step 7: Synthesize Separation of Concerns and Scope Creep

Accept the Evaluator's separation of concerns and scope creep results:

- [ ] 1. Accept `verdict.separation_of_concerns.sc_orthogonality.result` as-is
- [ ] 2. Accept `verdict.separation_of_concerns.cross_concern_overlap.result` as-is
- [ ] 3. Accept `verdict.scope_creep.cross_concern_overlap.result` as-is
- [ ] 4. Accept `verdict.scope_creep.scope_boundary_verification.result` as-is
- [ ] 5. Synthesize findings from all three sections into a unified concern-separation summary

```yaml
synthesized_concern_separation:
  sc_orthogonality: "PASS|FAIL"
  cross_concern_overlap: "PASS|FAIL"
  scope_creep_cross_concern: "PASS|FAIL"
  scope_boundary_verification: "PASS|FAIL"
  unified_findings: []
```

### Step 8: Self-Consistency Gate

Before writing the final artifact, verify judgment self-consistency:

- [ ] 1. For each accepted verdict, check: if `result: "PASS"` and `explanation` contains critique, hedging, or caveat language (e.g., "but", "however", "minor", "mostly", "functionally equivalent", "close enough", "with concerns"), the verdict is downgraded to FAIL
- [ ] 2. Check the Evaluator's `self_consistency` section — if the Evaluator already downgraded criteria, those downgrades are preserved
- [ ] 3. Check for monotonic non-increasing invariant: no FAIL from the Evaluator may become PASS in the judgment
- [ ] 4. If any criterion was downgraded, append a `self_consistency` section to the judgment:

```yaml
self_consistency:
  downgraded_criteria:
    - criterion_id: "CS-N"
      original_result: "PASS"
      downgraded_to: "FAIL"
      reason: "explanation contained hedging language: '<matched phrase>'"
  evaluator_downgrades_preserved: <N>
```

- [ ] 5. Update `all_criteria_pass` to `false` and `remediation_required` to `true` if any downgrade occurred

### Step 9: Synthesize Findings

Synthesize all findings from the Evaluator's verdict into a unified findings list. Do NOT add new findings — only organize and present what the Evaluator produced:

- [ ] 1. Collect all findings from `verdict.findings`
- [ ] 2. Group by finding type (BOILERPLATE_TITLE, CONCERN_MIXING, DEPENDENCY_REVERSAL, HIGH_RISK_GROUPING, MISSING_RISK_CLASSIFICATION, MISSING_INDEPENDENCE, BLAST_RADIUS_GAP, ROUTING_GAP, CONCERN_GAP, SCOPE_CREEP)
- [ ] 3. For each finding, include the Evaluator's recommendation
- [ ] 4. Produce a synthesized findings summary

```yaml
synthesized_findings:
  by_type:
    BOILERPLATE_TITLE: <N>
    CONCERN_MIXING: <N>
    DEPENDENCY_REVERSAL: <N>
    HIGH_RISK_GROUPING: <N>
    MISSING_RISK_CLASSIFICATION: <N>
    MISSING_INDEPENDENCE: <N>
    BLAST_RADIUS_GAP: <N>
    ROUTING_GAP: <N>
    CONCERN_GAP: <N>
    SCOPE_CREEP: <N>
  all_findings: []
```

### Step 10: Compute Final Judgment

Compute the final judgment from all synthesized data:

- [ ] 1. `overall_verdict = PASS` iff ALL criteria have `PASS` AND all separation-of-concerns sections have `PASS` AND all scope-creep sections have `PASS`
- [ ] 2. Any single FAIL cascades to `overall_verdict = FAIL`
- [ ] 3. `next_step = "proceed"` when `overall_verdict == PASS`
- [ ] 4. `next_step = "remediate then re-audit"` when `overall_verdict == FAIL`

```yaml
final_judgment:
  overall_verdict: "PASS|FAIL"
  next_step: "proceed|remediate then re-audit"
  all_criteria_pass: <true|false>
  remediation_required: <true|false>
  criteria_total: <N>
  criteria_pass: <N>
  criteria_fail: <N>
```

### Step 11: Write judgment.yaml

Write the full judgment to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/judgment.yaml`:

```yaml
provider_type: concern-separation-path-provider
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
evidence_source: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml"
reasoning_source: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml"
verdict_source: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml"
chain_integrity:
  evidence_to_reasoning: "INTACT|BROKEN"
  reasoning_to_verdict: "INTACT|BROKEN"
  evidence_to_verdict: "INTACT|BROKEN"
  breaks: []
validation_coverage:
  total_evidence_items: <N>
  validated: <N>
  unverified: <N>
  contradicted: <N>
  criteria_with_unverified_evidence: []
  criteria_with_contradicted_evidence: []
accepted_verdicts:
  - criterion_id: "CS-1"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
  - criterion_id: "CS-2"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
  - criterion_id: "CS-3"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
  - criterion_id: "CS-4"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
  - criterion_id: "CS-5"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
  - criterion_id: "CS-6"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
  - criterion_id: "CS-ROUTING"
    evaluator_result: "PASS|FAIL"
    accepted: true
    explanation: "<Evaluator's explanation>"
    remediation: "<Evaluator's remediation>"
synthesized_concern_separation:
  sc_orthogonality: "PASS|FAIL"
  cross_concern_overlap: "PASS|FAIL"
  scope_creep_cross_concern: "PASS|FAIL"
  scope_boundary_verification: "PASS|FAIL"
  unified_findings: []
self_consistency:
  downgraded_criteria: []
  evaluator_downgrades_preserved: <N>
synthesized_findings:
  by_type:
    BOILERPLATE_TITLE: <N>
    CONCERN_MIXING: <N>
    DEPENDENCY_REVERSAL: <N>
    HIGH_RISK_GROUPING: <N>
    MISSING_RISK_CLASSIFICATION: <N>
    MISSING_INDEPENDENCE: <N>
    BLAST_RADIUS_GAP: <N>
    ROUTING_GAP: <N>
    CONCERN_GAP: <N>
    SCOPE_CREEP: <N>
  all_findings: []
final_judgment:
  overall_verdict: "PASS|FAIL"
  next_step: "proceed|remediate then re-audit"
  all_criteria_pass: <true|false>
  remediation_required: <true|false>
  criteria_total: <N>
  criteria_pass: <N>
  criteria_fail: <N>
exec_summary: "Concern separation judgment: <X>/<Y> criteria PASS. <N> phases need review. Verdict: {PASS|FAIL}."
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/judgment.yaml"
summary: "Concern separation judgment: {N} criteria, {X} PASS, {Y} FAIL. Overall: {PASS|FAIL}. Next step: {proceed|remediate then re-audit}."
overall_verdict: "PASS|FAIL"
next_step: "proceed|remediate then re-audit"
all_criteria_pass: <true|false>
remediation_required: <true|false>
```

## Edge Cases

| Scenario | Action |
|----------|--------|
| Evaluator self-consistency already downgraded criteria | Preserve Evaluator's downgrades; do not re-downgrade |
| Knowledge Supporter has UNVERIFIED evidence items | Record in validation_coverage; accept Evaluator's verdict on affected criteria |
| Knowledge Supporter has CONTRADICTED evidence items | Record in validation_coverage; accept Evaluator's verdict on affected criteria |
| Evidence chain broken (wrong source paths) | Record in chain_integrity; proceed with available data; flag in exec_summary |
| All criteria PASS but separation_of_concerns has FAIL | overall_verdict = FAIL — all sections must PASS |
| All criteria PASS but scope_creep has FAIL | overall_verdict = FAIL — all sections must PASS |
| Single-step phases | Already atomic — Evaluator should have passed CS-2; accept as-is |
| Infrastructure/testing phases | Evaluator should have reported as intentional; accept as-is |
| No routing evidence | CS-ROUTING evaluates to PASS; accept as-is |

## Error Handling

| Error | Action |
|-------|--------|
| `evidence.yaml` not found | Return BLOCKED — Generator must produce evidence first |
| `reasoning.yaml` not found | Return BLOCKED — Knowledge Supporter must validate evidence first |
| `verdict.yaml` not found | Return BLOCKED — Evaluator must produce verdict first |
| `spec_local_dir` missing or empty | Return BLOCKED — cannot synthesize without source context |
| Upstream YAML unparseable | Return BLOCKED with `ARTIFACT_UNREADABLE` |
| Write permission denied | Return BLOCKED — cannot write judgment.yaml |

## Red Flags

- Never re-evaluate the Evaluator's per-criterion verdicts — accept as final
- Never produce new evidence or re-validate existing evidence — that is upstream work
- Never overrule a PASS/FAIL from the Evaluator — the Evaluator is the sole authority on per-criterion verdicts
- Never add new findings beyond what the Evaluator produced — synthesize, do not create
- Never change the Evaluator's remediation text — accept as-is
- Never fabricate verdicts when upstream artifacts are missing — missing data = BLOCKED
- Never pass YAML verdict content inline through orchestrator context — artifacts stay on disk

## Cross-References

- `tasks/concern-separation-generator.md` — Generator role (produces evidence.yaml)
- `tasks/concern-separation-knowledge-supporter.md` — Knowledge Supporter role (produces reasoning.yaml)
- `tasks/concern-separation-evaluator.md` — Evaluator role (produces verdict.yaml)
- `tasks/cross-validate.md` — General Path Provider (cross-validate for other audit tasks)
- `audit/SKILL.md` — DiMo role chain dispatch
- `000-critical-rules.md` — Single Concern Principle
- `065-verification-honesty.md` — live verification requirement
