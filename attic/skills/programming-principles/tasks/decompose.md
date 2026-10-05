# Task: decompose

## Purpose

Produces a decomposition proposal for oversized or over-coupled code based on the single-responsibility principle and cohesion. Advisory only — it returns a decomposition plan and does not modify any files.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Target file paths (`{file_paths}`) provided in context
- Worktree path (`{worktree.path}`) provided in context (prefix all file operations paths when set)

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. Read the target files, respecting `worktree.path` when set.
- [ ] 2. Load the engineering principles reference from `programming-principles/tasks/principles.md` and the application guide from `programming-principles/tasks/application-guide.md` to ground the assessment.
- [ ] 3. Identify functions, classes, or modules that violate the single-responsibility principle or exhibit low cohesion. Use the red flags in `application-guide.md` as signals:
   - [ ] a. A function/class with multiple reasons to change
   - [ ] b. A class name containing "and" or "or" (e.g., `ParserAndValidator`)
   - [ ] c. Testing requires mocking unrelated dependencies
   - [ ] d. A module handles both orchestration and implementation details
   - [ ] e. Business logic mixed with presentation or I/O
- [ ] 4. Propose a decomposition plan for each identified unit:
   - [ ] a. Split boundaries — where the unit should be divided
   - [ ] b. Renamed responsibilities — the responsibility each resulting unit owns
   - [ ] c. Dependency impacts — which callers/callees are affected and how
- [ ] 5. Do NOT modify any files. The decomposition plan is advisory — implementation is a separate, authorized step.
- [ ] 6. Write the decomposition proposal to disk as the evidence artifact, with before/after structure and dependency-impact analysis.
- [ ] 7. Return the result contract.

## Exit Criteria

- Decomposition proposal produced with before/after structure and dependency-impact analysis
- No files modified
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the decomposition proposal on disk>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Related task: `programming-principles/tasks/principles.md` (authoritative principle definitions, SRP/cohesion guidance)
- Related task: `programming-principles/tasks/application-guide.md` (red flags, decomposition criteria)
- Related guideline: `080-code-standards.md` (project-specific conventions, "No Monoliths")

## Note

Decomposition decisions are driven by the single-responsibility principle and cohesion — not line counts. A function that does one thing is correct regardless of length; a function that does multiple things should be split regardless of length. Do not propose splits based solely on code length.
