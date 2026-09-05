# Phase 5 — Behavioral enforcement tests (tests-v2 harness, opencode run)

**Concern:** Real-model behavioral scenarios: card-leak halt (SC-3), plan-leak halt (SC-4), no-false-halt (SC-5), plan-audit fixture flagging (SC-6b — its GREEN implements the audit plan-fidelity FAIL finding class) (R-5).

**Files:**

- `.opencode/tests-v2/behaviors/` (new scenario scripts)
- `.opencode/skills/audit/tasks/plan-fidelity-{investigator,evaluator,arbiter,validator}.md` (SC-6b GREEN)

**SCs:** SC-3, SC-4, SC-5, SC-6b

**Dependencies:** Phase 1 (all behavioral assertions — reason codes, canonical guard text — and the SC-6b audit finding class derive their expected strings from the canonical reference doc), Phase 3 (SC-3 card-leak and SC-5 no-false-halt exercise the guard embedded by the sweep), Phase 4 (SC-4 plan-leak exercises the guard emitted by the template)

**Entry Conditions:**

- Phase 1 complete: canonical guard reference document exists
- Phase 3 complete: all 51 cards embed the mechanical guard
- Phase 4 complete: plan template emits the guard with `ORCHESTRATOR_ONLY_PLAN`
- Feature branch current in the `.opencode` submodule

**Exit Conditions:**

- Behavioral scenario scripts exist for card-leak (SC-3), plan-leak (SC-4), no-false-halt (SC-5), and plan-audit fixture flagging (SC-6b)
- SC-3: sub-agent given a full card returns `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` with no dispatch attempt
- SC-4: sub-agent given a plan file returns `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN` with no phase execution
- SC-5: orchestrator session loading a guarded card reaches Trigger Dispatch Table use and emits no `BLOCKED`
- SC-6b: plan-fidelity audit flags a fixture plan missing the guard as a FAIL finding; the audit finding class is implemented in the same phase as its RED/verify/commit (triplet co-location)
- All scenario artifacts committed

**Code Path Coverage:**

- `.opencode/tests-v2/behaviors/` — new behavioral scenario scripts following the existing naming convention (`<issue>-sc<N>-<slug>.sh`): card-leak BLOCKED (SC-3), plan-leak BLOCKED (SC-4), orchestrator no-false-halt (SC-5), plan-audit fixture flagging (SC-6b); run via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` with >=600s timeouts
- `.opencode/skills/audit/tasks/plan-fidelity-{investigator,evaluator,arbiter,validator}.md` — SC-6b GREEN: add the FAIL finding class naming the missing canonical guard
- Consumers of this change: tests-v2 harness (regression gate for card/plan template changes); verification-before-completion (behavioral evidence source for SC-2..SC-5, SC-6b)

**Cross-Cutting SCs:**

- Discriminator correctness across the deck — the guard keys on task-tool absence as the sole discriminator; SC-5 is the false-halt recovery gate that catches any guard regression that over-fires
- Two artifact classes, two reason codes — SC-3 asserts `ORCHESTRATOR_ONLY_SKILL_CARD`; SC-4 asserts `ORCHESTRATOR_ONLY_PLAN`; each keys on the artifact-class-specific code
- Behavioral evidence discipline — SC-2, SC-3, SC-4, SC-5, SC-6b are behavioral: they run `opencode run` against real models via tests-v2 and assert on session.yaml (BLOCKED codes, dispatch attempts, TDT progression). Grep/static checks are EVIDENCE_TYPE_MISMATCH for these SCs and produce a FAIL verdict

**Interface Boundaries:**

- tests-v2 behavioral scenario contract (added, backward compatible): new scenario scripts follow the existing naming convention and harness invocation (with-test-home + `opencode run`, session.yaml evaluation). No changes to existing scenarios or harness

**State Transitions:**

- Sub-agent guard state (per dispatch): sub-agent receives full card/plan → checks tool list for a tool named `task` → absent ⇒ returns `BLOCKED` with the artifact-class reason code and halts before executing any instruction
- Orchestrator dispatch flow: orchestrator loads guarded card → checks tool list → tool named `task` present ⇒ proceeds normally to Trigger Dispatch Table use, no `BLOCKED` emitted
- Fixture flagging state: from "guard-missing fixture passes silently (no rule exists)" to "plan audit FAIL-finding names the fixture plan's missing guard (SC-6b, behavioral)"
- Failure mode: a sub-agent keys on the `skill` tool instead of `task` absence and reasons itself into orchestrator mode — the canonical text names `task` as the sole discriminator; SC-5 is the recovery gate for guard over-firing

**Cost frame:** Running the card-leak, plan-leak, and no-false-halt behavioral tests costs minutes of model execution each. Skipping costs 100×–1000× discovery latency — the exact routing-metadata misexecution this spec exists to prevent ships silently; unguarded plans pass review and malfunction at phase-execution time; a false halt blocks every orchestrator dispatch and surfaces as mysterious workflow deadlocks. Running the plan-audit fixture check costs minutes. Skipping costs a silent no-op audit path — unguarded plans pass review unflagged until a leak malfunctions downstream.

---

## Step-by-step

- [ ] 25. **RED (**task-card**).** Write a failing card-leak behavioral test: a sub-agent given a full prose-guard fixture card executes routing instructions without returning `BLOCKED`. **→ SC-3**
  - RED describes what fails: the pre-guard baseline fixture card (prose-only guard) is dispatched to a sub-agent via `opencode run`; the sub-agent consumes the Trigger Dispatch Table with no BLOCKED output — the assertion `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` with no dispatch attempt fails.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 26. **GREEN (**task-card**).** The guard embedded via the phase-3 sweep fires; test asserts `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD`, no dispatch attempt. **→ SC-3**
  - GREEN describes what must be true: re-running the scenario against a swept card (mechanical guard) produces `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` in the session record with no dispatch attempt. No scope creep — only the minimum change needed.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 27. **RED (**task-card**).** Write a failing plan-leak behavioral test: a sub-agent given an unguarded fixture plan executes plan phases without returning `BLOCKED`. **→ SC-4**
  - RED describes what fails: the pre-guard fixture plan is dispatched to a sub-agent via `opencode run`; the sub-agent executes plan phases with no BLOCKED output — the assertion `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN` with no phase execution fails.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 28. **GREEN (**task-card**).** The guard from the phase-4 template fires; test asserts `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN`, no phase execution. **→ SC-4**
  - GREEN describes what must be true: re-running the scenario against a guarded plan produces `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN` in the session record with no phase execution. No scope creep — only the minimum change needed.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 29. **GREEN (**task-card**).** No-false-halt scenario: orchestrator session loads a guarded card (phase-3 output), proceeds to Trigger Dispatch Table use, emits no `BLOCKED`. **→ SC-5**
  - GREEN describes what must be true: an orchestrator session loading a guarded card via `opencode run` reaches Trigger Dispatch Table use with zero `BLOCKED` output. The RED condition (an orchestrator session halting with `BLOCKED` — a false positive) is covered by the recovery-gate assertion: any over-firing guard variant fails this test.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 30. **RED (**task-card**).** Write a failing plan-audit fixture test: plan-fidelity audit against a fixture plan missing the guard reports no finding. **→ SC-6b**
  - RED describes what fails: the plan-fidelity audit path run against the fixture plan (missing the guard) reports no finding — the assertion that a FAIL finding names the missing guard fails.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 31. **GREEN (**task-card**).** Implement the audit plan-fidelity FAIL finding class in the same phase as RED/verify/commit (triplet co-location); the audit path flags the missing guard as a FAIL finding. **→ SC-6b**
  - GREEN describes what must be true: the plan-fidelity investigator/evaluator/arbiter/validator path carries the FAIL finding class for a plan missing the canonical guard; the fixture run produces the finding. No scope creep — only the minimum change needed.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 32. **Post-regression (**task-card**).** Run regression test patterns after the GREEN phase. **→ SC-3, SC-4, SC-5, SC-6b**
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-post-regression-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`.

- [ ] 33. **Verify (**task-card**).** Verify behavioral opencode runs produce the expected verdicts for all four SCs. **→ SC-3, SC-4, SC-5, SC-6b**
  - SC-3: `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` in stderr, no dispatch attempt.
  - SC-4: `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN`, no phase execution.
  - SC-5: progression to Trigger Dispatch Table use, no `BLOCKED`.
  - SC-6b: a FAIL finding naming the missing guard.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-verify-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

- [ ] 34. **Commit (**direct**).** Stage and commit changes — each behavioral scenario file, the audit check + fixture together. **→ SC-3, SC-4, SC-5, SC-6b**
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch.
  - No co-author trailers during implementation commits — those are added during squash at PR time.

#### Phase 5 Completion Block

- [ ] 35. **VbC (**task-card**).** Verification-before-completion assertions for phase 5. **→ SC-3, SC-4, SC-5, SC-6b**
  - All four behavioral scenarios produce their expected verdicts from real-model runs.
  - All exit conditions hold before post-implementation steps begin.

**Concern transition:** Leaving behavioral enforcement testing → entering post-implementation gates. All seven SCs now have their verifying evidence; the audit, Z3, structural, pre-PR, regression, review-prep, PR, and completion steps run once at plan level.