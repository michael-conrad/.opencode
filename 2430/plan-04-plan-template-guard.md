# Phase 4 — writing-plans plan template embeds the guard

**Concern:** Plan template + create/revise tasks emit the canonical guard with reason code `ORCHESTRATOR_ONLY_PLAN` into every produced plan (R-3).

**Files:**

- `.opencode/skills/writing-plans/` (plan template)
- `.opencode/skills/writing-plans/tasks/create.md`
- `.opencode/skills/writing-plans/tasks/revise.md`

**SCs:** SC-2

**Dependencies:** Phase 1 (the plan template emits the canonical guard text sourced from the phase-1 reference doc)

**Entry Conditions:**

- Phase 1 complete: canonical guard reference document exists
- Feature branch current in the `.opencode` submodule

**Exit Conditions:**

- The writing-plans plan template carries the canonical guard with reason code `ORCHESTRATOR_ONLY_PLAN`
- `tasks/create.md` and `tasks/revise.md` emit the guard on every produced plan
- The behavioral create-run emits a guarded plan (SC-2 GREEN passes)
- The template change and its behavioral test are committed together

**Code Path Coverage:**

- `.opencode/skills/writing-plans/` (plan template) — plan document structure emitted by `tasks/create.md` (structured markdown with frontmatter dispatch array): add the canonical guard with reason code `ORCHESTRATOR_ONLY_PLAN` to the plan template; create/revise tasks emit it on every produced plan
- Consumers of this change: executing-plans (reads plans at orchestrator level, dispatches phases via `task()`); sub-agents wrongly dispatched with a plan file via `task()` (guard fires with `ORCHESTRATOR_ONLY_PLAN` before phase execution)

**Cross-Cutting SCs:**

- Single canonical definition (no variant drift) — the emitted guard text must match the canonical reference doc verbatim
- Two artifact classes, two reason codes — plans carry the plan-class reason code `ORCHESTRATOR_ONLY_PLAN`; swapping or merging the codes breaks the SC-4 assertion and makes audit findings unattributable
- Behavioral evidence discipline — SC-2 is behavioral: the create-run executes `opencode run` against a real model via tests-v2 and asserts the emitted plan contains the canonical guard; grep/static checks are EVIDENCE_TYPE_MISMATCH for this SC

**Interface Boundaries:**

- Plan file structure (modified, backward compatible): plans produced by writing-plans gain a Pre-Flight Guard section with reason code `ORCHESTRATOR_ONLY_PLAN`. executing-plans reads plans at orchestrator level and is unaffected by the added section; existing pre-guard plans remain valid — no retroactive regeneration

**State Transitions:**

- Plan artifact guard state: from "plans produced with no guard at all" to "every plan emitted by writing-plans create/revise carries the canonical guard with `ORCHESTRATOR_ONLY_PLAN`"
- Invariant: backward compatible — existing pre-guard plans stay valid; new plans are self-describing
- Failure mode: template change lands but create/revise tasks do not emit the section (emission step missing) — the SC-2 behavioral test catches this
- Phase-4 RED note: the behavioral create-run (item-2 RED) fails because the same-phase template change has not landed yet; no cross-phase violation — phase-4 RED depends only on phase-1 canonical text committed earlier

**Cost frame:** Running the writing-plans create behavioral check costs minutes. Skipping costs the lifetime of plan production — every future plan ships unguarded, and each becomes a fresh leak discovered only at execution malfunction.

---

## Step-by-step

- [ ] 20. **RED (**task-card**).** Write a failing behavioral test asserting the emitted plan contains the canonical guard. **→ SC-2**
  - RED describes what fails: a behavioral create-run (tests-v2 harness, `opencode run` against a real model — not grep) produces a plan with no guard section; the assertion that the plan contains the canonical guard fails.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 21. **GREEN (**task-card**).** Update the plan template and create/revise tasks to emit the guard with `ORCHESTRATOR_ONLY_PLAN`. **→ SC-2**
  - GREEN describes what must be true: the plan template carries the canonical guard block with reason code `ORCHESTRATOR_ONLY_PLAN`, and `tasks/create.md` plus `tasks/revise.md` emit it into every produced plan. No scope creep — only the minimum change needed.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 22. **Verify (**task-card**).** Verify the behavioral create-run emits a guarded plan. **→ SC-2**
  - Verify behavioral evidence: the create-run against a real model emits a plan containing the canonical guard (assertion via session.yaml — the primary evidence source).
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-verify-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

- [ ] 23. **Commit (**direct**).** Stage and commit changes — template change together with its behavioral test. **→ SC-2**
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch.
  - No co-author trailers during implementation commits — those are added during squash at PR time.

#### Phase 4 Completion Block

- [ ] 24. **VbC (**task-card**).** Verification-before-completion assertions for phase 4. **→ SC-2**
  - Plan template + create/revise tasks emit the canonical guard with `ORCHESTRATOR_ONLY_PLAN`.
  - Behavioral create-run confirms the emitted plan carries the guard.
  - All exit conditions hold before phase 5 begins.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

**Concern transition:** Leaving plan-template guard emission → entering behavioral enforcement testing. Phase 5 depends on phase 3 (SC-3 card-leak and SC-5 no-false-halt exercise the guard embedded by the sweep) and on this phase (SC-4 plan-leak exercises the guard emitted by the template); both dependencies are now committed.