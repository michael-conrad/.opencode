---
name: coherence-maintenance-evaluator
description: "Evaluator role for the coherence-maintenance DiMo chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each coherence criterion, and writes verdict.yaml with per-criterion PASS/FAIL verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: coherence-maintenance-evaluator

## Purpose

Evaluator role for the coherence-maintenance DiMo chain. Reads `evidence.yaml` (Generator) and `reasoning.yaml` (upstream reasoning role), evaluates each coherence maintenance criterion against the validated evidence, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This role produces judgments — it does NOT collect evidence or validate evidence against sources.

> **DiMo Role: Evaluator.** This task evaluates coherence maintenance criteria. Reads `evidence.yaml` from the Generator and `reasoning.yaml` from the upstream reasoning role, then produces `verdict.yaml` with binary PASS/FAIL verdicts per criterion.
>
> You are the Evaluator. You are decisive and binary. Every criterion gets a PASS or a FAIL — nothing in between. You do not hedge, you do not defer, you do not ask for a second opinion. The evidence is in front of you. The upstream reasoning role has already validated it. Make the call.
>
>
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns"
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-evaluate evidence that upstream reasoning role already validated
> - MUST NOT re-collect evidence that Generator already collected
> - MUST write `verdict.yaml` as the primary output artifact
> - MUST apply the self-consistency gate: any hedging language in a PASS explanation downgrades to FAIL

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts (contains `evidence.yaml` from Generator and `reasoning.yaml` from upstream reasoning role)
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` (produced by Generator)
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` (produced by upstream reasoning role)
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (readable directory containing upstream artifacts)

## Exit Criteria

- `verdict.yaml` written to `{artifact_evidence_dir}/verdict.yaml`
- Every coherence maintenance criterion (CM-1 through CM-5) evaluated with binary PASS/FAIL
- Each verdict backed by evidence from `evidence.yaml` and validation from `reasoning.yaml`
- Drift classified as controlled or uncontrolled per criterion
- Migration candidates evaluated for completeness
- Self-consistency gate applied — no hedging language in PASS explanations
- Overall verdict computed: PASS if all criteria PASS, FAIL otherwise
- No re-collection of evidence — judgments only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `verdict.yaml` from `{artifact_evidence_dir}/`

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

- [ ] 5. Verify `artifact_evidence_dir` is writable

### Step 2: Load Upstream Artifacts

Read and parse the Generator's evidence and upstream reasoning role's validation:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml`
- [ ] 2. Parse the YAML content
- [ ] 3. Verify required top-level keys exist: `baseline`, `current_guidelines`, `current_skills`, `raw_diff`, `coherence_metrics`, `migration_candidate_evidence`, `state_analysis_evidence`
- [ ] 4. If any required key is missing, return BLOCKED with `MALFORMED_EVIDENCE` and the missing key name
- [ ] 5. Read `{artifact_evidence_dir}/reasoning.yaml`
- [ ] 6. Parse the YAML content
- [ ] 7. Verify required top-level keys exist: `baseline_validation`, `guideline_validation`, `skill_validation`, `diff_validation`, `metrics_validation`, `migration_candidate_validation`, `state_analysis_validation`, `overall_validation`
- [ ] 8. If any required key is missing, return BLOCKED with `MALFORMED_REASONING` and the missing key name
- [ ] 9. Record artifact metadata: generator name, knowledge supporter name, issue number, timestamps

### Step 3: Evaluate CM-1 — Baseline Rule Presence

Evaluate whether all baseline rules are present in the current state with no uncontrolled removals:

- [ ] 1. From `evidence.yaml` → `raw_diff.rules_removed`, identify all rules removed since baseline
- [ ] 2. From `reasoning.yaml` → `diff_validation.rules_removed`, check validation status for each removed rule
- [ ] 3. For each removed rule, determine if the removal is controlled (has corresponding migration, deprecation notice, or intentional decomposition) or uncontrolled (no justification)
- [ ] 4. **Controlled removal indicators:**
  - Rule was migrated to a skill (check `raw_diff.behaviors_added` for corresponding behavior)
  - Rule was deprecated with a deprecation notice in the guideline file
  - Rule was decomposed into sub-rules (check `raw_diff.rules_added` for replacement rules)
  - Rule was intentionally removed as part of a spec-driven change
- [ ] 5. **Uncontrolled removal indicators:**
  - Rule removed with no corresponding addition or migration
  - Rule removed with no deprecation notice
  - Rule removed and no replacement behavior exists
- [ ] 6. Produce verdict:

```yaml
CM-1:
  criterion: "All baseline rules present in current — no uncontrolled removals"
  result: PASS | FAIL
  evidence:
    total_rules_removed: <N>
    controlled_removals: <N>
    uncontrolled_removals: <N>
    uncontrolled_rule_ids: ["<rule-id>", ...]
  explanation: "<judgment>"
```

**PASS condition:** Zero uncontrolled removals. All removed rules have corresponding migration, deprecation, or decomposition.
**FAIL condition:** One or more uncontrolled removals. Rules removed without justification.

### Step 4: Evaluate CM-2 — Rule Modification Intentionality

Evaluate whether all rule modifications are intentional and controlled:

- [ ] 1. From `evidence.yaml` → `raw_diff.rules_modified`, identify all rules modified since baseline
- [ ] 2. From `reasoning.yaml` → `diff_validation.rules_modified`, check validation status for each modified rule
- [ ] 3. For each modified rule, compare baseline and current conditions/actions
- [ ] 4. **Controlled modification indicators:**
  - Modification corresponds to a spec-driven change (check `spec_local_dir` for related specs)
  - Modification is a clarification or refinement (conditions tightened, actions made more specific)
  - Modification adds new conditions or actions that extend (not contradict) the original rule
  - Modification has a corresponding changelog entry or commit message explaining the change
- [ ] 5. **Uncontrolled modification indicators:**
  - Modification contradicts the original rule's intent
  - Modification weakens the rule (removes conditions, broadens exceptions without justification)
  - Modification changes the rule's scope without corresponding spec change
  - Modification has no explanation or justification
- [ ] 6. Produce verdict:

```yaml
CM-2:
  criterion: "All rule modifications intentional — controlled modifications"
  result: PASS | FAIL
  evidence:
    total_rules_modified: <N>
    controlled_modifications: <N>
    uncontrolled_modifications: <N>
    uncontrolled_rule_ids: ["<rule-id>", ...]
  explanation: "<judgment>"
```

**PASS condition:** Zero uncontrolled modifications. All modifications are intentional with clear justification.
**FAIL condition:** One or more uncontrolled modifications. Rules changed without justification or with contradictory intent.

### Step 5: Evaluate CM-3 — No Orphan Skills

Evaluate whether every skill has a baseline reference and no skills are orphaned:

- [ ] 1. From `evidence.yaml` → `coherence_metrics.current.orphan_rules`, identify all orphan rules
- [ ] 2. From `reasoning.yaml` → `metrics_validation`, check validation status for orphan rule metrics
- [ ] 3. From `evidence.yaml` → `current_skills.behaviors`, identify skills with zero guideline references
- [ ] 4. **Orphan classification:**
  - **Guideline orphan:** A guideline rule with zero skill behavior references — the rule exists but nothing enforces it
  - **Skill orphan:** A skill behavior with zero guideline rule references — the behavior exists but has no governing rule
- [ ] 5. For each orphan, determine if it is intentional (new rule awaiting skill implementation, new skill awaiting guideline) or unintentional (drift)
- [ ] 6. Produce verdict:

```yaml
CM-3:
  criterion: "No orphan skills — each skill has baseline reference"
  result: PASS | FAIL
  evidence:
    total_orphan_rules: <N>
    guideline_orphans: <N>
    skill_orphans: <N>
    orphan_rule_ids: ["<rule-id>", ...]
    orphan_skills: ["<skill name>", ...]
  explanation: "<judgment>"
```

**PASS condition:** Zero orphans, or all orphans are intentional (new rules/skills with planned cross-references).
**FAIL condition:** One or more unintentional orphans. Rules or skills with no cross-references and no justification.

### Step 6: Evaluate CM-4 — Cross-Reference Consistency

Evaluate whether guideline ↔ skill cross-references are consistent and valid:

- [ ] 1. From `evidence.yaml` → `raw_diff.cross_refs_changed`, `cross_refs_added`, `cross_refs_removed`, identify all cross-reference changes
- [ ] 2. From `reasoning.yaml` → `diff_validation`, check validation status for cross-reference changes
- [ ] 3. For each cross-reference change:
  - [ ] 3a. **Changed cross-refs:** Verify the new target exists and is semantically consistent with the old target
  - [ ] 3b. **Added cross-refs:** Verify the target exists and the reference is bidirectional (guideline references skill AND skill references guideline)
  - [ ] 3c. **Removed cross-refs:** Verify the removal is intentional (target was deprecated, migrated, or decomposed)
- [ ] 4. **Consistency indicators:**
  - Bidirectional references: guideline → skill AND skill → guideline
  - Target existence: every cross-reference points to an existing file or rule ID
  - Semantic alignment: the referenced rule/behavior matches the referencing context
- [ ] 5. **Inconsistency indicators:**
  - One-way references: guideline references skill but skill does not reference guideline (or vice versa)
  - Dangling references: cross-reference points to a non-existent file or rule ID
  - Semantic mismatch: cross-reference points to unrelated content
- [ ] 6. Produce verdict:

```yaml
CM-4:
  criterion: "Cross-refs consistent — guideline ↔ skill mapping valid"
  result: PASS | FAIL
  evidence:
    total_cross_refs_changed: <N>
    total_cross_refs_added: <N>
    total_cross_refs_removed: <N>
    inconsistent_refs: <N>
    dangling_refs: <N>
    one_way_refs: <N>
    inconsistent_details:
      - reference: "<ref>"
        issue: "dangling | one_way | semantic_mismatch"
        detail: "<description>"
  explanation: "<judgment>"
```

**PASS condition:** All cross-references are bidirectional, targets exist, and semantics align. Zero dangling or one-way references.
**FAIL condition:** One or more inconsistent cross-references. Dangling, one-way, or semantically mismatched references.

### Step 7: Evaluate CM-5 — Migration Candidate Identification

Evaluate whether procedural workflow migration candidates are properly identified:

- [ ] 1. From `evidence.yaml` → `migration_candidate_evidence.candidates`, review all identified candidates
- [ ] 2. From `reasoning.yaml` → `migration_candidate_validation`, check validation status for each candidate
- [ ] 3. For each candidate, evaluate:
  - [ ] 3a. Does the task file actually contain procedural workflow patterns?
  - [ ] 3b. Is the pattern classification correct (procedural_workflow, checklist, sequential_steps)?
  - [ ] 3c. Is the step count accurate?
  - [ ] 3d. Would extraction improve coherence (reduce guideline bloat, improve skill autonomy)?
- [ ] 4. **Completeness check:** Are there procedural workflows in the codebase that were NOT identified as candidates?
  - [ ] 4a. From `reasoning.yaml` → `migration_candidate_validation.spot_check`, review excluded tasks
  - [ ] 4b. If spot check found false positives (excluded tasks that SHOULD be candidates), flag as incomplete
- [ ] 5. Produce verdict:

```yaml
CM-5:
  criterion: "Migration candidates identified — procedural workflows flagged"
  result: PASS | FAIL
  evidence:
    total_candidates: <N>
    validated_candidates: <N>
    false_positives: <N>
    missed_candidates: <N>
    candidate_details:
      - skill: "<skill name>"
        task: "<task name>"
        pattern: "<pattern>"
        step_count: <N>
        extraction_benefit: "high | medium | low"
  explanation: "<judgment>"
```

**PASS condition:** All procedural workflows identified as candidates. No missed candidates. All identified candidates are genuine procedural workflows.
**FAIL condition:** Missed candidates (procedural workflows not flagged). False positives (non-procedural tasks flagged as candidates). Incomplete identification.

### Step 8: Evaluate State Analysis Evidence

Evaluate the state analysis evidence for completeness and relevance:

- [ ] 1. From `evidence.yaml` → `state_analysis_evidence`, check if state analysis was provided
- [ ] 2. From `reasoning.yaml` → `state_analysis_validation`, check validation status
- [ ] 3. If state analysis was provided and validated:
  - [ ] 3a. Evaluate whether the state analysis covers all relevant state transitions affected by the changes
  - [ ] 3b. Evaluate whether the state analysis identifies any coherence-breaking state transitions
- [ ] 4. If state analysis was not provided:
  - [ ] 4a. Record as `not_provided` — this is informational, not a FAIL condition
  - [ ] 4b. Note that state analysis absence limits confidence in coherence evaluation
- [ ] 5. Produce evaluation:

```yaml
state_analysis_evaluation:
  provided: true | false
  validated: true | false
  covers_all_transitions: true | false | not_applicable
  coherence_breaking_transitions: <N>
  confidence_impact: "none | reduced | significant"
  explanation: "<judgment>"
```

**Note:** State analysis absence is NOT a FAIL condition for the overall verdict. It reduces confidence but does not block PASS.

### Step 9: Compute Overall Verdict

Compute the overall coherence maintenance verdict from per-criterion results:

- [ ] 1. Collect all criterion verdicts (CM-1 through CM-5)
- [ ] 2. Overall PASS: ALL five criteria are PASS
- [ ] 3. Overall FAIL: ANY criterion is FAIL
- [ ] 4. Compute drift summary from `evidence.yaml` → `raw_diff.summary`:
  - [ ] 4a. Total controlled changes: rules_added + behaviors_added + controlled modifications + controlled removals
  - [ ] 4b. Total uncontrolled changes: uncontrolled removals + uncontrolled modifications + orphan rules + inconsistent cross-refs
- [ ] 5. Compute coherence health score:

```yaml
coherence_health:
  guideline_coverage: <float from evidence.yaml>
  skill_alignment: <float from evidence.yaml>
  orphan_rate: <float>
  cross_ref_integrity: <float>
  overall_score: <float 0.0-1.0>
```

### Step 10: Apply Self-Consistency Gate

Before accepting the verdict, run a self-consistency check on every criterion entry:

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

- [ ] 2. For each criterion with `result: PASS`:
  - [ ] 2a. Check if the `explanation` field contains any hedging pattern
  - [ ] 2b. If a hedging pattern is found, downgrade the criterion to FAIL
  - [ ] 2c. Record the downgrade with a self-consistency note
- [ ] 3. If any criterion is downgraded, recompute the overall verdict to FAIL
- [ ] 4. Record self-consistency results:

```yaml
self_consistency:
  criteria_checked: <N>
  downgrades:
    - criterion: "<criterion-id>"
      original_result: PASS
      downgraded_to: FAIL
      hedging_pattern_found: "<pattern>"
      self_consistency_note: "Downgraded from PASS to FAIL: explanation contains critique/hedging language ('<pattern>') inconsistent with PASS verdict"
  total_downgrades: <N>
  overall_verdict_adjusted: true | false
```

### Step 11: Write verdict.yaml

Write the complete verdict to `{artifact_evidence_dir}/verdict.yaml`:

```yaml
evaluator: coherence-maintenance-evaluator
issue_number: <N>
generated_at: "<timestamp>"
artifact_evidence_dir: "<path>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
evidence_generated_at: "<timestamp from evidence.yaml>"
reasoning_generated_at: "<timestamp from reasoning.yaml>"
criteria:
  CM-1: {...}
  CM-2: {...}
  CM-3: {...}
  CM-4: {...}
  CM-5: {...}
state_analysis_evaluation: {...}
coherence_health: {...}
self_consistency: {...}
drift_summary:
  total_changes: <N>
  controlled_changes: <N>
  uncontrolled_changes: <N>
  rules_added: <N>
  rules_removed: <N>
  rules_modified: <N>
  behaviors_added: <N>
  behaviors_removed: <N>
  behaviors_modified: <N>
  cross_refs_changed: <N>
overall_verdict: PASS | FAIL
passing_criteria: <N>
failing_criteria: <N>
failing_criterion_ids: ["<criterion-id>", ...]
executive_summary: "Coherence maintenance evaluation: <N>/5 criteria PASS. <C> controlled changes, <U> uncontrolled changes. Verdict: <PASS|FAIL>."
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "Coherence maintenance evaluated: <N>/5 criteria PASS. <C> controlled, <U> uncontrolled changes. Verdict: <PASS|FAIL>."
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Evaluate CM-1 (Baseline Rule Presence) → INVALID if skipped
- [ ] 4. Evaluate CM-2 (Rule Modification Intentionality) → INVALID if skipped
- [ ] 5. Evaluate CM-3 (No Orphan Skills) → INVALID if skipped
- [ ] 6. Evaluate CM-4 (Cross-Reference Consistency) → INVALID if skipped
- [ ] 7. Evaluate CM-5 (Migration Candidate Identification) → INVALID if skipped
- [ ] 8. Evaluate State Analysis Evidence → INVALID if skipped
- [ ] 9. Compute Overall Verdict → INVALID if skipped
- [ ] 10. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 11. Write verdict.yaml → INVALID if skipped
- [ ] 12. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml not found | Return BLOCKED — run `coherence-maintenance-generator` first |
| reasoning.yaml not found | Return BLOCKED — run `coherence-maintenance-knowledge-supporter` first |
| evidence.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_EVIDENCE` and missing key name |
| reasoning.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_REASONING` and missing key name |
| Validation mismatch in reasoning.yaml for a criterion's evidence | Use the upstream reasoning role's validated values — do NOT re-validate |
| Evidence item unverifiable in reasoning.yaml | Record as `confidence: reduced` for that criterion — do NOT BLOCK |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| All evidence validated but insufficient for judgment | Return FAIL with `INSUFFICIENT_EVIDENCE` — do NOT produce PASS on insufficient data |
| Self-consistency gate triggers downgrade | Apply downgrade, recompute overall verdict — do NOT override the gate |

## Cross-References

- `tasks/coherence-maintenance-generator.md` — Generator role (produces the evidence.yaml consumed by this task)
- `tasks/coherence-maintenance-knowledge-supporter.md` — upstream reasoning role role (produces the reasoning.yaml consumed by this task)
- `tasks/cross-validate.md` — Path Provider role (consumes this Evaluator's verdict.yaml)
- `tasks/coherence-extraction.md` — baseline generation (prerequisite for the Generator)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — coherence maintenance requirement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
