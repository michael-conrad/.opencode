# Task: resolve-models

## Purpose

Read the canonical auditor model pool from `qualified-auditor-pool.sh`, map each model to its agent name and model family, detect the orchestrator's model, exclude same-family agents, and return two `subagent_type` strings from different families suitable for `task(subagent_type="auditor-*")` dispatch.

## Entry Criteria

- Invoked by `cross-validate` task or behavioral test helper
- `orchestrator_model` present in dispatch context (from session context `<ModelId>`)
- `.opencode/tests/qualification/qualified-auditor-pool.sh` exists and is readable

## Exit Criteria

- Return `{ auditor_1, auditor_2 }` where both are valid `subagent_type` strings (e.g., `"auditor-glm-5.1"`, `"auditor-mistral-large"`)
- Both auditors belong to different model families
- Neither auditor shares the orchestrator's model family
- If fewer than two eligible families remain: return `{ auditor_1: null, auditor_2: null, error: "INSUFFICIENT_FAMILIES" }`

## Procedure

### Step 1: Load Qualified Auditor Pool

Read `.opencode/tests/qualification/qualified-auditor-pool.sh`. Extract every model string between the `MODELS` heredoc delimiters. Each line is one model in `ollama/`-compatible `family-variant:cloud` format.

### Step 2: Build Agent-to-Family Mapping

For each model from the pool, derive the agent name and family:

| Model (pool entry) | Agent Name (`subagent_type`) | Family |
|---|---|---|
| `deepseek-v4-flash:cloud` | `auditor-deepseek-flash` | `deepseek` |
| `deepseek-v3.2:cloud` | `auditor-deepseek-v3` | `deepseek` |
| `glm-5.1:cloud` | `auditor-glm-5.1` | `glm` |
| `glm-5:cloud` | `auditor-glm-5` | `glm` |
| `mistral-large-3:675b-cloud` | `auditor-mistral-large` | `mistral` |
| `kimi-k2.6:cloud` | `auditor-kimi-k2` | `kimi` |
| `qwen3.5:397b-cloud` | `auditor-qwen3.5` | `qwen` |

The agent name format is `auditor-<family-base>-<variant>`. Verify each corresponding `.opencode/agents/<agent-name>.md` file exists via glob. Omit any agent whose file is missing.

### Step 3: Detect Orchestrator's Model Family

Parse `orchestrator_model` from dispatch context. Extract the family by matching against known family prefixes (deepseek, glm, mistral, kimi, qwen). The orchestrator model ID is typically `ollama/<model>:cloud` or `ollama-cloud/<model>` — strip the prefix and suffix to isolate the model core.

| Orchestrator Model | Family | Agent Name |
|---|---|---|
| Contains `deepseek-v4-flash` | `deepseek` | `auditor-deepseek-flash` |
| Contains `deepseek-v3` | `deepseek` | `auditor-deepseek-v3` |
| Contains `glm-5.1` | `glm` | `auditor-glm-5.1` |
| Contains `glm-5` | `glm` | `auditor-glm-5` |
| Contains `mistral-large-3` | `mistral` | `auditor-mistral-large` |
| Contains `kimi-k2` | `kimi` | `auditor-kimi-k2` |
| Contains `qwen3.5` | `qwen` | `auditor-qwen3.5` |

If the orchestrator model does not match any known family, treat it as unknown — exclude nothing by family, only by agent-name match.

### Step 4: Exclude Ineligible Agents

Remove from the candidate pool:
1. Any agent whose family matches the orchestrator's family
2. The specific agent that maps to the orchestrator's exact model (precautionary — catches edge cases where family match is ambiguous)

### Step 5: Select Two Cross-Family Auditors

Group remaining candidates by family. Pick the first available agent from each eligible family.

Selection priority within each family (most capable first):
- DeepSeek family: `auditor-deepseek-flash` > `auditor-deepseek-v3`
- GLM family: `auditor-glm-5.1` > `auditor-glm-5`
- All other families: single agent, no prioritization needed

Select two auditors from two different families. Prefer families with only one agent (forced diversification) to preserve multi-agent families for future expansion.

### Step 6: Return Result Contract

```
{
  auditor_1: "auditor-<family>-<variant>",
  auditor_2: "auditor-<family>-<variant>",
  family_1: "<family>",
  family_2: "<family>",
  orchestrator_family: "<family>",
  excluded_families: ["<family>", ...],
  candidates_available: N
}
```

If fewer than two eligible families remain after exclusion: return `{ auditor_1: null, auditor_2: null, error: "INSUFFICIENT_FAMILIES", reason: "<explanation>" }`.

## Context Required

- `orchestrator_model`: The orchestrator's resolved model ID (from `<ModelId>`)
- `github.owner`, `github.repo`: For file path resolution (defaults to `.opencode` context)

## Red Flags

- Never select two auditors from the same family — cross-family diversity is the invariant
- Never select the orchestrator's own agent type as an auditor — self-auditing defeats adversarial independence
- Never hardcode the agent-to-family mapping — always derive from `qualified-auditor-pool.sh` plus `.opencode/agents/` glob
- Never assume agent files exist without glob verification
- Never return a single auditor — dual dispatch is mandatory
- Never return raw model strings (e.g., `ollama/glm-5.1:cloud`) — always return `subagent_type` strings (e.g., `auditor-glm-5.1`)

## Cross-References

- `qualified-auditor-pool.sh` — canonical auditor model pool
- `.opencode/agents/auditor-*.md` — agent files with model and permission definitions
- `adversarial-audit/tasks/cross-validate.md` — consumer that dispatches resolved auditor types
- `adversarial-audit/SKILL.md` — skill-level rules (cross-family invariant, orchestrator exclusion)
- `multimodal-dispatch` skill — model capability probing if needed for family detection

## Sub-Agent Dispatch Audit

Authorization context is passed alongside model resolution context:

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Dispatch Rules
- Missing `authorization_scope` in dispatch context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `orchestrator_model`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`, `github.owner`, `github.repo` | Any implementation context, agent memory, cached model pool data | N/A — this task reads the qualified pool directly, not via pre-analysis | NO |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-04T00:00:00Z"
rules:
  - id: resolve-models-001
    title: "Family detection from qualified-auditor-pool.sh mapping is canonical"
    conditions:
      all: ["auditor_pool_read == false"]
    actions: [READ_FILE("qualified-auditor-pool.sh")]
    source: "resolve-models.md §Step 1"

  - id: resolve-models-002
    title: "Agent file existence must be verified via glob before inclusion in candidate pool"
    conditions:
      all: ["agent_file_glob == false"]
    actions: [GLOB(".opencode/agents/auditor-*.md")]
    source: "resolve-models.md §Step 2"

  - id: resolve-models-003
    title: "Cross-family selection mandatory — auditor_1.family != auditor_2.family"
    conditions:
      all: ["auditor_1_family == auditor_2_family", "families_available >= 2"]
    actions: [HALT, RESELECT_DIFFERENT_FAMILY]
    source: "resolve-models.md §Step 5"

  - id: resolve-models-004
    title: "Orchestrator model family exclusion mandatory"
    conditions:
      all: ["selected_auditor_family == orchestrator_family"]
    actions: [HALT, RESELECT_EXCLUDE_ORCHESTRATOR]
    source: "resolve-models.md §Step 4"

  - id: resolve-models-005
    title: "Insufficient families must return null result contract with error"
    conditions:
      all: ["eligible_families < 2"]
    actions: [RETURN_INSUFFICIENT_FAMILIES_ERROR]
    source: "resolve-models.md §Step 6"

  - id: resolve-models-006
    title: "Return subagent_type strings, never raw model strings"
    conditions:
      all: ["return_type contains 'ollama'"]
    actions: [HALT, MAP_TO_SUBAGENT_TYPE]
    source: "resolve-models.md §Step 6"

  - id: resolve-models-007
    title: "Orchestrator exact agent exclusion as precautionary defense"
    conditions:
      all: ["selected_agent_name == orchestrator_agent_name", "family_match_ambiguous == true"]
    actions: [HALT, RESELECT_EXCLUDE_EXACT_MATCH]
    source: "resolve-models.md §Step 4"

  - id: resolve-models-008
    title: "Unknown orchestrator family — exclude nothing by family, only by exact agent match"
    conditions:
      all: ["orchestrator_family == 'unknown'"]
    actions: [EXCLUDE_EXACT_AGENT_MATCH_ONLY]
    source: "resolve-models.md §Step 3"
```
