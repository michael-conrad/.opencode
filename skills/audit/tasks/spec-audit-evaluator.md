---
name: spec-audit-evaluator
description: "Evaluator role for the spec-audit DiMo chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each criterion, and writes verdict.yaml with per-criterion PASS/FAIL verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit-evaluator

## Purpose

Evaluator role for the spec-audit DiMo chain. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each criterion against the spec, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This role produces judgments — it does NOT collect evidence or validate evidence. Those are upstream responsibilities.

> **DiMo Role: Evaluator.** This task evaluates spec quality. Reads `evidence.yaml` + `reasoning.yaml` from upstream roles, evaluates each criterion, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts.
>
> You are the Evaluator. You are decisive and binary. Every criterion gets a PASS or a FAIL — nothing in between. You do not hedge, you do not defer, you do not ask for a second opinion. The evidence is in front of you. The upstream reasoning role has already validated it. Make the call.
>
>
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns", no INCONCLUSIVE
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-validate evidence that upstream reasoning role already validated — trust the `reasoning.yaml` validation status
> - MUST NOT collect new evidence — that is the Investigator's job
> - MUST write `verdict.yaml` as the primary output artifact
> - MUST apply the self-consistency gate: if a PASS verdict's explanation contains critique/hedging language, downgrade to FAIL

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from upstream roles are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against validated evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory containing `evidence.yaml` and `reasoning.yaml` from upstream roles
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity
- `blast_radius_path`: Path to blast radius analysis artifact (optional)
- `concern_map_path`: Path to concern map artifact (optional)
- `code_path_inventory_path`: Path to code path inventory artifact (optional)
- `cross_cutting_matrix_path`: Path to cross-cutting matrix artifact (optional)
- `interface_compatibility_path`: Path to interface compatibility artifact (optional)
- `state_analysis_path`: Path to state analysis artifact (optional)
- `testability_assessment_path`: Path to testability assessment artifact (optional)
- `failure_description`: Optional — prior implementation failure description (triggers enhanced determinism evaluation)

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Evaluator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the upstream reasoning role completed successfully and wrote `reasoning.yaml` before dispatching the Evaluator. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for verdict artifacts)
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- `verdict.yaml` written to `{artifact_evidence_dir}/verdict.yaml`
- Every criterion evaluated with binary PASS/FAIL — no INCONCLUSIVE, no "PASS with concerns"
- Holistic dimensions evaluated (11 dimensions from `.opencode/reference/holistic-dimensions.yaml`)
- Narrow criteria evaluated (SC-1 through SC-14 excluding SC-7, SC-DET, SC-STRUCTURAL-FAIL, SC-EVIDENCE-TYPE, SC-TRACKING-LANG, SC-PRESCRIPTIVE-CODE, SC-PIPELINE-GATES, SC-CANONICAL-PLAN-FORM, SC-ADMONISHMENT, SC-REASONING, SC-CLAIM, SC-BLAST-RADIUS, SC-CONCERN-MAP, SC-CODE-PATH, SC-CROSS-CUTTING, SC-INTERFACE, SC-STATE, SC-TESTABILITY)
- SC-SEM criteria evaluated (if spec is a skill card audit)
- Analytical artifact criteria evaluated (if artifact paths provided)
- Self-consistency gate applied to all PASS verdicts
- Bidirectional findings generated for FAIL/DISAGREE criteria
- No new evidence collected — all evaluation based on upstream artifacts

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `verdict.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for spec-audit-evaluator. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Evaluator."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for spec-audit-evaluator. The orchestrator must ensure the upstream reasoning role completed successfully and wrote reasoning.yaml before dispatching the Evaluator."
```

- [ ] 5. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 6. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for spec-audit-evaluator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 7. Verify `artifact_evidence_dir` is writable — create it if it does not exist
- [ ] 8. Verify plan-fidelity `verdict.yaml` exists at `./tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml` — this is a cross-chain dependency. The spec-audit evaluator MUST NOT produce a verdict without the plan-fidelity audit having completed first. The orchestrator MUST ensure plan-fidelity completed before dispatching the spec-audit evaluator.
- [ ] 9. If plan-fidelity `verdict.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_PLAN_FIDELITY_VERDICT
missing: "./tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml"
remediation: "Plan-fidelity verdict.yaml is required for spec-audit-evaluator. The orchestrator must ensure the plan-fidelity audit completed successfully before dispatching the Evaluator. The plan-fidelity audit produces verdict.yaml at ./tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml."
```

### Step 2: Load Upstream Artifacts

Read the Investigator's evidence and the upstream reasoning role's validated reasoning:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Parse all top-level sections from both artifacts
- [ ] 4. Record metadata: `generator`, `knowledge_supporter`, `issue_number`, `generated_at`, `spec_local_dir`
- [ ] 5. If any expected top-level section is absent from either artifact, record as `section_missing` — do NOT BLOCK, but flag in the verdict
- [ ] 6. Note the upstream reasoning role's `overall_validation_status` — this informs evaluation confidence

### Step 3: Load Spec Content

Read the spec files to establish the authoritative baseline for evaluation:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract spec body and frontmatter metadata from each file
- [ ] 4. Extract the Success Criteria table — this is the authoritative list of SCs to evaluate
- [ ] 5. Extract the STATUS marker if present
- [ ] 6. Determine if this is a skill card audit (spec references a SKILL.md file or `spec_local_dir` contains a SKILL.md)

### Step 4: Holistic Semantic Evaluation Gate

Evaluate the spec against all 11 holistic dimensions. This gate runs BEFORE narrow criteria — if any dimension FAILs, the spec is returned as DRAFT and narrow criteria never execute.

- [ ] 1. For each of the 11 holistic dimensions defined in `.opencode/reference/holistic-dimensions.yaml`, evaluate using the validated evidence from `reasoning.yaml`:

| # | Dimension | Question | Evidence Source |
|---|-----------|----------|-----------------|
| 1 | Implementability | Can an agent produce correct output from this spec? | `holistic_dimension_validation.implementability` |
| 2 | Internal Consistency | Does the spec contradict itself across sections? | `holistic_dimension_validation.internal_consistency` |
| 3 | Completeness | Are there gaps forcing the implementor to guess? | `holistic_dimension_validation.completeness` |
| 4 | Scope Discipline | Does the spec stay within its stated boundaries? | `holistic_dimension_validation.scope_discipline` |
| 5 | Testability | Can every SC be independently verified? | `holistic_dimension_validation.testability` |
| 6 | Escape Hatches | Does the spec contain language that lets the agent short-circuit requirements? | `prose_validation.escape_hatches` |
| 7 | Provenance | Are the spec's claims backed by evidence? | `holistic_dimension_validation.provenance` |
| 8 | Feasibility | Can this actually be done with available tools and constraints? | `holistic_dimension_validation.feasibility` |
| 9 | Safety | Does the spec have failure modes that could cause irreversible harm? | `holistic_dimension_validation.safety` |
| 10 | Traceability | Does every element connect to something else in a coherent chain? | `holistic_dimension_validation.traceability` |
| 11 | Correctness | Does this spec actually solve the right problem? | `holistic_dimension_validation.correctness` |

- [ ] 2. Each dimension gets a single PASS/FAIL — no hedging, no "PASS with concerns"
- [ ] 3. If the upstream reasoning role flagged a dimension's evidence as `corrected` or `unvalidated`, factor that into the evaluation
- [ ] 4. If any dimension FAILs:
  - Halt — do NOT proceed to narrow criteria (Steps 5+)
  - Record `holistic_status: DRAFT` in the verdict
  - Include specific findings for each failed dimension with remediation guidance
- [ ] 5. If all 11 dimensions PASS:
  - Proceed to narrow criteria (Steps 5+)
  - Record `holistic_status: PASS` in the verdict

Record results:

```yaml
holistic_evaluation:
  status: "PASS|DRAFT"
  dimensions:
    - id: 1
      name: "Implementability"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.implementability"
    - id: 2
      name: "Internal Consistency"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.internal_consistency"
    - id: 3
      name: "Completeness"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.completeness"
    - id: 4
      name: "Scope Discipline"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.scope_discipline"
    - id: 5
      name: "Testability"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.testability"
    - id: 6
      name: "Escape Hatches"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → prose_validation.escape_hatches"
    - id: 7
      name: "Provenance"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.provenance"
    - id: 8
      name: "Feasibility"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.feasibility"
    - id: 9
      name: "Safety"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.safety"
    - id: 10
      name: "Traceability"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.traceability"
    - id: 11
      name: "Correctness"
      result: "PASS|FAIL"
      finding: "<brief finding>"
      evidence_source: "reasoning.yaml → holistic_dimension_validation.correctness"
```

### Step 5: Evaluate Narrow Criteria

For each narrow criterion, evaluate using the validated evidence from `reasoning.yaml`. The evidence has already been collected (Investigator) and validated (upstream reasoning role). The Evaluator's job is to render judgment.

#### Step 5a: Evaluate Structural Criteria (SC-1 through SC-14, excluding SC-7)

| Criterion ID | Description | Evidence Source | Evaluation Rule |
|--------------|-------------|-----------------|-----------------|
| SC-1 | Problem statement present | `spec_structure_validation.preamble` | PASS if preamble present with non-empty Problem Statement |
| SC-2 | Success criteria measurable | `spec_structure_validation.success_criteria` + `determinism_validation.verification_methods` | PASS if every SC has a verification method |
| SC-3 | Phases well-structured | `spec_structure_validation.phases` | PASS if phases have clear boundaries and sub-items |
| SC-4 | Steps actionable | `spec_structure_validation` | PASS if each step has a file path or task reference |
| SC-5 | Dependencies identified | `reasoning_validation` | PASS if phase dependencies are documented |
| SC-6 | Concerns separated | `spec_structure_validation.phases` | PASS if single concern per phase |
| SC-8 | Operational clarity | `reasoning_validation.edge_cases` | PASS if edge cases and error recovery defined |
| SC-9 | Determinism achieved | `determinism_validation` | PASS if repeatable execution path (see also SC-DET) |
| SC-10 | Prose structure valid | `spec_structure_validation.prose_elements` | PASS if headers, lists, tables properly formatted |
| SC-11 | Documentation Sources present and populated | `documentation_source_validation` | PASS if non-empty Documentation Sources section with verified live sources |
| SC-12 | Preamble present | `spec_structure_validation.preamble` | PASS if "## Intent and Executive Summary" with all 5 fields for standard+ specs |
| SC-13 | Cost-frame prose + runtime execution in SCs | `prose_validation.cost_frame_language` | PASS if each SC carries cost-frame reformation language |
| SC-14 | SC Enforcement Gate present and explicit | `spec_structure_validation` | PASS if spec contains all-or-nothing gate statement |

- [ ] 1. For each SC-1 through SC-14 (excluding SC-7, which is now handled by plan-fidelity), read the corresponding evidence from `reasoning.yaml`
- [ ] 2. Apply the evaluation rule — render PASS or FAIL
- [ ] 3. If the upstream reasoning role flagged the evidence as `corrected`, use the corrected values
- [ ] 4. If the upstream reasoning role flagged the evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

#### Step 5b: Evaluate SC-DET (Determinism)

- [ ] 1. Read `determinism_validation` from `reasoning.yaml`
- [ ] 2. For each SC, evaluate:
  - Can two reasonable auditors independently produce the same PASS/FAIL result?
  - Does the SC contain any fail patterns (adverbs without thresholds, comparatives without baselines, open-ended quality, missing expected values, implicit behavior, either/or ambiguity)?
  - Can an executable verification command be written for this SC?
- [ ] 3. If any SC would produce INCONCLUSIVE from any reasonable auditor, flag as FAIL with `SPEC_GAP`
- [ ] 4. If `failure_description` is provided, evaluate whether the SCs are deterministic specifically in light of the failure evidence

#### Step 5c: Evaluate SC-STRUCTURAL-FAIL

- [ ] 1. For each SC that describes testable behavior (correctness, output, result, pass/fail, runtime logic):
  - Check the evidence type declared in `determinism_validation.evidence_type_declarations`
  - If the declared type is `structural` or `string` but the change affects runtime behavior, uplift to `behavioral`
  - If verification evidence is purely structural (grep/read/file-exists) for a behavioral SC, return FAIL with `STRUCTURAL_EVIDENCE` classification
- [ ] 2. Exception: non-testable prose changes (docs, runbooks, guidelines) may use semantic intent verification

#### Step 5d: Evaluate SC-EVIDENCE-TYPE

- [ ] 1. For each SC, read the declared evidence type from `determinism_validation.evidence_type_declarations`
- [ ] 2. Verify the evidence provided matches the minimum acceptable method:
  - `structural` → file existence evidence sufficient
  - `string` → grep/pattern evidence sufficient
  - `semantic` → sub-agent read + judgment evidence sufficient
  - `behavioral` → test execution with output inspection required
- [ ] 3. If the declared type is `behavioral` and only structural evidence exists → FAIL with `EVIDENCE_TYPE_MISMATCH`
- [ ] 4. If the declared type is `semantic` and only string evidence exists → FAIL with `EVIDENCE_TYPE_MISMATCH`
- [ ] 5. Default to `string` if no evidence type is declared

#### Step 5e: Evaluate SC-TRACKING-LANG

- [ ] 1. Read `prose_validation.tracking_language` from `reasoning.yaml`
- [ ] 2. If any tracking/status language instances exist ("implemented", "pending", "confirmed", "viable", "completed") → FAIL
- [ ] 3. Only forward-looking "MUST be" language is permitted

#### Step 5f: Evaluate SC-PRESCRIPTIVE-CODE

- [ ] 1. Read `prose_validation.prescriptive_code` from `reasoning.yaml`
- [ ] 2. If any prescriptive code instances exist (exact file paths with line numbers, exact import strings, exact assertion code) → FAIL
- [ ] 3. Spec should use file area references only

#### Step 5g: Evaluate SC-PIPELINE-GATES

- [ ] 1. Read `spec_structure_validation` from `reasoning.yaml`
- [ ] 2. Verify pipeline gates use canonical checklist format: numbered `- [ ] N.` with dispatch mode indicators
- [ ] 3. Gate tables (per-unit or shared cross-reference) → FAIL

#### Step 5h: Evaluate SC-CANONICAL-PLAN-FORM

- [ ] 1. If the spec defines plan output format requirements, validate they use canonical checklist format
- [ ] 2. Numbered `- [ ] N.` with sub-bullet metadata, dispatch mode indicators → PASS
- [ ] 3. Dispatch tables, shared cross-references → FAIL

#### Step 5i: Evaluate SC-ADMONISHMENT

- [ ] 1. For skill card audits: verify the SKILL.md contains the 5-item Mandatory Task Discipline admonishment
- [ ] 2. For task card audits: verify the 4-item (non-inline) or 3-item (inline) Task Discipline admonishment
- [ ] 3. If not a skill/task card audit: mark as N/A

### Step 6: Evaluate Reasoning Soundness (A1)

Evaluate the spec's causal reasoning, SC traceability, and internal consistency using validated evidence:

- [ ] 1. Read `reasoning_validation` from `reasoning.yaml`
- [ ] 2. **Causal chain validity** — Verify the M:N mapping between Root Cause and Fix Approach:
  - Is every Root Cause element addressed by at least one Fix Approach element? (completeness)
  - Does every Fix Approach element trace to at least one Root Cause element? (sufficiency)
  - If the causal chain is broken, flag as `REASONING_GAP` with `causal_chain_broken`
- [ ] 3. **SC traceability** — Verify each SC traces to at least one Root Cause element:
  - Each SC must have a `traces_to` field or implicit link to a Root Cause
  - Each Root Cause must be tested by at least one SC
  - If an SC has no traceable Root Cause, flag as `REASONING_GAP` with `orphan_sc`
  - If a Root Cause has no SC, flag as `REASONING_GAP` with `untested_root_cause`
- [ ] 4. **Contradiction detection** — Scan for internal contradictions:
  - Explicit contradictions: two statements that directly conflict
  - Implicit contradictions: statements that imply conflicting constraints
  - Scope contradictions: Fix Approach elements that contradict stated scope boundaries
  - If contradictions found, flag as `REASONING_GAP` with `contradiction_detected`

Record results:

```yaml
reasoning_soundness:
  causal_chain:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  sc_traceability:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  contradictions:
    status: "PASS|FAIL"
    findings: ["<description of each contradiction>"]
```

### Step 7: Evaluate Claim Accuracy (A2)

Evaluate the spec's claims for accuracy using validated evidence:

- [ ] 1. Read `documentation_source_validation` from `reasoning.yaml`
- [ ] 2. **FABRICATED verdict meta-rule** — When a claim in the spec has NO source evidence (no URL, no tool-call artifact, no code reference):
  - If the claim is presented as factual but has zero supporting evidence → `FABRICATED` verdict
  - Record as: `result: "FABRICATED"` with `explanation: "Claim asserted without source evidence"`
- [ ] 3. **Negation verification** — When a claim asserts absence, verify the upstream reasoning role confirmed via exhaustive search
- [ ] 4. **Interface contract verification** — When a spec references function signatures, verify the upstream reasoning role confirmed via `srclight_get_signature`

Record results:

```yaml
claim_accuracy:
  fabricated_claims:
    - claim: "<exact text>"
      status: "FABRICATED|PASS"
      explanation: "<reasoning>"
  negation_verifications:
    - claim: "<exact text>"
      status: "PASS|FAIL"
      finding: "<result>"
  interface_verifications:
    - claim: "<exact text>"
      status: "PASS|FAIL"
      finding: "<result>"
```

### Step 8: Evaluate Blast Radius (A3)

Evaluate the spec's blast radius analysis completeness:

- [ ] 1. Read `analytical_artifact_validation.blast_radius` from `reasoning.yaml`
- [ ] 2. **Impact completeness** — Verify all affected files/components are traced:
  - If the blast radius artifact exists, verify it covers all files mentioned in the spec
  - If dependents exist that are not listed, flag as `BLAST_RADIUS_GAP` with `missing_dependent`
- [ ] 3. **Non-code impact** — Check for guideline/skill cross-references and behavioral test implications:
  - Does the change affect any `.opencode/guidelines/` or `.opencode/skills/` files?
  - If non-code impact exists but is not addressed, flag as `BLAST_RADIUS_GAP` with `non_code_impact_unaddressed`

Record results:

```yaml
blast_radius:
  impact_completeness:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  non_code_impact:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 9: Evaluate Research Adequacy (A4)

Evaluate whether the spec's claims are backed by adequate research:

- [ ] 1. **Evidence provenance** — For each key finding, check for tool-call artifacts in `documentation_source_validation`
  - If a finding is asserted without tool-call provenance, flag as `RESEARCH_GAP` with `no_provenance`
- [ ] 2. **Investigation breadth** — Check if alternatives were ruled out via `reasoning_validation.alternatives_considered`
  - If no alternatives are discussed, flag as `RESEARCH_GAP` with `no_alternatives_explored`
- [ ] 3. **Edge case discovery** — Check for boundary exploration via `reasoning_validation.edge_cases`
  - If no edge cases are identified, flag as `RESEARCH_GAP` with `no_edge_case_analysis`
- [ ] 4. **Recency check** — Verify commit history was reviewed
  - If the spec makes claims about code state without commit history review, flag as `RESEARCH_GAP` with `no_recency_check`

Record results:

```yaml
research_adequacy:
  evidence_provenance:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  investigation_breadth:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  edge_case_discovery:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  recency_check:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 10: Evaluate Gap Analysis (A5)

Evaluate the spec for coverage gaps and implicit conditions:

- [ ] 1. **Missing coverage** — Identify untested boundary conditions:
  - For each SC, check if boundary conditions are explicitly tested
  - If an SC has no boundary condition testing, flag as `GAP_ANALYSIS` with `untested_boundary`
- [ ] 2. **Implicit conditions** — Identify preconditions not stated:
  - Scan the spec for assumptions that are not explicitly stated as preconditions
  - If an implicit precondition is found, flag as `GAP_ANALYSIS` with `implicit_precondition`

Record results:

```yaml
gap_analysis:
  missing_coverage:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  implicit_conditions:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 11: Evaluate Scope Creep (A6)

Evaluate the spec for scope boundary violations:

- [ ] 1. **Traceability enforcement** — Verify every Fix Approach element traces to a Root Cause:
  - Each Fix Approach element must have a `traces_to` field or implicit link
  - If a Fix element has no Root Cause traceability, flag as `SCOPE_CREEP` with `untraced_fix_element`
- [ ] 2. **Proportionality** — Verify fix scope aligns with blast radius:
  - Is the fix scope proportional to the blast radius?
  - If fix scope exceeds blast radius, flag as `SCOPE_CREEP` with `disproportionate_scope`

Record results:

```yaml
scope_creep:
  traceability_enforcement:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  proportionality:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 12: Evaluate Scope Narrowness (A7)

Evaluate the spec for insufficient root cause depth:

- [ ] 1. **Root cause depth** — Apply the 5-Whys test:
  - Does the spec identify the root cause, or just a symptom?
  - If the spec fixes a symptom rather than the root cause, flag as `SCOPE_NARROWNESS` with `symptom_only_fix`
- [ ] 2. **Systemic implication** — Check if the problem exists elsewhere:
  - Is the same pattern/issue present in other parts of the codebase?
  - If the fix is localized but the problem is systemic, flag as `SCOPE_NARROWNESS` with `systemic_implication_unaddressed`
- [ ] 3. **Minimum viable scope** — Verify the scope is not over-scoped:
  - Does the fix include changes beyond what's needed to address the root cause?
  - If the scope exceeds the minimum viable fix, flag as `SCOPE_NARROWNESS` with `over_scoped`

Record results:

```yaml
scope_narrowness:
  root_cause_depth:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  systemic_implication:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  minimum_viable_scope:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 13: Evaluate Cross-Reference Completeness (A9)

Evaluate the spec for citation completeness and reference sufficiency:

- [ ] 1. **Completeness of citation** — Verify all relevant context is cited:
  - For each claim that references an external source, check that the citation is complete
  - If a claim references a source without a complete citation, flag as `CROSS_REF_GAP` with `incomplete_citation`
- [ ] 2. **Reference sufficiency** — Verify cited sources support the claims:
  - For each cited source, verify the source actually supports the claim being made
  - If a cited source does not support the claim, flag as `CROSS_REF_GAP` with `insufficient_reference`

Record results:

```yaml
cross_reference_completeness:
  citation_completeness:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  reference_sufficiency:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 14: Evaluate Analytical Artifact Criteria

If analytical artifact paths are provided in the dispatch contract, evaluate each artifact:

- [ ] 1. For each of `blast_radius_path`, `concern_map_path`, `code_path_inventory_path`, `cross_cutting_matrix_path`, `interface_compatibility_path`, `state_analysis_path`, `testability_assessment_path`:
  - If the path is provided, read the corresponding validation from `analytical_artifact_validation` in `reasoning.yaml`
  - If the artifact exists and is non-empty → PASS
  - If the artifact is missing or empty → FAIL
  - If the path is not provided in the dispatch contract → mark as N/A (not required for this audit)
- [ ] 2. For each artifact that exists, cross-reference its content against the spec:
  - Blast radius: verify all spec Files Affected are covered
  - Concern map: verify each phase maps to exactly one concern
  - Code path inventory: verify all code paths affected are enumerated
  - Cross-cutting matrix: verify cross-cutting concerns are identified and mapped
  - Interface compatibility: verify all interface changes are documented
  - State analysis: verify state transitions and invariants are documented
  - Testability assessment: verify test strategy exists for each SC

Record results:

```yaml
analytical_artifact_evaluation:
  blast_radius:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
  concern_map:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
  code_path_inventory:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
  cross_cutting_matrix:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
  interface_compatibility:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
  state_analysis:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
  testability_assessment:
    artifact_path: "<path or absent>"
    status: "PASS|FAIL|N/A"
    findings: ["<description of each gap>"]
```

### Step 15: Evaluate Semantic Auditor Criteria (SC-SEM)

When the spec being audited is a skill card (SKILL.md file), evaluate the SC-SEM criteria:

- [ ] 1. Determine if this is a skill card audit — check if the spec references a SKILL.md file or if `spec_local_dir` contains a SKILL.md
- [ ] 2. If NOT a skill card audit: skip SC-SEM criteria entirely (mark as N/A)
- [ ] 3. If YES: evaluate each SC-SEM criterion using the spec content and validated evidence:

| Criterion ID | Description | Evaluation Rule |
|--------------|-------------|-----------------|
| SC-SEM-001 | Unambiguous dispatch condition | PASS if description clearly states when to invoke; FAIL if vague or ambiguous |
| SC-SEM-002 | Mandatory invocation signal | PASS if description uses mandatory language (MUST, REQUIRED, always); FAIL if reads as optional |
| SC-SEM-003 | Dispatch table alignment | PASS if description covers same use cases as Trigger Dispatch Table; FAIL if mismatch |
| SC-SEM-004 | Full coverage of dispatch conditions | PASS if every table trigger is reflected in description; FAIL if any trigger omitted |
| SC-SEM-005 | No optional/discretionary language | PASS if no optional language found; FAIL if "you can", "you may", "optionally", etc. |
| SC-SEM-006 | Dispatch table sub-item type correctness | PASS if sub-bullets for metadata, sub-checkboxes for actions; FAIL if type mismatch |

- [ ] 4. For each SC-SEM criterion, render PASS or FAIL with explanation and remediation guidance

### Step 16: Process Verdicts

Compile all per-criterion verdicts and apply consensus rules:

- [ ] 1. Collect all verdicts from Steps 4-15 into a single `per_criterion` array
- [ ] 2. Each entry must include: `criterion_id`, `declared_evidence_type`, `result`, `evidence`, `explanation`, `remediation`, `next_step`, `tool_calls_made`
- [ ] 3. `next_step` is `"proceed"` when result is PASS, `"remediate"` when result is FAIL
- [ ] 4. Count total, pass, and fail verdicts

### Step 17: Apply Self-Consistency Gate

Apply a self-consistency check to every PASS verdict:

- [ ] 1. For each criterion with `result: "PASS"`:
  - Read the `explanation` field
  - If the explanation contains critique/hedging language ("should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally") → downgrade to FAIL
  - A PASS verdict must be strictly confirmatory with no critique or hedging
- [ ] 2. Re-count pass/fail after self-consistency downgrades

### Step 18: Generate Bidirectional Findings

Generate findings ONLY for FAIL criteria. PASS criteria MUST NOT appear in the findings table.

| Finding Type | Direction | Description |
|-------------|-----------|-------------|
| SPEC_INCOMPLETE | spec→code | Spec missing required element |
| SPEC_AMBIGUOUS | spec↔code | Spec open to interpretation |
| SPEC_OUTDATED | code→spec | Implementation diverged from spec |
| SPEC_OVERSPECIFIED | spec→code | Spec constrains implementation unnecessarily |

- [ ] 1. For each FAIL criterion, classify the finding type
- [ ] 2. Present revision options for developer decision
- [ ] 3. Include specific remediation guidance for each FAIL

### Step 19: Write verdict.yaml

Write the complete verdict to `{artifact_evidence_dir}/verdict.yaml`:

```yaml
evaluator: spec-audit-evaluator
issue_number: <N>
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
spec_local_dir: "<path>"
holistic_evaluation:
  status: "PASS|DRAFT"
  dimensions: [...]
summary:
  total_criteria: <N>
  pass: <N>
  fail: <N>
  all_criteria_pass: true | false
  remediation_required: true | false
per_criterion:
  - criterion_id: "<ID>"
    declared_evidence_type: "<type>"
    result: "PASS|FAIL|FABRICATED|N/A"
    evidence: "<reference to reasoning.yaml section>"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
reasoning_soundness: {...}
claim_accuracy: {...}
blast_radius: {...}
research_adequacy: {...}
gap_analysis: {...}
scope_creep: {...}
scope_narrowness: {...}
cross_reference_completeness: {...}
analytical_artifact_evaluation: {...}
bidirectional_findings:
  - criterion_id: "<ID>"
    finding_type: "SPEC_INCOMPLETE|SPEC_AMBIGUOUS|SPEC_OUTDATED|SPEC_OVERSPECIFIED"
    description: "<description>"
    revision_option: "<guidance>"
```

### Step 20: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "<N> criteria evaluated. <X> PASS, <Y> FAIL."
all_criteria_pass: true | false
remediation_required: true | false
holistic_status: "PASS|DRAFT"
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Spec Content → INVALID if skipped
- [ ] 4. Holistic Semantic Evaluation Gate → INVALID if skipped (gate blocks all downstream steps on FAIL)
- [ ] 5. Evaluate Narrow Criteria (5a-5i) → INVALID if skipped
- [ ] 6. Evaluate Reasoning Soundness (A1) → INVALID if skipped
- [ ] 7. Evaluate Claim Accuracy (A2) → INVALID if skipped
- [ ] 8. Evaluate Blast Radius (A3) → INVALID if skipped
- [ ] 9. Evaluate Research Adequacy (A4) → INVALID if skipped
- [ ] 10. Evaluate Gap Analysis (A5) → INVALID if skipped
- [ ] 11. Evaluate Scope Creep (A6) → INVALID if skipped
- [ ] 12. Evaluate Scope Narrowness (A7) → INVALID if skipped
- [ ] 13. Evaluate Cross-Reference Completeness (A9) → INVALID if skipped
- [ ] 14. Evaluate Analytical Artifact Criteria → INVALID if skipped
- [ ] 15. Evaluate Semantic Auditor Criteria (SC-SEM) → INVALID if skipped for skill card audits; N/A for non-skill-card audits
- [ ] 16. Process Verdicts → INVALID if skipped
- [ ] 17. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 18. Generate Bidirectional Findings → INVALID if skipped
- [ ] 19. Write verdict.yaml → INVALID if skipped
- [ ] 20. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| reasoning.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| reasoning.yaml is not valid YAML | Return BLOCKED with INVALID_REASONING_FORMAT |
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| upstream reasoning role flagged evidence as unvalidated | Note uncertainty in explanation — still render verdict |
| upstream reasoning role flagged evidence as corrected | Use corrected values — do NOT use original evidence values |
| Holistic gate FAILs | Halt — do NOT proceed to narrow criteria; return DRAFT verdict |
| Analytical artifact path provided but artifact missing | Evaluate as FAIL with `artifact_missing` finding |

## Cross-References

- `tasks/spec-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/spec-audit-validator.md` — upstream reasoning role role (produces the reasoning.yaml consumed by this task)
- `tasks/cross-validate.md` — Arbiter role (consumes this task's verdict.yaml)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `.opencode/reference/holistic-dimensions.yaml` — 11 holistic dimensions definitions
- Load [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations
- Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md) — runtime-behavioral evidence classification gate
- Load [Hard Failure Discipline](guidelines/065-verification-honesty.md) — FAIL is a hard gate, never reclassifiable

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
