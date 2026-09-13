## Problem

The `spec-creation` skill's validate task (`tasks/validate.md`) references 4 canonical reference files using task-relative paths that do not resolve. The files exist in the repository, but at different locations than the paths `validate.md` uses, so every validate dispatch fails its reference-deck integrity check and returns `BLOCKED` with `reference-deck-integrity: FAIL`, halting the spec pipeline.

**Corrected claim (supersedes the original issue body):** the files were initially reported as "missing from the repository." Live filesystem verification shows they exist — the defect is **wrong reference paths in `tasks/validate.md`**, not absent files. The task-relative links resolve relative to the task file's directory (`.opencode/skills/spec-creation/`), but the canonical files live at repo-root level under `.opencode/`.

## Affected references (verified 2026-09-13)

| Referenced path in `tasks/validate.md` | Actual file location | Step |
|---|---|---|
| `reference/holistic-dimensions.yaml` | `.opencode/reference/holistic-dimensions.yaml` | Step 2.1/2.2 |
| `reference/spec-structure-standards.md` | `.opencode/reference/spec-structure-standards.md` | Steps 1.2, 3.1/3.2 |
| `reference/cost-model-standards.md` | `.opencode/reference/cost-model-standards.md` | Step 3.5 |
| `audit/reference/decomposition-criteria.md` | `.opencode/audit/reference/decomposition-criteria.md` | Step 3.7 |

Current state of referenced directories (verified):
- `.opencode/skills/spec-creation/reference/` contains only `sc-table-columns.md`
- `.opencode/skills/audit/reference/` does not exist

## Impact

Every `spec-creation` validate dispatch returns `BLOCKED` with `reference-deck-integrity: FAIL`, making the spec→plan→implement→PR pipeline unusable. (critical-rules-074 forbids inferring the dimension list / taxonomy from memory or fabricating placeholder files.)

## Evidence

- `find .opencode -name holistic-dimensions.yaml -o -name spec-structure-standards.md -o -name cost-model-standards.md -o -name decomposition-criteria.md` → all 4 found at `.opencode/reference/` and `.opencode/audit/reference/`
- `ls .opencode/skills/spec-creation/reference/` → `sc-table-columns.md` only
- `ls .opencode/skills/audit/reference/` → No such file or directory
- `grep -n "reference/" .opencode/skills/spec-creation/tasks/validate.md` → task-relative references at lines 24, 28, 30, 72, 97
- Blocked sub-agent run: validate task on spec issue NewSRX-Tech-LLC/Butter#346, 2026-09-12

## Files Affected

| File | Change |
|---|---|
| `.opencode/skills/spec-creation/tasks/validate.md` | Correct 4 reference paths (lines 24, 28, 30, 72, 97) |
| `.opencode/skills/spec-creation/tasks/create.md` | Correct same-pattern reference paths (lines 43, 45) — falls under SC-3 sibling audit |

## Approach

Update the 4 reference paths in `.opencode/skills/spec-creation/tasks/validate.md` to point at the actual canonical locations. `validate.md` sits at `.opencode/skills/spec-creation/tasks/validate.md`, so the correct relative prefix to `.opencode/` is `../../../` (tasks → spec-creation → skills → .opencode): `../../../reference/holistic-dimensions.yaml`, `../../../reference/spec-structure-standards.md`, `../../../reference/cost-model-standards.md`, and `../../../audit/reference/decomposition-criteria.md`. No new files are created; no reference file content changes.

## Alternatives Considered and Ruled Out

1. **Create copies of the 4 reference files inside `.opencode/skills/spec-creation/reference/`** — ruled out: duplicates the canonical sources, violates single-source-of-truth, and future dimension/taxonomy updates would drift between copies (critical-rules-074 prohibits placeholder/fabricated reference decks).
2. **Move the 4 canonical files into `.opencode/skills/spec-creation/reference/`** — ruled out: `.opencode/reference/` is the deck-wide canonical location referenced by other skills/guidelines; relocating would break those consumers and exceed the issue's scope.
3. **Rewrite `validate.md` to hardcode the dimension list and taxonomy inline** — ruled out: `validate.md` deliberately loads them dynamically from the reference files ("NOT hardcoded here — loaded dynamically"); inlining reverses a design decision.

## Edge Cases

- **Path depth if files relocate later:** the fix uses relative paths; if any canonical file moves again, `validate.md` breaks again. Mitigation: SC-3's grep audit covers all `reference/` mentions in the skill directory so any remaining stale path is caught; future relocations must update both locations.
- **`create.md` shares the defect:** sibling task `create.md` (lines 43, 45) uses the same broken `reference/` pattern. Fixing only `validate.md` would leave the pipeline blocked at the create step — included in scope via SC-3 and Files Affected.
- **Behavioral verification requires isolation:** running a validate dispatch against the real session would contaminate production opencode state; SC-2's behavioral check MUST run through `bash .opencode/tests-v2/with-test-home opencode run '<message>'`.

## Success Criteria

| SC | Criterion | Evidence Type |
|---|---|---|
| SC-1 | `tasks/validate.md` contains no reference link that resolves to a nonexistent path (all 4 corrected references verified by filesystem check). | structural |
| SC-2 | A validate-task dispatch's reference-deck integrity check can locate all 4 canonical files at the paths stated in `tasks/validate.md` — behavioral, executed via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; the run must pass the reference-deck integrity gate without `reference-deck-integrity: FAIL`. | behavioral |
| SC-3 | No file in `.opencode/skills/spec-creation/` (including sibling `create.md`) references `reference/` or `audit/reference/` paths that fail resolution — full grep audit of the skill directory. | structural |

## Cost Frames

- SC-1: trivial — grep + path-existence check, seconds.
- SC-2: moderate — one isolated behavioral run (`with-test-home`), minutes of model time.
- SC-3: trivial — grep audit over one skill directory.

## Implicit Preconditions

- SC-2 assumes the standalone opencode binary is cached at `.tools/opencode/opencode` and the `with-test-home` harness is functional (per `.opencode/AGENTS.md` test framework discipline); if the harness is broken, SC-2 verdicts FAIL and are remediated via harness repair, not evidence substitution.
- Implementation requires `for_implementation`+ authorization and a feature branch in the `.opencode` repo (the affected files live in the `.opencode` submodule; the parent-repo submodule pointer rides along with the next real parent-repo change).

## Verification

- SC-1/SC-3: grep + path-existence check over every `reference/` mention in `.opencode/skills/spec-creation/` (structural).
- SC-2: behavioral — an isolated validate-task run that reaches past the reference-deck integrity gate without `reference-deck-integrity: FAIL`.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
