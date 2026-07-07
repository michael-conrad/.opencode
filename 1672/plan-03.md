# Phase 3 — Refactor 15 Task Files

**Concern:** Refactor all 15 adversarial-audit task files to use DiMo role-differentiated agent chaining. Remove `audit_phase` from dispatch contracts, embed DiMo role personas, add pre-clean step, specify artifact paths, integrate Judger role, convert to sequential role chain, and update remediation sections.

**Files:**
- `.opencode/skills/adversarial-audit/tasks/closure-verification.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/coherence-extraction.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/coherence-maintenance.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/completion.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/concern-separation.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/content-audit.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/cross-validate.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/drift-detection.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/guideline-audit.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/resolve-models.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/spec-summary.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/test-quality-audit.md` — Modify
- `.opencode/skills/adversarial-audit/tasks/verification-audit.md` — Modify

**SCs:** SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11

**Dependencies:** Phase 1 complete (old infrastructure deleted), Phase 2 complete (auditor-role.md exists)

**Entry conditions:** No old auditor cards remain, auditor-role.md exists

**Exit conditions:** All 15 task files refactored with DiMo roles, no audit_phase conditionals, pre-clean step present, artifact paths specified, Judger integrated

---

- [ ] 39. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify SC-5 through SC-11 evidence types are correctly classified. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 40. **Z3 check (**inline**).** Run `solve check` against coherence gate output contract.

- [ ] 41. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of all 15 task files (grep for `audit_phase`, `INSUFFICIENT_FAMILIES`, current dispatch contract fields). **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 42. **Z3 check (**inline**).** Run `solve check` against pre-red-baseline output contract.

- [ ] 43. **RED: Write string-pattern test (**sub-agent**).** Dispatch `test-driven-development --task red` to write a test script that greps all 15 task files for:
  - `audit_phase` in dispatch contracts — should be absent (SC-5)
  - `if audit_phase` or equivalent conditional branches — should be absent (SC-6)
  - `./tmp/{issue-N}/artifacts/{task-name}/` pattern — should be present (SC-7)
  - Downstream role read chain pattern — should be present (SC-8)
  - Pre-clean step 0 pattern — should be present (SC-9)
  - Sequential role chain pattern — should be present (SC-10)
  - Remediation restart from step 0 pattern — should be present (SC-11)
  The test MUST fail at this point because the files still have the old patterns. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 44. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract.

- [ ] 45. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm the RED test correctly detects old patterns. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 46. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract.

- [ ] 47. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 48. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract.

- [ ] 49. **GREEN: Refactor 15 task files (**sub-agent**).** Dispatch `test-driven-development --task green` to refactor each of the 15 task files. For each file, apply the following transformations:
  - **Remove `audit_phase` from dispatch contract** — reduce to 2 fields: `spec_local_dir`, `artifact_evidence_dir` (SC-5)
  - **Embed DiMo role persona** — replace generic auditor persona with specific DiMo role(s) for this task. Each task file gets a role assignment based on its audit type (SC-6):
    - Open-ended audits (spec-audit, content-audit, drift-detection, guideline-audit, spec-summary): Divergent mode — Generator → Evaluator → Knowledge Supporter → Path Provider → Judger
    - Structured audits (verification-audit, plan-fidelity, closure-verification, concern-separation, coherence-extraction, coherence-maintenance, test-quality-audit): Logical mode — Evaluate → Refine → Judge loop
    - Cross-validate: Judger role only (holistic assessment)
    - Completion, resolve-models: Minimal role (cleanup/utility)
  - **Add pre-clean step (step 0)** — `rm -f ./tmp/{issue-N}/artifacts/{task-name}/*.yaml` at top of each task checklist (SC-9)
  - **Specify artifact paths** — `evidence.yaml` (Knowledge Supporter), `reasoning.yaml` (Path Provider), `verdict.yaml` (Evaluator), `judgment.yaml` (Judger) (SC-7)
  - **Specify downstream role read chain** — each role reads upstream artifacts: Knowledge Supporter writes evidence.yaml → Path Provider reads evidence.yaml → Evaluator reads evidence.yaml + reasoning.yaml → Judger reads all (SC-8)
  - **Integrate Judger as cross-validate** — replace separate cross-validate sub-agent with Judger role as the final step in each task's checklist (SC-8)
  - **Convert to sequential role chain** — role-1 → if PASS → role-2 → if PASS → role-3 → etc. (SC-10)
  - **Update remediation sections** — specify restart from pre-clean step (step 0), not from resolve-models (SC-11) **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 50. **Z3 check GREEN (**inline**).** Run `solve check` against green-phase output contract.

- [ ] 51. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 52. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-green-enforcement output contract.

- [ ] 53. **Checkpoint commit (**inline**).** Run `git add -A && git commit -m "Phase 3: Refactor 15 task files with DiMo roles"`. Create checkpoint tag: `opencode-config/checkpoint/1672/phase-3-opencode`. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 54. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 55. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm all 7 SCs pass via grep of all 15 task files. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

- [ ] 56. **VbC (**clean-room**).** Verify SC-5 through SC-11: grep all 15 task files for each pattern. **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11**

**Concern transition:** Leaving refactoring of 15 task files → updating SKILL.md and dispatch logic. Phase 4 depends on Phase 3's refactored task files (SKILL.md dispatch routing must reference the new DiMo-aligned task structure).
