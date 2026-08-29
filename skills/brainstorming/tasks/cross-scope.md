# Task: cross-scope

## Purpose

Produces concern-boundary preliminary artifacts (concern map, cross-cutting matrix) and runs a cross-spec scope search to detect overlapping or conflicting specs before spec creation.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Pre-spec inspection completed — results available from `explore/pre-spec-inspection.md`
- Issue number (`{issue_number}`) provided in context
- Project root (`{project_root}`) provided in context

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. **Cross-spec scope search:** Query open GitHub Issues for specs/plans that may overlap with the proposed work. Filter for `[SPEC]`, `[PLAN]`, `[SPEC-FIX]` prefixed issues. Extract scope signals from the request and compare against existing specs.
- [ ] 2. **Classify each overlap** using the four-tier classification from `explore/pre-spec-inspection.md` Step 0.5:
   - [ ] a. `FULL-SUPERSESSION` — existing spec entirely covers the request
   - [ ] b. `PARTIAL-OVERLAP` — existing spec shares files/symbols
   - [ ] c. `CONFLICT-RISK` — existing spec modifies the same files
   - [ ] d. `INDEPENDENT` — no meaningful overlap
- [ ] 3. **Concern map:** Map affected areas to concern boundaries. Identify where one concern spans multiple units or one unit addresses multiple concerns.
- [ ] 4. **Cross-cutting matrix:** Identify concerns spanning multiple phases/components. Produce a concern-to-phase matrix.
- [ ] 5. Write preliminary artifact files to `{project_root}/tmp/{issue-N}/artifacts/preliminary/`:
   - [ ] a. `concern-map.md` — concern boundaries mapped to affected areas
   - [ ] b. `cross-cutting.md` — cross-cutting concerns with propagation map
- [ ] 6. Return the result contract, including supersession/conflict details if any were found.

## Exit Criteria

- Cross-spec scope search complete with a classification for each overlapping spec
- Concern map and cross-cutting artifacts written to disk
- If a `FULL-SUPERSESSION` is found: return BLOCKED with supersession details (parent routes to the existing spec instead)
- If a `CONFLICT-RISK` is found: return BLOCKED with conflict details
- Result contract returned with artifact paths

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: complete | partial | blocked | failed
artifact_paths:
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/concern-map.md"
  - "{project_root}/tmp/{issue-N}/artifacts/preliminary/cross-cutting.md"
supersession_details:
  issue_number: "<N if FULL-SUPERSESSION or CONFLICT-RISK>"
  classification: "FULL-SUPERSESSION | PARTIAL-OVERLAP | CONFLICT-RISK"
  summary: "<description of the overlap>"
finding_summary: "<1-3 sentences of routing-significant output>"
blocker_reason: "<reason if blocked>"
```

## Context Required

- Related task: `explore/pre-spec-inspection` (Step 0.5 cross-spec scope search procedure, line 32 concern map verification action)
- Related task: `explore/exploration-workflow` (Step 2.5 artifact format and paths)
- Related guideline: `065-verification-honesty.md` (tool-call evidence for each classification)
