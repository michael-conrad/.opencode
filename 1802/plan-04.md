# Phase 4: Auto-Detect Test-Type Annotations from Infrastructure Usage

## Purpose

Implement auto-detection of test-type annotations from test infrastructure usage patterns, so that the VbC table's Result column automatically includes the correct annotation without manual specification.

## SC Coverage

| SC ID | Criterion | Evidence Type |
|-------|-----------|---------------|
| SC-3 | Test-type annotations auto-detected from test infrastructure usage patterns | behavioral |

## Red Checkpoint

- **RED checkpoint:** Test-type annotations are NOT auto-detected → failure condition: SC-3 not satisfied
- **Failure condition:** Detection logic missing in `collect.md`, annotation absent from evaluation output, or VbC table artifact lacks annotations

## Steps

### Step 8: Define Test-Type Detection Logic

**File:** `.opencode/skills/verification-before-completion/tasks/collect.md`

Add a new section defining the test-type detection logic.

**Changes:**
- Add a detection table mapping infrastructure patterns to annotations:

| Pattern | Annotation | Detection Method |
|---------|-----------|-----------------|
| `testcontainers` fixture, `postgres_container`, real DB instance | `(live DB)` | grep for testcontainers imports/fixtures |
| No fixtures, no mocks, no external dependencies | `(unit)` | Check for absence of mock/testcontainers imports |
| `unittest.mock`, `pytest-mock`, `mock.patch`, `MagicMock` | `(mock)` | grep for mock imports/decorators |
| `requests`, `httpx`, `docker`, filesystem I/O, network calls | `(integration)` | grep for network/filesystem imports |

- Add a detection procedure: read the test file, scan for infrastructure patterns, classify the test type
- Add a fallback: if no pattern matches, default to `(unit)`

**Dispatch:** `sub-agent` via `task()`

### Step 9: Integrate Detection into Behavioral Test Evaluation

**File:** `.opencode/skills/verification-before-completion/tasks/behavioral-test-evaluation.md`

Modify the evaluation task to run test-type detection and include the annotation in its output.

**Changes:**
- After running the behavioral test, read the test source file
- Apply the detection logic from Step 8
- Include the detected annotation in the evaluation result
- The annotation is appended to the PASS/FAIL result: `✅ PASS (live DB)`

**Dispatch:** `sub-agent` via `task()`

### Step 10: Update VbC Table Artifact to Include Annotations

**File:** `.opencode/skills/verification-before-completion/tasks/verify.md`

Ensure the VbC table artifact writing step (from Phase 1) includes the auto-detected annotations.

**Changes:**
- The VbC table artifact MUST include the annotation in the Result column
- The annotation is sourced from the behavioral test evaluation output
- If no annotation is available, default to `(unit)`

**Dispatch:** `sub-agent` via `task()`

## Phase Completion Block

- [ ] All 3 steps complete
- [ ] Test-type detection logic defined and documented
- [ ] Detection integrated into behavioral test evaluation
- [ ] VbC table artifact includes auto-detected annotations
- [ ] Phase checkpoint tag created
