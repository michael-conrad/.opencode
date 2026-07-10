# Phase 5: Strengthen SC-Fail Cascading Statement

## SCs

- **SC-9**: SC-fail cascading preamble with exact strong language added to create.md spec body template (string)
- **SC-19**: Behavioral test confirmed RED→GREEN (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Verify current SC-fail cascading language in create.md (line 339: `🚫 ALL-OR-NOTHING GATE`).
- [ ] 2. **Pre-red-baseline** — Record current SC-fail cascading text.
- [ ] 3. **RED — Behavioral test** — Extend behavioral test to assert weak cascading language is used (test fails after strengthening).
- [ ] 4. **GREEN — Replace SC-fail cascading text** — In `.opencode/skills/spec-creation/tasks/create.md`, replace line 339's `🚫 ALL-OR-NOTHING GATE` section with the exact language from the spec:
  > `**SC-Fail Cascading Preamble:** Any SC that is skipped, deferred, weakened, or otherwise bypassed marks ALL SCs as FAIL. A PR containing any such bypass MUST be immediately rejected and trashed as defective and unusable. There is no partial credit. There is no 'close enough.' 100% clean PASS on ALL SCs is the only acceptable outcome.`
- [ ] 5. **VbC** — SC-9: grep for `Any SC that is skipped, deferred, weakened.*marks ALL SCs as FAIL` in create.md returns matches with exact language.
- [ ] 6. **Audit** — Independent audit verifying exact language matches spec specification.
- [ ] 7. **Cross-validate** — Second verification.
- [ ] 8. **Regression check** — Ensure SC table format and verification method requirements are preserved.
- [ ] 9. **Commit** — `git commit -am "phase-5: strengthen SC-fail cascading statement in spec-creation (#1834)"`
