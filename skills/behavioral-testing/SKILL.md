---
name: behavioral-testing
description: "Load for ANY opencode behavior testing — running a behavioral SC, verifying agent behavior, executing or monitoring an `opencode run`, evaluating session evidence, or deciding how to produce behavioral evidence at all. Also load when a spec SC is classified behavioral, when a test scenario script under tests-v2/ is authored or run, when a behavioral test needs a real remote API (the harness provisions a self-contained GitBucket container — §12), or when a behavioral run stalls, times out, or fails. Routes to the tests-v2 behavioral harness — never an ad-hoc `opencode run`."
license: MIT
provenance: AI-authored, .opencode#2517; #2538 isolation mandate + evaluator contract restored from pre-rip deck; #2570 supervision-cycle absoluteness + no-output-filtering
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2517; #2538 clean-room isolation mandate and evaluator contract restored from pre-rip verification-before-completion; #2557 supervision poll discipline (≤60s, semantic check per poll, per-poll report) -->

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
9. **Supervise every run — 60-second poll cycle, update turn follows the poll's reminder.**
   Launch the run in background. **The supervision cycle is two turns, strictly
   alternating: (1) a tool call — `sleep 60`, then `.opencode/tests-v2/poll-run.sh
   <pinned-session-db> <poll#>` — whose output ENDS WITH THE REMINDER to
   deliver the analysis in chat (the poll script prints it); (2) the very next
   message is the text-only update — the analysis and NO tool call.** The reminder block in the poll
   output is the trigger; never chain another tool call before delivering the
   update. **The 60-second cycle is absolute — no longer sleeps (240s/300s+)
   between polls, ever (observed defect, #2570). Never pipe, grep, head, tail,
   or otherwise filter or truncate the poll output — the trailing reminder is
   the update trigger, and filtering it out silently suppresses the update
   turn (observed defect, #2570: a `grep | head` poll invocation dropped the
   reminder and produced a run of bare bash calls with zero in-chat updates).**
   The supervision loop is continuous — it does NOT yield to the
   developer between polls; mid-cycle yielding exits the loop and is the
   defect corrected in #2561. The cycle ends only when monitoring is
   conclusive: run completion, a handled hard-abort signal, or the
   evidence-sufficiency early exit. The developer's UI
   collapses Shell calls to bare command lines, so tool results, echo-carried
   updates, and text riding in tool-call turns all fail to surface (verified
   live, #2557; the standalone text turn is the only delivery that works). The
   update states: what the run agent is doing right now, what it intends next,
   whether that serves the scenario's goal, and which hard-abort signals (§14)
   have fired — read from the agent's actual words and work, not counters.
   **The loop is CONTINUOUS until conclusive (#2561 developer correction):
   never yield to the developer mid-cycle — a poll cycle ends only when the
   run is conclusive (run completion, a fired hard-abort signal handled, or
   the evidence-sufficiency early exit), not on a schedule or after each
   update. The per-poll sequence is: poll tool call → analyze its evidence →
   report in chat → next poll tool call, repeating inside the working turn.**
   **Keep the todo list current with the run's state** — it renders
   persistently between updates. **Pin the polled DB to the active run's test
   home** (env-passed path, not newest-by-mtime): a zombie run from a prior
   kill can outlive its supervisor and pollute mtime-based selection — kill
   survivors with `kill -9` by PID and re-verify with `pgrep`. Activity or
   uptime proxies are INADMISSIBLE as the check; counters alone are not a
   finding. **When the DB is flat, distinguish generating from stalled by
   inference-load evidence — GPU utilization (`nvidia-smi`) and `ollama ps`:
   a busy GPU is generation in progress; an idle GPU with a flat DB is a
   stall signal. The supervision loop stays inside the repository: no
   system-journal or system-log reads (journalctl and the like) in recurring
   polls.**
   **Cadence and gap claims are computed, never estimated:** record the nested
   run's launch time and every poll time, and derive any cadence or gap
   statement from those recorded timestamps — an assertion of compliance (or a
   "no gap" framing) built from an elapsed-time impression is a fabricated
   finding. If the run completed before the first poll, state that plainly,
   take the early-exit path, and report the actual timeline. **No blocking
   action longer than 60 s starts while a run is active** —
   dispatch clean-room evaluations at run boundaries (after the run ends),
   never mid-run. Abort on the hard-abort signals and record the diagnosis in
   the next update. **Early exit on evidence sufficiency (#2538):** when a
   poll's judgment finds the SC's evidence surface already complete and
   further running adds no value, conclude the run — kill, export per §10.5,
   record the sufficiency judgment, and proceed to evaluation. Waiting out a
   run whose evidence is captured burns inference for nothing. Whether the
   evidence surface is complete is a judgment call — never scripted. **Verdict
   for ceremony-escalation aborts:** a run aborted for ceremony escalation
   (self-inflicted detours — summoned machinery, tooling debugging, store
   initialization — the task never requires) whose root cause traces to deck
   wording is a **FAIL** verdict, remediated by the easy deck correction, and
   the scenario re-runs — never reclassified as inconclusive or worked around
   in the prompt.
10. **Timeouts and recovery.** Bash-tool timeout ≥ 600000 ms; on timeout,
    session resumption (`--continue`/`--session`) is the first-line recovery
    (§10.7); the §10 remediation paths replace model excuses and blind retries.
11. **Remote API tests are self-contained.** A behavioral SC requiring real
    remote API behavior opts into the harness's provisioned GitBucket container
    (`BEHAVIOR_NEEDS_REMOTE`; mechanics in tests-v2 §12) — no external server,
    no mock stand-in by default.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
