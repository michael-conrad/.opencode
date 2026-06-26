> **Full spec and artifacts: [`.issues/1430/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1430)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1430/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | Specs can enter the agent's working context without going through the spec-creation pipeline. The spec-audit is a pipeline step that can be skipped or bypassed. There is no hard gate that fires on spec encounter — only post-hoc checks that rely on the spec having gone through the creation pipeline. |
| **Root Cause / Motivation** | The agent already knows the provenance of any spec in its context — it either wrote it through the pipeline or it didn't. This knowledge must be acted on as a hard gate, not a soft check. |
| **Approach Chosen** | Add a provenance-based trigger with three artifacts: (1) a Tier 2 critical rule in `000-critical-rules.md` with a three-condition model, (2) a context-based trigger row in `adversarial-audit/SKILL.md`, (3) a stable verdict path at `.issues/{N}/spec-audit.yaml` for cross-session bridge. On non-pipeline spec, attempt autonomous remediation first; if remediation fails, enter open-ended discussion with the user (one topic at a time, no question tool, no pigeonholing). |
| **Alternatives Considered & Why Discarded** | (a) Post-hoc checks only — discarded because they rely on the spec having gone through the pipeline, creating a circular dependency. (b) GitHub API-based provenance tracking — discarded because it uses external state and adds latency. (c) Single session-level dedup flag — discarded because it breaks with multiple specs in context. (d) Hard rejection (86'ed) — discarded in favor of remediation-first approach. |
| **Key Design Decisions** | (1) Three-condition model with per-spec dedup. (2) Context-based trigger (not keyword-based). (3) Verdict file at `.issues/{N}/spec-audit.yaml` for cross-session bridge. (4) Tier 2 (overridable) — not Tier 1 — to allow developer override for legitimate edge cases. (5) Remediation-first: attempt autonomous fix before escalating to user discussion. |

## Problem

Specs can enter the agent's working context without going through the spec-creation pipeline. Currently, the spec-audit is a pipeline step that can be skipped or bypassed. There is no hard gate that fires on spec encounter — only post-hoc checks in `spec-creation/tasks/completion.md` that rely on the spec having gone through the creation pipeline.

The agent already knows the provenance of any spec in its context — it either wrote it through the pipeline or it didn't. This knowledge MUST be acted on as a hard gate.

## Scope

### In Scope

- A Tier 2 critical rule in `000-critical-rules.md` with a three-condition model
- A context-based trigger row in `adversarial-audit/SKILL.md` trigger dispatch table
- A stable verdict path: spec-audit task writes to `.issues/{N}/spec-audit.yaml`
- Behavioral enforcement tests for the provenance gate
- Per-spec dedup: `provenance_checked_<issue_number>_this_session`
- Autonomous remediation: attempt to bring non-pipeline spec up to spec-creation standards
- Open-ended discussion protocol: if remediation fails, one-topic-at-a-time discussion with user (no question tool, no pigeonholing)

### Out of Scope

- Changes to the spec-creation pipeline itself — the gate is in adversarial-audit and 000-critical-rules.md only
- Hard rejection (86'ed) — remediation-first approach replaces this
- No audit of non-pipeline specs — the spec-audit task runs after successful remediation
- No human override exception — all non-pipeline specs go through remediation or discussion
- No re-check on subsequent encounters — one check per spec per session
- No GitHub API calls for provenance tracking — verdict file is local only

## Solution

Add a **provenance-based trigger**: when a spec enters the agent's working context, the agent checks whether it was written through the spec-creation pipeline. If yes → proceed normally (spec-audit fires as part of the pipeline). If not → attempt autonomous remediation to bring the spec up to spec-creation standards. If remediation is not possible, alert the user and enter an open-ended discussion (one topic at a time, no question tool, no pigeonholing) to work interactively toward a remediated spec.

### Three Artifacts

#### 1. Critical Rule — `000-critical-rules.md`

Add a Tier 2 (Process-Integrity, halts) rule with a three-condition model:

- `spec_in_working_context == true` — a spec has entered the agent's context
- `spec_provenance != 'spec-creation-pipeline'` — the spec was NOT written through the spec-creation pipeline
- `about_to_act_on_spec == true` — agent is about to implement, revise, or use the spec as basis for action

On trigger: attempt autonomous remediation to bring the spec up to spec-creation standards. Remediation includes: adding missing sections (problem statement, success criteria, scope, risk), adding evidence type declarations, adding compliance blockquotes, and restructuring to match the spec template. If remediation succeeds, write the remediated spec to `.issues/{N}/spec.md` and proceed normally (spec-audit fires as pipeline step). If remediation is not possible (spec is fundamentally incompatible with the template), alert the user and enter open-ended discussion mode: one topic at a time, no question tool, no pigeonholing, work interactively with the user to produce a remediated spec. No CRITICAL VIOLATION header (Tier 2). Overridable by developer authorization.

#### 2. Trigger Dispatch Row — `adversarial-audit/SKILL.md`

Add a context-based row to the trigger dispatch table:

| User says / Context | Task | Dispatch | Context passed |
|---|---|---|---|---|
| `spec enters working context not from spec-creation pipeline` | `spec-provenance-remediate` | `sub-task` | {issue_number} |

#### 3. Stable Verdict Path — `spec-audit` task writes to `.issues/{N}/spec-audit.yaml`

The spec-audit task currently writes verdicts to `./tmp/{issue-N}/artifacts/pipeline-audit-spec-audit-{STATUS}-{timestamp}.yaml` — a temp path with timestamp, not suitable for stable checking.

Change the spec-audit task to also write a stable verdict file at `.issues/{N}/spec-audit.yaml` with the consensus PASS/FAIL result. This file:
- Lives in the issue's tracked directory (persists across sessions)
- Is not ephemeral (not in `./tmp/`)
- Is checkable by the orchestrator on first encounter
- Contains the consensus verdict and a reference to the full audit artifact path

Format:
```yaml
# spec-audit.yaml
consensus: PASS  # or FAIL
audit_type: spec-audit
provenance: spec-creation-pipeline
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-audit-spec-audit-PASS-{timestamp}.yaml"
audited_at: "2026-06-25T00:00:00Z"
```

### Check Location: First Encounter

The orchestrator checks provenance on **first encounter** of the spec — when it creates the spec, reads it from an issue, or downloads it. One check per spec per session.

- If provenance is `spec-creation-pipeline` → proceed normally (spec-audit fires as pipeline step, verdict stored at `.issues/{N}/spec-audit.yaml`)
- If provenance is anything else → attempt autonomous remediation. If remediation succeeds, proceed normally. If remediation fails, enter open-ended discussion with the user.

The dedup flag is per-spec (`provenance_checked_<issue_number>_this_session`), not per-session. This prevents the "multiple specs in context" edge case where checking one spec sets the flag for all specs.

### Cross-Session Bridge

A pipeline-written spec from a previous session is accepted if `.issues/{N}/spec-audit.yaml` exists with `provenance: spec-creation-pipeline`. The verdict file serves as the cross-session provenance record. Without the verdict file, a previous-session spec triggers the remediation path.

### Remediation Protocol

When a non-pipeline spec is detected, the agent follows this protocol:

1. **Assess remediability** — Can the spec be brought up to spec-creation standards? Check: does it have a problem statement? Success criteria? Scope definition? Risk analysis? Can missing sections be inferred from existing content?
2. **Autonomous remediation** — If remediable, restructure the spec to match the spec template. Add missing sections (problem statement, success criteria with evidence types, scope, risk traceability, decision ledger). Add compliance blockquotes. Add evidence type declarations to SCs. Write the remediated spec to `.issues/{N}/spec.md`.
3. **Proceed** — After successful remediation, the spec-audit fires as normal. The verdict file records `provenance: remediated`.
4. **Escalate to discussion** — If remediation is not possible (spec is fundamentally incompatible — e.g., it's a bug report, a question, or has no actionable content), alert the user. Enter open-ended discussion mode:
   - One topic at a time
   - No question tool
   - No pigeonholing (no constrained-choice prompts)
   - Work interactively with the user to produce a remediated spec
   - The discussion follows the brainstorming skill's explore task protocol

### Spec Origins

This gate covers ALL spec origins:
- AI-written via spec-creation pipeline → accepted, audited
- AI-written outside the pipeline (inline, ad-hoc) → remediate or discuss
- Human-written specs → remediate or discuss
- Specs downloaded from issues → remediate or discuss
- Specs from previous sessions → remediate or discuss (unless verdict file exists with pipeline_written)

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Three-condition model with per-spec dedup | Prevents multi-spec collision; single session-level flag breaks with multiple specs | MUST | SC-1, SC-11 |
| DEC-2 | Context-based trigger (not keyword-based) | Fires on spec encounter, not on user keyword — consistent with existing `completion / workflow end` pattern | MUST | SC-4, SC-5 |
| DEC-3 | Verdict file at `.issues/{N}/spec-audit.yaml` | Stable cross-session path; not ephemeral like `./tmp/` | MUST | SC-6, SC-9 |
| DEC-4 | Tier 2 (overridable) — not Tier 1 | Allows developer override for legitimate edge cases (e.g., session boundary) | MUST | SC-2 |
| DEC-5 | No GitHub API calls for provenance tracking | Verdict file is local only; avoids API latency and permission issues | MUST | SC-10 |
| DEC-6 | `about_to_act_on_spec` as third condition | Prevents false positives when agent reads a spec for reference without acting on it | SHOULD | SC-1 |
| DEC-7 | Remediation-first instead of hard rejection | Non-pipeline specs may be salvageable; autonomous remediation reduces friction; discussion mode handles edge cases | MUST | SC-7, SC-13, SC-14 |
| DEC-8 | Open-ended discussion (no question tool, no pigeonholing) | Prevents constrained-choice prompts; user drives the remediation direction | MUST | SC-14 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| R-1 | False positive — pipeline spec incorrectly sent to remediation | MEDIUM | MEDIUM | Verdict file cross-session bridge; autonomous remediation is harmless on valid spec | SC-9 |
| R-2 | False negative — non-pipeline spec not detected | MEDIUM | CRITICAL | Critical rule as primary enforcement; spec-audit self-check | SC-7 |
| R-3 | Provenance check bypassed by agent | LOW | CRITICAL | Behavioral enforcement test; verdict file audit trail | SC-7, SC-8 |
| R-4 | Session boundary — previous-session spec triggers unnecessary remediation | HIGH | LOW | Verdict file cross-session bridge; remediation is harmless on valid spec | SC-9 |
| R-5 | Three-condition model edge cases | MEDIUM | MEDIUM | Per-spec dedup flag; [SPEC] label discriminator | SC-11 |
| R-6 | Verdict file write failure | LOW | MEDIUM | Create directory if missing; fallback path | SC-6 |
| R-7 | Context trigger fires on non-spec content | MEDIUM | MEDIUM | [SPEC] label or frontmatter discriminator | SC-4 |
| R-8 | Remediation produces incorrect spec | MEDIUM | HIGH | Discussion mode as safety valve; user can reject remediation | SC-13, SC-14 |
| R-9 | Discussion mode loops indefinitely | LOW | MEDIUM | Tier 2 override available; developer can authorize spec as-is | SC-2 |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| multi-phase | 4 | One sub-issue per phase | stacked PRs per phase |

### Phases

| Phase | Target | SCs |
|-------|--------|-----|
| Phase 1 — Verdict Path Change | `.opencode/skills/adversarial-audit/tasks/spec-audit.md` | SC-6, SC-10 |
| Phase 2 — Critical Rule | `.opencode/guidelines/000-critical-rules.md` | SC-1, SC-2, SC-3, SC-11 |
| Phase 3 — Trigger Dispatch | `.opencode/skills/adversarial-audit/SKILL.md` | SC-4, SC-5 |
| Phase 4 — Remediation Protocol | `.opencode/guidelines/000-critical-rules.md` + brainstorming skill | SC-13, SC-14 |
| Phase 5 — Behavioral Tests | `.opencode/tests/behaviors/` | SC-7, SC-8, SC-9, SC-12 |

## Explicit Non-Goals

- **Changes to the spec-creation pipeline itself** — the gate is in adversarial-audit and 000-critical-rules.md only
- **Hard rejection (86'ed)** — remediation-first approach replaces this
- **Skipping remediation** — all non-pipeline specs go through remediation or discussion; no silent acceptance
- **Human override exception** — all non-pipeline specs go through remediation or discussion
- **Re-check on subsequent encounters** — one check per spec per session
- **GitHub API calls for provenance tracking** — verdict file is local only
- **Question tool or pigeonholing in discussion mode** — discussion is open-ended, one topic at a time

## Regression Invariants

1. Existing critical rules in `000-critical-rules.md` MUST continue to function — the new rule is additive, not modifying existing rules
2. Existing trigger dispatch table rows in `adversarial-audit/SKILL.md` MUST remain unchanged
3. Existing spec-audit verdict path to `./tmp/` MUST continue to work — the stable path is an additional write, not a replacement
4. All existing behavioral enforcement tests MUST continue to pass

## Cross-Cutting SCs

**Cross-Cutting SCs:** SC-7, SC-8, SC-9
— Verified once in Phase 4, applies to all subsequent phases.

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |
| sc-summary.yaml | MUST | Regenerate to match revised SCs |
| verification-consistency-contract.yaml | MUST | Regenerate to match revised SCs |
| revision-re-entry-contract.yaml | MUST | Regenerate to match revised scope |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep` for `tier: 2` in `000-critical-rules.md` | Verify Tier 2 rule pattern exists |
| Direct source search | `grep` for `yaml+symbolic` in guidelines | Verify yaml+symbolic format is established |
| Direct source search | `grep` for Trigger Dispatch Table in `adversarial-audit/SKILL.md` | Verify dispatch table structure |
| Direct source search | `read` of `spec-audit.md` Step 6 | Verify current verdict path |
| Direct source search | `read` of `spec-creation/tasks/write.md` | Verify write task procedure |
| Direct source search | `read` of `issue-operations/tasks/creation.md` | Verify creation task procedure |
| Session init | `github.owner`, `github.repo` | Resolve URL for issue references |

## Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**🚫 ALL-OR-NOTHING GATE:** ALL success criteria MUST pass for implementation to be considered complete. Any SKIPPED is treated as FAIL. Any FAILED triggers autonomous remediation. See `spec-creation/tasks/write.md` Step 3 for the complete gate rules.

**Cost-frame mandate:** Each SC below carries a cost-frame reformation statement. The implementing agent derives the exact prose autonomously based on the SC's verification method. The death spiral / break dynamics are formalized in `065-verification-honesty.md` §Cost Model — behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Critical rule added to `000-critical-rules.md` with three-condition model (`spec_in_working_context`, `spec_provenance != 'spec-creation-pipeline'`, `about_to_act_on_spec`) and HALT + REJECT_SPEC action | `string` | grep for `critical-rules-spec-provenance-gate` in `000-critical-rules.md`; verify conditions.all has 3 entries and actions includes HALT | If rule missing: add rule with correct conditions. If conditions wrong: fix conditions. | Phase 2 — Critical Rule | `.opencode/guidelines/000-critical-rules.md` | REQ-4 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-2 | Critical rule is Tier 2 (no CRITICAL VIOLATION header, overridable by developer authorization) | `string` | grep for `tier: 2` in the rule's yaml+symbolic block; verify no `CRITICAL VIOLATION` in title | If tier wrong: change to `tier: 2`. If CRITICAL VIOLATION header present: remove. | Phase 2 — Critical Rule | `.opencode/guidelines/000-critical-rules.md` | REQ-10, CON-2 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-3 | Critical rule uses yaml+symbolic format with conditions/actions/triggers compatible with session-enforcement.ts | `string` | grep for yaml+symbolic block with `conditions.all` and `actions` in the rule | If format wrong: rewrite in yaml+symbolic format matching existing patterns. | Phase 2 — Critical Rule | `.opencode/guidelines/000-critical-rules.md` | REQ-11 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-4 | Context-based trigger row added to `adversarial-audit/SKILL.md` trigger dispatch table | `string` | grep for `spec enters working context not from spec-creation pipeline` in `adversarial-audit/SKILL.md` | If row missing: add row. If trigger type wrong: change to context-based. | Phase 3 — Trigger Dispatch | `.opencode/skills/adversarial-audit/SKILL.md` | REQ-5, REQ-12, CON-5 | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-5 | Trigger row dispatches to `spec-provenance-remediate` sub-task with {issue_number} context | `string` | grep for `spec-provenance-remediate` in `adversarial-audit/SKILL.md` | If task name wrong: correct to `spec-provenance-remediate`. If context missing: add `{issue_number}`. | Phase 3 — Trigger Dispatch | `.opencode/skills/adversarial-audit/SKILL.md` | REQ-5 | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-6 | Spec-audit task writes stable verdict to `.issues/{N}/spec-audit.yaml` with consensus, audit_type, provenance, artifact_path, and audited_at fields | `behavioral` | Run spec-audit on a test spec, verify `.issues/{N}/spec-audit.yaml` exists with valid YAML content containing all required fields | If file not written: fix spec-audit.md Step 6 to write stable path. If fields missing: add missing fields. | Phase 1 — Verdict Path | `.opencode/skills/adversarial-audit/tasks/spec-audit.md` | REQ-6, CON-3 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-7 | Orchestrator attempts autonomous remediation on a non-pipeline spec on first encounter | `behavioral` | `opencode-cli run` with a non-pipeline spec in context, verify stderr shows remediation attempt (not rejection, not silent acceptance) | If no remediation: fix critical rule actions. If silent acceptance: add provenance check. | Phase 5 — Behavioral Tests | `.opencode/tests/behaviors/` | REQ-2, REQ-10 | Phase 5 | post-implementation | sequential | — | — | `test-spec-provenance-remediate.sh` | Phase 5 |
| SC-8 | Orchestrator accepts a spec from spec-creation pipeline and proceeds to audit | `behavioral` | `opencode-cli run` with a pipeline-written spec, verify stderr shows audit dispatch | If not accepted: fix critical rule pass-through condition. If no audit: verify pipeline continues. | Phase 5 — Behavioral Tests | `.opencode/tests/behaviors/` | REQ-3 | Phase 5 | post-implementation | sequential | — | — | `test-spec-provenance-accept.sh` | Phase 5 |
| SC-9 | Cross-session bridge: pipeline-written spec from previous session accepted when `.issues/{N}/spec-audit.yaml` exists with `provenance: spec-creation-pipeline` | `behavioral` | `opencode-cli run` with a spec and existing verdict file, verify stderr shows acceptance | If not accepted: add fourth condition for verdict file existence. If verdict file format wrong: fix format. | Phase 5 — Behavioral Tests | `.opencode/tests/behaviors/` | REQ-13 | Phase 5 | post-implementation | sequential | — | — | `test-spec-provenance-cross-session.sh` | Phase 5 |
| SC-10 | No issue comments, labels, or GitHub API calls used for provenance tracking or rejection | `string` | grep for absence of `github_issue_write`/`github_add_issue_comment` in spec-audit task for verdict storage | If API calls found: replace with local file write. | Phase 1 — Verdict Path | `.opencode/skills/adversarial-audit/tasks/spec-audit.md` | REQ-13 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-11 | Per-spec dedup: `provenance_checked_<issue_number>_this_session` is per-spec, not per-session | `string` | grep for per-spec dedup pattern in the critical rule conditions | If dedup is per-session: change to per-spec pattern. | Phase 2 — Critical Rule | `.opencode/guidelines/000-critical-rules.md` | REQ-7, CON-4 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-12 | Behavioral test mandate: Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rule; confirm RED state (test fails before change) | `string` | grep for behavioral test mandate in spec body | If mandate missing: add behavioral test mandate section. | Phase 5 — Behavioral Tests | `.opencode/tests/behaviors/` | REQ-8 | Phase 5 | pre-implementation | sequential | — | — | — | Phase 5 |
| SC-13 | Autonomous remediation: agent restructures non-pipeline spec to match spec template (adds problem statement, success criteria, scope, risk, compliance blockquotes, evidence type declarations) | `behavioral` | `opencode-cli run` with a non-pipeline spec that has partial content, verify stderr shows remediation producing a restructured spec with all required sections | If no restructuring: fix remediation protocol in critical rule. If sections missing: add section generation logic. | Phase 4 — Remediation Protocol | `.opencode/guidelines/000-critical-rules.md` | REQ-2 | Phase 4 | post-implementation | sequential | — | — | `test-spec-provenance-remediate.sh` | Phase 4 |
| SC-14 | Discussion mode: when remediation is not possible, agent enters open-ended discussion (one topic at a time, no question tool, no pigeonholing) and works interactively with user | `behavioral` | `opencode-cli run` with a fundamentally non-remediable spec (e.g., bug report), verify stderr shows discussion mode entry with no question tool usage | If question tool used: enforce no-question-tool rule. If pigeonholing: enforce open-ended discussion. If multiple topics: enforce one-topic-at-a-time. | Phase 4 — Remediation Protocol | `.opencode/guidelines/000-critical-rules.md` | REQ-2 | Phase 4 | post-implementation | sequential | — | — | `test-spec-provenance-discuss.sh` | Phase 4 |

After this spec is approved, invoke `writing-plans` to create `.issues/1432/plan.md` before implementation begins.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1430/`.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.issues/1430/` entry.
The implementation plan will be created in `.issues/1430/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
