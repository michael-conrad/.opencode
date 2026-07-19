---
name: coherence-maintenance-generator
description: "Investigator role for the coherence-maintenance DiMo chain. Reads the codebase and collects raw evidence about codebase coherence after changes. Writes evidence.yaml with baseline data, current state, and raw diff data. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: coherence-maintenance-generator

## Purpose

Investigator role for the coherence-maintenance DiMo chain. Reads the baseline coherence state and the current codebase (guidelines and skills), then produces `evidence.yaml` with raw evidence about what exists in both states. This role collects evidence only — it does NOT evaluate, judge, classify drift, or produce PASS/FAIL verdicts.

> **DiMo Role: Investigator.** This task generates raw evidence for coherence-maintenance. Writes `evidence.yaml` with baseline data, current state data, and raw diff data.
>
> You are the Investigator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You just collect.
>
>
> - MUST extract all evidence without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST NOT classify drift as controlled or uncontrolled
> - MUST write `evidence.yaml` as the only output artifact

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- Baseline file exists at `{project_root}/tmp/{issue-N}/artifacts/baseline-*.json`
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for evidence artifacts)
- `.opencode/guidelines/` directory exists and is readable
- `.opencode/skills/` directory exists and is readable
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- `evidence.yaml` written to `{artifact_evidence_dir}/evidence.yaml`
- Baseline data loaded and recorded
- Current guideline rules extracted and recorded
- Current skill behaviors extracted and recorded
- Raw diff data collected (rules added/removed/modified, behaviors added/removed/modified, cross-refs changed)
- No PASS/FAIL judgments in the output — raw evidence only
- No drift classification (controlled vs uncontrolled) — that is the Evaluator's job

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify baseline file exists — glob `baseline-*.json` in `{project_root}/tmp/{issue-N}/artifacts/`
- [ ] 2. If no baseline found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "baseline file"
remediation: "No baseline-*.json found in {project_root}/tmp/{issue-N}/artifacts/. Run coherence-extraction first to generate a baseline."
```

- [ ] 3. Verify `.opencode/guidelines/` exists and contains `.md` files
- [ ] 4. Verify `.opencode/skills/` exists and contains `SKILL.md` files
- [ ] 5. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Baseline

Find and load the latest baseline coherence file:

- [ ] 1. Glob `baseline-*.json` in `{project_root}/tmp/{issue-N}/artifacts/`
- [ ] 2. Select the latest baseline by filename date
- [ ] 3. Read and parse the baseline JSON
- [ ] 4. Record baseline metadata: version, generated_at, file path, file size

Record in evidence:

```yaml
baseline:
  path: "<absolute path to baseline file>"
  size_bytes: <N>
  version: "<baseline_version>"
  generated_at: "<ISO timestamp>"
  guidelines_count: <N>
  skills_count: <N>
  total_rules: <N>
  coverage: "<percentage>"
  orphan_rules: <N>
  raw: <full baseline JSON content>
```

### Step 3: Extract Current Guideline State

Scan `.opencode/guidelines/*.md` and extract all rules without evaluating:

- [ ] 1. Glob `**/*.md` in `.opencode/guidelines/`
- [ ] 2. For each guideline file, read the full content
- [ ] 3. Record file metadata: path, size, modification timestamp
- [ ] 4. Extract all rule definitions (rule IDs, titles, conditions, actions, sources)
- [ ] 5. Extract all cross-references to skills (mentions of skill names, task files)
- [ ] 6. Record the raw extracted data — do NOT filter or classify

Record in evidence:

```yaml
current_guidelines:
  files:
    - path: "<relative path>"
      size_bytes: <N>
      modified_at: "<timestamp>"
      line_count: <N>
  rules:
    - rule_id: "<rule-id>"
      title: "<title>"
      file: "<source file>"
      conditions: ["<condition>", ...]
      actions: ["<action>", ...]
      source: "<source reference>"
      cross_references: ["<skill or task reference>", ...]
  total_rule_count: <N>
```

### Step 4: Extract Current Skill State

Scan `.opencode/skills/*/SKILL.md` and all task files without evaluating:

- [ ] 1. Glob `**/SKILL.md` in `.opencode/skills/`
- [ ] 2. For each SKILL.md, read the full content
- [ ] 3. Record skill metadata: name, path, size, modification timestamp
- [ ] 4. Extract all task definitions from each skill's `tasks/` directory
- [ ] 5. For each task file, record: path, size, modification timestamp, task name
- [ ] 6. Extract all rule definitions from skill files
- [ ] 7. Extract all cross-references to guidelines (mentions of guideline files, rule IDs)
- [ ] 8. Record the raw extracted data — do NOT filter or classify

Record in evidence:

```yaml
current_skills:
  files:
    - skill: "<skill name>"
      path: "<relative path to SKILL.md>"
      size_bytes: <N>
      modified_at: "<timestamp>"
      line_count: <N>
      task_count: <N>
      tasks:
        - name: "<task name>"
          path: "<relative path to task file>"
          size_bytes: <N>
          modified_at: "<timestamp>"
  behaviors:
    - skill: "<skill name>"
      task: "<task name>"
      rules:
        - rule_id: "<skill>-<number>"
          title: "<title>"
          conditions: ["<condition>", ...]
          actions: ["<action>", ...]
      cross_references: ["<guideline file or rule ID>", ...]
  total_skill_count: <N>
  total_task_count: <N>
  total_behavior_rule_count: <N>
```

### Step 5: Collect Raw Diff Data

Compare baseline against current state and record raw differences without classifying:

- [ ] 1. **Rules added** — For each current guideline rule, check if it exists in the baseline. If not, record it as added.
- [ ] 2. **Rules removed** — For each baseline guideline rule, check if it exists in the current state. If not, record it as removed.
- [ ] 3. **Rules modified** — For each rule present in both baseline and current, compare conditions and actions. If different, record both versions.
- [ ] 4. **Behaviors added** — For each current skill behavior, check if it exists in the baseline. If not, record it as added.
- [ ] 5. **Behaviors removed** — For each baseline skill behavior, check if it exists in the current state. If not, record it as removed.
- [ ] 6. **Behaviors modified** — For each behavior present in both, compare rules and cross-references. If different, record both versions.
- [ ] 7. **Cross-references changed** — For each cross-reference in baseline, check if it still exists in current. Record any that changed or disappeared.
- [ ] 8. **New cross-references** — For each cross-reference in current that was not in baseline, record it.
- [ ] 9. **File-level changes** — Record any guideline or skill files that were added, removed, or modified since baseline.

Record in evidence:

```yaml
raw_diff:
  rules_added:
    - rule_id: "<rule-id>"
      title: "<title>"
      file: "<source file>"
      conditions: ["<condition>", ...]
      actions: ["<action>", ...]
  rules_removed:
    - rule_id: "<rule-id>"
      title: "<title>"
      file: "<source file>"
      conditions: ["<condition>", ...]
      actions: ["<action>", ...]
  rules_modified:
    - rule_id: "<rule-id>"
      title: "<title>"
      file: "<source file>"
      baseline:
        conditions: ["<condition>", ...]
        actions: ["<action>", ...]
      current:
        conditions: ["<condition>", ...]
        actions: ["<action>", ...]
  behaviors_added:
    - skill: "<skill name>"
      task: "<task name>"
      rules: ["<rule-id>", ...]
  behaviors_removed:
    - skill: "<skill name>"
      task: "<task name>"
      rules: ["<rule-id>", ...]
  behaviors_modified:
    - skill: "<skill name>"
      task: "<task name>"
      baseline:
        rules: ["<rule-id>", ...]
        cross_references: ["<ref>", ...]
      current:
        rules: ["<rule-id>", ...]
        cross_references: ["<ref>", ...]
  cross_refs_changed:
    - reference: "<guideline file or rule ID>"
      baseline_referenced_by: ["<skill>", ...]
      current_referenced_by: ["<skill>", ...]
  cross_refs_added:
    - reference: "<guideline file or rule ID>"
      referenced_by: ["<skill>", ...]
  cross_refs_removed:
    - reference: "<guideline file or rule ID>"
      was_referenced_by: ["<skill>", ...]
  file_changes:
    added: ["<path>", ...]
    removed: ["<path>", ...]
    modified: ["<path>", ...]
  summary:
    rules_added_count: <N>
    rules_removed_count: <N>
    rules_modified_count: <N>
    behaviors_added_count: <N>
    behaviors_removed_count: <N>
    behaviors_modified_count: <N>
    cross_refs_changed_count: <N>
    cross_refs_added_count: <N>
    cross_refs_removed_count: <N>
    files_added_count: <N>
    files_removed_count: <N>
    files_modified_count: <N>
```

### Step 6: Collect Coherence Metric Evidence

Compute raw coherence metrics from current state without evaluating:

- [ ] 1. **Guideline coverage** — For each guideline rule, count how many skill behaviors reference it
- [ ] 2. **Orphan rules** — List guideline rules with zero skill references
- [ ] 3. **Skill-guideline alignment** — For each skill behavior, count how many guideline rules it references
- [ ] 4. **Total rule count** — Sum of guideline rules and skill behavior rules
- [ ] 5. **Baseline vs current metric comparison** — Record baseline metrics alongside current metrics

Record in evidence:

```yaml
coherence_metrics:
  current:
    guideline_coverage: <float 0.0-1.0>
    orphan_rule_count: <N>
    orphan_rules: ["<rule-id>", ...]
    skill_guideline_alignment: <float 0.0-1.0>
    total_rules: <N>
    guideline_rule_count: <N>
    skill_behavior_rule_count: <N>
  baseline:
    guideline_coverage: <float 0.0-1.0>
    orphan_rule_count: <N>
    skill_guideline_alignment: <float 0.0-1.0>
    total_rules: <N>
  delta:
    guideline_coverage_delta: <float>
    orphan_rule_delta: <N>
    skill_guideline_alignment_delta: <float>
    total_rules_delta: <N>
```

### Step 7: Collect Migration Candidate Evidence

Identify procedural workflows that may be candidates for extraction without evaluating suitability:

- [ ] 1. For each skill behavior, check if it contains procedural workflow patterns (step-by-step instructions, checklist items, sequential procedures)
- [ ] 2. Record the skill name, task name, and the procedural pattern found
- [ ] 3. Do NOT judge whether migration is appropriate — only record what exists

Record in evidence:

```yaml
migration_candidate_evidence:
  candidates:
    - skill: "<skill name>"
      task: "<task name>"
      pattern: "procedural_workflow | checklist | sequential_steps"
      step_count: <N>
      description: "<brief description of the procedural pattern found>"
  total_candidates: <N>
```

### Step 8: Collect State Analysis Evidence

If a state analysis artifact path is provided in the dispatch contract, collect evidence about its presence and content:

- [ ] 1. Check if `state_analysis_path` is provided in the dispatch contract
- [ ] 2. If provided, check if the path exists and is non-empty
- [ ] 3. Record file existence, size, and modification timestamp
- [ ] 4. If the file exists, read and record its structure (keys, sections) without evaluating content
- [ ] 5. If the field is absent from the dispatch contract, record as `not_provided`

Record in evidence:

```yaml
state_analysis_evidence:
  provided: true | false
  path: "<path or absent>"
  exists: true | false
  size_bytes: <N or absent>
  modified_at: "<timestamp or absent>"
  structure:
    keys: ["<key>", ...]
    sections: ["<section>", ...]
```

### Step 9: Write evidence.yaml

Write all collected evidence to `{artifact_evidence_dir}/evidence.yaml`:

```yaml
generator: coherence-maintenance-generator
issue_number: <N>
generated_at: "<timestamp>"
artifact_evidence_dir: "<path>"
baseline: {...}
current_guidelines: {...}
current_skills: {...}
raw_diff: {...}
coherence_metrics: {...}
migration_candidate_evidence: {...}
state_analysis_evidence: {...}
```

### Step 10: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: baseline loaded, <N> guideline rules, <M> skill behaviors, <K> raw diffs, <L> migration candidates. No judgments applied."
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Baseline → INVALID if skipped
- [ ] 3. Extract Current Guideline State → INVALID if skipped
- [ ] 4. Extract Current Skill State → INVALID if skipped
- [ ] 5. Collect Raw Diff Data → INVALID if skipped
- [ ] 6. Collect Coherence Metric Evidence → INVALID if skipped
- [ ] 7. Collect Migration Candidate Evidence → INVALID if skipped
- [ ] 8. Collect State Analysis Evidence → INVALID if skipped
- [ ] 9. Write evidence.yaml → INVALID if skipped
- [ ] 10. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| Baseline not found | Return BLOCKED — run `coherence-extraction` first |
| No guidelines found | Return BLOCKED — baseline requires guidelines |
| No skills found | Return BLOCKED — baseline requires skills |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Malformed rule in guideline file | Record as `parse_error` with file path — do NOT BLOCK |
| Malformed rule in skill file | Record as `parse_error` with file path — do NOT BLOCK |
| State analysis path missing from dispatch | Record as `provided: false` — do NOT BLOCK |
| Baseline JSON parse failure | Return BLOCKED with PARSE_ERROR and file path |

## Cross-References

- `tasks/coherence-maintenance.md` — Evaluator role (consumes this Investigator's evidence.yaml)
- `tasks/coherence-extraction.md` — baseline generation (prerequisite for this task)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — coherence maintenance requirement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
