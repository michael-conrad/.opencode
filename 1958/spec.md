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

| # | Verb | Directive Text Template | Checkbox Variant | Rationale | Source |
|---|------|------------------------|------------------|-----------|--------|
| 1 | Read | `Read [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Read [the authorization token list](tmp/verb-test/target-a.md).` | Current form — baseline | OpenCode convention |
| 2 | Load | `Load [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Load [the authorization token list](tmp/verb-test/target-a.md).` | Common programming term | Hypothesis |
| 3 | Fetch | `Fetch [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Fetch [the authorization token list](tmp/verb-test/target-a.md).` | Implies retrieval action | Hypothesis |
| 4 | Consult | `Consult [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Consult [the authorization token list](tmp/verb-test/target-a.md).` | Suggests reference lookup | Hypothesis |
| 5 | Open | `Open [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Open [the authorization token list](tmp/verb-test/target-a.md).` | Direct file operation verb | Hypothesis |
| 6 | Retrieve | `Retrieve [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Retrieve [the authorization token list](tmp/verb-test/target-a.md).` | Formal retrieval term | Hypothesis |
| 7 | Access | `Access [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Access [the authorization token list](tmp/verb-test/target-a.md).` | Implies reaching a resource | Hypothesis |
| 8 | Follow instructions in | `Follow instructions in [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Follow instructions in [the authorization token list](tmp/verb-test/target-a.md).` | Multi-word directive | Hypothesis |
| 9 | Check | `Check [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Check [the authorization token list](tmp/verb-test/target-a.md).` | Common verification verb | Hypothesis |
| 10 | Look up | `Look up [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] Look up [the authorization token list](tmp/verb-test/target-a.md).` | Common reference verb | Hypothesis |
| 11 | MUST read | `You MUST read [the authorization token list](tmp/verb-test/target-a.md).` | `- [ ] You MUST read [the authorization token list](tmp/verb-test/target-a.md).` | OpenAI Codex-style imperative | OpenAI Codex AGENTS.md spec |
| 12 | See @ | `See @tmp/verb-test/target-a.md` | `- [ ] See @tmp/verb-test/target-a.md` | Amp-style @-mention | Amp AGENTS.md docs |
| 13 | (none — checkbox only) | — | `- [ ] [the authorization token list](tmp/verb-test/target-a.md).` | Tests whether checkbox alone (no verb) triggers read | Hypothesis |

**Note on #12 (See @):** The `See [file]` pattern without `@` is documented as defective — agents treat it as a citation to ignore. The `@` prefix from Amp's system is included to test whether the `@` symbol changes behavior. If `@` is not supported by the test harness, this variant may be skipped and noted in the test record.

**Note on #13 (checkbox only):** This variant has no imperative verb at all — just a markdown checkbox followed by a link. If this triggers `read` tool calls, it indicates that the checkbox prefix alone is sufficient to make the agent treat the link as an actionable task, regardless of verb choice.

**Checkbox variant rationale:** Markdown task list checkboxes (`- [ ]`) are a common pattern in LLM training data for indicating actionable items. Agents trained on GitHub issues, PRs, and project management data may treat checkbox-prefixed items as tasks to be completed rather than informational text. Testing the checkbox variant for each verb form determines whether the checkbox prefix improves adherence independently of the verb choice.

## Test Methodology

### Test Environment

Each test uses the existing `test-verb-variant.sh` script at `.opencode/tests-v2/behaviors/test-verb-variant.sh` with the following configuration:

- **Test project:** Isolated git repo with `.opencode` submodule cloned from remote
- **Guideline:** A test guideline (`999-verb-test.md`) is injected with the verb form under test, referencing two target files via the directive
- **Target files:** `tmp/verb-test/target-a.md` (authorization tokens) and `tmp/verb-test/target-b.md` (tool usage rules)
- **Prompt:** A real-domain task asking the agent to verify authorization using the token list and determine the correct path protocol — this triggers natural agent behavior, not prose recall
- **Directive injection:** The verb directive is also injected into a local copy of `default.txt` to simulate the production guideline context

### Multi-Model Test Matrix

Each verb form MUST be tested against ALL of the following models to account for model-specific behavior differences:

> **⚠️ No parallel tasking.** Only one model can be loaded into GPU memory at a time. Tests MUST be run sequentially per model — complete all verb tests for one model before switching to the next.
>
> **⚠️ Preflight warmup required on model switch.** When switching to a different model, a preflight warmup run MUST be completed and verified before recording any timing data. The warmup run loads the model into GPU memory and stabilizes inference latency. Timing data from the warmup run MUST be discarded — only timing from post-warmup runs is valid.
>
> **⚠️ Timing gate.** Timing for each test run MUST only be recorded after the preflight warmup is verified (model loaded, first inference completed without errors). Pre-warmup timing is invalid and MUST NOT be included in the test record.

| Model | Size | Type | Rationale |
|-------|------|------|----------|
| `ollama/qwen3.6:35b-256k` | 35B / 256k ctx | Local (default) | Default test model; baseline for all comparisons |
| `ollama/laguna-xs-2.1:q4_K_M-256k` | ~20B / 256k ctx | Local (quantized) | Tests whether quantized models behave differently |
| `ollama/gpt-oss:20b-128k` | 20B / 128k ctx | Local | Smaller model; tests whether model size affects adherence |
| `ollama/ornith:35b-256k` | 35B / 256k ctx | Local | Alternative 35B model; tests whether model architecture affects adherence |

Each verb form has TWO variants: plain directive text and checkbox-prefixed directive text (`- [ ]` prefix). Additionally, a checkbox-only variant (#13) tests whether the checkbox alone (no verb) triggers read. This produces a 4 (models) × 13 (verb forms) × 2 (plain/checkbox) × 2 (runs) = **208 total test runs** minimum for the orchestrator context alone, plus the same for sub-agent context = **416 total test runs** minimum across all combinations.

### Agent Context Test Matrix

Each verb+model combination MUST be tested in TWO agent contexts to determine whether the orchestrator and sub-agents behave differently:

| Context | How Tested | What It Simulates |
|---------|-----------|-------------------|
| **Orchestrator** | `opencode run` with the verb directive injected into `default.txt` (the system prompt) | The orchestrator receives the directive as part of its initial system prompt — tests whether the directive is followed when pre-loaded |
| **Sub-agent** | `opencode run` with the verb directive in a Tier 2 guideline file (loaded on-demand via `load_when: sub-agent`) | The sub-agent encounters the directive when loading a guideline during task execution — tests whether the directive is followed when discovered dynamically |

**Rationale:** If sub-agents read the cross-references but the orchestrator does not, this indicates a possible defect in the orchestrator's system prompt injection — the orchestrator may be receiving only relevant portions of the injected prompts, or the Tier 1 pre-loading may suppress the directive. If the orchestrator reads but sub-agents do not, the issue is in how guidelines are loaded for sub-agents.

**Test procedure for sub-agent context:** The verb directive is placed ONLY in the Tier 2 test guideline (`999-verb-test.md`), NOT in `default.txt`. The prompt triggers the guideline's `trigger_on` pattern, causing the orchestrator to dispatch a sub-agent. The sub-agent loads the guideline, encounters the verb directive, and should follow it. The test checks whether the sub-agent's stderr shows `read` tool calls to the target files.

**Test procedure for orchestrator context:** The verb directive is placed in `default.txt` (the system prompt). The prompt does NOT need to trigger a guideline — the directive is already in the orchestrator's context. The test checks whether the orchestrator's stderr shows `read` tool calls to the target files.

### Adherence Rate Threshold and Remediation

If the adherence rate across all verb+model+context combinations is **low (≤ 25%) or zero**, the following remediation steps MUST be taken:

1. **Research additional verb forms** — search for verb forms and link description text wordings used in production LLM systems that may produce better adherence. Document findings in `.issues/research-cards/imperative-verb-forms-load-directives.md`.
2. **Research link description text wording** — test variations of the link description text (e.g., "the authorization token list" vs "the file containing authorization tokens" vs "the rules in this file") to determine whether description text affects adherence.
3. **Test emphasis markers** — test with emphasis markers (e.g., `**IMPORTANT**: Read [file]`, `⚠️ You MUST read [file]`) to determine whether emphasis improves adherence.
4. **Test position effects** — test whether placing the directive at the top vs bottom of the guideline affects adherence.
5. **Test repetition** — test whether repeating the directive multiple times in the same guideline improves adherence.
6. **Document all findings** in `.opencode/.issues/1958/winning-verb-analysis.md` with recommendations for the next iteration.

### What "Works" Means

A verb form is considered to "work" when ALL of the following conditions are met:

1. **Agent loads the referenced file content into context using ANY available tool** — the agent may use the `read` tool, the editor MCP `read_file` tool, or any other tool that retrieves file content. The stderr log MUST contain evidence of a file-loading tool call targeting the exact file path (e.g., `tmp/verb-test/target-a.md`). The agent is NOT required to use the `read` tool specifically — it may choose any tool that accomplishes the same goal.
2. **Agent does NOT use grep/search as a substitute** — the stderr log MUST NOT show `grep` or `search` tool calls targeting the same content. Grep/search is a discovery mechanism, not a file-loading mechanism.
3. **Agent does NOT rely on pre-loaded context to answer** — the agent MUST NOT answer the prompt correctly without having read the target files (verified by checking that the answer contains content only available in the target files)

### Test Record Format

Each test run produces a row in the test record table:

| Verb | Variant (plain/checkbox) | Model | Context (orch/sub) | Warmup run? | Did agent load target file? | Tool used | Did agent use grep/search instead? | Time (post-warmup) | Notes |

The `Warmup run?` column indicates whether this run is a preflight warmup (timing discarded) or a recorded test run. Only runs marked `No` in this column have valid timing data.

### Test Execution

Each verb variant MUST be tested at least 2 times to account for model non-determinism. A verb is classified as "reliable" if it triggers `read` in at least 2 out of 2 runs.

### Test Script Modifications

The existing `test-verb-variant.sh` script MUST be used as-is for the first test run. If modifications are needed (e.g., to improve stderr parsing, add additional target files, or change the prompt), those modifications MUST be documented in the test record.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 13 candidate verb forms (12 verbs + 1 checkbox-only) are tested in BOTH plain and checkbox-prefixed variants, at least 2 times each, against ALL 4 models (`qwen3.6:35b-256k`, `laguna-xs-2.1:q4_K_M-256k`, `gpt-oss:20b-128k`, `ornith:35b-256k`) | behavioral | Run `test-verb-variant.sh` for each verb×model×variant combination 2 times; verify 208 runs completed for orchestrator context | Re-run any missing variant runs | test-execution | `.opencode/.issues/1958/` | Candidate Verb List, Multi-Model Test Matrix, Checkbox Variant | Phase 1 | pre-commit | sequential | — | — | `test-verb-variant.sh` | Phase 1 |
| SC-2 | Each verb+model combination is tested in BOTH orchestrator context (directive in `default.txt`) and sub-agent context (directive in Tier 2 guideline) | behavioral | Verify test record has separate rows for orchestrator and sub-agent contexts for each combination | Re-run missing context tests | test-execution | `.opencode/.issues/1958/` | Agent Context Test Matrix | Phase 1 | pre-commit | sequential | — | — | `test-verb-variant.sh` | Phase 1 |
| SC-3 | A test record table is produced with columns: Verb, Directive text, Model, Context (orchestrator/sub-agent), Did agent call read on target file?, Did agent use grep/search instead?, Did agent use other tool?, Time, Notes | string | Verify the table exists in `.opencode/.issues/1958/test-record.md` with all 12 verbs × 4 models × 2 contexts × 2 runs = 192 rows | Re-generate table from raw test artifacts | documentation | `.opencode/.issues/1958/test-record.md` | Test Record Format | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-4 | Each test run produces behavioral evidence artifacts (stdout.log, stderr.log, manifest.yaml, exit_code) in `tmp/behavioral-evidence-*/` | structural | Verify artifact directory exists for each of the 192 runs | Re-run failed runs | test-execution | `tmp/behavioral-evidence-*/` | Test Methodology | Phase 1 | pre-commit | sequential | — | — | `test-verb-variant.sh` | Phase 1 |
| SC-5 | A winning verb form is identified based on the criterion: triggers file-loading (any tool) in at least 2 out of 2 runs per model, does NOT trigger grep/search substitute | behavioral | Analyze test record table; select verb with highest file-loading call rate and zero grep/search substitution across all models and contexts | If no verb meets criterion, document the best performer and note the gap | analysis | `.opencode/.issues/1958/winning-verb-analysis.md` | What "Works" Means | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-6 | If adherence rate across all combinations is ≤ 25% or zero, remediation research is conducted: additional verb forms, link description text wording, emphasis markers, position effects, repetition | behavioral | Verify `.opencode/.issues/1958/winning-verb-analysis.md` contains remediation research findings | Conduct remediation research per Adherence Rate Threshold section | analysis | `.opencode/.issues/1958/winning-verb-analysis.md` | Adherence Rate Threshold and Remediation | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-7 | The winning verb form (or best performer) is documented with a recommendation for implementation in guidelines and default.txt, including any context-specific differences (orchestrator vs sub-agent) | string | Verify `.opencode/.issues/1958/winning-verb-analysis.md` contains a recommendation section with context-specific findings | Update recommendation based on additional analysis | documentation | `.opencode/.issues/1958/winning-verb-analysis.md` | Success Criteria | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-8 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | structural | Verify all SCs maintain their declared evidence type throughout implementation | Restore any weakened SC to original evidence type | audit | `.opencode/.issues/1958/` | Anti-Lobotomization | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-9 | Before any implementation, write behavioral enforcement tests in `.opencode/tests-v2/behaviors/` that verify the new rule; confirm RED state (test fails before change) | behavioral | Verify behavioral test script exists and fails before implementation changes are applied | Re-create behavioral test if missing | test-execution | `.opencode/tests-v2/behaviors/` | Behavioral Test Mandate | Phase 1 | pre-approval-gate | sequential | — | — | — | Phase 1 |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Model produces empty output | Retry up to 2 times per `behavior_run` default; record as FAIL if all retries empty |
| Model times out | Increase bash tool timeout to 600000ms; retry per `behavior_run` default |
| Test script needs modification | Document modification in test record; use modified script for remaining runs |
| Verb triggers partial read (reads some but not all target files) | Record as "partial" in Notes column; does not count as full PASS |
| Verb triggers read but also triggers grep/search | Record both; verb is disqualified if grep/search substitutes for read content |
| Model not available (e.g., not installed locally) | Skip that model for all verb tests; note in test record; continue with remaining models |
| Orchestrator and sub-agent produce different results | Record both results separately; flag for analysis in winning verb analysis |
| Adherence rate is zero across all combinations | Trigger remediation research per Adherence Rate Threshold section; do NOT conclude "nothing works" without remediation |

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
