# Phase 1 — Trigger Phrase Expansion

**Concern:** Skill card description fields lack article-variant triggers, causing the pre-response gate to miss user phrasings like "create a spec" and dispatch inline instead.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — description field
- `.opencode/skills/writing-plans/SKILL.md` — description field

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry conditions:** Spec approved, feature branch created

**Exit conditions:** Both description fields updated, behavioral tests pass

---

### Global Pre-Steps

- [ ] 1. **Coherence gate (**clean-room**).** `skill({name: "pre-analysis"})` → `task(..., prompt: "execute pre-analysis task from pre-analysis")` for spec-creation and writing-plans SKILL.md description fields. Verify the description field structure and current trigger list before making changes.

- [ ] 2. **Pre-red-baseline (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-3 and SC-4. Confirm behavioral tests do NOT pass before changes (RED state).

### Phase 1 Steps

- [ ] 3. **RED (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute red task from test-driven-development")` for SC-3 (spec-creation trigger dispatch). Write behavioral test: `opencode-cli run "create a spec for X"` → stderr shows `Skill "spec-creation"`. Confirm FAIL.

- [ ] 4. **RED (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute red task from test-driven-development")` for SC-4 (writing-plans trigger dispatch). Write behavioral test: `opencode-cli run "create a plan for X"` → stderr shows `Skill "writing-plans"`. Confirm FAIL.

- [ ] 5. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-1. Edit `.opencode/skills/spec-creation/SKILL.md` description field: append article-variant triggers.

- [ ] 6. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-2. Edit `.opencode/skills/writing-plans/SKILL.md` description field: append article-variant triggers.

- [ ] 7. **GREEN doublecheck (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-1 and SC-2. Verify: `grep -q "create a spec" .opencode/skills/spec-creation/SKILL.md` and `grep -q "create a plan" .opencode/skills/writing-plans/SKILL.md`.

- [ ] 8. **Checkpoint commit (**inline**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute commit task from git-workflow")` with message: `Phase 1: expand trigger phrases with article variants for spec-creation and writing-plans`.

### Global Post-Steps

- [ ] 9. **Behavioral test (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-3. Run behavioral test: `opencode-cli run "create a spec for X"` → stderr shows `Skill "spec-creation"`. Confirm PASS.

- [ ] 10. **Behavioral test (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-4. Run behavioral test: `opencode-cli run "create a plan for X"` → stderr shows `Skill "writing-plans"`. Confirm PASS.

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute completion task from verification-before-completion")` for SC-1, SC-2, SC-3, SC-4. Verify all four SCs pass.

**Concern transition:** Leaving trigger phrase expansion → entering dispatch table fixes. Phase 2 modifies the same SKILL.md file (spec-creation) but a different section (dispatch table, not description).
