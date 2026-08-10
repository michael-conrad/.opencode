---
name: plan-fidelity-investigator
description: "Collect raw evidence about how faithfully the plan implements the spec. Reads the spec and plan files, extracts structural and content-level data, and writes `evidence.yaml` with raw evidence and initial findings. Does NOT evaluate or judge — that is the Evaluator's role."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: plan-fidelity-investigator

## Purpose

Collect raw evidence about how faithfully the plan implements the spec. Reads the spec and plan files, extracts structural and content-level data, and writes `evidence.yaml` with raw evidence and initial findings. Does NOT evaluate or judge — that is the Evaluator's role.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- `spec_local_dir` is present and non-empty — contains at minimum `spec.md`
- Plan files exist in `spec_local_dir/` — either `plan.md` + `plan-*.md` phase files, or plan embedded in spec body
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- `evidence.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml`
- Spec content fully extracted (SC table, phases, files affected, cross-references)
- Plan content fully extracted (phase table, steps, dispatch indicators, TDD checkpoints, admonishments)
- All structural data recorded — no evaluation, no judgment

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove artifact files for this task from `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for plan-fidelity-generator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Extract Spec Content

Read the spec from `spec_local_dir/`:

- [ ] 1. Read `spec_local_dir/spec.md` for the full spec body
- [ ] 2. Extract the SC table — all success criteria with IDs, descriptions, and evidence types
- [ ] 3. Extract the Files Affected table — all file paths the spec declares as in-scope
- [ ] 4. Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure.

Record all extracted spec data in the evidence structure:

```yaml
spec:
  path: "<spec_local_dir>/spec.md"
  sc_table:
    - id: "SC-1"
      description: "<text>"
      evidence_type: "<behavioral|semantic|string|structural>"
  files_affected:
    - "<path>"
  sections:
    - name: "<section name>"
      present: <true|false>
      content_summary: "<text>"
      structure_issues: ["<description>"]
```

### Step 3: Extract Plan Content

Read the plan from `spec_local_dir/`:

- [ ] 1. Read `spec_local_dir/plan.md` for the plan index (phase table, exit criteria, admonishments)
- [ ] 2. Glob `spec_local_dir/plan-*.md` for phase files (one per phase, globally sequential steps)
- [ ] 3. If no `plan.md` exists, the plan is embedded in the spec body — extract from there
- [ ] 4. Extract the phase table — phase names, dispatch modes, descriptions
- [ ] 5. Extract all steps across all phases — step numbers, descriptions, sub-bullets, SC references
- [ ] 6. Extract dispatch indicators from step titles — ``, `(**sub-agent**)`, `(**clean-room**)`
- [ ] 7. Extract TDD checkpoints — RED/GREEN/REFACTOR structure, RED and GREEN separation
- [ ] 8. Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, collect evidence about its presence, content, and format.

Record all extracted plan data in the evidence structure:

```yaml
plan:
  path: "<spec_local_dir>/plan.md"
  phase_files: ["<spec_local_dir>/plan-phase-1.md", ...]
  phase_table:
    - name: "<phase name>"
      dispatch: "<inline|sub-agent|sub-agent-clean-room>"
      description: "<text>"
  steps:
    - global_number: <N>
      phase: "<phase name>"
      description: "<text>"
      dispatch_indicator: "<inline|sub-agent|clean-room>"
      sub_bullets: ["<text>"]
      sc_references: ["SC-N"]
  tdd_checkpoints:
    red_phases: ["<phase name>"]
    green_phases: ["<phase name>"]
    red_green_separated: <true|false>
  structural_elements:
    - name: "<element name>"
      present: <true|false>
      content_summary: "<text>"
      format_issues: ["<description>"]
```

### Step 4: Collect Structural Alignment Evidence

Compare spec and plan at the structural level — record facts, not judgments:

- [ ] 1. **Phase coverage** — list spec phases and which plan phases map to them
- [ ] 2. **Phase ordering** — record the order of phases in spec vs. plan
- [ ] 3. **SC coverage** — for each SC in the spec, record which plan step(s) reference it
- [ ] 4. **File coverage** — for each file in spec's Files Affected, record which plan steps reference it
- [ ] 5. **Extra files** — record any files referenced in plan steps that are NOT in spec's Files Affected
- [ ] 6. **Step numbering** — record whether steps are globally numbered or per-phase restart
- [ ] 7. **Dispatch mode consistency** — record each phase's declared dispatch mode and each step's dispatch indicator
- [ ] 8. **Checklist format** — record whether steps use `- [ ] N.` format with sub-bullets
- [ ] 9. **Sub-step expansion** — record any steps that describe more than one atomic action

Record in evidence:

```yaml
structural_alignment:
  phase_coverage:
    - spec_phase: "<name>"
      plan_phases: ["<name>"]
  phase_ordering:
    spec_order: ["<phase names>"]
    plan_order: ["<phase names>"]
  sc_coverage:
    - sc_id: "SC-N"
      plan_steps: [<step numbers>]
      covered: <true|false>
  file_coverage:
    - spec_file: "<path>"
      plan_steps: [<step numbers>]
      covered: <true|false>
  extra_files: ["<path>"]
  step_numbering: "<global|per_phase_restart>"
  dispatch_mode_consistency:
    - phase: "<name>"
      declared_dispatch: "<inline|sub-agent|sub-agent-clean-room>"
      step_indicators: ["<inline|sub-agent|clean-room>"]
  checklist_format: "<all_steps_compliant|some_steps_noncompliant>"
  sub_step_expansion:
    multi_action_steps: [<step numbers>]
```

### Step 5: Collect Content-Level Evidence

Extract content-level data for deeper analysis by downstream roles:

- [ ] 1. **Approach description** — extract the implementation approach described in spec vs. plan
- [ ] 2. **Edge case coverage** — extract edge cases mentioned in spec and which plan steps address them
- [ ] 3. **Error recovery** — extract error recovery paths in spec and which plan steps address them
- [ ] 4. **Root cause depth** — extract root cause description from spec and which plan phase addresses it

Record in evidence:

```yaml
content_evidence:
  approach:
    spec_approach: "<text>"
    plan_approach: "<text>"
  edge_cases:
    - description: "<text>"
      spec_source: "<location>"
      plan_steps: [<step numbers>]
  error_recovery:
    - description: "<text>"
      spec_source: "<location>"
      plan_steps: [<step numbers>]
  root_cause:
    spec_description: "<text>"
    plan_phase_addressing: "<phase name or null>"

```

### Step 6: Collect Blast Radius Evidence

- [ ] 1. For each file in the plan's scope, use `srclight_get_dependents` to discover dependents
- [ ] 2. Record dependents that the plan does not address

```yaml
blast_radius:
  - file: "<path>"
    dependents: ["<symbol>"]
    addressed_in_plan: <true|false>
```

### Step 7: Collect Cross-Reference Evidence

- [ ] 1. For each issue reference (`#N`) in the plan, verify the issue exists via `github_issue_read`
- [ ] 2. For each file path reference in the plan, verify the file exists via `glob`
- [ ] 3. Record broken or unverifiable references

```yaml
cross_reference_evidence:
  issue_refs:
    - ref: "#N"
      exists: <true|false>
      relevant: <true|false|null>
  file_refs:
    - ref: "<path>"
      exists: <true|false>
```

### Step 8: Write evidence.yaml

Write all collected evidence to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml`:

```yaml
generated_at: "<ISO timestamp>"
generator_model: "<model>"
spec:
  path: "<path>"
  sc_table: [...]
  files_affected: [...]
  sections:
    - name: "<section name>"
      present: <bool>
      content_summary: "<text>"
      structure_issues: ["<description>"]
plan:
  path: "<path>"
  phase_files: [...]
  phase_table: [...]
  steps: [...]
  tdd_checkpoints: {...}
  structural_elements:
    - name: "<element name>"
      present: <bool>
      content_summary: "<text>"
      format_issues: ["<description>"]
structural_alignment:
  phase_coverage: [...]
  phase_ordering: {...}
  sc_coverage: [...]
  file_coverage: [...]
  extra_files: [...]
  step_numbering: "<value>"
  dispatch_mode_consistency: [...]
  checklist_format: "<value>"
  sub_step_expansion: {...}
content_evidence:
  approach: {...}
  edge_cases: [...]
  error_recovery: [...]
  root_cause: {...}
blast_radius: [...]
cross_reference_evidence:
  issue_refs: [...]
  file_refs: [...]
```

### Step 9: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml"
summary: "Evidence collected: {N} SCs, {M} plan steps, {K} phases. {X} structural alignments recorded, {Y} content evidence items."
```

## Error Handling

| Error | Action |
|-------|--------|
| `spec_local_dir` missing or empty | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| No plan files found in `spec_local_dir/` | Return BLOCKED — `MISSING_PLAN` |
| `srclight_get_dependents` unavailable | Skip blast radius collection, note in evidence |
| `github_issue_read` unavailable | Skip cross-reference verification, note in evidence |
| Write permission denied | Return BLOCKED — cannot write evidence |

## Cross-References

- `tasks/plan-fidelity.md` — Evaluator role (consumes this Investigator's `evidence.yaml`)
- `tasks/coherence-extraction-investigator.md` — Investigator role reference pattern
- `audit/SKILL.md` — chain dispatch
- `writing-plans` skill — clean-room plan generation
- `000-critical-rules.md` — critical-rules-034 (inline work prohibition)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
