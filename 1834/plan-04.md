# Phase 4: Add Interdependency Checking and Marking

## SCs

- **SC-7**: Interdependency checking step added to operating-protocol.md before create (string)
- **SC-8**: Interdependency section with classification (BLOCKS, BLOCKED_BY, RELATED, SUPERSEDES, SUPERSEDED_BY) added to create.md spec body template (string)
- **SC-19**: Behavioral test confirmed RED→GREEN (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Verify current operating-protocol.md and create.md for existing interdependency references.
- [ ] 2. **Pre-red-baseline** — Record current state.
- [ ] 3. **RED — Behavioral test** — Extend behavioral test to assert agent does NOT check for overlapping/conflicting open specs before creating a spec.
- [ ] 4. **GREEN — Add interdependency step to operating-protocol.md** — Insert step between pipeline-readiness-gate (currently step 4.5) and risk (step 6):
  `- [ ] 5. [sub-task: interdependency] task(..., prompt: "execute interdependency task from spec-creation") — input: {project_root}/tmp/{N}/contracts/interdependency-input.yaml, output: {project_root}/tmp/{N}/contracts/interdependency-output.yaml, template: .opencode/skills/spec-creation/contracts/requirements-input-template.yaml (shared), chain: step_4.5`
- [ ] 5. **GREEN — Add Interdependency section to create.md spec body template** — Add before Documentation Sources:
  `### Interdependency\n\nCheck for overlapping/conflicting open specs before creation. Classify each finding: BLOCKS, BLOCKED_BY, RELATED, SUPERSEDES, SUPERSEDED_BY.\n\n| Issue | Classification | Description |\n|-------|---------------|-------------|\n| #N | SUPERSEDES | ... |\n| #N | RELATED | ... |\n| #N | BLOCKED_BY | ... |`
- [ ] 6. **VbC** — SC-7: grep for `interdependency\|overlapping\|conflicting.*spec` in operating-protocol.md returns matches. SC-8: grep for `BLOCKS\|BLOCKED_BY\|SUPERSEDES\|SUPERSEDED_BY\|Interdependency` in create.md returns matches.
- [ ] 7. **Audit** — Independent audit verifying interdependency checking is positioned before create step.
- [ ] 8. **Cross-validate** — Second verification.
- [ ] 9. **Regression check** — Verify operating-protocol.md step numbering correct.
- [ ] 10. **Commit** — `git commit -am "phase-4: add interdependency checking and marking to spec-creation (#1834)"`
