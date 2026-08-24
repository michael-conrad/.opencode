# Phase 1 — Create executing-plans skill with plan-reading mandate

**Concern:** Establish the foundational `executing-plans` skill (absent from the deck) with a mandatory plan-reading step so the routing rule and behavioral tests that dispatch it are coherent.

**Files:**
- `.opencode/skills/executing-plans/SKILL.md` (new)
- `.opencode/skills/executing-plans/tasks/` (new task cards)

**SCs:** SC-5

**Dependencies:** None

**Entry Conditions:**
- Spec #1364 approved
- Feature branch exists (per git-workflow pre-work)
- `.opencode/skills/executing-plans/` does not currently exist (verified)

**Exit Conditions:**
- SC-5 verified PASS (string evidence) and committed
- `executing-plans` skill directory exists with SKILL.md and task cards
- The plan-reading mandate step is present: read the plan file and dispatch each phase through the implementation pipeline in sequence

---

### Pre-implementation (one-time, before any phase)

- [ ] 1. **Coherence gate (**clean-room**).** Verify the plan faithfully derives from the approved spec #1364: every SC-1..SC-5 maps to exactly one plan item, evidence types match (SC-1, SC-2 behavioral; SC-3, SC-4, SC-5 string), and the phase DAG (phase 1 → phase 2 → phase 3, with phase 3 also depending on phase 1) is acyclic and matches the structure artifact. **→ coherence**
- [ ] 2. **Baseline check (**clean-room**).** Confirm the feature branch is at trunk-tip, submodules are clean, and `.opencode/skills/executing-plans/` does not exist while `.opencode/skills/approval-gate/SKILL.md` still carries the Gap-Fill column (no Pre-Flight/Pipeline). Record baseline state as the pre-change truth. **→ baseline**

### Item 1 (SC-5): Create executing-plans skill with plan-reading mandate

- [ ] 3. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-1364}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-5**
- [ ] 4. **RED (**sub-agent**).** Write a failing check asserting the plan-reading mandate step (read the plan file and dispatch each phase through the implementation pipeline in sequence) is absent from `.opencode/skills/executing-plans/SKILL.md` (the check fails because the skill directory does not exist yet). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-5**
- [ ] 5. **GREEN (**sub-agent**).** Create the `executing-plans` skill at `.opencode/skills/executing-plans/` with SKILL.md and task cards, adding the mandatory step: read the plan file and dispatch each phase through the implementation pipeline in sequence. No scope creep beyond the plan-reading mandate. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-5**
- [ ] 6. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the skill creation introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-5**
- [ ] 7. **Verify (**clean-room**).** Verify SC-5 against the deliverable: `.opencode/skills/executing-plans/SKILL.md` exists and contains the plan-reading mandate step text. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-5**
- [ ] 8. **Commit (**inline**).** Commit the skill creation (test + change together as one atomic slice). `git add .opencode/skills/executing-plans/ && git commit -m "<executing-plans skill creation message>"`. **→ SC-5**

#### Phase 1 VbC

- [ ] 9. **VbC (**clean-room**).** Verify SC-5 is clean PASS (evidence type `string` — grep confirms the plan-reading mandate step in `executing-plans/SKILL.md`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-5**

**Concern transition:** Leaving executing-plans skill creation → entering approval-gate scope model update. Phase 2 depends on the executing-plans skill existing (SC-5) before the routing rule referencing it is coherent.
