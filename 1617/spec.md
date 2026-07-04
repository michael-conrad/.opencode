---
type: SPEC-FIX
status: DRAFT
version: 1.0
created: 2026-07-01
labels: [SPEC-FIX, pipeline, enforcement, remediation, contract]
priority: high
---

# [SPEC-FIX] Pipeline enforcement gaps — contract paths, step-skip on FAIL, RED deliverable defects, dispatch directives

## Problem

During execution of spec #492 (stale-branch detection), four systemic enforcement gaps were discovered. These are not #492-specific — they are pipeline infrastructure defects that affect every plan execution.

### Gap 1: Contract path mismatch — Z3 check steps are dead code

The `implementation-pipeline/SKILL.md` dispatch routing table (lines 72-80) references contract paths under `contracts/red-phase-output-template.yaml`, `contracts/red-doublecheck-output-template.yaml`, `contracts/post-red-enforcement-output-template.yaml`, `contracts/green-phase-output-template.yaml`, `contracts/post-green-enforcement-output-template.yaml`. These resolve to `.opencode/skills/implementation-pipeline/contracts/` which does **not exist**.

All contract YAML files live under `.opencode/skills/writing-plans/contracts/` (22 files) and `.opencode/skills/spec-creation/contracts/` (3 files). The `implementation-pipeline` skill has zero contracts.

**Consequence:** Every Z3 check step in every plan (steps 4, 6, 8, 10, 12 in the standard 22-gate pipeline) references a non-existent file. The `solve check` tool requires `--contract-path` and `--state-path` — both point to non-existent files. These steps are dead code that silently fail or get skipped.

### Gap 2: Step skipping on FAIL without remediation

During execution of #492, steps 4-8 were skipped after the RED phase completed. The plan's SELF-REMEDIATION PROTOCOL mandates: diagnose → remediate → re-verify → proceed on PASS → HALT only on double-failure. Instead, the orchestrator skipped directly to the report-and-halt without executing the Z3 checks, doublecheck, or enforcement gates.

`000-critical-rules.md` §critical-rules-hard-fail and §critical-rules-accountability-ownership both mandate remediation-first. Skipping steps on FAIL without remediation is a Tier 2 violation.

**Consequence:** The RED phase deliverable (behavioral test script) shipped with defects — `echo` statements (violating `020-go-prohibitions.md`), undefined `$PARENT_REPO_DIR`, hardcoded `SUBMODULE_REMOTE` — that were never caught by the skipped enforcement gates.

### Gap 3: RED phase deliverable defects

The behavioral test script at `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` contains:

| Defect | Location | Violation |
|--------|----------|-----------|
| `echo` for narration | Lines 95, 104, 113 | `020-go-prohibitions.md` §1 — zero-tolerance prohibition on `echo`/`printf` |
| Undefined `$PARENT_REPO_DIR` | Lines 92, 101, 110 | Not defined in script or `helpers.sh` — will create temp dir in wrong location or fail |
| Hardcoded `SUBMODULE_REMOTE` | Line 14 | HTTPS URL hardcoded instead of derived from git config or session-init |

These defects were produced by the RED phase sub-agent and not caught because the enforcement gates (Z3 check, doublecheck, post-RED enforcement) were skipped.

### Gap 4: Sub-agent dispatch without task file discovery directive

The `brainstorming/SKILL.md` Invocation table (lines 53-59) provides canonical dispatch strings like `"execute explore task from brainstorming"` that are **missing** the mandatory `Read \`brainstorming/tasks/explore.md\` first` suffix required by the same skill's own "Required: Sub-agent Task File Discovery Directive" section (lines 94-104).

The `implementation-pipeline/SKILL.md` has the correct pattern in its prose (line 128) but the canonical dispatch strings in its Invocation table also lack the directive.

**Consequence:** Sub-agents dispatched without the discovery directive must search for the correct task file, wasting context and creating routing ambiguity. The directive is mandatory per both skills' own rules.

## Requirements

### R1: Create implementation-pipeline contracts

- [ ] Create `.opencode/skills/implementation-pipeline/contracts/` directory
- [ ] Create contract YAML files for each Z3 check gate referenced in the dispatch routing table:
  - `red-phase-output-template.yaml`
  - `red-doublecheck-output-template.yaml`
  - `post-red-enforcement-output-template.yaml`
  - `green-phase-output-template.yaml`
  - `post-green-enforcement-output-template.yaml`
- [ ] Each contract defines the expected output variables and constraints for that gate
- [ ] Update the dispatch routing table if any contract paths are incorrect

### R2: Enforce remediation-first on step failure

- [ ] Add a pre-flight gate to `implementation-pipeline/SKILL.md` that checks for contract existence before dispatching Z3 check steps. If contract file is missing, return BLOCKED with `MISSING_CONTRACT` — do NOT skip the step.
- [ ] Add a pipeline-level enforcement rule: if any step returns FAIL or BLOCKED, the orchestrator MUST remediate before proceeding. Skipping a failed step without remediation is a CRITICAL VIOLATION.
- [ ] Update `000-critical-rules.md` or add a symbolic rule: `critical-rules-step-skip` — skipping a pipeline step after a FAIL without remediation is a Tier 2 violation.

### R3: Fix RED phase deliverable defects

- [ ] Remove all `echo`/`printf` statements from `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh`
- [ ] Replace `$PARENT_REPO_DIR` with a derived path (e.g., from `SCRIPT_DIR` or `mktemp -d /tmp/opencode/`)
- [ ] Derive `SUBMODULE_REMOTE` from `git -C "$SCRIPT_DIR/../.." remote get-url origin` or session-init values instead of hardcoding
- [ ] Add a content-verification enforcement test that checks behavioral test scripts for prohibited patterns (echo, undefined variables, hardcoded URLs)

### R5: Set up test fixture repos for behavioral tests with real remotes

The #492 adversarial audit returned 6 FAILs because the behavioral test used a local bare repo as the remote. The agent detected "local-only repo" and refused to perform `git fetch`/`git rebase`/`git push` — all behavioral SCs (SC-2 through SC-5) failed because the test infrastructure couldn't support the required git operations.

Two blank fixture repos are available for this purpose. They have no fixed roles — either can be the root test repo, either can be a submodule, or both can be used independently:

| Repository | URL |
|------------|-----|
| test-submodule-1 | `https://github.com/michael-conrad/test-submodule-1` |
| test-submodule-2 | `https://github.com/michael-conrad/test-submodule-2` |

These are standalone repos (not submodules of opencode-config). They are currently blank — no pre-seeded content, no pre-assigned roles. The test framework sets them up at runtime: pushes a `dev` branch, forks a feature branch, pushes `dev` ahead, then runs the agent. The agent sees a real remote and can execute the full staleness-check + auto-rebase workflow.

- [ ] Document the two test repos in `.opencode/AGENTS.md` under a "Test Submodule Repositories" section (already done)
- [ ] Update `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` to use one of the test repos as the remote origin instead of a local bare repo. The test script pushes content to the repo at runtime — no pre-seeding needed.
- [ ] All future behavioral tests that require real remote operations MUST use these fixture repos

### R4: Fix canonical dispatch strings

- [ ] Update `brainstorming/SKILL.md` Invocation table (lines 53-59) to append `Read \`brainstorming/tasks/<task>.md\` first` to every canonical dispatch string
- [ ] Update `implementation-pipeline/SKILL.md` Invocation table to include the discovery directive in all canonical dispatch strings
- [ ] Audit all other SKILL.md files for the same gap

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `implementation-pipeline/contracts/` exists with 5+ contract YAML files | `string` | `ls .opencode/skills/implementation-pipeline/contracts/*.yaml | wc -l` returns ≥ 5 |
| SC-2 | Each contract file has valid `variables` and `constraints` sections | `string` | `grep -l "variables:" .opencode/skills/implementation-pipeline/contracts/*.yaml | wc -l` returns ≥ 5 |
| SC-3 | Pipeline-level enforcement rule exists: skipping failed step without remediation is a CRITICAL VIOLATION | `string` | `grep "step.*skip\|skip.*remediation" .opencode/skills/implementation-pipeline/SKILL.md` returns match |
| SC-4 | Behavioral test script has zero `echo`/`printf` statements | `string` | `grep -c "^[[:space:]]*echo \|^[[:space:]]*printf " .opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` returns 0 |
| SC-5 | Behavioral test script has no undefined `$PARENT_REPO_DIR` reference | `string` | `grep -c "PARENT_REPO_DIR" .opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` returns 0 |
| SC-6 | Behavioral test script derives `SUBMODULE_REMOTE` dynamically | `string` | `grep "remote get-url\|SUBMODULE_REMOTE=" .opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` returns match |
| SC-7 | Content-verification test exists for prohibited patterns in behavioral test scripts | `string` | `grep "echo\|printf\|PARENT_REPO_DIR" .opencode/tests/test-enforcement.sh` returns matches in enforcement context |
| SC-8 | `brainstorming/SKILL.md` Invocation table includes discovery directive in all canonical strings | `string` | `grep -c "Read \`brainstorming/tasks/" .opencode/skills/brainstorming/SKILL.md` returns ≥ 4 |
| SC-9 | `implementation-pipeline/SKILL.md` Invocation table includes discovery directive in all canonical strings | `string` | `grep -c "Read \`implementation-pipeline/tasks/" .opencode/skills/implementation-pipeline/SKILL.md` returns ≥ 10 |
| SC-10 | Behavioral test confirms orchestrator remediates before re-dispatch on FAIL | `behavioral` | Clean-room sub-agent: agent receives FAIL from step, diagnoses root cause, remediates, re-dispatches — does not skip |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/implementation-pipeline/contracts/red-phase-output-template.yaml` | New — RED phase output contract |
| `.opencode/skills/implementation-pipeline/contracts/red-doublecheck-output-template.yaml` | New — RED doublecheck output contract |
| `.opencode/skills/implementation-pipeline/contracts/post-red-enforcement-output-template.yaml` | New — post-RED enforcement output contract |
| `.opencode/skills/implementation-pipeline/contracts/green-phase-output-template.yaml` | New — GREEN phase output contract |
| `.opencode/skills/implementation-pipeline/contracts/post-green-enforcement-output-template.yaml` | New — post-GREEN enforcement output contract |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add pre-flight contract existence check; add step-skip enforcement rule; fix dispatch strings |
| `.opencode/skills/brainstorming/SKILL.md` | Fix canonical dispatch strings to include discovery directive |
| `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` | Fix echo, PARENT_REPO_DIR, SUBMODULE_REMOTE defects |
| `.opencode/tests/test-enforcement.sh` | Add content-verification check for prohibited patterns in behavioral test scripts |
| `.opencode/guidelines/000-critical-rules.md` | Add `critical-rules-step-skip` symbolic rule |

## Constraints

- Contract files follow the same YAML schema as `writing-plans/contracts/` (variables + constraints)
- The `solve check` tool requires both `--contract-path` and `--state-path` — state files are generated at runtime by the sub-agent, contracts are static
- Step-skip enforcement is a pipeline-level rule, not a per-skill rule — it belongs in `implementation-pipeline/SKILL.md`
- Behavioral test script fixes are part of this spec because the defects were caused by the enforcement gap, not by the test design

## Dependencies

- None — self-contained fix spec. Does not depend on #492 (the spec that exposed these gaps).

## Change Control

### v1.0 — Initial

**2026-07-01:** Created from root cause analysis of pipeline enforcement gaps discovered during #492 execution. Four gaps identified: contract paths, step-skip on FAIL, RED deliverable defects, dispatch directives.
