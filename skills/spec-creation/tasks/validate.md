# Task: validate — Spec verification pipeline

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

Read the full spec from `{spec_path}`.

Read [spec-structure-standards.md](reference/spec-structure-standards.md) and load the required section inventory dynamically. The section list is NOT hardcoded — it is loaded from the reference document.

### Step 2: Run 11-dimension holistic self-check

Evaluate the spec against all 11 holistic dimensions. The 11 dimensions are NOT hardcoded here — they are loaded dynamically from `reference/holistic-dimensions.yaml`, the single source of truth.

Read [holistic-dimensions.yaml](reference/holistic-dimensions.yaml) and load the `spec_dimensions` list. The dimension names, evaluation questions, and checks are taken from that reference document, not from a local list. When a dimension changes, update the reference file — this task always reflects it.

### Step 3: Run structural validation

#### Step 3.1: Format-level conformance checks

Check the spec against format-level rules loaded from spec-structure-standards.md:

- **SHALL language conformance:** Verify normative statements use "SHALL" (mandatory), "SHOULD" (recommendation), "MAY" (optional). Flag "must", "will", "should" (unqualified) as violations.
- **dark-prose-007 conformance:** Verify each SC includes a cost-frame statement explaining failure costs in dark prose authority frame. Flag SCs missing cost-frame language.
- **Documentation Sources conformance:** Verify the SC table includes a Documentation Sources column. Flag missing column or empty entries.

#### Step 3.2: Determinism check

Check each SC for determinism violations. Prohibited patterns (loaded from spec-structure-standards.md):

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

#### Step 3.3: Compound-SC detection

Check each SC for compound structure — an SC that bundles multiple independently verifiable claims:

- **Conjunctions:** "and", "or", "also", "plus" that join distinct verification targets
- **Multiple verification targets:** The SC describes more than one thing to verify (e.g., "X is Y and Z is W")
- **Cross-concern references:** The SC references concerns from different phases or domains

For each compound SC detected, flag as FAIL with the specific compound pattern identified. The spec must decompose compound SCs into individual atomic SCs.

#### Step 3.4: Causal-chain verification

Verify the causal chain between root causes and SCs:

- **Root cause to SC mapping:** For each root cause identified in the spec, verify at least one SC addresses it
- **Orphan detection:** Identify SCs that do not trace to any root cause (orphan SCs) and root causes not addressed by any SC (orphan root causes)
- **Causal sufficiency:** Verify the set of SCs is sufficient to address all identified root causes

Flag any orphan SCs or orphan root causes as FAIL.

#### Step 3.5: Evidence-type-to-method cross-check

Verify each SC's evidence type matches its verification method using the lookup table:

| Evidence Type | Required Verification Method |
|---------------|----------------------------|
| `behavioral` | Test execution (`opencode run`, `pytest`, `bash test.sh`) |
| `semantic` | Sub-agent read + analytical judgment |
| `string` | `grep`, pattern matching |
| `structural` | `ls`, `wc`, file existence |

For each SC, verify:
1. The declared evidence type is one of the four valid types
2. The verification method matches the evidence type per the lookup table
3. The verification method is specific enough to produce a PASS/FAIL verdict

Flag any mismatch as FAIL with `EVIDENCE_TYPE_MISMATCH` classification.

#### Step 3.6: Artifact cross-reference check

Cross-reference the spec against analytical artifacts at `{project_root}/{path}/.issues/{issue_number}/artifacts/`:

- **Blast-radius alignment:** Verify the spec's affected files match the blast-radius artifact
- **Concern-map alignment:** Verify the spec's phases align with concern boundaries from the concern-map artifact
- **Interface-compatibility alignment:** Verify the spec's interface changes match the interface-compatibility artifact
- **Testability-assessment alignment:** Verify the spec's verification methods match the testability-assessment artifact

For each artifact, check:
1. The artifact file exists and is non-empty
2. The spec's claims are consistent with the artifact's findings
3. Any discrepancies are flagged as warnings (not hard FAIL — artifacts may be preliminary)

### Step 4: Produce verdict

Aggregate all dimension and structural check results:

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
