---
name: coherence-maintenance-path-provider
description: "Arbiter role for the coherence-maintenance chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: coherence-maintenance-path-provider

## Purpose

Arbiter role for the coherence-maintenance chain. Reads all upstream artifacts — `evidence.yaml` (Investigator), `reasoning.yaml` (Validator), `verdict.yaml` (Evaluator) — and produces the final `judgment.yaml` with final judgment and `next_step`. This role synthesizes, not evaluates. It does NOT re-evaluate criteria, re-validate evidence, or second-guess upstream roles.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts (contains `evidence.yaml`, `reasoning.yaml`, `verdict.yaml` from upstream roles)
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` (produced by Investigator)
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` (produced by Validator)
- `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` (produced by Evaluator)
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (readable directory containing all upstream artifacts)

## Exit Criteria

- `judgment.yaml` written to `{artifact_evidence_dir}/judgment.yaml`
- All upstream artifacts loaded and cross-referenced
- Evaluator's per-criterion verdicts (CM-1 through CM-5) accepted as final — no re-evaluation
- Evidence-to-verdict consistency verified (verdict backed by evidence, evidence validated by reasoning)
- Self-consistency gate applied — no hedging language in PASS explanations
- Overall judgment computed: PASS if all criteria PASS, FAIL otherwise
- `next_step` field set: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL
- Drift summary synthesized from upstream artifacts
- Coherence health score synthesized from upstream artifacts
- No re-evaluation of criteria — synthesis only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `judgment.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml`
- [ ] 2. If `evidence.yaml` not found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "No evidence.yaml found in {artifact_evidence_dir}/. Run coherence-maintenance-generator first to produce evidence."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml`
- [ ] 4. If `reasoning.yaml` not found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "No reasoning.yaml found in {artifact_evidence_dir}/. Run coherence-maintenance-knowledge-supporter first to validate evidence."
```

- [ ] 5. Verify `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml`
- [ ] 6. If `verdict.yaml` not found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "No verdict.yaml found in {artifact_evidence_dir}/. Run coherence-maintenance-evaluator first to produce verdicts."
```

- [ ] 7. Verify `artifact_evidence_dir` is writable

### Step 2: Load Upstream Artifacts

Read and parse all three upstream artifacts:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml`
- [ ] 2. Parse the YAML content
- [ ] 3. Verify required top-level keys exist: `baseline`, `current_guidelines`, `current_skills`, `raw_diff`, `coherence_metrics`, `migration_candidate_evidence`, `state_analysis_evidence`
- [ ] 4. If any required key is missing, return BLOCKED with `MALFORMED_EVIDENCE` and the missing key name
- [ ] 5. Read `{artifact_evidence_dir}/reasoning.yaml`
- [ ] 6. Parse the YAML content
- [ ] 7. Verify required top-level keys exist: `baseline_validation`, `guideline_validation`, `skill_validation`, `diff_validation`, `metrics_validation`, `migration_candidate_validation`, `state_analysis_validation`, `overall_validation`
- [ ] 8. If any required key is missing, return BLOCKED with `MALFORMED_REASONING` and the missing key name
- [ ] 9. Read `{artifact_evidence_dir}/verdict.yaml`
- [ ] 10. Parse the YAML content
- [ ] 11. Verify required top-level keys exist: `criteria` (with CM-1 through CM-5), `coherence_health`, `self_consistency`, `drift_summary`, `overall_verdict`
- [ ] 12. If any required key is missing, return BLOCKED with `MALFORMED_VERDICT` and the missing key name
- [ ] 13. Record artifact metadata: generator name, knowledge supporter name, evaluator name, issue number, timestamps

### Step 3: Cross-Reference Evidence-to-Verdict Consistency

Verify that each criterion verdict is backed by evidence and that evidence was validated:

- [ ] 1. For each criterion (CM-1 through CM-5) in `verdict.yaml` → `criteria`:
  - [ ] 1a. Verify the criterion's `evidence` fields reference data that exists in `evidence.yaml`
  - [ ] 1b. Verify the referenced evidence was validated in `reasoning.yaml` (check corresponding validation section)
  - [ ] 1c. If evidence referenced in the verdict has a `mismatch` or `unverifiable` status in reasoning, flag as `EVIDENCE_INTEGRITY_CONCERN`
  - [ ] 1d. If the verdict's `result` is PASS but the referenced evidence has validation mismatches, flag as `VERDICT_EVIDENCE_MISALIGNMENT`
- [ ] 2. **CM-1 (Baseline Rule Presence):** Cross-check verdict's `uncontrolled_removals` count against `evidence.yaml` → `raw_diff.rules_removed` and `reasoning.yaml` → `diff_validation.rules_removed`
- [ ] 3. **CM-2 (Rule Modification Intentionality):** Cross-check verdict's `uncontrolled_modifications` count against `evidence.yaml` → `raw_diff.rules_modified` and `reasoning.yaml` → `diff_validation.rules_modified`
- [ ] 4. **CM-3 (No Orphan Skills):** Cross-check verdict's `orphan_rule_ids` against `evidence.yaml` → `coherence_metrics.current.orphan_rules` and `reasoning.yaml` → `metrics_validation`
- [ ] 5. **CM-4 (Cross-Reference Consistency):** Cross-check verdict's `inconsistent_refs` against `evidence.yaml` → `raw_diff.cross_refs_*` and `reasoning.yaml` → `diff_validation.cross_refs_*`
- [ ] 6. **CM-5 (Migration Candidate Identification):** Cross-check verdict's `candidate_details` against `evidence.yaml` → `migration_candidate_evidence` and `reasoning.yaml` → `migration_candidate_validation`
- [ ] 7. Record cross-reference results:

```yaml
evidence_verdict_consistency:
  CM-1:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  CM-2:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  CM-3:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  CM-4:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  CM-5:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  overall_alignment: "aligned | misaligned"
```

**Note:** Evidence-to-verdict misalignment is recorded as a finding but does NOT override the Evaluator's verdict. The Evaluator's verdict stands. Misalignment is reported in the judgment for transparency.

### Step 4: Synthesize Drift Summary

Synthesize the drift picture from all three upstream artifacts:

- [ ] 1. From `evidence.yaml` → `raw_diff.summary`, collect raw change counts
- [ ] 2. From `reasoning.yaml` → `diff_validation`, collect validation status for each change category
- [ ] 3. From `verdict.yaml` → `drift_summary`, collect the Evaluator's controlled/uncontrolled classification
- [ ] 4. Synthesize into a unified drift picture:

```yaml
synthesized_drift:
  total_changes: <N>
  controlled_changes: <N>
  uncontrolled_changes: <N>
  by_category:
    rules_added:
      count: <N>
      validated: <N>
      mismatches: <N>
    rules_removed:
      count: <N>
      controlled: <N>
      uncontrolled: <N>
    rules_modified:
      count: <N>
      controlled: <N>
      uncontrolled: <N>
    behaviors_added:
      count: <N>
      validated: <N>
      mismatches: <N>
    behaviors_removed:
      count: <N>
      controlled: <N>
      uncontrolled: <N>
    behaviors_modified:
      count: <N>
      controlled: <N>
      uncontrolled: <N>
    cross_refs_changed:
      count: <N>
      consistent: <N>
      inconsistent: <N>
  evidence_validation_rate: <float 0.0-1.0>
  drift_severity: "none | low | medium | high | critical"
```

- [ ] 5. Compute `drift_severity`:
  - `none`: Zero uncontrolled changes, zero validation mismatches
  - `low`: 1-2 uncontrolled changes, all evidence validated
  - `medium`: 3-5 uncontrolled changes, or evidence validation rate < 0.95
  - `high`: 6-10 uncontrolled changes, or evidence validation rate < 0.85
  - `critical`: >10 uncontrolled changes, or evidence validation rate < 0.70

### Step 5: Synthesize Coherence Health

Synthesize the coherence health picture from upstream artifacts:

- [ ] 1. From `evidence.yaml` → `coherence_metrics`, collect raw metrics
- [ ] 2. From `reasoning.yaml` → `metrics_validation`, collect validation status for each metric
- [ ] 3. From `verdict.yaml` → `coherence_health`, collect the Evaluator's health scores
- [ ] 4. Synthesize into a unified health picture:

```yaml
synthesized_coherence_health:
  guideline_coverage:
    current: <float>
    baseline: <float>
    delta: <float>
    validated: true | false
  skill_alignment:
    current: <float>
    baseline: <float>
    delta: <float>
    validated: true | false
  orphan_rate:
    current: <float>
    baseline: <float>
    delta: <float>
    validated: true | false
  cross_ref_integrity:
    current: <float>
    baseline: <float>
    delta: <float>
    validated: true | false
  overall_score:
    evaluator_score: <float>
    metrics_validation_rate: <float 0.0-1.0>
  health_trend: "improving | stable | declining | critical"
```

- [ ] 5. Compute `health_trend`:
  - `improving`: Overall score increased, orphan rate decreased, coverage increased
  - `stable`: All deltas within ±0.05
  - `declining`: Overall score decreased, orphan rate increased, or coverage decreased
  - `critical`: Overall score < 0.5, or orphan rate > 0.3

### Step 6: Apply Self-Consistency Gate

Before accepting the judgment, run a self-consistency check on every criterion entry from the Evaluator's verdict:

- [ ] 1. Define hedging patterns that indicate a PASS verdict is inconsistent with the explanation:

```python
hedging_patterns = [
    "should be", "needs", "missing", "could improve",
    "minor", "some issues", "mostly", "generally",
    "not ideal", "could be better", "incomplete",
    "lacking", "insufficient", "problematic",
    "requires attention", "needs work", "not fully"
]
```

- [ ] 2. For each criterion with `result: PASS` in `verdict.yaml` → `criteria`:
  - [ ] 2a. Check if the `explanation` field contains any hedging pattern
  - [ ] 2b. If a hedging pattern is found, record as `SELF_CONSISTENCY_CONCERN`
  - [ ] 2c. Note: The Evaluator already applied its own self-consistency gate. This is a second-pass check for synthesis integrity.
- [ ] 3. If the Evaluator's `self_consistency` section already recorded downgrades, verify they were applied to the criteria
- [ ] 4. Record self-consistency results:

```yaml
synthesized_self_consistency:
  evaluator_downgrades: <N>
  evaluator_downgrade_details:
    - criterion: "<criterion-id>"
      original_result: PASS
      downgraded_to: FAIL
      hedging_pattern_found: "<pattern>"
  path_provider_concerns: <N>
  path_provider_concern_details:
    - criterion: "<criterion-id>"
      evaluator_result: PASS
      concern: "explanation contains hedging language: '<pattern>'"
  overall_consistent: true | false
```

**Note:** The Arbiter does NOT downgrade verdicts. It records concerns for transparency. The Evaluator's verdicts are final.

### Step 7: Synthesize Migration Candidate Picture

Synthesize the migration candidate picture from upstream artifacts:

- [ ] 1. From `evidence.yaml` → `migration_candidate_evidence`, collect raw candidates
- [ ] 2. From `reasoning.yaml` → `migration_candidate_validation`, collect validation status
- [ ] 3. From `verdict.yaml` → `criteria.CM-5`, collect the Evaluator's assessment
- [ ] 4. Synthesize:

```yaml
synthesized_migration_candidates:
  total_candidates: <N>
  validated_candidates: <N>
  false_positives: <N>
  missed_candidates: <N>
  candidates:
    - skill: "<skill name>"
      task: "<task name>"
      pattern: "<pattern>"
      step_count: <N>
      extraction_benefit: "high | medium | low"
      validated: true | false
  completeness: "complete | incomplete"
```

### Step 8: Synthesize State Analysis Picture

Synthesize the state analysis picture from upstream artifacts:

- [ ] 1. From `evidence.yaml` → `state_analysis_evidence`, check if state analysis was provided
- [ ] 2. From `reasoning.yaml` → `state_analysis_validation`, collect validation status
- [ ] 3. From `verdict.yaml` → `state_analysis_evaluation`, collect the Evaluator's assessment
- [ ] 4. Synthesize:

```yaml
synthesized_state_analysis:
  provided: true | false
  validated: true | false
  covers_all_transitions: true | false | not_applicable
  coherence_breaking_transitions: <N>
  confidence_impact: "none | reduced | significant"
```

### Step 9: Compute Final Judgment

Compute the final judgment from all synthesized data:

- [ ] 1. Collect all criterion verdicts from `verdict.yaml` → `criteria` (CM-1 through CM-5)
- [ ] 2. **Overall PASS:** ALL five criteria are PASS AND evidence-verdict consistency is aligned AND self-consistency gate is clean
- [ ] 3. **Overall FAIL:** ANY criterion is FAIL, OR evidence-verdict consistency is misaligned, OR self-consistency concerns exist
- [ ] 4. Determine `next_step`:
  - `overall_judgment == PASS` → `next_step: "proceed"`
  - `overall_judgment == FAIL` → `next_step: "remediate then re-audit"`
- [ ] 5. Compose executive summary:

```yaml
final_judgment:
  overall: PASS | FAIL
  next_step: "proceed | remediate then re-audit"
  passing_criteria: <N>
  failing_criteria: <N>
  failing_criterion_ids: ["<criterion-id>", ...]
  evidence_verdict_alignment: "aligned | misaligned"
  self_consistency_clean: true | false
  drift_severity: "none | low | medium | high | critical"
  health_trend: "improving | stable | declining | critical"
  executive_summary: "Coherence maintenance judgment: <N>/5 criteria PASS. Drift: <C> controlled, <U> uncontrolled changes. Health trend: <trend>. Verdict: <PASS|FAIL>. Next step: <next_step>."
```

### Step 10: Write judgment.yaml

Write the complete judgment to `{artifact_evidence_dir}/judgment.yaml`:

```yaml
path_provider: coherence-maintenance-path-provider
issue_number: <N>
generated_at: "<timestamp>"
artifact_evidence_dir: "<path>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
verdict_source: "{artifact_evidence_dir}/verdict.yaml"
evidence_generated_at: "<timestamp from evidence.yaml>"
reasoning_generated_at: "<timestamp from reasoning.yaml>"
verdict_generated_at: "<timestamp from verdict.yaml>"
upstream_roles:
  generator: "<generator name from evidence.yaml>"
  knowledge_supporter: "<knowledge supporter name from reasoning.yaml>"
  evaluator: "<evaluator name from verdict.yaml>"
criteria:
  CM-1:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  CM-2:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  CM-3:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  CM-4:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  CM-5:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
evidence_verdict_consistency: {...}
synthesized_drift: {...}
synthesized_coherence_health: {...}
synthesized_self_consistency: {...}
synthesized_migration_candidates: {...}
synthesized_state_analysis: {...}
final_judgment: {...}
```

### Step 11: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/judgment.yaml"
summary: "Coherence maintenance judgment: <N>/5 criteria PASS. Drift: <C> controlled, <U> uncontrolled. Health: <trend>. Verdict: <PASS|FAIL>. Next step: <next_step>."
overall_judgment: PASS | FAIL
next_step: "proceed | remediate then re-audit"
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Cross-Reference Evidence-to-Verdict Consistency → INVALID if skipped
- [ ] 4. Synthesize Drift Summary → INVALID if skipped
- [ ] 5. Synthesize Coherence Health → INVALID if skipped
- [ ] 6. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 7. Synthesize Migration Candidate Picture → INVALID if skipped
- [ ] 8. Synthesize State Analysis Picture → INVALID if skipped
- [ ] 9. Compute Final Judgment → INVALID if skipped
- [ ] 10. Write judgment.yaml → INVALID if skipped
- [ ] 11. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml not found | Return BLOCKED — run `coherence-maintenance-generator` first |
| reasoning.yaml not found | Return BLOCKED — run `coherence-maintenance-knowledge-supporter` first |
| verdict.yaml not found | Return BLOCKED — run `coherence-maintenance-evaluator` first |
| evidence.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_EVIDENCE` and missing key name |
| reasoning.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_REASONING` and missing key name |
| verdict.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_VERDICT` and missing key name |
| Verdict references evidence not in evidence.yaml | Record as `EVIDENCE_INTEGRITY_CONCERN` — do NOT BLOCK |
| Evidence referenced in verdict has validation mismatch | Record as `VERDICT_EVIDENCE_MISALIGNMENT` — do NOT BLOCK |
| Evaluator self-consistency downgrades not applied to criteria | Record as `SELF_CONSISTENCY_CONCERN` — do NOT BLOCK |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Upstream artifact YAML unparseable | Return BLOCKED with `ARTIFACT_UNREADABLE` and file path |

## Non-Recovery Gates

The following states are **terminal BLOCKED states** with no fallback or recovery paths:

| Gate | Condition | Error Code | Action |
|------|-----------|------------|--------|
| MISSING_INPUT | Any upstream artifact missing | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<file>" }` |
| ARTIFACT_UNREADABLE | Upstream YAML artifact cannot be read or parsed | `ARTIFACT_UNREADABLE` | Return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE", file: "<path>" }` |
| MALFORMED_ARTIFACT | Upstream YAML artifact missing required keys | `MALFORMED_EVIDENCE` / `MALFORMED_REASONING` / `MALFORMED_VERDICT` | Return `{ status: "BLOCKED", error: "<code>", missing_key: "<key>" }` |

## Red Flags

- Never re-evaluate criteria — the Evaluator's verdicts are final
- Never re-validate evidence — the Validator's validation is final
- Never re-collect evidence — the Investigator's evidence is final
- Never override a PASS/FAIL from the Evaluator
- Never produce new evidence or findings beyond what upstream roles produced
- Never fabricate verdicts when upstream artifacts are unreadable — missing data = BLOCKED
- Never accept memory-cached claims as evidence — every reference must trace to an upstream artifact
- Never pass YAML artifact content inline through orchestrator context — artifacts stay on disk

## Cross-References

- `tasks/coherence-maintenance-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/coherence-maintenance-validator.md` — Validator role (produces the reasoning.yaml consumed by this task)
- `tasks/coherence-maintenance-evaluator.md` — Evaluator role (produces the verdict.yaml consumed by this task)
- `tasks/coherence-extraction.md` — baseline generation (prerequisite for the Investigator)
- `tasks/cross-validate.md` — Sole Arbiter for general audit chain (analogous role, different domain)
- `000-critical-rules.md` — coherence maintenance requirement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
