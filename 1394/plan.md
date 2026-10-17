## Plan — floor note: glob does not traverse submodules

Branch: `1394-floor-glob-submodule-note` (submodule `.opencode`, base tip
`553e3d02` = its remote trunk tip at branch time). Spec:
`.opencode/.issues/1394/spec.md` (validated PASS, zero findings).

### Item 1 — floor.md Environment line (SC-1)

- **Deliverable:** the R-1 line, verbatim, added under `## Environment` in
  `.opencode/floor.md`:
  `- The \`glob\` tool does not traverse submodules — "no files found" there is false absence; use \`grep\`, \`read\`, or \`bash\` for submodule file discovery.`
- **RED:** `rg -F -x "<R-1 line>" .opencode/floor.md` returns 0 matches on
  the trunk state — the line is absent (spec Evidence; re-runnable).
- **GREEN:** insert the line as the closing line of the Environment section.
- **Instrument:** `rg -F -x "<R-1 line>" .opencode/floor.md` returns exactly
  1 match, located between `## Environment` and the next `## ` heading.

### Item 2 — diff scope (SC-2)

- **Deliverable:** the `floor.md` modification consists of exactly one added
  line — the R-1 line — with no lines removed.
- **RED:** with no change staged, the diff assertion (exactly one `+` line
  matching R-1, zero `-` lines) fails — nothing to show.
- **GREEN:** achieved by Item 1's minimal insertion; no other edit.
- **Instrument:** `git diff main -- floor.md` contains exactly one `+` line,
  it matches the R-1 line (`rg -F`), and zero `-` lines.

### Item 3 — behavioral scenario (SC-3)

- **Deliverable:** `.opencode/tests-v2/behaviors/1394-sc3-submodule-glob-false-absence.sh`
  — dispatches an agent on a file-discovery task over known-existing files
  under a submodule path and asserts the report names them as present.
- **RED:** the failure mode against current behavior is already observed and
  recorded as spec Evidence (2026-10-17 live reproduction: glob returns
  "No files found" for existing submodule files). The scenario formalizes
  that observation; the pre-fix harness run demonstrating the agent cannot
  pass is the RED record.
- **GREEN:** with the floor line present (Items 1–2), the dispatched agent's
  final report names the target files as present.
- **Instrument:** harness run per `tests-v2/AGENTS.md`; the assertion is
  evaluated against session evidence (`session-to-timeline` extraction from
  `session.yaml`).

### Dependencies

Item 1 → Item 2 (the diff exists only after the insertion) → Item 3 (the
green harness run requires the floor change present).

### Traceability

| Item | SC | Requirement |
|------|----|-------------|
| 1 | SC-1 | R-1 |
| 2 | SC-2 | R-1 |
| 3 | SC-3 | R-1 (false-absence failure mode) |

### Documentation sources

- `floor.md` (the edited surface)
- `tests-v2/AGENTS.md` (scenario authoring contract)

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
