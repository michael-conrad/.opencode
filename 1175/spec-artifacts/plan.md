# Plan: Remove embedded pipeline checklist from writing-plans — single source of truth

**Issue:** [#1175](https://github.com/michael-conrad/.opencode/issues/1175) — [SPEC-FIX] Single source of truth for implementation pipeline checklist

**Authorization:** `for_pr` — auto-approved via pipeline scope

## Goal

Replace the embedded 14-item pipeline checklist template in `writing-plans/tasks/create/create-and-validate.md` lines 34-59 with a reference to `implementation-pipeline/SKILL.md` §Dispatch Routing Table as the single canonical source. Add spec writer mandates (plan creation requirement, local-issues sync) to `spec-creation/tasks/write.md`.

## Architecture

Two skill task file modifications:
1. `writing-plans/tasks/create/create-and-validate.md` — replace template + add validation
2. `spec-creation/tasks/write.md` — add mandate steps for plan policy and local-issues sync

No structural changes to `implementation-pipeline/SKILL.md` itself.

---

## Phase 3: Replace embedded checklist + add spec writer mandates

**Concern:** Two-part change: (a) remove embedded template from create-and-validate.md, (b) add plan-creation mandate and local-issues sync to spec-creation write.md.

**Files:**
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`
- `.opencode/skills/spec-creation/tasks/write.md`

**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

### Implementation Pipeline Checklist (14 steps, mandatory)

Z3 state at `./tmp/1175/state/state.yaml`. Contract: `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`.

- [ ] 1. **SC-COHERENCE-GATE** — **orchestrator routes to pre-analysis**: verify SC-1 through SC-8 are internally consistent. Confirm: SC-1 (no embedded template) and SC-6 (Step 9 validation intact) are NOT contradictory. The replacement removes the template but preserves validation. `solve check` MUST return SAT.
- [ ] 2. **PRE-RED-BASELINE** — **orchestrator routes to exploration**: read current `create-and-validate.md` (lines 34-59) — confirm the embedded 14-item template exists. Read `write.md` — confirm no `writing-plans` or `local-issues` mandates exist. Run behavioral test suite if any exists for these skills. Run `grep -c "Each phase MUST use" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` — MUST return > 0 (baseline).
- [ ] 3. **RED-PHASE** — **orchestrator routes to RED sub-agent**: write two behavioral enforcement tests:
  - `tests/behaviors/1175-sc1-no-embedded-checklist.sh`: verifies agent DOES NOT embed 14-item checklist in plan phases. Uses `opencode-cli run` with a plan-creation prompt, asserts stderr does NOT contain "Each phase MUST use the following template". Expected FAIL because the template still exists.
  - `tests/behaviors/1175-sc4-writer-mandate.sh`: verifies generated spec contains `writing-plans` mandate. Expected FAIL because write.md doesn't mandate it.
  - Output to `./tmp/1175/artifacts/phase3-test-output.log`.
- [ ] 4. **RED-DOUBLECHECK** — **orchestrator inline**: confirm RED artifacts exist and show non-zero exit for both tests.
- [ ] 5. **GREEN-PHASE** — **orchestrator routes to GREEN sub-agent (clean-room)**: make four changes:

  **Change A** — Replace lines 34-59 template in `create-and-validate.md`:
  - Remove the `### Phase body requirements — Mandatory 14-Item Checklist Template with Routing Annotations` section (lines 34-59)
  - Replace with: A reference block that says: "Each phase MUST use the 14-item implementation pipeline checklist with routing annotations from the canonical source: `implementation-pipeline/SKILL.md` §Dispatch Routing Table. Phase bodies follow the format: Concern, Files, SCs covered, then the 14-item checklist."
  - Keep the concern boundary annotations (remaining prose below line 59).

  **Change B** — Add Step 9 validation in `create-and-validate.md`:
  - In the Step 9 section, add: "Verify each referenced pipeline step label exists in `implementation-pipeline/SKILL.md`'s routing table."

  **Change C** — Add spec writer mandates to `spec-creation/tasks/write.md`:
  - In the spec content generation section, add a step that injects into the generated spec body: "After this spec is approved, invoke `writing-plans` to create `.issues/{N}/spec-artifacts/plan.md` before implementation begins."
  - The mandate MUST be in the spec content (what the writer generates), not just the task procedure.
  - Placed in the spec's preamble or as a paragraph before the Success Criteria section.

  **Change D** — Add local-issues sync step to `spec-creation/tasks/write.md`:
  - After the remote issue creation step: "Invoke `local-issues sync` and commit the resulting local `.issues/{N}/` directory."
  - Also add to the generated spec body's AI Agent Instructions section: "After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry."

  Run both behavioral tests → expected PASS (exit 0). Output to `./tmp/1175/artifacts/phase3-green-output.log`.

- [ ] 6. **CHECKPOINT-COMMIT** — **orchestrator inline**: `git add .opencode/skills/writing-plans/tasks/create/create-and-validate.md .opencode/skills/spec-creation/tasks/write.md .opencode/tests/behaviors/1175-sc1-no-embedded-checklist.sh .opencode/tests/behaviors/1175-sc4-writer-mandate.sh && git commit -m "phase3 checkpoint: remove embedded pipeline checklist, add writer mandates"`
- [ ] 7. **STRUCTURAL-CHECKS** — **orchestrator routes to structural sub-agent**: `grep -c "Each phase MUST use" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` MUST return 0 (SC-1). `grep -c "implementation-pipeline" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` MUST return > 0 (SC-2). `grep -c "writing-plans" .opencode/skills/spec-creation/tasks/write.md` MUST return > 0 (SC-4).
- [ ] 8. **GREEN-DOUBLECHECK** — **orchestrator inline**: confirm GREEN artifact shows exit 0 for both behavioral tests. Re-run structural checks.
- [ ] 9. **GREEN-VBC** — **orchestrator routes to VbC sub-agent**: verification-before-completion against Phase 3 SCs:
  - SC-1: grep for "Each phase MUST use" returns 0
  - SC-2: grep for "implementation-pipeline" with dispatch routing reference
  - SC-3: Step 9 has `implementation-pipeline/SKILL.md` reference
  - SC-4: write.md has `writing-plans` mandate in spec body generation
  - SC-5: Generated spec output contains `writing-plans` and `spec-artifacts/plan.md` with correct issue number
  - SC-6: Step 9 still contains `solve check` and `plan plan` references
  - SC-7: write.md has `local-issues` in creation procedure
  - SC-8: Generated spec body has `## AI Agent Instructions` with `local-issues`
- [ ] 10. **ADVERSARIAL-AUDIT** — **orchestrator routes to resolve-models**: dispatch 2 auditors. Audit: `plan-fidelity` (does change match spec #1175 intent), `concern-separation` (two changes in one phase — are they separable, or naturally coupled?).
- [ ] 11. **CROSS-VALIDATE** — **orchestrator inline**: verify dual-auditor consensus on all 8 SCs.
- [ ] 12. **REGRESSION-CHECK** — **orchestrator routes to regression sub-agent**: run `opencode-cli run` against the plan-writer skill with a simple spec input, verify the output plan still has valid phase structure (not corrupted by template removal).
- [ ] 13. **REVIEW-PREP** — **orchestrator routes to review-prep sub-agent**: compare URL for Phase 3 changes.
- [ ] 14. **EXEC-SUMMARY** — **orchestrator inline**: collect all sub-agent result contracts, produce phase summary.

### Inter-Phase Handoff (after Phase 3, before Phase 4)

- `solve state update` — set phase3 step states
- `solve check` — confirm SAT
- Append lifecycle manifest event for Phase 3 completion
- **MANDATORY**: Phase 4 depends on Phase 3. Confirm Phase 3 EXEC-SUMMARY PASS before proceeding.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `create-and-validate.md` no longer contains "Each phase MUST use the following template" | `string` | `grep -c "Each phase MUST use" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns 0 |
| SC-2 | Per-phase checklist references `implementation-pipeline` for execution targets | `string` | `grep -c "implementation-pipeline" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns > 0 |
| SC-3 | Step 9 validation checks pipeline step labels against `implementation-pipeline/SKILL.md` | `string` | `grep -c "implementation-pipeline/SKILL.md"` in Step 9 section returns > 0 |
| SC-4 | `spec-creation/tasks/write.md` includes step that generates spec body with `writing-plans` mandate | `string` | `grep -c "writing-plans" .opencode/skills/spec-creation/tasks/write.md` returns > 0 |
| SC-5 | Generated spec body contains `writing-plans` and `.issues/{N}/spec-artifacts/plan.md` path | `behavioral` | Generate a minimal spec; verify output contains both strings with correct issue number |
| SC-6 | Step 9 preserves `solve check` and `plan plan` references | `structural` | `grep -c "solve check"` and `grep -c "plan plan"` in Step 9 section both return > 0 |
| SC-7 | `spec-creation/tasks/write.md` includes `local-issues sync` in creation procedure | `string` | `grep -c "local-issues" .opencode/skills/spec-creation/tasks/write.md` returns > 0 |
| SC-8 | Generated spec body includes `## AI Agent Instructions` with `local-issues` | `string` | Generate a spec; grep for `local-issues` in AI Agent Instructions section |

---

## Z3 SAT Contract

Same pipeline contract. `solve check` MUST return SAT before every step transition.

*Co-authored with AI: OpenCode (deepseek-v4-flash)*