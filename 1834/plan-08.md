# Phase 8: Add Missing #1063 Pipeline Enforcement Gates

## SCs

- **SC-13**: Anti-merge gate added to create.md: verify no SC conflicts with already-merged specs (string)
- **SC-14**: Doc-source-currency check added to create.md: verify all documentation sources are current (string)
- **SC-15**: SC-ID traceability added to create.md: verify every SC ID maps to a unique, traceable requirement (string)
- **SC-19**: Behavioral test confirmed RED→GREEN (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Verify current create.md for any existing #1063 enforcement gates.
- [ ] 2. **Pre-red-baseline** — Record current state.
- [ ] 3. **RED — Behavioral test** — Extend behavioral tests to assert absence of anti-merge gate, doc-source-currency check, and SC-ID traceability.
- [ ] 4. **GREEN — Add anti-merge gate to create.md** — In the Procedure section, add step before assembly: "Step X: Anti-Merge Gate — Before assembling the spec, search for recently merged PRs that may conflict with this spec's approach. Verify no SC contradicts or duplicates already-merged work. Use `github_search_pull_requests` with relevant keywords."
- [ ] 5. **GREEN — Add doc-source-currency check to create.md** — Add step: "Step Y: Doc-Source-Currency Check — For each documentation source referenced, verify the source is current (not stale). Check the source's last-updated date or git history. If a source is stale, update the reference or flag it as deprecated."
- [ ] 6. **GREEN — Add SC-ID traceability to create.md** — Add step in the SC table assembly section: "Step Z: SC-ID Traceability — After writing all SCs, verify that every SC ID maps to a unique, traceable requirement in the Problem/Root Cause or Approach sections. Each SC ID MUST reference at least one requirement statement. Any SC without a traceable requirement must be either linked or removed."
- [ ] 7. **VbC** — SC-13: grep for `anti-merge\|merged.*spec.*conflict\|SC.*conflict.*merged` in create.md. SC-14: grep for `doc-source-currency\|documentation.*source.*current\|stale.*documentation` in create.md. SC-15: grep for `SC-ID.*traceability\|SC.*ID.*unique\|traceable.*requirement` in create.md. All return matches.
- [ ] 8. **Audit** — Independent audit verifying all three gates are mandatory pipeline steps, not optional comments.
- [ ] 9. **Cross-validate** — Second verification.
- [ ] 10. **Regression check** — Verify create.md pipeline step ordering is preserved.
- [ ] 11. **Commit** — `git commit -am "phase-8: add #1063 pipeline enforcement gates to spec-creation (#1834)"`
