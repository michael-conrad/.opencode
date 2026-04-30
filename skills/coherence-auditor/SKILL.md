---
name: coherence-auditor
description: Use when guidelines or skills are updated, to check consistency between rules and behavior. Triggers on: coherence, consistency, audit guidelines, skill extraction, drift detection, guideline update, skill update.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: coherence-auditor

## Overview

LLM Coherence Auditor ensuring guidelines, skills, and AI agent behavior work together effectively. Identifies procedural workflows for extraction and detects drift over time.

## Persona


## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `extract-scan` | Scan guidelines for skill candidates | ≈450 |
| `extract-analyze` | Calculate metrics and rank candidates | ≈380 |
| `maintenance-detect` | Detect drift from baseline | ≈370 |
| `maintenance-verify` | Verify guideline-skill references | ≈310 |
| `create-report` | Generate and attach audit report | ≈400 |

## Invocation

- `/skill coherence-auditor --mode extraction` — Scan for extraction candidates
- `/skill coherence-auditor --mode maintenance` — Detect drift from baseline
- `/skill coherence-auditor --task extract-scan` — Load specific task
- `/skill coherence-auditor --task extract-analyze` — Load specific task
- `/skill coherence-auditor --task maintenance-detect` — Load specific task
- `/skill coherence-auditor --task maintenance-verify` — Load specific task
- `/skill coherence-auditor --task create-report` — Load specific task
- `/skill coherence-auditor` — Overview only

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `extract-scan` | When scanning guidelines for skill candidates | Guideline file paths, scan configuration | Implementation context, agent memory | NO |
| `extract-analyze` | When calculating metrics and ranking candidates | Scan results, metric configuration | Implementation context, agent memory | NO |
| `maintenance-detect` | When detecting drift from baseline | Guideline file paths, baseline hashes | Implementation context, agent memory | NO |
| `maintenance-verify` | When verifying guideline-skill references | Guideline file paths, skill file paths | Implementation context, agent memory | NO |
| `create-report` | When generating and attaching audit report | Audit findings, github.owner, github.repo | Implementation context, agent memory | NO |

## Operating Protocol

1. **Mandatory invocation (no decision point):** The agent MUST invoke this skill when auditing guideline/skill coherence or when user requests extraction/maintenance audit.

2. **Mode selection:**
   - **Extraction mode**: Use when creating new skills from guideline content
   - **Maintenance mode**: Use for ongoing drift detection and verification

## Drift Patterns

| Pattern | Description |
|---------|------------|
| DUPLICATE-CONTENT | Same procedure in guideline AND skill |
| MISSING-SKILL-REF | Complex procedure without skill reference |
| STALE-SKILL | Skill references outdated guideline section |
| DRIFT-DETECTED | Guideline changed independently of skill |
| ORPHANED-PROCEDURE | Procedure removed from guideline but still in skill |
| SESSION-INIT-MISMATCH | Skill/guideline references a session-init variable name that doesn't appear in `.opencode/tools/session-init` output, or `.opencode/tools/session-init` outputs a prose label instead of the canonical variable name |

### Session Init Variable Alignment Check (maintenance mode)

When running in maintenance mode, the coherence auditor SHOULD verify:

1. All session-init variable names referenced in `.opencode/guidelines/` and `.opencode/skills/` (e.g., `github.owner`, `github.repo`, `github.platform`, `dev.name`, `dev.email`, `branch`, `worktree.path`, `worktree.fatal`, `github.html_url`, `gitbucket.html_url`, `gitbucket.ssh_url`, `gitbucket.has_credentials`) appear as `KEY:` prefixes in `.opencode/tools/session-init` stdout output
2. `.opencode/tools/session-init` does NOT output prose-only labels (e.g., `Owner:`, `Repository:`) for variables referenced by canonical names in guidelines
3. `env-loader.ts` `output.env` keys match the same canonical names

A mismatch is a MEDIUM-severity finding of class SESSION-INIT-MISMATCH.

## Priority Ranking

| Priority | Criteria |
|----------|----------|
| HIGH | Duplication ≥2 AND (complexity ≥medium OR words ≥150) |
| MEDIUM | Duplication ≥2 OR single-file complexity ≥medium |
| LOW | Single-file, low complexity, small word count |

## Word Count Measurement

- Use `wc -w` as the canonical measurement method
- Text: word count via `wc -w`
- Code blocks: word count via `wc -w` (includes code tokens as words)
- Tables: word count via `wc -w`

## Critical: Fresh-Start Context Preservation

**Temp files are NOT preserved between sessions.**

After creating audit log:
1. Write to `./tmp/coherence-audit-YYYYMMDD-<mode>.md`
2. Attach full content as GitHub Issue comment
3. Delete temp file

**Why:** Fresh-start AI agents cannot access `./tmp/` from previous sessions. GitHub Issue comments ARE preserved.

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `git-workflow` in Cross-References section | File exists at `.opencode/skills/git-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `guideline-auditor` in Cross-References section | File exists at `.opencode/skills/guideline-auditor/SKILL.md` | MISSING-TRACEABILITY if missing |
| `skill-creator` (implied by extraction workflow) | File exists at `.opencode/skills/skill-creator/SKILL.md` | MISSING-TRACEABILITY if missing |
| `sync-guidelines` (implied by sync workflow) | File exists at `.opencode/skills/sync-guidelines/SKILL.md` | MISSING-TRACEABILITY if missing |
| Task table entry `extract-scan` | File exists at `.opencode/skills/coherence-auditor/tasks/extract-scan.md` | MISSING-TRACEABILITY if missing |
| Task table entry `extract-analyze` | File exists at `.opencode/skills/coherence-auditor/tasks/extract-analyze.md` | MISSING-TRACEABILITY if missing |
| Task table entry `maintenance-detect` | File exists at `.opencode/skills/coherence-auditor/tasks/maintenance-detect.md` | MISSING-TRACEABILITY if missing |
| Task table entry `maintenance-verify` | File exists at `.opencode/skills/coherence-auditor/tasks/maintenance-verify.md` | MISSING-TRACEABILITY if missing |
| Task table entry `create-report` | File exists at `.opencode/skills/coherence-auditor/tasks/create-report.md` | MISSING-TRACEABILITY if missing |
| `git-workflow` PR behavior | Matches actual SKILL.md: PR creation and branch management | CONFLICTING if mismatched |
| `guideline-auditor` quality verification behavior | Matches actual SKILL.md: guideline quality auditing | CONFLICTING if mismatched |
| `skill-creator` creation workflow behavior | Matches actual SKILL.md: TDD skill creation, validation | CONFLICTING if mismatched |
| `sync-guidelines` cross-repo sync behavior | Matches actual SKILL.md: issue-based sync, classification | CONFLICTING if mismatched |

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

## Cross-References

- Related skills: `git-workflow` (PR with changes), `guideline-auditor` (verify guideline quality), `skill-creator` (TDD skill creation for extraction candidates), `sync-guidelines` (cross-repo synchronization)

## Symbolic Engine Integration

**Optional pre-step:** Before auditing, invoke the symbolic analysis engine for formal evidence:

```bash
./.opencode/tools/symbolic conflicts
```

The `sym-conflicts` analysis provides formal contradiction detection via sympy boolean satisfiability. Results are used as **evidence** (not verdict) during coherence audits — they identify overlapping conditions with conflicting actions, replacing ad-hoc prose comparison.

**Graceful degradation:** If the engine is unavailable or produces no results, fall back to prose-only analysis. Do NOT block the audit if the engine fails.

## Parent Spec

GitHub Issue #316: Guidelines Audit: Extract Complex Workflows to Skills

## Maintenance Schedule

| Trigger | Mode |
|---------|------|
| Weekly/monthly | maintenance |
| After guideline update | maintenance |
| After skill creation | maintenance |
| Before major release | maintenance |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-26T00:00:00Z"
rules:
  - id: coherence-auditor-001
    title: "Extraction scan requires valid guidelines directory"
    conditions:
      all:
        - "guidelines_available == true"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: [skill-creator]
    source: "coherence-auditor/SKILL.md"

  - id: coherence-auditor-002
    title: "Maintenance drift detection requires baseline"
    conditions:
      all:
        - "guidelines_changed == true"
        - "baseline_available == true"
    actions:
      - INVOKE(maintenance-detect)
    conflicts_with: []
    requires: []
    triggers: []
    source: "coherence-auditor/SKILL.md"

tasks:
  - id: extract-scan
    skill: coherence-auditor
    preconditions: ["guidelines_available == true"]
    postconditions: ["extraction_complete == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping extraction scan"
    source: "coherence-auditor/SKILL.md"

  - id: extract-analyze
    skill: coherence-auditor
    preconditions: ["extraction_complete == true"]
    postconditions: ["analysis_complete == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping extraction analysis"
    source: "coherence-auditor/SKILL.md"

  - id: maintenance-detect
    skill: coherence-auditor
    preconditions: ["guidelines_changed == true"]
    postconditions: ["drift_detected == true OR no_drift == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping drift detection"
    source: "coherence-auditor/SKILL.md"

  - id: maintenance-verify
    skill: coherence-auditor
    preconditions: ["drift_detected == true"]
    postconditions: ["drift_verified == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping drift verification"
    source: "coherence-auditor/SKILL.md"

  - id: create-report
    skill: coherence-auditor
    preconditions: ["any_state"]
    postconditions: ["report_produced == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping report generation"
    source: "coherence-auditor/SKILL.md"

decomposition:
  - type: skill-task
    skill: spec-auditor
    task: ground-truth
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Ground-Truth Verification"
    purpose: "Adversarial verification of drift findings against actual skill content"

  - type: skill-task
    skill: skill-creator
    task: validate-skill
    mandatory: true
    bypass_violation: "WARNING: Skipping skill card validation"
    purpose: "Validate candidate skills meet structural requirements"

gates:
  - id: guidelines-available
    condition: "guidelines_available == true"
    on_fail: "HALT"
    critical_violation: true

  - id: drift-genuine
    condition: "drift_verified == true"
    on_fail: "RECLASSIFY_AS_FALSE_POSITIVE"
    critical_violation: false

evidence_artifacts:
  - name: drift_findings_table
    type: structured_table
    verification: "Each drift finding has pattern, location, severity, recommendation"

  - name: cross_reference_verification
    type: tool_call_artifact
    verification: "Each cross-reference verified against actual skill content"

state_machines:
  - id: coherence-audit-session
    states: [idle, scanning, analyzing, detecting, verifying, reporting, complete]
    start_state: idle
    transitions:
      - from: idle
        to: scanning
        guard: "mode_selected == true"
        action: INVOKE(extract-scan OR maintenance-detect)
      - from: scanning
        to: analyzing
        guard: "scan_complete == true"
        action: INVOKE(extract-analyze)
      - from: analyzing
        to: detecting
        guard: "analysis_complete == true AND mode == 'maintenance'"
        action: INVOKE(maintenance-detect)
      - from: detecting
        to: verifying
        guard: "drift_detected == true"
        action: INVOKE(maintenance-verify)
      - from: verifying
        to: reporting
        guard: "verification_complete == true"
        action: INVOKE(create-report)
      - from: reporting
        to: complete
        guard: "report_produced == true"
        action: PROCEED
```