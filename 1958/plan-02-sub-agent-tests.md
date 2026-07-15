# Phase 02 — Sub-agent Context Tests

## Phase Metadata

- **Concern:** Test all 13 verb forms × 2 variants (plain/checkbox) × 4 models × 2 runs in sub-agent context (directive in Tier 2 guideline, NOT in `default.txt`)
- **Files:** `.opencode/tests-v2/behaviors/test-verb-variant.sh`, `.opencode/tests-v2/behaviors/helpers.sh`, `.opencode/guidelines/999-verb-test.md`
- **SCs:** SC-2, SC-3, SC-8
- **Dependencies:** Phase 1 complete (all 208 orchestrator context runs verified)
- **Entry conditions:** Phase 1 exit criteria met, all 4 models available
- **Exit conditions:** All 208 sub-agent context runs complete with behavioral evidence artifacts

## Code Path Coverage

- `test-verb-variant.sh` — Full execution path for sub-agent context (directive in Tier 2 guideline, `load_when: sub-agent`)
- `helpers.sh` — `behavior_run`, assertion helpers

## Cross-Cutting SCs

- SC-8 (anti-lobotomization): Applies to all test runs

## Interface Boundaries

- Test harness interface: `test-verb-variant.sh <verb> <directive_text> <model> <prompt_keyword>`
- Model interface: Ollama API at `localhost:11434`
- Guideline loading: Tier 2 guideline `999-verb-test.md` with `load_when: sub-agent`

## State Transitions

- Model loaded → warmup run → recorded test runs → model unloaded → next model
- No parallel state: only one model loaded at a time

## Step-by-step

### Model 1: `ollama/qwen3.6:35b-256k` — Sub-agent Context

- [ ] 2.1 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `qwen3.6:35b-256k` in sub-agent context
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/qwen3.6:35b-256k authorization-token`
  - **SC:** SC-2
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded. The directive is in the Tier 2 guideline, not `default.txt`.

- [ ] 2.2 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `qwen3.6:35b-256k` in sub-agent context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/qwen3.6:35b-256k authorization-token`
  - **SC:** SC-2, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist
  - **Note:** Sequential execution — one test at a time, no parallel tasking

### Model 2: `ollama/laguna-xs-2.1:q4_K_M-256k` — Sub-agent Context

- [ ] 2.3 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `laguna-xs-2.1:q4_K_M-256k` in sub-agent context
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/laguna-xs-2.1:q4_K_M-256k authorization-token`
  - **SC:** SC-2
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 2.4 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `laguna-xs-2.1:q4_K_M-256k` in sub-agent context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/laguna-xs-2.1:q4_K_M-256k authorization-token`
  - **SC:** SC-2, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist

### Model 3: `ollama/gpt-oss:20b-128k` — Sub-agent Context

- [ ] 2.5 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `gpt-oss:20b-128k` in sub-agent context
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/gpt-oss:20b-128k authorization-token`
  - **SC:** SC-2
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 2.6 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `gpt-oss:20b-128k` in sub-agent context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/gpt-oss:20b-128k authorization-token`
  - **SC:** SC-2, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist

### Model 4: `ollama/ornith:35b-256k` — Sub-agent Context

- [ ] 2.7 Preflight warmup: Run `test-verb-variant.sh` with `Read` verb on `ornith:35b-256k` in sub-agent context
  - **Dispatch:** `bash .opencode/tests-v2/behaviors/test-verb-variant.sh Read "Read [the authorization token list](tmp/verb-test/target-a.md)." ollama/ornith:35b-256k authorization-token`
  - **SC:** SC-2
  - **Expected:** Model loaded, first inference completes without errors
  - **Note:** Timing data from this run MUST be discarded

- [ ] 2.8 Run all 13 verb forms × 2 variants × 2 runs = 52 tests on `ornith:35b-256k` in sub-agent context
  - **Dispatch:** For each verb+variant+run combination, call `bash .opencode/tests-v2/behaviors/test-verb-variant.sh <verb> "<directive>" ollama/ornith:35b-256k authorization-token`
  - **SC:** SC-2, SC-3
  - **Expected:** 52 behavioral evidence artifact directories created
  - **Verification:** Count artifact directories — confirm 52 exist

### Phase 2 Completion

- [ ] 2.9 Verify all 208 sub-agent context test runs completed with behavioral evidence artifacts
  - **Dispatch:** Inline — count artifact directories across all 4 models
  - **SC:** SC-3
  - **Expected:** 208 artifact directories exist (416 total across both phases)
  - **Verification:** `ls tmp/behavioral-evidence-*/ | wc -l` — confirm 416 total

- [ ] 2.10 Verify no SC weakened, deferred, or reclassified
  - **Dispatch:** Inline — audit all SCs against original spec
  - **SC:** SC-8
  - **Expected:** All SCs maintain declared evidence type
  - **Verification:** Compare SC evidence types against spec

- [ ] 2.11 Phase 2 completion block — mark phase complete, transition to Phase 3
  - **Dispatch:** Inline
  - **Expected:** Phase 2 marked complete, Phase 3 entry conditions met

## Phase 2 — Safety/Rollback

- **Destructive operations:** None — test execution is read-only
- **Rollback plan:** N/A
- **Data loss risk:** None

## Concern Transition

Phase 2 completes all sub-agent context tests. Phase 3 analyzes the combined test results from both phases to identify the winning verb form and produce the recommendation document.
