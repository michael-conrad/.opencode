---
name: concern-separation-evaluator
description: "Evaluator role for the concern-separation chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each criterion, and writes verdict.yaml with per-criterion PASS/FAIL verdicts."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: concern-separation-evaluator

## Purpose

Evaluate concern-separation evidence against criteria and produce binary PASS/FAIL verdicts. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each criterion, and writes `verdict.yaml` with per-criterion verdicts. Produces judgments, not just evidence.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts
- `evidence_path`: Path to `evidence.yaml` produced by the Investigator
- `reasoning_path`: Path to `reasoning.yaml` produced by the upstream reasoning role

## Entry Criteria

- `evidence.yaml` present at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`
- `reasoning.yaml` present at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml`
- `spec_local_dir` present and non-empty
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- All evaluation criteria (CS-1 through CS-6, CS-ROUTING) evaluated against evidence
- Separation of concerns (SC orthogonality, cross-concern overlap) evaluated
- Scope creep (cross-concern overlap, scope boundary verification) evaluated
- Self-consistency gate applied — any PASS with hedging language downgraded to FAIL
- `verdict.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml`

## Procedure

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`
- [ ] 2. Verify `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml`
- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 4. If any criterion fails, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "<field_name>"
remediation: "<field_name> is required for concern-separation-evaluator. The orchestrator must provide a valid path."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load Upstream Artifacts

Read the Investigator's evidence and the upstream reasoning role's validated evidence:

```python
evidence = read_yaml(f"{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml")
reasoning = read_yaml(f"{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml")
```

Extract all evidence sections from `evidence.yaml`:
- `phases` — phase structure data
- `symbol_evidence` — symbol-level callers/callees/dependents
- `cross_phase_overlaps` — shared files and symbols between phases
- `blast_radius` — dependency impact chains
- `dependency_order` — declared dependency ordering
- `sc_orthogonality` — SC independence data
- `routing_evidence` — routing table references

Extract all validation sections from `reasoning.yaml`:
- `phase_validation` — validated phase structure
- `symbol_validation` — validated symbol data
- `cross_phase_validation` — validated cross-phase overlaps
- `blast_radius_validation` — validated blast radius
- `dependency_order_validation` — validated dependency order
- `sc_orthogonality_validation` — validated SC orthogonality
- `routing_validation` — validated routing evidence

### Step 3: Load Spec Files

Load spec files for direct reference during evaluation:

```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
for f in spec_files:
    read(filePath=f)
```

### Step 4: Build Evaluation Criteria

| Criterion ID | Description | Expected Result | Evidence Source |
|--------------|-------------|-----------------|-----------------|
| CS-1 | Phase names are concern-specific | No boilerplate titles (Implementation, Testing) | `phase_validation` |
| CS-2 | Single concern per phase | All steps share same concern boundary | `phase_validation`, `cross_phase_validation` |
| CS-3 | Dependency order correct | No phase depends on later phase | `dependency_order_validation` |
| CS-4 | Risk levels grouped appropriately | HIGH and LOW not mixed in same phase | `phase_validation` |
| CS-5 | Deployment independence achieved | Each phase can be deployed independently | `blast_radius_validation`, `symbol_validation` |
| CS-6 | Blast radius bounded | Phase failure impact is contained | `blast_radius_validation` |
| CS-ROUTING | Missing routing table changes when task file removed | When a spec removes or delegates a task file that has a routing/dispatch table, checks that the spec also addresses the routing table changes | `routing_validation` |

### Step 5: Evaluate CS-1 — Phase Names Are Concern-Specific

For each phase in `evidence.phases`, evaluate whether the phase name is concern-specific:

- [ ] 1. Check each `phase_name` against boilerplate patterns: `Implementation`, `Testing`, `Phase 1`, `Phase 2`, `Miscellaneous`, `Other`
- [ ] 2. If any phase name matches a boilerplate pattern, record FAIL with `BOILERPLATE_TITLE`
- [ ] 3. If all phase names are concern-specific, record PASS

```yaml
cs1_evaluation:
  result: "PASS|FAIL"
  phases_checked: <N>
  boilerplate_phases: ["<phase_name>", ...]
  explanation: "<reasoning>"
```

### Step 6: Evaluate CS-2 — Single Concern Per Phase

For each phase, evaluate whether all steps share the same concern boundary:

- [ ] 1. For each phase, extract `concern_keywords` from `evidence.phases`
- [ ] 2. If a phase has keywords from multiple concern categories (e.g., both `data` and `business_logic`), record FAIL with `CONCERN_MIXING`
- [ ] 3. Check `cross_phase_overlaps` — if two phases share files or symbols, check whether the overlap is intentional (infrastructure, testing) or indicates concern mixing
- [ ] 4. If all phases have single-concern steps, record PASS

```yaml
cs2_evaluation:
  result: "PASS|FAIL"
  phases_checked: <N>
  mixed_concern_phases:
    - phase_name: "<name>"
      concern_keywords: ["<keyword>", ...]
      conflicting_categories: ["<category>", ...]
  explanation: "<reasoning>"
```

### Step 7: Evaluate CS-3 — Dependency Order Correct

For each dependency entry in `evidence.dependency_order`, evaluate ordering:

- [ ] 1. Check `order_valid` field from `evidence.dependency_order` — if any entry has `order_valid: false`, record FAIL with `DEPENDENCY_REVERSAL`
- [ ] 2. Cross-check against `dependency_order_validation` in `reasoning.yaml` — if any validation status is `CONTRADICTED`, record FAIL
- [ ] 3. If all dependencies are correctly ordered, record PASS

```yaml
cs3_evaluation:
  result: "PASS|FAIL"
  dependencies_checked: <N>
  reversals:
    - from_phase: "<name>"
      to_phase: "<name>"
      from_index: <N>
      to_index: <N>
  explanation: "<reasoning>"
```

### Step 8: Evaluate CS-4 — Risk Levels Grouped Appropriately

For each phase, evaluate risk level grouping:

- [ ] 1. Check `declared_risk` for each phase in `evidence.phases`
- [ ] 2. If a phase has `declared_risk: not_declared`, record FAIL with `MISSING_RISK_CLASSIFICATION`
- [ ] 3. If a phase's steps include both HIGH-risk and LOW-risk operations (inferred from step descriptions), record FAIL with `HIGH_RISK_GROUPING`
- [ ] 4. If all phases have appropriate risk grouping, record PASS

```yaml
cs4_evaluation:
  result: "PASS|FAIL"
  phases_checked: <N>
  risk_issues:
    - phase_name: "<name>"
      issue: "MISSING_RISK_CLASSIFICATION|HIGH_RISK_GROUPING"
  explanation: "<reasoning>"
```

### Step 9: Evaluate CS-5 — Deployment Independence Achieved

For each phase, evaluate deployment independence:

- [ ] 1. Check `blast_radius_validation` in `reasoning.yaml` — if any phase has `cross_phase_dependents` that are not infrastructure or testing, record FAIL with `MISSING_INDEPENDENCE`
- [ ] 2. Check `symbol_validation` — if a phase's symbols have callers in other phases (non-infrastructure, non-testing), record FAIL
- [ ] 3. If all phases are deployment-independent, record PASS

```yaml
cs5_evaluation:
  result: "PASS|FAIL"
  phases_checked: <N>
  dependent_phases:
    - phase_name: "<name>"
      cross_phase_dependents: ["<symbol>", ...]
      dependent_on_phase: "<phase_name>"
  explanation: "<reasoning>"
```

### Step 10: Evaluate CS-6 — Blast Radius Bounded

For each phase, evaluate blast radius containment:

- [ ] 1. Check `blast_radius_validation` in `reasoning.yaml` — if any phase has dependents outside the spec's scope, record FAIL with `BLAST_RADIUS_GAP` and `unexpected_downstream_impact`
- [ ] 2. Check `blast_radius` in `evidence.yaml` — if any phase has `cross_phase_dependents` that are not infrastructure or testing, record FAIL with `BLAST_RADIUS_GAP` and `cross_phase_impact`
- [ ] 3. If all phases have bounded blast radius, record PASS

```yaml
cs6_evaluation:
  result: "PASS|FAIL"
  phases_checked: <N>
  blast_radius_gaps:
    - phase_name: "<name>"
      gap_type: "cross_phase_impact|unexpected_downstream_impact"
      affected_symbols: ["<symbol>", ...]
  explanation: "<reasoning>"
```

### Step 11: Evaluate CS-ROUTING — Routing Table Changes When Task File Removed

For each entry in `evidence.routing_evidence`, evaluate routing table completeness:

- [ ] 1. Check `routing_validation` in `reasoning.yaml` — if any entry has `routing_references_found` that are non-empty and the spec does not address them, record FAIL
- [ ] 2. If a spec step removes or delegates a task file, verify the spec also addresses routing table updates
- [ ] 3. If no routing changes are needed (no task files removed or delegated), record PASS
- [ ] 4. If all routing changes are addressed, record PASS

```yaml
cs_routing_evaluation:
  result: "PASS|FAIL"
  routing_entries_checked: <N>
  unaddressed_routing:
    - phase: "<phase_name>"
      referenced_task: "<task_name>"
      routing_references_found: ["<file_path>", ...]
  explanation: "<reasoning>"
```

### Step 12: Evaluate Separation of Concerns (A8)

Evaluate the spec for SC-level concern separation using evidence from `evidence.sc_orthogonality` and validation from `reasoning.sc_orthogonality_validation`:

- [ ] 1. **SC orthogonality** — Verify each SC can be independently verified:
  - Check `sc_orthogonality.scs` — if any SC's `referenced_symbols` or `referenced_files` overlap with another SC's, flag as `CONCERN_GAP` with `sc_overlap`
  - Check `sc_orthogonality.sc_overlaps` — if any overlap exists, flag as `CONCERN_GAP`
  - If an SC cannot be verified independently (depends on another SC's state), flag as `CONCERN_GAP` with `sc_dependency`
- [ ] 2. **Cross-concern overlap detection** — Check for shared symbols between phases:
  - Check `cross_phase_overlaps` in `evidence.yaml` — if two phases share symbols, flag as `CONCERN_GAP` with `shared_symbols_between_phases`
  - Cross-check against `cross_phase_validation` in `reasoning.yaml` — if overlaps are validated, they are genuine

```yaml
separation_of_concerns:
  sc_orthogonality:
    result: "PASS|FAIL"
    scs_checked: <N>
    findings:
      - type: "sc_overlap|sc_dependency"
        sc_a: "<id>"
        sc_b: "<id>"
        description: "<description>"
  cross_concern_overlap:
    result: "PASS|FAIL"
    phases_checked: <N>
    findings:
      - type: "shared_symbols_between_phases"
        phase_a: "<name>"
        phase_b: "<name>"
        shared_symbols: ["<symbol>", ...]
        description: "<description>"
```

### Step 13: Evaluate Scope Creep (A6)

Evaluate the spec for cross-concern scope violations using evidence from `evidence.cross_phase_overlaps` and validation from `reasoning.cross_phase_validation`:

- [ ] 1. **Cross-concern scope detection** — Check if any phase's scope overlaps with another phase's concern:
  - Check `cross_phase_overlaps` in `evidence.yaml` — if two phases share files or symbols, flag as `SCOPE_CREEP` with `cross_concern_overlap`
  - Cross-check against `cross_phase_validation` in `reasoning.yaml` — if overlaps are validated, they are genuine
- [ ] 2. **Scope boundary verification** — Verify each phase stays within its declared concern:
  - For each phase, compare its `concern_keywords` against the concern categories of its steps
  - If a phase includes steps outside its concern, flag as `SCOPE_CREEP` with `phase_scope_breach`

```yaml
scope_creep:
  cross_concern_overlap:
    result: "PASS|FAIL"
    phases_checked: <N>
    findings:
      - type: "cross_concern_overlap"
        phase_a: "<name>"
        phase_b: "<name>"
        shared_files: ["<path>", ...]
        shared_symbols: ["<symbol>", ...]
        description: "<description>"
  scope_boundary_verification:
    result: "PASS|FAIL"
    phases_checked: <N>
    findings:
      - type: "phase_scope_breach"
        phase_name: "<name>"
        declared_concern: "<concern>"
        breaching_steps: ["<step_text>", ...]
        description: "<description>"
```

### Step 14: Classify Findings

Map evaluation results to finding types:

| Finding Type | Problem Class | Criterion | Verdict |
|-------------|---------------|-----------|---------|
| BOILERPLATE_TITLE | Phase name generic | CS-1 | FAIL |
| CONCERN_MIXING | Steps from different concerns | CS-2 | FAIL |
| DEPENDENCY_REVERSAL | Wrong order | CS-3 | FAIL |
| HIGH_RISK_GROUPING | Risk mixing | CS-4 | FAIL |
| MISSING_RISK_CLASSIFICATION | No risk declared | CS-4 | FAIL |
| MISSING_INDEPENDENCE | Cannot deploy phase alone | CS-5 | FAIL |
| BLAST_RADIUS_GAP | Impact not contained | CS-6 | FAIL |
| ROUTING_GAP | Routing table not updated | CS-ROUTING | FAIL |
| CONCERN_GAP | SC overlap or dependency | A8 | FAIL |
| SCOPE_CREEP | Cross-concern scope violation | A6 | FAIL |

### Step 15: Self-Consistency Gate

Before writing the final artifact, verify verdict self-consistency:

- [ ] 1. For each `per_criterion` entry, check: if `result: "PASS"` and `explanation` contains critique, hedging, or caveat language (e.g., "but", "however", "minor", "mostly", "functionally equivalent", "close enough", "with concerns"), the verdict is downgraded to FAIL
- [ ] 2. If any criterion was downgraded, append a `self_consistency` section to the verdict:

```yaml
self_consistency:
  downgraded_criteria:
    - criterion_id: "CS-N"
      original_result: "PASS"
      downgraded_to: "FAIL"
      reason: "explanation contained hedging language: '<matched phrase>'"
```

- [ ] 3. Update `all_criteria_pass` to `false` and `remediation_required` to `true` if any downgrade occurred

### Step 16: Write verdict.yaml

Write the full verdict to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml`:

```yaml
evaluator_type: concern-separation-evaluator
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
evidence_source: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml"
reasoning_source: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml"
phases_analyzed: <N>
per_criterion:
  - criterion_id: "CS-1"
    result: "PASS|FAIL"
    evidence: "<reference to evidence.yaml or reasoning.yaml section>"
    explanation: "<reasoning — no hedging language>"
    remediation: "<remediation if FAIL, empty if PASS>"
    next_step: "proceed|remediate"
  - criterion_id: "CS-2"
    result: "PASS|FAIL"
    evidence: "<reference>"
    explanation: "<reasoning>"
    remediation: "<remediation if FAIL>"
    next_step: "proceed|remediate"
  - criterion_id: "CS-3"
    result: "PASS|FAIL"
    evidence: "<reference>"
    explanation: "<reasoning>"
    remediation: "<remediation if FAIL>"
    next_step: "proceed|remediate"
  - criterion_id: "CS-4"
    result: "PASS|FAIL"
    evidence: "<reference>"
    explanation: "<reasoning>"
    remediation: "<remediation if FAIL>"
    next_step: "proceed|remediate"
  - criterion_id: "CS-5"
    result: "PASS|FAIL"
    evidence: "<reference>"
    explanation: "<reasoning>"
    remediation: "<remediation if FAIL>"
    next_step: "proceed|remediate"
  - criterion_id: "CS-6"
    result: "PASS|FAIL"
    evidence: "<reference>"
    explanation: "<reasoning>"
    remediation: "<remediation if FAIL>"
    next_step: "proceed|remediate"
  - criterion_id: "CS-ROUTING"
    result: "PASS|FAIL"
    evidence: "<reference>"
    explanation: "<reasoning>"
    remediation: "<remediation if FAIL>"
    next_step: "proceed|remediate"
separation_of_concerns:
  sc_orthogonality:
    result: "PASS|FAIL"
    findings: []
  cross_concern_overlap:
    result: "PASS|FAIL"
    findings: []
scope_creep:
  cross_concern_overlap:
    result: "PASS|FAIL"
    findings: []
  scope_boundary_verification:
    result: "PASS|FAIL"
    findings: []
self_consistency:
  downgraded_criteria: []
findings:
  - type: "<finding_type>"
    phase: "<phase_name>"
    description: "<description>"
    recommendation: "<recommendation>"
verdict: "PASS|FAIL"
all_criteria_pass: <true|false>
remediation_required: <true|false>
exec_summary: "Concern separation: <X>/<Y> criteria PASS. <N> phases need review."
```

### Step 16.5: Identify Behavioral SCs for Clean-Room Evaluation

- [ ] 16.5. From the evaluated criteria, collect SC IDs whose evidence type is `behavioral` (either declared or uplifted)
  - Add `needs_clean_room: [SC-IDs]` to the result contract
  - If no behavioral SCs, set `needs_clean_room: []`

### Step 17: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/verdict.yaml"
summary: "Concern separation evaluated: {N} criteria, {X} PASS, {Y} FAIL. Verdict: {PASS|FAIL}."
all_criteria_pass: <true|false>
remediation_required: <true|false>
needs_clean_room: [SC-IDs]
```

## Edge Cases

| Phase Type | Analysis |
|-----------|----------|
| Infrastructure | Crosses all layers by design — report as intentional, do not FAIL CS-2 or CS-5 |
| Testing | Validates all layers — report as intentional, do not FAIL CS-2 or CS-5 |
| Single-step | Already atomic — no split needed, PASS CS-2 |
| No routing evidence | CS-ROUTING evaluates to PASS (no task files removed or delegated) |
| srclight unavailable | Evidence items with `validation_status: UNVERIFIED` due to srclight — evaluate on available evidence, note limitation in explanation |

## Error Handling

| Error | Action |
|-------|--------|
| `evidence.yaml` not found | Return BLOCKED — Investigator must produce evidence first |
| `reasoning.yaml` not found | Return BLOCKED — upstream reasoning role must validate evidence first |
| `spec_local_dir` missing or empty | Return BLOCKED — cannot evaluate without source data |
| Evidence section missing from evidence.yaml | Record `evidence_missing: true` for that criterion, evaluate on available data |
| Validation section missing from reasoning.yaml | Record `validation_missing: true` for that criterion, evaluate on raw evidence |
| Write permission denied | Return BLOCKED — cannot write verdict.yaml |

## Cross-References

- `tasks/concern-separation-investigator.md` — Investigator role (produces evidence.yaml)
- `tasks/concern-separation-validator.md` — upstream reasoning role role (produces reasoning.yaml)
- `tasks/cross-validate.md` — Arbiter (final judgment, consumes verdict.yaml)
- `000-critical-rules.md` — Single Concern Principle
- `065-verification-honesty.md` — live verification requirement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
