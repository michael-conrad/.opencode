# Task: testability-assessment

## Purpose

Verify that every success criterion is testable with available tooling before the spec is finalized. For each SC, classify the evidence type, verify the required verification method is available in the current environment, and flag SCs that require unavailable tooling.

## Entry Criteria

- Requirements extraction completed
- Decomposition completed (units identified)
- Code path analysis completed (paths known)
- (Recommended) Pipeline readiness gate completed

## Exit Criteria

- Every SC classified by evidence type
- Verification method availability confirmed for each SC
- SCs requiring unavailable tooling flagged
- Testability assessment artifact produced
- No SC is finalized with unverifiable testability

## Procedure

### Step 1: Classify Each SC by Evidence Type

For every SC in the spec, classify the evidence type required to verify it:

| Evidence Type | Method | Verifies | Example SC |
|---------------|--------|----------|------------|
| **behavioral** | Test execution (opencode-cli run, pytest, bash test.sh) | Agent behavior, runtime output, functional correctness | "Agent dispatches sub-agents, no inline work" |
| **semantic** | AI agent read + analytical judgment | Intent and meaning, not just pattern | "SKILL.md routes only to Trigger Dispatch Table" |
| **string** | grep, pattern matching | Content pattern present or absent | "requirements.md includes adversarial verification" |
| **structural** | ls, wc, file existence | File exists, file is non-empty, file has correct name | "blast-radius.md exists" |

### Step 2: Verify Verification Method Availability

For each SC, verify that the required verification method is available in the current environment:

| Evidence Type | Required Tooling | Availability Check |
|---------------|-----------------|-------------------|
| **behavioral** | opencode-cli, test models, test home isolation | Check opencode-cli is installed, check model availability via opencode-cli models, check with-test-home wrapper exists |
| **semantic** | AI agent with read access | Check that a sub-agent can be dispatched with read access to the deliverable |
| **string** | grep, file read | Always available |
| **structural** | ls, file existence check | Always available |

For each SC, document:

- **Evidence type:** The classified evidence type
- **Required tooling:** What tools or infrastructure are needed
- **Availability:** Available / Unavailable / Unknown
- **Availability evidence:** How availability was verified (tool call, command output, environment check)

### Step 3: Flag Unverifiable SCs

Any SC whose required verification method is unavailable must be flagged:

- **Unavailable behavioral tooling:** SC cannot be behaviorally verified. Options: downgrade evidence type (with justification), defer to later phase, or block spec finalization.
- **Unavailable semantic tooling:** SC cannot be semantically verified. Options: downgrade to string evidence (with justification), or block spec finalization.
- **Unknown availability:** SC verification method availability is unknown. Must investigate before finalizing.

Flagged SCs must include:

- **SC ID and description**
- **Required evidence type**
- **Unavailable tooling**
- **Recommended action:** Downgrade, defer, or block

### Step 4: Produce Testability Assessment Artifact

Create a structured artifact containing:

- **SC testability table:** Every SC with evidence type, required tooling, availability, and availability evidence
- **Flagged SCs:** SCs with unavailable or unknown verification methods
- **Recommendations:** For each flagged SC, the recommended action
- **Overall verdict:** All SCs testable / Some SCs require attention / Spec cannot be finalized

### Step 5: Verify Coverage

Cross-reference the testability assessment against the spec's SC table. Verify that:

- Every SC in the spec has a testability assessment entry
- Every SC's evidence type is correctly classified
- Every SC's verification method availability is verified
- No SC is missing from the assessment

## Content Coverage

Does the testability assessment cover:

- Every SC classified by evidence type?
- Verification method availability verified for each SC?
- Unavailable tooling flagged with recommended action?
- Coverage verification against the SC table?
- Overall testability verdict?

**Any format that communicates these concerns clearly is acceptable.** An SC testability table with evidence type, availability, and verdict columns works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `requirements`, `decompose`, `code-path-analysis`
- Feeds into: `risk`, `write`
