---
plan_schema_version: 1
lifecycle_events:
  - timestamp: "2026-08-04T06:14:33Z"
    event: plan_created
    plan_path: .opencode/.issues/2245/plan.md
    phase_count: 4
issue: 2245
title: "Remove assert_semantic() and call sites; orchestrator-dispatched clean-room sub-agent evaluation"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2245 — Remove assert_semantic() and Replace with Clean-Room Sub-Agent Evaluation

**Issue:** [https://github.com/michael-conrad/.opencode/issues/2245](https://github.com/michael-conrad/.opencode/issues/2245)

**Goal:** Remove the `assert_semantic()` function from `tests-v2/behaviors/helpers.sh` and its 12 call sites, converting those behavior scripts to artifact-only generators, and replace inline `opencode run` evaluation with a documented orchestrator-dispatched clean-room sub-agent evaluation contract.

**Architecture:** Four dependency-ordered phases in a single stacked PR. Phase 1 converts the 12 call-site behavior scripts to artifact-only generators (removing the inline `assert_semantic` call and comment, preserving `behavior_run` args, mandatory header, and unconditional exit 0). Phase 2 removes the `assert_semantic()` function definition from `helpers.sh` after all call sites are gone. Phase 3 documents the clean-room sub-agent evaluation contract in `tests-v2/AGENTS.md`. Phase 4 updates the three enforcement docs: explicitly names `assert_semantic` FORBIDDEN in `tests-v2/AGENTS.md` (SC-6), and removes `assert_semantic` references from `test-driven-development/SKILL.md` (SC-7) and `verification-before-completion/tasks/verify.md` (SC-8), replacing the behavioral assertion guidance with the clean-room sub-agent evaluation mechanism.

**Files:**
- `tests-v2/behaviors/helpers.sh` — remove `assert_semantic()` function block
- 12 call-site scripts under `tests-v2/behaviors/`: `2219-sc10-non-pointer-guard.sh`, `2219-sc11-existing-cleanup.sh`, `2219-sc15-decline-submodule-pr.sh`, `2219-sc16-stale-pointer-block.sh`, `2219-sc19-release-pr-prework.sh`, `2219-sc3-prework-ordering.sh`, `2219-sc6-dead-branch-detection.sh`, `2219-sc7-submodule-pr-verification.sh`, `2219-sc8-dead-branch-deletion.sh`, `2219-sc9-dirty-pointer.sh`, `2239-sc8-check-pr-routing.sh`, `skill-deck-completeness.sh` — convert to artifact-only generators
- `tests-v2/AGENTS.md` — document clean-room contract (SC-5), explicitly name `assert_semantic` FORBIDDEN (SC-6)
- `skills/test-driven-development/SKILL.md` — remove `assert_semantic` references, describe clean-room sub-agent evaluation (SC-7)
- `skills/verification-before-completion/tasks/verify.md` — remove `assert_semantic` reference, reference clean-room evaluation (SC-8)

**Dispatch:** `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `completion-core`

## Blast Radius

- **helpers.sh:** removal of the only assertion helper — no other helper exists, so no collateral impact on other assertions
- **12 behavior scripts:** conversion removes inline evaluation; `behavior_run` invocation args, mandatory header, and exit-0 semantics preserved — no change to generation behavior or scenario prompts
- **tests-v2/AGENTS.md:** contract documentation and forbidden-helper naming — §1, §2, §6a coherence maintained
- **test-driven-development/SKILL.md:** replaces `assert_semantic` references with clean-room evaluation description — evidence-type taxonomy and no-lobotomizing mandate preserved
- **verification-before-completion/tasks/verify.md:** removes `assert_semantic` from assertion-helper list — cross-model validation gate and behavioral-test-run instructions preserved
- **No changes to:** historical/archival `.issues/` files (R-9 scope constraint), fixture content (R-10), `test-enforcement.sh`, `with-test-home`, `session-to-timeline`, scenario prompts

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Convert 12 behavior scripts | Remove inline assert_semantic calls/comments; preserve contract and exit-0 | SC-2, SC-3, SC-4 | — | 3–14 | test-driven-development, verification-before-completion |
| 2 | Remove assert_semantic() | Delete function definition; verify sourcing integrity | SC-1 | Phase 1 | 15–18 | test-driven-development, verification-before-completion |
| 3 | Document clean-room contract | Replace inline evaluation with documented dispatch contract | SC-5 | Phase 2 | 19–22 | test-driven-development, verification-before-completion |
| 4 | Update enforcement docs | Forbid assert_semantic; purge from TDD SKILL and verify.md | SC-6, SC-7, SC-8 | Phase 3 | 23–34 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate:** Verify spec/plan coherence — confirm the spec at `.opencode/.issues/2245/spec.md` matches the plan structure. The spec defines 8 SCs across 4 dependency-ordered phases — this plan covers all 8. (**inline**)
- [ ] 2. **Baseline check:** Verify all target files exist and are readable: `tests-v2/behaviors/helpers.sh`, the 12 call-site behavior scripts, `tests-v2/AGENTS.md`, `skills/test-driven-development/SKILL.md`, `skills/verification-before-completion/tasks/verify.md`. Verify the 12 call-site count matches the spec (exclude `helpers.sh` which holds the definition). (**inline**)

---

## Phase 1 — Convert 12 Behavior Scripts

**Concern:** Remove inline `assert_semantic` calls and comments from 12 call-site behavior scripts; preserve `behavior_run` args, mandatory header, and exit-0 artifact-only semantics.

**Files:** 12 scripts under `tests-v2/behaviors/`: `2219-sc10-non-pointer-guard.sh`, `2219-sc11-existing-cleanup.sh`, `2219-sc15-decline-submodule-pr.sh`, `2219-sc16-stale-pointer-block.sh`, `2219-sc19-release-pr-prework.sh`, `2219-sc3-prework-ordering.sh`, `2219-sc6-dead-branch-detection.sh`, `2219-sc7-submodule-pr-verification.sh`, `2219-sc8-dead-branch-deletion.sh`, `2219-sc9-dirty-pointer.sh`, `2239-sc8-check-pr-routing.sh`, `skill-deck-completeness.sh`

**SCs:** SC-2, SC-3, SC-4

**Dependencies:** —

**Entry:** Pre-implementation complete; baseline confirms 12 call sites

**Exit:** All 12 scripts call `behavior_run` then `exit 0`; no `assert_semantic` token; `behavior_run` args and mandatory header intact

**Code Path Coverage:** Each script's `assert_semantic` call and `# Evaluate with assert_semantic` comment block; the `behavior_run` invocation; the mandatory cross-reference header (shebang + behavioral-test comment + AGENTS.md reference + artifact-only generator statement); the unconditional `exit 0` tail.

**Cross-Cutting SCs:** None — SC-2, SC-3, SC-4 are all call-site specific.

**Interface Boundaries:** No external API calls. Text edits to 12 shell scripts under `set -euo pipefail`. `helpers.sh` is sourced but its `assert_semantic` definition is untouched in this phase (removed in Phase 2).

**State Transitions:** Each script transitions from inline-evaluating generator to artifact-only generator. After conversion the script exits 0 without calling `assert_semantic` — it remains sourceable while `helpers.sh` still defines the function (SC-2/3/4 precede SC-1).

**Cost frame:** Running the 12 converted scripts costs minutes of execution time and produces behavioral evidence of artifact-only generation. Skipping means inline evaluation remains embedded in the scripts and the behavioral signal for these SCs stays conflated with generation.

- [ ] 3. **RED** — For SC-2, write an enforcement test that greps each of the 12 scripts for the `assert_semantic` call token. Verify the test FAILS (the token is present because the removal hasn't happened). Record the failing evidence. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-2, files: [12 call-site scripts], assertion: grep for assert_semantic returns non-empty}`
- [ ] 4. **GREEN** — Remove the inline `assert_semantic` call and its `# Evaluate with assert_semantic` comment from each of the 12 scripts. Leave the `behavior_run` invocation and the unconditional `exit 0` unchanged. Do not modify scenario prompts or the mandatory header. (**sub-agent**)
  - Context: `{issue_number: 2245, sc: SC-2, files: [12 call-site scripts], action: remove assert_semantic call + comment, preserve: behavior_run args, mandatory header, exit 0}`
- [ ] 5. **Verify** — For SC-2, grep each of the 12 scripts for the `assert_semantic` token. Confirm all return empty (call and comment removed). (**inline**)
- [ ] 6. **Commit** — `git add tests-v2/behaviors/ && git commit -m "phase-1(#2245): remove inline assert_semantic calls from 12 behavior scripts (SC-2)"` (**inline**)
- [ ] 7. **RED** — For SC-3, inspect a converted script and confirm the `behavior_run` invocation arguments and the mandatory cross-reference header are intact. If preservation holds, the test confirms the contract; assert it FAILS only if a conversion dropped an arg or header element. Record the failing evidence if any. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-3, files: [12 call-site scripts], assertion: behavior_run args unchanged + mandatory header present}`
- [ ] 8. **GREEN** — If the SC-3 RED test detected any regression in `behavior_run` args or the mandatory header, restore them. If preservation holds, no code change is required — the GREEN is a no-op confirming preservation. (**sub-agent**)
  - Context: `{issue_number: 2245, sc: SC-3, action: restore any regressed behavior_run arg/header, preserve: mandatory cross-reference header}`
- [ ] 9. **Verify** — For SC-3, run each converted script via `bash tests-v2/behaviors/<scenario>.sh` and confirm the `behavior_run` invocation arguments are unchanged and the mandatory header is present. (**inline**)
- [ ] 10. **Commit** — If any arg/header restoration fixes were made, commit them together with the conversion slice. If no fixes were needed, this step is a no-op. (**inline**)
- [ ] 11. **RED** — For SC-4, run a converted script and confirm it exits 0 and produces an artifact directory containing `session.yaml`. Assert this FAILS if the script exits non-zero or omits `session.yaml`. Record the failing evidence if any. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-4, assertion: exit code 0 + artifact dir with session.yaml}`
- [ ] 12. **GREEN** — If the SC-4 RED test detected any regression in the unconditional `exit 0` or artifact production, restore it. If exit-0 semantics hold, the GREEN is a no-op confirming artifact-only generation. (**sub-agent**)
  - Context: `{issue_number: 2245, sc: SC-4, action: restore any regressed unconditional exit 0, preserve: artifact directory + session.yaml}`
- [ ] 13. **Verify** — For SC-4, run each converted script via `bash tests-v2/behaviors/<scenario>.sh` and confirm exit 0 and an artifact directory with `session.yaml` present. (**inline**)
- [ ] 14. **Commit** — If any exit-0/artifact restoration fixes were made, commit them together with the conversion slice. If none, this step is a no-op. (**inline**)

> **Phase 1 complete.** VbC: SC-2, SC-3, SC-4 all PASS. All 12 scripts converted to artifact-only generators. Proceed to Phase 2.

---

## Phase 2 — Remove assert_semantic()

**Concern:** Delete the `assert_semantic()` function definition from `helpers.sh`; verify sourcing integrity.

**Files:** `tests-v2/behaviors/helpers.sh`

**SCs:** SC-1

**Dependencies:** Phase 1

**Entry:** Phase 1 complete; no script calls `assert_semantic`

**Exit:** `assert_semantic` absent from `helpers.sh`; `helpers.sh` sources cleanly with no undefined-function references

**Code Path Coverage:** The `assert_semantic()` function block in `helpers.sh`; the sourcing chain that loads `helpers.sh` (all behavior scripts source it via `SCRIPT_DIR/helpers.sh`).

**Cross-Cutting SCs:** None — SC-1 is helper-specific.

**Interface Boundaries:** `helpers.sh` is sourced by all behavior scripts under `set -euo pipefail`. Removing the function must not leave an undefined-function reference that breaks sourcing.

**State Transitions:** `helpers.sh` drops the `assert_semantic` definition. Because Phase 1 removed all call sites, no script references the removed function — sourcing remains valid.

**Cost frame:** Verifying the function removal costs one grep of `helpers.sh` and a sourcing check. Skipping means the inline-evaluation function survives as dead code and the inline-evaluation anti-pattern persists.

- [ ] 15. **RED** — For SC-1, grep `helpers.sh` for `assert_semantic`. Verify the test FAILS (the function is still defined). Record the failing evidence. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-1, file: tests-v2/behaviors/helpers.sh, assertion: grep for assert_semantic returns non-empty}`
- [ ] 16. **GREEN** — Delete the `assert_semantic()` function block from `helpers.sh`. Do not modify any other helper or the generation logic. (**sub-agent**)
  - Context: `{issue_number: 2245, file: tests-v2/behaviors/helpers.sh, action: remove assert_semantic function block, preserve: all other helpers and behavior_run generation logic}`
- [ ] 17. **Verify** — For SC-1, grep `helpers.sh` for `assert_semantic` returns empty; run `bash -c 'source tests-v2/behaviors/helpers.sh; :'` and confirm it succeeds with no undefined-function references; confirm a converted script sources `helpers.sh` and exits 0. (**inline**)
- [ ] 18. **Commit** — `git add tests-v2/behaviors/helpers.sh && git commit -m "phase-2(#2245): remove assert_semantic() from helpers.sh (SC-1)"` (**inline**)

> **Phase 2 complete.** VbC: SC-1 PASS. `assert_semantic()` removed from `helpers.sh`. Proceed to Phase 3.

---

## Phase 3 — Document Clean-Room Contract

**Concern:** Document the orchestrator-dispatched clean-room sub-agent evaluation contract in `tests-v2/AGENTS.md`, replacing the inline-evaluation mechanism.

**Files:** `tests-v2/AGENTS.md`

**SCs:** SC-5

**Dependencies:** Phase 2

**Entry:** Phase 2 complete; inline evaluation mechanism removed

**Exit:** `tests-v2/AGENTS.md` documents the clean-room sub-agent evaluation contract with sub-agent inputs, `session.yaml`-primary evidence, and PASS/FAIL + justification return

**Code Path Coverage:** The two-SC pattern and clean-room isolation sections of `tests-v2/AGENTS.md` (§1, §6a).

**Cross-Cutting SCs:** None — SC-5 is contract-documentation specific.

**Interface Boundaries:** `tests-v2/AGENTS.md` is the canonical test harness spec. The contract must integrate coherently with the artifact-only mandate, the `session.yaml`-primary rule, and exit-0 semantics.

**State Transitions:** No runtime state transition — documentation-only. Downstream behavioral SC evaluation gains a specified contract for orchestrator dispatch.

**Cost frame:** Verifying the documented contract costs one grep of `AGENTS.md` for the clean-room isolation constraints. Skipping means downstream behavioral SC evaluation has no specified contract and reverts to inline/contaminated evaluation.

- [ ] 19. **RED** — For SC-5, grep `tests-v2/AGENTS.md` for the two-SC clean-room evaluation contract. Verify the test FAILS (the contract text is absent/incomplete). Record the failing evidence. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-5, file: tests-v2/AGENTS.md, assertion: two-SC clean-room contract text absent/incomplete}`
- [ ] 20. **GREEN** — Add the documented clean-room sub-agent evaluation contract to `tests-v2/AGENTS.md`. The contract MUST specify the sub-agent receives only the artifact directory path, the SC criterion, and `github.owner`/`github.repo`; reads `session.yaml` as the PRIMARY evidence source; and returns PASS/FAIL with a one-sentence justification. It MUST NOT receive orchestrator reasoning, expected outcomes, or cached results. (**sub-agent**)
  - Context: `{issue_number: 2245, file: tests-v2/AGENTS.md, action: add clean-room contract, inputs: artifact_dir + sc_criterion + github.owner + github.repo, evidence: session.yaml PRIMARY, return: PASS/FAIL + one-sentence justification}`
- [ ] 21. **Verify** — For SC-5, grep `tests-v2/AGENTS.md` for the two-SC pattern and clean-room isolation constraints. Confirm the contract text is present and coherent. (**inline**)
- [ ] 22. **Commit** — `git add tests-v2/AGENTS.md && git commit -m "phase-3(#2245): document clean-room sub-agent evaluation contract (SC-5)"` (**inline**)

> **Phase 3 complete.** VbC: SC-5 PASS. Clean-room contract documented. Proceed to Phase 4.

---

## Phase 4 — Update Enforcement Docs

**Concern:** Explicitly forbid `assert_semantic` in `tests-v2/AGENTS.md` (SC-6) and remove `assert_semantic` references from `test-driven-development/SKILL.md` (SC-7) and `verification-before-completion/tasks/verify.md` (SC-8), replacing the inline-evaluation guidance with the clean-room sub-agent evaluation mechanism.

**Files:** `tests-v2/AGENTS.md`, `skills/test-driven-development/SKILL.md`, `skills/verification-before-completion/tasks/verify.md`

**SCs:** SC-6, SC-7, SC-8

**Dependencies:** Phase 3

**Entry:** Phase 3 complete; clean-room contract documented

**Exit:** `tests-v2/AGENTS.md` explicitly names `assert_semantic` FORBIDDEN; `test-driven-development/SKILL.md` and `verify.md` contain no `assert_semantic` references and describe clean-room evaluation

**Code Path Coverage:** The forbidden-assertion-helper list in `tests-v2/AGENTS.md`; the `assert_semantic` references in `test-driven-development/SKILL.md` (8 references: assertion-helper table, definition, required-pattern examples, no-lobotomizing prohibited patterns, evidence-type table, hard-rule); the assertion-helper list in `verify.md`.

**Cross-Cutting SCs:** SC-6, SC-7, SC-8 are mutually independent — they modify three distinct files. Applied as separate commits per item.

**Interface Boundaries:** Three independent files with no shared content. The behavioral assertion guidance in `test-driven-development/SKILL.md` and `verify.md` MUST be replaced (not deleted) by the clean-room evaluation description, preserving the evidence-type taxonomy and no-lobotomizing mandate.

**State Transitions:** No runtime state transition — documentation-only. After Phase 4, no active enforcement doc references the removed `assert_semantic` helper.

**Cost frame:** Verifying the doc updates costs three greps: one confirming `assert_semantic` is explicitly named forbidden in `AGENTS.md`, and two confirming absence in the TDD SKILL.md and verify.md. Skipping means stale references instruct agents to use a helper that no longer exists, producing a behavioral-defect death spiral at the assertion-guidance layer.

- [ ] 23. **RED** — For SC-6, grep `tests-v2/AGENTS.md` for `assert_semantic` in the forbidden-helper list. Verify the test FAILS (the list names the grep helpers and the generic `assert_*` pattern but not `assert_semantic` explicitly). Record the failing evidence. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-6, file: tests-v2/AGENTS.md, assertion: assert_semantic not explicitly named FORBIDDEN in forbidden-helper list}`
- [ ] 24. **GREEN** — For SC-6, add `assert_semantic` to the forbidden-helper list in `tests-v2/AGENTS.md`, explicitly marked FORBIDDEN. Preserve the artifact-only mandate, `session.yaml`-primary rule, two-SC pattern, and exit-0 semantics. (**sub-agent**)
  - Context: `{issue_number: 2245, sc: SC-6, file: tests-v2/AGENTS.md, action: add assert_semantic to forbidden-helper list, preserve: artifact-only mandate + session.yaml-primary rule + two-SC pattern + exit-0 semantics}`
- [ ] 25. **Verify** — For SC-6, grep `tests-v2/AGENTS.md` for `assert_semantic` and confirm it returns a match explicitly naming it as forbidden; confirm the two-SC section and mandate text remain intact. (**inline**)
- [ ] 26. **Commit** — `git add tests-v2/AGENTS.md && git commit -m "phase-4(#2245): explicitly forbid assert_semantic in AGENTS.md (SC-6)"` (**inline**)
- [ ] 27. **RED** — For SC-7, grep `skills/test-driven-development/SKILL.md` for `assert_semantic`. Verify the test FAILS (8 references present). Record the failing evidence. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-7, file: skills/test-driven-development/SKILL.md, assertion: grep for assert_semantic returns non-empty}`
- [ ] 28. **GREEN** — For SC-7, remove the `assert_semantic` references from `skills/test-driven-development/SKILL.md`; describe clean-room sub-agent evaluation (reading `session.yaml`) as the behavioral evidence mechanism. Preserve the evidence-type taxonomy and the no-lobotomizing mandate — replace the guidance, do not delete it. (**sub-agent**)
  - Context: `{issue_number: 2245, sc: SC-7, file: skills/test-driven-development/SKILL.md, action: remove assert_semantic references + describe clean-room sub-agent evaluation, preserve: evidence-type taxonomy + no-lobotomizing mandate}`
- [ ] 29. **Verify** — For SC-7, grep `skills/test-driven-development/SKILL.md` for `assert_semantic` returns empty; confirm behavioral assertion guidance is present (describing clean-room sub-agent evaluation). (**inline**)
- [ ] 30. **Commit** — `git add skills/test-driven-development/SKILL.md && git commit -m "phase-4(#2245): remove assert_semantic references from TDD SKILL.md (SC-7)"` (**inline**)
- [ ] 31. **RED** — For SC-8, grep `skills/verification-before-completion/tasks/verify.md` for `assert_semantic`. Verify the test FAILS (a reference exists in the assertion-helper list). Record the failing evidence. (**clean-room**)
  - Context: `{issue_number: 2245, sc: SC-8, file: skills/verification-before-completion/tasks/verify.md, assertion: grep for assert_semantic returns non-empty}`
- [ ] 32. **GREEN** — For SC-8, remove the `assert_semantic` reference from the assertion-helper list in `skills/verification-before-completion/tasks/verify.md`; reference orchestrator-dispatched clean-room sub-agent evaluation. Preserve the cross-model validation gate and behavioral-test-run instructions. (**sub-agent**)
  - Context: `{issue_number: 2245, sc: SC-8, file: skills/verification-before-completion/tasks/verify.md, action: remove assert_semantic from assertion-helper list + reference clean-room evaluation, preserve: cross-model validation gate + behavioral-test-run instructions}`
- [ ] 33. **Verify** — For SC-8, grep `skills/verification-before-completion/tasks/verify.md` for `assert_semantic` returns empty; confirm behavioral run instructions remain intact. (**inline**)
- [ ] 34. **Commit** — `git add skills/verification-before-completion/tasks/verify.md && git commit -m "phase-4(#2245): remove assert_semantic from verify.md (SC-8)"` (**inline**)

> **Phase 4 complete.** VbC: SC-6, SC-7, SC-8 all PASS. Enforcement docs updated. Proceed to post-implementation.

---

## Post-Implementation Steps

- [ ] 35. **Structural checks** — Run lint and typecheck on modified shell and markdown files. For shell scripts, run `bash -n` on each converted script. For markdown, run `uvx pymarkdownlnt scan -r` and `uvx mdformat --check` on the modified docs. (**inline**)
- [ ] 36. **Verification** — Run all converted behavior scripts via `bash tests-v2/behaviors/<scenario>.sh` (timeout >= 600000ms). Confirm each exits 0 and produces an artifact directory with `session.yaml`. Confirm all SC greps pass. (**inline**)
- [ ] 37. **Audit** — Dispatch adversarial audit of the deliverable. (**sub-agent**)
- [ ] 38. **Cross-validate** — Verify audit findings against SC evidence. (**sub-agent**)
- [ ] 39. **Review-prep** — Prepare PR review context. (**sub-agent**)
- [ ] 40. **Create PR** — Create the pull request. (**sub-agent**)
- [ ] 41. **Completion** — Generate completion executive summary. (**sub-agent**)

---

## Exit Criteria

- [ ] C1: `assert_semantic()` function block absent from `helpers.sh` (SC-1)
- [ ] C2: All 12 behavior scripts remove the inline `assert_semantic` call and its `# Evaluate with assert_semantic` comment (SC-2)
- [ ] C3: Each converted behavior script preserves its pre-conversion contract — `behavior_run` args and mandatory header intact (SC-3)
- [ ] C4: Each converted behavior script exits 0 unconditionally as an artifact-only generator, producing an artifact directory with `session.yaml` (SC-4)
- [ ] C5: `tests-v2/AGENTS.md` documents the clean-room sub-agent evaluation contract — sub-agent receives only artifact dir + SC criterion + `github.owner`/`github.repo`, reads `session.yaml` as PRIMARY source, returns PASS/FAIL + justification (SC-5)
- [ ] C6: `tests-v2/AGENTS.md` explicitly names `assert_semantic` FORBIDDEN in its assertion-helper list (SC-6)
- [ ] C7: `skills/test-driven-development/SKILL.md` has no `assert_semantic` references and describes clean-room sub-agent evaluation as the behavioral evidence mechanism, preserving evidence-type taxonomy and no-lobotomizing mandate (SC-7)
- [ ] C8: `skills/verification-before-completion/tasks/verify.md` has no `assert_semantic` reference and references orchestrator-dispatched clean-room sub-agent evaluation, preserving the cross-model validation gate and behavioral-test-run instructions (SC-8)
- [ ] C9: All converted behavior scripts pass `bash -n` and exit 0 with artifact directories
- [ ] C10: Post-implementation audit passes with no critical findings
- [ ] C11: Structural checks (lint, typecheck, markdown lint/format) pass
- [ ] C12: PR created and review-ready
