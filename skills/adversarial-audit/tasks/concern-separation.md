<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **⚠️ ROLE ANCHOR: You are the DISPATCHED AUDITOR SUB-AGENT.** Your role is to evaluate criteria and produce findings. You do NOT dispatch sub-agents, call `skill()`, or orchestrate pipeline routing. The orchestrator handles all dispatch. Read this file for evaluation criteria and procedure only — ignore any text describing orchestration responsibilities.

# Task: concern-separation

## Purpose

Audit spec phase structure for concern separation quality using dual-adversarial verification. Checks deployment independence, risk profile, and blast radius per phase.

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) both auditors independently agree.

## Entry Criteria

- Spec issue number provided
- `audit_phase: sub_issue_creation` OR `plan_creation`
- `github.owner`, `github.repo` available

## Exit Criteria

- All phases analyzed for concern boundaries
- Risk classification verified
- Deployment independence assessed
- PASS/FAIL consensus achieved

## Procedure

## Concern Separation Checklist

- [ ] 0. Pre-Flight Validation Gate — validate required inputs before proceeding
- [ ] 1. Load Spec — glob spec_local_dir for .md files, read all, extract phases
- [ ] 2. Build Evaluation Criteria — define CS table with evidence types
- [ ] 3. Analyze Phase Structure — per-phase concern/risk/independence/blast radius
- [ ] 4. Cross-Validate — cross-validate will be called by the orchestrator with pre-resolved verdicts
- [ ] 5. Classify Findings — map to finding types
- [ ] 6. Verify Boundary Claims — live tool-call verification per claim
- [ ] 7. Write Verdict Artifact to Disk — YAML output
- [ ] 8. Return Frugal Result Contract

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for concern-separation. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

### Step 1: Load Spec

`spec_local_dir` is REQUIRED. Auditors BLOCK if absent.
```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
for f in spec_files:
    read(filePath=f)
```

Extract all phases and their steps.

### Step 2: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| CS-1 | Phase names are concern-specific | No boilerplate titles (Implementation, Testing) |
| CS-2 | Single concern per phase | All steps share same concern boundary |
| CS-3 | Dependency order correct | No phase depends on later phase |
| CS-4 | Risk levels grouped appropriately | HIGH and LOW not mixed in same phase |
| CS-5 | Deployment independence achieved | Each phase can be deployed independently |
| CS-6 | Blast radius bounded | Phase failure impact is contained |
| CS-ROUTING | Missing routing table changes when task file removed | When a spec removes or delegates a task file that has a routing/dispatch table, checks that the spec also addresses the routing table changes. If the routing table is not updated, the criterion FAILs. |

### Step 3: Analyze Phase Structure

For each phase:

```python
analysis = {
    "phase_name": phase_name,
    "concern": infer_concern(phase_name, steps),
    "is_boilerplate": is_boilerplate_title(phase_name),
    "steps": steps,
    "risk_profile": compute_risk_profile(steps),
    "deployment_independence": check_independence(phase_name, dependencies),
    "blast_radius": compute_blast_radius(steps)
}
```

Concern inference:
- Keywords: migration, schema, table → Data concern
- Keywords: repository, query, ORM → Data access concern
- Keywords: API, service, handler → Business logic concern
- Keywords: UI, component, template → Presentation concern

### Step 3a: Evaluate Separation of Concerns (A8)

Evaluate the spec for SC-level concern separation:

- [ ] 1. **SC orthogonality** — Verify each SC can be independently verified:
  - Does each SC test a distinct behavior without overlapping with other SCs?
  - If two SCs test the same behavior, flag as `CONCERN_GAP` with `sc_overlap`
  - If an SC cannot be verified independently (depends on another SC's state), flag as `CONCERN_GAP` with `sc_dependency`
- [ ] 2. **Cross-concern overlap detection** — Check for shared symbols between phases:
  - For each phase, use `srclight_search_symbols` to find symbols referenced in that phase
  - If two phases share symbols, flag as `CONCERN_GAP` with `shared_symbols_between_phases`

Record results:

```yaml
separation_of_concerns:
  sc_orthogonality:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  cross_concern_overlap:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3b: Evaluate Scope Creep (A6)

Evaluate the spec for cross-concern scope violations:

- [ ] 1. **Cross-concern scope detection** — Check if any phase's scope overlaps with another phase's concern:
  - For each phase, compare its file paths and symbols against other phases
  - If two phases modify the same files or symbols, flag as `SCOPE_CREEP` with `cross_concern_overlap`
- [ ] 2. **Scope boundary verification** — Verify each phase stays within its declared concern:
  - Does the phase's implementation steps stay within its concern boundary?
  - If a phase includes steps outside its concern, flag as `SCOPE_CREEP` with `phase_scope_breach`

Record results:

```yaml
scope_creep:
  cross_concern_overlap:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  scope_boundary_verification:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 4: Cross-Validate

Cross-validate will be called by the orchestrator with pre-resolved auditor_artifact_paths after both auditors complete. Do NOT call cross-validate — your role is to produce your verdict artifact only.

### Step 5: Classify Findings

| Finding Type | Problem Class | Classification |
|-------------|---------------|----------------|
| BOILERPLATE_TITLE | Phase name generic | flag-for-review |
| CONCERN_MIXING | Steps from different concerns | flag-for-review |
| DEPENDENCY_REVERSAL | Wrong order | auto-fix |
| HIGH_RISK_GROUPING | Risk mixing | conditional |
| MISSING_INDEPENDENCE | Cannot deploy phase alone | flag-for-review |

### Step 6: Verify Boundary Claims

Each boundary claim must be verified:

| Claim | Tool Call |
|-------|-----------|
| "Phases share same concern" | `srclight_search_symbols(query, kind)` → check file paths |
| "Phase is deployment-independent" | `srclight_get_callers(symbol_name)` → check cross-phase calls |
| "Risk classification accurate" | `srclight_get_dependents(symbol_name, transitive=true)` → count affected |

**Extended blast radius procedure (CS-6):** For each phase, use `srclight_get_dependents` with `transitive=true` to trace the full impact chain:
- [ ] 1. For each file modified in the phase, call `srclight_get_dependents(symbol_name, transitive=true)` to find all downstream dependents
- [ ] 2. If dependents span multiple phases, flag as `BLAST_RADIUS_GAP` with `cross_phase_impact`
- [ ] 3. If dependents exist outside the spec's scope, flag as `BLAST_RADIUS_GAP` with `unexpected_downstream_impact`

### Step 7: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-concern-separation-{STATUS}-{timestamp}.yaml`:

```yaml
audit_phase: concern_separation
auditor_type: concern-separation
family: <family>
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
phases_analyzed: N
phase_analyses:
  - phase_name: "<phase>"
    concern: "<concern>"
    risk_profile: "<high|medium|low>"
    deployment_independence: true
    blast_radius: "<contained|cross-phase>"
per_criterion:
  - criterion_id: "CS-1"
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"  # Conditional: "remediate" when result is "FAIL", "proceed" when result is "PASS"
findings:
  - type: "BOILERPLATE_TITLE"
    phase: "<phase>"
    classification: "flag-for-review"
    recommendation: "<recommendation>"
exec_summary: "Concern separation: X/Y criteria. N phases need review."
all_criteria_pass: false
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

### Step 8: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-concern-separation-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
all_criteria_pass: false
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

## Edge Cases

| Phase Type | Analysis |
|-----------|----------|
| Infrastructure | Crosses all layers by design → report as intentional |
| Testing | Validates all layers → report as intentional |
| Single-step | Already atomic → no split needed |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 0 (Pre-Flight Validation Gate) → INVALID if skipped
- Step 1 (Load Spec) → INVALID if skipped
- Step 2 (Build Evaluation Criteria) → INVALID if skipped
- Step 3 (Analyze Phase Structure) → INVALID if skipped
- Step 4 (Cross-Validate) → INVALID if skipped
- Step 5 (Classify Findings) → INVALID if skipped
- Step 6 (Verify Boundary Claims) → INVALID if skipped
- Step 7 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After concern-separation completes:
- If consensus PASS: proceed to plan-fidelity or sub_issue_creation pipeline
- If consensus FAIL: remediate findings, then re-audit (resolve-models → auditors → cross-validate)

This step is MANDATORY — the pipeline does not terminate early.

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `concern-separation-auditor/tasks/audit-phases.md` — original procedure
- `000-critical-rules.md` — Single Concern Principle
- `065-verification-honesty.md` — live verification requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: concern-separation-001
    title: "Boilerplate phase names require justification"
    conditions:
      all: ["phase_name matches 'Implementation|Testing|Build|Development'"]
    actions: [REPORT_BOILERPLATE]
    source: "concern-separation.md §Step 3"

  - id: concern-separation-002
    title: "Boundary claims must be verified via live tool calls"
    conditions:
      all: ["claim_made == true", "tool_call_reference == null"]
    actions: [REPORT_VERIFICATION_GAP]
    source: "concern-separation.md §Step 6"

  - id: concern-separation-003
    title: "Cross-phase dependencies must be documented"
    conditions:
      all: ["dependency_found == true", "dependency_documented == false"]
    actions: [REPORT_MISSING_DEPENDENCY]
    source: "concern-separation.md §Step 3"

  - id: concern-separation-004
    title: "next_step MUST be 'remediate' when result is 'FAIL', 'proceed' when result is 'PASS'"
    conditions:
      any:
        - "per_criterion[].result == 'FAIL' AND per_criterion[].next_step != 'remediate'"
        - "per_criterion[].result == 'PASS' AND per_criterion[].next_step != 'proceed'"
    actions: [HALT, REQUIRE_CORRECT_NEXT_STEP]
    source: "concern-separation.md §Step 7 — conditional next_step enforcement"

  - id: concern-separation-005
    title: "all_criteria_pass MUST be true when every criterion result is 'PASS', false otherwise"
    conditions:
      any:
        - "all(criterion.result == 'PASS' for criterion in per_criterion) AND all_criteria_pass != true"
        - "any(criterion.result == 'FAIL' for criterion in per_criterion) AND all_criteria_pass != false"
    actions: [HALT, REQUIRE_CORRECT_ALL_CRITERIA_PASS]
    source: "concern-separation.md §Step 7 — all_criteria_pass enforcement"
```