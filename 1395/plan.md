# Implementation Plan — [#1395](https://github.com/michael-conrad/.opencode/issues/1395) — Remove Dead Submodule JSONC Agent Configs

- **Goal:** Delete 4 unused `.jsonc` agent configs, remove the Sub-Agent Tasks for Submodule Operations table from `git-workflow/SKILL.md`, update routing and cross-references, and normalize 8 task files to standard `task(subagent_type="general")` dispatch language.
- **Architecture:** Cleanup-only — no new functionality. Delete files, remove references, replace dedicated sub-agent names with standard dispatch language. All inline `must_receive`/`must_not_receive` schemas preserved unchanged.
- **PR Strategy:** stacked (single branch, all items in one PR)
- **Dependency:** None (first in stack)

## Items

### Item 1 — Delete 4 dead JSONC files
- **SCs:** SC-1 (structural)
- **Files:** `agents/submodule-dev-restore.jsonc`, `agents/submodule-feature-push.jsonc`, `agents/submodule-liveness-check.jsonc`, `agents/submodule-tag-prework.jsonc`
- **Action:** Delete all 4 files
- **Verification:** `ls agents/*.jsonc` returns empty

### Item 2 — Remove JSONC refs and sub-agent table from SKILL.md
- **SCs:** SC-2 (string), SC-3 (string), SC-5 (string)
- **Files:** `skills/git-workflow/SKILL.md`
- **Action:**
  - Remove the "Sub-Agent Tasks for Submodule Operations" table
  - Update Sub-Agent Routing section to remove dedicated sub-agent names
  - Update cross-reference from `submodule-tag-prework` task to `pre-work.md` Step 3.5
  - Merge submodule ops into main routing table
- **Verification:** `grep -rn '\.jsonc' skills/git-workflow/` returns zero; `grep -c 'Sub-Agent Tasks for Submodule Operations'` returns 0

### Item 3 — Update 8 task files to standard dispatch language
- **SCs:** SC-4 (string)
- **Files:** `pre-work.md`, `branch-cleanup.md`, `enforcement-gate.md`, `push-and-cleanup.md`, `check-pr.md`, `cleanup.md`, `pr-creation.md`, `review-prep.md`
- **Action:** Replace dedicated sub-agent dispatch language (e.g., "dispatches a `submodule-*` sub-agent") with standard `task(subagent_type="general")` language. Preserve all inline `must_receive`/`must_not_receive` schemas unchanged.
- **Verification:** No task file says "dispatches a `submodule-*` sub-agent"

## Execution

Each item is dispatched to the implementation-pipeline via `assemble-work` → `pipeline-executor`. The pipeline-executor runs the standard gate sequence (SC-coherence-gate → pre-red-baseline → red-phase → red-doublecheck → post-red-enforcement → green-phase → post-green-enforcement → checkpoint-tag-create → checkpoint-commit → structural-checks → green-doublecheck → green-vbc) for each item independently.

Items execute in order: Item 1 → Item 2 → Item 3. After all items complete, global post-steps run (resolve-models → adversarial-audit ×2 → cross-validate → regression-check → review-prep → exec-summary).

## Exit Criteria
- C1: No `.jsonc` files remain in `.opencode/agents/` (SC-1)
- C2: `git-workflow/SKILL.md` contains no references to `.opencode/agents/*.jsonc` (SC-2)
- C3: `git-workflow/SKILL.md` contains no "Sub-Agent Tasks for Submodule Operations" heading or table (SC-3)
- C4: All 8 task files use `task(subagent_type="general")` language for submodule operations (SC-4)
- C5: `git-workflow/SKILL.md` routing section lists submodule ops as standard tasks (SC-5)
- C6: All pipeline gates passed for all 3 items
