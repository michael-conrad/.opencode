# Task: top-down-analysis

## Purpose

Produces code-level preliminary analytical artifacts (blast radius, code path inventory, interface compatibility, state analysis, testability assessment) as preliminary drafts derived from pre-spec inspection results.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Pre-spec inspection completed — results available from `explore/pre-spec-inspection.md`
- Issue number (`{issue_number}`) provided in context
- Project root (`{project_root}`) provided in context
- `srclight` tools available for code analysis

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. Read the pre-spec-inspection results from the exploration artifacts produced by `explore/pre-spec-inspection.md`. Do not re-investigate code already inspected.
- [ ] 2. For each affected symbol/file identified, use `srclight` tools to trace dependents, callers, callees, and signatures:
   - [ ] a. `srclight_get_dependents(symbol_name=..., transitive=True)` — trace dependents for blast radius
   - [ ] b. `srclight_get_callers` / `srclight_get_callees` — trace execution paths
   - [ ] c. `srclight_get_signature` — verify public API compatibility
   - [ ] d. `srclight_get_tests_for` — evaluate existing test coverage
- [ ] 3. Write preliminary artifact files to `{project_root}/tmp/{issue-N}/artifacts/preliminary/`:
   - [ ] a. `blast-radius.md` — files/symbols affected by the change, with impact classification (direct consumer, indirect consumer, data-flow dependent)
   - [ ] b. `code-paths.md` — execution paths through affected code, with path inventory
   - [ ] c. `interface-compat.md` — public API compatibility assessment with signature verification
   - [ ] d. `state-analysis.md` — persistent state affected by the change, with state transition model
   - [ ] e. `testability.md` — existing test coverage evaluation of affected paths
- [ ] 4. Write each artifact as a MARKDOWN file with structured YAML frontmatter containing `name`, `status`, and `source_issue` fields.
- [ ] 5. Set each artifact's `status` field to `complete`, `partial`, or `not-applicable`, with a justification for any non-complete status.
- [ ] 6. Update the handoff contract (`{project_root}/tmp/{issue-N}/artifacts/preliminary/handoff.yaml`) listing each artifact with its path and completion status. If the handoff contract does not yet exist, report back to the parent for handoff assembly.
- [ ] 7. Return the result contract.

## Exit Criteria

- All applicable preliminary artifacts written to disk with `complete` status (or `partial`/`not-applicable` with justification)
- Handoff contract updated, or the artifact list reported back to the parent for handoff assembly
- Result contract returned with artifact paths

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: complete | partial | failed
artifact_paths:
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/blast-radius.md"
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/code-paths.md"
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/interface-compat.md"
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/state-analysis.md"
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/testability.md"
finding_summary: "<1-3 sentences of routing-significant output>"
blocker_reason: "<reason if blocked>"
```

## Context Required

- Related task: `explore/pre-spec-inspection` (source of pre-spec inspection results)
- Related task: `explore/exploration-workflow` (Step 2.5 artifact paths and handoff contract format)
- Related guideline: `065-verification-honesty.md` (tool-call evidence for each artifact)
