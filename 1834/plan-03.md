# Phase 3: Add Live Documentation URL Verification

## SCs

- **SC-5**: Live documentation URL verification step added to create.md (string)
- **SC-6**: Documentation Sources section in spec body template mandates verified live URLs (string)
- **SC-19**: Behavioral test confirmed RED→GREEN (behavioral, cross-cutting)

## Steps

- [ ] 1. **Coherence gate** — Verify current create.md Documentation Sources section format and URL handling.
- [ ] 2. **Pre-red-baseline** — Record current state of Documentation Sources section.
- [ ] 3. **RED — Behavioral test** — Extend behavioral test to assert agent does NOT verify documentation URLs are live before spec completion.
- [ ] 4. **GREEN — Add mandatory URL verification step** — Edit `.opencode/skills/spec-creation/tasks/create.md`:
  - Add to Procedure (after the Documentation Sources section): "Step X: Verify Documentation Source URLs — For each URL in the Documentation Sources table, confirm the URL is reachable via HTTP HEAD or GET. If a URL returns 4xx/5xx, replace it with a working alternative or remove it. Local documentation is fallback only — online (live) documentation is preferred."
  - Update the Documentation Sources template to mandate verified live URLs and add a note: "Local docs are fallback only — online (live) documentation is preferred and MUST be verified reachable."
  - Remove the phrase "Simple specs may skip this section." from the Documentation Sources section.
- [ ] 5. **VbC** — SC-5: grep for `verify.*URL.*live\|URL.*reachable\|live.*documentation` in create.md returns matches. SC-6: grep for `verified live URL\|URL must be confirmed reachable\|prefer online` in create.md returns matches.
- [ ] 6. **Audit** — Independent audit verifying URL verification step is in mandatory pipeline, not optional.
- [ ] 7. **Cross-validate** — Second verification of string evidence.
- [ ] 8. **Regression check** — Verify existing Documentation Sources format is preserved.
- [ ] 9. **Commit** — `git commit -am "phase-3: add live documentation URL verification to spec-creation (#1834)"`
- [ ] 10. **Phase completion** — Update pipeline state.
