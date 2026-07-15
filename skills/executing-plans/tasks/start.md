# Task: start

Task() to implementation-pipeline for implementation.

## Purpose

This task() routes plan execution to the implementation-pipeline per the SKILL.md Trigger Dispatch Table, which handles all implementation through the unified work workflow.

## Invocation Procedure

- [ ] 1. **Verify plan approval** — confirm the plan issue has explicit approval in comments
- [ ] 2. **Verify prerequisites** — feature branch exists, working tree clean, dependencies ready
- [ ] 3. **Read work state file to compose initial phase progress** — before task()ing, read `{project_root}/tmp/{N}/work.md` to determine which phases (if any) are already marked complete. Compose the initial `phase_progress` for the task context:
   - If no phases are complete yet: `completed_phases: "No phases completed yet. This is the first phase."`, `concern_boundaries_crossed: ""`, `verification_evidence: ""`
   - If prior phases are complete: list them by concern name using the concern boundary annotations in the plan body, note any transitions between concerns, and summarize verification outcomes from the work state file
- [ ] 4. **Check halt_at boundary** — if `halt_at == plan_created`, HALT. Do NOT task() to implementation. The authorization scope stops at plan creation.
- [ ] 5. **Step 5.5: RED Phase Verification Checkpoint — Content and Behavioral (MANDATORY)** — Before task()ing to the implementation-pipeline per the SKILL.md Trigger Dispatch Table, the agent MUST verify that for each TDD-marked implementation item, a RED test artifact exists. The type of RED test depends on whether the item is a rule change or a code change:

   - **For rule/guideline items** (changes to `.opencode/guidelines/*.md`, `.opencode/skills/*/SKILL.md`, `.opencode/skills/*/tasks/*.md`, critical violation text, agent behavior rules): The RED test artifact MUST be a **behavioral enforcement test** — one that sends the agent a prompt and verifies the agent does NOT follow the new rule yet (test FAILS because the rule change hasn't been made). Content-verification (grep for text presence) is SECONDARY and does NOT satisfy the behavioral RED gate for rule items. See `080-code-standards.md` → Behavioral Enforcement Tests (PRIMARY) and `091-incremental-build.md` → Behavioral Variant for Rule Items. **The prompt MUST be a real-domain scenario (e.g., actual audit prompt, actual implementation request) — NOT a prose-recall prompt (e.g., 'Describe how you would resolve models'). Behavioral evidence is collected from stderr (agent actions), not stdout prose recall. Stderr assertion helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) are the PRIMARY assertion mechanism.**
   - **For code items** (changes to `src/`, `test/`, Python files, notebook cells): The RED test artifact MUST be a **unit or integration test** that verifies the implementation behavior before the change exists. Standard TDD RED phase applies.

   - **5a.** For each item in the plan that requires implementation (not documentation-only), confirm that an enforcement test exists in `.opencode/tests-v2/test-enforcement.sh` or `.opencode/tests-v2/behaviors/` that corresponds to that item's change.
   - **5b.** For rule/guideline items: confirm the enforcement test is a **behavioral test** (uses `.opencode/tests-v2/behaviors/helpers.sh` assertion helpers like `assert_stderr_pattern_present`, `assert_stderr_pattern_absent`, `assert_tool_calls_made`, `assert_forbidden_pattern_absent`, `assert_required_pattern_present`). For code items: confirm the test is a unit/integration test that exercises the changed functionality.
   - **5c.** Confirm the enforcement test has been run and produced a FAILURE result (RED state) — the test must fail because the implementation change does not yet exist. For behavioral tests, run `bash .opencode/tests-v2/behaviors/<scenario>.sh` — the `with-test-home` wrapper is baked into `behavior_run()` in `helpers.sh`. Do NOT run bare `opencode run` or recreate the test infrastructure.
   - **5d.** If no RED test artifact exists for a TDD-marked item, or if a rule item only has a content-verification test (grep pattern) without a behavioral test, the agent MUST HALT and require the behavioral RED phase to be completed before proceeding. Content-verification alone does NOT satisfy the RED gate for rule changes per `080-code-standards.md` → Behavioral Enforcement Tests (PRIMARY).
   - **5e.** Tool-call artifact REQUIRED: The agent must produce a tool-call artifact (e.g., `grep` or `bash` command output) proving that the RED test check was performed, showing the test exists and was verified to be in RED state.

   This checkpoint enforces the per-item TDD cycle mandated by `091-incremental-build.md`. For rule items, it enforces the behavioral TDD variant — behavioral tests must exist and be in RED state before implementation begins. Content-verification tests are secondary for rule changes. Skipping this checkpoint is a critical violation per `000-critical-rules.md`.

#### Step 5.5a — Verify Behavioral Enforcement Test Files Exist (Missing-Test Recovery)

**5.5a.** Before task()ing, verify behavioral enforcement test files exist for each TDD-marked item. If absent, create them from the spec's Success Criteria test mandate. If present, run them and confirm they fail (RED). If they pass, HALT.

This makes the implementation phase resilient to branch switching, worktree recreation, and developer context-switching.

- [ ] 6. **Behavioral uplift at TDD start:** When starting TDD for an item, if the change affects runtime behavior, declare the SC evidence type as `behavioral`. The classification question ("Does this change affect runtime behavior?") is substrate-determined. See `guidelines/000-critical-rules.md` §critical-rules-BEH-EV.

- [ ] 7. **Task() to implementation-pipeline:**

```
`skill({name: "implementation-pipeline"})` then dispatch per the SKILL.md Trigger Dispatch Table
```

When task()ing, pass `authorization_scope`, `halt_at`, and `pipeline_phase` alongside `plan_issue`, `spec_issue`, `<github.owner>`, `<github.repo>`, and `<worktree.path>`. The implementation-pipeline uses these fields for scope-aware task() boundary enforcement per the SKILL.md Trigger Dispatch Table.

**Authorization context:**
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```
- Missing `authorization_scope` → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

The phase progress information comes from two sources:
- The `{project_root}/tmp/{N}/work.md` state file (which phases are marked complete)
- Concern boundary annotations in the plan body (prose descriptions of architectural concern transitions)

Phase progress is prose-driven — the orchestrating agent describes progress in natural prose. The requirement is that the information travels, not that it follows a rigid schema.

The implementation-pipeline per the SKILL.md Trigger Dispatch Table handles:

- Creating feature branches and worktrees
- Sub-agent task() for each implementation item
- Squash-merging feature branches into work branch
- Verification gates (verification-before-completion, finishing-a-development-branch)

**There is no single-issue bypass.** Single issue = work of one = one sub-agent.

## Legacy Task Redirects

| Legacy Task | Redirect Target |
|------------|----------------|
| `step` | `implementation-pipeline` per the SKILL.md Trigger Dispatch Table |
| `progress` | `implementation-pipeline` per the SKILL.md Trigger Dispatch Table |
| `verify` | `verification-before-completion --task verify` |

## Enforcement

- No approval → HALT (approval-gate blocks)
- Placeholders in plan → HALT (writing-plans blocks)
- No feature branch → HALT (git-workflow creates)