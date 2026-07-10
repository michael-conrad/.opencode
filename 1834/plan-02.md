# Phase 2: Add Research Card Consultation Mandate

## SCs

- **SC-3**: Research card consultation step added to operating-protocol.md before requirements extraction (string)
- **SC-4**: Research card check added to requirements.md (string)
- **SC-19**: Behavioral test confirmed RED→GREEN (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Verify operating-protocol.md and requirements.md current state. grep for existing `research-cards` or `research card` references.
- [ ] 2. **Pre-red-baseline** — Record current `grep -c "research.car\|research.cards" .opencode/skills/spec-creation/tasks/operating-protocol.md .opencode/skills/spec-creation/tasks/requirements.md`
- [ ] 3. **RED — Behavioral test** — Extend behavioral test from Phase 1 (or create new scenario) that asserts agent does NOT check research cards before requirements extraction.
- [ ] 4. **GREEN — Add research card step to operating-protocol.md** — Edit `.opencode/skills/spec-creation/tasks/operating-protocol.md`:
  - Add new step between step 1 (pre-spec inspection) and step 2 (requirements extraction):
    `- [ ] 1.5. [inline] Research card consultation — check `.opencode/.issues/research-cards/` for existing findings on the topic before proceeding. chain: step_1`
- [ ] 5. **GREEN — Add research card check to requirements.md** — Edit `.opencode/skills/spec-creation/tasks/requirements.md`:
  - Add to Entry Criteria: "- Research card consultation completed (findings checked)"
  - Add to procedure: before Step 1 (Extract Explicit Requirements), add: "Step 0: Check `.opencode/.issues/research-cards/` for existing findings on the spec topic. Incorporate relevant findings into requirements extraction."
- [ ] 6. **VbC** — SC-3: grep for `research.car\|research card` in operating-protocol.md returns matches. SC-4: grep for same in requirements.md returns matches.
- [ ] 7. **Audit** — Independent audit verifying research card consultation step is positioned before requirements extraction.
- [ ] 8. **Cross-validate** — Second verification of string evidence.
- [ ] 9. **Regression check** — Verify operating-protocol.md pipeline sequence still coherent (step numbering correct).
- [ ] 10. **Commit** — `git commit -am "phase-2: add research card consultation mandate to spec-creation (#1834)"`
- [ ] 11. **Phase completion** — Update pipeline state.
