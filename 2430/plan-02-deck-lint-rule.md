# Phase 2 — Guard-verbatim deck-lint rule + fixture flagging

**Concern:** skildeck lint rule module + `validate_skill_cards.py` check that flag any SKILL.md missing the canonical guard or carrying a deviant (non-mechanical) variant, verified against a guard-missing fixture card (R-4 deck-lint half).

**Files:**

- `.opencode/tools/skildeck`
- `.opencode/tools/impl/skildeck/` (lint rule modules)
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`

**SCs:** SC-6a

**Dependencies:** Phase 1 (the lint rule's verbatim pattern is derived from the canonical guard text; the reference doc must exist before the rule can check conformance)

**Entry Conditions:**

- Phase 1 complete: canonical guard reference document exists and its commit is landed
- Feature branch current in the `.opencode` submodule

**Exit Conditions:**

- Deck lint flags the guard-missing fixture card (flagged verdict recorded)
- `validate_skill_cards.py` verifies guard-verbatim embedding for every card it validates
- Lint rule is content-based and position-independent — guard placement after other sections does not evade the flag
- The item's commit is landed (lint rule + fixture together)

**Code Path Coverage:**

- `.opencode/tools/skildeck` — lint action (delegates to `.opencode/tools/impl/skildeck/` rule modules): add a guard-verbatim lint rule that flags any SKILL.md missing the canonical guard or carrying a deviant (non-mechanical, prose-only) guard; content-based, position-independent pattern check
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` — card validation checks: add validation that every card embeds the canonical guard verbatim (R-2 verification step)
- Consumers of this change: skildeck lint invocations (CI / agent sessions — deck-wide guard enforcement), skill-creator create/update flows (every future card validated for guard verbatim), audit skill plan-fidelity audits (every future plan audited for guard presence)

**Cross-Cutting SCs:**

- Lint-before-sweep ordering — the phase-2 lint rule flags cards missing the guard, but the sweep that fixes all 51 cards lands in phase 3. Between the two commits the deck is intentionally red; lint output must not be treated as authoritative until the sweep GREEN lands (medium impact)
- Two artifact classes, two reason codes — lint assertions key on the card-class reason code `ORCHESTRATOR_ONLY_SKILL_CARD`
- Behavioral evidence discipline — SC-6a is structural: the fixture lint run IS the flagged verdict to record; grep/static checks are legitimate only for this SC

**Interface Boundaries:**

- skildeck lint rule surface (modified, backward compatible): a new guard-verbatim lint rule is added; existing lint rules and action CLI surface unchanged. Cards currently in the deck will flag once the rule lands and before the phase-3 sweep — the flag is the phase-3 RED, not a regression
- skill-creator validation contract (modified, backward compatible): `validate_skill_cards.py` gains a guard-verbatim check; existing structural validations unchanged

**State Transitions:**

- Deck lint conformance state (per SKILL.md): before — card carries prose-only guard (or none); lint has no guard rule. After — lint flags any card missing the canonical guard or carrying a deviant variant; after the phase-3 sweep all 51 cards conform and lint reports zero findings
- Fixture flagging state: before — guard-missing fixture passes silently (no rule exists). After — deck lint flags the fixture card (SC-6a, structural); a missing guard can never produce a silent PASS
- Failure mode: tooling unavailable — lint command failure is a hard FAIL (`BLOCKED` with a tool-missing reason), never a silent pass

**Cost frame:** Running deck lint against the fixture costs seconds — a bounded check that proves the flagging rule actually fires. Skipping costs the check itself going unverified — a silent no-op lint discovered only when the first deviant card ships unflagged, far from introduction.

---

## Step-by-step

- [ ] 10. **RED (**task-card**).** Write a failing enforcement test: lint run against a fixture card missing the guard reports no flag. **→ SC-6a**
  - RED describes what fails: with no guard-verbatim rule present, deck lint run against the fixture card (missing the guard) reports no flag.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 11. **GREEN (**task-card**).** Implement the content-based position-independent lint rule that flags cards missing/deviant; fixture run reports the flag. **→ SC-6a**
  - GREEN describes what must be true: the guard-verbatim rule module flags cards missing the canonical guard or carrying a deviant (non-mechanical, prose-only) guard; the fixture run reports the flagged verdict; `validate_skill_cards.py` carries the matching guard-verbatim validation. No scope creep — only the minimum change needed.
  - The rule pattern is derived from the canonical guard text exactly (SC-1 verbatim semantics).
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 12. **Verify (**task-card**).** Verify the flagged verdict is recorded for the fixture. **→ SC-6a**
  - Verify structural evidence: the lint run against the fixture card produces and records the flagged verdict as evidence.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-verify-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

- [ ] 13. **Commit (**direct**).** Stage and commit changes — lint rule + fixture together as one atomic slice. **→ SC-6a**
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch.
  - No co-author trailers during implementation commits — those are added during squash at PR time.

#### Phase 2 Completion Block

- [ ] 14. **VbC (**task-card**).** Verification-before-completion assertions for phase 2. **→ SC-6a**
  - Fixture card is flagged by deck lint; flagged verdict recorded.
  - `validate_skill_cards.py` guard-verbatim check in place.
  - All exit conditions hold before phase 3 begins.

**Concern transition:** Leaving guard-verification tooling → entering deck-wide guard embedding. Phase 3 depends on phase 2's lint rule as its gate — RED = lint flags all 51 cards missing/deviant; GREEN = lint reports zero. The deck is intentionally red between phase 2's commit and phase 3's GREEN; lint output in that window is the expected RED signal, not a regression.