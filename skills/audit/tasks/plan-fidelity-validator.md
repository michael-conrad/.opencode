---
name: plan-fidelity-knowledge-supporter
description: "Validator role for the plan-fidelity DiMo chain. Reads evidence.yaml from the Investigator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: plan-fidelity-knowledge-supporter

## Purpose

Validate evidence collected by the Investigator for plan-fidelity audit. Reads `evidence.yaml`, cross-checks each evidence item against source data (spec files, plan files, live tool calls), and writes `reasoning.yaml` with validated evidence and source references. This is the Validator role in the DiMo 4-role chain — it validates and supports, it does NOT evaluate or judge.

> **DiMo Role: Validator.** This task validates evidence for plan-fidelity audit. Reads `evidence.yaml` (Investigator output), validates each item against source data, and writes `reasoning.yaml` with validated evidence.
>
> You are the Validator. Your job is to validate evidence — nothing more, nothing less. You are thorough, skeptical, and completely non-judgmental. Every piece of evidence the Investigator collected gets checked against its source. You do not decide what passes or fails. You do not decide what matters. You do not produce verdicts. You validate and support.
>
> - MUST validate every evidence item against its source data — no skipping, no sampling
> - MUST record source references for every validated item
> - MUST flag unverifiable items with `unverifiable: true` and a reason
> - MUST NOT produce any PASS/FAIL judgment — that is the Evaluator's role
> - MUST NOT evaluate whether evidence is "sufficient" — that is the Evaluator's role
> - MUST write `reasoning.yaml` as the only output artifact

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts — contains `evidence.yaml` from Investigator
- `github.owner`, `github.repo` available

## Entry Criteria

- `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml` — produced by the Investigator role
- `spec_local_dir` is present and non-empty — contains at minimum `spec.md`
- Plan files exist in `spec_local_dir/` — either `plan.md` + `plan-*.md` phase files, or plan embedded in spec body
- Write access to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/`
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- Every evidence item in `evidence.yaml` validated against source data
- Unverifiable items flagged with `unverifiable: true` and a reason
- Source references recorded for every validated item
- `reasoning.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml`
- No PASS/FAIL judgments in output — validated evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove `reasoning.yaml` if it exists from a prior run: `rm -f {project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml`
- [ ] 2. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 3. If `evidence.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for plan-fidelity-knowledge-supporter. The Investigator role must produce evidence.yaml before the Validator can validate it."
```

- [ ] 4. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for plan-fidelity-knowledge-supporter. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Read evidence.yaml

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml`
- [ ] 2. Parse all top-level sections: `spec`, `plan`, `structural_alignment`, `content_evidence`, `blast_radius`, `cross_reference_evidence`
- [ ] 3. Build an inventory of all evidence items — each item is a discrete claim that must be validated

### Step 3: Validate Spec Evidence

Validate each item in the `spec` section against the actual spec files:

- [ ] 1. **SC table** — for each SC in `spec.sc_table`, verify the SC exists in `spec_local_dir/spec.md` with matching ID, description, and evidence type
- [ ] 2. **Files affected** — for each file in `spec.files_affected`, verify the file path is listed in the spec's Files Affected table
- [ ] 3. **Phases** — for each phase in `spec.phases`, verify the phase name and description match the spec body
- [ ] 4. **Cross-references** — for each issue reference in `spec.cross_references.issue_refs`, verify the reference appears in the spec body
- [ ] 5. **Delegation refs** — for each delegation reference in `spec.delegation_refs`, verify the directive and target appear in the spec body
- [ ] 6. **Scope** — verify `spec.scope.in_scope` and `spec.scope.out_of_scope` match the spec body

For each item, record:

```yaml
- item: "spec.sc_table.SC-1"
  source: "<spec_local_dir>/spec.md"
  validated: true | false
  unverifiable: false
  unverifiable_reason: ""
  discrepancy: ""  # non-empty if validated=false — what the source actually says
```

### Step 4: Validate Plan Evidence

Validate each item in the `plan` section against the actual plan files:

- [ ] 1. **Phase table** — for each phase in `plan.phase_table`, verify the phase name, dispatch mode, and description match the plan files
- [ ] 2. **Steps** — for each step in `plan.steps`, verify the global number, phase, description, dispatch indicator, sub-bullets, and SC references match the plan files
- [ ] 3. **TDD checkpoints** — verify `plan.tdd_checkpoints` matches the RED/GREEN/REFACTOR structure in the plan
- [ ] 4. **Admonishments** — verify `plan.admonishments.prologue_present`, `epilogue_present`, and `canonical_text_match` by reading the plan files
- [ ] 5. **Plan scope** — for each file in `plan.plan_scope.files_referenced`, verify the file path appears in plan steps
- [ ] 6. **Cross-references** — for each issue reference in `plan.cross_references.issue_refs`, verify the reference appears in the plan body
- [ ] 7. **Delegation definitions** — for each definition in `plan.delegation_definitions`, verify the directive and concrete definition appear in the plan
- [ ] 8. **Gate sequence** — verify `plan.gate_sequence` matches the pipeline gates referenced in plan steps
- [ ] 9. **Verification instructions** — for each instruction in `plan.verification_instructions`, verify the step number, SC ID, and required evidence type match the plan
- [ ] 10. **Z3 contract refs** — for each ref in `plan.z3_contract_refs`, verify the contract path is referenced in the plan
- [ ] 11. **Prescriptive content** — for each item in `plan.prescriptive_content`, verify the step number, type, and content match the plan

For each item, record:

```yaml
- item: "plan.phase_table.Phase-1"
  source: "<spec_local_dir>/plan.md"
  validated: true | false
  unverifiable: false
  unverifiable_reason: ""
  discrepancy: ""
```

### Step 5: Validate Structural Alignment Evidence

Validate each item in the `structural_alignment` section by cross-referencing spec and plan:

- [ ] 1. **Phase coverage** — for each entry in `structural_alignment.phase_coverage`, verify the spec phase exists in the spec and the plan phases exist in the plan
- [ ] 2. **Phase ordering** — verify `structural_alignment.phase_ordering.spec_order` matches the spec and `plan_order` matches the plan
- [ ] 3. **SC coverage** — for each entry in `structural_alignment.sc_coverage`, verify the SC ID exists in the spec and the plan steps exist in the plan
- [ ] 4. **File coverage** — for each entry in `structural_alignment.file_coverage`, verify the spec file exists in the spec's Files Affected and the plan steps exist in the plan
- [ ] 5. **Extra files** — for each file in `structural_alignment.extra_files`, verify it is referenced in plan steps but NOT in the spec's Files Affected
- [ ] 6. **Step numbering** — verify `structural_alignment.step_numbering` matches the actual numbering scheme in the plan
- [ ] 7. **Dispatch mode consistency** — for each entry in `structural_alignment.dispatch_mode_consistency`, verify the declared dispatch matches the phase table and step indicators match the plan steps
- [ ] 8. **Checklist format** — verify `structural_alignment.checklist_format` by spot-checking plan steps for `- [ ] N.` format
- [ ] 9. **One-step protocol** — verify `structural_alignment.one_step_protocol_present` by reading the plan prologue
- [ ] 10. **Sub-step expansion** — for each step in `structural_alignment.sub_step_expansion.multi_action_steps`, verify the step describes more than one atomic action

For each item, record:

```yaml
- item: "structural_alignment.phase_coverage[0]"
  source: "<spec_local_dir>/spec.md + <spec_local_dir>/plan.md"
  validated: true | false
  unverifiable: false
  unverifiable_reason: ""
  discrepancy: ""
```

### Step 6: Validate Content Evidence

Validate each item in the `content_evidence` section:

- [ ] 1. **Approach** — verify `content_evidence.approach.spec_approach` matches the spec body and `plan_approach` matches the plan body
- [ ] 2. **Edge cases** — for each entry in `content_evidence.edge_cases`, verify the description and spec source exist in the spec, and the plan steps exist in the plan
- [ ] 3. **Error recovery** — for each entry in `content_evidence.error_recovery`, verify the description and spec source exist in the spec, and the plan steps exist in the plan
- [ ] 4. **Root cause** — verify `content_evidence.root_cause.spec_description` matches the spec and `plan_phase_addressing` matches a plan phase
- [ ] 5. **Delegation completeness** — for each entry in `content_evidence.delegation_completeness`, verify the directive exists in the spec and the `has_concrete_definition` value matches the plan
- [ ] 6. **Gate sequence** — verify `content_evidence.gate_sequence` matches the pipeline gates referenced in plan steps
- [ ] 7. **Verification evidence types** — for each entry in `content_evidence.verification_evidence_types`, verify the SC ID exists in the spec, the `spec_declared_type` matches the spec's SC table, and the `plan_required_type` matches the plan's verification instructions
- [ ] 8. **Cost-frame prose** — for each entry in `content_evidence.cost_frame_prose`, verify the `present` value by reading the phase's instructions in the plan
- [ ] 9. **SC gate language** — verify `content_evidence.sc_gate_language.present` by reading the plan for all-or-nothing gate references

For each item, record:

```yaml
- item: "content_evidence.approach"
  source: "<spec_local_dir>/spec.md + <spec_local_dir>/plan.md"
  validated: true | false
  unverifiable: false
  unverifiable_reason: ""
  discrepancy: ""
```

### Step 7: Validate Blast Radius Evidence

Validate each item in the `blast_radius` section:

- [ ] 1. For each entry in `blast_radius`, verify the file exists in the plan's scope
- [ ] 2. For each dependent symbol, verify it is a real symbol via `srclight_get_dependents` on the file
- [ ] 3. Verify `addressed_in_plan` by checking whether the dependent symbol appears in plan steps

If `srclight_get_dependents` is unavailable, mark blast radius items as `unverifiable: true` with reason `TOOL_UNAVAILABLE`.

For each item, record:

```yaml
- item: "blast_radius[0]"
  source: "srclight_get_dependents on <file>"
  validated: true | false
  unverifiable: false
  unverifiable_reason: ""
  discrepancy: ""
```

### Step 8: Validate Cross-Reference Evidence

Validate each item in the `cross_reference_evidence` section:

- [ ] 1. **Issue refs** — for each entry in `cross_reference_evidence.issue_refs`, verify `exists` by calling `github_issue_read(method=get, issue_number=N)` and verify `relevant` by reading the issue body
- [ ] 2. **File refs** — for each entry in `cross_reference_evidence.file_refs`, verify `exists` by calling `glob` on the file path

If `github_issue_read` is unavailable, mark issue refs as `unverifiable: true` with reason `TOOL_UNAVAILABLE`.

For each item, record:

```yaml
- item: "cross_reference_evidence.issue_refs[0]"
  source: "github_issue_read on #N"
  validated: true | false
  unverifiable: false
  unverifiable_reason: ""
  discrepancy: ""
```

### Step 9: Write reasoning.yaml

Write all validated evidence to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml`:

```yaml
generated_at: "<ISO timestamp>"
supporter_model: "<model>"
evidence_source: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml"
total_items: <N>
validated_count: <N>
unverifiable_count: <N>
discrepancy_count: <N>
spec_validation:
  - item: "spec.sc_table.SC-1"
    source: "<spec_local_dir>/spec.md"
    validated: true | false
    unverifiable: false
    unverifiable_reason: ""
    discrepancy: ""
plan_validation:
  - item: "plan.phase_table.Phase-1"
    source: "<spec_local_dir>/plan.md"
    validated: true | false
    unverifiable: false
    unverifiable_reason: ""
    discrepancy: ""
structural_alignment_validation:
  - item: "structural_alignment.phase_coverage[0]"
    source: "<spec_local_dir>/spec.md + <spec_local_dir>/plan.md"
    validated: true | false
    unverifiable: false
    unverifiable_reason: ""
    discrepancy: ""
content_evidence_validation:
  - item: "content_evidence.approach"
    source: "<spec_local_dir>/spec.md + <spec_local_dir>/plan.md"
    validated: true | false
    unverifiable: false
    unverifiable_reason: ""
    discrepancy: ""
blast_radius_validation:
  - item: "blast_radius[0]"
    source: "srclight_get_dependents on <file>"
    validated: true | false
    unverifiable: false
    unverifiable_reason: ""
    discrepancy: ""
cross_reference_validation:
  - item: "cross_reference_evidence.issue_refs[0]"
    source: "github_issue_read on #N"
    validated: true | false
    unverifiable: false
    unverifiable_reason: ""
    discrepancy: ""
```

### Step 10: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml"
summary: "Evidence validated: {validated_count}/{total_items} items confirmed. {unverifiable_count} unverifiable, {discrepancy_count} discrepancies found."
```

## Error Handling

| Error | Action |
|-------|--------|
| `evidence.yaml` missing | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| `spec_local_dir` missing or empty | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| No plan files found in `spec_local_dir/` | Return BLOCKED — `MISSING_PLAN` |
| `srclight_get_dependents` unavailable | Mark blast radius items as `unverifiable: true`, continue |
| `github_issue_read` unavailable | Mark cross-reference items as `unverifiable: true`, continue |
| Write permission denied | Return BLOCKED — cannot write reasoning |
| Evidence item references non-existent source | Record `validated: false` with `discrepancy` describing what was found (or not found) |

## Cross-References

- `tasks/plan-fidelity-investigator.md` — Investigator role (produces `evidence.yaml` consumed by this task)
- `tasks/plan-fidelity.md` — Evaluator role (consumes this task's `reasoning.yaml`)
- `tasks/resolve-models.md` — Arbiter role reference (consumes `reasoning.yaml`)
- `audit/SKILL.md` — DiMo chain dispatch (Investigator → Validator → Evaluator → Arbiter)
- `000-critical-rules.md` — critical-rules-034 (inline work prohibition)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
