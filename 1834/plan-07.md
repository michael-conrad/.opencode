# Phase 7: Fix Contract File Naming Drift

## SCs

- **SC-12**: Contract files renamed from write-* to create-* and all references updated (string)

## Steps

- [ ] 1. **Coherence gate** — Verify current contract files and all references to write-input-template/output-template in spec-creation/.
- [ ] 2. **Pre-red-baseline** — Record current file listing: `ls .opencode/skills/spec-creation/contracts/` and `grep -r "write-input-template\|write-output-template" .opencode/skills/spec-creation/`
- [ ] 3. **RED — Behavioral test** — Write test asserting contract files use write-* prefix (test fails after rename).
- [ ] 4. **GREEN — Rename contract files**:
  - `git mv .opencode/skills/spec-creation/contracts/write-input-template.yaml .opencode/skills/spec-creation/contracts/create-input-template.yaml`
  - `git mv .opencode/skills/spec-creation/contracts/write-output-template.yaml .opencode/skills/spec-creation/contracts/create-output-template.yaml`
- [ ] 5. **GREEN — Update all references**:
  - In `.opencode/skills/spec-creation/tasks/operating-protocol.md`: Replace all `write-input-template` → `create-input-template`, `write-output-template` → `create-output-template`, `write-input.yaml` → `create-input.yaml`, `write-output.yaml` → `create-output.yaml` (lines 20-21)
  - In `.opencode/skills/spec-creation/SKILL.md`: Update any contract references
  - In `.opencode/skills/spec-creation/tasks/create.md`: Update Exit Criteria contract path references
- [ ] 6. **VbC** — SC-12: `ls .opencode/skills/spec-creation/contracts/create-input-template.yaml` exists. `ls .opencode/skills/spec-creation/contracts/create-output-template.yaml` exists. `grep -r "write-input-template\|write-output-template" .opencode/skills/spec-creation/` returns no matches.
- [ ] 7. **Audit** — Independent audit verifying all references updated (grep for old names across entire skill directory).
- [ ] 8. **Cross-validate** — Second verification.
- [ ] 9. **Regression check** — Run any existing tests that consume contract files.
- [ ] 10. **Commit** — `git commit -am "phase-7: fix contract file naming drift write-* to create-* (#1834)"`
