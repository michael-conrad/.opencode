# Implementation Plan — [#1543](https://github.com/michael-conrad/.opencode/issues/1543) — Phase 2: Holistic Complexity Metric Fix

- **Goal:** Remediate all 56 findings from Phase 1 audit — remove word/line/token count and byte-dispatch formulas as implementation effort proxies across 40+ files. Establish the authoritative principle: tested verified correct code operations passing with 100% clean PASS is the ONLY valid metric.
- **Architecture:** 5 sequential phases — HIGH severity root causes first, then MEDIUM, then LOW bulk propagation, then symbolic rules, then verification re-scan. Each phase remediates a subset of findings from `.opencode/.issues/1542/artifacts/audit-findings.md`.
- **Files:** 40+ files across `.opencode/guidelines/` and `.opencode/skills/*/` (see Phase 1 findings for complete list)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — HIGH Severity Root Cause Remediation

**Concern:** Remove the 7 HIGH severity findings that directly instruct agents to use document size or cost formulas for implementation decisions. These are the root cause patterns that propagate to all other files.

**Files:**
- `guidelines/091-incremental-build.md` (findings 1-2)
- `skills/programming-principles/SKILL.md` (finding 3)
- `skills/programming-principles/tasks/principles.md` (finding 4)
- `guidelines/020-go-prohibitions.md` (findings 12-13)

**SCs:** SC-2, SC-4

**Dependencies:** None

**Entry conditions:** Spec approved, research evidence collected

**Exit conditions:** All 7 HIGH findings remediated, authoritative principle present in all 4 files

- [ ] 1. **Remediate `091-incremental-build.md` — remove "Complexity Metric: Word Count" section (**inline**).** Rewrite lines 45-64 to remove word count as "canonical complexity metric." Remove hard split thresholds (≤3,000/≤4,000/≤2,000 words). Remove symbolic rule `incremental-build-006` ("Task files must not exceed 3000 words"). Add authoritative principle. **→ SC-2, SC-4**

- [ ] 2. **Remediate `programming-principles/SKILL.md` — remove word-count code size limits (**inline**).** Remove or reframe word-count-based code size limits (Python functions ≈100 words, notebook cells ≈120 words, source files ≈750 words). Add authoritative principle. **→ SC-2, SC-4**

- [ ] 3. **Remediate `programming-principles/tasks/principles.md` — remove line-count decomposition thresholds (**inline**).** Remove the "Decomposition Thresholds" table (File > 400 lines → Split, Function > 30 lines → Extract, etc.). Remove `wc -w` and `wc -l` as measurement methods. Add authoritative principle. **→ SC-2, SC-4**

- [ ] 4. **Remediate `020-go-prohibitions.md` — reframe byte-dispatch formulas (**inline**).** Reframe the "Two-Role Context Cost Model" section (§1.1) to explicitly state these are internal operational bookkeeping metrics, NOT implementation complexity measures. Remove or reframe Cost-Frame Dark Prose blocks. Remove word-dispatch arithmetic (`3,000 words × 144 = 432,000 word-dispatches`). Add explicit disclaimer. Add authoritative principle. **→ SC-2, SC-4**

- [ ] 5. **Remediate `000-critical-rules.md` — reframe critical-rules-063 and critical-rules-065 (**inline**).** Reframe byte-dispatch formulas in critical-rules-063 (Orchestrator Context Lean) and critical-rules-065 (Result Contract Frugality) to remove cost-as-effort framing. Add explicit disclaimer that these are operational guidelines, not implementation complexity measures. Add authoritative principle. **→ SC-2, SC-4**

#### Phase 1 VbC

- [ ] 6. **VbC (**clean-room**).** Verify all 7 HIGH findings are remediated — no file contains unreframed word-count-as-complexity or byte-dispatch-as-complexity language. Verify authoritative principle present in all 4 files. **→ SC-2, SC-4**

**Concern transition:** Leaving HIGH severity root causes → entering MEDIUM severity cost language. Phase 2 depends on Phase 1 establishing the authoritative principle text.

## Phase 2 — MEDIUM Severity Cost Language Remediation

**Concern:** Reframe the 10 MEDIUM severity findings that present cost framing as relevant to implementation.

**Files:**
- `guidelines/000-critical-rules.md` (finding 16)
- `skills/writing-plans/tasks/write.md` (finding 17)
- `guidelines/060-tool-usage.md` (findings 10-11)
- `skills/spec-creation/tasks/write.md` (finding 7)
- `skills/brainstorming/tasks/explore/exploration-workflow.md` (finding 8)
- `skills/issue-operations/tasks/comment.md` (finding 9)
- `skills/issue-operations/platforms/github-mcp/SKILL.md` (finding 18)

**SCs:** SC-2, SC-4

**Dependencies:** Phase 1 (authoritative principle text established)

**Entry conditions:** Phase 1 VbC PASS

**Exit conditions:** All 10 MEDIUM findings remediated

- [ ] 7. **Remediate `000-critical-rules.md` — reframe critical-rules-066 (**inline**).** Reframe terminology standardization for cost language to remove cost-as-effort framing. Add explicit note that these terms describe operational bookkeeping, not implementation complexity. **→ SC-2, SC-4**

- [ ] 8. **Remediate `writing-plans/tasks/write.md` — reframe "cost of an extra step" (**inline**).** Reframe line 121 to remove cost-as-effort language. Keep the intent (don't skip steps) but reframe as process discipline, not cost estimation. **→ SC-2, SC-4**

- [ ] 9. **Remediate `060-tool-usage.md` — reframe word-count budget language (**inline**).** Reframe lines 11 and 201 to explicitly state these are operational guidelines for context management, NOT implementation complexity measures. Add explicit disclaimer. **→ SC-2, SC-4**

- [ ] 10. **Remediate `spec-creation/tasks/write.md` — reframe spec length constraints (**inline**).** Reframe line 603 word-count-based spec length constraint as document quality guideline, NOT implementation complexity measure. Add explicit note that spec length does not correlate with implementation effort. **→ SC-2, SC-4**

- [ ] 11. **Remediate remaining MEDIUM findings (**inline**).** Reframe `brainstorming/tasks/explore/exploration-workflow.md:90` (word-count section scaling), `issue-operations/tasks/comment.md:208` (comment length guidance), `issue-operations/platforms/github-mcp/SKILL.md:3` ("wasted effort" language). Add authoritative principle where appropriate. **→ SC-2, SC-4**

#### Phase 2 VbC

- [ ] 12. **VbC (**clean-room**).** Verify all 10 MEDIUM findings are remediated — no file contains unreframed cost-as-effort language. Verify authoritative principle present in all affected files. **→ SC-2, SC-4**

**Concern transition:** Leaving MEDIUM severity cost language → entering LOW severity bulk propagation. Phase 3 depends on Phase 1 and Phase 2 for the authoritative principle text and reframing patterns.

## Phase 3 — LOW Severity Bulk Context Cost Frame Remediation

**Concern:** Reframe or remove the identical context cost frame block in 35 SKILL.md files (findings 19-53) and the 3 result contract word-count constraints (findings 54-56).

**Files:** 35 SKILL.md files (see Phase 1 findings §12 for complete list), plus `approval-gate/tasks/screen-issue.md`, `approval-gate/tasks/screen/screen-issue-gate2.md`, `approval-gate/enforcement/work-state-schema.md`

**SCs:** SC-1, SC-2, SC-4

**Dependencies:** Phase 1, Phase 2

**Entry conditions:** Phase 2 VbC PASS

**Exit conditions:** All 35 context cost frame blocks reframed or removed, all 3 result contract word-count constraints reframed

- [ ] 13. **Reframe context cost frame blocks in 35 SKILL.md files (**inline**).** For each of the 35 files listed in Phase 1 findings §12, reframe the identical context cost frame block to explicitly state these are internal operational bookkeeping metrics, NOT implementation complexity estimation. Add authoritative principle where appropriate. **→ SC-1, SC-2, SC-4**

- [ ] 14. **Reframe result contract word-count constraints (**inline**).** Reframe `approval-gate/tasks/screen-issue.md:38`, `approval-gate/tasks/screen/screen-issue-gate2.md:22,179`, and `approval-gate/enforcement/work-state-schema.md:53` to remove document-size-as-effort framing. **→ SC-2, SC-4**

#### Phase 3 VbC

- [ ] 15. **VbC (**clean-room**).** Verify all 35 context cost frame blocks are reframed or removed. Verify all 3 result contract word-count constraints are reframed. Verify authoritative principle present where appropriate. **→ SC-1, SC-2, SC-4**

**Concern transition:** Leaving LOW severity bulk propagation → entering symbolic rule updates. Phase 4 depends on Phase 1 and Phase 2 for rule changes.

## Phase 4 — Symbolic Rule Updates

**Concern:** Update symbolic rules that enforce word/line count limits or byte-dispatch formulas.

**Files:** `guidelines/091-incremental-build.md`, `guidelines/000-critical-rules.md`

**SCs:** SC-5

**Dependencies:** Phase 1, Phase 2

**Entry conditions:** Phase 3 VbC PASS

**Exit conditions:** All symbolic rules updated

- [ ] 16. **Update `incremental-build-006` in `091-incremental-build.md` (**inline**).** Remove or rewrite the symbolic rule enforcing word-count limit. **→ SC-5**

- [ ] 17. **Update symbolic rules in `000-critical-rules.md` (**inline**).** Update critical-rules-063 and critical-rules-065 to remove byte-dispatch formula enforcement. Update critical-rules-066 to remove cost-language standardization. **→ SC-5**

#### Phase 4 VbC

- [ ] 18. **VbC (**clean-room**).** Verify all symbolic rules updated — no rule enforces word/line count limits or byte-dispatch formulas. **→ SC-5**

**Concern transition:** Leaving symbolic rule updates → entering verification re-scan. Phase 5 depends on all previous phases.

## Phase 5 — Verification Re-Scan

**Concern:** Full re-scan to confirm zero remaining defective patterns.

**Files:** All 40+ files from Phase 1 audit

**SCs:** SC-6

**Dependencies:** Phases 1-4

**Entry conditions:** Phase 4 VbC PASS

**Exit conditions:** Re-scan confirms zero remaining defective patterns, verification artifact written

- [ ] 19. **Re-run Phase 1 audit scan (**inline**).** Re-scan all 40+ files for remaining word/line/token count and byte-dispatch formula patterns. Confirm no new defective patterns introduced. **→ SC-6**

- [ ] 20. **Write verification artifact (**inline**).** Write results to `.opencode/.issues/1543/artifacts/verification.md`. Include per-file status, any remaining findings, and confirmation of authoritative principle presence. **→ SC-6**

#### Phase 5 VbC

- [ ] 21. **VbC (**clean-room**).** Verify re-scan confirms zero remaining defective patterns. Verify verification artifact written and complete. **→ SC-6**

## Exit Criteria

- **C1.** All 56 findings from Phase 1 audit are remediated
- **C2.** No SKILL.md file contains an unreframed "context cost frame" that presents byte-dispatch as implementation complexity
- **C3.** No guideline or task file uses word/line count to estimate implementation effort
- **C4.** All fixes reference Phase 1 findings artifact by path and line range
- **C5.** The authoritative principle (tested verified correct code operations = ONLY metric) is present in all previously defective files
- **C6.** Symbolic rules updated to remove word/line count limits and byte-dispatch formulas
- **C7.** Full re-scan confirms zero remaining defective patterns
- **C8.** Verification artifact written to `.opencode/.issues/1543/artifacts/verification.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.
