## Spec Audit Report — `.opencode#1832`

**Issue:** [SPEC] Test environment must replicate production — consolidate with-test-home, env-loader, and dead code cleanup
**URL:** https://github.com/michael-conrad/.opencode/issues/1832
**Date:** 2026-07-10
**Auditor:** opencode (ollama/ornith:35b-256k)
**Classification:** Pre-implementation spec audit

---

## Executive Summary

| Check | Verdict | Severity |
|-------|---------|----------|
| SC-DET (Success Criteria Detection) | WARN | medium |
| SC-SCOPE (Scope Verification) | PASS | — |
| SC-CONFLICT (Conflict Detection) | FAIL | **block** |
| SC-DETENTION (Dead Code Check) | WARN | medium |
| SC-VERIFICATION (Verification Method Check) | FAIL | **block** |
| AUTH-CURRENCY (Authorization Currency) | PASS | — |
| CODEBASE-GROUNDING | WARN | medium |
| SUPERCISION CHECK | FAIL | **block** |

**Overall: FAIL — 3 block issues, 4 warnings, 1 pass**

---

## 1. SC-DET (Success Criteria Detection)

### 1.1 Evidence Type Declaration

| Status | PASS |
|--------|------|

All 18 SCs have an `Evidence Type` column declared. No SC lacks evidence type classification.

### 1.2 SC-to-Test Traceability

| Status | WARN |
|--------|------|

**Finding:** No behavioral enforcement test files exist for SC-1, SC-17, or SC-18 (the only `behavioral`-typed SCs). The spec defines behavioral evidence requirements but provides no corresponding test file references.

**Evidence:**
- Grep of `.opencode/tests/behaviors/` for `SC-1` through `SC-18` (spec-1832 context) returns zero matches
- Grep of `.opencode/tests/test-enforcement.sh` for `SC-1` through `SC-18` returns zero matches for this spec's SC IDs
- SC-1, SC-17, SC-18 are the only `behavioral`-typed SCs; the remaining 15 are `string`-typed

**Recommendation:** For a pre-implementation audit, this is expected. The spec should reference where behavioral tests will live (e.g., "SC-1, SC-17, SC-18: behavioral tests in `.opencode/tests/behaviors/1832-sc1-behavioral-env-loader.sh`"). Without this, the SC-to-test traceability requirement from `080-code-standards.md` cannot be verified until implementation.

---

## 2. SC-SCOPE (Scope Verification)

| Status | PASS |
|--------|------|

All 18 SCs are testable and within the spec's stated scope:

| SC | Testable? | Within Scope? |
|----|-----------|---------------|
| SC-1 | ✅ Grep stderr for error string | ✅ Env-loader plugin fix |
| SC-2 | ✅ Grep function body for specific string | ✅ Model discovery unification |
| SC-3 | ✅ Grep for provider name | ✅ Model discovery unification |
| SC-4 | ✅ Grep for variable in array | ✅ Test home isolation |
| SC-5 | ✅ Grep for env var presence | ✅ Test home isolation |
| SC-6 | ✅ Grep for function removal | ✅ Model discovery unification |
| SC-7 | ✅ File existence check | ✅ Dead code removal |
| SC-8 | ✅ Grep for reference removal | ✅ Dead code removal |
| SC-9 | ✅ Grep for reference removal | ✅ Dead code removal |
| SC-10 | ✅ Grep for reference removal | ✅ Dead code removal |
| SC-11 | ✅ Grep for section heading | ✅ Documentation |
| SC-12 | ✅ Grep for cross-reference | ✅ Documentation |
| SC-13 | ✅ Grep for export change | ✅ Env-loader plugin fix |
| SC-14 | ✅ Grep for each export name | ✅ Env-loader plugin fix |
| SC-15 | ✅ tsc exit code | ✅ Env-loader plugin fix |
| SC-16 | ✅ File existence check | ✅ Env-loader plugin fix |
| SC-17 | ✅ Behavioral: env var injection | ✅ Env-loader plugin fix |
| SC-18 | ✅ Behavioral: full test suite | ✅ Full suite verification |

---

## 3. SC-CONFLICT (Conflict Detection)

| Status | FAIL | Severity: **block** |
|--------|------|---------------------|

### Finding 3.1: Superseded Issues Still Open — Direct Contradiction

The spec states that issues #676, #793, #1370, and #1653 are **absorbed/superseded**. However:

| Issue | Spec Claims | Actual State | Contradiction |
|-------|-------------|--------------|---------------|
| #676 | Absorbed | **closed** (completed 2026-05-21) | No contradiction — closed is consistent with absorption |
| #793 | Absorbed | **open** (labels: `needs-approval`, `spec`, `approved-for-pr`) | **CONFLICT** — spec claims absorbed but issue is still open with approval labels |
| #1370 | Absorbed | **open** (labels: `approved-for-pr`, `[SPEC-FIX]`, `plugin`, `approved-for-plan`) | **CONFLICT** — spec claims absorbed but issue is still open with multiple approval labels |
| #1653 | Absorbed | **open** (labels: `spec-fix`, `test-infrastructure`) | **CONFLICT** — spec claims absorbed but issue is still open |

**Why this is a block:** If #793, #1370, and #1653 are truly superseded by #1832, they should be closed with "superseded by #1832" as the reason. Their open state with approval labels means they may receive separate PRs that conflict with #1832's changes. This is a direct SC-CONFLICT between the spec's stated intent and the actual issue state.

**Recommendation:** Close #793, #1370, and #1653 with "superseded by #1832" before implementation. The spec's "Supersedes" table must reflect reality.

### Finding 3.2: SC-4 vs SC-5 Contradiction in `with-test-home`

The spec says:
- SC-4: `TEST_HOME` must appear in `pass_through_env` array
- SC-5: `OPENCODE_CONFIG_CONTENT` must appear in `env -i` block

Current `with-test-home` (lines 218-244):
```bash
pass_through_env=()
for var in GITHUB_TOKEN GH_TOKEN GH_AUTH_TOKEN SSH_AUTH_SOCK GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL; do
    ...
done

OPENCODE_CONFIG_CONTENT_VALUE='...'
env -i \
    ...
    OPENCODE_CONFIG_CONTENT="$OPENCODE_CONFIG_CONTENT_VALUE" \
    "${pass_through_env[@]}" \
    "$@"
```

**No contradiction** — SC-4 requires `TEST_HOME` in `pass_through_env`, SC-5 requires `OPENCODE_CONFIG_CONTENT` in `env -i`. These are orthogonal. Both pass after implementation.

---

## 4. SC-DETENTION (Dead Code Check)

| Status | WARN | Severity: medium |
|--------|------|-------------------|

### Finding 4.1: `tools/ollama-model-resolve` — Already Deleted

The spec SC-7 requires deleting `tools/ollama-model-resolve`. Grep for `ollama-model-resolve` across the entire `.opencode/` directory returns **zero matches**.

**Evidence:**
- `grep -r "ollama-model-resolve" .opencode/` → no matches
- The file `tools/ollama-model-resolve` does not exist

**Implication:** SC-7 is already satisfied. This is a regression guard that has already been addressed. The spec's "Still needed" list in Phase 3 is partially outdated.

**Recommendation:** Update Phase 3 description to note that SC-7 is already satisfied. This does not block implementation — it's informational.

### Finding 4.2: `behavior_resolve_model()` — Already Removed

The spec states `behavior_resolve_model()` is "already absent" from `helpers.sh`. Verification confirms:
- Grep for `behavior_resolve_model` in `.opencode/tests/behaviors/helpers.sh` returns zero matches
- This is consistent with the spec's claim

---

## 5. SC-VERIFICATION (Verification Method Check)

| Status | FAIL | Severity: **block** |
|--------|------|---------------------|

### Finding 5.1: `string` Evidence Type for Runtime-Behavioral Changes — EVIDENCE_TYPE_MISMATCH

Per `080-code-standards.md` §Evidence Type Taxonomy and `020-go-prohibitions.md` §1 (cost-blind verification), behavioral changes require `behavioral` evidence. The following SCs affect runtime behavior but are classified as `string`:

| SC | Claimed Type | Should Be | Reason |
|----|-------------|-----------|--------|
| SC-2 | `string` | **`behavioral`** | Changes model discovery path — runtime behavior change |
| SC-3 | `string` | **`behavioral`** | Adds cloud provider block — changes which models the agent can dispatch to at runtime |
| SC-4 | `string` | **`behavioral`** | Changes env passthrough — changes what env vars the agent sees at runtime |
| SC-5 | `string` | **`behavioral`** | Preserves env var — changes what env vars the agent sees at runtime |
| SC-6 | `string` | **`behavioral`** | Removes function — changes code path execution |
| SC-15 | `string` | **`behavioral`** | TypeScript compilation — runtime build behavior |

**Why this is a block:** Per `080-code-standards.md` §Evidence Type Taxonomy enforcement matrix, submitting `string` evidence for a behavioral SC is a CRITICAL VIOLATION (EVIDENCE_TYPE_MISMATCH). The spec itself requires `behavioral` evidence for SC-1, SC-17, and SC-18 but uses `string` for 12 other SCs that affect runtime behavior.

**The automatic uplift rule applies:** Per `000-critical-rules.md` §Runtime-Behavioral Evidence Classification Gate, when a change affects runtime behavior, the evidence type is automatically uplifted from `structural`/`string` to `behavioral` regardless of what the author declares.

**Recommendation:** Re-classify SC-2, SC-3, SC-4, SC-5, SC-6, and SC-15 from `string` to `behavioral`. This requires writing corresponding behavioral enforcement tests.

### Finding 5.2: SC-2 Verification Method Is Insufficient

SC-2 claims: "Grep `with-test-home` for `opencode-cli models` in `seed_model_config`"

**Problem:** A `grep` for `opencode-cli models` could match a comment, a string literal, or a different function. The verification method does not verify that the function actually *uses* `opencode-cli models` — only that the string appears somewhere.

**Recommendation:** Strengthen to: "Grep `seed_model_config()` function body (lines X-Y) for `opencode-cli models` — must appear. Grep for `ollama list` in same function body — must not appear."

### Finding 5.3: SC-14 Verification Method Is Ambiguous

SC-14: "Grep for each export name in `plugins/env-loader.ts`"

**Problem:** Five export names to grep for, but the verification method doesn't specify how to handle partial matches (e.g., `parseEnvFile` appearing in a comment).

**Recommendation:** Specify: "Grep for exact function/class declaration patterns: `^export (const|function) (parseEnvFile|isEnvGitignored|writeDiagnostic)$` and `^const DIAGNOSTICS_PATH` and `^interface PluginDiagnostic`"

---

## 6. AUTH-CURRENCY (Authorization Currency)

| Status | PASS |
|--------|------|

**Finding:** No comments exist on issue #1832 (0 comments returned). No authorization comments to check for currency. The issue has labels `spec` and `test-infrastructure` but no `approved-for-*` label — meaning no authorization has been given yet. This is consistent with a pre-implementation audit.

**Verification:** `github_issue_read(method=get_comments, issue_number=1832)` returned empty array `[]`.

---

## 7. CODEBASE-GROUNDING

| Status | WARN | Severity: medium |
|--------|------|-------------------|

### Finding 7.1: `session-enforcement.ts` TypeScript Errors — Not Verified

SC-15 requires fixing "pre-existing TypeScript errors in `session-enforcement.ts`" but the spec does not specify which errors exist. The current `session-enforcement.ts` uses `export default` (line 744), which is the same pattern as `env-loader.ts` — this is likely one of the errors.

**Evidence:**
- `session-enforcement.ts` line 744: `export default async function sessionEnforcementPlugin(input: PluginInput): Promise<Hooks>`
- This uses `export default` with `PluginInput` — same pattern as the broken `env-loader.ts`

**Recommendation:** The spec should explicitly list which TypeScript errors exist in `session-enforcement.ts` and what the fix is. Currently it's too vague for SC-15 to be verifiable.

### Finding 7.2: `tools/ollama-model-resolve` — Already Deleted (Redundant SC-7)

Already covered in Finding 4.1. The file does not exist in the codebase. SC-7 is a no-op.

### Finding 7.3: `test-enforcement.sh` Scenario `ollama-tooling-registration`

The spec SC-9 requires removing `ollama-model-resolve` from this scenario. Grep for `ollama-tooling-registration` in `test-enforcement.sh`:

**No matches found.** The scenario may have been renamed or removed already.

**Recommendation:** Verify the actual scenario name. If it no longer exists, SC-9 is already satisfied.

### Finding 7.4: `verify-authorization.md` Step 0.2

The spec SC-10 requires removing `ollama-model-resolve` from this file. Grep returns zero matches — the reference has already been removed.

**Recommendation:** Verify. If already absent, SC-10 is already satisfied.

---

## 8. SUPERCISION CHECK

| Status | FAIL | Severity: **block** |
|--------|------|---------------------|

### Finding 8.1: Open Issues #793, #1370, #1653 May Conflict With #1832

| Issue | State | Labels | Potential Conflict |
|-------|-------|--------|-------------------|
| #793 | Open | `needs-approval`, `spec`, `approved-for-pr` | Dead code removal — same files as Phase 3 |
| #1370 | Open | `approved-for-pr`, `[SPEC-FIX]`, `plugin`, `approved-for-plan` | Env-loader fix — same files as Phase 1 |
| #1653 | Open | `spec-fix`, `test-infrastructure` | with-test-home fixes — same files as Phase 2 |

**Why this is a block:** If any of these issues receive approval and proceed to implementation independently, they will conflict with #1832's changes to the same files. The spec's "Supersedes" table claims absorption but the issues remain open with approval labels — meaning they may proceed independently.

**Specific conflicts:**
- **#1370** (open, `approved-for-pr`) proposes the same env-loader.ts fix as Phase 1. If #1370 merges first, it may conflict with #1832's Phase 1 changes.
- **#793** (open, `approved-for-pr`) proposes dead code removal that overlaps with Phase 3.
- **#1653** (open) proposes with-test-home fixes that overlap with Phase 2.

**Recommendation:** Before implementation, close #793, #1370, and #1653 with "superseded by #1832" as the state reason. Verify with the issue author that these are truly absorbed.

---

## Summary of Required Actions

### Block Issues (Must Fix Before Implementation)

1. **SC-CONFLICT:** Close superseded issues #793, #1370, #1653 with "superseded by #1832" before implementation begins
2. **SC-VERIFICATION:** Re-classify SC-2, SC-3, SC-4, SC-5, SC-6, SC-15 from `string` to `behavioral` evidence type (automatic uplift per substrate classification)
3. **SUPERCISION:** Verify no open issues conflict with #1832's scope — specifically confirm #793, #1370, #1653 are truly absorbed

### Warnings (Should Fix Before Implementation)

4. **SC-DET:** Add SC-to-test traceability references for behavioral SCs (SC-1, SC-17, SC-18)
5. **SC-DETENTION:** Update Phase 3 description to note SC-7 is already satisfied (file already deleted)
6. **CODEBASE-GROUNDING:** Specify exact TypeScript errors in `session-enforcement.ts` for SC-15
7. **CODEBASE-GROUNDING:** Verify actual scenario name for `test-enforcement.sh` SC-9 reference

### Pass (No Action Needed)

8. **SC-SCOPE:** All SCs are testable and within scope
9. **AUTH-CURRENCY:** No authorization comments to verify (pre-implementation)

---

*Audit performed by opencode (ollama/ornith:35b-256k). All evidence from live tool calls in this session.*
