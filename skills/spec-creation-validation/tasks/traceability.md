# Task: traceability

## Purpose

Map every requirement to spec section, test, and implementation step. Ensure nothing is lost between requirements and implementation.

## Entry Criteria

- Requirements extraction completed
- (Optional) Decomposition completed

## Exit Criteria

- Every requirement maps to at least one spec section
- Every spec section maps to at least one requirement
- Test scenarios identified for each requirement
- Implementation steps traceable to requirements
- Every SC has a phase binding — no orphan SCs (SC-32)

## Procedure

### Step 1: Build Traceability

Map each requirement to:
- Which spec section covers it
- What test scenario validates it
- Which implementation step implements it

### Step 2: Verify Bidirectional Coverage

- **Forward:** Every requirement → spec section (nothing lost)
- **Backward:** Every spec section → requirement (no scope creep)
- **Test coverage:** Every requirement → at least one test scenario
- **Implementation coverage:** Every requirement → at least one implementation step

### Step 3: Identify Gaps

- Requirements without spec sections (lost requirements)
- Spec sections without requirements (scope creep)
- Requirements without test scenarios (untestable)
- Requirements without implementation steps (orphan)

### Step 4: Verify SC-to-Phase Binding (SC-32 — MANDATORY for multi-phase specs)

For multi-phase specs, verify every SC has a phase binding:

- [ ] 1. Extract all SC IDs from the spec's SC table
- [ ] 1. Extract all phase names from the spec's Phase section
- [ ] 1. For each SC, verify it has a `Phase Binding` column value that matches a phase name in the Phase section
- [ ] 1. Cross-cutting SCs (apply across all phases) MUST be designated as `common` in the Phase Binding column
- [ ] 1. Any SC without a valid phase binding → MISSING-TRACEABILITY finding
- [ ] 1. Any phase with zero SCs assigned → STRUCTURE-VIOLATION finding (orphan phase)

**Single-task exemption:** Specs with exactly one phase are exempt from Step 4 — all SCs implicitly bind to the single phase.

## Content Coverage

Can each requirement be traced to a spec section, test scenario, and implementation step? Does the traceability provide bidirectional coverage?

- **Forward traceability:** Every requirement → spec section and test
- **Backward traceability:** Every spec section → requirement

**Any format that provides this coverage is acceptable.** A formal traceability matrix table works well for complex specs. A prose list or inline references work well for simple specs. The agent chooses the format that best serves the spec.

## Adversarial Verification of Trace Targets (MANDATORY)

**🚫 CRITICAL: Every trace target (referenced issue, spec, code symbol) MUST be verified to actually exist. Unverified trace references are MISSING-TRACEABILITY findings per `065-verification-honesty.md`.**

### Verification Procedure

After building traceability (Step 1-3), verify every referenced target:

| Trace Target Type | Verification Action | Tool Call | Problem Class |
|-------------------|-------------------|-----------|---------------|
| Referenced GitHub Issue | Verify the issue exists and is accessible | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → confirm `title` is not "404" | MISSING-TRACEABILITY | <!-- Routes through issue-operations per SPEC #683 -->
| Referenced spec (by issue number) | Verify the spec Issue exists with proper prefix and labels | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → check title starts with `[SPEC]` | MISSING-TRACEABILITY | <!-- Routes through issue-operations per SPEC #683 -->
| Referenced code symbol | Verify the symbol exists in the current codebase | `srclight_get_symbol(name="symbol_name")` → confirm non-empty result | VERIFICATION-GAP |
| Referenced file path | Verify the file exists at the claimed path | `glob(pattern="**/filepath")` → confirm match | VERIFICATION-GAP |
| Bidirectional coverage | Verify every requirement maps to a section AND every section maps to a requirement | Cross-reference requirement list with section anchors | MISSING-TRACEABILITY |

### Evidence Format

```
Check: [what was verified]
Tool: [tool call and parameters]
Result: [actual state found]
Classification: [STRUCTURE-VIOLATION|MISSING-ELEMENT|CONFLICTING|VERIFICATION-GAP|MISSING-TRACEABILITY]
Action: [auto-fix|FAIL]
```

### Classification on Failure

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Referenced issue does not exist | MISSING-TRACEABILITY | auto-fix | Remove or replace the broken reference |
| Referenced spec lacks [SPEC] prefix | MISSING-TRACEABILITY | FAIL | Verify it IS a spec; add prefix or fix reference |
| Referenced code symbol not found | VERIFICATION-GAP | FAIL | May be renamed/removed; verify alternate names |
| Referenced file path not found | VERIFICATION-GAP | FAIL | May be reorganized; search for file |
| Requirement with no section mapping | MISSING-TRACEABILITY | auto-fix | Add section mapping |
| Section with no requirement mapping | STRUCTURE-VIOLATION | FAIL | Possible scope creep; report for domain review |

**These verifications are MANDATORY. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

## Code-Path-to-Test Mapping (MANDATORY)

**For each identified code path affected by the spec, verify at least one SC exercises it. An untested code path is a defect waiting to surface.**

### Step 5: Identify Affected Code Paths

From the requirements and decomposition, enumerate every code path that the spec changes or touches:

| Code Path | File(s) | Entry Point | Exit Point | SC Coverage |
|---|---|---|---|---|
| User validation flow | `src/auth/validator.py` | `validate_user()` | return or raise | SC-3, SC-4 |
| Config file parsing | `src/config/loader.py` | `load_config()` | return config dict | SC-7 |
| Data export pipeline | `src/export/csv_writer.py` | `write_csv()` | file written or error | SC-12 |

### Step 6: Verify SC Coverage per Code Path

For each identified code path, verify:

- [ ] At least one SC exercises the happy path (normal operation)
- [ ] At least one SC exercises the primary error path (expected failure mode)
- [ ] At least one SC exercises each boundary condition (empty input, max input, concurrent access)
- [ ] No code path has zero SC coverage

### Step 6a: Gap Remediation

If a code path has zero SC coverage:

1. Determine whether the path is in scope (part of the spec's intended changes)
2. If in scope: add a new SC that exercises that path, with appropriate evidence type
3. If out of scope: document why the path is excluded (non-requirement with boundary marker)
4. If the path is pre-existing and unchanged by the spec: no SC needed, but document as "pre-existing, unchanged"

### Evidence Format

```
Check: [code path description]
Tool: [srclight_get_callers, srclight_get_symbol, or file read]
Result: [SC coverage found or gap identified]
Classification: [COVERED|GAP-IDENTIFIED|PRE-EXISTING-UNCHANGED]
Action: [proceed|add-SC|document-exclusion]
```

## Context Required

- Preceded by: `requirements`, optionally `decompose`
- Feeds into: `write`
- Note: Creation-time traceability is enforced here. `spec-auditor` verifies traceability as a second pass.

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/traceability.yaml" |
| blocker_reason | "..." |