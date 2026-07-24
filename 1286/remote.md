---
remote_issue: 1286
remote_url: "https://github.com/michael-conrad/.opencode/issues/1286"
last_sync: "2026-06-18T17:06:21Z"
source: github
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `plan` and `solve` tools (`./.opencode/tools/plan`, `./.opencode/tools/solve`) have fallback tasks that describe manual procedures (acyclic graph checks, topological sort, dependency verification) when the tool is **unavailable**. But there is no protocol for when the tool **is available but broken** — crashes, hangs, garbage output, corrupted results, or silent failures.

Currently, when `plan plan --problem ...` or `solve check --state-path ...` runs:
- **Available + produces correct result** → proceed (works)
- **Unavailable** → fallback describes manual procedure (acceptable for unavailability)
- **Available but broken** (crash, timeout, garbage YAML, UNSAT when should be SAT, wrong model) → **NO PROTOCOL EXISTS**

The local issue files are unversioned and low-cost. The fallback tasks themselves are local artifacts. Neither situation justifies continuing pipeline work through potentially corrupted constraint or planning data. If the tools cannot be trusted, all pipeline work relying on them is untrustworthy.

## Root Cause

The `plan` skill's `tasks/fallback.md` and the `solve` skill's `tasks/fallback.md` both document manual procedures but lack an **escalation protocol** — a hard gate that halts execution, notifies the developer, and revokes pipeline authorizations. The `writing-plans` task cards that invoke these tools also lack the escalation protocol — they HALT but do not revoke auths or notify with the severity the situation demands.

## Fix Approach

### Phase 1: Escalation protocol for `plan/tasks/fallback.md`

Add a Step 0 (hard gate before any manual procedure) to `.opencode/skills/plan/tasks/fallback.md`:

- **Step 0: Tool Breakage Escalation Gate**
  - Distinguish between "tool unavailable" (not installed, import fails) and "tool broken" (crashes, hangs, produces garbage/corrupted output, UNSAT when expected SAT)
  - If tool is **broken**: HALT immediately. Do NOT execute any fallback manual procedure. The tool being broken means the pipeline cannot trust any constraint or planning data produced through it.
  - Required notification: report to developer (chat) that the tool is broken, include evidence (error output, crash logs, corrupted output), state that all pipeline processing is halted
  - Required auth revocation: ALL pipeline authorizations for the current session are revoked. The developer must explicitly re-authorize after the tool is fixed.
  - Required diff/status report: run `git status` and `git diff --stat` to report current branch state before halting
- If tool is **unavailable**: proceed to existing manual fallback procedures

### Phase 2: Escalation protocol for `solve/tasks/fallback.md`

Add a Step 0 (hard gate before any manual procedure) to `.opencode/skills/solve/tasks/fallback.md`:

- Same structure as Phase 1: distinguish broken vs unavailable, broken → hard halt + dev notification + auth revocation + diff report, unavailable → manual fallback

### Phase 3: Escalation protocol for `writing-plans` tool invocation steps

Update all references to `plan plan` and `solve check` in:
- `.opencode/skills/writing-plans/tasks/create/plan-structure.md` (lines 37-41, 296-301)
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` (lines 129-131)
- `.opencode/skills/writing-plans/tasks/create.md` (line 102)

For each invocation, add the breakage detection + escalation protocol:
- Check return code AND output validity (non-empty, parseable, semantically correct)
- If return code non-zero OR output is corrupted/unparseable: classify as BROKEN → hard halt
- If return code is zero but result is obviously wrong (e.g., UNSAT when contract is trivially SAT): classify as BROKEN → hard halt
- Hard halt includes: dev notification, auth revocation, diff/status report
- Auth is NOT revoked for unavailability (tool not installed) — only for breakage (tool installed but producing wrong results)

### Phase 4: Behavioral enforcement test

Add a behavioral enforcement test that:
1. Simulates a broken tool scenario (e.g., `plan` crashes or returns garbage)
2. Verifies the agent HARD HALTS (does not proceed with fallback manual procedures)
3. Verifies the agent notifies the developer with evidence of the breakage
4. Verifies the agent revokes pipeline authorizations

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `plan/tasks/fallback.md` Step 0 distinguishes broken vs unavailable | `string` | `grep -q "BROKEN\b" .opencode/skills/plan/tasks/fallback.md` && `grep -q "unavailable" .opencode/skills/plan/tasks/fallback.md` |
| SC-2 | `plan/tasks/fallback.md` Step 0 hard-halts on broken with auth revocation | `string` | `grep -E "HALT|auth.*revoc|authorization.*revoked" .opencode/skills/plan/tasks/fallback.md` |
| SC-3 | `solve/tasks/fallback.md` Step 0 distinguishes broken vs unavailable | `string` | `grep -q "BROKEN\b" .opencode/skills/solve/tasks/fallback.md` && `grep -q "unavailable" .opencode/skills/solve/tasks/fallback.md` |
| SC-4 | `solve/tasks/fallback.md` Step 0 hard-halts on broken with auth revocation | `string` | `grep -E "HALT|auth.*revoc|authorization.*revoked" .opencode/skills/solve/tasks/fallback.md` |
| SC-5 | `plan-structure.md` tool invocations include breakage detection + escalation | `string` | `grep -q "BROKEN\|hard halt\|auth.*revoc" .opencode/skills/writing-plans/tasks/create/plan-structure.md` |
| SC-6 | `create-and-validate.md` tool invocations include breakage detection + escalation | `string` | `grep -q "BROKEN\|hard halt\|auth.*revoc" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` |
| SC-7 | `create.md` tool invocation includes breakage detection + escalation | `string` | `grep -q "BROKEN\|hard halt\|auth.*revoc" .opencode/skills/writing-plans/tasks/create.md` |
| SC-8 | Behavioral test: agent hard-halts on broken tool, notifies dev, revokes auths | `behavioral` | `opencode-cli run` with broken tool simulation, verify stderr shows HALT + auth revocation + dev notification |

## Edge Cases

- **Tool unavailable vs. broken**: Unavailability means the tool binary does not exist or cannot be imported. Broken means the tool exists but produces incorrect/corrupted results. The escalation protocol for broken tools is a hard halt with auth revocation — unavailability is not auth-worthy, just a fallback trigger.
- **Transient failures**: A one-time crash (OOM, transient file system error) is still BROKEN for the current invocation. The agent does not retry — it halts. The developer can re-authorize after fixing the underlying issue.
- **Auth scope granularity**: Auth revocation applies to ALL pipeline authorizations for the current session — not just the current phase. A broken planning tool means no pipeline stage relying on it can be trusted.
- **Multiple sequential breakages**: If both `plan` and `solve` are broken, report both with their evidence, revoke auths once (not per-tool), and halt.
- **Local-only repos (identity_source == "local")**: Auth revocation still applies to local-only repos. The developer must re-authorize even though there are no remotes — the pipeline state is corrupted regardless.

---

🤖 OpenCode (deepseek-v4-flash)