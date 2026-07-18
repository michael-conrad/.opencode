# [SPEC] Inline cf. form with resolution table and admonition — systematic comparison against Agent Skills spec inline link form

> **Sibling spec to #1958.** This spec and #1958 address the same cross-reference pattern problem from different angles. If this spec's tests validate the cf. form, #1958 becomes moot. If this spec's tests fail, #1958's approach remains the primary path. The two specs are independent in execution — neither blocks the other.

## Problem

The Agent Skills specification (agentskills.io/specification) defines the file reference pattern as direct inline links: `See [the reference guide](references/REFERENCE.md)`. However, the agent reads the entire SKILL.md in one atomic pass — it cannot pause mid-document to follow a link. The link passes by as text during the first pass, and there is no structural signal at the end of the document to trigger a fetch.

An alternative pattern is proposed: inline named refs using `§Name` in the body, a resolution table at the end of the document mapping each named ref to its file path with a link, and an admonition immediately after the table instructing the agent to read all linked documents.

A systematic comparison is needed to determine which form more reliably causes the agent to access referenced files.

### Key Fact

The agent always reads the entire document in one atomic pass before it can request linked documents. There is no mid-read pause to fetch a file. This is a descriptive fact about the agent's reading model, not a normative rule. It has a direct impact on how cross-reference patterns must be designed — the inline form must carry enough contextual signal during the first pass that the agent knows a reference exists, and the end-of-document structure must trigger the fetch.

**This fact must be noted in #1958 as an additional consideration:** whatever document contains the refs, the entire document is always read before the agent can request linked documents be included. This affects wording and understanding of how the pieces fit together.

## Goals

1. Compare Form A (inline link) vs Form B (symbol-only + table + admonition) vs Form C (explicit verb + table + admonition) on file access rate
2. Determine which inline ref variant within Form B (bare `§Name`, bracketed `[§Name]`, conditional `§Name when condition`) produces the highest file access rate
3. Test whether the pattern survives the orchestrator→sub-agent handoff (Tier 2)
4. Produce a recommendation for the winning form with supporting evidence

## Non-Goals

- Not testing non-reference forms (declarative, passive voice)
- Not testing the effectiveness of the cross-reference pattern itself (only the forms)
- Not testing Form C verb variants at variant level — Form C's 3 verb forms ("Read §X", "Refer to §X", "Use §X when...") are tested as a single Form C cell, not individually. Only Form B has variant-level testing (B1, B2, B3)
- Not implementing the winning form in guidelines — that is a follow-up implementation spec

## Scope

- 3 forms tested: Form A (Agent Skills inline link), Form B (symbol-only refs + table + admonition), Form C (explicit verb + symbol + table + admonition)
- 3 inline ref variants within Form B: bare `§Name`, bracketed `[§Name]`, and conditional `§Name when condition`
- 4 fixture types: Configuration values, Rules/policy, Procedure steps, Validation criteria
- 2 tiers: Tier 1 (orchestrator level), Tier 2 (clean-room sub-agent level)
- 3 runs per cell (a "cell" = one form+fixture combination; e.g., Form A + Fixture A = 1 cell with 3 runs)
- Per fixture: 5 cells (Form A, Form B1, Form B2, Form B3, Form C) × 3 runs = 15 runs per fixture
- Default model: ollama/qwen3.6:35b-256k
- No model fallback — Ollama is a system service required by the test framework. If the default model is unavailable, it is an infrastructure failure, not a test-configuration problem. Do not attempt to select an alternative model.

## Forms

### Form A — Agent Skills Spec Inline Link (Current Standard)

```
See [the reference guide](references/REFERENCE.md) for details.
```

The link is inline in the body. No table at end. No admonition.

### Form B — Symbol-Only Refs + Table + Admonition

**Body text:** `Use the timeout from §TimeoutConfig.`

**End of document:**

| Reference | File |
|-----------|------|
| §TimeoutConfig | [references/TimeoutConfig.md](references/TimeoutConfig.md) |

> **Read all linked documents before proceeding.**

**Variants:**
- B1: Bare `§Name` (e.g., `§TimeoutConfig`)
- B2: Bracketed `[§Name]` (e.g., `[§TimeoutConfig]`)
- B3: Conditional `§Name when condition` (e.g., `§TimeoutConfig when configuring the timeout`)

### Form C — Explicit Verb + Symbol + Table + Admonition

**Body text:** `Read §TimeoutConfig`, `Refer to §TimeoutConfig`, or `Use §TimeoutConfig when configuring the timeout`.

**End of document:** Same table and admonition as Form B.

## Fixture Types

### Fixture A — Configuration Values
SKILL.md says: "Run `sleep` in the bash shell. Use the timeout from §TimeoutConfig."
Referenced file: `timeout=30`
The agent needs the value to execute the command correctly.

### Fixture B — Rules/Policy
SKILL.md says: "Name resources per §NamingPolicy."
Referenced file: naming convention rules.
The agent needs the rules to name resources correctly.

### Fixture C — Procedure Steps
SKILL.md says: "Handle errors per §ErrorHandling."
Referenced file: error handling procedure steps.
The agent needs the steps to handle errors correctly.

### Fixture D — Validation Criteria
SKILL.md says: "Verify output against §ValidationSpec."
Referenced file: validation criteria.
The agent needs the criteria to verify output correctly.

Each fixture includes both relevant and irrelevant referenced files. Accessing irrelevant files is a neutral signal (not penalized, not rewarded) — the measurement tracks whether the relevant file was accessed, not whether irrelevant files were avoided.

## Test Tiers

### Tier 1 — Orchestrator Level
The orchestrator reads a SKILL.md with references (Form A, B, or C). The SKILL.md references multiple files — some relevant to the task, some irrelevant. Success = the orchestrator accesses the referenced files after the atomic read.

All 4 fixtures × 3 forms × 3 runs = 36 runs.

### Tier 2 — Sub-Agent Level (Clean Room)
The orchestrator dispatches a clean-room sub-agent to read a task card. The task card itself contains similar relevant and non-relevant linked documents (using the same form). The sub-agent reads the task card atomically, then must access the referenced files. This tests whether the pattern survives the handoff — the sub-agent has no prior context, just the task card.

Best 2 fixtures (selected after Tier 1 results) × 3 forms × 3 runs = 18 runs.

**Fixture selection criteria for Tier 2:** The 2 fixtures with the widest spread in file access rates between forms (most discriminating) are selected. If spread is tied, select the fixtures most representative of real-world SKILL.md usage (Procedure Steps > Configuration Values > Rules/Policy > Validation Criteria).

## Success Criteria

| ID | Criterion | Evidence Type | PASS Threshold | Verification Method |
|----|-----------|---------------|----------------|---------------------|
| SC-0 | Form A (inline link) establishes a baseline file access rate | behavioral | Form A achieves ≥40% access rate across all fixtures (≥6 of 15 runs per fixture × 4 fixtures = ≥24 of 60 total) | Test execution via opencode run; stderr inspection for file read tool calls |
| SC-1 | Form B or C achieves ≥80% file access rate across all runs in at least one fixture | behavioral | ≥80% access rate (≥12 of 15 runs for 1 fixture: 5 cells × 3 runs) | Test execution via opencode run; stderr inspection for file read tool calls |
| SC-2 | Form B or C outperforms Form A by ≥20 percentage points in file access rate on the same fixture | behavioral | ≥20pp advantage over Form A on at least 1 fixture | Test execution; compare access rates per fixture |
| SC-3 | At least one Form B variant (B1, B2, B3) achieves ≥70% file access rate | behavioral | ≥70% access rate (≥9 of 12 runs for 1 variant × 4 fixtures × 3 runs) | Test execution; per-variant access rate |
| SC-4 | The winning form's file access rate survives Tier 2 (sub-agent handoff) within 1 run of Tier 1 rate | behavioral | Tier 2 rate within 1 run (absolute difference ≤1) of Tier 1 rate for same form+fixture; with 3 runs per cell, this means Tier 2 rate is 2/3 or 3/3 when Tier 1 was 3/3 | Test execution at Tier 2; compare to Tier 1 baseline |
| SC-5 | All measurements (File access, Read selection, Read depth, Time) are recorded for every run | structural | Every run has a complete measurement record | File existence check on measurement logs |

## Measurements

| Measurement | Evidence Type | Description | Threshold |
|-------------|---------------|-------------|-----------|
| File access | behavioral | Did the agent access the referenced file(s)? (any tool: read, grep, bash, etc.) | Binary (yes/no) per run |
| Read selection | behavioral | Which files were accessed: relevant only, irrelevant only, or both? | Categorical (relevant/irrelevant/both) |
| Read depth | behavioral | Full read (entire file) vs partial read (first N lines, grep, search) | Categorical (full/partial) |
| Time | behavioral | Time to complete | Descriptive only; ≥30s difference between forms flagged as notable |

## Test Fixtures Required

- 3 SKILL.md files per fixture (Form A, Form B, Form C) — 12 total
- 3 task card files per fixture for Tier 2 (Form A, Form B, Form C) — up to 12 total
- Referenced files (relevant + irrelevant per fixture)
- Test harness to run each form and record measurements

## Approach

1. Create test fixtures (SKILL.md files, task cards, referenced files)
2. Run Tier 1: all 4 fixtures × 3 forms × 3 runs
3. Analyze Tier 1 results: compute file access rate per form per fixture. Select best 2 fixtures for Tier 2 using the fixture selection criteria (widest spread between forms; tiebreak by real-world representativeness)
4. Run Tier 2: best 2 fixtures × 3 forms × 3 runs
5. Produce structured comparison table with per-form, per-fixture, per-variant access rates
6. Identify winning form: the form with the highest mean file access rate across all fixtures and tiers. Ties broken by read depth (full reads preferred over partial). If still tied, by time (faster wins).

## Impact

- Risk: Model behavior may vary across runs — each variant tested 3 times minimum to mitigate
- Risk: Test fixtures may need refinement — documented if so
- Key dependency: Working opencode CLI with ollama/qwen3.6:35b-256k model. Ollama is a system service required by the test framework — if the model is unavailable, it is an infrastructure failure. Do not attempt model fallback.
- Call to action: Review and approve this spec to begin systematic testing
