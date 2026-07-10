# Phase 1: Remove Complexity Escape Hatch (#1552)

**Issue:** #1552 — Remove 'simple specs may skip' complexity classification escape hatch

## SCs

- **SC-1**: "Simple specs may skip" language removed from create.md; all sections mandatory (string)
- **SC-2**: No minimal/standard/complex tiered structure remains in create.md (string)
- **SC-19**: Behavioral enforcement test written in `.opencode/tests/behaviors/`, confirmed RED before change (behavioral, cross-cutting)
- **SC-20**: No SC weakened, deferred, or reclassified (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Pre-RED coherence check: verify current create.md contains the "Simple specs may skip" patterns. grep for `simple specs may skip`, `Skip areas that don't apply`, `Minimal specs`, `Standard specs`, `Complex specs`.
- [ ] 2. **Pre-red-baseline** — Record current state: `git diff --stat` on create.md before changes.
- [ ] 3. **RED — Behavioral test** — Write behavioral test in `.opencode/tests/behaviors/` that sends a prompt triggering the spec-creation skill and asserts the agent does NOT skip required sections (test fails because escape hatch still exists).
- [ ] 4. **GREEN — Remove escape hatch** — Edit `.opencode/skills/spec-creation/tasks/create.md`:
  - Remove line 10: "Other prerequisite tasks completed or explicitly skipped via simplicity heuristic"
  - Remove "Skip areas that don't apply to simple specs; add areas that do." (line 72)
  - Remove "Simple specs may skip this section." text
  - Remove the Minimal/Standard/Complex tiered structure (lines ~405-408: "Minimal specs", "Standard specs", "Complex specs" sections)
  - Replace entry criteria line: remove "or explicitly skipped via simplicity heuristic"
- [ ] 5. **VbC** — Run `verification-before-completion`:
  - SC-1: `grep -r "simple specs may skip\|Skip areas that don't apply" .opencode/skills/spec-creation/tasks/create.md` returns no matches
  - SC-2: `grep -r "Minimal specs\|Standard specs\|Complex specs" .opencode/skills/spec-creation/tasks/create.md` returns no matches
  - SC-19: `bash .opencode/tests/behaviors/<test>.sh` → PASS
- [ ] 6. **Audit** — Independent audit of create.md changes: verify all escape hatch language removed, no new escape hatch introduced.
- [ ] 7. **Cross-validate** — Second independent verification of SC-1 and SC-2 string evidence.
- [ ] 8. **Regression check** — `grep -c "Simple specs\|Minimal specs\|Standard specs\|Complex specs\|skip areas that don't apply" .opencode/skills/spec-creation/tasks/create.md` → 0.
- [ ] 9. **Commit** — `git add -A && git commit -m "phase-1: remove complexity escape hatch from spec-creation create.md (#1834)"`
- [ ] 10. **Phase completion** — Update pipeline state to `phase-1-complete`. Proceed to Phase 2.
