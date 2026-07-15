---
title: Imperative verb forms for cross-reference load directive — systematic comparison
status: draft
created: 2026-07-15
license: MIT
provenance: AI-generated
issue: 1958
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-15

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Problem

The `Read [Text](path)` cross-reference pattern in `.opencode/guidelines/` files is the designated mechanism for directing an AI agent to load referenced content into its context. The pattern appears in `000-critical-rules.md` as the mandatory cross-reference form:

> When agent-facing text references content in another file, the agent MUST use the `Read [Text](path)` pattern. This is an instruction to call the `read` tool on that path.

However, it is unknown which imperative verb form most reliably causes the agent to actually invoke the `read` tool (or any other available tool) on the linked file. The agent may instead:

- Rely on memory or training data to answer without reading
- Use `grep` or `search` as a substitute for `read`
- Use other tools (srclight, glob) instead of reading the file directly
- Ignore the directive entirely

A systematic comparison across candidate verb forms is needed to determine which form produces the most reliable `read` tool invocation.

## Root Cause Analysis

The root cause is that the agent's training data contains many imperative verb forms used in documentation ("see", "refer to", "check", "look at") that do not correspond to tool invocations. The agent has learned to treat these as informational cues rather than actionable directives. The `Read` verb was chosen because it directly names the `read` tool, but no empirical evidence exists that it outperforms alternatives.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Testing only `Read` in isolation | Does not provide comparative data — cannot determine if another form is more effective |
| Testing via human evaluation | Not scalable — requires automated, repeatable methodology |
| Testing all possible verbs | Impractical — 8-10 candidates provides sufficient coverage for a winning form |
| Testing in production guidelines | Risk of agent confusion during testing — isolated test environment required |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1958](https://github.com/michael-conrad/.opencode/issues/1958) | BLOCKS | This spec blocks the follow-up implementation spec for the winning verb form |

## Research Cards

The following research cards were created during the investigation phase and MUST be consulted before implementation:

| Card | Path | Key Findings |
|------|------|-------------|
| Microsoft markdown link patterns | `.issues/research-cards/microsoft-markdown-link-patterns.md` | VS Code uses passive references, not load directives. `Read [Text](path)` is NOT cargo-culted from Microsoft — it's an independent convention. |
| Imperative verb forms for LLM load directives | `.issues/research-cards/imperative-verb-forms-load-directives.md` | No production system uses `Read [Text](path)` except OpenCode. Amp uses `@-mention`. No research exists on verb effectiveness. "See [file]" is documented as defective. |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Local docs | `.opencode/guidelines/000-critical-rules.md` | Understand existing `Read [Text](path)` pattern |
| Local docs | `.opencode/guidelines/INDEX.md` | Understand guideline structure and trigger patterns |
| Local docs | `.opencode/tests-v2/AGENTS.md` | Understand behavioral test harness specification |
| Local docs | `.opencode/tests-v2/behaviors/helpers.sh` | Understand `behavior_run` and assertion helpers |
| Local docs | `.opencode/tests-v2/behaviors/test-verb-variant.sh` | Understand existing verb test script |
| Local docs | `.opencode/tests-v2/default-model.sh` | Confirm default model is `ollama/qwen3.6:35b-256k` |
| Local docs | `.opencode/prompts/default.txt` | Understand where directives are injected |
| Research card | `.issues/research-cards/microsoft-markdown-link-patterns.md` | Microsoft's passive reference pattern vs OpenCode's active load directive |
| Research card | `.issues/research-cards/imperative-verb-forms-load-directives.md` | Candidate verb forms, production system patterns, known defective patterns |
| Web | VS Code prompt files docs | Microsoft's documented markdown link pattern |
| Web | Amp AGENTS.md docs | `@-mention` syntax for file references |
| Web | OpenAI Codex AGENTS.md spec | Imperative "MUST" language for agent instructions |
| Web | Anthropic CLAUDE.md best practices | Emphasis markers and native auto-loading |
| Web | Future AGI prompt best practices | Instruction-first ordering, constraint pinning |
| Web | Agent Patterns documentation | 9-section structure for agent prompts |
| Web | Paxrel AI agent prompt patterns | 10 patterns for AI agent prompts |
| Web | arxiv papers (Arbiter, Prompt Template Analysis) | Academic context for prompt engineering |

## Candidate Verb List

The following 12 imperative verb forms MUST be tested. The list was derived from research findings (see Research Cards section) and includes the current form, alternatives from production systems, and hypotheses:

| # | Verb | Directive Text Template | Rationale | Source |
|---|------|------------------------|-----------|--------|
| 1 | Read | `Read [the authorization token list](tmp/verb-test/target-a.md).` | Current form — baseline | OpenCode convention |
| 2 | Load | `Load [the authorization token list](tmp/verb-test/target-a.md).` | Common programming term | Hypothesis |
| 3 | Fetch | `Fetch [the authorization token list](tmp/verb-test/target-a.md).` | Implies retrieval action | Hypothesis |
| 4 | Consult | `Consult [the authorization token list](tmp/verb-test/target-a.md).` | Suggests reference lookup | Hypothesis |
| 5 | Open | `Open [the authorization token list](tmp/verb-test/target-a.md).` | Direct file operation verb | Hypothesis |
| 6 | Retrieve | `Retrieve [the authorization token list](tmp/verb-test/target-a.md).` | Formal retrieval term | Hypothesis |
| 7 | Access | `Access [the authorization token list](tmp/verb-test/target-a.md).` | Implies reaching a resource | Hypothesis |
| 8 | Follow instructions in | `Follow instructions in [the authorization token list](tmp/verb-test/target-a.md).` | Multi-word directive | Hypothesis |
| 9 | Check | `Check [the authorization token list](tmp/verb-test/target-a.md).` | Common verification verb | Hypothesis |
| 10 | Look up | `Look up [the authorization token list](tmp/verb-test/target-a.md).` | Common reference verb | Hypothesis |
| 11 | MUST read | `You MUST read [the authorization token list](tmp/verb-test/target-a.md).` | OpenAI Codex-style imperative | OpenAI Codex AGENTS.md spec |
| 12 | See @ | `See @tmp/verb-test/target-a.md` | Amp-style @-mention | Amp AGENTS.md docs |

**Note on #12 (See @):** The `See [file]` pattern without `@` is documented as defective — agents treat it as a citation to ignore. The `@` prefix from Amp's system is included to test whether the `@` symbol changes behavior. If `@` is not supported by the test harness, this variant may be skipped and noted in the test record.

## Test Methodology

### Test Environment

Each test uses the existing `test-verb-variant.sh` script at `.opencode/tests-v2/behaviors/test-verb-variant.sh` with the following configuration:

- **Model:** `ollama/qwen3.6:35b-256k` (the default model from `default-model.sh`)
- **Test project:** Isolated git repo with `.opencode` submodule cloned from remote
- **Guideline:** A test guideline (`999-verb-test.md`) is injected with the verb form under test, referencing two target files via the directive
- **Target files:** `tmp/verb-test/target-a.md` (authorization tokens) and `tmp/verb-test/target-b.md` (tool usage rules)
- **Prompt:** A real-domain task asking the agent to verify authorization using the token list and determine the correct path protocol — this triggers natural agent behavior, not prose recall
- **Directive injection:** The verb directive is also injected into a local copy of `default.txt` to simulate the production guideline context

### What "Works" Means

A verb form is considered to "work" when ALL of the following conditions are met:

1. **Agent calls `read` tool on the referenced file path** — the stderr log MUST contain evidence of a `read` tool call targeting the exact file path (e.g., `tmp/verb-test/target-a.md`)
2. **Agent does NOT use grep/search as a substitute** — the stderr log MUST NOT show `grep` or `search` tool calls targeting the same content
3. **Agent does NOT rely on pre-loaded context to answer** — the agent MUST NOT answer the prompt correctly without having read the target files (verified by checking that the answer contains content only available in the target files)

### Test Record Format

Each test run produces a row in the test record table:

| Verb | Directive text | Model | Did agent call read on target file? | Did agent use grep/search instead? | Did agent use other tool? | Time | Notes |

### Test Execution

Each verb variant MUST be tested at least 2 times to account for model non-determinism. A verb is classified as "reliable" if it triggers `read` in at least 2 out of 2 runs.

### Test Script Modifications

The existing `test-verb-variant.sh` script MUST be used as-is for the first test run. If modifications are needed (e.g., to improve stderr parsing, add additional target files, or change the prompt), those modifications MUST be documented in the test record.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 10 candidate verb forms are tested at least 2 times each against model `ollama/qwen3.6:35b-256k` | Run `test-verb-variant.sh` for each verb variant 2 times; verify 20 total runs completed | Re-run any missing variant runs | test-execution | `.opencode/.issues/1958/` | Candidate Verb List | Phase 1 | pre-commit | sequential | — | — | `test-verb-variant.sh` | Phase 1 |
| SC-2 | A test record table is produced with columns: Verb, Directive text, Model, Did agent call read on target file?, Did agent use grep/search instead?, Did agent use other tool?, Time, Notes | Verify the table exists in `.opencode/.issues/1958/test-record.md` with all 10 verbs and 20 rows | Re-generate table from raw test artifacts | documentation | `.opencode/.issues/1958/test-record.md` | Test Record Format | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-3 | Each test run produces behavioral evidence artifacts (stdout.log, stderr.log, manifest.yaml, exit_code) in `tmp/behavioral-evidence-*/` | Verify artifact directory exists for each of the 20 runs | Re-run failed runs | test-execution | `tmp/behavioral-evidence-*/` | Test Methodology | Phase 1 | pre-commit | sequential | — | — | `test-verb-variant.sh` | Phase 1 |
| SC-4 | A winning verb form is identified based on the criterion: triggers `read` in at least 2 out of 2 runs, does NOT trigger grep/search substitute | Analyze test record table; select verb with highest `read` call rate and zero grep/search substitution | If no verb meets criterion, document the best performer and note the gap | analysis | `.opencode/.issues/1958/winning-verb-analysis.md` | What "Works" Means | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-5 | The winning verb form is documented with a recommendation for implementation in guidelines and default.txt | Verify `.opencode/.issues/1958/winning-verb-analysis.md` contains a recommendation section | Update recommendation based on additional analysis | documentation | `.opencode/.issues/1958/winning-verb-analysis.md` | Success Criteria | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-6 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Verify all SCs maintain their declared evidence type throughout implementation | Restore any weakened SC to original evidence type | audit | `.opencode/.issues/1958/` | Anti-Lobotomization | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-7 | Before any implementation, write behavioral enforcement tests in `.opencode/tests-v2/behaviors/` that verify the new rule; confirm RED state (test fails before change) | Verify behavioral test script exists and fails before implementation changes are applied | Re-create behavioral test if missing | test-execution | `.opencode/tests-v2/behaviors/` | Behavioral Test Mandate | Phase 1 | pre-approval-gate | sequential | — | — | — | Phase 1 |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Model produces empty output | Retry up to 2 times per `behavior_run` default; record as FAIL if all retries empty |
| Model times out | Increase bash tool timeout to 600000ms; retry per `behavior_run` default |
| Test script needs modification | Document modification in test record; use modified script for remaining runs |
| Verb triggers partial read (reads some but not all target files) | Record as "partial" in Notes column; does not count as full PASS |
| Verb triggers read but also triggers grep/search | Record both; verb is disqualified if grep/search substitutes for read content |

## Implementation Approach

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1958/plan.md` before implementation begins.

The implementation plan MUST:

1. Use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form for every dispatch step
2. NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards
3. Enumerate the full implementation pipeline with no skipped or combined steps: coherence gate, pre-red-baseline, RED/GREEN per item, VbC, audit, cross-validate, regression check, finishing checklist, review-prep, cleanup
4. Reference the correct skill/task combination for each step

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use existing `test-verb-variant.sh` as test harness | Avoids reinventing test infrastructure; script already handles model invocation, artifact collection, and test project setup | MUST | SC-1, SC-3 |
| DEC-2 | Test each verb 2 times minimum | Model output is non-deterministic; single-run results are unreliable | MUST | SC-1 |
| DEC-3 | Default model is `ollama/qwen3.6:35b-256k` | Specified in requirements; matches `default-model.sh` | MUST | SC-1 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Model behavior varies across runs | High | Medium | Test each verb 2 times; use majority vote | SC-1 |
| RISK-2 | Test script needs modification | Medium | Low | Document modifications; use modified script | SC-1 |
| RISK-3 | No verb reliably triggers `read` | Medium | High | Document best performer; consider alternative approaches | SC-4 |
| RISK-4 | Model unavailable during testing | Low | High | Retry with increased timeout; use alternative model if specified | SC-3 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Test record table | MUST | Regenerate if candidate list changes |
| Winning verb analysis | MUST | Re-analyze if test methodology changes |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
