# Phase 01 — Orchestrator Context Tests

## Phase Metadata

- **Concern:** Test all 13 verb forms × 2 variants (plain/checkbox) × 4 models × 2 runs in orchestrator context (directive in `default.txt`)
- **Files:** `.opencode/tests-v2/behaviors/test-verb-variant.sh`, `.opencode/tests-v2/behaviors/helpers.sh`, `.opencode/prompts/default.txt`
- **SCs:** SC-1, SC-3, SC-8, SC-9
- **Dependencies:** None
- **Entry conditions:** Spec approved, branch exists, test harness available
- **Exit conditions:** All 208 orchestrator context runs complete with behavioral evidence artifacts

## Code Path Coverage

- `test-verb-variant.sh` — Full execution path for orchestrator context (directive in `default.txt`)
- `helpers.sh` — `behavior_run`, assertion helpers

## Cross-Cutting SCs

- SC-8 (anti-lobotomization): Applies to all test runs — no SC may be weakened
- SC-9 (behavioral tests RED before implementation): Applies before any implementation changes

## Interface Boundaries

- Test harness interface: `test-verb-variant.sh <verb> <directive_text> <model> <prompt_keyword>`
- Model interface: Ollama API at `localhost:11434`

## State Transitions

- Model loaded → warmup run → recorded test runs → model unloaded → next model
- No parallel state: only one model loaded at a time

## Step-by-step

### Preflight: Behavioral Enforcement Tests (SC-9)

- [ ] 1.1 Write behavioral enforcement test in `.opencode/tests-v2/behaviors/` that verifies the winning verb form triggers `read` tool calls
  - **Dispatch:** `task(subagent_type="general", prompt="execute test-driven-development task from test-driven-development")`
  - **SC:** SC-9
  - **Expected:** Test script exists and fails (RED state) before any implementation changes
  - **Verification:** Run the test script — confirm it fails

### Model 1: `ollama/qwen3.6:35b-256k` — Orchestrator Context

- [ ] 1.2 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `qwen3.6:35b-256k` to load model into GPU memory
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/qwen3.6:35b-256k authorization-token`
  - **SC:** SC-1
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 1.3 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `qwen3.6:35b-256k` in orchestrator context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/qwen3.6:35b-256k authorization-token`
  - **SC:** SC-1, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created in `tmp/behavioral-evidence-*/`
  - **Verification:** Count artifact directories — confirm 52 exist
  - **Note:** Sequential execution — one test at a time, no parallel tasking

### Model 2: `ollama/laguna-xs-2.1:q4_K_M-256k` — Orchestrator Context

- [ ] 1.4 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `laguna-xs-2.1:q4_K_M-256k` to load model into GPU memory
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/laguna-xs-2.1:q4_K_M-256k authorization-token`
  - **SC:** SC-1
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 1.5 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `laguna-xs-2.1:q4_K_M-256k` in orchestrator context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/laguna-xs-2.1:q4_K_M-256k authorization-token`
  - **SC:** SC-1, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist

### Model 3: `ollama/gpt-oss:20b-128k` — Orchestrator Context

- [ ] 1.6 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `gpt-oss:20b-128k` to load model into GPU memory
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/gpt-oss:20b-128k authorization-token`
  - **SC:** SC-1
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 1.7 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `gpt-oss:20b-128k` in orchestrator context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/gpt-oss:20b-128k authorization-token`
  - **SC:** SC-1, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist

### Model 4: `ollama/ornith:35b-256k` — Orchestrator Context

- [ ] 1.8 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `ornith:35b-256k` to load model into GPU memory
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/ornith:35b-256k authorization-token`
  - **SC:** SC-1
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 1.9 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `ornith:35b-256k` in orchestrator context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/ornith:35b-256k authorization-token`
  - **SC:** SC-1, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist

### Phase 1 Completion

- [ ] 1.10 Verify all 208 orchestrator context test runs completed with behavioral evidence artifacts
  - **Dispatch:** Inline — count artifact directories across all 4 models
  - **SC:** SC-3
  - **Expected:** 208 artifact directories exist
  - **Verification:** `ls tmp/behavioral-evidence-*/ | wc -l` — confirm 208

- [ ] 1.11 Verify no SC weakened, deferred, or reclassified
  - **Dispatch:** Inline — audit all SCs against original spec
  - **SC:** SC-8
  - **Expected:** All SCs maintain declared evidence type
  - **Verification:** Compare SC evidence types against spec

- [ ] 1.12 Phase 1 completion block — mark phase complete, transition to Phase 2
  - **Dispatch:** Inline
  - **Expected:** Phase 1 marked complete, Phase 2 entry conditions met

## Phase 1 — Safety/Rollback

- **Destructive operations:** None — test execution is read-only (creates artifacts but does not modify production files)
- **Rollback plan:** N/A
- **Data loss risk:** None

## Concern Transition

Phase 1 completes all orchestrator context tests. Phase 2 repeats the same test matrix in sub-agent context (directive in Tier 2 guideline, not `default.txt`).
