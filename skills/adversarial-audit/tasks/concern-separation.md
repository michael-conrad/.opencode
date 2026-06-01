<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: concern-separation

## Purpose

Audit spec phase structure for concern separation quality using dual-adversarial verification. Checks deployment independence, risk profile, and blast radius per phase.

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

### Step 4: Cross-Validate via task()

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task cross-validate with:

spec_local_dir: {spec_local_dir}
audit_phase: {audit_phase}
authorization_scope: {authorization_scope}
halt_at: {halt_at}
pr_strategy: {pr_strategy}
pipeline_phase: {pipeline_phase}

# NOTE: cross-validate does NOT dispatch auditors — it receives
# pre-resolved auditor_artifact_paths and reads YAMLs from disk.
auditor_artifact_paths: {auditor_artifact_paths}

worktree.path: {worktree.path}
"""
)
```

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

### Step 7: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `./tmp/artifacts/pipeline-{issue_number}-audit-concern-separation-{STATUS}-{timestamp}.yaml`:

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
    next_step: "proceed"
findings:
  - type: "BOILERPLATE_TITLE"
    phase: "<phase>"
    classification: "flag-for-review"
    recommendation: "<recommendation>"
exec_summary: "Concern separation: X/Y criteria. N phases need review."
```

### Step 8: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/artifacts/pipeline-{issue_number}-audit-concern-separation-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
```

## Edge Cases

| Phase Type | Analysis |
|-----------|----------|
| Infrastructure | Crosses all layers by design → report as intentional |
| Testing | Validates all layers → report as intentional |
| Single-step | Already atomic → no split needed |

## Dispatch Mandate (CRITICAL — per critical-rules-048)

This task is a **reference document** that defines evaluation criteria and result contracts. The orchestrator is responsible for:
1. Dispatching a sub-agent for `resolve-models` to obtain auditor pair
2. Dispatching auditor sub-agents in parallel
3. Dispatching a sub-agent for `cross-validate` with pre-resolved `auditor_artifact_paths`

This task MUST NOT be read and executed inline. Reading this file and performing the described steps via raw tool calls is a CRITICAL VIOLATION per critical-rules-048.

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
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
```