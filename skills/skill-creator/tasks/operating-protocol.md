# Skill Creator Operating Protocol

## Entry Criteria

- Skill creation, update, or validation requested
- Skill name and output directory known

## Procedure

- [ ] 1. **Iron Law:** no skill creation/update without failing test first (RED phase). Document baseline failure.
- [ ] 2. **No hardcoded identity values:** use `<AgentName>`, `<ModelId>`, `<github.owner>`, `<github.repo>`, `<dev.name>`, `<dev.email>` placeholders.
- [ ] 3. **Worktree awareness mandatory** for skills with git/file operations.
- [ ] 4. **Submodule path awareness:** All tools/scripts in generated skills MUST account for workdir being inside a submodule. Paths MUST NOT compose `.opencode/.opencode/` nesting.
- [ ] 5. **Enforcement test step mandatory** after creation/update — add behavioral test scenarios.
- [ ] 6. **Verification-enforcement gate** before skill generation.
- [ ] 7. **Required frontmatter:** name, description, type, license, provenance, compatibility.
- [ ] 8. **Session-init variable alignment:** use canonical dotted-name format.
- [ ] 9. **Fragment discipline:** master copy is single source of truth — never edit copies directly. Registry at `.opencode/.guidelines/registry.yaml`.
- [ ] 10. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Skill created/updated
- Behavioral tests passing
- Fragment registry updated (if applicable)
