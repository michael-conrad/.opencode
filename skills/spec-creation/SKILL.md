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

### Create a new spec

1. **analyze** — Dispatch `task(..., prompt: "execute analyze from spec-creation. Read \`skills/spec-creation/tasks/analyze.md\` first")`
   - **Context passed:** `{issue_number, project_root}`
   - **Returns:** `{status, analysis_artifact_path, finding_summary}`

2. **create** — Dispatch `task(..., prompt: "execute create from spec-creation. Read \`skills/spec-creation/tasks/create.md\` first")`
   - **Context passed:** `{issue_number, analysis_artifact_path}`
   - **Returns:** `{status, spec_path, issue_url, finding_summary}`

3. **validate** — Dispatch `task(..., prompt: "execute validate from spec-creation. Read \`skills/spec-creation/tasks/validate.md\` first")`
   - **Context passed:** `{issue_number, spec_path}`
   - **Returns:** `{status, verdicts: [{check_name, result}], finding_summary}`

4. **If validate returns FAIL:** Dispatch `task(..., prompt: "execute revise from spec-creation. Read \`skills/spec-creation/tasks/revise.md\` first")`
   - **Context passed:** `{issue_number, spec_path, validation_findings}`
   - **Returns:** `{status, spec_path, finding_summary}`
   - Then return to step 3 (validate)

5. **If validate returns PASS:** Spec is ready for approval. Report spec_path and issue_url.

### Revise an existing spec

1. **revise** — Dispatch `task(..., prompt: "execute revise from spec-creation. Read \`skills/spec-creation/tasks/revise.md\` first")`
   - **Context passed:** `{issue_number, spec_path, revision_reason}`
   - **Returns:** `{status, spec_path, finding_summary}`

2. **validate** — Dispatch `task(..., prompt: "execute validate from spec-creation. Read \`skills/spec-creation/tasks/validate.md\` first")`
   - **Context passed:** `{issue_number, spec_path}`
   - **Returns:** `{status, verdicts, finding_summary}`

3. If validate returns FAIL, return to step 1. If PASS, spec is ready.

## Task Files

| File | Category | Purpose |
|------|----------|---------|
| `tasks/analyze.md` | ANALYSIS | Pre-spec inspection, requirements extraction, decomposition, analytical artifacts |
| `tasks/create.md` | PRODUCTION | Assemble spec, create remote issue, write local spec |
| `tasks/validate.md` | VERIFICATION | Holistic self-check (11 dimensions), structural validation |
| `tasks/revise.md` | PRODUCTION | Spec revision with change control tracking |

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


