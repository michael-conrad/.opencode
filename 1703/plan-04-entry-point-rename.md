# Phase 4 — entry-point-rename

**Concern:** Rename spec-creation's `write` task to `create` to match writing-plans. Update all cross-references across the skill deck and guidelines.

**Files:**
- `.opencode/skills/spec-creation/tasks/write.md` → `create.md` (rename)
- `.opencode/skills/spec-creation/SKILL.md` (update — Trigger Dispatch Table, task list, Invocation table, Operating Protocol)
- `.opencode/skills/spec-creation/tasks/completion.md` (update — line referencing `--task write`)
- `.opencode/guidelines/140-planning-spec-creation.md` (update — line referencing `--task write`)
- `.opencode/skills/adversarial-audit/tasks/test-quality-audit.md` (update — lines referencing `spec-creation/tasks/write.md`)
- `.opencode/skills/approval-gate/tasks/verify-authorization/sc-traceability-check.md` (update — lines referencing `spec-creation/tasks/write.md`)

**SCs:** SC-4, SC-5, SC-6

**Dependencies:** None

**Entry conditions:** Phase 3 complete and committed

**Exit conditions:** File renamed, all SKILL.md references updated, all cross-references updated, behavioral tests pass, grep confirms zero stale references

---

- [ ] 21. (**RED**) Write behavioral enforcement test that verifies spec-creation dispatches via `create` task. Test sends a spec creation prompt and asserts the agent dispatches the `create` task (not `write`). Save to `.opencode/tests/behaviors/spec-creation-entry-point.sh`.
- [ ] 22. (**inline**) Run the behavioral test — confirm it FAILS (RED phase passes).
- [ ] 23. (**GREEN**) Rename file: `mv .opencode/skills/spec-creation/tasks/write.md .opencode/skills/spec-creation/tasks/create.md`.
- [ ] 24. (**GREEN**) Update `.opencode/skills/spec-creation/SKILL.md`: change Trigger Dispatch Table `"write spec"` → `"create spec"`, task `write` → task `create`; change task list `write` → `create`; change Invocation table `"execute write task from spec-creation"` → `"execute create task from spec-creation"`; change Operating Protocol step 10 `[sub-task: write]` → `[sub-task: create]`.
- [ ] 25. (**GREEN**) Update `.opencode/skills/spec-creation/tasks/completion.md`: change `spec-creation --task write` → `spec-creation --task create`.
- [ ] 26. (**GREEN**) Update `.opencode/guidelines/140-planning-spec-creation.md`: change `spec-creation (--task write)` → `spec-creation (--task create)`.
- [ ] 27. (**GREEN**) Update `.opencode/skills/adversarial-audit/tasks/test-quality-audit.md`: change `spec-creation/tasks/write.md` → `spec-creation/tasks/create.md`.
- [ ] 28. (**GREEN**) Update `.opencode/skills/approval-gate/tasks/verify-authorization/sc-traceability-check.md`: change `spec-creation/tasks/write.md` → `spec-creation/tasks/create.md`.
- [ ] 29. (**inline**) Run grep to verify zero stale references: `grep -r "spec-creation.*--task write" .opencode/skills/ .opencode/guidelines/` returns zero matches; `grep -r "spec-creation/tasks/write" .opencode/skills/ .opencode/guidelines/` returns zero matches.
- [ ] 30. (**inline**) Run the behavioral test — confirm it PASSES (GREEN phase passes).
- [ ] 31. (**inline**) VbC: Verify SC-4 (both skills use `create`), SC-5 (zero `--task write` references), SC-6 (zero `tasks/write` references). Verify behavioral test passes.
- [ ] 32. (**inline**) Phase completion: Commit phase 4 artifacts to feature branch.
