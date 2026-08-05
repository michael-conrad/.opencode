---
plan_schema_version: "1.0"
issue: 2248
title: "Enforce no-outguess of harness model/GPU selection during behavioral testing"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2248 — Enforce No-Outguess of Harness Model/GPU Selection

> Issue: https://github.com/michael-conrad/.opencode/issues/2248

**Goal:** Document a non-waivable no-outguess mandate in `.opencode/tests-v2/AGENTS.md` (the agent MUST NOT probe VRAM or hand-select a model override; the harness/ollama handles model/GPU selection, and `DEFAULT_TEST_MODEL` from `default-model.sh` is the single source of truth) and add three behavioral enforcement test scenarios (SC-1 test-time model usage, SC-2 failure-path remediation, SC-4 excuse-fabrication reinforcement) that verify agents follow the documented mandate.

**Architecture:** Two-phase additive change to the behavioral test harness documentation and scenarios — no harness infrastructure change. Phase 1 (SC-3, foundational) adds the mandate text to `tests-v2/AGENTS.md` §9 (Default Model) and §10.4. Phase 2 (SC-1/SC-2/SC-4) adds three new artifact-only generator scenario scripts under `tests-v2/behaviors/`, each paired with a clean-room `session.yaml` evaluation per the Two-SC pattern (§6a). The phase DAG (Phase 1 → Phase 2) is acyclic and Z3-SAT validated: SC-3 must be documented before the behavioral tests can verify agents follow it. Each SC gets its own RED → GREEN → verify → commit cycle; no item covers more than one SC. `default-model.sh` remains unchanged (R-5); Mandate #5 grep enforcement is complementary, not modified (R-6).

**Files (sub-folder references):**
- `.opencode/tests-v2/AGENTS.md` (§9 Change Control / Default Model, §10.4 Fabricated Model Excuses, or a new §10.6)
- `.opencode/tests-v2/behaviors/<scenario>.sh` (three new artifact-only generator scripts)
- `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run` — read/invoked, NOT modified)
- `.opencode/tests-v2/default-model.sh` (read — `DEFAULT_TEST_MODEL` source, unchanged)
- `.opencode/tests-v2/with-test-home` (invoked for isolation, unchanged)
- `tmp/behavioral-evidence-<scenario>-.../session.yaml` (generated artifacts)

---

## Pre-Implementation Steps

These steps run once before any phase begins.

- [ ] **P1. Coherence gate (**clean-room**).** Verify the plan is coherent with the spec: every SC (SC-1, SC-2, SC-3, SC-4) is mapped to exactly one item, no item covers multiple SCs, the phase DAG (Phase 1 → Phase 2) is acyclic and Z3-SAT validated, and no superseding/stale spec exists. **→ all SCs**
- [ ] **P2. Baseline check (**sub-agent**).** Verify the working tree is at trunk tip with zero pending changes and no stale `tmp/.behavior-run.lock`. Confirm the target files exist (`tests-v2/AGENTS.md`, `tests-v2/default-model.sh`, `tests-v2/behaviors/helpers.sh`, `tests-v2/with-test-home`) and that `default-model.sh` reads `DEFAULT_TEST_MODEL=ollama/qwen3.6:35b-256k`. **→ all SCs**

---

## Phase Table

| Phase | Concern | Skill | Task | Target | SCs | Depends On |
|-------|---------|-------|------|--------|-----|------------|
| 1 — Document no-outguess mandate | C1 | `test-driven-development` | `red` | `.opencode/tests-v2/AGENTS.md` (§9, §10.4/new §10.6) | SC-3 | — |
| 2 — Behavioral enforcement tests | C2 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/` (3 new scenario scripts) + clean-room session.yaml evaluation | SC-1, SC-2, SC-4 | 1 |

---

## Phase Details

### Phase 1 — Document No-Outguess Mandate (Concern C1)

| Field | Value |
|-------|-------|
| Concern | C1 — document the no-outguess model/GPU mandate in `tests-v2/AGENTS.md` |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/AGENTS.md` (§9 Change Control / Default Model, §10.4 Fabricated Model Excuses, or a new §10.6) |
| SCs | SC-3 |
| Depends On | — |

**Context:**
```yaml
concern: C1
target: .opencode/tests-v2/AGENTS.md
scs: [SC-3]
evidence_type: string
mandate_text: >
  The agent MUST NOT outguess model/GPU selection during behavioral testing.
  The harness/ollama handles model/GPU selection; the model used SHALL be
  DEFAULT_TEST_MODEL from default-model.sh (the unchanged single source of truth).
  The agent MUST NOT probe GPU VRAM (ollama-probe hw) to justify a model override,
  MUST NOT hand-select cloud/local model overrides, and MUST follow the documented
  §10 remediation path on test failure or timeout instead of diagnosing
  "model too big"/"VRAM insufficient" and switching models.
sections_to_modify:
  - "§9 Change Control / Default Model"
  - "§10.4 Fabricated Model Excuses (or a new §10.6)"
constraints:
  - "default-model.sh MUST remain unchanged (R-5)"
  - "mandate MUST be consistent with (not contradict) Mandate #5 grep-based default-model enforcement (R-6)"
```

### Phase 2 — Behavioral Enforcement Tests (Concern C2)

| Field | Value |
|-------|-------|
| Concern | C2 — add three behavioral enforcement test scenarios verifying agents follow the documented no-outguess mandate |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/` (three new artifact-only generator scenario scripts) + clean-room `session.yaml` evaluation |
| SCs | SC-1, SC-2, SC-4 |
| Depends On | 1 |

**Context:**
```yaml
concern: C2
target: .opencode/tests-v2/behaviors/
scs: [SC-1, SC-2, SC-4]
evidence_type: behavioral
two_sc_pattern: true
scenarios:
  SC-1:
    name: 2248-sc1-test-time-model-usage
    criterion: "Agent uses the harness's DEFAULT_TEST_MODEL during behavioral testing; does not substitute based on VRAM/GPU/ollama-probe hw assessment"
  SC-2:
    name: 2248-sc2-failure-path-remediation
    criterion: "On test failure/timeout, agent follows the documented §10 remediation path rather than diagnosing VRAM and switching models"
  SC-4:
    name: 2248-sc4-excuse-fabrication-reinforcement
    criterion: "Spec reinforces §10.4 model-excuse prohibition; model/GPU handling is the harness's job, never the agent's outguessing"
prompt_rules:
  - "real-domain (natural behavior), NOT prose-recall, per §11"
  - "MUST reference the documented no-outguess mandate so the agent can comply"
harness_constraints:
  - "run via .opencode/tests-v2/with-test-home"
  - "bash tool timeout >= 600000ms (600s)"
  - "session.yaml is PRIMARY evaluation source (Two-SC pattern per §6a)"
  - "no GNU timeout in scripts"
```

---

## Exit Criteria

- [ ] C1. `tests-v2/AGENTS.md` documents the no-outguess mandate: the agent MUST NOT outguess model/GPU selection; the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` only; the agent MUST NOT probe VRAM to justify a model override, MUST NOT hand-select overrides, and MUST follow the §10 remediation path on failure/timeout (SC-3). `default-model.sh` unchanged; mandate consistent with Mandate #5.
- [ ] C2. Three new artifact-only generator scenario scripts exist under `tests-v2/behaviors/` (SC-1 test-time model usage, SC-2 failure-path remediation, SC-4 excuse-fabrication reinforcement), each run via `with-test-home` with real-domain prompts, each producing a `session.yaml`; a clean-room sub-agent reads each `session.yaml` and verifies the corresponding behavioral criterion (SC-1, SC-2, SC-4).
- [ ] C3. All four SCs map to exactly one item each; no item covers multiple SCs; the phase DAG (Phase 1 → Phase 2) is acyclic and Z3-SAT validated; each phase addresses exactly one concern (C1, C2).

---
