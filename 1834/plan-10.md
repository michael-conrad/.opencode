# Phase 10: Create Research Card

## SCs

- **SC-18**: Research card created at `.opencode/.issues/research-cards/spec-creation-state.md` with current state, known defects, interdependency map, and fix spec scope (string)

## Steps

- [ ] 1. **Coherence gate** — Check existing research cards at `.opencode/.issues/research-cards/` to confirm format.
- [ ] 2. **Pre-red-baseline** — Record current state of research cards directory.
- [ ] 3. **RED — Behavioral test** — Extend behavioral test to assert research card at `spec-creation-state.md` does not exist.
- [ ] 4. **GREEN — Create research card** — Write `.opencode/.issues/research-cards/spec-creation-state.md` with:
  - Current state of spec-creation skill (after all phase changes)
  - Known defects and their status
  - Interdependency map (cross-reference to #1834, #1552, #1229, #1064, #1063, #1703, #1673, #1605, #1060, #1061, #1062, #850)
  - This fix spec's scope
  - Confidence score (0.0–1.0)
  - Source URLs
  - Tags
- [ ] 5. **VbC** — SC-18: `ls .opencode/.issues/research-cards/spec-creation-state.md` exists and file is non-empty.
- [ ] 6. **Audit** — Independent audit verifying card contains current state, known defects, interdependency map, and fix spec scope.
- [ ] 7. **Cross-validate** — Second verification.
- [ ] 8. **Commit** — `git commit -am "phase-10: create research card for spec-creation skill state (#1834)"`
