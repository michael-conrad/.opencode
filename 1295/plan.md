# Implementation Plan — #1295

**Goal:** Fix `local-issues` PEP 723 header from deprecated `# /// pyproject.toml` to `# /// script`, update `070-environment.md` with canonical reference and version pinning standards, and expand `test-pep723-tools.sh` with lint checks for PEP 723 compliance.

**Architecture:** Three independent concern areas — executable tool file (`.opencode/tools/local-issues`), documentation guideline (`.opencode/guidelines/070-environment.md`), enforcement test script (`.opencode/tests/test-pep723-tools.sh`). No shared code or coupling between phases.

**Tech Stack:** Python (PEP 723 scripts via `uv run --script`), Bash (test script), Markdown (guidelines).

## File Structure

| File | Phase | Responsibility |
|------|-------|----------------|
| `.opencode/tools/local-issues` | 1 | Tool file — PEP 723 header rewrite from `# /// pyproject.toml` to `# /// script` |
| `.opencode/guidelines/070-environment.md` | 2 | Documentation — PEP 723 reference link, correct marker spec, version pinning standards |
| `.opencode/tests/test-pep723-tools.sh` | 3 | Enforcement tests — check functions for `requires-python` pinning, dependency pinning, pyproject.toml marker absence |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

### Phase 1: Fix local-issues

**Concern:** Executable tool file — PEP 723 metadata block header rewrite
**Files:** `.opencode/tools/local-issues` (lines 1-12)
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5
**Entry condition:** Current header uses deprecated `# /// pyproject.toml` with `[project]` section, unversioned `pyyaml`, and bare `>=3.12`
**Exit condition:** Header uses `# /// script` with `requires-python = "~=3.12.0"` and `dependencies = ["pyyaml~=6.0"]`; `init` exits 0

**Concern boundary (entry):** Starting from the tool file's current defective header — entering header rewrite. No external dependencies.

#### Item: P1-I1 — Replace inline metadata block

**SCs:** SC-2 (script marker), SC-3 (no [project]), SC-4 (~=3.12.0), SC-5 (pyyaml~=6.0)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|---------------|--------|----------------|-------------------|-----|
| sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate coherence-extraction from adversarial-audit", "issue_number": 1295, "phase": 1}` | SC-2, SC-3, SC-4, SC-5 |
| pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute verify from verification-before-completion", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| checkpoint-commit | inline | N/A | N/A | — | SC-2, SC-3, SC-4, SC-5 |
| structural-checks | sub-task | yes (blind) | general | `{"task": "execute checklist from finishing-a-development-branch", "issue_number": 1295, "phase": 1}` | SC-2, SC-3, SC-4, SC-5 |
| green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute verify from verification-before-completion", "issue_number": 1295, "phase": 1, "item": "P1-I1"}` | SC-2, SC-3, SC-4, SC-5 |
| adversarial-audit | multi-dispatch | N/A | resolve-models | Orchestrator manages: resolve-models → auditor_1 → remediate → auditor_2 → cross-validate | SC-2, SC-3, SC-4, SC-5 |
| cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from adversarial-audit", "auditor_artifact_paths": "<from resolve-models>", "issue_number": 1295}` | SC-2, SC-3, SC-4, SC-5 |
| regression-check | sub-task | yes (blind) | general | `{"task": "execute patterns from test-driven-development", "issue_number": 1295}` | SC-2, SC-3, SC-4, SC-5 |
| review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from git-workflow", "issue_number": 1295}` | SC-2, SC-3, SC-4, SC-5 |

#### Item: P1-I2 — Verify init works

**SCs:** SC-1 (init exits 0)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|---------------|--------|----------------|-------------------|-----|
| sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate coherence-extraction from adversarial-audit", "issue_number": 1295, "phase": 1}` | SC-1 |
| pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1295, "phase": 1, "item": "P1-I2"}` | SC-1 |
| red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development", "issue_number": 1295, "phase": 1, "item": "P1-I2"}` | SC-1 |
| green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development", "issue_number": 1295, "phase": 1, "item": "P1-I2"}` | SC-1 |
| checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| green-vbc | sub-task | yes (blind) | general | `{"task": "execute completion from verification-before-completion", "issue_number": 1295, "phase": 1}` | SC-1 |

**Concern boundary (exit):** Leaving the tool file fix — documentation phase requires the corrected pattern as reference.

---

### Phase 2: Update 070-environment.md PEP 723 documentation

**Concern:** Documentation guideline — PEP 723 canonical reference, correct marker, version pinning standards
**Files:** `.opencode/guidelines/070-environment.md`
**SCs covered:** SC-6, SC-7
**Entry condition:** 070-environment.md lacks PEP 723 link, uses incorrect marker, has no pinning standards
**Exit condition:** Contains PEP 723 URL, specifies `# /// script` as only standardized marker, mandates `~=` for both requires-python and dependencies

**Concern boundary (entry):** Entering documentation — requires Phases 1 corrected pattern as reference content (pedagogical dependency). Phase 2 starts after Phase 1 checkpoint-commit.

#### Item: P2-I1 — Add PEP 723 canonical reference and correct conventions

**SCs:** SC-6 (PEP 723 URL), SC-7 (~= pinning prose)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|---------------|--------|----------------|-------------------|-----|
| sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate coherence-extraction from adversarial-audit", "issue_number": 1295, "phase": 2}` | SC-6, SC-7 |
| pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1295, "phase": 2, "item": "P2-I1"}` | SC-6, SC-7 |
| red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development", "issue_number": 1295, "phase": 2, "item": "P2-I1"}` | SC-6, SC-7 |
| green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development", "issue_number": 1295, "phase": 2, "item": "P2-I1"}` | SC-6, SC-7 |
| checkpoint-commit | inline | N/A | N/A | — | SC-6, SC-7 |
| green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute verify from verification-before-completion", "issue_number": 1295, "phase": 2}` | SC-6, SC-7 |
| green-vbc | sub-task | yes (blind) | general | `{"task": "execute completion from verification-before-completion", "issue_number": 1295, "phase": 2}` | SC-6, SC-7 |
| adversarial-audit | multi-dispatch | N/A | resolve-models | Orchestrator manages: resolve-models → auditor_1 → remediate → auditor_2 → cross-validate | SC-6, SC-7 |
| cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from adversarial-audit", "auditor_artifact_paths": "<from resolve-models>", "issue_number": 1295}` | SC-6, SC-7 |
| exec-summary | sub-task | yes (blind) | general | `{"task": "execute completion from completion-core", "issue_number": 1295}` | SC-6, SC-7 |

**Concern boundary (exit):** Leaving documentation — linting phase also requires the corrected pattern as reference.

---

### Phase 3: Expand test-pep723-tools.sh linting

**Concern:** Enforcement test — automated linting for PEP 723 violations in `.opencode/tools/`
**Files:** `.opencode/tests/test-pep723-tools.sh`
**SCs covered:** SC-8, SC-9, SC-10, SC-11
**Entry condition:** test-pep723-tools.sh lacks `check_requires_python_pinned` and `check_dependencies_pinned` functions
**Exit condition:** Both functions exist; running the script on post-fix repo exits 0

**Concern boundary (entry):** Entering test expansion — requires Phase 1 corrected local-issues as the target of linting checks.

#### Item: P3-I1 — Add check_requires_python_pinned function

**SCs:** SC-8 (check_requires_python_pinned exists)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|---------------|--------|----------------|-------------------|-----|
| sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate coherence-extraction from adversarial-audit", "issue_number": 1295, "phase": 3}` | SC-8 |
| pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1295, "phase": 3, "item": "P3-I1"}` | SC-8 |
| red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development", "issue_number": 1295, "phase": 3, "item": "P3-I1"}` | SC-8 |
| green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development", "issue_number": 1295, "phase": 3, "item": "P3-I1"}` | SC-8 |
| checkpoint-commit | inline | N/A | N/A | — | SC-8 |
| green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute verify from verification-before-completion", "issue_number": 1295, "phase": 3}` | SC-8 |

#### Item: P3-I2 — Add check_dependencies_pinned function

**SCs:** SC-9 (check_dependencies_pinned exists)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|---------------|--------|----------------|-------------------|-----|
| sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate coherence-extraction from adversarial-audit", "issue_number": 1295, "phase": 3}` | SC-9 |
| pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1295, "phase": 3, "item": "P3-I2"}` | SC-9 |
| red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development", "issue_number": 1295, "phase": 3, "item": "P3-I2"}` | SC-9 |
| green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development", "issue_number": 1295, "phase": 3, "item": "P3-I2"}` | SC-9 |
| checkpoint-commit | inline | N/A | N/A | — | SC-9 |
| green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute verify from verification-before-completion", "issue_number": 1295, "phase": 3}` | SC-9 |

#### Item: P3-I3 — Verify test script exits 0 on clean repo

**SCs:** SC-10 (exit 0), SC-11 (no pyproject.toml marker)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|---------------|--------|----------------|-------------------|-----|
| sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate coherence-extraction from adversarial-audit", "issue_number": 1295, "phase": 3}` | SC-10, SC-11 |
| pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1295, "phase": 3, "item": "P3-I3"}` | SC-10, SC-11 |
| red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development", "issue_number": 1295, "phase": 3, "item": "P3-I3"}` | SC-10, SC-11 |
| green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development", "issue_number": 1295, "phase": 3, "item": "P3-I3"}` | SC-10, SC-11 |
| checkpoint-commit | inline | N/A | N/A | — | SC-10, SC-11 |
| green-vbc | sub-task | yes (blind) | general | `{"task": "execute completion from verification-before-completion", "issue_number": 1295, "phase": 3}` | SC-10, SC-11 |
| adversarial-audit | multi-dispatch | N/A | resolve-models | Orchestrator manages: resolve-models → auditor_1 → remediate → auditor_2 → cross-validate | SC-10, SC-11 |
| cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from adversarial-audit", "auditor_artifact_paths": "<from resolve-models>", "issue_number": 1295}` | SC-10, SC-11 |
| regression-check | sub-task | yes (blind) | general | `{"task": "execute patterns from test-driven-development", "issue_number": 1295}` | SC-10, SC-11 |
| review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from git-workflow", "issue_number": 1295}` | SC-10, SC-11 |
| exec-summary | sub-task | yes (blind) | general | `{"task": "execute completion from completion-core", "issue_number": 1295}` | SC-10, SC-11 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | Plan header includes Goal, Architecture, Tech Stack |
| C2 | File structure lists all files with responsibilities |
| C3 | TDD tasks include mandatory Step 2 RED checkpoint |
| C4 | Phase descriptions include concern boundary annotations |
| C5 | Plan stored at `.opencode/.issues/1295/plan.md` |
| C6 | No TBD/TODO placeholders remain |
| C7 | Plan artifact created locally in `.opencode/.issues/1295/` |
| C8 | Status marker uses prose-driven format |
| C9 | Approval cascade honors `for_plan` scope — halt at `plan_created` |

**Authorization context:** `for_plan` scope, `halt_at: plan_created`, `pr_strategy: none` — plan is a local artifact. Pipeline authorization covers plan approval. HALT after plan creation.