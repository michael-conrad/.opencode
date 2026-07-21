---
name: plan-fidelity-evaluator
description: "Evaluator role for the plan-fidelity DiMo chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each criterion against validated evidence, and writes verdict.yaml with per-criterion PASS/FAIL verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: plan-fidelity-evaluator

## Purpose

Evaluate plan fidelity against spec using evidence collected and validated by upstream DiMo roles. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each criterion, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This is the Evaluator role in the DiMo 4-role chain — it produces judgments, not just evidence.


>
> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts — contains `evidence.yaml` from Investigator and `reasoning.yaml` from upstream reasoning role
- `github.owner`, `github.repo` available

**Expected-determination rejection:** If the orchestrator includes an expected PASS/FAIL determination or expected verdict in the dispatch context, return:

```yaml
status: BLOCKED
reason: EXPECTED_DETERMINATION_REJECTED
message: "Expected determination detected. Dispatch without pre-judgment."
```

## Entry Criteria

- `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/evidence.yaml` — produced by the Investigator role
- `reasoning.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/reasoning.yaml` — produced by the upstream reasoning role role
- `spec_local_dir` is present and non-empty — contains at minimum `spec.md`
- Plan files exist in `spec_local_dir/` — either `plan.md` + `plan-*.md` phase files, or plan embedded in spec body
- Write access to `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/`
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

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
- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
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

### Step 2.5: Clean-Room Dispatch for Behavioral SCs

For each SC declared as `behavioral` evidence type:

- [ ] 1. Dispatch `behavioral-sc-evaluator` with `artifact_evidence_dir` only (no orchestrator context, no expected outcomes, no cached results)
- [ ] 2. Read the clean-room verdict from `{artifact_evidence_dir}/verdict.yaml`
- [ ] 3. If clean-room returns FAIL for any behavioral SC, the evaluator verdict for that SC is FAIL (regardless of other evidence)
- [ ] 4. If clean-room artifacts are missing or empty, the evaluator verdict for that SC is FAIL with `NO_BEHAVIORAL_EVIDENCE`

### Step 3: Build Evaluation Criteria

Evaluate each criterion against the validated evidence. Expected values reference authoritative skill cards, not hard-coded concrete values.

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| PF-1 | All phases in clean-room appear in existing | One-to-one phase coverage |
| PF-2 | Phase order matches dependency order | No dependency reversal |
| PF-3 | Steps cover ALL success criteria; missing any is automatic FAIL per spec gate | Each SC has corresponding step — missing any is automatic FAIL |
| PF-4 | No missing critical steps | Edge cases, error recovery included |
| PF-5 | Approach consistent | Clean-room and existing use same strategy |
| PF-6 | TDD checkpoints present with RED/GREEN separation; every step has dispatch mode indicator | RED GREEN REFACTOR structure present; RED and GREEN are separate phases, not combined; every step has a valid dispatch indicator per Load [Dispatch Indicators](skills/writing-plans/tasks/write.md) — exactly one of the three |
| PF-7a | Cost-frame prose + runtime execution in instructions | Each phase's implementation instructions carry cost-frame reformation prose and require real test execution with saved artifacts |
| PF-7 | SC gate language preserved in plan tasks | Plan task structure references the all-or-nothing gate from spec; each TDD RED checkpoint is a sub-gate in the chain |
| PF-STRUCTURAL-FAIL | Structural evidence rejected for behavioral SCs in plan instructions | If a plan phase's verification instructions accept structural evidence (grep/read/file-exists) for a behavioral SC, return FAIL with `STRUCTURAL_EVIDENCE` classification. **PF-STRUCTURAL-FAIL uplift:** When checking plan fidelity, if an implementation change affects runtime behavior, uplift the SC evidence type to `behavioral`. Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md). Verification instructions MUST require behavioral test execution — structural checks do not verify behavior. |
| PF-Z3-CONTRACT | Z3 contract completeness and correctness | Check: (1) Contract follows Load [Contract YAML Structure](skills/solve/tasks/contract.md) — typed variables (`type`, `domain`, `nullable`) with Z3 expression constraints. (2) NO preconditions declared (preconditions block valid state transitions). (3) Invariants enforce serial ordering (implies pN, pN-1). Any check fails → PF-BLOCKED. |
| PF-PRESCRIPTIVE-CODE | No prescriptive code in RED/GREEN conditions | RED/GREEN conditions contain NO line numbers, exact code, or file paths. RED describes "what fails". GREEN describes "what must be true". Prescriptive content → flag if present. |
| PF-CHECKLIST-FORMAT | All steps use `- [ ] N.` format with sub-bullets | Every step is a numbered checkbox with at least one sub-bullet containing metadata, SC reference, or command |
| PF-DISPATCH-MODE | Every step has valid dispatch mode indicator | Every step title contains a valid dispatch indicator per Load [Dispatch Indicators](skills/writing-plans/tasks/write.md) — exactly one of the three |
| PF-DISPATCH-DEFECTS | Dispatch marking defects detected: (a) missing Dispatch declaration, (b) inline phase with only sub-agent steps, (c) sub-agent-clean-room phase with inline steps | Check plan phase table for `Dispatch` column (split plans) or `**Dispatch:**` field (non-split plans). If missing → FAIL. If `Dispatch: inline` and all steps are sub-agent or clean-room → FAIL. If `Dispatch: sub-agent-clean-room` and any step is inline → FAIL. |
| PF-SUBSTEP-EXPAND | No collapsed multi-operation steps | Every sub-operation from pipeline task files gets its own `- [ ] N.` entry. No step describes more than one atomic action |
| PF-ADMONISHMENT | Compliance admonishment present at top and bottom | Full canonical text blockquote: "rework from scratch and loss of all prior work" — present at both prologue and epilogue |
| PF-GLOBAL-NUMBERING | Steps numbered globally across all phases | No per-phase restart — step N+1 follows step N across phase boundaries |
| PF-ONE-STEP | One-step-at-a-time protocol admonishment present at top of plan | FAIL if missing |
| PF-DELEGATION | Undefined delegation targets | Checks that every "delegate to", "unified", "merged into", or "replaced by" reference in the spec has a corresponding concrete definition in the plan — specific file changes, routing table updates, cross-reference updates, and capability migration. If any delegation reference lacks concrete plan definitions, the criterion FAILs. |
| PF-SEQUENCE-MATCHES | Gate sequence matches pipeline source — missing gates are automatic FAIL with no remediation path | Gate sequence matches Load [implementation-pipeline SKILL.md](skills/implementation-pipeline/SKILL.md) dispatch routing table — read dynamically, not hardcoded. Any missing gate is automatic FAIL — the plan MUST be regenerated, not patched. |
| PF-PIPELINE-COMPLETENESS | All 19 mandatory pipeline stages present in plan | Plan MUST include all of: assemble-work, sc-coherence-gate, pre-red-baseline, red-phase, z3-check-red, red-doublecheck, green-phase, z3-check-green, green-doublecheck, checkpoint-tag-create, checkpoint-commit, green-vbc, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary. Missing any stage → FAIL. |

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

### Step 12.5: Behavioral SC Clean-Room Evaluation

For each behavioral SC identified in the evaluation criteria, dispatch a clean-room sub-agent to evaluate the behavioral evidence independently. The evaluator MUST NOT use file-existence or structural checks as evidence for behavioral SCs.

- [ ] 1. **Identify behavioral SCs** — scan the evaluation criteria for SCs with `behavioral` evidence type. These require clean-room evaluation.
- [ ] 2. **For each behavioral SC**, dispatch `behavioral-sc-evaluator` via `task()` with ONLY the artifact directory path and the SC criterion text:
  - `artifact_path`: `{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/`
  - `sc_criteria`: the behavioral SC text to evaluate against
  - MUST NOT include orchestrator reasoning, expected outcomes, or cached results
- [ ] 3. **Collect result contract** — the clean-room sub-agent returns:
  ```yaml
  status: DONE
  artifact_path: "<artifact directory path>"
  summary: "Evaluated {N} behavioral SCs: {M} PASS, {K} FAIL"
  per_sc:
    - sc_id: "<SC-N>"
      verdict: PASS|FAIL
      justification: "<1-2 sentence explanation based on actual agent output>"
  ```
- [ ] 4. **Apply clean-room verdict** — for each behavioral SC:
  - If clean-room sub-agent returns `PASS` → evaluator verdict for that SC is `PASS`
  - If clean-room sub-agent returns `FAIL` → evaluator verdict for that SC is `FAIL` (overrides any upstream evidence)
  - If clean-room sub-agent returns `BLOCKED` → evaluator verdict for that SC is `FAIL` with `remediation: "Clean-room evaluation blocked — behavioral evidence could not be assessed"`
- [ ] 5. **File-existence is NOT sufficient** — if the only evidence for a behavioral SC is that a file exists (stdout.log, stderr.log, or any artifact), the verdict MUST be `FAIL`. Behavioral SCs require behavioral evidence: the agent must have taken the correct action, not just produced output files.
- [ ] 6. **Log behavioral evaluation** — record the clean-room evaluation results in the verdict YAML under `behavioral_sc_evaluation`:
  ```yaml
  behavioral_sc_evaluation:
    - sc_id: "<SC-N>"
      clean_room_verdict: PASS|FAIL
      justification: "<from clean-room sub-agent>"
  ```

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

### Step 14: Return Frugal Result Contract

```yaml
status: DONE | FAIL | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/plan-fidelity/verdict.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL. Z discrepancies found."
all_criteria_pass: true | false
remediation_required: true | false
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
- `tasks/plan-fidelity.md` — Main task file (orchestrator-level plan-fidelity audit)
- `tasks/cross-validate.md` — Arbiter role (consumes this task's `verdict.yaml`)
- `writing-plans` skill — clean-room plan generation
- Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md) (PF-STRUCTURAL-FAIL uplift), Load [critical-rules-034](guidelines/000-critical-rules.md) (inline work prohibition)
- Load [implementation-pipeline SKILL.md](skills/implementation-pipeline/SKILL.md) — dispatch routing table (PF-SEQUENCE-MATCHES source)
- Load [Contract YAML Structure](skills/solve/tasks/contract.md) (PF-Z3-CONTRACT source)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{project_root}/tmp/{issue-N}/artifacts/{chain}/...` | Path to the output artifact file |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `status` | Yes | `DONE | BLOCKED` | Task completion status |
| `summary` | Yes | `string` | 1-3 sentence summary of findings |

The output artifact MUST be written to `artifact_path` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `artifact_path`. The orchestrator reads only this contract — it does NOT re-read the artifact.
