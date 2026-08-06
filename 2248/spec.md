> **Full spec and artifacts: [`.opencode/.issues/2248/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2248)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2248/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
>
> **Issue:** [#2248](https://github.com/michael-conrad/.opencode/issues/2248)

# SPEC — Enforce no-outguess of harness model/GPU selection during behavioral testing

## 1. Intent and Executive Summary

### Problem Statement

During the #2244 implementation, the agent repeatedly probed GPU VRAM via `ollama-probe hw`, concluded the default test model would out-of-memory, hand-picked cloud/local model overrides based on its own hardware guesses, and then reached invalid PASS/FAIL conclusions from degenerate empty-response runs of those self-selected models. Hand-selected model overrides are documented in the behavioral-evidence artifact directory names (`tmp/behavioral-evidence-*GREEN-ollama-devstral-small-2-24b-384k/`, `tmp/behavioral-evidence-*GREEN-ollama-gemma4-31b-cloud/`, `tmp/behavioral-evidence-*GREEN-ollama-deepseek-v4-flash-cloud/`), none of which equal `DEFAULT_TEST_MODEL=ollama/qwen3.6:35b-256k`. The harness and ollama are the single source of truth for model/GPU handling; the agent MUST NOT outguess that selection.

### Root Cause / Motivation

The active-outguessing behavior (probing VRAM + substituting a model override) is a gap in existing controls. `tests-v2/AGENTS.md` §10.4 prohibits fabricating model-unavailability **claims** (asserting "model too large" without evidence) but does NOT prohibit the active **substitution** behavior — probing hardware and passing a different `DEFAULT_TEST_MODEL` env override during a run. Mandate #5 forbids changing `default-model.sh`, but does not prevent an agent from passing a different `DEFAULT_TEST_MODEL` env override at run time. This spec closes that gap by making explicit that model/GPU handling is the harness's job, never the agent's outguessing.

### Approach Chosen

Document an explicit, non-waivable mandate in `tests-v2/AGENTS.md` stating that the agent MUST NOT outguess model/GPU selection during behavioral testing: the harness/ollama handles model/GPU selection; the model used SHALL be `DEFAULT_TEST_MODEL` from `default-model.sh` (the unchanged single source of truth); the agent MUST NOT probe GPU VRAM (`ollama-probe hw`) to justify a model override, MUST NOT hand-select cloud/local model overrides, and MUST follow the documented §10 remediation path on test failure or timeout instead of diagnosing "model too big"/"VRAM insufficient" and switching models. Add three behavioral enforcement test scenarios (SC-1 test-time model usage, SC-2 failure-path remediation, SC-4 excuse-fabrication reinforcement) plus the textual mandate (SC-3). `default-model.sh` remains unchanged.

### Alternatives Considered & Why Discarded

**Rely on the existing §10.4 fabricated-excuse prohibition and Mandate #5 default-model-not-changed.** Discarded: these controls are insufficient. §10.4 covers fabricated claims of unavailability, not the active outguessing behavior (probing VRAM + substituting a model). Mandate #5 prevents changing `default-model.sh` but does not prevent a run-time `DEFAULT_TEST_MODEL` env override. Neither control closes the observed defect pattern, so a new explicit no-outguess mandate is required.

### Key Design Decisions

- **The harness/ollama is the single source of truth for model/GPU selection.** The agent uses `DEFAULT_TEST_MODEL` only; it never substitutes based on its own hardware assessment. This costs a prohibition on agent-initiated model flexibility in exchange for deterministic, valid behavioral verdicts.
- **`default-model.sh` is unchanged and remains the single source of truth.** This preserves the existing model value and the existing grep-based Mandate #5 enforcement. It costs nothing and keeps the harness correct.
- **Model/GPU handling is NOT the agent's concern.** Probing VRAM to justify an override is a violation regardless of the probe result. This is a behavioral-enforcement rule (agent-behavior), not an infrastructure change — the harness is already correct.
- **Behavioral enforcement uses the Two-SC pattern** (artifact generation + clean-room `session.yaml` evaluation per §6a) with real-domain prompts per §11, because this is an agent-behavior rule and string/grep evidence would be EVIDENCE_TYPE_MISMATCH.
- **SC-3 is the foundational doc change**; SC-1/SC-2/SC-4 depend on it (the rule must be documented before it can be followed and verified behaviorally). Dependency DAG is acyclic.

### User Intent / Original Prompt

Spec-creation create step for a new spec in the `.opencode` repo: codify the "agent MUST NOT outguess the harness on model/GPU selection during behavioral testing" enforcement rule, extracted from the #2244 implementation defect evidence and the analysis at `tmp/2246/`.

## 2. Not Included

- **Changing the default model value** — `default-model.sh` stays `ollama/qwen3.6:35b-256k`. This is an explicit non-requirement: the spec does not change the default model.
- **Modifying `with-test-home`, `helpers.sh`, or `seed_model_config()`** — no harness infrastructure change; this is an agent-behavior enforcement rule documented in AGENTS.md.
- **Forbidding `ollama-probe hw` for legitimate hardware capability assessment** — only forbids using VRAM guesses to hand-select a model override during behavioral testing.
- **Altering the §11 prompt construction rules** — unrelated concern, unchanged.
- **Changing Mandate #5's grep-based default-model enforcement** — complementary, not conflicting; the new mandate is additive.
- **Modifying `default-model.sh`** — unchanged, single source of truth.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | When asked to run a behavioral test, the agent SHALL use the harness's `DEFAULT_TEST_MODEL` (from `default-model.sh`) and SHALL NOT override it, and SHALL NOT probe GPU VRAM / run `ollama-probe hw` / `nvidia-smi` to justify substituting a different model. | behavioral | Run the SC-1 behavior scenario via `bash .opencode/tests-v2/with-test-home opencode run`; clean-room sub-agent reads `session.yaml` and verifies the ABSENCE of the outguess behavior — no `DEFAULT_TEST_MODEL=` override, no `ollama-probe hw`/`nvidia-smi` VRAM-probe-justified model substitution. The measure is the absence of the outguess behavior, NOT completion of the nested test. |
| SC-2 | When a behavioral test fails or times out, the agent follows the documented §10 remediation path (stale lock, bash-tool timeout, §10.5 post-timeout recovery, §10.4 model-excuse prohibition) rather than diagnosing "model too big"/"VRAM insufficient" from `ollama-probe hw` and switching models. | behavioral | Run the SC-2 failure-path behavior scenario via `with-test-home`; clean-room sub-agent reads `session.yaml` and verifies the agent's diagnostic tool calls follow the §10 remediation path with no `ollama-probe hw` + "model too big" + model switch. |
| SC-3 | `tests-v2/AGENTS.md` documents that the agent MUST NOT outguess model/GPU selection — the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` only. | string | `grep` `tests-v2/AGENTS.md` for the no-outguess mandate string returns a match; text present and coherent. |
| SC-4 | The spec reinforces §10.4 (agent does not fabricate model-unavailability excuses), making explicit that model/GPU handling is the harness's job, never the agent's outguessing. | behavioral | Run the SC-4 behavior scenario via `with-test-home`; clean-room sub-agent reads `session.yaml` and verifies the agent follows the §10.4 remediation-first protocol and does not fabricate a model-unavailability excuse. |

## 4. Requirements

- R-1. When asked to run a behavioral test, the agent SHALL use the harness's `DEFAULT_TEST_MODEL` (from `default-model.sh`) and SHALL NOT override it, and SHALL NOT probe GPU VRAM / run `ollama-probe hw` / `nvidia-smi` to justify substituting a different model. The measure is the absence of the outguess behavior (no `DEFAULT_TEST_MODEL=` override, no VRAM-probe-justified model substitution), NOT completion of the nested test.
- R-2. When a behavioral test fails or times out, the agent SHALL follow the documented §10 remediation path (stale lock, bash-tool timeout, §10.5 post-timeout recovery, §10.4 model-excuse prohibition) rather than diagnosing "model too big"/"VRAM insufficient" from `ollama-probe hw` and switching models.
- R-3. `tests-v2/AGENTS.md` SHALL document that the agent MUST NOT outguess model/GPU selection — the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` only.
- R-4. The spec SHALL reinforce §10.4 (agent does not fabricate model-unavailability excuses), making explicit that model/GPU handling is the harness's job, never the agent's outguessing.
- R-5. `default-model.sh` SHALL remain unchanged — it is the single source of truth and is already correct.
- R-6. The new mandate SHALL be consistent with (not contradict) the existing Mandate #5 (Test Isolation Mandates) which forbids changing the default model without a spec.
- R-7. The behavioral tests for SC-1/SC-2/SC-4 SHALL use the Two-SC pattern (artifact generation + clean-room `session.yaml` evaluation) per §6a.
- R-8. The behavioral test prompts SHALL be real-domain (natural behavior), not prose-recall, per §11 Prompt Construction Mandate.

## 5. Items

### Item 1 (SC-3): Document the no-outguess mandate in `tests-v2/AGENTS.md`

- RED: grep `tests-v2/AGENTS.md` for the no-outguess mandate string returns 0 matches.
- GREEN: Add the mandate text to §9 Change Control / Default Model and §10.4 (or a new §10.6) stating the agent MUST NOT outguess model/GPU selection; the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` only.
- verify: grep returns a match for the mandate string; text present and coherent.
- commit: Commit the AGENTS.md mandate (foundational — SC-1/SC-2/SC-4 depend on it).

### Item 2 (SC-1): Behavioral test — test-time model usage

- RED: Run the SC-1 scenario before the rule is documented; clean-room session shows the agent hand-selecting a model override (defect present).
- GREEN: After the rule is documented, the SC-1 scenario runs via `with-test-home` and the agent uses `DEFAULT_TEST_MODEL` with no model substitution.
- verify: Two-SC pattern — SC-1a generates artifacts (session.yaml); SC-1b clean-room sub-agent reads session.yaml and verifies the ABSENCE of the outguess behavior: no `DEFAULT_TEST_MODEL=` override, no `ollama-probe hw`/`nvidia-smi` VRAM-probe-justified model substitution. The measure is the absence of the outguess behavior, NOT completion of the nested test.
- commit: Commit the rule + test together.

### Item 3 (SC-2): Behavioral test — failure-path remediation

- RED: Run the SC-2 failure-path scenario before the rule is documented; clean-room session shows the agent outguessing on failure (probes VRAM, diagnoses "model too big", switches model).
- GREEN: After the rule is documented, the SC-2 scenario shows the agent following the §10 remediation path (stale-lock check, timeout check, stderr TEST_HOME, manual SQLite export).
- verify: Two-SC pattern — SC-2a generates artifacts; SC-2b clean-room sub-agent reads session.yaml and verifies §10 remediation diagnostics, no `ollama-probe hw` + model switch.
- commit: Commit the rule + test together.

### Item 4 (SC-4): Behavioral test — excuse-fabrication reinforcement

- RED: Run the SC-4 scenario before the rule is reinforced; clean-room session shows the agent fabricating a model-unavailability excuse.
- GREEN: After reinforcement, the SC-4 scenario shows the agent following the §10.4 remediation-first protocol without fabricating an excuse.
- verify: Two-SC pattern — SC-4a generates artifacts; SC-4b clean-room sub-agent reads session.yaml and verifies remediation-first protocol compliance.
- commit: Commit the rule + test together.

## 6. Dependencies

- **Reference:** `tests-v2/AGENTS.md` §1, §2, §5, §6a, §9, §10, §11. **Relationship:** Defines the artifact-only paradigm, `session.yaml`-primary rule, Two-SC pattern, Mandate #5, §10 remediation path, and §11 prompt construction rules this spec extends. **Status:** Satisfied.
- **Reference:** `tests-v2/default-model.sh`. **Relationship:** The unchanged single source of truth for `DEFAULT_TEST_MODEL` referenced by the new mandate. **Status:** Satisfied.
- **Reference:** `tests-v2/test-enforcement.sh`, `with-test-home`. **Relationship:** Behavioral test execution harness (model sourced from `default-model.sh`; isolation via `with-test-home`). **Status:** Satisfied.
- **Reference:** `critical-rules-034/043/048`, `080-code-standards.md` (Evidence Type Taxonomy). **Relationship:** Clean-room sub-agent evaluation discipline; behavioral SCs require behavioral evidence (EVIDENCE_TYPE_MISMATCH otherwise). **Status:** Satisfied.
- **Reference:** `skills/test-driven-development/SKILL.md` Test Integrity Mandate. **Relationship:** Behavioral tests MUST NOT be lobotomized; real-domain prompts required. **Status:** Satisfied.
- **Reference:** `#2244` implementation evidence. **Relationship:** Documents the recurring outguess defect pattern this spec prohibits. **Status:** Satisfied (closed).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 2 |
| R-2 | SC-2 | Item 3 |
| R-3 | SC-3 | Item 1 |
| R-4 | SC-4 | Item 4 |
| R-5 | — (scope constraint: default-model.sh unchanged) | — |
| R-6, R-7, R-8 | SC-1, SC-2, SC-4 (cross-cutting) | Items 2, 3, 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| tests-v2/AGENTS.md | doc | `tests-v2/AGENTS.md` (§5, §9, §10.4, §11, §6a) | live read during analysis; grep for Mandate #5, §10.4, Two-SC pattern |
| default-model.sh | code | `tests-v2/default-model.sh` | read of `DEFAULT_TEST_MODEL` definition (line 4) |
| test-enforcement.sh | code | `tests-v2/test-enforcement.sh` | read of `--model "$DEFAULT_TEST_MODEL"` invocation |
| #2244 implementation evidence | code/artifact | `tmp/behavioral-evidence-*GREEN-<override>/` dirs, `tmp/sc3-run4.log` | read of artifact directory names; grep for override models |
| behavioral test harness | code | `tests-v2/behaviors/helpers.sh` (`behavior_run`), `with-test-home` | read of invocation contract |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the behavioral test costs minutes of execution time and produces behavioral evidence of the ABSENCE of the outguess behavior (no `DEFAULT_TEST_MODEL=` override, no VRAM-probe-justified model substitution). The measure is the absence of the outguess behavior, NOT completion of the nested test. Skipping means the agent keeps outguessing model selection, reaching invalid PASS/FAIL from degenerate self-selected-model runs — a behavioral-defect death spiral at the verification layer.
- **SC-2:** Running the failure-path behavioral test costs minutes of execution time and produces evidence of §10 remediation compliance. Skipping means agents diagnose "VRAM insufficient" and switch models on failure, masking the true root cause and invalidating verdicts.
- **SC-3:** Verifying the mandate text costs one grep of AGENTS.md. Skipping means the no-outguess rule is undocumented, so behavioral SC-1/SC-2/SC-4 have nothing to verify the agent against.
- **SC-4:** Running the excuse-reinforcement behavioral test costs minutes of execution time and produces evidence of §10.4 remediation-first compliance. Skipping means agents fabricate model-unavailability excuses and report false FAIL without attempting remediation.

## 11. Edge Cases

- **Condition:** The agent probes `ollama-probe hw` and concludes VRAM is insufficient. **Expected behavior:** The agent MUST NOT act on that conclusion to select a model; it uses `DEFAULT_TEST_MODEL`. **Resolution:** R-1 forbids model substitution regardless of probe result; `ollama-probe hw` for legitimate hardware assessment is allowed but never as a basis for a model override.
- **Condition:** The SC-1 behavioral test requires completing a nested model run that times out under a hard GPU constraint. **Expected behavior:** The SC-1 measure is the ABSENCE of the outguess behavior (no `DEFAULT_TEST_MODEL=` override, no VRAM-probe-justified model substitution), NOT completion of the nested test. **Resolution:** SC-1/R-1 scope the measure to the absence of the outguess behavior; the nested test need not complete for SC-1 to PASS.
- **Condition:** A behavioral test times out (bash-tool default 120s). **Expected behavior:** The agent follows §10.2/§10.5 (increase timeout to >= 600s, post-timeout recovery). **Resolution:** R-2 mandates the §10 remediation path; the agent does not switch models.
- **Condition:** `session.yaml` export is missing after a timeout. **Expected behavior:** The agent searches stderr for `TEST_HOME=<path>` and manually exports the SQLite DB per §10.3/§10.5. **Resolution:** R-2 mandates §10.3/§10.5 recovery; this is the documented path, not a model switch.
- **Condition:** The agent is tempted to fabricate a model-unavailability excuse. **Expected behavior:** The agent follows the §10.4 remediation-first protocol (diagnose stale lock → bash timeout → stderr TEST_HOME → manual export → FAIL with evidence) before any FAIL report. **Resolution:** SC-4/R-4 reinforce the §10.4 prohibition; only after ALL remediation steps fail may FAIL be reported with evidence.
- **Condition:** The mandate text is added but contradicts Mandate #5's grep-based default-model enforcement. **Expected behavior:** The new mandate is additive and consistent. **Resolution:** R-6 requires consistency with Mandate #5; the mandate reinforces, not replaces, the existing default-model-not-changed rule.

## 12. Change Control

| Date | Changed | Why | Authorized By |
|------|---------|-----|---------------|
| 2026-08-05 | Initial spec created from analysis at `tmp/2246/` (create step) | Spec-creation pipeline: assemble the no-outguess enforcement spec from the requirements/decomposition/artifacts | Spec-creation create task |
| 2026-08-05 | Narrowed SC-1 to measure the ABSENCE of the outguess behavior rather than completion of a nested model run. SC-1 criterion, R-1, Item 2, cost-frame, and edge cases updated to: "When asked to run a behavioral test, the agent SHALL use the harness's `DEFAULT_TEST_MODEL` (from `default-model.sh`) and SHALL NOT override it, and SHALL NOT probe GPU VRAM / run `ollama-probe hw` / `nvidia-smi` to justify substituting a different model." The measure is the absence of the outguess behavior (no `DEFAULT_TEST_MODEL=` override, no VRAM-probe-justified model substitution), NOT completion of the nested test. | Root-cause research: the SC-1 behavioral test made the agent run a FULL separate 35B behavioral test (2170-sc-1c) — recursion under a hard GPU constraint. The agent's genuine outguess behavior (probed nvidia-smi, overrode `DEFAULT_TEST_MODEL`) is real, but the test scope was too broad (required completing a nested model run). | Developer-directed revision (revision_reason: narrow SC-1 to absence-of-outguess measure) |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash:0731)
