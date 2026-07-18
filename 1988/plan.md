# Plan: Cross-Reference Form Comparison (#1988)

## Overview

Systematic comparison of 3 cross-reference forms (A: inline link, B: symbol-only+table+admonition, C: explicit verb+table+admonition) across 4 fixture types, 2 tiers, with 3 runs per cell. Produces a recommendation with supporting evidence.

## Phase Table

| Phase | Name | Description | Depends On | SCs |
|-------|------|-------------|------------|-----|
| 1 | Test Fixture Creation | Create SKILL.md files, task cards, and referenced files for all forms and fixtures | — | SC-5 |
| 2 | Test Harness Development | Build the test runner that executes each form+fixture combination and records measurements | Phase 1 | SC-5 |
| 3 | Tier 1 Execution | Run all 4 fixtures × 3 forms × 3 runs = 36 runs | Phase 2 | SC-0, SC-1, SC-2, SC-3 |
| 4 | Tier 2 Execution | Select best 2 fixtures, run 2 × 3 forms × 3 runs = 18 runs | Phase 3 | SC-4 |
| 5 | Analysis and Recommendation | Compute access rates, produce comparison table, identify winning form | Phase 4 | SC-0, SC-1, SC-2, SC-3, SC-4 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-0 | Form A baseline ≥40% access rate | 3, 5 | 3.1, 5.1, 5.2 |
| SC-1 | Form B or C ≥80% on ≥1 fixture | 3, 5 | 3.1, 5.1, 5.2 |
| SC-2 | Form B or C outperforms Form A by ≥20pp | 3, 5 | 3.1, 5.1, 5.2 |
| SC-3 | ≥1 Form B variant ≥70% access rate | 3, 5 | 3.1, 5.1, 5.2 |
| SC-4 | Winning form survives Tier 2 within 1 run | 4, 5 | 4.1, 4.2, 5.1, 5.2 |
| SC-5 | All measurements recorded for every run | 1, 2, 3, 4 | 1.1, 1.2, 1.3, 2.1, 2.2, 3.1, 4.1 |

---

## Phase 1 — Test Fixture Creation

### Safety/Rollback
No destructive operations in this phase.

### Steps

| Step | Description | SCs |
|------|-------------|-----|
| 1.1 | Create 3 SKILL.md files per fixture (Form A, Form B, Form C) — 12 total. Each SKILL.md contains references to relevant and irrelevant files per the fixture spec. Form B files include the resolution table and admonition. Form C files use explicit verb forms. | SC-5 |
| 1.2 | Create up to 12 task card files for Tier 2 (Form A, Form B, Form C per selected fixture). Same structure as SKILL.md files but in task card format. | SC-5 |
| 1.3 | Create referenced files (relevant + irrelevant per fixture). Fixture A: timeout config. Fixture B: naming policy. Fixture C: error handling procedure. Fixture D: validation criteria. Each fixture gets 2-3 referenced files (1 relevant, 1-2 irrelevant). | SC-5 |

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | SKILL.md format | ✅ | Existing SKILL.md files in `.opencode/skills/` |
| 1.2 | Task card format | ✅ | Existing task card files in `.opencode/skills/*/tasks/` |
| 1.3 | Fixture spec in spec-body.md | ✅ | Spec §Fixture Types defines all 4 fixtures |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| SKILL.md files follow existing format | `ls .opencode/skills/*/SKILL.md` | ✅ |
| Task cards follow existing format | `ls .opencode/skills/*/tasks/*.md` | ✅ |

---

## Phase 2 — Test Harness Development

### Safety/Rollback
No destructive operations in this phase.

### Steps

| Step | Description | SCs |
|------|-------------|-----|
| 2.1 | Build test runner script that: (a) sets up a test project with the fixture SKILL.md, (b) runs `opencode run` with a task prompt that triggers file access, (c) captures stderr for file read tool calls, (d) records measurements (File access, Read selection, Read depth, Time) to a structured log. | SC-5 |
| 2.2 | Build measurement recording system: per-run log entry with all 4 measurements. Output format: JSON lines file at `tmp/1988/measurements.jsonl`. | SC-5 |

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 2.1 | `opencode run` CLI | ✅ | Existing test infrastructure in `.opencode/tests-v2/` |
| 2.1 | `with-test-home` wrapper | ✅ | Existing in `.opencode/tests-v2/with-test-home` |
| 2.2 | JSON lines format | ✅ | Standard format, no dependencies |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `opencode run` is available | `which opencode` | ✅ |
| `with-test-home` exists | `ls .opencode/tests-v2/with-test-home` | ✅ |

---

## Phase 3 — Tier 1 Execution

### Safety/Rollback
No destructive operations in this phase.

### Steps

| Step | Description | SCs |
|------|-------------|-----|
| 3.1 | Run Tier 1: all 4 fixtures × 3 forms × 3 runs = 36 runs. For each run: set up test project, run `opencode run`, capture stderr, record measurements. Default model: qwen3.6:35b-256k. No model fallback. | SC-0, SC-1, SC-2, SC-3, SC-5 |

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 3.1 | qwen3.6:35b-256k model | ⚠️ | Must verify via `ollama-probe` before execution |
| 3.1 | 36 runs × ~2 min each = ~72 min | ⚠️ | Estimated; timeout configurable |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Model available | `ollama-probe hw` + `opencode models` | ⚠️ Verify at execution time |

---

## Phase 4 — Tier 2 Execution

### Safety/Rollback
No destructive operations in this phase.

### Steps

| Step | Description | SCs |
|------|-------------|-----|
| 4.1 | Analyze Tier 1 results: compute file access rate per form per fixture. Select best 2 fixtures using selection criteria (widest spread between forms; tiebreak by real-world representativeness: Procedure Steps > Configuration Values > Rules/Policy > Validation Criteria). | SC-4 |
| 4.2 | Run Tier 2: best 2 fixtures × 3 forms × 3 runs = 18 runs. For each run: orchestrator dispatches clean-room sub-agent with task card containing references; capture stderr; record measurements. | SC-4, SC-5 |

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 4.1 | Tier 1 measurement logs | ✅ | Produced in Phase 3 |
| 4.2 | Task card files | ✅ | Produced in Phase 1 |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Tier 1 results available | `tmp/1988/measurements.jsonl` | ⚠️ Produced in Phase 3 |

---

## Phase 5 — Analysis and Recommendation

### Safety/Rollback
No destructive operations in this phase.

### Steps

| Step | Description | SCs |
|------|-------------|-----|
| 5.1 | Compute per-form, per-fixture, per-variant file access rates from measurement logs. Produce structured comparison table. | SC-0, SC-1, SC-2, SC-3, SC-4 |
| 5.2 | Identify winning form: highest mean file access rate across all fixtures and tiers. Tiebreak: read depth (full reads preferred), then time (faster wins). Produce recommendation with supporting evidence. | SC-0, SC-1, SC-2, SC-3, SC-4 |

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 5.1 | Measurement logs | ✅ | Produced in Phases 3 and 4 |
| 5.2 | Tiebreak criteria | ✅ | Defined in spec §Approach step 6 |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| All measurements recorded | `tmp/1988/measurements.jsonl` | ⚠️ Produced in Phases 3 and 4 |

---

## Phase Exit Criteria for Behavioral SCs

### Phase 3 Exit Criteria

| SC ID | Evidence Type | Verification Method |
|-------|---------------|---------------------|
| SC-0 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-1 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-2 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-3 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |

### Phase 4 Exit Criteria

| SC ID | Evidence Type | Verification Method |
|-------|---------------|---------------------|
| SC-4 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |

### Phase 5 Exit Criteria

| SC ID | Evidence Type | Verification Method |
|-------|---------------|---------------------|
| SC-0 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-1 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-2 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-3 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |
| SC-4 | behavioral | `behavior_run` → `behavioral-test-evaluation` clean-room dispatch |

### VbC Gate for Behavioral SCs

After artifact generation (`behavior_run`), dispatch `behavioral-test-evaluation` before allowing PASS verdict. The evaluation sub-agent reads the measurement logs and produces PASS/FAIL per SC.
