## Problem

The implementation-pipeline SKILL.md has two dispatch tables that disagree with each other:

1. **Trigger Dispatch Table** — the standard table every SKILL.md has. Maps user phrases and context to tasks. Written as if implementation-pipeline owns all 24 steps, with canonical dispatch strings like `"execute red-phase from implementation-pipeline. Read implementation-pipeline/tasks/red-phase.md first"` — pointing to files that don't exist.

2. **Dispatch Routing Table** — unique to implementation-pipeline. Maps step labels to the actual owning skill/task they dispatch to (e.g., `red-phase` → `test-driven-development --task red`). This table has the correct routing.

The two tables are inconsistent. The Trigger Dispatch Table routes to phantom `implementation-pipeline/tasks/` files. The Dispatch Routing Table routes to the correct owning skills.

Additionally, the YAML frontmatter `description` field lists trigger phrases that belong to other skills ("green phase, red phase" → `test-driven-development`) and internal gates ("post-green enforcement, post-red enforcement"). It's missing unique entry-point triggers like "pre-flight" and "handoff".

### Root Cause

The Trigger Dispatch Table was written as an aspirational design document in commit 9854f806 (#1210) and never updated to reflect reality. When assemble-work.md and pipeline-executor.md were deleted in commit f1b415fd (#1674), the dispatch table was declared the "single source of truth" — but it still references 17 phantom task files.

### What Exists

**7 real task files in `implementation-pipeline/tasks/`:**
- `pre-red-baseline.md` — doc-source-currency + SC-ID cross-ref traceability
- `post-red-enforcement.md` — structural gate: RED did not modify src/
- `post-green-enforcement.md` — structural gate: GREEN did not modify test/
- `checkpoint-tag-create.md` — creates git tag for rollback anchor
- `pre-flight-handoff.md` — plan-to-pipeline handoff verification
- `sc-closeout.md` — SC close-out verification
- `behavioral-test-remediation.md` — remediation loop for behavioral test failures

**17 steps that route to other skills — all target tasks verified to exist:**

| Step | Correct Routing | Target Exists |
|---|---|---|
| `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | ✅ |
| `red-phase` | `test-driven-development --task red` | ✅ |
| `z3-check-red` | `solve --task check` | ✅ |
| `red-doublecheck` | `verification-before-completion --task verify` | ✅ |
| `z3-check-red-doublecheck` | `solve --task check` | ✅ |
| `z3-check-post-red` | `solve --task check` | ✅ |
| `green-phase` | `test-driven-development --task green` | ✅ |
| `z3-check-green` | `solve --task check` | ✅ |
| `z3-check-post-green` | `solve --task check` | ✅ |
| `checkpoint-commit` | `git-workflow --task commit-prep` | ✅ |
| `structural-checks` | `finishing-a-development-branch --task checklist` | ✅ |
| `green-doublecheck` | `verification-before-completion --task verify` | ✅ |
| `green-vbc` | `verification-before-completion --task completion` | ✅ |
| `cross-validate` | `adversarial-audit --task cross-validate` | ✅ |
| `regression-check` | `test-driven-development --task patterns` | ✅ |
| `review-prep` | `git-workflow --task review-prep` | ✅ |
| `exec-summary` | `completion-core --task completion` | ✅ |

### Owning Skills — YAML Descriptions Already Correct

All owning skills already have the correct trigger phrases in their YAML descriptions. No changes needed to other skills:

| Skill | Trigger Phrases | Status |
|-------|----------------|--------|
| `test-driven-development` | "write test, TDD, test-first, RED phase, GREEN phase, behavioral test, regression test" | ✅ |
| `adversarial-audit` | "audit spec, audit plan, check fidelity, verify coherence, detect drift, cross-validate, audit guidelines, verify closure, audit tests, verify verification, content audit, resolve auditor models" | ✅ |
| `verification-before-completion` | "verify completion, check SC, produce evidence, live-source verify, validate completion" | ✅ |
| `completion-core` | "complete task, signal completion, generate URL, append lifecycle event, executive summary" | ✅ |
| `finishing-a-development-branch` | "finish branch, final checks, pre-PR checklist, branch readiness, ready for PR" | ✅ |
| `solve` | "solve constraints, check contract, verify state, prove theorem, check dependency ordering, validate workflow, run Z3, run solve, fallback check, acyclic check" | ✅ |
| `git-workflow` | "create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules" | ✅ |

## Scope

1. Merge the two dispatch tables into one. The Trigger Dispatch Table is the standard pattern every SKILL.md uses — it should be the single source of truth. Each entry must route to the owning skill, not to a phantom `implementation-pipeline/tasks/` file. The Dispatch Routing Table is redundant once the Trigger Dispatch Table is correct — remove it.

2. Fix the YAML frontmatter `description` field:
   - **Remove:** `green phase`, `red phase` (belong to `test-driven-development`), `post-green enforcement`, `post-red enforcement` (internal pipeline gates, not user-facing)
   - **Add:** `pre-flight`, `handoff`, `submodule verification` (unique entry-point triggers for this skill)
   - **Keep:** `execute pipeline`, `run pipeline`, `dispatch stage`, `pipeline state`, `checkpoint`, `remediation`

   **Current description:**
   ```
   "Use when executing an approved plan through the implementation pipeline. Also use when dispatching pipeline stages to clean-room sub-agents, managing pipeline state, or handling remediation routing. Invoke for: pipeline execution, stage dispatch, state management, checkpoint creation, remediation routing, post-green enforcement, post-red enforcement. MUST dispatch here after plan approval, before any file modification. Trigger phrases: execute pipeline, run pipeline, dispatch stage, pipeline state, checkpoint, remediation, green phase, red phase."
   ```

   **Revised description:**
   ```
   "Use when executing an approved plan through the implementation pipeline. Also use when dispatching pipeline stages to clean-room sub-agents, managing pipeline state, or handling remediation routing. Invoke for: pipeline execution, stage dispatch, state management, checkpoint creation, remediation routing, pre-flight handoff, submodule verification. MUST dispatch here after plan approval, before any file modification. Trigger phrases: execute pipeline, run pipeline, dispatch stage, pipeline state, checkpoint, remediation, pre-flight, handoff."
   ```

3. No changes needed to other skills' YAML descriptions — they are already correct.

## Affected Files

- `.opencode/skills/implementation-pipeline/SKILL.md` — merge Trigger Dispatch Table and Dispatch Routing Table into one correct table; remove Dispatch Routing Table; update Invocation section; update Step Labels; fix YAML frontmatter description

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Only one dispatch table exists in SKILL.md — the Trigger Dispatch Table | `string` | grep for `## Dispatch Routing Table` returns no match |
| SC-2 | Trigger Dispatch Table has no entries routing to non-existent `implementation-pipeline/tasks/` files | `string` | grep for `implementation-pipeline/tasks/` in dispatch table — only 7 real task files referenced |
| SC-3 | Every dispatch table entry routes to the owning skill (e.g., `red-phase` → `test-driven-development --task red`) | `string` | grep each entry against owning skill's task file existence |
| SC-4 | Invocation section lists only the 7 real task files + orchestrator entry | `string` | grep Invocation section for task count |
| SC-5 | Step Labels section lists only steps that have corresponding entries in the dispatch table | `string` | diff step labels against dispatch table entries |
| SC-6 | YAML description does not contain "green phase", "red phase", "post-green enforcement", "post-red enforcement" | `string` | grep description field — no match for removed phrases |
| SC-7 | YAML description contains "pre-flight", "handoff", "submodule verification" | `string` | grep description field — match for added phrases |
| SC-8 | No changes to other skills' YAML descriptions | `string` | grep trigger phrases in test-driven-development, adversarial-audit, verification-before-completion, completion-core, finishing-a-development-branch, solve, git-workflow — all unchanged |
| SC-9 | Behavioral test: orchestrator dispatches `red-phase` to `test-driven-development --task red`, not to `implementation-pipeline/tasks/red-phase.md` | `behavioral` | opencode-cli run with pipeline execution prompt; verify stderr shows dispatch to test-driven-development |
| SC-10 | Behavioral test: orchestrator dispatches `green-phase` to `test-driven-development --task green` | `behavioral` | opencode-cli run with pipeline execution prompt; verify stderr shows dispatch to test-driven-development |
| SC-11 | Behavioral test: orchestrator dispatches `review-prep` to `git-workflow --task review-prep` | `behavioral` | opencode-cli run with pipeline execution prompt; verify stderr shows dispatch to git-workflow |

## Out of Scope

- Creating new task files for the phantom entries (they route to existing skills)
- Modifying the owning skills' task files or YAML descriptions
- Changing the pipeline step ordering or sequence
- Adding new pipeline steps

## Change Control

- **Spec created:** 2026-07-06
- **Spec author:** OpenCode (deepseek-v4-pro)
- **Status:** DRAFT

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)