> **Full spec and artifacts: [`.opencode/.issues/1697/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1697)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1697/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

During implementation of #1673, 6 behavioral SCs were deferred, then the test artifacts were evaluated inline (grep on stderr) instead of via clean-room sub-agents, and defective tests were not remediated. The user had to point out each failure. Root cause analysis identified 4 distinct failure modes:

**Failure 1 — SC Lobotomy (critical-rules-sc-lobotomy):** Behavioral SCs were reported as "pending post-merge" — a deferral that violates the SC Lobotomy Prohibition. The agent claimed "22 string-type SCs verified PASS. 6 behavioral SCs pending post-merge" instead of implementing them.

**Failure 2 — "Artifact generated" reported as PASS (EVIDENCE_TYPE_MISMATCH):** After `behavior_run` produced artifacts, the agent reported "✅ Artifact generated" as a test verdict. This is structural evidence (file exists) for a behavioral SC — a hard FAIL per `080-code-standards.md` §Evidence Type Taxonomy. The artifacts were never evaluated by clean-room sub-agents.

**Failure 3 — No prompt validation:** The initial test prompts lacked authorization context ("approved" / "go"), so the agent halted at the authorization gate. The tests generated artifacts but the agent never performed the target behavior. No gate checked whether the prompt would actually trigger the target behavior.

**Failure 4 — No remediation loop:** When the first clean-room evaluation showed FAIL for all 6 tests, the agent fixed the prompts but didn't re-evaluate through clean-room sub-agents. It reported PASS based on grep counts — the same EVIDENCE_TYPE_MISMATCH pattern.

## Root Causes

1. **No mandatory post-behavioral-test evaluation gate in the skill deck.** After `behavior_run` produces artifacts, there is no mandatory step to dispatch clean-room sub-agents for evaluation. The `verification-before-completion` skill covers SC verification for implementation code but not for behavioral test artifacts.

2. **No "artifact generated ≠ PASS" enforcement in guidelines.** The behavioral test harness spec (`.opencode/tests/AGENTS.md`) correctly states that scripts are "artifact-only generators" and "NEVER evaluate model output" — but there is no corresponding rule that the orchestrator MUST evaluate artifacts via clean-room sub-agents before reporting PASS.

3. **No behavioral test prompt validation gate.** No gate checks that a behavioral test prompt will actually trigger the target behavior. Prompts lacking authorization context, fixture data, or proper scope produce artifacts where the agent never reaches the target behavior.

4. **No mandatory remediation loop for behavioral test failures.** When a clean-room evaluation returns FAIL, there is no protocol requiring: diagnose → fix → re-run → re-evaluate → confirm PASS before reporting.

## Scope

**In scope:**
- Add mandatory behavioral test evaluation gate to `verification-before-completion` skill
- Add "artifact generated ≠ PASS" enforcement rule to `080-code-standards.md`
- Add behavioral test prompt validation gate to `test-driven-development` skill
- Add mandatory remediation loop for behavioral test failures to `implementation-pipeline` skill
- Behavioral enforcement tests for all changes

**Out of scope:**
- Redesign of the behavioral test harness (`.opencode/tests/AGENTS.md`) — that's a separate concern
- Changes to the `behavior_run` function itself

## Approach

Four changes across four skill/guideline files:

1. **`verification-before-completion` skill** — Add a `behavioral-test-evaluation` task that dispatches clean-room sub-agents to evaluate behavioral test artifacts. The task receives artifact directory paths, reads stdout/stderr/timeline, and returns PASS/FAIL per SC.

2. **`080-code-standards.md`** — Add rule: "Artifact generated" is NOT a valid PASS verdict for behavioral SCs. Behavioral test artifacts MUST be evaluated by clean-room sub-agents before any PASS claim.

3. **`test-driven-development` skill** — Add a `validate-behavioral-prompt` task that checks whether a behavioral test prompt will trigger the target behavior (authorization context present, fixture data available, prompt is a real-domain task not prose-recall).

4. **`implementation-pipeline` skill** — Add a `behavioral-test-remediation` step to the Trigger Dispatch Table. When a behavioral test evaluation returns FAIL, the orchestrator MUST: diagnose root cause → fix → re-run test → re-evaluate → confirm PASS before proceeding.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `verification-before-completion` has a `behavioral-test-evaluation` task that dispatches clean-room sub-agents | `string` | `grep -q "behavioral-test-evaluation" .opencode/skills/verification-before-completion/SKILL.md` |
| SC-2 | `080-code-standards.md` has a rule: "Artifact generated" is NOT a valid PASS verdict for behavioral SCs | `string` | `grep -q "Artifact generated" .opencode/guidelines/080-code-standards.md` |
| SC-3 | `test-driven-development` has a `validate-behavioral-prompt` task | `string` | `grep -q "validate-behavioral-prompt" .opencode/skills/test-driven-development/SKILL.md` |
| SC-4 | `implementation-pipeline` has a `behavioral-test-remediation` step in Trigger Dispatch Table | `string` | `grep -q "behavioral-test-remediation" .opencode/skills/implementation-pipeline/SKILL.md` |
| SC-5 | Behavioral test: agent dispatches clean-room sub-agent to evaluate behavioral test artifacts after `behavior_run` | `behavioral` | `opencode-cli run` with behavioral test → stderr shows clean-room evaluation dispatch |
| SC-6 | Behavioral test: agent does NOT report "artifact generated" as PASS for behavioral SC | `behavioral` | `opencode-cli run` with behavioral test → stderr shows clean-room evaluation, not "artifact generated" |

## Dependencies

- None — all changes are to separate files

## Edge Cases

- **Existing behavioral tests are not affected** — the evaluation gate only applies to new behavioral test runs
- **The `behavior_run` function itself is unchanged** — only the post-run evaluation protocol changes
- **Clean-room sub-agent evaluation may time out** — the evaluation task should have a generous timeout (600s+)

---

🤖 OpenCode (deepseek-v4-flash) created