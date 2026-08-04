> **Full spec and artifacts: [`.opencode/.issues/2245/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2245)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2245/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
>
> **Issue:** [#2245](https://github.com/michael-conrad/.opencode/issues/2245)


# SPEC — Remove `assert_semantic()` and inline opencode-run evaluation; orchestrator-dispatched clean-room sub-agent evaluation

## 1. Intent and Executive Summary

### Problem Statement

`tests-v2/behaviors/helpers.sh` defines the `assert_semantic()` function block, the only assertion helper in the behavioral test framework. It performs an inline `opencode run` with a clean-room inspector prompt, evaluating model output from `stdout.log`/`stderr.log` inside the script. Twelve behavior scripts call `assert_semantic` inline after `behavior_run`. This conflates artifact generation with evaluation and evaluates against prose logs instead of the authoritative `session.yaml` — directly contradicting the artifact-only paradigm documented in `tests-v2/AGENTS.md`.

### Root Cause / Motivation

The artifact-only paradigm (tests-v2/AGENTS.md §1, §6a) mandates that behavioral test scripts are pure artifact generators that exit 0 unconditionally, and that behavioral SC evaluation is performed by orchestrator-dispatched clean-room sub-agents reading `session.yaml`. `assert_semantic()` violates this: it performs inline, in-script evaluation against stdout/stderr. Because `assert_semantic` is the sole assertion helper and 12 scripts embed it, the framework currently ships generation and evaluation as one inseparable operation. This must be resolved now because it is the last remaining inline-evaluation anti-pattern preventing the two-SC clean-room pattern from being the sole behavioral verification path.

### Approach Chosen

Remove the `assert_semantic()` function definition from `helpers.sh` and convert all 12 call-site behavior scripts to artifact-only generators (calling `behavior_run` then `exit 0`, removing the inline `assert_semantic` call and its comment). Replace the inline evaluation mechanism with a documented orchestrator-dispatched clean-room sub-agent evaluation contract: the sub-agent receives only the artifact directory path, the SC criterion, and `github.owner`/`github.repo`; it reads `session.yaml` (PRIMARY evidence) and returns PASS/FAIL plus a one-sentence justification. Update the three active enforcement docs (`tests-v2/AGENTS.md`, `skills/test-driven-development/SKILL.md`, `skills/verification-before-completion/tasks/verify.md`) to reflect the clean-room evaluation pattern. For `tests-v2/AGENTS.md`, which already has zero `assert_semantic` references, the required change is to explicitly name `assert_semantic` as FORBIDDEN in its assertion-helper list so the prohibition is unambiguous rather than implied by the generic `assert_*` pattern.

### Alternatives Considered & Why Discarded

**Retain `assert_semantic()` but change its evaluation source to `session.yaml`.** Discarded: this preserves inline in-script evaluation, which the artifact-only paradigm forbids regardless of evidence source. Evaluation must be decoupled from generation and dispatched by the orchestrator, not embedded in the script. Keeping the function in any form perpetuates the inline-evaluation anti-pattern.

### Key Design Decisions

- **Evaluation is decoupled from generation.** `behavior_run` produces artifacts; a separate orchestrator-dispatched clean-room sub-agent evaluates them. This decision follows the two-SC pattern (SC-N generates, SC-N+1 evaluates) and costs a clean separation of concerns in exchange for requiring orchestrator dispatch discipline.
- **`session.yaml` remains the PRIMARY evaluation evidence source.** stdout.log/stderr.log are prose/diagnostics only. This decision costs nothing new — it preserves an existing mandate — and guarantees behavioral SC evaluation uses the authoritative SQLite export.
- **Clean-room isolation:** the evaluation sub-agent receives only `{artifact_dir, sc_criterion, github.owner, github.repo}` — no orchestrator reasoning, expected outcomes, or cached results. This costs dispatch rigor and prevents context contamination.
- **Removal order is SC-2/SC-3 (convert scripts) before SC-1 (remove function).** Removing the function while scripts still call it would break sourcing under `set -euo pipefail`. This decision costs a dependency-ordering constraint but prevents a broken-framework state.

### User Intent / Original Prompt

Issue 2245 topic: "Remove assert_semantic() and call sites; replace inline opencode-run evaluation with orchestrator-dispatched clean-room sub-agent evaluation; update docs." This is the analysis-phase trigger that motivated this spec.

## 2. Not Included

- **Historical/archival `.issues/` files** — Dozens of completed plan/spec/artifact files reference `assert_semantic`; these are records of completed work, not active enforcement documentation. This is an explicitly-scoped scope constraint (non-requirement): the system MUST NOT modify these files as part of this change.
- **Fixture content edits** (e.g., `tests-v2/behaviors/fixtures/issues/2230/plan.md`, "Phase 6 — New Behavioral Test" section referencing `assert_semantic`) — test input data. This is an explicitly-scoped scope constraint (non-requirement): updating fixture content is optional and non-blocking for test execution.
- **`tests-v2/test-enforcement.sh`** (content-verification framework) — it greps files, not `assert_semantic`; not affected.
- **`tests-v2/with-test-home` harness** — XDG isolation; not affected.
- **`.opencode/tools/session-to-timeline`** — separate tool; not affected.
- **Other assertion helpers** — none exist in `helpers.sh` besides `assert_semantic`.
- **`behavior_run()` generation logic, artifact directory structure, or `__export_sqlite_to_yaml()`** — unchanged; generation behavior is preserved.
- **Rewriting scenario prompts** — out of scope; only the evaluation mechanism changes.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `assert_semantic()` function block is absent from `tests-v2/behaviors/helpers.sh`, and `helpers.sh` still sources cleanly with no undefined-function references from converted scripts. | structural | `grep` for `assert_semantic` in `helpers.sh` returns empty; `bash -c 'source helpers.sh; :'` succeeds; a converted behavior script runs to exit 0. |
| SC-2 | All 12 behavior scripts remove the inline `assert_semantic` call and its `# Evaluate with assert_semantic` comment. | behavioral | Run each converted script via `bash .opencode/tests-v2/behaviors/<scenario>.sh`; grep each script for the `assert_semantic` token returns empty (call and comment removed). |
| SC-3 | All 12 converted behavior scripts preserve generation behavior: each retains its `behavior_run` invocation arguments and the mandatory cross-reference header, and exits 0 unconditionally. | behavioral | Run each converted script via `bash .opencode/tests-v2/behaviors/<scenario>.sh`; verify exit 0, artifact directory produced with `session.yaml` present, `behavior_run` args unchanged, and header intact. |
| SC-4 | The orchestrator-dispatched clean-room sub-agent evaluation contract is documented in `tests-v2/AGENTS.md`, specifying that the sub-agent receives only artifact dir + SC criterion + `github.owner`/`github.repo`, reads `session.yaml` as PRIMARY source, and returns PASS/FAIL with a one-sentence justification. | string | `grep` `tests-v2/AGENTS.md` for the two-SC pattern and clean-room isolation constraints; contract text present and coherent. |
| SC-5 | `tests-v2/AGENTS.md` explicitly names `assert_semantic` as FORBIDDEN in its assertion-helper list, and reflects the two-SC clean-room evaluation pattern coherently with the artifact-only mandate, `session.yaml`-primary rule, and exit-0 semantics. | string | `grep` `tests-v2/AGENTS.md` for the forbidden-helper list returns a match explicitly naming `assert_semantic` as forbidden; two-SC section and mandate text intact. |
| SC-6 | `skills/test-driven-development/SKILL.md` contains no `assert_semantic` references and describes clean-room sub-agent evaluation (reading `session.yaml`) as the behavioral evidence mechanism, preserving the evidence-type taxonomy and no-lobotomizing mandate. | string | `grep` `skills/test-driven-development/SKILL.md` for `assert_semantic` returns empty; behavioral assertion guidance present. |
| SC-7 | `skills/verification-before-completion/tasks/verify.md` contains no `assert_semantic` reference in its assertion-helper list and references orchestrator-dispatched clean-room sub-agent evaluation, preserving the cross-model validation gate and behavioral-test-run instructions. | string | `grep` `skills/verification-before-completion/tasks/verify.md` for `assert_semantic` returns empty; behavioral run instructions intact. |

## 4. Requirements

- R-1. The system SHALL remove the `assert_semantic()` function definition from `tests-v2/behaviors/helpers.sh`.
- R-2. The system SHALL convert all 12 `assert_semantic` call-site behavior scripts to artifact-only generators by removing the inline `assert_semantic` call and its `# Evaluate with assert_semantic` comment, preserving each script's `behavior_run` invocation arguments, mandatory cross-reference header, and unconditional `exit 0`.
- R-3. The system SHALL replace inline `opencode run` evaluation with orchestrator-dispatched clean-room sub-agent evaluation.
- R-4. The system SHALL document the clean-room sub-agent evaluation contract in `tests-v2/AGENTS.md`, requiring the sub-agent to receive only the artifact directory path, the SC criterion, and `github.owner`/`github.repo`, and to read `session.yaml` as the PRIMARY evidence source.
- R-5. The system SHALL update `tests-v2/AGENTS.md`, `skills/test-driven-development/SKILL.md`, and `skills/verification-before-completion/tasks/verify.md` to remove all `assert_semantic` references; for `tests-v2/AGENTS.md`, where no `assert_semantic` references currently exist, the system SHALL explicitly name `assert_semantic` as FORBIDDEN in the assertion-helper list.
- R-6. The system SHALL preserve behavior test generation behavior during conversion (no change to `behavior_run` invocation args, model, workdir, or agent).
- R-7. Converted behavior scripts SHALL retain the mandatory cross-reference header and exit-0 semantics (artifact-only generator paradigm).
- R-8. The evaluation sub-agent SHALL NOT receive orchestrator reasoning, expected outcomes, or cached results.
- R-11. The orchestrator SHALL dispatch the evaluation via `task()` and SHALL NOT inline the evaluation work.

> **Scope constraints (non-requirements):** The following are explicitly-scoped constraints, not SHALL requirements. They carry no SC because they define what is out of scope rather than what must be delivered. See §2 Not Included.
>
> - R-9. The system SHALL NOT modify historical/archival `.issues/` plan/spec/artifact files referencing `assert_semantic` (out of scope).
> - R-10. Fixture content referencing `assert_semantic` SHALL be treated as test input data; its update is optional and non-blocking.

## 5. Items

### Item 1 (SC-2): Remove the inline `assert_semantic` call and comment from 12 behavior scripts

- RED: grep each of the 12 scripts for the `assert_semantic` call — present (test fails because it should be removed).
- GREEN: Remove the inline `assert_semantic` call and its `# Evaluate with assert_semantic` comment from each script.
- verify: grep each script for `assert_semantic` returns empty (call and comment removed).
- commit: Commit the 12 converted scripts (removal slice).

### Item 2 (SC-3): Verify preservation of generation behavior and exit-0 semantics

- RED: Inspect a converted script — confirm its `behavior_run` invocation args, mandatory cross-reference header, and unconditional `exit 0` are intact.
- GREEN: No code change required if preservation holds; restore any regressed arg/header/exit-0 if a conversion dropped it.
- verify: Run each converted script via `bash .opencode/tests-v2/behaviors/<scenario>.sh`; confirm exit 0, artifact directory with `session.yaml`, `behavior_run` args unchanged, and header present.
- commit: Commit any preservation-restoration fixes together with the conversion slice.

### Item 3 (SC-1): Remove `assert_semantic()` from helpers.sh

- RED: grep `assert_semantic` in `helpers.sh` — present (function still defined).
- GREEN: Delete the `assert_semantic()` function block from `helpers.sh`.
- verify: grep returns empty; `bash -c 'source helpers.sh; :'` succeeds; a converted script sources helpers.sh and exits 0.
- commit: Commit the helper removal.

### Item 4 (SC-4): Document the clean-room sub-agent evaluation contract

- RED: grep `tests-v2/AGENTS.md` for the two-SC clean-room evaluation contract — absent/incomplete.
- GREEN: Add the documented contract specifying sub-agent inputs (artifact dir, SC criterion, `github.owner`/`github.repo`), `session.yaml`-primary evidence, and PASS/FAIL + justification return.
- verify: grep confirms contract text present and coherent.
- commit: Commit the AGENTS.md contract.

### Item 5 (SC-5): Explicitly name `assert_semantic` as FORBIDDEN in `tests-v2/AGENTS.md`

- RED: grep `tests-v2/AGENTS.md` for `assert_semantic` in the forbidden-helper list — not explicitly named (the list names the 6 grep helpers and the generic `assert_*` pattern but not `assert_semantic`).
- GREEN: Add `assert_semantic` to the forbidden-helper list, explicitly marked FORBIDDEN; preserve the artifact-only mandate, `session.yaml`-primary rule, two-SC pattern, and exit-0 semantics.
- verify: grep `tests-v2/AGENTS.md` for `assert_semantic` returns a match explicitly naming it as forbidden; two-SC section and mandate text intact.
- commit: Commit the `tests-v2/AGENTS.md` update.

### Item 6 (SC-6): Update `skills/test-driven-development/SKILL.md`

- RED: grep `assert_semantic` in `skills/test-driven-development/SKILL.md` — present (8 references).
- GREEN: Remove `assert_semantic` references from `skills/test-driven-development/SKILL.md`; describe clean-room sub-agent evaluation (reading `session.yaml`) as the behavioral evidence mechanism; preserve the evidence-type taxonomy and no-lobotomizing mandate.
- verify: grep `assert_semantic` in `skills/test-driven-development/SKILL.md` returns empty; behavioral assertion guidance present.
- commit: Commit the TDD SKILL.md update.

### Item 7 (SC-7): Update `skills/verification-before-completion/tasks/verify.md`

- RED: grep `assert_semantic` in `skills/verification-before-completion/tasks/verify.md` — present (reference in the assertion-helper list in `verify.md`).
- GREEN: Remove the `assert_semantic` reference from the assertion-helper list in `skills/verification-before-completion/tasks/verify.md`; reference orchestrator-dispatched clean-room sub-agent evaluation; preserve the cross-model validation gate and behavioral-test-run instructions.
- verify: grep `assert_semantic` in `skills/verification-before-completion/tasks/verify.md` returns empty; behavioral run instructions intact.
- commit: Commit the verify.md update.

## 6. Dependencies

- **Reference:** `tests-v2/AGENTS.md` §1, §2, §6a (live doc). **Relationship:** Defines the artifact-only paradigm, `session.yaml`-primary rule, and two-SC pattern this spec formalizes. **Status:** Satisfied.
- **Reference:** `2230-sc1-trunk-tip-dispatch.sh` (canonical artifact-only target). **Relationship:** Reference model for the 12 script conversions. **Status:** Satisfied.
- **Reference:** `critical-rules-034/043/048`, `.issues/research-cards/spec-creation-state.md`. **Relationship:** Clean-room discipline — orchestrator MUST NOT inline evaluation; must dispatch via `task()`. **Status:** Satisfied.
- **Reference:** `skills/test-driven-development/SKILL.md` Test Integrity Mandate. **Relationship:** SC-2/SC-3 conversion MUST NOT lobotomize the behavioral signal; evaluation is relocated, not dropped. **Status:** Satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 2 |
| R-2 | SC-2, SC-3 | Phase 1 |
| R-6, R-7 | SC-3 | Phase 1 |
| R-3, R-4, R-8, R-11 | SC-4 | Phase 3 |
| R-5 | SC-5, SC-6, SC-7 | Phase 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| tests-v2/AGENTS.md | doc | `tests-v2/AGENTS.md` (§1, §2, §6a) | live read during analysis; grep for session.yaml-primary, two-SC pattern, and explicit `assert_semantic` forbidden naming |
| assert_semantic() definition | code | `tests-v2/behaviors/helpers.sh` (the `assert_semantic()` function block) | grep of function defs; read of inline `opencode run` block |
| assert_semantic call sites | code | 12 files under `tests-v2/behaviors/` | grep of call sites |
| Canonical artifact-only target | code | `tests-v2/behaviors/2230-sc1-trunk-tip-dispatch.sh` | read of script structure (behavior_run + exit 0) |
| TDD SKILL.md behavioral assertion guidance | doc | `skills/test-driven-development/SKILL.md` | grep of assert_semantic references (8 present) |
| verify.md assertion-helper list | doc | `skills/verification-before-completion/tasks/verify.md` (the assertion-helper list) | grep of assert_semantic reference (in the assertion-helper list) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the function removal costs one grep of helpers.sh and a sourcing check. Skipping means the inline-evaluation function survives as dead code and the inline-evaluation anti-pattern persists.
- **SC-2/SC-3:** Running the 12 converted scripts costs minutes of execution time and produces behavioral evidence of artifact-only generation. Skipping means inline evaluation remains embedded in scripts, and the behavioral signal for those SCs stays conflated with generation.
- **SC-4:** Verifying the documented contract costs one grep of AGENTS.md for the clean-room isolation constraints. Skipping means downstream behavioral SC evaluation has no specified contract and reverts to inline/contaminated evaluation.
- **SC-5/SC-6/SC-7:** Verifying the doc updates costs three greps: one confirming `assert_semantic` is explicitly named forbidden in AGENTS.md, and two confirming absence in the TDD SKILL.md and verify.md. Skipping means stale references instruct agents to use a helper that no longer exists, producing a behavioral-defect death spiral at the assertion-guidance layer.

## 11. Edge Cases

- **Condition:** A converted script is run before SC-1 (function still defined). **Expected behavior:** The script exits 0 (artifact-only, does not call `assert_semantic`). **Resolution:** SC-2/SC-3 run before SC-1 per dependency DAG, so no script calls a removed function.
- **Condition:** A non-converted script still calls `assert_semantic` when SC-1 removes the function. **Expected behavior:** `set -euo pipefail` turns the undefined-function call into an error, breaking sourcing. **Resolution:** Enforced by the SC-2 → SC-1 dependency — all 12 call sites removed before the function is deleted.
- **Condition:** `session.yaml` is absent from an artifact directory during evaluation. **Expected behavior:** The evaluation sub-agent cannot produce a verdict against PRIMARY evidence. **Resolution:** Guard on the GENERATE → EVALUATE_DISPATCHED transition (session.yaml present, exit_code 0); the contract documents session.yaml as required input.
- **Condition:** An orchestrator attempts to inline the evaluation instead of dispatching. **Expected behavior:** Clean-room discipline violation. **Resolution:** R-11 and the documented contract require `task()` dispatch; inline evaluation is forbidden by critical-rules-034/043/048.
- **Condition:** Doc update removes behavioral assertion guidance along with `assert_semantic` references. **Expected behavior:** Behavioral evidence taxonomy and no-lobotomizing mandate are preserved. **Resolution:** SC-6/SC-7 invariants require the clean-room evaluation description to replace, not delete, the behavioral assertion guidance.
- **Condition:** Historical `.issues/` files still reference `assert_semantic` after implementation. **Expected behavior:** They are archival records; not modified. **Resolution:** R-9 explicitly excludes them from scope as a non-requirement scope constraint.
- **Condition:** Three doc updates (SC-5, SC-6, SC-7) are applied concurrently. **Expected behavior:** No conflict — they are independent files. **Resolution:** SC-5/SC-6/SC-7 are mutually independent; applied as separate commits.

## 12. Change Control

| Date | Changed | Why | Authorized By |
|------|---------|-----|---------------|
| 2026-08-04 | Decomposed Item 4 (SC-4, SC-5, SC-6) into three separate per-SC items: Item 4 (SC-4), Item 5 (SC-5), Item 6 (SC-6) | Validation FAILED: single item covered three distinct files (three SCs), violating spec-structure-standards §5 (no item may cover multiple SCs) and 091-incremental-build per-SC decomposition | Validation finding (spec-creation pipeline) |
| 2026-08-04 | (1) Reframed SC-4 (now SC-5): live verification showed `tests-v2/AGENTS.md` has zero `assert_semantic` references and already documents §6a two-SC pattern; the actual doc gap is that the forbidden-helper list does not explicitly name `assert_semantic`. Changed the criterion from "no references" (already true) to "explicitly names `assert_semantic` as FORBIDDEN". (2) Corrected `assert_semantic()` line-range claim from 653-706 to 653-708 (verified def spans 653-708). (3) Decomposed compound SC-2 into SC-2 (removal) and SC-3 (preservation + exit-0), renumbering the doc SCs (SC-4..SC-6 → SC-5..SC-7). (4) Moved R-9/R-10 (orphaned scope constraints with no SC) out of the SHALL requirements into explicit non-requirement scope constraints, removing the "— (scope constraint)" traceability rows. (5) Noted the missing `.opencode/.issues/2245/artifacts/` directory as a deviation; `sc-summary.yaml` present at issue root. | Validation FAILED: SC-4 premise stale; R-9/R-10 orphaned; SC-2 compound; artifacts cross-reference warning | Validation finding (spec-creation pipeline) |
| 2026-08-04 | Replaced all prescriptive line-number references with stable file-area / function-name / section-anchor references: §1 Problem Statement "lines 653-708" → "the `assert_semantic()` function block"; Item 3 (SC-1) GREEN "lines 653-708" → "the `assert_semantic()` function block"; §2 Not Included "line 221" → "Phase 6 — New Behavioral Test" section in `plan.md`; Item 7 (SC-7) RED "line ~270" → "the assertion-helper list in `verify.md`"; §8 Documentation Sources "lines 653-708" and "line ~270" → function block and assertion-helper list anchors. | Validation FAILED on format conformance: prescriptive line-number references violate spec-structure-standards.md "Prohibited Content Patterns" and the stable-anchor cross-reference standard in guidelines/080-code-standards.md. SC semantics, evidence types, and traceability structure unchanged. | Validation finding (spec-creation pipeline) |
