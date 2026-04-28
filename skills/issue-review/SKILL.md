---
name: issue-review
description: Use when reviewing a GitHub issue for comments, audits, or Q/A. Triggers on: review issue, review spec, check issue, issue review, audit issue.
type: orchestrator
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: issue-review

## Overview

**MANDATORY: The agent MUST invoke `issue-review` when reviewing a GitHub issue. Skipping this invocation is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Bypassing Mandatory Skill Invocations.** Exempt: no issue review requested.

Unified "review" command for GitHub Issues. Gathers issue data, classifies the review path via content analysis (not label conventions), delegates to appropriate downstream skills, and handles Q/A for non-spec issues. One entry point replaces manual orchestration of comment reading, audit detection, and audit execution.

## Persona

You are an Issue Review Orchestrator. Your focus is gathering all issue context, classifying the right review path, and delegating to the correct downstream skill or workflow.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `gather` | Collect all issue data (body, comments, labels, sub-issues, auth status) | ≈500 |
| `triage` | Two-pass classification: pattern signals + AI verification | ≈600 |
| `audit` | Delegate to `spec-auditor` with triage hints | ≈350 |
| `qa` | Ask clarifying questions one at a time for non-bug, non-spec issues | ≈500 |
| `analyze-and-spec` | Root cause analysis → fix spec auto-creation for bug reports | ≈600 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `gather` | When collecting all issue data for review | Issue number, github.owner, github.repo | Implementation context, agent memory, cached verification | NO |
| `triage` | When classifying an issue by type and priority | Issue number, gathered data, github.owner, github.repo | Implementation context, agent memory | NO |
| `audit` | When delegating to spec-auditor with triage hints | Issue number, triage results, github.owner, github.repo | Implementation context, agent memory | NO |
| `qa` | When asking clarifying questions for non-bug, non-spec issues | Issue number, github.owner, github.repo | Implementation context, agent memory | NO |
| `analyze-and-spec` | When root cause analysis and fix spec creation for bug reports | Issue number, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill issue-review --issue N` — Full review (gather → triage → dispatch)
- `/skill issue-review --issue N --task gather` — Data collection only
- `/skill issue-review --issue N --task triage` — Classification only (requires prior gather)
- `/skill issue-review --issue N --task audit` — Audit delegation only (requires prior triage)
- `/skill issue-review --issue N --task qa` — Q/A mode for non-bug, non-spec issues
- `/skill issue-review --issue N --task analyze-and-spec` — Root cause analysis + fix spec for bug reports
- `/skill issue-review --issue N --task completion` — Invoke when workflow halts at any point
- `/skill issue-review` — Overview only

## Operating Protocol

**Pre-implementation file changes are ephemeral.** Any modifications to project source files made during this phase are not committed and will likely be silently discarded before the plan is approved for implementation. Only the artifact produced by this skill (the spec, plan, bug report, or issue) persists.

1. **Mandatory issue parameter:** This skill MUST be invoked with `--issue N` where N is the GitHub Issue number to review.

2. **Automatic workflow:** When invoked without `--task`, the full workflow runs:
   - `gather` → `triage` → path dispatch → recursive sub-issue handling

3. **Comments read first (CRITICAL):** `gather` reads ALL comments before any triage decision, per `067-context-completeness.md`.

4. **No label dependency:** Triage uses content analysis, not `[SPEC]` prefix or other label conventions.

5. **Sub-issue recursion:** When sub-issues exist, the full workflow runs on each sub-issue independently.

## Orchestration Flow

```
review #N
  ├── gather (issue + sub-issues data)
  ├── triage (pattern signals + AI verification → path decision)
  ├── path dispatch:
  │   ├── audit → spec-auditor with hints → exec summary to chat
  │   ├── analyze-and-spec → root cause analysis → fix spec sub-issue → exec summary to chat
  │   ├── qa → one-at-a-time questions in chat → exec summary to issue
  │   ├── just-review → exec summary of current state to chat
  │   └── already-handled → full re-verification → status to chat
  └── recurse for sub-issues (gather → triage → dispatch for each)
```

## Triage Paths

| Path | When | Output Target |
|------|------|---------------|
| `audit` | Content looks like a spec (phases/steps, success criteria, edge cases) | Chat exec summary |
| `analyze-and-spec` | Bug report (crash, error, broken, steps to reproduce) | Fix spec sub-issue linked to bug report |
| `qa` | Non-bug, non-spec issue needing clarification (feature ideas, vague requests) | Chat questions, then issue exec summary |
| `just-review` | Already-audited spec with no new relevant comments | Chat exec summary |
| `already-handled` | Issue appears complete (approved + implemented) | Chat re-verification status |

## Path Dispatch Details

### Audit Path

Invoke `spec-auditor --issue N` with triage hints about which subtasks are relevant:

| Spec Type | Hint |
|-----------|------|
| Simple bug-fix spec | "likely baseline only" |
| Feature with phases | "baseline + concerns likely relevant" |
| Complex multi-phase spec | "all subtasks likely relevant" |

Hints inform but do not override — `spec-auditor` retains its own subtask selection logic.

**CRITICAL:** Audit findings are internal agent guidance — DO NOT post to GitHub comments (per `000-critical-rules.md`). Produce prose exec summary for chat only.

### Analyze-and-Spec Path

Invoke `analyze-and-spec` task for root cause analysis and fix spec auto-creation. See `tasks/analyze-and-spec.md` for full procedure.

**CRITICAL: Symptom-only fix-specs are a CRITICAL GUIDELINE VIOLATION.** Every fix spec created through this path MUST include a "Root Cause" section identifying the underlying cause, and the "Fix Approach" section MUST target the root cause — not just the observed symptom. See `000-critical-rules.md` → "Symptom-Only Fix-Specs" for the complete rule and anti-pattern table.

**Key behavior:**
- Bug language triggers this path (NOT `qa` anymore)
- Root cause analysis is read-only and MANDATORY — never skip to a quick fix
- Fix spec MUST include "Root Cause" and "Fix Approach" sections targeting the root cause
- Symptom-only patches (e.g., "just add the missing close call" without enforcement) are FORBIDDEN
- Fix spec sub-issue created and linked to bug report parent
- Smart checkpoint: auto-proceed if clear, HALT if ambiguous
- Fix spec still requires explicit authorization before code changes

### Q/A Path

Ask questions one at a time in chat. Q/A is for non-bug, non-spec issues only.

| Content Type | Q/A Depth |
|--------------|-----------|
| Feature with technical implications | Scope + feasibility |
| Feature idea that could become a spec | Scope + feasibility + offer to scaffold spec |
| Vague or unclear request (not a bug) | Scope clarification only |

On resolution, post exec summary to issue (durable outcomes only, not Q&A chatter). HALT after posting.

### Just-Review Path

Produce prose exec summary of current state including: authorization status, last audit summary, open questions, overall health assessment.

### Already-Handled Path

**Full re-verification — NEVER rely on history, comments, or memory.**

1. Verify GitHub state: issue closed, PR merged, sub-issues status
2. Verify implementation: check that files mentioned in spec exist in codebase
3. Verify tests: check test status for affected areas
4. For bug reports: check if fix spec sub-issue exists and is resolved
5. If fully verified: report "confirmed complete"
6. If gaps found: report what needs attention, suggest re-triage

## Final Report Format (CRITICAL)

All outputs follow prose format per `000-critical-rules.md`:

```
<optional details and analysis>

<exec summary>

<URL if relevant>

🤖 <AgentName> (<ModelId>) <status>
```

No template files. No structured schema output. Prose throughout.

## Lazy-Loaded Guidelines

When invoked, this skill requires the following guidelines to be loaded on-demand (they are not permanently loaded):

- **Load guideline:** `.opencode/guidelines/067-context-completeness.md` — Required before reading issue comments (mandatory per context completeness rule)

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `spec-auditor` in Cross-References and Audit Path | File exists at `.opencode/skills/spec-auditor/SKILL.md` | MISSING-TRACEABILITY if missing |
| `approval-gate` in Cross-References and gather task | File exists at `.opencode/skills/approval-gate/SKILL.md` | MISSING-TRACEABILITY if missing |
| `issue-operations` comment task in Cross-References section | File exists at `.opencode/skills/issue-operations/SKILL.md` | MISSING-TRACEABILITY if missing |
| `systematic-debugging` in Cross-References section | File exists at `.opencode/skills/systematic-debugging/SKILL.md` | MISSING-TRACEABILITY if missing |
| `issue-operations` in Cross-References section | File exists at `.opencode/skills/issue-operations/SKILL.md` | MISSING-TRACEABILITY if missing |
| `programming-principles` in Cross-References section | File exists at `.opencode/skills/programming-principles/SKILL.md` | MISSING-TRACEABILITY if missing |
| Task table entry `gather` | File exists at `.opencode/skills/issue-review/tasks/gather.md` | MISSING-TRACEABILITY if missing |
| Task table entry `triage` | File exists at `.opencode/skills/issue-review/tasks/triage.md` | MISSING-TRACEABILITY if missing |
| Task table entry `audit` | File exists at `.opencode/skills/issue-review/tasks/audit.md` | MISSING-TRACEABILITY if missing |
| Task table entry `qa` | File exists at `.opencode/skills/issue-review/tasks/qa.md` | MISSING-TRACEABILITY if missing |
| Task table entry `analyze-and-spec` | File exists at `.opencode/skills/issue-review/tasks/analyze-and-spec.md` | MISSING-TRACEABILITY if missing |
| `spec-auditor` audit delegation behavior | Matches actual SKILL.md: `audit` task delegates to spec-auditor with triage hints | CONFLICTING if mismatched |
| `approval-gate` authorization check behavior | Matches actual SKILL.md: `verify-authorization` task for authorization status | CONFLICTING if mismatched |
| `issue-operations` comment posting behavior | Matches actual SKILL.md: `comment` task format and routing rules | CONFLICTING if mismatched |
| `spec-auditor` ground-truth subtask | File exists at `.opencode/skills/spec-auditor/tasks/ground-truth.md` | MISSING-TRACEABILITY if missing |
| `065-verification-honesty.md` metadata extension | Guideline contains "Metadata Verification Extension" section | CONFLICTING if missing |

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
| Invocation mismatch | CONFLICTING | flag-for-review | Skill may have been updated |
| Ground-truth subtask missing | MISSING-TRACEABILITY | flag-for-review | spec-auditor may not have Phase 1 changes |

**Adversarial cross-reference:** The `spec-auditor --task ground-truth` subtask (Phase 1 of spec #827) performs adversarial verification of metadata claims including STATUS markers, label accuracy, comment verification, and authorization currency. When this skill's triage relies on comment claims or metadata state, ground-truth verification ensures those claims are accurate. See `065-verification-honesty.md` → "Metadata Verification Extension" for the extended principle.

## Live Verification: Comment Claims (MANDATORY)

**🚫 CRITICAL: When this skill reads issue comments and other metadata to make triage decisions, claims found in comments MUST be verified against live GitHub state. Trusting comment assertions without verification is a VERIFICATION-GAP finding per `065-verification-honesty.md`.**

| Metadata Trust Point | Verification Action | Tool Call | Problem Class |
|---------------------|-------------------|-----------|---------------|
| Comment claims "approved" | Verify authorization comment author is developer, scope matches current issue, not superseded | `github_issue_read(method=get_comments)` → filter by `author_association` | CONFLICTING |
| Comment claims "already implemented" | Verify referenced files exist and contain claimed implementation | `glob(pattern="**/file")` or `srclight_get_symbol(name="symbol")` | VERIFICATION-GAP |
| Comment claims "related to #N" | Verify issue #N exists and is relevant | `github_issue_read(method=get, issue_number=N)` | MISSING-TRACEABILITY |
| Comment claims issue status (closed, merged) | Verify actual state via GitHub API | `github_issue_read(method=get)` → check `state`, `state_reason` | CONFLICTING |
| Triage classification based on content claims | Verify content actually matches classification (e.g., "bug report" has bug language) | `github_issue_read(method=get)` → scan body for bug signals | STRUCTURE-VIOLATION |

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
| Authorization from non-developer | CONFLICTING | flag-for-review | HALT — requires real developer authorization |
| Claimed implementation not found | VERIFICATION-GAP | conditional | Re-triage based on actual state |
| Referenced issue does not exist | MISSING-TRACEABILITY | auto-fix | Remove broken reference |
| Claimed status contradicts actual | CONFLICTING | auto-fix | Use actual state for triage |
| Content does not match claimed type | STRUCTURE-VIOLATION | auto-fix | Re-classify based on actual content |

## Cross-References

- `spec-auditor`: Called by `audit` task for spec quality checks (including `ground-truth` adversarial verification subtask)
- `approval-gate`: Referenced for authorization status in `gather`; verifies fix spec for bug reports
- `systematic-debugging`: Invokes `analyze-and-spec` after bug report creation
- `issue-operations`: Called by `analyze-and-spec` for fix spec creation
- `programming-principles`: Principle context for audit path delegation
- `065-verification-honesty.md` (metadata verification extension): Extended "don't trust — verify" principle covering issue metadata

Base directory for this skill: `.opencode/skills/issue-review/`

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps are never skipped. It is idempotent and safe to invoke multiple times.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: issue-review-001
    title: "Bug discovery does NOT authorize fixing"
    conditions:
      all:
        - "bug_discovered_during_analysis == true"
        - "fix_authorization_received == false"
    actions:
      - HALT
      - CREATE(bug_report_issue)
      - INVOKE(analyze-and-spec)
    conflicts_with: []
    requires: []
    triggers: [analyze-and-spec, qa]
    source: "000-critical-rules.md §Bug Discovery Does Not Authorize Bug Fixing"

  - id: issue-review-002
    title: "Fix spec must target root cause, not symptom"
    conditions:
      all:
        - "fix_spec_created == true"
        - "spec_contains_root_cause_section == false OR fix_approach_targets_symptom == true"
    actions:
      - REJECT
      - HALT
    conflicts_with: []
    requires: []
    triggers: [analyze-and-spec]
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - id: issue-review-003
    title: "No code edits during analysis phase"
    conditions:
      all:
        - "current_task == 'analyze-and-spec' OR 'gather' OR 'triage' OR 'qa'"
        - "code_modification_attempted == true"
    actions:
      - HALT
      - REVERT
    conflicts_with: []
    requires: []
    triggers: [analyze-and-spec, gather, triage, qa]
    source: "000-critical-rules.md §Bug Discovery Does Not Authorize Bug Fixing"

  - id: issue-review-004
    title: "Comments read before triage decision"
    conditions:
      all:
        - "triage_decision_made == true"
        - "all_comments_read == false"
    actions:
      - HALT
      - INVOKE(gather)
    conflicts_with: []
    requires: []
    triggers: [triage]
    source: "issue-review/SKILL.md §Operating Protocol point 3"

  - id: issue-review-005
    title: "Symptom-only fix-specs are forbidden"
    conditions:
      all:
        - "fix_spec_created == true"
        - "fix_approach_type == 'symptom_only'"
    actions:
      - REJECT
      - HALT
    conflicts_with: []
    requires: [issue-review-002]
    triggers: [analyze-and-spec]
    source: "000-critical-rules.md §Symptom-Only Fix-Specs"

  - id: issue-review-006
    title: "Fix spec still requires explicit authorization before code changes"
    conditions:
      all:
        - "fix_spec_sub_issue_created == true"
        - "code_change_authorization_received == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [analyze-and-spec]
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - id: issue-review-007
    title: "Audit findings are internal — not posted to GitHub"
    conditions:
      all:
        - "audit_completed == true"
        - "posting_audit_findings_to_github == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [audit]
    source: "issue-review/SKILL.md §Audit Path"

tasks:
  - id: gather
    skill: issue-review
    preconditions: ["issue_number_provided"]
    postconditions: ["issue_body_read", "all_comments_read", "labels_read", "sub_issues_read", "auth_status_determined"]
    mandatory: true
    bypass_violation: "CRITICAL: Gathering incomplete context leads to incorrect triage decisions"
    source: "issue-review/SKILL.md §Tasks"

  - id: triage
    skill: issue-review
    preconditions: ["gather_completed"]
    postconditions: ["path_classified", "dispatch_target_determined"]
    mandatory: true
    bypass_violation: "CRITICAL: Triage drives all downstream dispatch; skipping causes wrong skill invocation"
    source: "issue-review/SKILL.md §Tasks"

  - id: analyze-and-spec
    skill: issue-review
    preconditions: ["issue_classified_as_bug == true"]
    postconditions: ["root_cause_identified", "fix_spec_sub_issue_created", "fix_spec_linked_to_bug_report"]
    mandatory: true
    bypass_violation: "CRITICAL: Bug reports without fix spec sub-issues cannot be legitimately closed"
    source: "issue-review/SKILL.md §Tasks"

  - id: audit
    skill: issue-review
    preconditions: ["issue_classified_as_spec == true"]
    postconditions: ["spec_auditor_invoked", "exec_summary_to_chat"]
    mandatory: false
    bypass_violation: "Specs should be audited but path is determined by triage, not mandatory for all issues"
    source: "issue-review/SKILL.md §Tasks"

  - id: qa
    skill: issue-review
    preconditions: ["issue_classified_as_non_bug_non_spec == true"]
    postconditions: ["clarifying_questions_asked", "exec_summary_to_issue"]
    mandatory: false
    bypass_violation: "Q/A path is for non-bug, non-spec issues; not all issues require it"
    source: "issue-review/SKILL.md §Tasks"

  - id: completion
    skill: issue-review
    preconditions: ["workflow_halted_or_completed"]
    postconditions: ["mandatory_steps_verified", "status_reported"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping completion task may leave terminal-state dispatch unverified"
    source: "issue-review/SKILL.md §Tasks"

decomposition:
  - type: skill-task
    skill: brainstorming
    task: explore
    mandatory: false
    bypass_violation: "Brainstorming used for analysis depth when root cause is ambiguous"
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - type: skill-task
    skill: spec-creation
    task: create
    mandatory: true
    bypass_violation: "Fix spec creation is mandatory for bug report closure"
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - type: skill-task
    skill: issue-operations
    task: creation
    mandatory: true
    bypass_violation: "Fix spec sub-issue must be created through issue-operations for validation"
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - type: skill-task
    skill: issue-operations
    task: link-sub-issue
    mandatory: true
    bypass_violation: "Fix spec sub-issue must be linked to bug report parent"
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - type: skill-task
    skill: spec-auditor
    task: audit
    mandatory: false
    bypass_violation: "Auditor invoked for spec-classified issues only"
    source: "issue-review/SKILL.md §Audit Path"

  - type: skill-task
    skill: approval-gate
    task: verify-fix-spec
    mandatory: true
    bypass_violation: "Fix spec verification required before bug report closure"
    source: "000-critical-rules.md §Bug Reports Without Fix Spec"

gates:
  - id: root-cause-not-symptom
    condition: "fix_spec_contains_root_cause_section == true AND fix_approach_targets_root_cause == true"
    on_fail: HALT
    critical_violation: true
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - id: no-code-edits-during-analysis
    condition: "code_modification_attempted == false"
    on_fail: HALT
    critical_violation: true
    source: "000-critical-rules.md §Bug Discovery Does Not Authorize Bug Fixing"

  - id: comments-read-before-triage
    condition: "all_comments_read == true"
    on_fail: HALT
    critical_violation: true
    source: "067-context-completeness.md"

  - id: bug-discovery-report-not-fix
    condition: "bug_discovered == true AND fix_code_change_attempted == false"
    on_fail: HALT
    critical_violation: true
    source: "000-critical-rules.md §Bug Discovery Does Not Authorize Bug Fixing"

  - id: audit-findings-not-on-github
    condition: "posting_audit_to_github == false"
    on_fail: HALT
    critical_violation: true
    source: "issue-review/SKILL.md §Audit Path"

evidence_artifacts:
  - name: root_cause_section
    type: tool_call
    verification: "Read fix spec body — confirm 'Root Cause' section exists and identifies underlying cause"
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - name: fix_spec_sub_issue_link
    type: api_call
    verification: "github_issue_read(method=get_sub_issues, issue_number=bug_report_N) → confirm fix spec linked"
    source: "issue-review/SKILL.md §Analyze-and-Spec Path"

  - name: comments_read_evidence
    type: api_call
    verification: "github_issue_read(method=get_comments, issue_number=N) → all comments retrieved"
    source: "067-context-completeness.md"

  - name: authorization_status
    type: api_call
    verification: "github_issue_read(method=get_comments) → filter for authorization comments from developer"
    source: "issue-review/SKILL.md §Live Verification"
```