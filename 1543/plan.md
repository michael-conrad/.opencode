# Phase 2 Plan: Holistic Fix — Remediate All Defective Complexity Metric Patterns

**Parent:** [#1541](https://github.com/michael-conrad/.opencode/issues/1541)
**Spec:** [#1543](https://github.com/michael-conrad/.opencode/issues/1543)
**Phase 1 Artifact:** `.opencode/.issues/1542/artifacts/audit-findings.md`

## Overview

Apply corrective changes to all 56 files identified in Phase 1 that incorrectly use word/line/token counts or byte-dispatch formulas as implementation effort proxies. All findings MUST be remediated — no exceptions.

## Single Authoritative Principle

All modifications establish this principle across the codebase:

> **Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity.**

## Scope

- **56 findings** across **40+ files**
- **10 HIGH severity** — directly instruct agents to use document size for implementation decisions
- **10 MEDIUM severity** — present cost framing as relevant to implementation
- **36 LOW severity** — propagate context cost frame blocks

## Phases

### Phase 2.1: HIGH Severity — Root Cause Remediation

Address the 10 HIGH severity findings that directly instruct agents to use document size or cost formulas for implementation decisions.

#### Step 1: `091-incremental-build.md` — Remove "Canonical Complexity Metric" Section

**File:** `guidelines/091-incremental-build.md`
**Lines:** 45-64, 137-138
**Finding:** Word count declared as "canonical complexity metric" with hard split thresholds (≤3,000/≤4,000/≤2,000 words) and symbolic rule enforcing 3,000-word limit.
**Action:**
- Rewrite the "Complexity Metric: Word Count" section to remove all language presenting word count as an implementation complexity metric
- Reframe as document quality/cognitive load guidelines (if retained at all)
- Remove or rewrite the symbolic rule `incremental-build-006` ("Task files must not exceed 3000 words")
- Add the authoritative principle: "Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS"

#### Step 2: `programming-principles/SKILL.md` — Remove Word-Count Code Size Limits

**File:** `skills/programming-principles/SKILL.md`
**Line:** 13
**Finding:** Word-count-based code size limits (Python functions ≈100 words, notebook cells ≈120 words, source files ≈750 words).
**Action:**
- Remove or reframe the word-count code size limits
- If size limits are retained, present them as document quality guidelines, NOT implementation complexity thresholds
- Add the authoritative principle

#### Step 3: `programming-principles/tasks/principles.md` — Remove Line-Count Decomposition Thresholds

**File:** `skills/programming-principles/tasks/principles.md`
**Lines:** 425, 429, 434-444
**Finding:** Line-count-based decomposition thresholds (File > 400 lines → Split, Function > 30 lines → Extract, etc.) and measurement method instructions (wc -w, wc -l).
**Action:**
- Remove or reframe the "Decomposition Thresholds" table
- Remove `wc -w` and `wc -l` as measurement methods for code complexity
- Reframe as document quality guidelines if retained
- Add the authoritative principle

#### Step 4: `020-go-prohibitions.md` — Reframe Byte-Dispatch Formulas

**File:** `guidelines/020-go-prohibitions.md`
**Lines:** 78-114, 164-174
**Finding:** Byte-dispatch formulas (`size × remaining_dispatches²`) presented as cost/complexity model. Cost-Frame Dark Prose blocks with word-dispatch arithmetic (`3,000 words × 144 = 432,000 word-dispatches`).
**Action:**
- Reframe the "Two-Role Context Cost Model" section to explicitly state these are internal operational bookkeeping metrics, NOT implementation complexity measures
- Remove or reframe the Cost-Frame Dark Prose blocks
- Remove the word-dispatch arithmetic (`3,000 words × 144 = 432,000 word-dispatches`)
- Add explicit disclaimer: "These metrics describe internal agent operational efficiency. They are NOT relevant to implementation complexity estimation."
- Add the authoritative principle

#### Step 5: `000-critical-rules.md` — Reframe Critical Rules

**File:** `guidelines/000-critical-rules.md`
**Lines:** 757-758, 760-761
**Finding:** Byte-dispatch formulas in critical-rules-063 and critical-rules-065 presented as binding constraints.
**Action:**
- Reframe critical-rules-063 ("Orchestrator Context Lean") to remove cost-as-effort framing
- Reframe critical-rules-065 ("Result Contract Frugality") to remove cost-as-effort framing
- Add explicit disclaimer that these are operational guidelines, not implementation complexity measures
- Add the authoritative principle

### Phase 2.2: MEDIUM Severity — Cost Language Remediation

Address the 10 MEDIUM severity findings that present cost framing as relevant to implementation.

#### Step 6: `000-critical-rules.md` — Reframe Terminology Standardization

**File:** `guidelines/000-critical-rules.md`
**Lines:** 963-964
**Finding:** Terminology standardization for cost language (critical-rules-066) codifies cost language as standard vocabulary.
**Action:**
- Reframe to remove cost-as-effort framing from the standardized vocabulary
- Add explicit note that these terms describe operational bookkeeping, not implementation complexity

#### Step 7: `writing-plans/tasks/write.md` — Reframe "Cost of an Extra Step"

**File:** `skills/writing-plans/tasks/write.md`
**Line:** 121
**Finding:** "Cost of an extra step" language implies quantifiable step costs relevant to effort estimation.
**Action:**
- Reframe to remove cost-as-effort language
- Keep the intent (don't skip steps) but reframe as process discipline, not cost estimation

#### Step 8: `060-tool-usage.md` — Reframe Word-Count Budget Language

**File:** `guidelines/060-tool-usage.md`
**Lines:** 11, 201
**Finding:** Word-count budget for orchestrator context (≤1,500 words) and word-count comparison for task files vs. result contracts.
**Action:**
- Reframe to explicitly state these are operational guidelines for context management, NOT implementation complexity measures
- Add explicit disclaimer

#### Step 9: `spec-creation/tasks/write.md` — Reframe Spec Length Constraints

**File:** `skills/spec-creation/tasks/write.md`
**Line:** 603
**Finding:** Word-count-based spec length constraint (150-300 words, 1 page max).
**Action:**
- Reframe as document quality guideline, NOT implementation complexity measure
- Add explicit note that spec length does not correlate with implementation effort

#### Step 10: Remaining MEDIUM Findings

**Files:**
- `skills/brainstorming/tasks/explore/exploration-workflow.md:90` — Reframe word-count section scaling guidance
- `skills/issue-operations/tasks/comment.md:208` — Reframe comment length guidance
- `skills/issue-operations/platforms/github-mcp/SKILL.md:3` — Reframe "wasted effort" language

**Action:** Reframe each to remove cost-as-effort framing and add the authoritative principle.

### Phase 2.3: LOW Severity — Bulk Context Cost Frame Remediation

Address the 36 LOW severity findings, primarily the 35 SKILL.md context cost frame blocks.

#### Step 11: Reframe Context Cost Frame Blocks in 35 SKILL.md Files

**Files:** 35 SKILL.md files (see Phase 1 findings §12 for complete list)
**Finding:** Identical context cost frame block in each file presenting byte-dispatch formula as relevant to orchestrator behavior.
**Action:**
- For each file, reframe the context cost frame block to explicitly state:
  - These are internal operational bookkeeping metrics
  - They are NOT relevant to implementation complexity estimation
  - They describe how the orchestrator manages context, not how to estimate work
- OR remove the block entirely if it adds no value to the specific skill's guidance
- Add the authoritative principle where appropriate

#### Step 12: Remaining LOW Findings

**Files:**
- `skills/approval-gate/tasks/screen-issue.md:38` — Reframe word-count result contract constraint
- `skills/approval-gate/tasks/screen/screen-issue-gate2.md:22, 179` — Reframe word-count result contract constraints
- `skills/approval-gate/enforcement/work-state-schema.md:53` — Reframe word-count limit

**Action:** Reframe each to remove document-size-as-effort framing.

### Phase 2.4: Symbolic Rule Updates

#### Step 13: Update Symbolic Rules

**Files:** All files containing symbolic rules related to word/line count or byte-dispatch formulas.
**Action:**
- Update `incremental-build-006` in `091-incremental-build.md` to remove word-count limit
- Update any symbolic rules in `000-critical-rules.md` that reference byte-dispatch formulas
- Add new symbolic rules where needed to enforce the authoritative principle

### Phase 2.5: Verification

#### Step 14: Full Re-Scan Verification

**Action:**
- Re-run the Phase 1 audit scan to verify all findings have been remediated
- Confirm no new defective patterns were introduced
- Verify the authoritative principle is present in all previously defective files
- Write verification artifact to `.opencode/.issues/1543/artifacts/verification.md`

## Success Criteria

| ID | Criterion | Evidence Type | Phase |
|----|-----------|---------------|-------|
| SC-1 | No SKILL.md file contains an unreframed "context cost frame" that presents byte-dispatch as implementation complexity | `behavioral` | 2.3 |
| SC-2 | No guideline or task file uses word/line count to estimate implementation effort | `behavioral` | 2.1, 2.2 |
| SC-3 | All fixes reference Phase 1 findings artifact by path and line range | `string` | All |
| SC-4 | The authoritative principle (tested verified correct code operations = ONLY metric) is present in all previously defective files | `behavioral` | All |
| SC-5 | Symbolic rules updated to remove word/line count limits and byte-dispatch formulas | `behavioral` | 2.4 |
| SC-6 | Full re-scan confirms zero remaining defective patterns | `behavioral` | 2.5 |

## Execution Order

1. **Phase 2.1** (Steps 1-5): HIGH severity root causes — MUST complete first as they are the origin of propagated patterns
2. **Phase 2.2** (Steps 6-10): MEDIUM severity cost language — can proceed in parallel with 2.1
3. **Phase 2.3** (Steps 11-12): LOW severity bulk propagation — depends on 2.1 and 2.2 for the authoritative principle text
4. **Phase 2.4** (Step 13): Symbolic rule updates — depends on 2.1 and 2.2 for rule changes
5. **Phase 2.5** (Step 14): Verification — depends on all previous phases

## Dependencies

- Phase 1 (#1542) audit findings: `.opencode/.issues/1542/artifacts/audit-findings.md`
- Parent spec (#1541): approval for Phase 2
- No other dependencies

## Estimated Scope

- **~45 file modifications** across guidelines and skills
- **~10 symbolic rule updates**
- **1 verification re-scan**
- **1 verification artifact**

---

## Notes on Pipeline Execution

This plan was created after the `writing-plans` 21-step pipeline could not be fully executed due to tool limitations (no sub-agent dispatch available in this environment). The research evidence was gathered by directly reading the Phase 1 audit artifact. All 56 findings from the audit are addressed in this plan.
