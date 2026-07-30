## Objective

Decouple the plan-writing pipeline from the implementation-pipeline skill by creating a static reference card containing ALL workflow content — dispatch strings, enforcement rules, coercion rule, artifact retention, remediation routing, sub-agent routing, and state management guidance — so plans become fully self-contained and the orchestrator no longer depends on loading the implementation-pipeline skill at execution time.

## Background

All content from `skills/implementation-pipeline/` is subsumed into the reference card at `skills/writing-plans/reference/implementation-workflow.md`. The skill directory is deleted entirely. No stripped shell remains — the plan is fully self-contained with zero dependency on the implementation-pipeline skill.

The current design splits dispatch metadata across two locations: the implementation-pipeline TDT (trigger dispatch table in `skills/implementation-pipeline/SKILL.md`) and the plan writer (`skills/writing-plans/tasks/create.md`). The plan writer loads the implementation-pipeline skill at runtime to discover the canonical per-task cycle and dispatch strings. This creates a two-phase lookup: first load the skill, then match against the TDT. Every implementation-pipeline change cascades into every plan because the plan writer is coupled to the live skill.

The same coupling exists for the research task (`research.md` reads the TDT for skill+task selection), the validation task (`validate.md` verifies plans against the TDT), and the plan artifact format specification (`plan-artifact-format.md` references `implementation-pipeline/SKILL.md` as the validation authority). Five audit tasks also reference the pipeline skill for gate-sequence verification. Additionally, approval-gate-scope/SKILL.md and 065-verification-honesty.md reference the DONE_WITH_CONCERNS coercion rule in implementation-pipeline/SKILL.md. The pipeline chain `pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep` appears in the implementation-pipeline/SKILL.md itself (line 304, `Bypassing Mandatory Skill Calls` enforcement block: 'Pipeline chain: pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep') and in tertiary files across .opencode/ that reference the chain for routing context.

The refactoring moves ALL 23 sections of implementation-pipeline content into a static reference card at `skills/writing-plans/reference/implementation-workflow.md`. The plan writer, research task, and validation task read this card instead of loading the live skill. The implementation-pipeline skill directory (`skills/implementation-pipeline/`) is deleted entirely — no files remain. All cross-references across `.opencode/` are updated to point to the new reference card, the applicable replacement guideline, or are removed. The pipeline chain `pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep` is replaced with `pre-work → execute-plan → verification-before-completion → finishing-checklist → review-prep`.

**Two-phase lookup problem eliminated:** Before this change, every plan-write requires: (1) orchestrator loads implementation-pipeline skill, (2) reads TDT for dispatch strings. After this change: plan writer reads a static `.md` file directly — no `skill()` call needed at plan-writing time. The orchestrator reads the plan (which contains baked-in dispatch strings) at execution time, so no skill loading is needed at execution time either.

## Alternatives Considered

### Delete-not-strip vs Strip-dispatch-strings-only

Two approaches were considered for decoupling the plan writer from the implementation-pipeline skill:

**Delete-not-strip (chosen):** Delete the entire `skills/implementation-pipeline/` directory and subsume all content sections into a static reference card. The directory is removed entirely — no files remain. This provides a clean break with no risk of stale files being misinterpreted as active.

**Strip-dispatch-strings-only (rejected):** Remove only the TDT and dispatch strings from the implementation-pipeline SKILL.md, leaving the enforcement rules, state machine, and other content in place. This was rejected because a stripped skill directory is a maintenance liability — future agents may not recognize the directory as deprecated, stale cross-references may accumulate around the remaining files, and the plan writer would still depend on the skill directory existing (just with fewer files inside). Delete-not-strip was chosen because it eliminates ambiguity: the absence of the directory forces all cross-references to be updated, and no future work can accidentally depend on the old skill.

## Not Included

- CHANGELOG.md, README.md — informational only, no structural change
- dispatch-table.yaml — already DEPRECATED
- scripts/session_context_triggers.py — name-only reference
- tmp/rewrite_descriptions.py — throwaway script

## Success Criteria

**All 13 success criteria below MUST pass for implementation to be considered complete. No SC is optional.**

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans/reference/implementation-workflow.md` exists | structural | `ls` |
| SC-2 | Reference card contains all 16 content sections enumerated below from implementation-pipeline/SKILL.md: per-task cycle, 17 canonical dispatch strings, dispatch indicator semantics, audit sequence protocol, DISPATCH_GATE protocol, sub-agent file discovery directive, dispatch context contract, pipeline re-priming enforcement, orchestrator entry criteria, DONE_WITH_CONCERNS coercion rule, remediation routing, 13 pipeline enforcement rules, artifact retention rules, lifecycle manifest event emission, sub-agent context shape, worktree mode | string | grep each section header; authoritative section list at cross-ref-audit.yaml CREATE_TARGET.sections |
| SC-3 | `create.md` reads the reference card instead of loading the implementation-pipeline TDT | behavioral | `opencode run` with plan-writing scenario, stderr shows reference card read |
| SC-4 | `research.md` reads the reference card for skill+task selection instead of implementation-pipeline TDT | behavioral | `opencode run` with research scenario |
| SC-5 | `validate.md` validates against the reference card instead of implementation-pipeline TDT | behavioral | `opencode run` with validate scenario |
| SC-6 | `plan-artifact-format.md` validation rule references the reference card | string | grep |
| SC-7 | `skills/implementation-pipeline/` deleted entirely — all files (SKILL.md, enforcement/*.md, pipeline-state-machine.yaml) removed. All 23 sections of content subsumed into reference card or appropriate destinations | string + structural | `ls` confirms directory absent; grep confirms no orphaned path references |
| SC-8 | ALL cross-references to `skills/implementation-pipeline/` across `.opencode/` updated — every reference redirected to `skills/writing-plans/reference/implementation-workflow.md`, applicable replacement guideline, or removed. Sub-groups: (a) 5 audit tasks, (c) 065-verification-honesty.md (Pre-Response Factual Claim Gate section — TDT URL extraction ref), (e) tertiary files with pipeline chain refs | string | grep cross-ref count comparison per sub-group |
| SC-9 | Pipeline chain replacement — old chain `pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep` replaced with `pre-work → execute-plan → verification-before-completion → finishing-checklist → review-prep` in: implementation-pipeline/SKILL.md enforcement block (deleted via SC-7) and tertiary files across `.opencode/` | string | grep for old chain pattern; assert absent |
| SC-10 | Behavioral enforcement tests exist for the new plan-writing workflow (create.md reads card, validate.md validates against card) and for the delete-not-strip approach (implementation-pipeline directory absent) | behavioral | `opencode run` with enforcement test scenario |
| SC-11 | Coercion rule preserved — DONE_WITH_CONCERNS coercion rule moves to reference card; approval-gate-scope/SKILL.md and 065-verification-honesty.md references updated to point to reference card | string | grep |
| SC-12 | State management guidance moved to reference card as optional section (solve state no longer required — plan order IS the state machine) | structural | `ls` + grep |
| SC-13 | Enforcement directory contents (4 files) merged into reference card or deleted; no orphaned references | string | grep |

## Requirements

The spec SHALL:

1. **REQ-1**: Create a static reference card at `skills/writing-plans/reference/implementation-workflow.md` containing all content sections from implementation-pipeline/SKILL.md.

2. **REQ-2**: Update `skills/writing-plans/tasks/create.md` to read the reference card instead of loading the implementation-pipeline TDT at runtime. Replace "Load the implementation-pipeline TDT" with "Read the implementation-workflow reference card".

3. **REQ-3**: Update `skills/writing-plans/tasks/research.md` to read the reference card for skill+task selection instead of the implementation-pipeline TDT.

4. **REQ-4**: Update `skills/writing-plans/tasks/validate.md` to verify plan skill+task references against the reference card instead of the implementation-pipeline TDT.

5. **REQ-5**: Update `skills/writing-plans/reference/plan-artifact-format.md` — replace the validation rule referencing `implementation-pipeline/SKILL.md` with a reference to the new reference card.

6. **REQ-6**: DELETE `skills/implementation-pipeline/` entirely. All 23 content sections subsumed into the reference card or appropriate destinations. State management (solve state) is deleted — plan step order IS the state machine. DONE_WITH_CONCERNS coercion rule moves to reference card. Enforcement rules move to reference card. Enforcement reference docs (4 files) merged into reference card.

7. **REQ-7**: Update ALL cross-references to implementation-pipeline across `.opencode/`. Every reference to `skills/implementation-pipeline/SKILL.md` or any path under `skills/implementation-pipeline/` must be redirected to `skills/writing-plans/reference/implementation-workflow.md`, the applicable replacement guideline, or removed. This includes 5 audit tasks, 065-verification-honesty.md (Pre-Response Factual Claim Gate section), and all tertiary files.

8. **REQ-8**: Pipeline chain replacement — old chain `pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep` replaced with `pre-work → execute-plan → verification-before-completion → finishing-checklist → review-prep` in: implementation-pipeline/SKILL.md enforcement block (deleted via SC-7) and tertiary files across `.opencode/`.

9. **REQ-9**: Add behavioral enforcement tests verifying the plan writer reads the reference card, the validator checks against the card, and the implementation-pipeline directory is deleted (not stripped).

10. **REQ-10**: Coercion rule migration verified across all consumers — approval-gate-scope/SKILL.md and 065-verification-honesty.md must reference the reference card for the DONE_WITH_CONCERNS coercion rule, not the deleted skill.

11. **REQ-11**: No orphaned references to deleted paths remain — final grep sweep confirms zero matches for `skills/implementation-pipeline/` across all `.opencode/` files.

## Items

| Item | Phase | SC | Description | Concern | Files |
|------|-------|----|-------------|---------|-------|
| 1 | 1 | SC-1 | Create reference card file | Reference card creation | `skills/writing-plans/reference/implementation-workflow.md` |
| 2 | 1 | SC-2 | Populate card with ALL 23 sections from pipeline skill | Reference card creation | `skills/writing-plans/reference/implementation-workflow.md` |
| 3 | 2 | SC-3 | Update create.md to read reference card | Plan writer update | `skills/writing-plans/tasks/create.md` |
| 4 | 2 | SC-4 | Update research.md to read reference card | Plan writer update | `skills/writing-plans/tasks/research.md` |
| 5 | 2 | SC-5 | Update validate.md to validate against reference card | Plan writer update | `skills/writing-plans/tasks/validate.md` |
| 6 | 2 | SC-6 | Update plan-artifact-format.md validation rule | Plan writer update | `skills/writing-plans/reference/plan-artifact-format.md` |
| 7 | 3 | SC-7 | DELETE skills/implementation-pipeline/ entirely | Source skill deletion | `skills/implementation-pipeline/` (all files) |
| 8 | 3 | SC-8 | Update ALL cross-references — sub-groups: (a) 5 audit tasks, (c) 065-verification-honesty.md (Pre-Response Factual Claim Gate section — TDT URL extraction ref), (e) tertiary files with pipeline chain refs | Cross-reference update | All `.opencode/` files per cross-ref-audit.yaml |
| 9 | 3 | SC-9 | Pipeline chain updates (pre-work → execute-plan) across tertiary files | Pipeline chain rename | All `.opencode/` files with old chain pattern |
| 10 | 4 | SC-10 | Add behavioral enforcement tests (plan-writer + delete-not-strip) | Cleanup | New test files under `.opencode/tests-v2/behaviors/` |
| 11 | 3 | SC-11 | Coercion rule migration — move DONE_WITH_CONCERNS rule to reference card, update approval-gate-scope and 065-verification-honesty refs | Coercion rule | reference card, approval-gate-scope/SKILL.md, 065-verification-honesty.md |
| 12 | 3 | SC-12 | Enforcement doc merge + cleanup — merge 4 enforcement directory files into reference card, delete originals | Enforcement docs | reference card, enforcement/*.md |
| 13 | 4 | SC-13 | Orphan reference sweep — final grep for any remaining `skills/implementation-pipeline/` references | Cleanup | All `.opencode/` files |

## Dependencies

- **Prerequisite skills**: `implementation-pipeline` — provides source data for migration before deletion (all 23 content sections consumed into reference card before directory removal)
- **Related skills**: `writing-plans` — all plan-writing tasks being updated; `audit` — cross-references updated (5 audit files); `approval-gate-scope` — coercion rule redirect
- **Guidelines**: `080-code-standards.md` — behavioral test mandate for guideline/skill changes; `065-verification-honesty.md` — coercion rule refs updated
- **No other spec dependencies** — this is a standalone refactoring

## Risks and Edge Cases

### File path conflicts
The reference card at `skills/writing-plans/reference/implementation-workflow.md` occupies a path previously unused. Ensure no existing or planned file uses this path. The `skills/writing-plans/reference/` directory already exists for `plan-artifact-format.md`, so the parent directory is established.

### Partial cross-reference updates
If a cross-reference to `skills/implementation-pipeline/` is missed during the migration, the reference will dangle after the directory is deleted. Mitigation: SC-13 requires a final grep sweep confirming zero matches for `skills/implementation-pipeline/` across all `.opencode/` files. The grep sweep MUST run after all other changes are committed.

### Behavioral test infrastructure failure preconditions
Behavioral tests (SC-10) require `opencode run` with a test harness. Preconditions:
- Standalone opencode binary available at `.tools/opencode/opencode` or installable
- `with-test-home` wrapper functional
- AI model (default or configured) responds within timeout
- Test home directory at `./tmp/test-home-*` is writable and not locked

If infrastructure is unavailable, SC-10 cannot be verified with behavioral evidence, and the SC would FAIL per the Evidence Type Taxonomy (behavioral evidence requires test execution).

## Traceability

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| REQ-1 | SC-1, SC-2 | Phase 1 |
| REQ-2 | SC-3 | Phase 2 |
| REQ-3 | SC-4 | Phase 2 |
| REQ-4 | SC-5 | Phase 2 |
| REQ-5 | SC-6 | Phase 2 |
| REQ-6 | SC-7 | Phase 3 |
| REQ-7 | SC-8 | Phase 3 |
| REQ-8 | SC-9 | Phase 3 |
| REQ-9 | SC-10 | Phase 4 |
| REQ-10 | SC-11 | Phase 3 |
| REQ-11 | SC-13 | Phase 4 |

> **Full spec and artifacts: [`.opencode/.issues/2203/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2203)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2203/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-30 | Full revision: approach changed from "strip dispatch strings" to "DELETE entire implementation-pipeline/ directory and subsume all 23 content sections into reference card". Added SC-11 (coercion rule), SC-12 (state management), SC-13 (orphan sweep). Updated ALL REQs 6-11, Items 7-13, phases, cross-ref scope, background, not-included, dependencies, and traceability. | Developer directive — complete approach pivot | opencode (deepseek-v4-flash-free) |
| 2026-07-30 | Item 8: removed approval-gate-scope/SKILL.md, split into explicit groups (plan-fidelity-evaluator + 4 verification-audit tasks replace dispatch-string refs; 065-verification-honesty.md line 413 updated, lines 318/453 preserved) | Finding 1 (consistency FAIL) + Finding 2 (scope fidelity FAIL) | opencode (deepseek-v4-flash-free) |
| 2026-07-30 | SC-8: clarified which cross-references get updated vs preserved; added explicit line-number scope for 065-verification-honesty.md | Finding 1 — SC-8 was ambiguous about which of 065-verification-honesty.md's 3 references should be updated | opencode (deepseek-v4-flash-free) |
| 2026-07-30 | REQ-7: split into dispatch-string-only scope with explicit preservation boundaries for approval-gate-scope/SKILL.md and 065-verification-honesty.md lines 318/453 | Finding 1 — REQ-7 lacked scope boundaries, allowing contradictory interpretation with Dependencies section | opencode (deepseek-v4-flash-free) |
| 2026-07-30 | SC-2/REQ-1: fixed string count parenthetical "(pre-regression through exec-summary)" → "(pre-regression through exec-summary plus step-dispatch)" — 17 total includes step-dispatch; "through exec-summary" yields 16 | Validator finding — string count mismatch | opencode (deepseek-v4-flash-free) |
| 2026-07-30 | Validation fixes: Background — removed false 000-critical-rules.md claim (live grep confirms zero occurrences). SC-2/REQ-1 — "23 content sections" replaced with accurate count-free references (source SKILL.md has 16 ##-level sections). SC-8 — removed (b) 000-critical-rules.md and (d) approval-gate-scope (SC-11 covers coercion rule). SC-8(c) — scoped to line 413 only (TDT URL extraction ref). SC-9/REQ-8 — removed 000-critical-rules.md from scope, clarified replacement scope. Item 8 — removed overlapping sub-groups. REQ-7 — removed 000-critical-rules.md and approval-gate-scope from file list. | 5 validation failures from spec audit | opencode (deepseek-v4-flash-free) |
| 2026-07-30 | SC-2: replaced "All content sections" with "all 16 content sections enumerated below"; added cross-ref note to Verification Method. SC-8(c): replaced fragile line 413 with stable "Pre-Response Factual Claim Gate section" anchor. REQ-7 / Item 8: same stable anchor. Added Alternatives Considered section (delete-not-strip vs strip-dispatch-strings-only). Added Risks and Edge Cases section (file path conflicts, partial cross-ref updates, behavioral test infrastructure preconditions). | Remediate 3 audit findings from spec-audit (FAIL 1: open-ended SC-2; FAIL 2: fragile line reference; FAIL 3: analytical gaps) | opencode (deepseek-v4-flash-free) |
