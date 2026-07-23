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
