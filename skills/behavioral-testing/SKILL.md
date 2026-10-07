---
name: behavioral-testing
description: "Load for ANY opencode behavior testing — running a behavioral SC, verifying agent behavior, executing or monitoring an `opencode run`, evaluating session evidence, or deciding how to produce behavioral evidence at all. Also load when a spec SC is classified behavioral, when a test scenario script under tests-v2/ is authored or run, when a behavioral test needs a real remote API (the harness provisions a self-contained GitBucket container — §12), or when a behavioral run stalls, times out, or fails. Routes to the tests-v2 behavioral harness — never an ad-hoc `opencode run`."
license: MIT
provenance: AI-authored, .opencode#2517; #2538 isolation mandate + evaluator contract restored from pre-rip deck
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2517; #2538 clean-room isolation mandate and evaluator contract restored from pre-rip verification-before-completion -->

# behavioral-testing — the tests-v2 harness gate

1. **Harness only.** Behavioral evidence is produced by `.opencode/tests-v2/`
   — read [`tests-v2/AGENTS.md`](../../tests-v2/AGENTS.md) first, every time.
   Scenario scripts via `behavior_run()`, environment via `with-test-home`;
   an ad-hoc `opencode run` is never behavioral evidence. Invoke only as
   `bash .opencode/tests-v2/behaviors/<scenario>.sh` from the project root —
   never bare `opencode run` (SQLite session conflicts with the desktop app),
   never inline or from-scratch test infrastructure.
2. **Clean-room isolation is inviolable.** The test home is built from the
   pushed effective commit — never from session state. Do NOT pass session
   credentials through the `env -i` allowlist, do NOT inject config entries
   or secrets into the seeded test environment (including via per-scenario
   fixtures), do NOT weaken isolation to make a failing test pass. If a
   behavioral SC needs something the isolated environment cannot provide,
   that is a spec problem — re-scope the SC at the spec, never the isolation.
   (Observed regression, #2538: a fixture was authored to inject an MCP entry
   into the seeded test config and an allowlist credential passthrough was
   proposed; both ruled a bypass of the isolation the harness exists to
   enforce.)
3. **Scenario authoring.** Copy `template.sh`; the script is an artifact-only
   generator — it runs `behavior_run`, exits 0, and NEVER evaluates output.
   `SCENARIO_NAME` is kebab-case and MUST match any
   `fixtures/setup/<name>.sh` fixture filename; prompt references to issue
   content require fixture files under `fixtures/issues/{N}/` (§3). Every run
   follows the ordered precondition cycle: commit → push → fetch/verify →
   run (§4).
4. **Artifacts.** Harness output lands where `behavior_run` writes it
   (`./tmp/behavioral-evidence-<scenario>-<phase>-<model>/`, tests-v2/AGENTS.md
   §2); preserve verification artifacts issue-keyed under
   `{project_root}/tmp/{issue-N}/artifacts/`. Never fabricate, move, or
   synthesize artifacts — a missing export is remediated per §10, never
   reconstructed.
5. **Standard evaluator sub-agent.** After every behavioral run, dispatch the
   clean-room evaluator — Read [Clean-Room Behavioral
   Evaluation](references/behavioral-evaluation.md). It receives ONLY the
   artifact directory and the SC criteria — no orchestrator context, no
   expected outcomes, no cached results — reads `session.yaml` as the PRIMARY
   source, writes `evaluation-<timestamp>.yaml` into the artifact directory,
   and returns the YAML verdict record. "Artifact generated" is NEVER a valid
   PASS verdict for a behavioral SC.
6. **Two-SC pattern.** Artifact generation (run, produce `session.yaml`) and
   clean-room evaluation (separate sub-agent reads the artifacts) are separate
   SCs and separate dispatches — never merged.
7. **Prompts are real-domain tasks.** Interview/prose-recall prompts are a
   hard FAIL (§11).
8. **Default model is single-sourced.** `DEFAULT_TEST_MODEL` in
   `default-model.sh` runs every test; model-shopping is prohibited (R-20,
   §10.6). Remediation targets the defect classes, never model selection.
9. **Monitor every run.** Launch in background; poll the live session DB at
   30–60s intervals; record a semantic judgment on **every** poll (progressing
   vs. off-track) in the poll log. A blind wait or a mechanical-only DB read
   is a violation (§14). Abort on the hard-abort signals and record the
   diagnosis. **Early exit on evidence sufficiency (#2538):** when a poll's
   judgment finds the SC's evidence surface already complete and further
   running adds no value, conclude the run — kill, export per §10.5, record
   the sufficiency judgment, and proceed to evaluation. Waiting out a run
   whose evidence is captured burns inference for nothing. This is a judgment
   call — never scripted.
10. **Timeouts and recovery.** Bash-tool timeout ≥ 600000 ms; on timeout,
    session resumption (`--continue`/`--session`) is the first-line recovery
    (§10.7); the §10 remediation paths replace model excuses and blind retries.
11. **Remote API tests are self-contained.** A behavioral SC requiring real
    remote API behavior opts into the harness's provisioned GitBucket container
    (`BEHAVIOR_NEEDS_REMOTE`; mechanics in tests-v2 §12) — no external server,
    no mock stand-in by default.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
