---
name: finishing-a-development-branch
description: Use when implementation is complete and branch needs final checks before PR. Triggers on: done, finished, ready for PR, implementation complete, branch ready, push changes, final check.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: finishing-a-development-branch

## Overview

Branch completion workflow that ensures a feature branch is fully ready for PR creation. Verifies all changes are committed, tested, pushed, and reviewed before the developer creates a PR. Implementation tracks against plan sub-issues, not spec sub-issues. Adapted from the \<UPSTREAM_ORG>/\<UPSTREAM_REPO> workflow.

**Source Attribution:** This skill is adapted from \<UPSTREAM_ORG>/\<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `prepare` | Prepare branch for PR creation | ≈450 |
| `checklist` | Run completion checklist | ≈350 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈200 |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `prepare` | ≈450 |
| `checklist` | ≈350 |
| `completion` | ≈200 |

## Invocation

- `/skill finishing-a-development-branch` — Overview only
- `/skill finishing-a-development-branch --task prepare` — Prepare branch for PR
- `/skill finishing-a-development-branch --task checklist` — Run completion checklist
- `/skill finishing-a-development-branch --task completion` — Invoke when workflow halts at any point

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps (push, compare URL, status report) are never skipped. It is idempotent and safe to invoke multiple times.

## Operating Protocol

1. **Mandatory invocation (no decision point):** The agent MUST invoke this skill when implementation completes on a feature branch, when the user says "done" or "finished" or "ready for PR", or before review-prep task in git-workflow.
2. **Verification-first approach:** All changes must be committed. All tests must pass. All lint/typecheck must pass. Branch must be pushed to remote.
3. **Exit conditions:** Branch is READY when all checklist items pass, compare URL is generated, and agent HALTs to report readiness.
4. **Branch mode (conditional):** Feature branches operate either directly in main repo (default) or in worktrees (when `WORKTREE_REQUIRED` set). In worktree mode, if `worktree.path` is not set: FATAL ERROR → FLAG DEV → HALT.

## Worktree Mode (Conditional — Only When WORKTREE_REQUIRED)

When `WORKTREE_REQUIRED` is set and `worktree.path` is set: all file operations prefix paths with `worktree.path`.

When `WORKTREE_REQUIRED` is NOT set (direct-branch mode): operate normally from the main repo directory. No worktree cleanup needed.

**If in worktree mode and `worktree.path` is empty:** **FATAL ERROR → FLAG DEV → HALT.** Do not proceed without a valid worktree path.

- All `bash` tool calls use `workdir="{{worktree.path}}"` (worktree mode only)
- All `read`/`edit`/`write`/`glob`/`grep` tool calls prefix paths with `{{worktree.path}}/` (worktree mode only)
- NEVER operate on `main` or `dev` branch during implementation (regardless of mode)

## Lazy-Loaded Guidelines

When invoked, this skill requires the following guidelines to be loaded on-demand (they are not permanently loaded):

- **Load guideline:** `.opencode/guidelines/065-verification-honesty.md` — Required before branch completion verification claims

## Integration with Existing Workflow

### Dispatch Order

```
executing-plans → verification-before-completion → finishing-a-development-branch → review-prep → (PR creation by user)
```

### Plan Hierarchy Context

Implementation tracks against **plan sub-issues**, not spec sub-issues. The hierarchy is: Spec → (linked reference in body) → Plan → Sub-issues. When verifying branch completion, reference the plan issue for tracking status and the spec issue for requirements.

### Git-Workflow Integration

- This skill runs BEFORE review-prep
- review-prep handles squash and push
- finishing-a-development-branch handles quality verification

### PR Creation

- This skill does NOT create PRs
- PR creation requires explicit "create a PR" instruction
- After checklist passes, report readiness and HALT

## Live Verification: Checklist Evidence (MANDATORY)

**🚫 CRITICAL: Each checklist item in the `checklist` task MUST produce a tool-call artifact demonstrating the check was actually performed, not just checked off. Checklist assertions without tool-call evidence are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Checklist Item | Verification Action | Tool Call | Problem Class |
|---------------|-------------------|-----------|---------------|
| "All changes committed" | Verify working tree is clean | `bash` to run `git status` → confirm "nothing to commit" | VERIFICATION-GAP |
| "Tests pass" | Verify by running tests | `bash` to run `uv run pytest test/` → confirm exit code 0 | VERIFICATION-GAP |
| "Lint passes" | Verify by running linter | `bash` to run `uvx ruff check src/ test/` → confirm no errors | VERIFICATION-GAP |
| "Branch pushed to remote" | Verify remote branch exists | `bash` to run `git log origin/<branch>..HEAD` → confirm empty | MISSING-ELEMENT |
| "All files in worktree" | Verify all changed files are under worktree.path (worktree mode only) | `bash` to run `git diff --name-only HEAD≈1` → check paths | STRUCTURE-VIOLATION |

**Evidence format:**

```
Check: [what was verified]
Tool: [tool call and parameters]
Result: [actual state found]
Classification: [STRUCTURE-VIOLATION|MISSING-ELEMENT|CONFLICTING|VERIFICATION-GAP|MISSING-TRACEABILITY]
Action: [auto-fix|conditional|flag-for-review]
```

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Uncommitted changes found | VERIFICATION-GAP | auto-fix | Commit remaining changes |
| Tests failing | VERIFICATION-GAP | flag-for-review | HALT — fix test failures before proceeding |
| Lint errors found | VERIFICATION-GAP | auto-fix | Run `ruff check --fix` and re-verify |
| Branch not pushed | MISSING-ELEMENT | auto-fix | Push branch and re-verify |
| Changes outside worktree (worktree mode only) | STRUCTURE-VIOLATION | flag-for-review | HALT — investigate, may need worktree re-creation |

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `git-workflow` in Cross-References | File exists at `.opencode/skills/git-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `verification-before-completion` in Cross-References | File exists at `.opencode/skills/verification-before-completion/SKILL.md` | MISSING-TRACEABILITY if missing |
| `pr-creation-workflow` in Cross-References | File exists at `.opencode/skills/pr-creation-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `spec-auditor` ground-truth subtask | File exists at `.opencode/skills/spec-auditor/tasks/ground-truth.md` | MISSING-TRACEABILITY if missing |
| `065-verification-honesty.md` metadata extension | Guideline contains "Metadata Verification Extension" section | CONFLICTING if missing |
| Task table entry `prepare` | File exists at `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` | MISSING-TRACEABILITY if missing |
| Task table entry `checklist` | File exists at `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` | MISSING-TRACEABILITY if missing |
| Task table entry `completion` | File exists at `.opencode/skills/finishing-a-development-branch/tasks/completion.md` | MISSING-TRACEABILITY if missing |
| `git-workflow` review-prep task | Task exists at `.opencode/skills/git-workflow/tasks/review-prep.md` | MISSING-TRACEABILITY if missing |

**Verification Procedure:**

Before invoking any cross-referenced skill:
1. `ls .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: file exists or MISSING-TRACEABILITY
2. `grep -c "<task-name>" .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: task referenced or MISSING-TRACEABILITY
3. Compare described behavior with actual content → EVIDENCE: match or CONFLICTING

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Referenced skill file missing | MISSING-TRACEABILITY | flag-for-review | Cannot verify cross-reference |
| Referenced task file missing | MISSING-TRACEABILITY | flag-for-review | Task may have been renamed |
| Described behavior mismatches | CONFLICTING | flag-for-review | Cross-reference may be stale |
| review-prep task missing | MISSING-TRACEABILITY | flag-for-review | git-workflow may have been restructured |

**Adversarial cross-reference:** The `spec-auditor --task ground-truth` subtask (Phase 1 of spec #827) performs adversarial verification of metadata claims including STATUS markers, labels, and authorization currency. When this skill encounters a checklist "all clear" but the ground-truth model suggests the branch state may be inconsistent, invoke `spec-auditor --task ground-truth` to verify. See `065-verification-honesty.md` → "Metadata Verification Extension" for the extended principle.

## Cross-References

- Related skills: `git-workflow` (branch management, mandatory post-merge cleanup), `verification-before-completion` (evidence), `pr-creation-workflow` (PR timing), `spec-auditor` (ground-truth adversarial verification)
- Related guidelines: `000-critical-rules.md` (review-prep required), `060-tool-usage.md` (build/lint commands), `065-verification-honesty.md` (metadata verification extension)
- Authorization classification: See `010-approval-gate.md` §Action Authorization Classification

## Platform Compatibility

- **GitHub:** Not applicable (this repository uses GitBucket)
- **GitBucket:** Fully supported — uses GitBucket compare URL format
- **Platform Detection:** Uses `github.platform` environment variable

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-26T00:00:00Z"
rules:
  - id: finishing-a-development-branch-001
    title: "All changes must be committed before branch completion"
    conditions:
      all:
        - "working_tree_not_clean == true"
    actions:
      - COMMIT_REMAINING
      - RE_VERIFY
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "finishing-a-development-branch/SKILL.md §checklist task"

  - id: finishing-a-development-branch-002
    title: "All tests must pass before branch completion"
    conditions:
      all:
        - "tests_pass == false"
    actions:
      - HALT
      - FIX_TESTS
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "finishing-a-development-branch/SKILL.md §checklist task"

  - id: finishing-a-development-branch-003
    title: "All lint must pass before branch completion"
    conditions:
      all:
        - "lint_pass == false"
    actions:
      - AUTOFIX_THEN_REVERIFY
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "finishing-a-development-branch/SKILL.md §checklist task"

  - id: finishing-a-development-branch-004
    title: "Branch must be pushed before claiming completion"
    conditions:
      all:
        - "branch_pushed == false"
    actions:
      - PUSH
      - RE_VERIFY
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "finishing-a-development-branch/SKILL.md §checklist task"

tasks:
  - id: prepare
    skill: finishing-a-development-branch
    preconditions: ["implementation_complete == true"]
    postconditions: ["branch_prepared_for_pr == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Branch Preparation"
    source: "finishing-a-development-branch/SKILL.md"

  - id: checklist
    skill: finishing-a-development-branch
    preconditions: ["branch_prepared_for_pr == true"]
    postconditions: ["lint_pass == true && tests_pass == true && branch_pushed == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Uncommitted/Unpushed Changes After Implementation"
    source: "finishing-a-development-branch/SKILL.md"
    evidence_artifacts:
      - gate: lint
        verification: "uvx ruff check src/ test/"
        expected: "zero errors"
      - gate: test
        verification: "uv run pytest test/"
        expected: "all tests pass"
      - gate: push
        verification: "git log origin/<branch>..HEAD"
        expected: "empty (all commits pushed)"

  - id: completion
    skill: finishing-a-development-branch
    preconditions: ["any_state"]
    postconditions: ["completion_tasks_executed == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Completion Guarantee on Workflow Halt"
    source: "finishing-a-development-branch/SKILL.md"

decomposition:
  - type: skill-task
    skill: verification-before-completion
    task: verify
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Verification"
  - type: command
    skill: git
    task: push
    mandatory: true
    bypass_violation: "CRITICAL: Unpushed Changes"
  - type: sub-agent-dispatch
    isolation: clean-room
    must_receive: [checklist items, verification targets]
    must_not_receive: [implementation context, agent memory from prior phases, cached verification results]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Clean-Room Dispatch for Sub-Agents"
state_machines:
  - id: branch-completion-lifecycle
    states: [prepared, linted, tested, pushed, completed, failed]
    start_state: prepared
    decomposition_guard:
      field: "decomposition.verification_commands"
      message: "CRITICAL: Cannot complete branch without verification steps"
    transitions:
      - from: prepared
        to: linted
        guard: "lint_pass == true"
        action: RUN_TESTS
      - from: prepared
        to: failed
        guard: "lint_pass == false && autofix_failed == true"
        action: HALT_AND_FIX_LINT
      - from: linted
        to: tested
        guard: "tests_pass == true"
        action: PUSH_BRANCH
      - from: linted
        to: failed
        guard: "tests_pass == false"
        action: HALT_AND_FIX_TESTS
      - from: tested
        to: pushed
        guard: "branch_pushed == true"
        action: GENERATE_URL
      - from: pushed
        to: completed
        guard: "compare_url_generated == true"
        action: REPORT_COMPLETE
gates:
  - id: working-tree-clean
    condition: "working_tree_not_clean == false"
    on_fail: "COMMIT_REMAINING and re-verify"
    critical_violation: true
  - id: lint-pass
    condition: "lint_pass == true"
    on_fail: "AUTOFIX_THEN_REVERIFY"
    critical_violation: false
  - id: tests-pass
    condition: "tests_pass == true"
    on_fail: "HALT and fix tests"
    critical_violation: true
  - id: branch-pushed
    condition: "branch_pushed == true"
    on_fail: "PUSH and re-verify"
    critical_violation: true
evidence_artifacts:
  - name: lint_output
    type: tool_call
    verification: "uvx ruff check src/ test/ returns zero errors"
  - name: test_output
    type: tool_call
    verification: "uv run pytest test/ passes"
  - name: push_confirmation
    type: tool_call
    verification: "git push output confirms branch pushed"
  - name: compare_url
    type: constructed_url
    verification: "URL format matches dev...branch pattern"
```
