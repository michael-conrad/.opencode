# Phase 6: Add Anti-Lobotomization Language

## SCs

- **SC-10**: Anti-lobotomization preamble section added to create.md spec body template (string)
- **SC-11**: Anti-lobotomization SC added to spec body template that explicitly forbids test lobotomization (string)
- **SC-19**: Behavioral test confirmed RED→GREEN (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Verify current create.md for any anti-lobotomization references.
- [ ] 2. **Pre-red-baseline** — Record current state.
- [ ] 3. **RED — Behavioral test** — Extend behavioral test to assert agent does NOT include anti-lobotomization language in generated specs.
- [ ] 4. **GREEN — Add anti-lobotomization preamble** — In `.opencode/skills/spec-creation/tasks/create.md`, add new preamble section near line 339 area:
  > `**Anti-Lobotomization Preamble:** Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See 080-code-standards.md Test Integrity Mandate.`
- [ ] 5. **GREEN — Add anti-lobotomization SC to template** — In the SC table template, add a note: "Include an SC that explicitly forbids test lobotomization: 'SC-N: Tests MUST NOT be lobotomized — removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. Evidence type: behavioral.'"
- [ ] 6. **VbC** — SC-10: grep for `Tests MUST NOT be lobotomized\|CRITICAL VIOLATION.*lobotomiz` in create.md returns matches. SC-11: grep for `SC.*lobotom\|anti-lobotomization SC\|forbids test lobotomization` returns matches.
- [ ] 7. **Audit** — Independent audit verifying anti-lobotomization is a preamble section (not just a task instruction).
- [ ] 8. **Cross-validate** — Second verification.
- [ ] 9. **Regression check** — Ensure SC template format is preserved.
- [ ] 10. **Commit** — `git commit -am "phase-6: add anti-lobotomization language to spec-creation (#1834)"`
