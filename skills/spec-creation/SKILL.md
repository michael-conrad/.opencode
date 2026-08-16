---
name: spec-creation
description: "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements. The orchestrator sequences a 3-category clean-room pipeline: analyze (pre-spec inspection, requirements extraction, decomposition, analytical artifacts) → create (assemble spec, write remote issue, write local spec) → validate (holistic self-check, structural validation) → (revise → validate)* → done. Each step is a clean-room sub-agent dispatch — the orchestrator does not perform inline work."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: spec-creation

## Overview

Create and validate specification documents. The orchestrator sequences a 3-category clean-room pipeline through 4 task cards. No sub-skills. Each sub-agent receives only its scoped context — no preloaded reasoning, no orchestrator conclusions.

## Pipeline Sequence

The orchestrator dispatches each step as a clean-room `task()` call. The orchestrator does NOT perform inline work.

```
analyze → create → validate → (revise → validate)* → done
```

## Workflows

The orchestrator follows the steps below step-by-step, in order. Each step is a clean-room `task()` dispatch (or an inline orchestrator action where marked). The `Execution mode` sub-bullet on every step makes the inline-vs-dispatch decision explicit: `sub-agent dispatch` means the orchestrator dispatches a clean-room sub-agent via `task()`; `inline` means the orchestrator performs the action in its own context. The orchestrator waits for each result contract before dispatching the next step.

### Create a new spec

- [ ] 1. **analyze** — Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/analyze.md](.opencode/skills/spec-creation/tasks/analyze.md)")`
  - **Context passed:** `{issue_number, project_root}`
  - **Returns:** `{status, analysis_artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **create** — Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/create.md](.opencode/skills/spec-creation/tasks/create.md)")`
  - **Context passed:** `{issue_number, analysis_artifact_path, project_root}`
  - **Returns:** `{status, spec_path, issue_url, artifact_url, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2.1. **reconcile-push** — Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/reconcile-push.md](.opencode/skills/spec-creation/tasks/reconcile-push.md)")`
  - **Context passed:** `{issue_number, artifact_url, project_root}`
  - **Returns:** `{status, issue_url, finding_summary}`
  - **Execution mode:** sub-agent dispatch
  - Runs after `create` returns the `artifact_url` from `push-artifacts`; reconciles the Spec Reference Blockquote / artifact URL in the remote issue body.

- [ ] 3. **validate** — Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/validate.md](.opencode/skills/spec-creation/tasks/validate.md)")`
  - **Context passed:** `{issue_number, spec_path}`
  - **Returns:** `{status, verdicts: [{check_name, result}], finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 4. **If validate returns FAIL:** Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/revise.md](.opencode/skills/spec-creation/tasks/revise.md)")`
  - **Context passed:** `{issue_number, spec_path, validation_findings}`
  - **Returns:** `{status, spec_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch
  - Then return to step 3 (validate)

#### Tiered Escalation (validate→revise loop)

The validate→revise loop uses a 3-tier escalation when validation continues to fail:

| Tier | Condition | Action |
|------|-----------|--------|
| **Tier 1** | First 3 validate→revise iterations | Continue the loop. Each iteration addresses the specific validation findings from the previous run. No escalation. |
| **Tier 2** | 4th consecutive validate FAIL | Dispatch a structural diagnostic: task a clean-room sub-agent to analyze the spec's structural defects independently. The diagnostic produces a structured defect report identifying root causes of repeated validation failures. |
| **Tier 3** | 5th+ consecutive validate FAIL (or diagnostic reveals fundamental spec defect) | Escalate to user. Report: (a) the validation findings from all iterations, (b) the structural diagnostic findings, (c) a recommendation for spec restructuring or user guidance. HALT — do not continue the loop without user input. |

The tier counter resets when validate returns PASS (successful exit from the loop).

- [ ] 5. **If validate returns PASS:** Spec is ready for approval. Report spec_path and issue_url.
  - **Execution mode:** inline

### Revise an existing spec

- [ ] 1. **revise** — Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/revise.md](.opencode/skills/spec-creation/tasks/revise.md)")`
  - **Context passed:** `{issue_number, spec_path, revision_reason}`
  - **Returns:** `{status, spec_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **validate** — Dispatch `task(..., prompt: "Follow the instructions in [spec-creation/tasks/validate.md](.opencode/skills/spec-creation/tasks/validate.md)")`
  - **Context passed:** `{issue_number, spec_path}`
  - **Returns:** `{status, verdicts, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 3. If validate returns FAIL, return to step 1 (with tiered escalation per the Tiered Escalation section above). If PASS, spec is ready.
  - **Execution mode:** inline

## Cross-References

Skills: `brainstorming` (upstream handoff), `writing-plans` (downstream consumer), `audit` (spec-audit), `approval-gate`. Guidelines: `000-critical-rules.md` (clean-room discipline), `080-code-standards.md` (evidence type taxonomy).

### [critical-rules-042] Skipping Spec/Plan Coherence Gate (Pre-RED)
Dispatching RED sub-agents without a coherence gate means your implementation plan has never been checked against the codebase. Professional engineers verify coherence before writing a single line of code. Amateurs find out at review time.


### [critical-rules-042] Skipping Execution-Time Coherence Detection (RED + GREEN)
A RED sub-agent that detects a spec/codebase contradiction but proceeds anyway is producing code that cannot work. Professional sub-agents return BLOCKED. Amateurs return broken code that CI will discover later.


### [critical-rules-sc-lobotomy] CRITICAL VIOLATION — SC Lobotomy Prohibition — removing, weakening, deferring, skipping, or blocking success criteria

Removing or weakening a success criterion from a spec to evade implementation is a CRITICAL VIOLATION. An agent MUST NOT:
- Remove an SC from a spec's SC table to make it "closable"
- Weaken an SC's evidence type (e.g., `behavioral` to `string`) to make it easier to verify
- Replace an SC with a weaker version (changing what success means)
- Mark an SC as "blocked" or "deferred" in the spec body to evade implementation
- Skip an SC entirely — claiming it is "not applicable", "out of scope for this change", "too complex for this change", "will be handled separately", or any equivalent rationalization
- Add a `depends-on` or cross-reference solely to push SC verification out of the current spec
- Claim an SC is "not achievable" and modify the spec rather than implementing it

Required behavior: If an SC is structurally valid and the agent cannot implement it, report BLOCKED with root cause and HALT. The agent must NOT modify the spec, remove the SC, add a new change to "fix" the SC by changing what it tests, or create a dependent spec to offload the SC. The remediation-first protocol applies: attempt to implement before concluding impossibility.

## Superseding Issues and Overlap Detection

Before implementing OR revising any spec, check for superseding issues and staleness:

**Superseding Issues**: Later GitHub Issues that may supersede, invalidate, or contradict the active spec. Implementation of a superseded spec is wasted work.

- Query all open `[SPEC]` issues and check for conflicting/overlapping objectives
- Look for `[SPEC-FIX]` or `[SPEC-ENHANCEMENT]` issues that may render the active spec obsolete
- If a later issue exists, SILENTLY HALT and report the conflict — do NOT proceed with superseded spec

**Staleness from Implemented Specs**: Other specs that were implemented while this spec was pending, making the active spec stale or partially obsolete.

- Check for merged PRs that implemented related functionality
- Check if referenced code locations have been modified since spec creation
- Check if referenced dependencies/libraries have changed
- Check if the problem statement still applies (may have been fixed by another implementation)
- If staleness detected, REVISE the spec before implementation:
  1. Update problem statement if context changed
  2. Update affected files/lines if code locations changed
  3. Update success criteria if requirements shifted
  4. Update dependencies if integration points changed
  5. Report the revision and HALT — wait for approval before proceeding
- NEVER implement a stale spec as-is — always revise first

**Overlap Detection Checklist (MANDATORY when checking for superseding issues):**

Title/objective comparison alone is insufficient. Before classifying overlap, perform the following checklist:

- [ ] **File-level search:** Extract all file paths mentioned in the active spec's affected-files or file_references sections. For each open `[SPEC]`/`[SPEC-FIX]` issue, and for each local `.issues/{N}/plan.md` file, compare file paths. Shared files → potential overlap.
- [ ] **Symbol-level search:** Extract all function, class, and module names referenced in the active spec body. For each overlapping open issue, compare symbol names. Shared symbols → potential overlap.
- [ ] **Concern boundary comparison:** Extract the concern area each phase addresses (what problem each phase solves). For each overlapping open issue, compare concern boundaries. Shared concerns → potential overlap.
- [ ] **Four-tier classification:** Based on file, symbol, and concern overlap, classify using:
  - **FULL-SUPERSESSION:** Another spec's scope entirely covers this spec's scope → HALT, report full scope overlap, recommend using existing spec
  - **PARTIAL-OVERLAP:** Specs share files/symbols but have different core concerns → Surface to developer, suggest scoping to avoid overlap
  - **CONFLICT-RISK:** Same files modified with conflicting intent → HALT, suggest coordination
  - **INDEPENDENT:** No meaningful overlap → Proceed normally
- [ ] **Evidence artifacts:** For each overlap classification, record: `{Check: overlap search, Tool: github_list_issues + srclight_get_dependents, Result: shared files/symbols/concerns, Classification: FULL-SUPERSESSION|PARTIAL-OVERLAP|CONFLICT-RISK|INDEPENDENT, Action: HALT|surface|surface|proceed}`

## Plan Audit Code Deep Dive

When auditing or updating any plan, strictly follow the mandatory code deep dive and verification requirements defined in the [spec-creation](skills/spec-creation/SKILL.md) and [audit](skills/audit/SKILL.md) skills. Ground every plan audit finding in the actual filesystem and source code, not in remembered or stored state.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*


