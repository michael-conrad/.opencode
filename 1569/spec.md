## Problem

The test enforcement script (`test-enforcement.sh`) crashes with an "unbound variable" error at line 875 when it encounters a scenario name that exists in the `SCENARIOS` array but not in the `EXPECTED_SKILLS` associative array. This causes the entire Guideline Content Verification section to be skipped, masking all content-verification failures.

## Root Cause

Line 875: `EXPECTED="${EXPECTED_SKILLS[$scenario_name]}"` — when `$scenario_name` is not a key in `EXPECTED_SKILLS`, bash's `set -u` (from `set -euo pipefail` at line 16) triggers an unbound variable error.

## Affected Scenarios (26 total)

```
cross-validate-sc1-monotonic-invariant
cross-validate-sc10-existing-rules-preserved
cross-validate-sc11-self-corrections-cascade-fail
cross-validate-sc2-fail-is-terminal
cross-validate-sc3-self-check-step-5-7
cross-validate-sc4-self-corrections-in-result-contract
cross-validate-sc5-no-remediation-verification
cross-validate-sc6-self-check-scans-explanation
guideline-frontmatter
guideline-index-exists
guideline-index-word-count
model-aware-critical-violation
ollama-tooling-registration
progressive-disclosure-060-updated
sc1-must-receive-no-spec-body
sc12-task-context-tables-reflect-removal
sc2-must-not-receive-spec-body-forbidden
sc4-task-context-spec-body-removed
sc6-no-unconditional-general
sc8-context-tainted-sc-conflict
session-enforcement-guideline-index
skildeck-lint-progressive-disclosure
skill-word-count
sub-agent-injection-gating
sub-agent-operational-guards-unconditional
sub-agent-session-detection
```

## Evidence

```
/home/muksihs/git/opencode-config/.opencode/tests/test-enforcement.sh: line 875: EXPECTED_SKILLS[$scenario_name]: unbound variable
```

## Classification

Pre-existing — these scenarios were never added to `EXPECTED_SKILLS` when they were created.

## Root Cause

When new test scenarios are added to the `SCENARIOS` array, the corresponding entry in `EXPECTED_SKILLS` must also be added. This was missed for 26 scenarios.

## Suggested Fix

Option A: Add all 26 missing entries to `EXPECTED_SKILLS` with empty string values (no expected skill).
Option B: Add a guard at line 875: `EXPECTED="${EXPECTED_SKILLS[$scenario_name]:-}"` to default to empty string when key is missing.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)