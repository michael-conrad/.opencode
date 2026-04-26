---
name: pr-creation-workflow
description: Use when asking about when to create a PR or whether PR creation is authorized. Triggers on: create PR, make PR, pull request, PR timing, when to PR, PR authorized. This skill covers feature branch PRs targeting dev only. Release PRs (dev → main promotion) are handled by git-workflow --task release-promotion. Do NOT invoke this skill for release promotion requests.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# PR Creation Workflow Skill

## Overview

PR creation is a DISTINCT phase requiring EXPLICIT instruction — it is NOT automatic after implementation. "Approved" and "go" authorize implementation ONLY, not PR creation. The developer MUST explicitly say "create a PR" or equivalent.

## Exclusions

This skill covers **feature branch PRs targeting `dev`** only. Release PRs (dev → main promotion) are handled by `git-workflow --task release-promotion`. The routing decision boundary:

- Feature PR (feature/* → dev) → `pr-creation-workflow` skill
- Release PR (dev → main) → `git-workflow --task release-promotion`

Do NOT invoke this skill for release promotion requests.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `pre-pr-checklist` | Mandatory checks before PR creation (squash, changelog, branch state) | ≈500 |
| `sub-issue-collection` | Fetch and include sub-issues in PR body for autoclose | ≈300 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Invocation

- `/skill pr-creation-workflow --task pre-pr-checklist` - Run mandatory pre-PR checks
- `/skill pr-creation-workflow --task sub-issue-collection` - Collect sub-issues for PR body
- `/skill pr-creation-workflow --task completion` - Invoke when workflow halts at any point
- `/skill pr-creation-workflow` - Overview only

## Authorization Boundary (CRITICAL)

### What Authorizes Implementation (BUT NOT PR — Unless Pipeline Scope Applies)

| Authorization | Meaning | PR Authorized? |
|---------------|---------|----------------|
| `approved` | Begin implementation | ❌ NO (unless scope >= for_pr) |
| `go` | Proceed to next task | ❌ NO (unless scope >= for_pr) |
| `approved: 1` | Implement Phase 1 | ❌ NO (unless scope >= for_pr) |
| `proceed` | Continue with plan | ❌ NO (unless scope >= for_pr) |
| `approved #N to PR` / `for PR` | Pipeline authorization through PR | ✅ YES (scope >= for_pr) |
| `pr_only` | PR creation only | ✅ YES |

### What Authorizes PR Creation

"create a PR", "make a PR", "push and create PR", "let's get a PR up", "create a pull request", "PR" (bare), "PR #NNN"

**Pipeline scope authorization:** When `authorization_scope >= for_pr` or scope is `pr_only`, the user's pipeline instruction authorizes PR creation as part of the scope. No separate "create a PR" instruction is required.

## Operating Protocol

1. **After implementation completes:** Report completion, HALT. Do NOT ask about PRs.
2. **When developer says "create a PR":** Run pre-PR checklist, squash, push, create PR, report URL, HALT.
3. **Never merge PRs:** Merging is HUMAN-ONLY operation.
4. **Never create PR without explicit instruction:** "approved" does NOT authorize PR creation.

## Pre-PR Creation Checklist (MANDATORY)

- Squash verification: ONE commit for single-issue branches; N commits (one per item) for work branches
- Work branch detection: Check for `.opencode/tmp/work-*.md` — if present, skip re-squashing
- Work state guard: If `.opencode/tmp/work-*.md` exists, individual feature branch PRs are FORBIDDEN. Only the work branch may have a PR created. HALT if attempting to create an individual PR during work execution.
- Changelog generated (all platforms, no exceptions)
- Branch state: working tree clean
- Push verification: no unpushed commits
- Co-author trailers: both AI and human trailers included
- Issue references: `Fixes #<parent>` for parent, `Fixes #<child>` for each sub-issue; for work PRs include `## Work Issues` section listing all implemented issues; PR strategy determines whether single stacked PR or individual PRs

## After PR Creation

1. Report URL in chat (NEVER to GitHub Issues)
2. HALT — wait for human to merge
3. Never merge PRs — HUMAN-ONLY operation
4. Delete merged branches AFTER merge confirmation

## Prohibitions

- Create PRs autonomously or after "approved"/"go"
- Ask "Ready for a PR?" or "Should I create a PR?"
- Merge PRs
- Submit PR without squashing to single commit
- Close issues before PR merge

## Live Verification: PR State Claims (MANDATORY)

**🚫 CRITICAL: When this skill verifies PR readiness, it MUST check against live git/GitHub state (not cached or claimed). PR readiness claims without live verification are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| PR Readiness Claim | Verification Action | Tool Call | Problem Class |
|--------------------|-------------------|-----------|---------------|
| "All changes committed" | Verify working tree is clean | `bash` to run `git status` → confirm "nothing to commit" | VERIFICATION-GAP |
| "Branch pushed to remote" | Verify remote tracking branch exists | `bash` to run `git log origin/<branch>..HEAD` → confirm empty | MISSING-ELEMENT |
| "Squash is clean (single commit)" | Verify commit count on branch | `bash` to run `git log --oneline dev..HEAD \| wc -l` | STRUCTURE-VIOLATION |
| "Changelog generated" | Verify changelog file exists and is current | `glob(pattern="**/CHANGELOG*")` | MISSING-ELEMENT |
| "Co-author trailers present" | Verify commit message contains trailers | `bash` to run `git log -1 --format="%B"` → check trailers | MISSING-ELEMENT |
| "Sub-issues included in PR body" | Verify PR body after creation references sub-issues | `github_pull_request_read(method=get)` → check body | VERIFICATION-GAP |

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
| Uncommitted changes | VERIFICATION-GAP | auto-fix | Commit remaining changes |
| Branch not pushed | MISSING-ELEMENT | auto-fix | Push branch and re-verify |
| Multiple commits not squashed | STRUCTURE-VIOLATION | auto-fix | Squash commits |
| Changelog missing | MISSING-ELEMENT | auto-fix | Generate changelog |
| Co-author trailers missing | MISSING-ELEMENT | auto-fix | Amend commit with trailers |
| Sub-issues not in PR body | VERIFICATION-GAP | auto-fix | Update PR body |

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `git-workflow` in Cross-References | File exists at `.opencode/skills/git-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `git-workflow` pr-creation task | Task exists at `.opencode/skills/git-workflow/tasks/pr-creation.md` | MISSING-TRACEABILITY if missing |
| `000-critical-rules.md` in Cross-References | Guideline exists at `.opencode/guidelines/000-critical-rules.md` | MISSING-TRACEABILITY if missing |
| `020-go-prohibitions.md` in Cross-References | Guideline exists at `.opencode/guidelines/020-go-prohibitions.md` | MISSING-TRACEABILITY if missing |
| `010-approval-gate.md` in Cross-References | Guideline exists at `.opencode/guidelines/010-approval-gate.md` | MISSING-TRACEABILITY if missing |
| `spec-auditor` ground-truth subtask | File exists at `.opencode/skills/spec-auditor/tasks/ground-truth.md` | MISSING-TRACEABILITY if missing |
| `065-verification-honesty.md` metadata extension | Guideline contains "Metadata Verification Extension" section | CONFLICTING if missing |
| Task table entry `pre-pr-checklist` | File exists at `.opencode/skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | MISSING-TRACEABILITY if missing |
| Task table entry `sub-issue-collection` | File exists at `.opencode/skills/pr-creation-workflow/tasks/sub-issue-collection.md` | MISSING-TRACEABILITY if missing |

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
| Referenced guideline missing | MISSING-TRACEABILITY | flag-for-review | Guideline may have been renumbered |
| Described behavior mismatches | CONFLICTING | flag-for-review | Cross-reference may be stale |

**Adversarial cross-reference:** The `spec-auditor --task ground-truth` subtask (Phase 1 of spec #827) performs adversarial verification of metadata claims including authorization currency. When this skill encounters PR readiness claims that may be based on stale state (e.g., claiming "all changes committed" based on a previous check), it MUST verify against live git state. See `065-verification-honesty.md` → "Metadata Verification Extension" for the extended principle.

## Cross-References

| Guideline | Content |
|-----------|---------|
| `git-workflow` skill `pr-creation` task | Full PR workflow |
| `000-critical-rules.md` | Critical violation: PRs without instruction |
| `020-go-prohibitions.md` | GO does not authorize PR |
| `010-approval-gate.md` | PR timing requirements |
| `git-workflow` skill | Post-merge workflow including issue closure |
| `spec-auditor` (ground-truth subtask) | Adversarial verification of authorization and PR state claims |
| `065-verification-honesty.md` | Metadata verification extension for PR readiness claims |

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps are never skipped. It is idempotent and safe to invoke multiple times.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-26T00:00:00Z"
rules:
  - id: pr-workflow-001
    title: "PR requires explicit instruction — approved/go does NOT authorize PR"
    conditions:
      all:
        - "pr_creation_attempted == true"
        - "explicit_pr_instruction_received == false"
        - "authorization_scope < for_pr"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "pr-creation-workflow/SKILL.md §Authorization Boundary"

  - id: pr-workflow-002
    title: "Base branch must be dev for feature PRs"
    conditions:
      all:
        - "pr_type == 'feature'"
        - "base_branch != 'dev'"
    actions:
      - HALT
      - SET(base_branch='dev')
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "000-critical-rules.md §Wrong Compare URL Base Branch"

  - id: pr-workflow-003
    title: "PR body must use Summary/Outcome/Fixes format"
    conditions:
      all:
        - "pr_creation_attempted == true"
        - "pr_body_format != 'summary_outcome_fixes'"
    actions:
      - REFORMAT(pr_body)
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "000-critical-rules.md §Wrong PR Body Format"

  - id: pr-workflow-004
    title: "No PR for dev-to-main (use release-promotion)"
    conditions:
      all:
        - "head_branch == 'dev'"
        - "base_branch == 'main'"
    actions:
      - HALT
      - INVOKE(git-workflow --task release-promotion)
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "pr-creation-workflow/SKILL.md §Exclusions"

  - id: pr-workflow-005
    title: "Squash verification before PR"
    conditions:
      all:
        - "pr_creation_attempted == true"
        - "squash_verified == false"
    actions:
      - HALT
      - SQUASH
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

  - id: pr-workflow-006
    title: "Never merge PRs — human-only operation"
    conditions:
      all:
        - "merge_attempted_by_agent == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist, sub-issue-collection]
    source: "pr-creation-workflow/SKILL.md §Operating Protocol point 3"

  - id: pr-workflow-007
    title: "Work branch guard — no individual PRs during work execution"
    conditions:
      all:
        - "work_state_file_exists == true"
        - "individual_pr_attempted == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

  - id: pr-workflow-008
    title: "Changelog required before PR"
    conditions:
      all:
        - "pr_creation_attempted == true"
        - "changelog_generated == false"
    actions:
      - HALT
      - GENERATE(changelog)
    conflicts_with: []
    requires: []
    triggers: [pre-pr-checklist]
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

  - id: pr-workflow-009
    title: "Pipeline scope >= for_pr authorizes PR creation"
    conditions:
      any:
        - "authorization_scope == 'for_pr'"
        - "authorization_scope == 'pr_only'"
    actions:
      - PROCEED(pr_creation_authorized)
    conflicts_with: [pr-workflow-001]
    requires: []
    triggers: [pre-pr-checklist]
    source: "pr-creation-workflow/SKILL.md §Authorization Boundary"

tasks:
  - id: pre-pr-checklist
    skill: pr-creation-workflow
    preconditions: ["explicit_pr_instruction_received OR authorization_scope >= for_pr"]
    postconditions: ["squash_verified", "changelog_generated", "branch_clean", "push_verified", "co_author_trailers_present", "issue_references_in_body"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping pre-PR checklist risks un-squashed commits, missing changelog, and stale branch state"
    source: "pr-creation-workflow/SKILL.md §Tasks"

  - id: sub-issue-collection
    skill: pr-creation-workflow
    preconditions: ["parent_issue_has_sub_issues"]
    postconditions: ["sub_issues_included_in_pr_body"]
    mandatory: false
    bypass_violation: "Sub-issue collection needed for work PRs but not required for single-issue branches"
    source: "pr-creation-workflow/SKILL.md §Tasks"

  - id: completion
    skill: pr-creation-workflow
    preconditions: ["workflow_halted_or_completed"]
    postconditions: ["mandatory_steps_verified", "status_reported"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping completion task may leave PR state unverified"
    source: "pr-creation-workflow/SKILL.md §Tasks"

decomposition:
  - type: skill-task
    skill: git-workflow
    task: pr-creation
    mandatory: true
    bypass_violation: "git-workflow pr-creation handles actual PR API call with URL extraction"
    source: "pr-creation-workflow/SKILL.md §Cross-References"

  - type: skill-task
    skill: git-workflow
    task: review-prep
    mandatory: true
    bypass_violation: "review-prep produces compare URL and verifies branch push state"
    source: "pr-creation-workflow/SKILL.md §Cross-References"

  - type: skill-task
    skill: git-workflow
    task: cleanup
    mandatory: true
    bypass_violation: "Post-merge cleanup handles branch deletion and issue closure"
    source: "pr-creation-workflow/SKILL.md §After PR Creation"

  - type: skill-task
    skill: changelog-generator
    task: generate
    mandatory: true
    bypass_violation: "Changelog generation required before PR creation"
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

  - type: sub-agent-dispatch
    isolation: clean-room
    must_receive: [branch compare data, spec summary]
    must_not_receive: [implementation context, agent memory from prior phases, cached verification results]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Clean-Room Dispatch for Sub-Agents"

gates:
  - id: explicit-pr-instruction
    condition: "explicit_pr_instruction_received == true OR authorization_scope >= for_pr"
    on_fail: HALT
    critical_violation: true
    source: "pr-creation-workflow/SKILL.md §Authorization Boundary"

  - id: base-branch-is-dev
    condition: "base_branch == 'dev' ( for feature PRs )"
    on_fail: HALT
    critical_violation: true
    source: "000-critical-rules.md §Wrong Compare URL Base Branch"

  - id: squash-verified
    condition: "squash_verified == true"
    on_fail: HALT
    critical_violation: true
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

  - id: changelog-present
    condition: "changelog_generated == true"
    on_fail: HALT
    critical_violation: false
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

  - id: no-agent-merge
    condition: "merge_attempted_by_agent == false"
    on_fail: HALT
    critical_violation: true
    source: "pr-creation-workflow/SKILL.md §Operating Protocol point 3"

  - id: work-branch-guard
    condition: "work_state_file_exists == false OR pr_is_work_branch == true"
    on_fail: HALT
    critical_violation: true
    source: "pr-creation-workflow/SKILL.md §Pre-PR Creation Checklist"

evidence_artifacts:
  - name: working_tree_clean
    type: tool_call
    verification: "bash: git status → confirm 'nothing to commit'"
    source: "pr-creation-workflow/SKILL.md §Live Verification"

  - name: branch_pushed
    type: tool_call
    verification: "bash: git log origin/<branch>..HEAD → confirm empty"
    source: "pr-creation-workflow/SKILL.md §Live Verification"

  - name: squash_commit_count
    type: tool_call
    verification: "bash: git log --oneline dev..HEAD | wc -l → single commit for single-issue, N for work"
    source: "pr-creation-workflow/SKILL.md §Live Verification"

  - name: changelog_file_exists
    type: file_exists
    verification: "glob(pattern='**/CHANGELOG*') → file exists"
    source: "pr-creation-workflow/SKILL.md §Live Verification"

  - name: co_author_trailers
    type: tool_call
    verification: "bash: git log -1 --format='%B' → check for AI and human trailers"
    source: "pr-creation-workflow/SKILL.md §Live Verification"

  - name: pr_url_extraction
    type: api_call
    verification: "github_create_pull_request response → html_url field (NEVER constructed from template)"
    source: "000-critical-rules.md §URL Sourcing Rule 1"
```