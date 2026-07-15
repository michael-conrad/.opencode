# Phase 03 — Analysis and Recommendation

## Phase Metadata

- **Concern:** Analyze combined test results from Phases 1 and 2, identify winning verb form, document findings, produce recommendation
- **Files:** `.opencode/.issues/1958/test-record.md`, `.opencode/.issues/1958/winning-verb-analysis.md`
- **SCs:** SC-4, SC-5, SC-6, SC-7
- **Dependencies:** Phase 2 complete (all 416 test runs verified)
- **Entry conditions:** All behavioral evidence artifacts available, test record data collected
- **Exit conditions:** Winning verb identified, analysis documented, recommendation produced

## Code Path Coverage

- Analysis of stderr logs from all 416 test runs
- Pattern matching for `read` tool calls, `grep`/`search` tool calls, other tool calls

## Cross-Cutting SCs

- SC-6 (anti-lobotomization): Applies to all analysis — no SC may be weakened
- SC-7 (behavioral tests RED before implementation): Applies before any implementation changes

## Interface Boundaries

- Test record table format: Verb, Variant, Model, Context, Warmup, Did agent load target file?, Tool used, Did agent use grep/search?, Time, Notes
- Analysis document format: Findings, winning verb, recommendation, context-specific differences

## State Transitions

- Raw test artifacts → parsed test record → analysis → recommendation document
- No destructive state transitions

## Step-by-step

- [ ] 3.1 Parse all behavioral evidence artifacts and produce the test record table at `.opencode/.issues/1958/test-record.md`
  - **Dispatch:** `task(subagent_type="general", prompt="execute research task from research")`
  - **SC:** SC-3, SC-4
  - **Input:** All `tmp/behavioral-evidence-*/` directories with stdout.log, stderr.log, manifest.yaml
  - **Expected:** Test record table with columns: Verb, Variant (plain/checkbox), Model, Context (orchestrator/sub-agent), Warmup run?, Did agent load target file?, Tool used, Did agent use grep/search instead?, Time (post-warmup), Notes
  - **Verification:** Table has 416 data rows (208 orchestrator + 208 sub-agent) plus warmup rows marked accordingly

- [ ] 3.2 Analyze test record to identify the winning verb form
  - **Dispatch:** `task(subagent_type="general", prompt="execute research task from research")`
  - **SC:** SC-4
  - **Input:** `.opencode/.issues/1958/test-record.md`
  - **Expected:** Winning verb identified based on: highest file-loading call rate across all models and contexts, zero grep/search substitution, at least 2 out of 2 runs per model
  - **Verification:** Winning verb meets all criteria from "What 'Works' Means" section in spec

- [ ] 3.3 If adherence rate across all combinations is ≤ 25% or zero, conduct remediation research
  - **Dispatch:** `task(subagent_type="general", prompt="execute research task from research")`
  - **SC:** SC-6
  - **Input:** Test record table, winning verb analysis
  - **Expected:** Research findings documented: additional verb forms, link description text wording, emphasis markers, position effects, repetition
  - **Verification:** `.opencode/.issues/1958/winning-verb-analysis.md` contains remediation research findings
  - **Note:** Only execute this step if adherence rate ≤ 25% or zero

- [ ] 3.4 Document winning verb analysis and recommendation at `.opencode/.issues/1958/winning-verb-analysis.md`
  - **Dispatch:** `task(subagent_type="general", prompt="execute research task from research")`
  - **SC:** SC-5, SC-7
  - **Expected:** Document contains: winning verb form, context-specific differences (orchestrator vs sub-agent), recommendation for implementation in guidelines and `default.txt`, any remediation research findings
  - **Verification:** Document exists and contains all required sections

- [ ] 3.5 Verify no SC weakened, deferred, or reclassified
  - **Dispatch:** Inline — audit all SCs against original spec
  - **SC:** SC-8
  - **Expected:** All SCs maintain declared evidence type
  - **Verification:** Compare SC evidence types against spec

## Phase 3 — Safety/Rollback

- **Destructive operations:** None — analysis is read-only
- **Rollback plan:** N/A
- **Data loss risk:** None

## Concern Transition

Phase 3 completes the full plan. All exit criteria must be verified before marking the plan complete.
