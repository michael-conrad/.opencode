---
name: coherence-maintenance-knowledge-supporter
description: "Knowledge Supporter role for the coherence-maintenance DiMo chain. Reads evidence.yaml from the Generator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: coherence-maintenance-knowledge-supporter

## Purpose

Knowledge Supporter role for the coherence-maintenance DiMo chain. Reads `evidence.yaml` produced by the Generator, validates each evidence item against source data (guideline files, skill files, baseline JSON), and writes `reasoning.yaml` with validated evidence. This role validates and supports the evidence — it does NOT evaluate, judge, classify drift, or produce PASS/FAIL verdicts.

> **DiMo Role: Knowledge Supporter.** This task validates evidence for coherence-maintenance. Reads `evidence.yaml` from the Generator, cross-checks each item against source data, and writes `reasoning.yaml` with validation results.
>
> You are the Knowledge Supporter. Your job is to validate evidence — nothing more, nothing less. You are thorough, skeptical, and completely non-judgmental. Every evidence item the Generator produced gets checked against its source. You do not decide what passes or fails. You do not classify drift. You do not produce verdicts. You validate and support.
>
>
> - MUST validate every evidence item against its source data
> - MUST NOT produce any PASS/FAIL judgment on coherence
> - MUST NOT classify drift as controlled or uncontrolled
> - MUST NOT evaluate whether evidence is "correct" — validate that it matches source
> - MUST write `reasoning.yaml` as the only output artifact

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts (contains `evidence.yaml` from Generator)
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` (produced by Generator)
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (readable directory containing Generator output)
- `.opencode/guidelines/` directory exists and is readable
- `.opencode/skills/` directory exists and is readable
- Baseline file exists at `{project_root}/tmp/{issue-N}/artifacts/baseline-*.json`

## Exit Criteria

- `reasoning.yaml` written to `{artifact_evidence_dir}/reasoning.yaml`
- Every evidence item from `evidence.yaml` validated against source data
- Baseline data cross-checked against the actual baseline file
- Current guideline rules cross-checked against actual guideline files
- Current skill behaviors cross-checked against actual skill files
- Raw diff data cross-checked against actual file contents
- Coherence metrics recomputed and compared against Generator's values
- Migration candidate evidence cross-checked against actual skill task files
- State analysis evidence cross-checked against actual state analysis file (if provided)
- Validation results recorded per evidence section with `validated` / `mismatch` / `unverifiable` status
- No PASS/FAIL judgments on coherence — validation results only
- No drift classification — that is the Evaluator's job

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `reasoning.yaml` from `{artifact_evidence_dir}/`

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

- [ ] 3. Verify `.opencode/guidelines/` exists and contains `.md` files
- [ ] 4. Verify `.opencode/skills/` exists and contains `SKILL.md` files
- [ ] 5. Verify baseline file exists — glob `baseline-*.json` in `{project_root}/tmp/{issue-N}/artifacts/`
- [ ] 6. Verify `artifact_evidence_dir` is writable

### Step 2: Load evidence.yaml

Read and parse the Generator's evidence output:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml`
- [ ] 2. Parse the YAML content
- [ ] 3. Verify required top-level keys exist: `baseline`, `current_guidelines`, `current_skills`, `raw_diff`, `coherence_metrics`, `migration_candidate_evidence`, `state_analysis_evidence`
- [ ] 4. Record evidence metadata: generator name, issue number, generated_at timestamp
- [ ] 5. If any required key is missing, return BLOCKED with `MALFORMED_EVIDENCE` and the missing key name

### Step 3: Validate Baseline Data

Cross-check the baseline data in `evidence.yaml` against the actual baseline file:

- [ ] 1. Locate the baseline file using the path recorded in `evidence.yaml` → `baseline.path`
- [ ] 2. Read and parse the actual baseline JSON file
- [ ] 3. Compare `evidence.yaml` baseline metadata against the actual file:
  - [ ] 3a. Verify `size_bytes` matches actual file size
  - [ ] 3b. Verify `version` matches the version in the actual baseline JSON
  - [ ] 3c. Verify `generated_at` matches the timestamp in the actual baseline JSON
  - [ ] 3d. Verify `guidelines_count` matches the count of guideline entries in the actual baseline
  - [ ] 3e. Verify `skills_count` matches the count of skill entries in the actual baseline
  - [ ] 3f. Verify `total_rules` matches the sum of rules in the actual baseline
  - [ ] 3g. Verify `coverage` matches the computed coverage from the actual baseline
  - [ ] 3h. Verify `orphan_rules` matches the count of orphan rules in the actual baseline
- [ ] 4. For each metadata field, record validation result: `validated` (matches source) or `mismatch` (differs from source)
- [ ] 5. If the baseline file cannot be read or parsed, record as `unverifiable` with the error

Record in reasoning:

```yaml
baseline_validation:
  path: "<baseline file path>"
  source_verified: true | false
  fields:
    - field: "size_bytes"
      evidence_value: <N>
      source_value: <N>
      result: validated | mismatch
    - field: "version"
      evidence_value: "<version>"
      source_value: "<version>"
      result: validated | mismatch
    - field: "generated_at"
      evidence_value: "<timestamp>"
      source_value: "<timestamp>"
      result: validated | mismatch
    - field: "guidelines_count"
      evidence_value: <N>
      source_value: <N>
      result: validated | mismatch
    - field: "skills_count"
      evidence_value: <N>
      source_value: <N>
      result: validated | mismatch
    - field: "total_rules"
      evidence_value: <N>
      source_value: <N>
      result: validated | mismatch
    - field: "coverage"
      evidence_value: <float>
      source_value: <float>
      result: validated | mismatch
    - field: "orphan_rules"
      evidence_value: <N>
      source_value: <N>
      result: validated | mismatch
  raw_content_match: true | false
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 4: Validate Current Guideline State

Cross-check the guideline rules in `evidence.yaml` against actual guideline files:

- [ ] 1. For each guideline file listed in `evidence.yaml` → `current_guidelines.files`:
  - [ ] 1a. Verify the file exists at the recorded path
  - [ ] 1b. Verify `size_bytes` matches actual file size
  - [ ] 1c. Verify `modified_at` matches actual file modification timestamp
  - [ ] 1d. Verify `line_count` matches actual file line count
- [ ] 2. For each rule in `evidence.yaml` → `current_guidelines.rules`:
  - [ ] 2a. Verify the source file exists and contains the rule
  - [ ] 2b. Verify `rule_id` appears in the source file
  - [ ] 2c. Verify `title` matches the rule title in the source file
  - [ ] 2d. Verify `conditions` are present in the source file
  - [ ] 2e. Verify `actions` are present in the source file
  - [ ] 2f. Verify `cross_references` point to existing files or rule IDs
- [ ] 3. Verify `total_rule_count` matches the count of rules in the `rules` list
- [ ] 4. For each validation, record result: `validated`, `mismatch`, or `unverifiable`
- [ ] 5. Spot-check: randomly select 3 guideline files not in the evidence list — verify they exist but are correctly excluded (not relevant to the diff)

Record in reasoning:

```yaml
guideline_validation:
  files:
    - path: "<relative path>"
      exists: true | false
      fields:
        - field: "size_bytes"
          evidence_value: <N>
          source_value: <N>
          result: validated | mismatch
        - field: "modified_at"
          evidence_value: "<timestamp>"
          source_value: "<timestamp>"
          result: validated | mismatch
        - field: "line_count"
          evidence_value: <N>
          source_value: <N>
          result: validated | mismatch
  rules:
    - rule_id: "<rule-id>"
      found_in_source: true | false
      fields:
        - field: "title"
          evidence_value: "<title>"
          source_value: "<title>"
          result: validated | mismatch
        - field: "conditions"
          evidence_value: ["<condition>", ...]
          source_value: ["<condition>", ...]
          result: validated | mismatch
        - field: "actions"
          evidence_value: ["<action>", ...]
          source_value: ["<action>", ...]
          result: validated | mismatch
        - field: "cross_references"
          evidence_value: ["<ref>", ...]
          source_value: ["<ref>", ...]
          result: validated | mismatch
  total_rule_count:
    evidence_value: <N>
    actual_count: <N>
    result: validated | mismatch
  spot_check:
    excluded_files_verified: ["<path>", ...]
    false_positives: <N>
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 5: Validate Current Skill State

Cross-check the skill behaviors in `evidence.yaml` against actual skill files:

- [ ] 1. For each skill file listed in `evidence.yaml` → `current_skills.files`:
  - [ ] 1a. Verify the SKILL.md file exists at the recorded path
  - [ ] 1b. Verify `size_bytes` matches actual file size
  - [ ] 1c. Verify `modified_at` matches actual file modification timestamp
  - [ ] 1d. Verify `line_count` matches actual file line count
  - [ ] 1e. Verify `task_count` matches the count of task files in the skill's `tasks/` directory
- [ ] 2. For each task listed under a skill:
  - [ ] 2a. Verify the task file exists at the recorded path
  - [ ] 2b. Verify `size_bytes` matches actual file size
  - [ ] 2c. Verify `modified_at` matches actual file modification timestamp
- [ ] 3. For each behavior in `evidence.yaml` → `current_skills.behaviors`:
  - [ ] 3a. Verify the skill and task exist
  - [ ] 3b. Verify each `rule_id` appears in the task file
  - [ ] 3c. Verify `conditions` and `actions` match the task file content
  - [ ] 3d. Verify `cross_references` point to existing guideline files or rule IDs
- [ ] 4. Verify `total_skill_count` matches the count of skills in the `files` list
- [ ] 5. Verify `total_task_count` matches the sum of task counts across all skills
- [ ] 6. Verify `total_behavior_rule_count` matches the count of behavior rules
- [ ] 7. For each validation, record result: `validated`, `mismatch`, or `unverifiable`

Record in reasoning:

```yaml
skill_validation:
  files:
    - skill: "<skill name>"
      path: "<relative path>"
      exists: true | false
      fields:
        - field: "size_bytes"
          evidence_value: <N>
          source_value: <N>
          result: validated | mismatch
        - field: "modified_at"
          evidence_value: "<timestamp>"
          source_value: "<timestamp>"
          result: validated | mismatch
        - field: "line_count"
          evidence_value: <N>
          source_value: <N>
          result: validated | mismatch
        - field: "task_count"
          evidence_value: <N>
          source_value: <N>
          result: validated | mismatch
      tasks:
        - name: "<task name>"
          path: "<relative path>"
          exists: true | false
          fields:
            - field: "size_bytes"
              evidence_value: <N>
              source_value: <N>
              result: validated | mismatch
            - field: "modified_at"
              evidence_value: "<timestamp>"
              source_value: "<timestamp>"
              result: validated | mismatch
  behaviors:
    - skill: "<skill name>"
      task: "<task name>"
      found_in_source: true | false
      rules:
        - rule_id: "<rule-id>"
          found_in_source: true | false
          fields:
            - field: "conditions"
              evidence_value: ["<condition>", ...]
              source_value: ["<condition>", ...]
              result: validated | mismatch
            - field: "actions"
              evidence_value: ["<action>", ...]
              source_value: ["<action>", ...]
              result: validated | mismatch
      cross_references:
        - reference: "<ref>"
          target_exists: true | false
          result: validated | mismatch
  total_skill_count:
    evidence_value: <N>
    actual_count: <N>
    result: validated | mismatch
  total_task_count:
    evidence_value: <N>
    actual_count: <N>
    result: validated | mismatch
  total_behavior_rule_count:
    evidence_value: <N>
    actual_count: <N>
    result: validated | mismatch
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 6: Validate Raw Diff Data

Cross-check the raw diff data in `evidence.yaml` against actual file contents:

- [ ] 1. **Rules added** — For each rule in `raw_diff.rules_added`:
  - [ ] 1a. Verify the source file exists
  - [ ] 1b. Verify the rule actually exists in the source file
  - [ ] 1c. Verify the rule does NOT exist in the baseline
- [ ] 2. **Rules removed** — For each rule in `raw_diff.rules_removed`:
  - [ ] 2a. Verify the rule exists in the baseline
  - [ ] 2b. Verify the rule does NOT exist in the current source file
- [ ] 3. **Rules modified** — For each rule in `raw_diff.rules_modified`:
  - [ ] 3a. Verify the baseline version matches the baseline file
  - [ ] 3b. Verify the current version matches the current source file
  - [ ] 3c. Verify the baseline and current versions actually differ
- [ ] 4. **Behaviors added** — For each behavior in `raw_diff.behaviors_added`:
  - [ ] 4a. Verify the skill and task files exist
  - [ ] 4b. Verify the behavior rules exist in the task file
  - [ ] 4c. Verify the behavior does NOT exist in the baseline
- [ ] 5. **Behaviors removed** — For each behavior in `raw_diff.behaviors_removed`:
  - [ ] 5a. Verify the behavior exists in the baseline
  - [ ] 5b. Verify the behavior does NOT exist in the current task file
- [ ] 6. **Behaviors modified** — For each behavior in `raw_diff.behaviors_modified`:
  - [ ] 6a. Verify the baseline version matches the baseline file
  - [ ] 6b. Verify the current version matches the current task file
  - [ ] 6c. Verify the baseline and current versions actually differ
- [ ] 7. **Cross-references changed** — For each entry in `raw_diff.cross_refs_changed`:
  - [ ] 7a. Verify the baseline referenced_by list matches the baseline file
  - [ ] 7b. Verify the current referenced_by list matches current source files
- [ ] 8. **Cross-references added** — For each entry in `raw_diff.cross_refs_added`:
  - [ ] 8a. Verify the reference target exists
  - [ ] 8b. Verify the referenced_by list matches current source files
- [ ] 9. **Cross-references removed** — For each entry in `raw_diff.cross_refs_removed`:
  - [ ] 9a. Verify the reference target exists (or confirm it was removed)
  - [ ] 9b. Verify the was_referenced_by list matches the baseline file
- [ ] 10. **File changes** — For each entry in `raw_diff.file_changes`:
  - [ ] 10a. Verify `added` files exist in the current filesystem
  - [ ] 10b. Verify `removed` files do NOT exist in the current filesystem
  - [ ] 10c. Verify `modified` files exist and have different content from baseline
- [ ] 11. Verify all summary counts match the actual list lengths
- [ ] 12. For each validation, record result: `validated`, `mismatch`, or `unverifiable`

Record in reasoning:

```yaml
diff_validation:
  rules_added:
    - rule_id: "<rule-id>"
      exists_in_source: true | false
      absent_from_baseline: true | false
      result: validated | mismatch
  rules_removed:
    - rule_id: "<rule-id>"
      exists_in_baseline: true | false
      absent_from_source: true | false
      result: validated | mismatch
  rules_modified:
    - rule_id: "<rule-id>"
      baseline_matches: true | false
      current_matches: true | false
      actually_different: true | false
      result: validated | mismatch
  behaviors_added:
    - skill: "<skill name>"
      task: "<task name>"
      exists_in_source: true | false
      absent_from_baseline: true | false
      result: validated | mismatch
  behaviors_removed:
    - skill: "<skill name>"
      task: "<task name>"
      exists_in_baseline: true | false
      absent_from_source: true | false
      result: validated | mismatch
  behaviors_modified:
    - skill: "<skill name>"
      task: "<task name>"
      baseline_matches: true | false
      current_matches: true | false
      actually_different: true | false
      result: validated | mismatch
  cross_refs_changed:
    - reference: "<ref>"
      baseline_referenced_by_matches: true | false
      current_referenced_by_matches: true | false
      result: validated | mismatch
  cross_refs_added:
    - reference: "<ref>"
      target_exists: true | false
      referenced_by_matches: true | false
      result: validated | mismatch
  cross_refs_removed:
    - reference: "<ref>"
      target_status: "exists | removed"
      was_referenced_by_matches: true | false
      result: validated | mismatch
  file_changes:
    added:
      - path: "<path>"
        exists: true | false
        result: validated | mismatch
    removed:
      - path: "<path>"
        exists: false | true
        result: validated | mismatch
    modified:
      - path: "<path>"
        exists: true | false
        content_differs_from_baseline: true | false
        result: validated | mismatch
  summary_counts:
    - field: "rules_added_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "rules_removed_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "rules_modified_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "behaviors_added_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "behaviors_removed_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "behaviors_modified_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "cross_refs_changed_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "cross_refs_added_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "cross_refs_removed_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "files_added_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "files_removed_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
    - field: "files_modified_count"
      evidence_value: <N>
      actual_count: <N>
      result: validated | mismatch
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 7: Validate Coherence Metrics

Recompute coherence metrics independently and compare against Generator's values:

- [ ] 1. **Guideline coverage** — Independently compute: for each guideline rule, count how many skill behaviors reference it. Compare against `evidence.yaml` → `coherence_metrics.current.guideline_coverage`.
- [ ] 2. **Orphan rules** — Independently identify guideline rules with zero skill references. Compare list and count against `evidence.yaml` → `coherence_metrics.current.orphan_rules` and `orphan_rule_count`.
- [ ] 3. **Skill-guideline alignment** — Independently compute: for each skill behavior, count how many guideline rules it references. Compare against `evidence.yaml` → `coherence_metrics.current.skill_guideline_alignment`.
- [ ] 4. **Total rules** — Independently count guideline rules and skill behavior rules. Compare against `evidence.yaml` → `coherence_metrics.current.total_rules`.
- [ ] 5. **Guideline rule count** — Independently count. Compare against `evidence.yaml` → `coherence_metrics.current.guideline_rule_count`.
- [ ] 6. **Skill behavior rule count** — Independently count. Compare against `evidence.yaml` → `coherence_metrics.current.skill_behavior_rule_count`.
- [ ] 7. **Baseline metrics** — Cross-check baseline metrics against the actual baseline file.
- [ ] 8. **Delta values** — Recompute deltas from validated current and baseline values. Compare against `evidence.yaml` → `coherence_metrics.delta`.
- [ ] 9. For each metric, record validation result: `validated` (within 0.01 tolerance for floats, exact match for integers) or `mismatch`.

Record in reasoning:

```yaml
metrics_validation:
  current:
    - metric: "guideline_coverage"
      evidence_value: <float>
      recomputed_value: <float>
      result: validated | mismatch
    - metric: "orphan_rule_count"
      evidence_value: <N>
      recomputed_value: <N>
      result: validated | mismatch
    - metric: "orphan_rules"
      evidence_value: ["<rule-id>", ...]
      recomputed_value: ["<rule-id>", ...]
      result: validated | mismatch
    - metric: "skill_guideline_alignment"
      evidence_value: <float>
      recomputed_value: <float>
      result: validated | mismatch
    - metric: "total_rules"
      evidence_value: <N>
      recomputed_value: <N>
      result: validated | mismatch
    - metric: "guideline_rule_count"
      evidence_value: <N>
      recomputed_value: <N>
      result: validated | mismatch
    - metric: "skill_behavior_rule_count"
      evidence_value: <N>
      recomputed_value: <N>
      result: validated | mismatch
  baseline:
    - metric: "guideline_coverage"
      evidence_value: <float>
      baseline_source_value: <float>
      result: validated | mismatch
    - metric: "orphan_rule_count"
      evidence_value: <N>
      baseline_source_value: <N>
      result: validated | mismatch
    - metric: "skill_guideline_alignment"
      evidence_value: <float>
      baseline_source_value: <float>
      result: validated | mismatch
    - metric: "total_rules"
      evidence_value: <N>
      baseline_source_value: <N>
      result: validated | mismatch
  delta:
    - metric: "guideline_coverage_delta"
      evidence_value: <float>
      recomputed_value: <float>
      result: validated | mismatch
    - metric: "orphan_rule_delta"
      evidence_value: <N>
      recomputed_value: <N>
      result: validated | mismatch
    - metric: "skill_guideline_alignment_delta"
      evidence_value: <float>
      recomputed_value: <float>
      result: validated | mismatch
    - metric: "total_rules_delta"
      evidence_value: <N>
      recomputed_value: <N>
      result: validated | mismatch
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 8: Validate Migration Candidate Evidence

Cross-check migration candidate evidence against actual skill task files:

- [ ] 1. For each candidate in `evidence.yaml` → `migration_candidate_evidence.candidates`:
  - [ ] 1a. Verify the skill SKILL.md file exists
  - [ ] 1b. Verify the task file exists
  - [ ] 1c. Read the task file and verify it contains procedural workflow patterns (step-by-step instructions, checklist items, sequential procedures)
  - [ ] 1d. Verify `step_count` matches the actual count of procedural steps in the task file
  - [ ] 1e. Verify `pattern` classification is consistent with the task file content
- [ ] 2. Verify `total_candidates` matches the count of candidates in the list
- [ ] 3. Spot-check: randomly select 2 skill task files not in the candidates list — verify they do NOT contain procedural workflow patterns (confirm correct exclusion)
- [ ] 4. For each validation, record result: `validated`, `mismatch`, or `unverifiable`

Record in reasoning:

```yaml
migration_candidate_validation:
  candidates:
    - skill: "<skill name>"
      task: "<task name>"
      task_file_exists: true | false
      contains_procedural_pattern: true | false
      fields:
        - field: "step_count"
          evidence_value: <N>
          source_value: <N>
          result: validated | mismatch
        - field: "pattern"
          evidence_value: "<pattern>"
          source_value: "<pattern>"
          result: validated | mismatch
  total_candidates:
    evidence_value: <N>
    actual_count: <N>
    result: validated | mismatch
  spot_check:
    excluded_tasks_verified: ["<skill>/<task>", ...]
    false_positives: <N>
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 9: Validate State Analysis Evidence

Cross-check state analysis evidence against the actual state analysis file:

- [ ] 1. Check if `state_analysis_evidence.provided` is `true` in `evidence.yaml`
- [ ] 2. If `provided: true`:
  - [ ] 2a. Verify the path recorded in `evidence.yaml` → `state_analysis_evidence.path` exists
  - [ ] 2b. Verify `exists` matches actual file existence
  - [ ] 2c. If the file exists, verify `size_bytes` matches actual file size
  - [ ] 2d. If the file exists, verify `modified_at` matches actual modification timestamp
  - [ ] 2e. If the file exists, read it and verify `structure.keys` and `structure.sections` match the actual file structure
- [ ] 3. If `provided: false`:
  - [ ] 3a. Verify that no state analysis path was provided in the dispatch contract
  - [ ] 3b. Record as `validated` (correctly recorded as not provided)
- [ ] 4. For each validation, record result: `validated`, `mismatch`, or `unverifiable`

Record in reasoning:

```yaml
state_analysis_validation:
  provided: true | false
  path: "<path or absent>"
  fields:
    - field: "exists"
      evidence_value: true | false
      source_value: true | false
      result: validated | mismatch
    - field: "size_bytes"
      evidence_value: <N or absent>
      source_value: <N or absent>
      result: validated | mismatch | not_applicable
    - field: "modified_at"
      evidence_value: "<timestamp or absent>"
      source_value: "<timestamp or absent>"
      result: validated | mismatch | not_applicable
    - field: "structure.keys"
      evidence_value: ["<key>", ...]
      source_value: ["<key>", ...]
      result: validated | mismatch | not_applicable
    - field: "structure.sections"
      evidence_value: ["<section>", ...]
      source_value: ["<section>", ...]
      result: validated | mismatch | not_applicable
  validation_summary: "<N> validated, <M> mismatches, <K> unverifiable"
```

### Step 10: Write reasoning.yaml

Write all validation results to `{artifact_evidence_dir}/reasoning.yaml`:

```yaml
knowledge_supporter: coherence-maintenance-knowledge-supporter
issue_number: <N>
generated_at: "<timestamp>"
artifact_evidence_dir: "<path>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
evidence_generated_at: "<timestamp from evidence.yaml>"
baseline_validation: {...}
guideline_validation: {...}
skill_validation: {...}
diff_validation: {...}
metrics_validation: {...}
migration_candidate_validation: {...}
state_analysis_validation: {...}
overall_validation:
  total_items_validated: <N>
  total_validated: <N>
  total_mismatches: <M>
  total_unverifiable: <K>
  validation_rate: <float 0.0-1.0>
```

### Step 11: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: <N> total items checked, <V> validated, <M> mismatches, <U> unverifiable. Validation rate: <R>. No judgments applied."
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load evidence.yaml → INVALID if skipped
- [ ] 3. Validate Baseline Data → INVALID if skipped
- [ ] 4. Validate Current Guideline State → INVALID if skipped
- [ ] 5. Validate Current Skill State → INVALID if skipped
- [ ] 6. Validate Raw Diff Data → INVALID if skipped
- [ ] 7. Validate Coherence Metrics → INVALID if skipped
- [ ] 8. Validate Migration Candidate Evidence → INVALID if skipped
- [ ] 9. Validate State Analysis Evidence → INVALID if skipped
- [ ] 10. Write reasoning.yaml → INVALID if skipped
- [ ] 11. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml not found | Return BLOCKED — run `coherence-maintenance-generator` first |
| evidence.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_EVIDENCE` and missing key name |
| Baseline file not found at recorded path | Record as `unverifiable` for baseline section — do NOT BLOCK |
| Guideline file not found at recorded path | Record as `mismatch` for that file — do NOT BLOCK |
| Skill file not found at recorded path | Record as `mismatch` for that file — do NOT BLOCK |
| Task file not found at recorded path | Record as `mismatch` for that task — do NOT BLOCK |
| Source file unreadable (permission) | Record as `unverifiable` with PERMISSION_DENIED — do NOT BLOCK |
| Baseline JSON parse failure | Record as `unverifiable` for baseline section — do NOT BLOCK |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| State analysis file not found (when provided: true) | Record as `mismatch` for state_analysis_evidence — do NOT BLOCK |
| Cross-reference target not found | Record as `mismatch` for that cross-reference — do NOT BLOCK |

## Cross-References

- `tasks/coherence-maintenance-generator.md` — Generator role (produces the evidence.yaml consumed by this task)
- `tasks/coherence-maintenance.md` — Evaluator role (consumes this Knowledge Supporter's reasoning.yaml)
- `tasks/cross-validate.md` — Path Provider role (consumes all upstream artifacts)
- `tasks/coherence-extraction.md` — baseline generation (prerequisite for the Generator)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — coherence maintenance requirement
