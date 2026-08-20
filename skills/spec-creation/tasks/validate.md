# Task: validate

## Category

VERIFICATION

## Purpose

Run the 11-dimension holistic self-check and structural validation (SC completeness, evidence types, traceability) on a completed spec. Produce PASS/FAIL verdict per check. This task does NOT perform analysis steps or production steps.

## Entry Criteria

- [ ] `issue_number` and `spec_path` received in dispatch context
- [ ] No producer context, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Spec file exists at `{spec_path}`
- [ ] Analytical artifacts directory exists at `{project_root}/{path}/.issues/{issue_number}/artifacts/` (or warning logged if not)

## Procedure

### Step 1: Read spec and reference documents

- [ ] 1.1. Read the full spec from `{spec_path}`.

- [ ] 1.2. Read [spec-structure-standards.md](reference/spec-structure-standards.md) and load the required section inventory dynamically. The section list is NOT hardcoded — it is loaded from the reference document.

### Step 2: Run 11-dimension holistic self-check

- [ ] 2.1. Evaluate the spec against all 11 holistic dimensions. The 11 dimensions are NOT hardcoded here — they are loaded dynamically from `reference/holistic-dimensions.yaml`, the single source of truth.

- [ ] 2.2. Read [holistic-dimensions.yaml](reference/holistic-dimensions.yaml) and load the `spec_dimensions` list. The dimension names, evaluation questions, and checks are taken from that reference document, not from a local list. When a dimension changes, update the reference file — this task always reflects it.

### Step 3: Run structural validation

- [ ] 3.1. **Format-level conformance checks** — Check the spec against format-level rules loaded from spec-structure-standards.md:

  - **SHALL language conformance:** Verify normative statements use "SHALL" (mandatory), "SHOULD" (recommendation), "MAY" (optional). Flag "must", "will", "should" (unqualified) as violations.
  - **dark-prose-007 conformance:** Verify each SC includes a cost-frame statement explaining failure costs in dark prose authority frame. Flag SCs missing cost-frame language.
  - **Documentation Sources conformance:** Verify the SC table includes a Documentation Sources column. Flag missing column or empty entries.

- [ ] 3.2. **Determinism check** — Check each SC for determinism violations. Prohibited patterns (loaded from spec-structure-standards.md):

  - Adverbs without thresholds: "quickly", "efficiently", "properly"
  - Comparatives without baselines: "better", "faster", "more readable"
  - Open-ended quality terms: "good", "clean", "well-structured"
  - Missing expected values: "should match" without specifying what
  - Implicit behavior: "should work correctly" without defining "correctly"
  - Either/or ambiguity: "or", "either", "alternatively" in Required Actions
  - Hedging language: "should", "may", "preferably", "ideally", "if possible", "as appropriate", "as needed", "consider", "optionally", "if desired", "TBD", "TODO", "to be determined", "use best judgment", "if time permits", "implementor's discretion"
  - Escape hatches: "or similar", "or equivalent", "and/or", "etc.", "and so on"
  - Ambiguity markers: vague references without clear targets, unspecified thresholds, undefined terms

  For each SC, record which prohibited patterns are present. Flag any SC with ≥1 prohibited pattern as FAIL.

- [ ] 3.3. **Compound-SC detection** — Check each SC for compound structure — an SC that bundles multiple independently verifiable claims:

  - **Conjunctions:** "and", "or", "also", "plus" that join distinct verification targets
  - **Multiple verification targets:** The SC describes more than one thing to verify (e.g., "X is Y and Z is W")
  - **Cross-concern references:** The SC references concerns from different phases or domains

  For each compound SC detected, flag as FAIL with the specific compound pattern identified. The spec must decompose compound SCs into individual atomic SCs.

- [ ] 3.4. **Causal-chain verification** — Verify the causal chain between root causes and SCs:

  - **Root cause to SC mapping:** For each root cause identified in the spec, verify at least one SC addresses it
  - **Orphan detection:** Identify SCs that do not trace to any root cause (orphan SCs) and root causes not addressed by any SC (orphan root causes)
  - **Causal sufficiency:** Verify the set of SCs is sufficient to address all identified root causes

  Flag any orphan SCs or orphan root causes as FAIL.

- [ ] 3.5. **Evidence-type-to-method cross-check** — Verify each SC's evidence type matches its verification method. The evidence-type taxonomy is NOT hardcoded here — it is loaded dynamically from the single canonical reference.

  Read [cost-model-standards.md](reference/cost-model-standards.md) and load the evidence-type taxonomy (the "Tiered Cost Table by Evidence Type" section lists the four valid types). When the canonical taxonomy changes, update the reference file — this task always reflects it.

  For each SC, verify:
- [ ] 1. The declared evidence type is one of the valid types in the canonical reference
- [ ] 2. The verification method matches the evidence type per the canonical reference
- [ ] 3. The verification method is specific enough to produce a PASS/FAIL verdict

  Flag any mismatch as FAIL with `EVIDENCE_TYPE_MISMATCH` classification.

- [ ] 3.6. **Artifact cross-reference check** — Cross-reference the spec against analytical artifacts at `{project_root}/{path}/.issues/{issue_number}/artifacts/`:

  - **Blast-radius alignment:** Verify the spec's affected files match the blast-radius artifact
  - **Concern-map alignment:** Verify the spec's phases align with concern boundaries from the concern-map artifact
  - **Interface-compatibility alignment:** Verify the spec's interface changes match the interface-compatibility artifact
  - **Testability-assessment alignment:** Verify the spec's verification methods match the testability-assessment artifact

  For each artifact, check:
- [ ] 1. The artifact file exists and is non-empty
- [ ] 2. The spec's claims are consistent with the artifact's findings
- [ ] 3. Any discrepancies are flagged as warnings (not hard FAIL — artifacts may be preliminary)

- [ ] 3.7. **Decomposition Criteria** — Check each SC against the 6 spec-level decomposition criteria. This is a distinct checklist from Step 3.3 Compound-SC detection, which is retained for its own purpose.

  **Skip condition:** If the spec has exactly **1 SC** AND **1 affected file**, skip this check entirely (not evaluated) and mark it PASS. The skip-guard requires BOTH conditions — a spec with 1 SC but more than 1 affected file is evaluated.

  See audit/reference/decomposition-criteria.md for master definition. Inline copy mirrors the criteria content, not the master reference's numbered heading format. Maintain in lockstep with the master reference per its maintainer note.

### Atomicity

```
Is the SC a single, indivisible concern?
├── YES → Is it free of coordinating conjunctions (and, or) and comma-separated lists?
│   ├── YES → PASS — SC is atomic
│   └── NO → FAIL — SC contains trigger words indicating multiple concerns
└── NO → FAIL — SC bundles multiple concerns
```

**Trigger-word sub-check:** Flag any SC containing `and` (coordinating conjunction joining two requirements), `or` (disjunctive alternative), or comma-separated lists (enumerating multiple items as one SC) as FAIL.

### Single Deliverable

```
Does the SC produce exactly one deliverable?
├── YES → Is the deliverable a single file, function, or configuration change?
│   ├── YES → PASS — SC has a single deliverable
│   └── NO → FAIL — SC spans multiple deliverables
└── NO → FAIL — SC produces zero or multiple deliverables
```

### Binary Verifiability

```
Can the SC be verified as PASS or FAIL with no interpretation?
├── YES → Is the SC free of disjunctive patterns (either/or, alternatively, one of)?
│   ├── YES → Is the SC free of vague terms (should, could, ideally, as appropriate)?
│   │   ├── YES → PASS — SC is binary-verifiable
│   │   └── NO → FAIL — SC contains vague terms
│   └── NO → FAIL — SC contains disjunctive patterns
└── NO → FAIL — SC requires interpretation to verify
```

**Disjunctive-pattern sub-check:** Flag any SC containing `either/or` (presents two alternatives as one SC), `alternatively` (suggests a second path), or `one of` (selects from multiple options) as FAIL.

**Vague-term sub-check:** Flag any SC containing `should` (aspirational), `could` (optional), `ideally` (preference), or `as appropriate` (subjective judgment required) as FAIL.

### PR-Gate Viability

```
Can the SC be delivered as a single, independently reviewable PR?
├── YES → Does the SC represent a single RED/GREEN cycle?
│   ├── YES → PASS — SC is PR-gate viable
│   └── NO → FAIL — SC spans multiple RED/GREEN cycles
└── NO → FAIL — SC requires unreviewed dependencies
```

**Meta RED/GREEN principle:** Each spec is a **RED** — it defines what must be true. Each PR merge is a **GREEN** — it makes that truth permanent. An SC that requires multiple PR merges to satisfy is not PR-gate viable and SHALL be decomposed into sub-SCs, each with its own RED/GREEN cycle.

### Ceremony

```
Does the SC add any verification signal over the union of prior SCs?
├── YES → PASS — SC adds a new verification signal
└── NO → FAIL — SC is ceremony (same deliverable + same verification method, no new requirement)
```

**Scope of comparison:** Computed as set-entailment over **prior SCs** only — the union of the deliverables and verification methods of all SCs that precede it in the spec. The Problem Statement / intent prose universe is OUT OF SCOPE because Binary Verifiability forbids interpretation-dependent verdicts.

### Coverage / Covered-by-Prior

```
Is the SC's requirement set already entailed by a prior SC?
├── NO → PASS — SC adds a requirement not entailed by any prior SC
└── YES → FAIL — SC is covered by a prior SC (requirement set already entailed)
```

**Scope of comparison:** Computed as set-entailment over **prior SCs** only — the requirement set of each prior SC in the spec. The Problem Statement / intent prose universe is OUT OF SCOPE because Binary Verifiability forbids interpretation-dependent verdicts.

### Step 4: Produce verdict

- [ ] 4.1. Aggregate all dimension and structural check results:

  - **PASS** — All checks pass
  - **FAIL** — One or more checks fail (include which checks failed and why)

## Exit Criteria

- [ ] All 11 holistic dimensions evaluated with PASS/FAIL per dimension
- [ ] Structural validation complete
- [ ] Aggregate verdict produced
- [ ] No spec content written, no analysis performed, no remote issue operations

## Result Contract

```yaml
status: DONE | BLOCKED
verdicts:
  - check_name: "completeness"
    result: PASS | FAIL
    justification: "Brief explanation"
  - check_name: "clarity"
    result: PASS | FAIL
    justification: "Brief explanation"
  # ... all 11 dimensions + structural checks
aggregate_verdict: PASS | FAIL
finding_summary: "Summary of all check results, key failures if any"
blocker_reason: "If BLOCKED: why validation could not complete"
```
