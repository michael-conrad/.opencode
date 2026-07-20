## Problem

Specs can enter the agent's working context without going through the spec-creation pipeline. Currently, the spec-audit is a pipeline step that can be skipped or bypassed. There is no hard gate that fires on spec encounter — only post-hoc checks in `spec-creation/tasks/completion.md` that rely on the spec having gone through the creation pipeline.

The agent already knows the provenance of any spec in its context — it either wrote it through the pipeline or it didn't. This knowledge must be acted on.

## Solution

Add a **provenance-based trigger**: when a spec enters the agent's working context, the agent checks whether it was written through the spec-creation pipeline. If not → 86'ed (rejected outright, no audit, no remediation, no exceptions). If yes → proceed normally (spec-audit fires as part of the pipeline).

### Three Artifacts

#### 1. Critical Rule — `000-critical-rules.md`

Add a Tier 2 (Process-Integrity, halts) rule:

```yaml
- id: critical-rules-spec-provenance-gate
  tier: 2
  title: "Spec not from spec-creation pipeline is 86'ed — hard halt, no exceptions"
  conditions:
    all:
      - "spec_in_working_context == true"
      - "spec_provenance != 'spec-creation-pipeline'"
      - "about_to_act_on_spec == true"
  actions:
    - HALT
    - REJECT_SPEC(reason: "Spec was not written through the spec-creation pipeline. Only pipeline-written specs are accepted.")
```

The three conditions:
- `spec_in_working_context` — agent has a spec (created it, downloaded it, read it from an issue)
- `spec_provenance != 'spec-creation-pipeline'` — the spec was not written by the spec-creation pipeline (agent knows this from its own context)
- `about_to_act_on_spec == true` — agent is about to implement, revise, or use the spec as basis for action (not just reading for reference)

#### 2. Trigger Dispatch Row — `adversarial-audit/SKILL.md`

Add a context-based row to the trigger dispatch table:

| User says / Context | Task | Dispatch | Context passed |
|---|---|---|---|
| `spec enters working context not from spec-creation pipeline` | `spec-provenance-reject` | `sub-task` | {issue_number} |

#### 3. Stable Verdict Path — `spec-audit` task writes to `.issues/{N}/spec-audit.yaml`

The spec-audit task currently writes verdicts to `./tmp/{issue-N}/artifacts/pipeline-audit-spec-audit-{STATUS}-{timestamp}.yaml` — a temp path with timestamp, not suitable for stable checking.

Change the spec-audit task to also write a stable verdict file at `.issues/{N}/spec-audit.yaml` with the consensus PASS/FAIL result.

### Check Location: First Encounter

The orchestrator checks provenance on **first encounter** of the spec. One check per spec per session.

- If provenance is `spec-creation-pipeline` → proceed normally (spec-audit fires as pipeline step, verdict stored at `.issues/{N}/spec-audit.yaml`)
- If provenance is anything else → 86'ed. HALT. No audit, no remediation, no exceptions.

### No Exceptions

- AI-written via spec-creation pipeline → accepted, audited
- AI-written outside the pipeline (inline, ad-hoc) → 86'ed
- Human-written specs → 86'ed
- Specs downloaded from issues → 86'ed
- Specs from previous sessions → 86'ed

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Critical rule added to `000-critical-rules.md` with provenance gate and REJECT_SPEC action | `string` | grep for `critical-rules-spec-provenance-gate` in `000-critical-rules.md` |
| SC-2 | Context-based trigger row added to `adversarial-audit/SKILL.md` trigger dispatch table | `string` | grep for `spec enters working context not from spec-creation pipeline` in `adversarial-audit/SKILL.md` |
| SC-3 | Spec-audit task writes stable verdict to `.issues/{N}/spec-audit.yaml` with consensus, audit_type, artifact_path, and audited_at fields | `behavioral` | Run spec-audit on a test spec, verify `.issues/{N}/spec-audit.yaml` exists with valid YAML content |
| SC-4 | Orchestrator rejects (86's) a spec not from spec-creation pipeline on first encounter | `behavioral` | `opencode-cli run` with a non-pipeline spec in context, verify stderr shows rejection with no audit dispatch |
| SC-5 | Orchestrator accepts a spec from spec-creation pipeline and proceeds to audit | `behavioral` | `opencode-cli run` with a pipeline-written spec, verify stderr shows audit dispatch |
| SC-6 | No issue comments, labels, or GitHub API calls used for provenance tracking or rejection | `string` | grep for absence of `github_issue_write`/`github_add_issue_comment` in spec-audit task for verdict storage |

## Implementation Plan

### Phase 1: Verdict Path Change
1. Modify `adversarial-audit/tasks/spec-audit.md` to write `.issues/{N}/spec-audit.yaml` after consensus
2. Update the completion task to verify the stable verdict file exists

### Phase 2: Critical Rule
1. Add `critical-rules-spec-provenance-gate` to `000-critical-rules.md` Tier 2 section

### Phase 3: Trigger Dispatch
1. Add context-based row to `adversarial-audit/SKILL.md` trigger dispatch table

### Phase 4: Behavioral Tests
1. Write behavioral enforcement test for SC-4 (non-pipeline spec → 86'ed)
2. Write behavioral enforcement test for SC-5 (pipeline spec → audit)
3. Confirm RED state before Phase 2-3 changes
4. Confirm GREEN after changes
