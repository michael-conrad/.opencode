# [SPEC-FIX] Solve tool: add --output json flag for agent-parsable structured output

## Problem

The `solve` tool (`opencode/tools/solve`) prints Z3 SAT/UNSAT results as human-readable stdout text:

```
SAT
Checking contract: .../contract.yaml
Status: SATISFIED
```

Sub-agents executing pipeline verification steps cannot programmatically consume this output. They must grep stdout for substring patterns (`"SAT"`, `"UNSAT"`, `"SATISFIED"`), which is fragile, prone to false positives, and bypasses the structured-parsing contract that the pipeline depends on.

This was documented as **Lesson 9** in the session-2026-06-27 lessons learned — the solve tool has no structured output mechanism.

## Related

- Lesson 9: `opencode/.issues/lessons-learned/session-2026-06-27/README.md`
- Supersedes sym-* tool purge (#872, closed) — solve tool exists and works, but output format blocks programmatic consumption
- Partially addresses Lesson 10 (naming ambiguity) via updated tool `--description`

## Proposed Approach

1. Add `--output json` flag to all 4 solve actions (`check`, `model`, `prove`, `state`)
2. When `--output json` is set, output valid JSON to stdout instead of human-readable prose
3. When `--output json` is absent, existing human-readable output preserved (backward compatible)
4. As part of the same change: update the tool's `--description` text to clarify scope: "Z3 constraint solver (bool/int/real/string SAT). For workflow/ordering validation, use the plan tool."
5. No structural changes to Z3 engine, contract format, or state format
6. Must write behavioral test(s) per `080-code-standards.md` §Behavioral Enforcement Tests

## JSON Output Schema

### solve check

```json
{"action": "check", "status": "SAT|UNSAT", "contract": "<path>", "unsat_core": ["<var1>", ...]}
```

### solve model

```json
{"action": "model", "status": "SAT|UNSAT", "query": "<query>", "assignment": {"<var>": <value>, ...}}
```

### solve prove

```json
{"action": "prove", "status": "VALID|INVALID", "theorem": "<theorem>"}
```

### solve state init|update|status

```json
{"action": "state", "subaction": "init|update|status", "status": "OK|ERROR", "variables": {...}, "error": "<reason_if_ERROR>"}
```

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `solve check --output json` returns valid JSON with SAT/UNSAT status | `string` + `behavioral` |
| SC-2 | `solve model --output json` returns valid JSON with assignment on SAT queries | `string` + `behavioral` |
| SC-3 | `solve prove --output json` returns valid JSON with VALID/INVALID | `string` + `behavioral` |
| SC-4 | `solve state init --output json` returns valid JSON with status OK | `string` + `behavioral` |
| SC-5 | `solve state status --output json` returns valid JSON with variables | `string` + `behavioral` |
| SC-6 | Existing human-readable output preserved when `--output json` absent | `structural` |
| SC-7 | `--help` output includes description clarifying Z3 scope (bool/int/real/string) | `string` |
| SC-8 | Behavioral test verifies sub-agent can parse `--output json` from `solve check` | `behavioral` |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash-free)
