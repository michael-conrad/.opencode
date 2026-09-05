# Phase 3 — Card sweep — canonical guard embedded in all 51 cards

**Concern:** Replace the prose-only guard with the canonical mechanical guard in 48 top-level `.opencode/skills/*/SKILL.md` plus the 3 nested platform cards (R-1).

**Files:**

- `.opencode/skills/*/SKILL.md` (48 top-level)
- `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/skills/issue-operations/platforms/local/SKILL.md`

**SCs:** SC-1

**Dependencies:** Phase 1 (the sweep embeds the canonical guard verbatim — the text comes from the phase-1 reference doc), Phase 2 (the sweep's RED/GREEN/verify cycle uses the phase-2 lint rule as its gate)

**Entry Conditions:**

- Phase 1 complete: canonical guard reference document exists
- Phase 2 complete: guard-verbatim lint rule landed, fixture flagged
- Feature branch current in the `.opencode` submodule

**Exit Conditions:**

- All 51 SKILL.md files embed the canonical mechanical guard verbatim; no card carries a deviant (non-mechanical or prose-only) guard variant
- Deck lint reports zero cards missing/deviant
- The 51-file sweep is committed as one atomic commit

**Code Path Coverage:**

- `.opencode/skills/*/SKILL.md` (48 top-level cards) — Pre-Flight Guard section (e.g. `git-workflow/SKILL.md` currently carries the prose-only variant): replace prose-only guard with the canonical mechanical guard verbatim, reason code `ORCHESTRATOR_ONLY_SKILL_CARD`; no other section touched
- `.opencode/skills/issue-operations/platforms/{github-mcp,gitbucket-api,local}/SKILL.md` (3 nested platform cards) — Pre-Flight Guard section: same replacement; included because nested platform cards are dispatched the same way via `task()`
- Consumers of this change: every sub-agent dispatched with a card via `task()` (guard fires before routing metadata is consumed); deck lint phase-2 rule verifies all 51 cards carry the guard verbatim (SC-1)

**Cross-Cutting SCs:**

- Single canonical definition (no variant drift) — every embedded copy must match the canonical reference doc verbatim; whitespace/formatting drift between the canonical text and embedded copies would flag; the sweep must agree on the exact canonical block
- Discriminator correctness across the deck — the guard keys on task-tool absence as the sole discriminator; the `skill` tool is present in sub-agent context and must not be treated as a discriminator
- Two artifact classes, two reason codes — all 51 embedded cards carry the card-class reason code `ORCHESTRATOR_ONLY_SKILL_CARD`
- Lint-before-sweep ordering — RED = lint flags all 51 cards (expected, this is the gate working); GREEN = lint reports zero

**Interface Boundaries:**

- SKILL.md Pre-Flight Guard section (modified, backward compatible): the prose-only guard text in each card's Pre-Flight Guard section is replaced by the canonical mechanical guard verbatim. Section position and all other card sections (TDT, Invocation, tasks) unchanged. Dispatch strings and result contracts are untouched — the guard is strictly additive (spec Key Decision 4)

**State Transitions:**

- Deck lint conformance state: from "all 51 cards flagged missing/deviant" (RED) to "lint reports zero findings" (GREEN)
- Sub-agent guard state: from "sub-agent receives full card with no mechanical signal; consumes routing metadata it cannot execute and malfunctions" to "sub-agent checks tool list for a tool named `task`; absent ⇒ returns `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` and halts before executing any instruction"
- Invariant: guard governs ACTION, not perception — reading already happened; execution is what is forbidden. No dispatch attempt occurs after the guard
- Concurrency: guard replacement is additive and mechanical, so concurrent dispatches during the sweep are unaffected; the per-item TDD commit keeps the sweep atomic

**Cost frame:** Running deck lint across 51 cards costs seconds — a bounded check that catches any card shipping without the guard. Skipping costs weeks — an unguarded card leaks into sub-agent dispatch and the malfunction surfaces only when a session is diagnosed, far from introduction.

---

## Step-by-step

- [ ] 15. **RED (**task-card**).** Write a failing enforcement test: the phase-2 lint rule reports all 51 cards missing/deviant. **→ SC-1**
  - RED describes what fails: the deck-lint guard-verbatim check run over all 51 SKILL.md files reports cards missing/deviant guard — every card still carries the prose-only variant.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 16. **GREEN (**task-card**).** Replace the prose guard with the canonical mechanical guard in all 48 top-level cards and the 3 nested platform cards. **→ SC-1**
  - GREEN describes what must be true: all 51 cards embed the canonical guard verbatim from the phase-1 reference doc with reason code `ORCHESTRATOR_ONLY_SKILL_CARD`; no other section touched; dispatch strings, Trigger Dispatch Tables, and result contracts untouched. No scope creep — only the minimum change needed.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 17. **Verify (**task-card**).** Verify lint reports zero cards missing/deviant. **→ SC-1**
  - Verify string evidence: deck lint guard-verbatim pattern check across all 51 SKILL.md files reports zero missing/deviant; inspect lint output.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-verify-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

- [ ] 18. **Commit (**direct**).** Stage and commit changes — the 51-file card sweep as one atomic commit. **→ SC-1**
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch.
  - No co-author trailers during implementation commits — those are added during squash at PR time.

#### Phase 3 Completion Block

- [ ] 19. **VbC (**task-card**).** Verification-before-completion assertions for phase 3. **→ SC-1**
  - All 51 SKILL.md files embed the canonical guard verbatim.
  - Deck lint reports zero cards missing/deviant.
  - All exit conditions hold before phase 4 begins.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

**Concern transition:** Leaving deck-wide guard embedding → entering plan-template guard emission. Phase 4 depends on phase 1's canonical text; it is independent of phases 2–3 and may proceed once phase 1 lands. Phase 5 depends on both this phase (SC-3 card-leak, SC-5 no-false-halt exercise the swept cards) and phase 4 (SC-4 plan-leak exercises the template).