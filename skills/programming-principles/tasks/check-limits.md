# Task: check-limits

## Purpose

Checks code against structural and complexity limits grounded in the single-responsibility principle and cohesion — not word/line counts. Produces a violation report citing the relevant principle and its apply-strongly/relax context.

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
- [ ] 2. Load the 20 engineering principles reference from `programming-principles/tasks/principles.md` to ground each assessment against the authoritative definitions.
- [ ] 3. Assess each file against the principles, focusing on structural and complexity indicators:
   - [ ] a. **Single Responsibility Principle** — does a function/class/module do exactly one thing, or does it have multiple reasons to change?
   - [ ] b. **Cohesion / Separation of Concerns** — do elements within a module belong together, and are domains isolated?
   - [ ] c. **DRY** — is duplicated logic present that should be extracted (3+ instances)?
   - [ ] d. **YAGNI** — is there speculative abstraction or "just in case" code?
   - [ ] e. **Fail Fast / Defensive Programming** — is input validation present at module boundaries?
   - [ ] f. **Blast Radius Minimization** — does the change isolate failures, or does it widen blast radius?
- [ ] 4. Apply the grandfather policy: only new or modified files are assessed; existing files are exempt.
- [ ] 5. For each violation found, cite the principle reference and its apply-strongly/relax context from `principles.md`.
- [ ] 6. Write the violation report to disk as the evidence artifact, with per-file findings and principle citations.
- [ ] 7. Return the result contract.

## Exit Criteria

- Violation report produced with per-file findings and principle citations
- A clean report (no violations found) is valid output — `status: DONE` with an empty finding list
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the violation report on disk>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Related task: `programming-principles/tasks/principles.md` (authoritative principle definitions, enforcement levels, apply-strongly/relax guidance)
- Related task: `programming-principles/tasks/application-guide.md` (red flags, tradeoff justification format)
- Related guideline: `080-code-standards.md` (project-specific conventions, "No Monoliths", "Single Function Methods")

## Note

This task assesses structural and complexity indicators, NOT raw line/word counts. The `programming-principles` skill explicitly disclaims word/line-count-based decomposition — a function that does one thing is correct regardless of length, and a function that does multiple things should be split regardless of length. Do not flag code solely for its length.
