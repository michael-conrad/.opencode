# Synced from GitHub Issue #381 at 2026-05-04T04:02:50Z

## Root Cause

The `task()` built-in tool has no model selection parameter — every sub-agent inherits the orchestrator's model. The dual-adversarial auditor pattern from #365, #364, #362 requires two different cloud models evaluating the same evidence independently. The current workaround (`opencode-cli run --model` via bash) is heavyweight (full session init per evaluation) and sidesteps the clean-room dispatch architecture.

## Scope

Create `.opencode/agents/` directory with markdown agent files for the 9 qualified auditor models, plus a thin skill wrapper for dual-auditor cross-validation dispatch. Configuration-only — no engine changes required.

## Fix Approach

### Phase 1: Auditor Agent Files

Create `.opencode/agents/` with one markdown file per qualified model from `qualified-auditor-pool.sh`. Each file specifies:
- `mode: subagent`
- `model: ollama/:cloud`
- `description`: adversarial auditing of model output
- `permission`:
  - `read`: allow
  - `glob`: allow
  - `grep`: allow
  - `skill`: allow
  - `webfetch`: allow
  - `websearch`: allow
  - `edit`: deny
  - `bash`: deny
  - `task`: deny
  - `todowrite`: deny
  - `question`: deny
- Prompt instructing the model it is an autonomous adversarial auditor that trusts nothing from the orchestrator, independently searches for and verifies against live documentation, and returns structured JSON verdicts

**9 agents:**

1. `auditor-deepseek-v4` (model: `ollama/deepseek-v4-pro:cloud`)
2. `auditor-deepseek-flash` (model: `ollama/deepseek-v4-flash:cloud`)
3. `auditor-deepseek-v3` (model: `ollama/deepseek-v3.2:cloud`)
4. `auditor-glm-5.1` (model: `ollama/glm-5.1:cloud`)
5. `auditor-glm-5` (model: `ollama/glm-5:cloud`)
6. `auditor-mistral-large` (model: `ollama/mistral-large-3:675b-cloud`)
7. `auditor-kimi-k2` (model: `ollama/kimi-k2.6:cloud`)
8. `auditor-qwen3.5` (model: `ollama/qwen3.5:397b-cloud`)
9. `auditor-devstral-2` (model: `ollama/devstral-2:123b-cloud`)

Naming: family-based, not model-precise — enables cross-family selection at dispatch time without renaming agents when models upgrade.

### Phase 2: Skill Wrapper

Create or update a skill (`adversarial-audit`) that wraps dual-auditor dispatch:
- Task `cross-validate`: accepts evidence payload + evaluation criteria, dispatches to two auditor sub-agents from different families using `task(subagent_type="auditor-*")`, collects structured JSON verdicts, cross-references them for consensus (PASS iff both agree PASS)
- Task `resolve-models`: resolves which two auditor models to use (pick from different families, exclude orchestrator's model)
- Task `completion`: halt guarantee

### Phase 3: Infrastructure Updates

- Fix stale comment in `qualified-auditor-pool.sh` (says "These 6 models" but lists 9)
- Update `.opencode/tests/behaviors/helpers.sh` `behavior_adversarial_eval` to use `task()` dispatch to auditor sub-agents instead of `opencode-cli run` bash workaround (if feasible within same PR scope)
- Update `behavior_adversarial_eval` model resolution to use `adversarial-audit --task resolve-models`

## Success Criteria

| # | Criterion | Verification | Semantic Intent |
|---|-----------|--------------|-----------------|
| SC-1 | `.opencode/agents/` directory exists with 9 auditor markdown agent files, each with correct model, permissions, and prompt | `ls .opencode/agents/auditor-*.md | wc -l` returns 9; each file's YAML frontmatter has `mode: subagent`, correct `model:` field, exactly 7 `allow` and 4 `deny` permissions | Agent files must be structurally valid with correct permission surface — 7 allow (read, glob, grep, skill, webfetch, websearch, websearch) and 4 deny (edit, bash, task, todowrite, question) maps to 11 total permissions |
| SC-2 | `qualified-auditor-pool.sh` comment corrected to "These 9 models" | Line 4 of `qualified-auditor-pool.sh` reads `# These 9 models passed both skill-listing and file-reading probes` | The comment must reflect the actual count of models in the file (9), not 6 — stale comments create confusion about the auditor pool size |
| SC-3 | All 9 auditor agents appear in `opencode agent list` as subagent type entries | `opencode agent list` output includes `auditor-deepseek-v4`, `auditor-deepseek-flash`, `auditor-deepseek-v3`, `auditor-glm-5.1`, `auditor-glm-5`, `auditor-mistral-large`, `auditor-kimi-k2`, `auditor-qwen3.5`, `auditor-devstral-2` | Agent registration must work end-to-end — existence of files is insufficient; the CLI must parse and register them |
| SC-4 | `adversarial-audit` skill exists with `cross-validate` and `resolve-models` tasks | `ls .opencode/skills/adversarial-audit/SKILL.md` and `ls .opencode/skills/adversarial-audit/tasks/cross-validate.md` and `ls .opencode/skills/adversarial-audit/tasks/resolve-models.md` and `ls .opencode/skills/adversarial-audit/tasks/completion.md` | The skill must be structurally complete with all required task files |
| SC-5 | `behavior_adversarial_eval` in `helpers.sh` dispatches via `task(subagent_type="auditor-*")` instead of `opencode-cli run` bash | `helpers.sh` behavior_adversarial_eval function uses `task()` built-in tool, no longer contains `opencode-cli run` or `BEHAVIOR_TEST_HOME` references for auditor dispatch | Replace bash-based model invocation with clean-room sub-agent dispatch — eliminates heavyweight session-init overhead and restores clean-room isolation |
| SC-6 | Behavioral: orchestrator dispatches dual-auditor cross-validation using `task(subagent_type="auditor-glm-5.1")` and `task(subagent_type="auditor-mistral-large")` — both agents independently evaluate, produce structured JSON verdicts, and orchestrator cross-references for consensus | Dual-auditor behavioral test; RED: auditor dispatch not possible (no agent files exist), GREEN: both auditors return structured `[{"id":"...","result":"PASS|FAIL","explanation":"..."}]` and cross-reference produces PASS only when both agree | Cross-family model selection (GLM and Mistral) verifies that different model architectures produce independent verdicts — consensus gate ensures no single model bias dominates |
| SC-7 | Content-verification: all 9 agent files have correct permission surface (7 allow, 4 deny) | For each `auditor-*.md`, count `allow:` entries = 7 and `deny:` entries = 4 | Permission surface is the security boundary for auditor sub-agents — missing denies could allow unintended mutations |
| SC-8 | Behavioral: auditor agent, when presented with a factually incorrect claim about a publicly documented API, independently fetches the live docs and returns FAIL — verified by dual-auditor cross-validation | Present claim "requests.get() takes a `timeout_ms` parameter" (fake), verify auditor fetches `requests` docs via `webfetch` and returns FAIL for that claim; dual-auditor consensus on FAIL | Verifies auditor independence — auditor MUST fetch live docs, not trust orchestrator or training data. This SC validates the entire adversarial audit pipeline end-to-end |

## Dependencies

None — this is net-new infrastructure that does not modify existing enforcement rules.

## PR Merge Boundaries

None — no upstream dependencies.

## Related Issues

- #365 — dual-auditor as architectural invariant
- #364 — content-verification extension
- #362 — template awareness
- #360 — original dual-auditor discovery

---

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
