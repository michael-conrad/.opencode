---
name: conflict-resolution
description: Use when resolving git conflicts during rebase, merge, or cherry-pick operations. Triggers on: conflict, merge conflict, rebase conflict, resolve conflict, cherry-pick conflict, conflict resolution, intent conflict, conflict classification.
---

# Skill: conflict-resolution

## Overview

Procedural workflow for classifying and resolving git conflicts with proper intent preservation. Prevents silent erosion of committed work during rebase, merge, cherry-pick, or any git operation that produces conflicts.

## Persona

You are a Conflict Resolution Specialist. Your focus is ensuring no committed work or spec intent is silently lost during git conflict resolution.

## Invocation

- **Automatic**: Invoked by `git-workflow` tasks when conflicts are detected during rebase/merge
- **Manual**: `/skill conflict-resolution` — Overview only
- **Manual**: `/skill conflict-resolution --task classify-and-resolve` — Full classification and resolution procedure
- **Manual**: `/skill conflict-resolution --task completion` — Invoke when workflow halts at any point

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `classify-and-resolve` | Detect, classify, and resolve conflicts by tier | ≈550 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `classify-and-resolve` | When a git conflict is detected and needs resolution | Branch name, conflict file paths, worktree.path | Implementation context, agent memory, conflict resolution decisions from prior sessions | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Conflict Classification Tiers

Before resolving ANY conflict, classify it:

| Tier | Name | Criteria | Agent Action |
|------|------|----------|-------------|
| 1 | **Trivial** | Whitespace, formatting, reordering of unchanged lines | Auto-resolve, silent |
| 2 | **Textual but safe** | Same intent on both sides, just different text | Auto-resolve, note in chat |
| 3 | **Intent conflict** | Different goals, or resolution could alter spec compliance | HALT, flag for developer review |

**Classification rule:** When in doubt, classify UP to the next tier. If unsure whether something is Tier 2 or Tier 3, treat it as Tier 3.

## Notification Format

### Tier 2 (Chat only)

```
**Conflict Resolution (Tier 2 - Textual):**
- File: <path>
- Reason: <why it's textual but safe>
- Resolution: <which side was accepted>
```

### Tier 3 Minor (Chat only)

```
**⚠️ Intent Conflict Detected (Tier 3 - Minor):**
- File: <path>
- Feature branch intent: <what>
- Parent branch intent: <what>
- Resolution: <agent recommendation, awaiting developer confirmation>
```

### Tier 3 Complex (Chat + GitHub Issue)

Chat notification plus persistent GitHub Issue with `conflict-resolution` label for tracking.

## Anti-Patterns

**🚫 NEVER:**
- Resolve ALL conflicts with `git checkout --theirs` or `git checkout --ours`
- Use `git rebase --strategy-option=theirs/ours` as blanket resolution
- Skip reading the conflict content before resolving
- Assume formatting conflicts are always trivial (could hide intent changes)
- Continue rebase after resolving intent conflicts without verifying spec compliance
- Create commits that silently drop committed work

**✅ ALWAYS:**
- Classify every conflict into a tier before resolving
- When in doubt, classify UP (Tier 2 vs Tier 3 → Tier 3)
- Verify spec compliance after resolving all conflicts
- Notify developer for Tier 3 conflicts
- Create GitHub Issue for complex Tier 3 conflicts
- Preserve feature branch intent unless developer says otherwise

## Integration Points

| Skill | When |
|-------|------|
| `git-workflow` `--task review-prep` | Automatically invokes this skill when rebase produces conflicts |
| `git-workflow` `--task implementation` | May invoke if mid-implementation merge produces conflicts |

## Cross-References

- Related skills: `git-workflow` (branch management, rebase operations)
- Related guidelines: `000-critical-rules.md` → "Critical Violation: Blind Conflict Resolution"

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps are never skipped. It is idempotent and safe to invoke multiple times.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: conflict-res-001
    title: "Tier 3 conflicts MUST halt for developer review"
    conditions:
      all:
        - "conflict_classified == 'tier_3_intent'"
    actions:
      - HALT
      - NOTIFY(developer)
      - CREATE(github_issue_with_conflict-resolution_label_if_complex)
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Conflict Classification Tiers"

  - id: conflict-res-002
    title: "Classify before resolving — never use blanket ours/theirs"
    conditions:
      all:
        - "conflict_detected == true"
        - "conflict_classified == false"
    actions:
      - HALT
      - INVOKE(classify-and-resolve)
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: conflict-res-003
    title: "No blanket ours/theirs resolution"
    conditions:
      any:
        - "resolution_uses == 'git checkout --theirs' ( blanket )"
        - "resolution_uses == 'git checkout --ours' ( blanket )"
        - "resolution_uses == 'git rebase --strategy-option=theirs/ours' ( blanket )"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: conflict-res-004
    title: "When in doubt classify UP"
    conditions:
      all:
        - "conflict_tier_ambiguous == true"
    actions:
      - CLASSIFY(next_higher_tier)
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Conflict Classification Tiers"

  - id: conflict-res-005
    title: "Read conflict content before resolving"
    conditions:
      all:
        - "conflict_detected == true"
        - "conflict_content_read == false"
    actions:
      - HALT
      - READ(conflict_file_content)
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: conflict-res-006
    title: "No commits that silently drop committed work"
    conditions:
      all:
        - "resolution_would_drop_committed_work == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: conflict-res-007
    title: "Verify spec compliance after all conflicts resolved"
    conditions:
      all:
        - "all_conflicts_resolved == true"
        - "spec_compliance_verified == false"
    actions:
      - VERIFY(spec_compliance)
    conflicts_with: []
    requires: []
    triggers: [classify-and-resolve]
    source: "conflict-resolution/SKILL.md §Anti-Patterns ALWAYS DO"

tasks:
  - id: classify-and-resolve
    skill: conflict-resolution
    preconditions: ["conflict_detected == true"]
    postconditions: ["conflict_classified", "trivial_or_textual_resolved OR tier3_halted_for_developer", "spec_compliance_verified"]
    mandatory: true
    bypass_violation: "CRITICAL: Resolving conflicts without classification risks silently eroding committed work"
    source: "conflict-resolution/SKILL.md §Tasks"

  - id: completion
    skill: conflict-resolution
    preconditions: ["workflow_halted_or_completed"]
    postconditions: ["mandatory_steps_verified", "status_reported"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping completion task may leave conflict resolution state unverified"
    source: "conflict-resolution/SKILL.md §Tasks"

decomposition:
  - type: skill-task
    skill: git-workflow
    task: review-prep
    mandatory: false
    bypass_violation: "git-workflow review-prep auto-invokes this skill when rebase produces conflicts"
    source: "conflict-resolution/SKILL.md §Integration Points"

  - type: skill-task
    skill: git-workflow
    task: implementation
    mandatory: false
    bypass_violation: "Mid-implementation merge may invoke if conflicts produced"
    source: "conflict-resolution/SKILL.md §Integration Points"

gates:
  - id: tier-3-halt-for-developer
    condition: "conflict_tier != 'tier_3_intent'"
    on_fail: HALT
    critical_violation: true
    source: "conflict-resolution/SKILL.md §Conflict Classification Tiers"

  - id: classification-before-resolution
    condition: "conflict_classified == true"
    on_fail: HALT
    critical_violation: true
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: no-blanket-ours-theirs
    condition: "resolution_is_per_conflict == true ( NOT blanket )"
    on_fail: HALT
    critical_violation: true
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: conflict-content-read
    condition: "conflict_content_read == true"
    on_fail: HALT
    critical_violation: false
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

  - id: no-silent-drop
    condition: "resolution_would_drop_committed_work == false"
    on_fail: HALT
    critical_violation: true
    source: "conflict-resolution/SKILL.md §Anti-Patterns"

evidence_artifacts:
  - name: conflict_classification
    type: tool_call
    verification: "bash: git diff output showing conflict markers, then classification decision recorded in chat"
    source: "conflict-resolution/SKILL.md §Conflict Classification Tiers"

  - name: tier2_resolution_note
    type: tool_call
    verification: "Chat notification with file path, reason, and resolution side for Tier 2 conflicts"
    source: "conflict-resolution/SKILL.md §Notification Format Tier 2"

  - name: tier3_developer_notification
    type: tool_call
    verification: "Chat notification with feature branch intent, parent branch intent, and agent recommendation"
    source: "conflict-resolution/SKILL.md §Notification Format Tier 3"

  - name: tier3_github_issue
    type: api_call
    verification: "github_issue_read(method=get) → issue with conflict-resolution label exists for complex Tier 3"
    source: "conflict-resolution/SKILL.md §Notification Format Tier 3 Complex"

  - name: spec_compliance_check
    type: tool_call
    verification: "Read spec body, compare against resolved files to confirm spec intent preserved"
    source: "conflict-resolution/SKILL.md §Anti-Patterns ALWAYS DO"
```