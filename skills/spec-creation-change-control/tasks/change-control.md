# Task: change-control

## Purpose

Version the spec, document rationale and impact analysis for changes. Enforce change discipline for spec revisions.

## Entry Criteria

- Spec written and approved (initial version), OR
- Spec revision needed after audit or feedback

## Exit Criteria

- Spec version incremented
- Rationale documented for each change
- Impact analysis completed
- STATUS updated to `REVISED - NEEDS APPROVAL`
- **When revision was triggered by spec-audit FAILs:** All prior audit FAILs resolved to PASS

## Procedure

### Step 1: Identify Changes

Document each change:
- What changed (section, requirement, criterion)
- Why it changed (audit finding, user feedback, scope adjustment)
- Impact (what other sections are affected)

### Step 2: Version the Spec

- Increment version number: `STATUS: 1.0` → `STATUS: 1.1 (REVISED - NEEDS APPROVAL)`
- Add `needs-approval` label to the GitHub Issue
- Post chat output with prose revision summary (per `issue-operations` skill → `comment` task)
- Post Issue comment with prose revision summary

### Step 3: Impact Analysis

For each change, document:
- Which requirements are affected
- Which success criteria need updating
- Which traceability mappings changed
- Whether the change requires re-audit

### Step 3.5: Mandatory Re-Audit (Audit-Triggered Revisions Only)

**When the revision was triggered by spec-audit FAILs**, the change-control task MUST note that a re-audit is required. The SKILL.md pipeline handles spec-audit as an inline orchestrator step — this sub-agent does not call it.

**When the revision was NOT triggered by spec-audit FAILs** (user feedback, scope adjustments, etc.), skip this step — re-audit is not required.

### Step 4: HALT

After revision, the spec needs fresh authorization:
- Do NOT proceed to implementation
- Wait for explicit `approved` or `go`

## Adversarial Verification of STATUS Exemption (MANDATORY)

**🚫 CRITICAL: Every STATUS marker claiming exemption from change control MUST be verified against actual revision history. Unverified exemption claims are CONFLICTING findings per Load [065-verification-honesty.md](guidelines/065-verification-honesty.md).**

### Verification Procedure

After Step 1 (Identify Changes) and Step 2 (Version the Spec), verify any STATUS exemption claims:

| Exemption Claim | Verification Action | Tool Call | Problem Class |
|----------------|-------------------|-----------|---------------|
| "Initial spec creation" (no version increment) | Verify the spec has no prior versions — check Issue body for `STATUS: 1.0` or version history | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → search body for `STATUS:` markers | CONFLICTING | <!-- Routes through issue-operations per SPEC #683 -->
| "Non-substantive change" (typos, cross-refs) | Verify the change is truly non-substantive — no scope, requirements, or success criteria changes | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → compare current vs previous body content | CONFLICTING | <!-- Routes through issue-operations per SPEC #683 -->
| "STATUS marker update" (checkbox, phase number) | Verify the change is only a STATUS marker toggle — no content change | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → diff body against comment history | STRUCTURE-VIOLATION | <!-- Routes through issue-operations per SPEC #683 -->
| "Bug report addition" (separate from spec content) | Verify the added content is a bug report section, not a spec content change | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → check section added | VERIFICATION-GAP | <!-- Routes through issue-operations per SPEC #683 -->

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
| Claims "initial creation" but `STATUS: 1.0` exists | CONFLICTING | auto-fix | Increment version, apply change control |
| Claims "non-substantive" but content changed | CONFLICTING | FAIL | HALT — requires domain review |
| Claims "STATUS update" but content also changed | STRUCTURE-VIOLATION | auto-fix | Apply full change control to content change |
| Claims "bug report" but adds spec requirements | VERIFICATION-GAP | FAIL | Verify scope; if requirements changed, apply change control |

**These verifications are MANDATORY for any STATUS exemption claim. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

## Code-Level Backward Compatibility Impact Analysis (MANDATORY)

When a spec changes an API signature, config key, or data format, assess what existing consumers would break. This is the spec-level counterpart to the backward compatibility analysis in Load [risk.md](skills/spec-creation-validation/tasks/risk.md) — it operates at the code level rather than the architecture level.

### Step 5: Identify Changed Code Contracts

From the spec's requirements and decomposition, enumerate every code-level contract that changes:

| Contract Type | What Changed | Old Form | New Form | Consumer Search Method |
|---|---|---|---|---|
| API signature | Function parameter added | `validate(name: str)` | `validate(name: str, age: int)` | `srclight_get_callers('validate')` |
| Config key | Key renamed | `DB_HOST` | `DATABASE_HOST` | `grep` for `DB_HOST` across codebase |
| Data format | Field type changed | `created: str` (ISO) | `created: int` (epoch) | `srclight_search_symbols` for deserialization of this format |
| Return type | Return type narrowed | `dict[str, Any]` | `UserProfile` | `srclight_get_callers` on the function |
| Error contract | Error type changed | raises `ValueError` | raises `ValidationError` | `srclight_get_callers` + inspect error handling |

### Step 6: Consumer Breakage Assessment

For each changed contract, assess breakage:

| Breakage Mode | Detection Method | Severity | Remediation |
|---|---|---|---|
| Compile-time type error | Static analysis (pyright, mypy, tsc) | HIGH | Add adapter or versioned overload |
| Runtime type error | Callers pass old types | CRITICAL | Add runtime type coercion or migration period |
| Silent behavioral change | Callers depend on old behavior | CRITICAL | Add feature flag or behavior-preserving default |
| Config load failure | Config file uses old key | HIGH | Add backward-compatible key alias |
| Data deserialization failure | Stored data uses old format | CRITICAL | Add migration script or dual-format reader |
| Missing import/export | Module path changed | HIGH | Add re-export from old path |

### Step 7: Document in Impact Analysis

For each breakage mode with severity HIGH or CRITICAL, add to the spec's impact analysis:

- **Affected consumers:** list of callers, config files, or data stores identified
- **Coexistence strategy:** versioned API, feature flag, adapter layer, or migration window
- **Deprecation plan:** if phasing out old contract, document the deprecation period and warning mechanism
- **Rollback trigger:** what condition would trigger reverting the change

### Evidence Format

```
Check: [contract change description]
Tool: [srclight_get_callers, grep, srclight_search_symbols]
Result: [N consumers found, breakage mode, severity]
Classification: [COMPATIBLE|BREAKING-HIGH|BREAKING-CRITICAL]
Action: [proceed|add-migration|add-coexistence|HALT]
```

## Exemptions

- Initial spec creation (version 1.0): No change control needed
- STATUS marker updates: No version increment, no approval revocation
- Non-substantive changes (typos, cross-refs): No version increment

## Context Required

- Preceded by: `write` (spec must exist to revise)
- Followed by: `approval-gate` (fresh authorization required)