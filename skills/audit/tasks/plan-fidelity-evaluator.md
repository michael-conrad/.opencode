
<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: plan-fidelity-evaluator

## Purpose

Evaluate plan fidelity against spec using evidence collected and validated by upstream roles. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each criterion, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This is the Evaluator role in the 4-role chain — it produces judgments, not just evidence.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts — contains `evidence.yaml` from Investigator and `reasoning.yaml` from upstream reasoning role
- `github.owner`, `github.repo` available

## Entry Criteria

- `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml` — produced by the Investigator role
- `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml` — produced by the upstream reasoning role role
- `spec_local_dir` is present and non-empty — contains at minimum `spec.md`
- Plan files exist in `spec_local_dir/` — either `plan.md` + `plan-*.md` phase files, or plan embedded in spec body
- Write access to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/`

## Exit Criteria

- Every criterion in the evaluation table evaluated against validated evidence
- Per-criterion PASS/FAIL verdicts produced with explanations and evidence references
- Self-consistency gate applied — no PASS verdicts with hedging language
- Discrepancies classified by finding type
- Bidirectional findings generated for FAIL/DISAGREE criteria
- `verdict.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml`
- No unjudged criteria — every criterion has a verdict

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove `verdict.yaml` if it exists from a prior run: `rm -f {project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml`
- [ ] 2. Verify `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml`
- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob(pattern="**/*.md", path="<spec_local_dir>")
- [ ] 4. If `evidence.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for plan-fidelity-evaluator. The Investigator role must produce evidence.yaml before the Evaluator can produce verdicts."
```

- [ ] 5. If `reasoning.yaml` is missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for plan-fidelity-evaluator. The upstream reasoning role role must produce reasoning.yaml before the Evaluator can produce verdicts."
```

- [ ] 6. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for plan-fidelity-evaluator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Read Upstream Artifacts

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml` — raw evidence from Investigator
- [ ] 2. Read `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml` — validated evidence from upstream reasoning role
- [ ] 3. Cross-reference: for each evidence item, confirm the upstream reasoning role's validation status
- [ ] 4. Identify items marked `unverifiable: true` — these cannot be used as evidence for PASS verdicts
- [ ] 5. Identify items marked `validated: false` with discrepancies — these indicate evidence-source mismatch

### Step 3: Build Evaluation Criteria

Evaluate each criterion against the validated evidence. Expected values reference authoritative skill cards, not hard-coded concrete values.

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| PF-1 | All phases in clean-room appear in existing | One-to-one phase coverage |
| PF-2 | Phase order matches dependency order | No dependency reversal |
| PF-3 | Steps cover ALL success criteria; missing any is automatic FAIL per spec gate | Each SC has corresponding step — missing any is automatic FAIL |
| PF-5 | Approach consistent | Clean-room and existing use same strategy |
| PF-STRUCTURAL-FAIL | Structural evidence rejected for behavioral SCs in plan instructions | If a plan phase's verification instructions accept structural evidence (grep/read/file-exists) for a behavioral SC, return FAIL with `STRUCTURAL_EVIDENCE` classification. **PF-STRUCTURAL-FAIL uplift:** When checking plan fidelity, if an implementation change affects runtime behavior, uplift the SC evidence type to `behavioral`. Read [critical-rules-BEH-EV](guidelines/000-critical-rules.md). Verification instructions MUST require behavioral test execution — structural checks do not verify behavior. |
| PF-Z3-CONTRACT | Z3 contract completeness and correctness | Check: (1) Contract follows Read [Contract YAML Structure](skills/solve/tasks/contract.md) — typed variables (`type`, `domain`, `nullable`) with Z3 expression constraints. (2) NO preconditions declared (preconditions block valid state transitions). (3) Invariants enforce serial ordering (implies pN, pN-1). Any check fails → PF-BLOCKED. |
| PF-SEQUENCE-MATCHES | Gate sequence matches pipeline source — missing gates are automatic FAIL with no remediation path | Gate sequence matches Read [implementation-workflow reference card](skills/writing-plans/reference/implementation-workflow.md) dispatch routing table — read dynamically, not hardcoded. Any missing gate is automatic FAIL — the plan MUST be regenerated, not patched. |
| PF-STRUCTURAL | Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, verify the plan has that element with the correct format. | All structural elements present and correctly formatted |
| PF-7a (cost-frame) | Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each phase's cost frame follows the dark-prose-007 pattern. | Each phase's cost frame follows dark-prose-007 |
| PF-CHECKLIST-FORMAT | Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify all steps use the canonical checklist format. | All steps use canonical checklist format |
| PF-DISPATCH-MODE | Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify every step has exactly one valid dispatch indicator. | Every step has exactly one valid dispatch indicator |
| PF-DISPATCH-DEFECTS | Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify dispatch declarations are consistent with step indicators. | Dispatch declarations consistent with step indicators |
| PF-SUBSTEP-EXPAND | Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify no step describes more than one atomic action. | No step describes more than one atomic action |

### Step 4: Evaluate Each Criterion

For each criterion in the evaluation table, produce a verdict using evidence from `reasoning.yaml`:

- [ ] 1. **Locate evidence** — find the relevant evidence items in `reasoning.yaml` that pertain to this criterion
- [ ] 2. **Check validation status** — if evidence is `unverifiable: true`, it cannot support a PASS verdict
- [ ] 3. **Check discrepancies** — if evidence is `validated: false` with a discrepancy, the criterion FAILs
- [ ] 4. **Apply expected result** — compare the evidence against the criterion's expected result
- [ ] 5. **Produce verdict** — PASS only if evidence 100% supports the expected result with no caveats; otherwise FAIL
- [ ] 6. **Write explanation** — cite specific evidence items from `reasoning.yaml` that support the verdict

For each criterion, record:

```yaml
- criterion_id: "PF-1"
  result: "PASS" | "FAIL"
  evidence: "<reference to reasoning.yaml item>"
  explanation: "<reasoning — cite specific evidence>"
  remediation: ""  # non-empty only if FAIL — what must change
  next_step: "proceed" | "remediate"
```

### Step 5: Evaluate Gap Analysis

Evaluate the plan for coverage gaps using evidence from `reasoning.yaml`:

- [ ] 1. **Plan completeness** — verify the plan covers all SCs from the spec:
  - Does every SC have a corresponding step in the plan?
  - If an SC has no plan step, flag as `GAP_ANALYSIS` with `missing_sc_coverage`

Record results:

```yaml
gap_analysis:
  plan_completeness:
    status: "PASS" | "FAIL"
    findings: ["<description of each gap>"]
```

### Step 6: Evaluate Scope Creep

Evaluate the plan for scope boundary violations using evidence from `reasoning.yaml`:

- [ ] 1. **Plan scope boundary verification** — verify the plan doesn't exceed the spec's scope:
  - Does the plan include steps that modify files not in the spec's Files Affected table?
  - If the plan exceeds spec scope, flag as `SCOPE_CREEP` with `plan_exceeds_spec_scope`

Record results:

```yaml
scope_creep:
  plan_scope_boundary:
    status: "PASS" | "FAIL"
    findings: ["<description of each gap>"]
```

### Step 7: Evaluate Scope Narrowness

Evaluate the plan for insufficient root cause depth using evidence from `reasoning.yaml`:

- [ ] 1. **Plan root cause depth** — verify the plan addresses the root cause, not just symptoms:
  - Does the plan's first phase address the root cause identified in the spec?
  - If the plan only addresses symptoms, flag as `SCOPE_NARROWNESS` with `plan_symptom_only`

Record results:

```yaml
scope_narrowness:
  plan_root_cause_depth:
    status: "PASS" | "FAIL"
    findings: ["<description of each gap>"]
```

### Step 8: Evaluate Cross-Reference Completeness

Evaluate the plan for reference integrity using evidence from `reasoning.yaml`:

- [ ] 1. **Plan reference integrity** — verify all cross-references in the plan are accurate:
  - For each issue reference (#N), verify the issue exists and is relevant
  - For each file path reference, verify the file exists
  - If a reference is broken or irrelevant, flag as `CROSS_REF_GAP` with `broken_reference`

Record results:

```yaml
cross_reference_completeness:
  plan_reference_integrity:
    status: "PASS" | "FAIL"
    findings: ["<description of each gap>"]
```

### Step 9: Evaluate Blast Radius

Evaluate the plan's blast radius analysis using evidence from `reasoning.yaml`:

- [ ] 1. **Plan scope verification** — verify the plan's scope matches the spec's scope:
  - Does the plan cover all files listed in the spec's Files Affected table?
  - Does the plan add files not in the spec? If so, flag as `BLAST_RADIUS_GAP` with `plan_overscoped`
- [ ] 2. **Impact trace** — for each file in the plan, use `srclight_get_dependents` to verify blast radius:
  - If dependents exist that the plan doesn't address, flag as `BLAST_RADIUS_GAP` with `missing_dependent`

Record results:

```yaml
blast_radius:
  plan_scope_verification:
    status: "PASS" | "FAIL"
    findings: ["<description of each gap>"]
  impact_trace:
    status: "PASS" | "FAIL"
    findings: ["<description of each gap>"]
```

### Step 10: Classify Discrepancies

After verdict collection, classify each discrepancy:

| Finding Type | Classification | Action |
|-------------|----------------|--------|
| MISSING_PHASE | auto-fix | Add phase from clean-room |
| EXTRA_PHASE | FAIL | May be intentional — must be justified |
| MISSING_STEP | auto-fix | Add step from clean-room |
| EXTRA_STEP | FAIL | May be intentional — must be justified |
| APPROACH_DIFFERENCE | auto-fix | Clarify difference |
| MISSING_EDGE_CASE | FAIL | Verify clean-room correctness |
| DEPENDENCY_REVERSAL | auto-fix | Reorder phases |
| MISSING_TDD_CHECKPOINT | FAIL | Add RED checkpoint |

### Step 11: Generate Bidirectional Findings

For FAIL/DISAGREE criteria:

| Direction | Description |
|-----------|-------------|
| PLAN_INCOMPLETE | Existing plan missing clean-room elements |
| PLAN_OVERSCOPED | Clean-room smaller than existing |
| PLAN_DRIFT | Clean-room and existing diverged |

Present revision options.

### Step 12: Self-Consistency Gate — Verdict Integrity Check

Before writing verdict.yaml, run the self-consistency gate on every criterion:

- [ ] 1. For each criterion where `result: "PASS"`, inspect `explanation` for critique/hedging language:
  - Hedging patterns: "mostly", "largely", "generally", "for the most part", "minor issues", "some concerns", "slight", "mostly correct", "functionally equivalent", "close enough", "with caveats", "with notes"
  - If ANY hedging pattern is found, downgrade `result` to `FAIL` and set `remediation` to `"Self-consistency gate: PASS verdict contradicted by hedging in explanation"`
- [ ] 2. If `result: "FAIL"` and `explanation` contains no hedging or critique, the verdict stands — no upgrade to PASS
- [ ] 3. Log the self-consistency check result in the verdict YAML under `self_consistency_gate: { triggered: true|false, downgraded_criteria: ["<criterion IDs>"] }`

### Step 13: Write verdict.yaml

Write the complete verdict to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml`:

```yaml
generated_at: "<ISO timestamp>"
evaluator_model: "<model>"
evidence_source: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml"
reasoning_source: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml"
per_criterion:
  - criterion_id: "PF-1"
    result: "PASS" | "FAIL"
    evidence: "<reference to reasoning.yaml item>"
    explanation: "<reasoning — cite specific evidence>"
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
all_criteria_pass: true | false
remediation_required: true | false
auto_fixes_applied: []
exec_summary: "Plan fidelity: X/Y criteria PASS. N discrepancies found."
```

### Step 13.5: Identify Behavioral SCs for Clean-Room Evaluation

- [ ] 13.5. From the evaluated criteria, collect SC IDs whose evidence type is `behavioral` (either declared or uplifted)
  - Add `needs_clean_room: [SC-IDs]` to the result contract
  - If no behavioral SCs, set `needs_clean_room: []`

### Step 14: Return Frugal Result Contract

```yaml
status: DONE | FAIL | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL. Z discrepancies found."
all_criteria_pass: true | false
remediation_required: true | false
needs_clean_room: [SC-IDs]
```

## Error Handling

| Error | Action |
|-------|--------|
| `evidence.yaml` missing | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| `reasoning.yaml` missing | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| `spec_local_dir` missing or empty | Return BLOCKED — `MISSING_REQUIRED_INPUT` |
| Evidence item marked `unverifiable: true` | Cannot support PASS verdict — criterion FAILs unless other evidence suffices |
| Evidence item marked `validated: false` with discrepancy | Criterion FAILs — evidence-source mismatch |
| Write permission denied | Return BLOCKED — cannot write verdict |
| Self-consistency gate triggers downgrade | Downgrade PASS to FAIL, record in `self_consistency_gate` |

## Cross-References

- `tasks/plan-fidelity-investigator.md` — Investigator role (produces `evidence.yaml` consumed by this task)
- `tasks/plan-fidelity-validator.md` — upstream reasoning role role (produces `reasoning.yaml` consumed by this task)
- `audit/SKILL.md` — orchestrator-level plan-fidelity audit dispatch (chain: Investigator → upstream reasoning role → Evaluator → Arbiter)
- `writing-plans` skill — clean-room plan generation
- Read [critical-rules-BEH-EV](guidelines/000-critical-rules.md) (PF-STRUCTURAL-FAIL uplift), Read [critical-rules-034](guidelines/000-critical-rules.md) (inline work prohibition)
- Read [implementation-workflow reference card](skills/writing-plans/reference/implementation-workflow.md) — dispatch routing table (PF-SEQUENCE-MATCHES source)
- Read [Contract YAML Structure](skills/solve/tasks/contract.md) (PF-Z3-CONTRACT source)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
