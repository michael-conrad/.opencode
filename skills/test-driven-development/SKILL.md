---
name: test-driven-development
description: "Test-driven development that runs RED/GREEN cycles, writes behavioral enforcement tests, and generates regression test patterns. Load via skill() when writing tests before implementation, or when adopting a test-first development approach. Also load when running RED/GREEN cycles, writing behavioral enforcement tests, or generating regression test patterns. TDD is REQUIRED. User phrases: write test, RED phase, GREEN phase, TDD, behavioral test, regression test"
license: MIT
compatibility: opencode
---

# Skill: test-driven-development

## Persona

TDD enforcer. Routes RED-phase test writing and GREEN-phase implementation to separate clean-room sub-agents that independently verify each item. An orchestrator that writes tests and implementation inline instead of dispatching to separate sub-agents has produced a self-verified cycle, not a TDD cycle — every RED/GREEN transition carries the orchestrator's own knowledge of what the implementation should look like, collapsing the separation that makes TDD reliable. Professional TDD practitioners dispatch RED and GREEN to separate sub-agents. Inlining means no test was ever independently RED before GREEN.

## Five Core Principles

- [ ] 1. **FAIL=FAIL** — No soft-passing. Verify against live sources. Report PASS/FAIL truthfully.
- [ ] 2. **RED/GREEN separation** — RED and GREEN must be separate phases. They may NEVER be combined into a single phase or step. RED must complete (test written and confirmed FAIL) before GREEN begins. This is a hard gate — no authorization or developer instruction may override it.
- [ ] 3. **TDD discipline** — RED phase tests before GREEN phase implementation. REFACTOR is mandatory, not optional.
- [ ] 4. **Clean-room** — No inline fallback. Sub-agents receive only scoped context. No pre-determined findings.
- [ ] 5. **Independent intelligence** — Autonomous analysis. If the task contains excessive instruction where your own analysis should apply, HALT and notify parent.
- [ ] 6. **Verify LIVE** — Never trust training data, memory, or metadata. Verify against live docs, source code, and test results.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "red" / "write test" / "failing test" | `red` | `sub-task` | {spec_context} |
| "green" / "implement" / "pass test" | `green` | `sub-task` | {spec_context} |
| "refactor" / "clean up" | `refactor` | `sub-task` | {spec_context} |
| "patterns" / "test patterns" / "decision matrix" | `patterns` | `sub-task` | {spec_context} |
| "anti-patterns" / "test anti-patterns" | `anti-patterns` | `sub-task` | {spec_context} |
| "checklist" / "TDD checklist" | `checklist` | `sub-task` | {spec_context} |
| "phase-0" / "pre-regression" / "baseline" | `phase-0` | `sub-task` | {spec_context} |
| "phase-4" / "post-regression" / "verify" | `phase-4` | `sub-task` | {spec_context} |
| "validate-behavioral-prompt" / "validate prompt" / "check prompt" | `validate-behavioral-prompt` | `sub-task` | {prompt_text, sc_list} |

## TDD Heading Format Requirement

Read [the TDD heading format requirements and SC-ID extraction contract](skills/test-driven-development/tasks/operating-protocol.md).

## ASCII Cycle Diagram

Read [the TDD cycle diagram](skills/test-driven-development/tasks/operating-protocol.md).

## Tasks

|------|-------|---------|
| `red` | Execution-only: write failing test |
| `green` | Execution-only: minimal impl |
| `refactor` | Execution-only: clean while green |
| `patterns` | 4-pattern decision matrix |
| `anti-patterns` | 5 anti-patterns with alternatives |
| `checklist` | Quality checklists, timing, step-size |
| `phase-0` | Pre-regression baseline gate |
| `phase-4` | Post-regression verification gate |
| `validate-behavioral-prompt` | Validate behavioral test prompt triggers target behavior |

## Invocation

`skill({name: "test-driven-development"})` — call the skill, then call via task():

| Task | Call via task() |

| (use task name) | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [execute the named TDD task](.opencode/skills/test-driven-development/tasks/<task>.md). "))` |

**CLI equivalent (for human TUI use):** `` `skill({name: "test-driven-development"})` ``

## Gate Descriptions

### Phase 0 — Pre-Regression Baseline

Invoked before the first RED phase. AI-driven dependency analysis (`srclight_get_dependents`), full test suite execution. BLOCKED on test failure — cycle cannot start until existing failures are resolved. Empty blast radius = silent proceed.

### Phase 4 — Post-Regression Verification

Invoked after REFACTOR completes. Re-computes blast radius, runs full suite. Remediation loop: first failure returns to GREEN, second consecutive failure = BLOCKED with halt.

### Completeness Gate (After TDD Cycle, Before Audit)

After Phase 4 passes and before routing to audit, the orchestrator MUST run `completeness-gate --task check` on the deliverable. This gate verifies the deliverable covers all spec success criteria and is structurally sound. The gate is non-adversarial and read-only — it checks presence and coverage, not correctness depth. Read [completeness-gate skill](skills/completeness-gate/SKILL.md) for routing decisions.

## Cycle-Reset Discipline

### Normal Completion

After Phase 4 PASSES:
- [ ] 1. Commit the cycle (test + implementation + refactor as one working slice)
- [ ] 2. Reset to Phase 0 for the next item
- [ ] 3. Never carry state across cycles

### Mid-Cycle Restart

If at ANY point within RED/GREEN/REFACTOR a step exceeds its timing target (30s RED / 2-5min GREEN / 1-3min REFACTOR) or produces unexpected test failures, the agent MUST restart the full RED→GREEN→REFACTOR cycle from the beginning — not limp forward on a broken foundation:

- [ ] 1. Discard all uncommitted changes from the current cycle
- [ ] 2. Restart from RED with zero state carryover
- [ ] 3. If Phase 0 elapsed > 1 full cycle since last baseline, re-execute Phase 0

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ spec_context, test_path, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. Exclusions: implementation context, agent memory, prior test results. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Orchestrator Entry Criteria

Reading the Trigger Dispatch Table and Invocation section in the orchestrator's own context is small, necessary, routing-relevant work assigned to the orchestrator by allocation-by-context-cost: the skill card is routing metadata the orchestrator must hold, and sub-agents cannot call `skill()` or load skills. The no-preloaded-context substance below is unchanged.

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Operating Protocol

- [ ] 1. **RED phase evidence:** RED phase MUST produce evidence of test failure before proceeding to GREEN
- [ ] 2. **Phase 0 before RED:** Phase 0 (pre-regression baseline) MUST complete before RED phase begins
- [ ] 3. **Phase 4 before cycle reset:** Phase 4 (post-regression verification) MUST complete before cycle reset

## Enforcement Test Mandate for Guideline and Skill Changes

**Terminology:** In this document, "behavioral test" and "functional test" are synonymous. Both refer to tests that verify actual agent behavior by executing code and observing output, as opposed to structural/content-verification tests that verify text patterns in files. When a functional/behavioral test cannot execute, the SC is FAIL — never PASS or UNVERIFIED with a structural substitute.

Behavioral tests are how real agents prove their rules work. Adding a guideline change without a behavioral test means you are documenting, not enforcing.

Guideline files (`.opencode/guidelines/*.md`) and skill files (`.opencode/skills/*/SKILL.md`, `.opencode/skills/*/tasks/*.md`) are enforcement-critical documents that control AI agent behavior. Changes to these files MUST be accompanied by corresponding enforcement test updates.

### Behavioral Enforcement Tests (PRIMARY)

Behavioral enforcement tests verify that the agent actually behaves differently after a rule change. They send a prompt to the agent and verify the response actions (tool calls, decline patterns, explicit questions), not just whether rule text exists in a file.

**Principle:** Behavioral tests answer "Does the agent actually behave differently?" Content-verification tests answer "Does the rule text exist in the file?" Both are needed, but behavioral is the PRIMARY enforcement gate.

**Prompt construction:** Behavioral test prompts MUST be real-domain tasks that trigger natural agent behavior — never interview-style prose-recall prompts. Read [§9 Prompt Construction Mandate](.opencode/tests-v2/AGENTS.md) for the full specification.

**Root case:** Bug #1217 demonstrated that the agent had all the correct guideline text about verification but still answered a general knowledge question with zero tool-call verification. Content-verification alone was insufficient — the agent behavior did not match the rule text.

Every critical violation change MUST have at least one behavioral test that verifies the agent follows the new rule. Behavioral tests use the assertion helpers in `.opencode/tests-v2/behaviors/helpers.sh`:

- `assert_tool_calls_made` — verify the agent made at least N tool calls of a specified type
- `assert_forbidden_pattern_absent` — verify the agent's response does NOT contain a specified pattern (e.g., `(unverified)` tags)
- `assert_required_pattern_present` — verify the agent's response DOES contain a specified pattern (e.g., decline-to-answer language)
- `assert_skill_called` — verify a specific skill was called
- `assert_no_skill_called` — verify a specific skill was NOT called when it shouldn't be

### Assert Helpers — Correct Evidence Type per SC Type

Behavioral tests verify agent ACTIONS and DECISIONS. The assertion helper must match the SC's evidence type:

| SC Evidence Type | PRIMARY Assertion | SECONDARY (corroboration only) | FORBIDDEN |
|---|---|---|---|
| `behavioral` | Orchestrator-dispatched clean-room sub-agent evaluation reading `session.yaml` | `assert_stderr_pattern_*` for tool dispatch strings only | grep/string on agent output prose |
| `string` | `assert_stderr_pattern_*`, `assert_required_pattern_present`, `assert_forbidden_pattern_absent` | — | — |
| `structural` | `ls`, `wc`, file existence | — | — |

**Clean-room sub-agent evaluation of `session.yaml`** — The orchestrator dispatches a clean-room sub-agent that reads the behavioral test's `session.yaml` as the PRIMARY evidence source and judges whether the agent TOOK THE RIGHT ACTION or MADE THE RIGHT DECISION. Different model, no context preloading, no cached results. This is the ONLY valid evidence mechanism for behavioral SCs that verify agent actions, decisions, or reasoning.

**`assert_stderr_pattern_present/absent`** — grep on stderr for tool-call strings (e.g., `Skill "approval-gate"`, `git checkout -b`). Only valid for verifying that a tool dispatch OCCURRED or DID NOT occur — NEVER for judging agent reasoning, approach, or decisions. USE AS SECONDARY CORROBORATION ONLY for behavioral SCs, never as primary evidence.

**All other string assertions** (`assert_required_pattern_present`, `assert_forbidden_pattern_absent`, `assert_tool_calls_made`, `assert_skill_called`, `assert_no_skill_called`) — string evidence, appropriate for string or structural SCs, FORBIDDEN as primary evidence for behavioral SCs.

**Prohibitions (per §Rule 5):**
- 🚫 `assert_stderr_pattern_present` as PRIMARY evidence for "agent verified authorization scope" — this is string evidence, not behavioral
- 🚫 `assert_required_pattern_present` on agent prose as primary evidence for "agent chose stacked approach" — this is string evidence on prose, the weakest form
- 🚫 Any grep/string assertion on agent output prose as PRIMARY evidence for a behavioral SC — EVIDENCE_TYPE_MISMATCH
- ✅ Clean-room sub-agent reads `session.yaml` and judges whether the agent took the required action described by the SC — clean-room evaluation of full output
- ✅ `assert_stderr_pattern_present 'Skill "approval-gate"'` as SECONDARY corroboration only

### Content-Verification Tests (SECONDARY)

Content-verification tests verify that rule text exists in the correct files. They are a supplementary sanity check — they confirm the rule was written down but do NOT prove the agent follows it.

Content-verification tests are valuable as a fast check that files haven't regressed, but they MUST NOT be the only enforcement gate for a behavioral rule change. A rule change with only a content-verification test is NOT verified — it only proves the text was written, not that the agent follows it (see #1217).

### 🚫 PROHIBITED

- Adding a critical violation section without a BEHAVIORAL enforcement test that verifies the agent's actual response
- Adding a verification step to a skill without a BEHAVIORAL enforcement test that validates the agent follows it
- Creating a new guideline without a BEHAVIORAL enforcement test that sends a prompt and verifies the agent's behavior
- Modifying a guideline or skill without updating the corresponding BEHAVIORAL enforcement test
- Content-verification tests (checking rule text exists) as the ONLY enforcement for a behavioral rule change
- Running `opencode run` directly without the `with-test-home` wrapper

### ✅ REQUIRED

- Every guideline/skill change comes with a BEHAVIORAL enforcement test that verifies agent behavior
- Content-verification tests as a supplementary sanity check, NOT the primary enforcement gate
- Add the BEHAVIORAL test FIRST (RED), then make the change (GREEN) — behavioral TDD for rules
- Run individual behavioral test scripts (`bash .opencode/tests-v2/behaviors/<scenario>.sh`) for behavioral tests
- Run scope-filtered `bash .opencode/tests-v2/test-enforcement.sh --tag <tag>` or `--changed` for content-verification tests
- Use `bash .opencode/tests-v2/with-test-home opencode run '<message>'` for all opencode testing — never run bare `opencode run`
- Clean up test homes after testing: `bash .opencode/tests-v2/with-test-home --clean-all`

### Per-Change TDD Pattern

| TDD Phase | Action |
| -- | -- |
| **RED** | Write a BEHAVIORAL test that sends a prompt and expects the agent to follow the new rule (test fails because agent doesn't follow it yet); optionally add a content-verification test |
| **GREEN** | Make the guideline/skill change that causes the agent to follow the rule |
| **REFACTOR** | Verify content-verification also passes; clean up test scenarios; confirm behavioral test passes reliably |
| **COMMIT** | Both the behavioral test, content-verification test (if any), and the guideline/skill change committed together |

### Why This Matters

Enforcement tests are the verification layer that proves agent guidelines are actually enforceable. A guideline without a behavioral test is a suggestion, not a rule. A skill without a behavioral test is documentation, not enforcement. Bug #1217 proved that content-verification alone is insufficient — the agent had correct rule text but did not follow the rule in practice.

The `with-test-home` wrapper prevents SQLite session conflicts between the desktop app and CLI tests.

**Read [the incremental implementation discipline](.opencode/guidelines/091-incremental-build.md) that governs HOW these changes are delivered.** **Read [the enforcement test template and usage guide](.opencode/tests-v2/README.md). Read [behavioral test infrastructure, helpers, and template](.opencode/tests-v2/behaviors/).**

### Evidence Type Taxonomy (MANDATORY)

Every spec success criterion MUST declare an evidence type from the four-type taxonomy. The evidence type determines the minimum acceptable verification method — using evidence below the minimum type is a CRITICAL VIOLATION.

| Evidence Type | Method | Verifies | Minimum Acceptable | Cost | Gate Position |
|---|---|---|---|---|---|
| `behavioral` | Test execution (`opencode run`, `pytest`, `bash test.sh`) | Agent behavior, runtime output, functional correctness | Test execution with output inspection | Lowest: behavioral FAIL at gate 1 → immediate fix → zero downstream cost | pre-commit / pre-RED |
| `semantic` | AI agent read + analytical judgment | Intent and meaning, not just pattern | Sub-agent read + judgment | Medium: semantic PASS → behavioral FAIL at CI → 100x rework | pre-PR / review |
| `string` | `grep`, pattern matching | Content pattern present or absent | `grep` | High: string PASS → behavioral FAIL in production → NIST 29x escalation | CI / static analysis |
| `structural` | `ls`, `wc`, file existence | File exists, file is non-empty, file has correct name | `ls`/`wc` | Highest: structural PASS → defect ships → death spiral → compounding exponential cost | none / irrelevant |

### Evidence Type Enforcement Matrix

| SC Evidence Type | Structural Evidence | String Evidence | Semantic Evidence | Behavioral Evidence |
|---|---|---|---|---|
| `structural` | ✅ Sufficient | ✅ Sufficient | ✅ Sufficient but unnecessary | ⚠️ Overkill |
| `string` | ❌ Insufficient | ✅ Sufficient | ✅ Sufficient | ⚠️ Overkill |
| `semantic` | ❌ Insufficient | ❌ Insufficient | ✅ Sufficient | ✅ Sufficient |
| `behavioral` | ❌ **CRITICAL VIOLATION** | ❌ **CRITICAL VIOLATION** | ❌ **CRITICAL VIOLATION** | ✅ Only sufficient type |

Evidence below the minimum type for an SC's declared evidence type is a CRITICAL VIOLATION — it is not a soft-pass or an acceptable substitute. This applies at every pipeline stage: VbC, auditor dispatch, cross-validate, and PR body.

**Existing specs without evidence type columns default to `string` evidence type.** The spec-audit SC-DET check flags specs missing evidence type declarations but does not block them — only downgrade to a warning until the spec is updated.

**Mixed-evidence SCs** (e.g., `string + behavioral`) require ALL declared types to be present in the evidence. An SC that requires both string and behavioral evidence must have both a `grep` result and a test execution result.

**EVIDENCE_TYPE_MISMATCH** classification: When an auditor or VbC sub-agent provides structural evidence for a behavioral SC, the verdict MUST be reported as FAIL with `EVIDENCE_TYPE_MISMATCH` classification. This is not a soft-pass — it is a hard FAIL. Cross-validate MUST downgrade any PASS verdict with wrong evidence type to FAIL with `EVIDENCE_TYPE_MISMATCH`.

### SC-to-Test Traceability (MANDATORY) — Behavioral PRIMARY

Every spec success criterion MUST have at least one corresponding BEHAVIORAL enforcement test assertion that references the SC ID. The assertion must include a comment linking it to the specific SC:

```bash
# SC-2: agent declines to answer without verification
assert_forbidden_pattern_absent "(unverified)" "unverified escape hatch" || OVERALL_RESULT=1
```

The SC ID comment convention is now a REQUIREMENT, not a convention. Every enforcement test that verifies a spec success criterion MUST include a `# SC-N:` comment prefix identifying which SC it covers.

Content-verification tests (checking rule text existence) are SECONDARY — they supplement behavioral tests but MUST NOT be the only enforcement for behavioral rule changes.

**Spec Success Criteria tables MUST include an Evidence Type column** declaring the evidence type for each SC:

```
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | SKILL.md routes only to Trigger Dispatch Table | `string + semantic` | grep + sub-agent read |
| SC-14 | Agent dispatches sub-agents, no inline work | `behavioral` | `opencode run` → stderr assertions |
```

The Evidence Type column is MANDATORY in all spec success criteria tables. Specs missing the Evidence Type column fail the spec-audit SC-DET check with a warning (not a block) until updated.

### RED-Phase Ordering (BEHAVIORAL PRIMARY) — MANDATORY

The BEHAVIORAL enforcement test for each SC MUST exist and FAIL before implementation of that SC begins. This is the behavioral TDD cycle:

1. **RED**: Write the BEHAVIORAL enforcement test that verifies the SC (send a prompt, assert the agent follows the rule — test fails because the change doesn't exist yet)
2. **GREEN**: Implement the change that makes the agent follow the rule
3. **REFACTOR**: Verify content-verification also passes; clean up test scenarios
4. **COMMIT**: Both the behavioral test and the change committed together

Writing behavioral tests AFTER implementation means the test was never RED — it never caught the gap between the rule and the agent's behavior. The #1217 root cause was exactly this: the agent had correct rule text (passed content-verification) but did not follow the rule in practice (would have failed behavioral verification).

If SC-to-test traceability is missing any behavioral test for any SC, or if behavioral test assertions were written after implementation (GREEN-without-RED), implementation MUST NOT proceed until the behavioral tests are added and shown to fail first.

## Behavioral RED/GREEN as Primary Enforcement Gate

Content-verification tests (grep for text presence) are SECONDARY. Behavioral tests (verify agent behavior changes) are PRIMARY. This hierarchy is enforced at every workflow step where rule changes are made or approved.

### The Behavioral RED/GREEN Gate

The TDD RED/GREEN cycle for rule changes MUST use behavioral enforcement tests, not just content-verification tests:

1. **RED phase**: Write a behavioral enforcement test that sends the agent a prompt and verifies the agent does NOT follow the new rule yet. The test MUST FAIL at this point because the rule change hasn't been made. Use assertion helpers from `.opencode/tests-v2/behaviors/helpers.sh` (`assert_tool_calls_made`, `assert_forbidden_pattern_absent`, `assert_required_pattern_present`, `assert_skill_called`, `assert_stderr_pattern_present`, `assert_stderr_pattern_absent`, `assert_stderr_pattern_present_all_models`, `assert_stderr_pattern_absent_all_models`).
2. **GREEN phase**: Make the guideline/rule change and re-run the behavioral test. The test MUST PASS because the agent now follows the rule.
3. **No exceptions**: This gate applies to ALL rule changes — guideline files, skill files, task files, critical violation sections, system prompt blocks.

### 🚫 PROHIBITED (for behavioral rule changes)

- Content-verification tests (grep patterns) as the ONLY enforcement for a behavioral rule change
- Marking a rule change as "tested" when only text presence was verified — the agent having correct rule text does NOT prove it follows the rule
- Writing behavioral tests AFTER implementation (GREEN-without-RED) — the test must be RED first, then GREEN
- Bypassing the behavioral gate because a content-verification test already exists for the same rule
- Claiming a rule is "enforced" based solely on content-verification without behavioral evidence

### ✅ REQUIRED (for behavioral rule changes)

- Every critical violation change MUST have at least one behavioral test verifying the agent follows the new rule
- Behavioral tests are PRIMARY — they prove the agent's behavior actually changed
- Content-verification tests are SECONDARY — they confirm rule text exists but do NOT prove agent compliance
- Add the behavioral test FIRST (RED), then make the change (GREEN) — behavioral TDD for rules
- The behavioral RED/GREEN gate is enforced at every workflow step: spec creation, plan creation, plan execution, and approval gate

### Root Case

Bug #1217 demonstrated that the agent had all the correct guideline text about verification but still answered a general knowledge question with zero tool-call verification. Content-verification alone was insufficient — the agent behavior did not match the rule text. This is why behavioral tests are PRIMARY: they verify that the agent actually behaves differently, not just that the rule text exists.

## Test Integrity Mandate — No Lobotomizing Tests

**Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is the most expensive defect you can introduce. A lobotomized test passes by removing the signal it was designed to verify — producing a false PASS that masks a real defect. This is equivalent to soft-passing a verification mismatch (already prohibited by §Evidence Type Taxonomy and [§critical-rules-020](.opencode/guidelines/000-critical-rules.md)).**

### Rule 1: No Lobotomizing Tests — ZERO TOLERANCE

Removing or weakening a behavioral (semantic, functional) test assertion to work around a timeout, failure, or infrastructure issue is a **CRITICAL VIOLATION**.

**Prohibited patterns:**
- Removing the clean-room sub-agent evaluation of `session.yaml` because the evaluation model times out
- Replacing a `behavioral` evidence type with `string` or `structural` to "fix" a failing test
- Removing an assertion entirely because it "flakes" or "hangs"
- Commenting out an assertion with `# TODO: fix later`
- Replacing the clean-room sub-agent evaluation of `session.yaml` with `assert_stderr_pattern_present` because "it's faster"
- Skipping a behavioral SC entirely — claiming it is "not applicable", "out of scope for this change", "too complex for this change", "will be handled separately", or any equivalent rationalization

**The only valid remediation cycle:**
1. **Increase timeout** — `BEHAVIOR_TIMEOUT`, `BEHAVIOR_SEMANTIC_TIMEOUT`, or `BEHAVIOR_MAX_RETRIES`
2. **Inspect stdout** — Read `$BEHAVIOR_STDOUT` or `$log_dir/stdout.log` to understand what the agent actually produced
3. **Inspect stderr** — Read `$BEHAVIOR_STDERR` or `$log_dir/stderr.log` to understand tool dispatch and errors
4. **Diagnose root cause** — Determine if the issue is: infrastructure (model load time, network latency, GPU memory), test harness (test repo setup, model config seeding), or test spec (prompt too complex, assertion too broad)
5. **Remediate** — Fix the root cause: increase timeout, fix model config, adjust prompt specificity, add retry logic
6. **Repeat** — Re-run the test after remediation
7. **Escalate** — Only after multiple remediation cycles have genuinely failed

**Escalation is the LAST resort, not the first. Proceeding past a FAIL is never legitimate — it is always cheaper to diagnose and fix than to hide the defect.**

### Rule 2: Timeout Is Always Diagnosable — Never Assume Model Unavailability

When a behavioral test times out, the agent MUST:
1. Inspect `stdout.log` and `stderr.log` from the test run
2. Run `opencode models` to verify model availability — never assume unavailability from memory or training data
3. Run a direct `with-test-home opencode run "test ping" --model <model>` to verify the model works
4. Report the actual root cause (timeout duration, model load time, network latency, etc.)

**Never claim "model not available" or "model timed out" without tool-call evidence.** This is already covered by `065-verification-honesty.md` but the pattern keeps recurring in behavioral test contexts, so this rule cannonizes it specifically for the test integrity domain.

### Rule 3: Research Sub-Agents for Test Infrastructure Problems

When the remediation cycle (increase timeout → inspect output → diagnose → fix) fails to resolve the issue after 2+ attempts, the agent MUST dispatch a research sub-agent to investigate known solutions for:
- LLM inference timeouts in CI environments
- `opencode run` timeout patterns and mitigation
- Model loading latency in test environments
- Behavioral test harness reliability patterns

This research is mandatory — the agent MUST NOT give up on a behavioral test and proceed past a FAIL. Research, remediate, and repeat is the only valid cycle.

### Rule 5: Agent Output MUST Be Verified by Clean-Room Semantic Inspection — NEVER by grep/string on Prose

**Agent output (stdout + stderr) is LLM-generated English prose. grep/string assertions on LLM prose are string evidence, which is EVIDENCE_TYPE_MISMATCH for behavioral SCs.**

Behavioral SCs require behavioral evidence. Behavioral evidence means a **clean-room sub-agent** (the semantic inspector) evaluates the full agent output and renders a PASS/FAIL judgment. The inspector is a different model reading the output cold — no context preloading, no orchestrator hints, no cached results. This is the only valid form of behavioral verification for agent output.

#### What Each Assertion Type Actually Verifies

| Assertion | Evidence Type | What It Checks | When It's Sufficient |
|-----------|--------------|----------------|----------------------|
| Clean-room sub-agent evaluation of `session.yaml` | behavioral | Sub-agent reads the behavioral test's `session.yaml` and judges full agent output for ACTIONS and DECISIONS | PRIMARY — always sufficient for behavioral SCs |
| `assert_stderr_pattern_present/absent` on tool calls | string (acceptable for structural checks only) | grep matches raw tool-call strings in stderr (e.g., `Skill "approval-gate"`, `git checkout -b`) | ONLY for verifying tool dispatches occurred/didn't occur — NEVER for judging agent reasoning |
| `assert_forbidden_pattern_absent` | string | grep matches forbidden text patterns in agent prose | ONLY for detecting prohibited output patterns (e.g., `(unverified)` tags, solicitation phrases) — NEVER for judging agent decisions or approach |
| `assert_required_pattern_present` | string | grep matches required text in agent prose | ONLY for detecting required output patterns (e.g., byline presence) — NEVER for judging agent reasoning or approach |

#### The Hard Rule

**For any SC that requires verifying the agent TOOK THE RIGHT ACTION or MADE THE RIGHT DECISION (e.g., "agent creates 1 branch, not 2", "agent dispatches the correct skill", "agent follows stacked PR strategy"), the ONLY sufficient evidence is orchestrator-dispatched clean-room sub-agent evaluation reading `session.yaml`. grep/string assertions on agent output are EVIDENCE_TYPE_MISMATCH for behavioral SCs.**

This means:

- 🚫 FORBIDDEN: `assert_stderr_pattern_present "Skill.*approval-gate"` as primary evidence for "agent verified authorization scope" — this is string evidence, not behavioral
- 🚫 FORBIDDEN: `assert_stderr_pattern_absent "create_branch.*feature"` as primary evidence for "agent did not create multiple branches" — this is string evidence, not behavioral
- 🚫 FORBIDDEN: `assert_required_pattern_present "stacked"` in agent prose as primary evidence for "agent chose stacked approach" — this is string evidence on prose, the weakest form
- ✅ REQUIRED: dispatch a clean-room sub-agent to read `session.yaml` and judge whether the agent dispatched the approval-gate skill and created exactly ONE feature branch for both issues together — clean-room sub-agent evaluation of full output
- ✅ ACCEPTABLE: `assert_stderr_pattern_present 'Skill "approval-gate"'` as SECONDARY structural corroboration — confirms tool dispatch occurred, but does NOT verify the agent's decision or approach

#### Why This Matters

LLM output is non-deterministic. The exact strings the agent produces change on every run. grep patterns that match today break tomorrow. A semantic inspector evaluates the *meaning* of the output, not the *strings*. This is the same distinction as the Evidence Type Taxonomy: `behavioral` > `semantic` > `string` > `structural`. Using string evidence where behavioral is required is EVIDENCE_TYPE_MISMATCH — a hard FAIL.

### Rule 4: FAIL Is a Hard Gate — Never Proceed Past FAIL

This reinforces [§critical-rules-hard-fail](.opencode/guidelines/000-critical-rules.md) for the behavioral testing context specifically:

**A behavioral test that FAILS is a hard gate. The agent MUST NOT:**
- Proceed to the next task or pipeline stage
- Mark the test as "PASS with caveats" or "functionally equivalent"
- Report the test as "INCONCLUSIVE" without exhausting remediation first
- Treat INCONCLUSIVE as anything other than a FAIL that needs more remediation
- Remove or weaken the assertion that produced the FAIL

**The only valid outcomes:**
- **PASS** — all assertions pass with genuine behavioral evidence
- **FAIL** — one or more assertions fail; remediate and re-run
- **INCONCLUSIVE after exhaustive remediation** — escalate; do NOT proceed

### Rule 6: "Artifact Generated" Is NOT a Valid PASS Verdict for Behavioral SCs

**Reporting "artifact generated" as a PASS verdict for a behavioral SC is EVIDENCE_TYPE_MISMATCH — a hard FAIL.**

Behavioral test artifacts (stdout.log, stderr.log, session.yaml) are raw output from `behavior_run`. Their existence proves the test ran, NOT that the agent's behavior matched the SC criterion. Evaluating artifacts requires a clean-room sub-agent that reads the artifacts and judges whether the agent's actions and decisions satisfy the SC.

**Prohibited patterns:**
- Reporting "✅ Artifact generated" as a PASS verdict for a behavioral SC
- Reporting "Artifacts exist" as evidence of behavioral compliance
- Using file existence (structural evidence) as a substitute for clean-room evaluation
- Skipping clean-room evaluation because "the artifacts look correct"

**Required pattern:**
1. After `behavior_run` produces artifacts, dispatch `behavioral-test-evaluation` from `verification-before-completion`
2. The evaluation task dispatches clean-room sub-agents to read artifacts and produce PASS/FAIL per SC
3. Only after clean-room evaluation returns PASS for all behavioral SCs may the agent report PASS
4. "Artifact generated" is NEVER a valid PASS verdict — only clean-room evaluation counts

## Provenance

Derived from [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry) (MIT).


