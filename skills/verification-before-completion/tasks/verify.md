# Task: verify

Verify all success criteria have evidence before allowing completion claims.

## Prerequisites

- Task or phase claimed complete
- Plan issue has success criteria defined
- Evidence collection may still be pending

## Verification Workflow

### 0. Structural Completeness Gate (MANDATORY — Before Per-SC Verification)

**Before checking individual success criteria evidence, verify that the implementation includes ALL structural components the spec requires.**

- [ ] 1. Identify the spec that authorized the implementation
- [ ] 2. Parse the spec for required structural components:
   - `state_machines` with `decomposition_guard` fields
   - `evidence_artifacts` sections
   - `gates` sections
   - `decomposition` sections
   - `tasks` entries with `mandatory` + `bypass_violation` fields
- [ ] 3. For each target skill/guideline file:
   - Read the file's `yaml+symbolic` block
   - Verify each structural component from the spec exists in the implementation
   - Report PASS/FAIL per component
- [ ] 4. If ANY structural component is missing:
   - HALT verification immediately
   - Report missing components as FAIL
   - Do NOT proceed to per-SC evidence check
- [ ] 5. If ALL structural components present:
    - Proceed to Step 1 (Query Success Criteria)

**Orchestrator dispatches structural-verify sub-agent:** When the verification context is the same agent that performed implementation, the orchestrator dispatches a `structural-verify` sub-agent to ensure clean-room isolation. The sub-agent receives ONLY the spec SC list and file paths — NOT implementation context.

**Authorization context for sub-agent task():**
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
spec_local_dir: <path> | [<path>, ...]     # REQUIRED — one or more local issue directories containing spec.md
artifact_evidence_dir: <path> | [<path>, ...]  # OPTIONAL — one or more behavioral evidence directories
```
- Missing `authorization_scope` → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

### VbC Pre-Check (MANDATORY)

**`spec_local_dir` semantics:**
All entries equally relevant. Sub-agent scans each folder for spec files, extracts SCs from each.

**`artifact_evidence_dir` semantics:**
Sub-agent searches all listed directories for evidence files via `glob`/`read`.

- [ ] 1. **`spec_local_dir`** — REQUIRED. If absent from context: BLOCKED with MISSING_INPUT_DIR. If present but path not found: BLOCKED with SPEC_NOT_FOUND.
- [ ] 2. **`artifact_evidence_dir`** — OPTIONAL. Absent or empty: handle gracefully.
- [ ] 3. Both fields are PROCEED — standard evidence input directories, not contamination.

### 0.75. Coverage Completeness Gate (MANDATORY — After Structural Completeness, Before Per-SC Verification)

**After verifying that all structural components exist (Step 0), verify that every changed file has at least one matching success criterion. Changed files with zero matching SCs are orphan changes — code paths that execute at runtime with zero behavioral verification.**

- [ ] 1. Get the list of changed files: `git diff --name-only dev`
- [ ] 2. Get the spec's SC table and affected files list
- [ ] 3. For each changed file, check if at least one SC covers it
- [ ] 4. Any changed file with zero matching SCs is flagged as `VERIFICATION-GAP` with FAIL verdict
- [ ] 5. `VERIFICATION-GAP` files MUST be resolved before proceeding:
   a. Add an SC for the file (if it's in scope), OR
   b. Document the file as explicitly out-of-scope with developer authorization

**🚫 FORBIDDEN:** Silently skipping uncovered changes. A changed file with no matching SC is a code path executing at runtime with zero behavioral verification — the agent "verified" the spec's SCs but never asked whether the implementation went beyond the spec.

**Authority:** `guidelines/000-critical-rules.md` §critical-rules-BEH-EV, Issue #836

### 0.5. Dispatch Chain Compliance Gate (MANDATORY — Before Per-SC Verification)

**Verify that the work was produced through the proper `skill() → task()` dispatch chain, not via inline execution.**

Inline execution bypasses every quality gate — clean-room isolation, cross-family auditors, evidence classification. A structurally correct implementation produced inline is indistinguishable from a bypass until the dispatch log is checked.

- [ ] 1. Check the dispatch log for `skill()` calls matching the current pipeline stage:
   - `skill({name: "spec-creation"})` or `skill({name: "writing-plans"})` for plan/spec stages
   - `skill({name: "verification-before-completion"})` for this verification stage
   - `skill({name: "adversarial-audit"})` for audit stages
- [ ] 2. If the dispatch log is empty (no `skill()` calls recorded): return BLOCKED with `DISPATCH_CHAIN_VIOLATION`
- [ ] 3. If the dispatch log has `skill()` calls but none match the current pipeline stage: return BLOCKED with `DISPATCH_CHAIN_VIOLATION`
- [ ] 4. If the dispatch log has matching `skill()` calls: proceed to Step 0.5a

**No override path exists.** A DISPATCH_CHAIN_VIOLATION is terminal for this verification pass — the agent must restart from `verify-authorization` with proper skill dispatch.

### 0.5a. Header Verification Checkpoint (MANDATORY — For New Files)

**For each new file added by the agent during implementation, verify it contains the required headers per its file type as defined in `080-code-standards.md` §"Header Format by File Type".**

- [ ] 1. Identify all files added (not modified) during this implementation: `git diff --diff-filter=A --name-only dev`
- [ ] 2. For each new file, determine its file type and check for required headers:
   - Python (`.py`): SPDX copyright, SPDX license (MIT), Provenance header, AI byline in docstring
   - SKILL.md: `license` and `provenance` fields in YAML frontmatter
   - Markdown (`.md`): SPDX copyright, SPDX license, Provenance as HTML comments
   - Scala (`.scala`): SPDX copyright, SPDX license (project-appropriate), Provenance header, AI byline in ScalaDoc
   - Other languages: Fallback rule per `080-code-standards.md` §"Other Languages (Fallback Rule)"
- [ ] 3. If ANY new file is missing required headers:
   - Report as FAIL with specific file and missing header(s)
   - Do NOT proceed to Step 1 until headers are added
- [ ] 4. If ALL new files have required headers:
   - Report as PASS
   - Proceed to Step 1

**Grandfather clause:** Pre-existing files modified by the agent are exempt from header verification — only newly created files require headers.

### 1. Query Success Criteria

- Read spec files from `spec_local_dir` directories for defined success criteria
- Parse each criterion as a testable statement
- Identify evidence needed for each

### 2. Check for Evidence

- Review issue comments for evidence
- Check `{project_root}/tmp/{issue-N}/artifacts/` for verification artifacts
- Verify evidence matches criteria

### 2a. Todowrite Cleanup Verification

- Verify no stale todowrite items remain (`pending` or `in_progress`)
- If todowrite was used during the session, confirm `todowrite(todos=[])` was called before HALT
- Evidence: todowrite state is empty or all items are `completed`
- Failure: HALT and require todowrite cleanup before allowing completion

### 3. Mark Verified/Unverified

```markdown
## Success Criteria Verification

1. ✅ [Criterion] - EVIDENCE: [Link/output]
2. ✅ [Criterion] - EVIDENCE: [Link/output]
3. ❌ [Criterion] - MISSING EVIDENCE
```

### 4. Report Status

- If all verified → Allow completion claim
- If any unverified → HALT and require evidence

### 4.5. Cross-Model Validation Gate (MANDATORY)

**When behavioral testing is part of the spec's verification scope, single-model evidence is insufficient.** The orchestrator MUST verify that both local and cloud model runs exist:

- [ ] 1. Check evidence artifacts for both `model: <local>` and `model: <cloud>` entries
- [ ] 2. If only single-model evidence is present: flag as `CROSS_MODEL_GAP`
   - HALT completion claim
   - Re-task verification against the missing model
- [ ] 3. Cross-model result comparison:
   - Both pass: cross-validation confirmed (PASS)
   - Only one passes: **brittleness detected** — instructions are model-biased. Flag as `BRITTLENESS_DETECTED` with remediation required
   - Both fail: instructions broken — HALT and require fix
- [ ] 4. If both model runs produce evidence: proceed to step 4

**🚫 FORBIDDEN:** Accepting single-model results as cross-model-validated; treating `PASS` from one model as equivalent to cross-model verification.

**AUTHORITY:** `000-critical-rules.md` §Model-Aware Clean-Room task(), Spec #262

## Evidence Types — STRUCTURAL EVIDENCE IS ALWAYS FAIL FOR CODE CHANGES (ZERO TOLERANCE)

**🚫 STRUCTURAL EVIDENCE (grep/read/file-exists) IS NEVER ACCEPTABLE FOR TESTABLE CODE.**

If the change modifies behavior, logic, or executable code, ALL success criteria require behavioral/functional/regression test execution as evidence. grep, read, ls, file-existence, content-checking are NOT evidence of correct behavior — they are evidence that text was written. Code that exists but produces wrong output is indistinguishable from code that does not exist until you run it.

### Exception: Non-Testable Content (docs, runbooks, guidelines, prose)

For changes to non-executable content (markdown documentation, runbooks, guidelines, prose-only files), structural evidence IS acceptable but MUST use **semantic intent verification by direct AI agent inspection** — NOT grep/pattern matching. The agent MUST:

- [ ] 1. Read the actual content of the modified file
- [ ] 2. Compare it semantically against the spec's intent — does the prose actually convey the intended meaning?
- [ ] 3. Report PASS only if the semantic intent is correctly expressed, not just if keywords appear

Grep/pattern-match verification is FORBIDDEN even for prose content. The agent must read and understand, not search for string patterns.

### Classification

| Change Type | Evidence Requirement | Method |
|-------------|---------------------|--------|
| Testable code (logic, behavior, runtime) | Behavioral/functional/regression test execution | `pytest`, `opencode-cli run`, lint, typecheck — all with saved artifacts in `{project_root}/tmp/{issue-N}/artifacts/` |
| Non-testable prose (docs, runbooks, guidelines) | Semantic intent verification by direct AI agent read | Read the file, understand the prose, verify semantic intent against spec — NOT grep/pattern matching |
| | | |
| Structural-only evidence (grep/read/file-exists) for testable code | **TOTAL FAIL** — entire verification gate returns FAIL | No exceptions. No metadata exemption. |

### Invalid Evidence

| Type | Why Invalid |
| -- | -- |
| "Trust me" | No verification |
| "It should work" | Assumption, not proof |
| "I checked" | No artifact |
| "Code is correct" | No test run |
| Placeholder text | "TBD" or "TODO" |
| File exists / test file present | File existence ≠ test execution; structural evidence accepted as behavioral evidence |

### Verification Rule: Behavioral vs Structural Evidence

**When an SC requires behavioral verification, structural evidence is INSUFFICIENT. The agent MUST run the behavioral test and report its output.**

Reading a test implementation file and confirming it exists is structural evidence. Running the test and observing PASS/FAIL output is behavioral evidence. These are fundamentally different — a test file that contains a deliberate bug will pass the structural check (the file exists, the test function is present) but fail the behavioral check (the test output shows FAIL).

- 🚫 FORBIDDEN: Reporting file existence as evidence that a behavioral SC is satisfied
- 🚫 FORBIDDEN: Reading a test file and reporting "test exists → PASS" without executing it
- 🚫 FORBIDDEN: Using `cat`, `read`, or `ls` to verify behavioral correctness
- ✅ REQUIRED: For behavioral SCs, the agent MUST execute the test and report the output
- ✅ REQUIRED: Classify each SC as structural or behavioral in the evidence table
- ✅ REQUIRED: Use behavioral evidence (test execution output) only for behavioral SCs

### When Behavioral/Functional Tests Cannot Execute

If a behavioral/functional test cannot run (model unavailable, timeout, infrastructure error, `opencode-cli` not installed):

| Outcome | Classification | Correct Report |
|---------|---------------|-----------------|
| Test executed successfully | Behavioral evidence | PASS or FAIL per test output |
| Test cannot execute | **FAIL** — never PASS/UNVERIFIED with substitute | `FAIL: behavioral/functional test could not execute` |
| Test cannot execute, agent substitutes structural check | **CRITICAL VIOLATION** | HALT and report |

**"Functional test" and "behavioral test" are synonymous.** Both refer to tests that verify actual agent behavior by executing code and observing output.

The only valid outcomes for a behavioral SC are:
- [ ] 1. Test runs → report PASS or FAIL based on actual test output
- [ ] 2. Test cannot run → report FAIL with explanation of why
- [ ] 3. Test cannot run → attempt remediation (model selection, infrastructure check)
- [ ] 4. Remediation also fails → report FAIL, await human intervention
- [ ] 5. Remediation must be exhaustive before escalation: only after ALL available model selection, infrastructure check, and alternative model paths have been verified as failed may the agent HALT with escalation

There is NO valid path from "test cannot run" to "PASS" or "UNVERIFIED with structural substitute."

### Pre-Existing Failure Prohibition (See critical-rules-069)

**CRITICAL: The agent MUST NOT rationalize any test failure as "pre-existing", "already broken", or "baseline failure".** All pipeline state at entry is owned by the agent. If a baseline test fails, the agent must remediate it before proceeding.

When a baseline test failure is detected:
- [ ] 1. **Record the failure evidence** — capture stdout/stderr
- [ ] 2. **Attempt remediation** — diagnose root cause, fix, re-run
- [ ] 3. **If remediation fails after 2+ attempts** — report as BLOCKED with all failure evidence
- [ ] 4. **NEVER proceed past a FAIL** — regardless of whether the failure was "pre-existing"

## Verification Report Format

```markdown
## Verification Report

**Task:** [Task description]
**Plan Issue:** #N

### Success Criteria Verification

| Criterion | Status | Evidence |
|-----------|--------|----------|
| ✅ Test passed | ✅ VERIFIED | `pytest test/x.py` output |
| ✅ Lint clean | ✅ VERIFIED | `ruff check src/` output |
| ✅ File created | ❌ MISSING | Need: `ls -la path/to/file` |

### Missing Evidence

1. **File created**: Need to verify file exists
   - Expected: `ls -la path/to/file`
   - Current: No evidence provided

### Required Actions

- [ ] Provide evidence for missing criteria
- [ ] Re-run verification after evidence added

---

🤖 <AgentName> (<ModelId>) ✅ completed
```

## Comparison Mode Enforcement (MANDATORY)

**🚫 CRITICAL: When verifying DNS records, configuration values, API responses, or infrastructure state, use `exact` comparison mode. Soft-passing a mismatch as "functionally equivalent" is a CRITICAL VIOLATION.**

### Verification Table Format (MANDATORY for External Verifications)

When verifying live values against specifications, use this row-by-row comparison table:

```markdown
| Field | Expected (from source) | Actual (live) | Result |
|-------|----------------------|---------------|--------|
| priority | 5 | 0 | ❌ FAIL |
| weight | 0 | 5 | ❌ FAIL |
| port | 443 | 443 | ✅ PASS |
| target | server.example.com | server.example.com | ✅ PASS |
```

### Prohibited Patterns

| Pattern | Why Prohibited |
| -- | -- |
| "Functionally equivalent" | Agent judgment substituting for spec compliance |
| "Minor difference" | "Close enough" is never a valid verification outcome |
| "Works the same" | Functional analysis is for design, not verification |
| Reporting swapped fields as PASS | Each field is independently compared |

### Enforcement Matrix

| Verification Type | Comparison Mode | Default | Override? |
| -- | -- | -- | -- |
| DNS records | Exact | Exact | Never |
| Configuration values | Exact | Exact | Never |
| API responses | Exact | Exact | Never |
| Infrastructure state | Exact | Exact | Never |
| Code behavior | Semantic (with justification) | Exact | Per-field justification required |
| File existence | Exact | Exact | Never |

## Per-SC Evidence Table (MANDATORY)

**🚫 CRITICAL: Before marking ANY task or phase complete, the agent MUST produce a per-SC evidence table with one row per success criterion from the corresponding spec. This table is the completion gate — no row may be skipped, and no row may show PASS without exact-match evidence.**

### Table Format

| SC ID | Success Criterion Text | Evidence Type | Verification Command Run | Exact Output Observed | Pass/Fail |
| -- | -- | -- | -- | -- | -- |
| SC-1 | \[criterion text\] | structural/string/semantic/behavioral | `command --flag` | \[exact output\] | PASS/FAIL/MISSING EVIDENCE |

The **Evidence Type** column is MANDATORY. It MUST match the evidence type declared in the spec's success criteria table. If the spec does not declare evidence types, default to `string` per `080-code-standards.md` §Evidence Type Taxonomy.

**Every row's evidence MUST match or exceed the declared evidence type:**

| Declared Evidence Type | Minimum Acceptable Evidence | Using Lower Evidence |
| -- | -- | -- |
| `structural` | `ls`, `wc`, file existence | N/A (structural is minimum) |
| `string` | `grep`, pattern matching | ❌ CRITICAL VIOLATION if only structural |
| `semantic` | Sub-agent read + analytical judgment | ❌ CRITICAL VIOLATION if only structural/string |
| `behavioral` | Test execution with output inspection | ❌ CRITICAL VIOLATION if only structural/string/semantic |

### Behavioral SC Enforcement

When an SC declares evidence type `behavioral`:

- [ ] 1. The VbC sub-agent MUST execute the behavioral test (e.g., `bash test/script.sh`) and include the execution output (especially stderr) in its evidence
- [ ] 2. The VbC sub-agent MUST NOT accept `ls test/script.sh` or `grep assertion test/script.sh` as evidence for a behavioral SC
- [ ] 3. If the test cannot execute (infrastructure failure, model unavailable), the SC verdict is FAIL — never PASS or UNVERIFIED with a structural substitute
- [ ] 4. The evidence table MUST show the test execution command and its result, not just the file path

### Mandatory Outcomes Per Row

| Outcome | Meaning | When Applied |
| -- | -- | -- |
| **PASS** | Exact match between observed output and literal SC text | Observed output character-for-character matches the SC's specified value |
| **FAIL** | Mismatch between observed output and literal SC text | Observed output differs from the SC's specified value in any way |
| **MISSING EVIDENCE** | No verification command was run for this SC | Agent skipped verification for this criterion |

### 🚫 FORBIDDEN Outcomes (Zero Tolerance)

| Pattern | Why FORBIDDEN |
| -- | -- |
| "functionally equivalent" | Agent judgment substituting for spec compliance |
| "close enough" | "Close enough" is never a valid verification outcome |
| "semantically similar" | Semantic analysis is for design, not verification |
| "works the same way" | Behavioral proximity is not spec compliance |
| PASS with caveat or footnote | A PASS with an asterisk is a FAIL |

**Any row using a FORBIDDEN outcome is automatically reclassified as FAIL. The agent cannot override this reclassification.**

### Enforcement

- All rows MUST show PASS before completion is allowed
- Any FAIL or MISSING EVIDENCE row blocks completion
- Agent MUST re-run the verification command for any FAIL row
- Agent MUST provide a verification command for any MISSING EVIDENCE row

## Programmatic Enforcement Tools (AVAILABLE)

The following `skildeck` commands are available for automated verification:

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `skildeck verify-structure --spec-file <path> --files <paths>` | Verify structural components (state_machines, evidence_artifacts, gates, decomposition, tasks) in implementation match spec | During Structural Completeness Gate (Step 0) |
| `skildeck verify-acceptance --spec-file <path>` | Verify acceptance criteria from spec against implementation | During per-SC verification (Step 1) |
| `skildeck verify-issue --spec-file <path> --files <paths>` | Combined structural + acceptance verification in single report | When `verify fully implemented` is requested |

These tools produce PASS/FAIL/MANUAL-REVIEW tables and exit code 1 on any failure. They are the programmatic enforcement layer complementing manual verification.

**🚫 MANDATORY: `skildeck verify-structure` and `skildeck verify-acceptance` MUST be used as the programmatic enforcement layer for structural and acceptance verification respectively.** Manual verification alone is insufficient — the skildeck commands provide repeatable, deterministic verification that manual inspection cannot guarantee. When these commands are available, verification MUST include their output as evidence artifacts in the per-SC evidence table.

## Post-Verification Chain

After verification passes, the following skills MUST be invoked in sequence:

- [ ] 1. **finishing-a-development-branch --task checklist** — Branch readiness verification
- [ ] 2. **git-workflow --task review-prep** — Push verification, compare URL, chat output

These are NOT optional. Verification passing triggers the chain:
`verify` → `finishing-a-development-branch --task checklist` → `git-workflow --task review-prep`

If verification fails, HALT — do NOT proceed to the chain.

## Enforcement

### What Skills MUST Check

- [ ] 1. Before marking complete:

   - Are ALL success criteria defined?
   - Do ALL criteria have evidence?
   - Is evidence verifiable?

- [ ] 2. Enforcement matrix:

   - All criteria verified → ALLOW completion claim
   - Some criteria unverified → HALT, require evidence
   - No criteria defined → HALT, require success criteria
   - Evidence placeholder → HALT, require real evidence

### Enforcement Messages

**Missing evidence:**

```
Completion claim rejected. Evidence missing for:

- [ ] Success criterion: "[Criterion description]"
- [ ] Expected: [What evidence to provide]
- [ ] Current: [What evidence exists]

Please provide evidence before claiming completion.
```

**Success criteria undefined:**

```
Cannot verify completion. Success criteria not defined.

Task: [Task description]
Plan Issue: #N

Please define success criteria in the plan before execution.
```

**Evidence placeholder:**

```
Evidence placeholder detected. Real evidence required.

- [ ] Placeholder: "TBD" or "TODO"
- [ ] Expected: Verifiable test output, file path, or code diff

Please replace placeholder with actual evidence.
```

## Live Verification: Completion Evidence Claims (MANDATORY)

**Each completion claim MUST be verified against live state — not assumed from checklist assertions. This extends `065-verification-honesty.md` to completion verification.**

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "Success criterion met" | Verify criterion against actual code/test output | `read` or `srclight_get_symbol` or test execution | VERIFICATION-GAP |
| "Test passing" | Run the actual test command | `uv run pytest test/test_file.py` | VERIFICATION-GAP |
| "Files modified as specified" | Verify file changes match spec | `git diff dev --name-only` → compare with spec | CONFLICTING |
| "No uncommitted changes" | Verify clean working tree | `git status --porcelain` | VERIFICATION-GAP |
| "Branch pushed to remote" | Verify tracking branch exists | `git branch -vv` → check `[origin/<branch>]` | MISSING-ELEMENT |
| "Evidence artifact produced" | Verify tool call exists for each criterion | Check tool-call records in context | MISSING-ELEMENT |

**Evidence artifact:** Each verification check MUST produce a tool-call result. Assertions without tool-call artifacts are VERIFICATION-GAP findings.

### Finding Classification

| Finding | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Criterion claimed met without evidence | VERIFICATION-GAP | conditional | Re-verify with actual tool call |
| Test not actually passing | CONFLICTING | flag-for-review | HALT — fix test before claiming completion |
| Files differ from spec | CONFLICTING | flag-for-review | Report — scope may have deviated |
| Uncommitted changes exist | VERIFICATION-GAP | conditional | Commit before proceeding |
| Branch not pushed | MISSING-ELEMENT | auto-fix | Push immediately |
