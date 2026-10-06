---
name: behavioral-testing
description: "Load for ANY opencode behavior testing — running a behavioral SC, verifying agent behavior, executing or monitoring an `opencode run`, evaluating session evidence, or deciding how to produce behavioral evidence at all. Also load when a spec SC is classified behavioral, when a test scenario script under tests-v2/ is authored or run, when a behavioral test needs a real remote API (the harness provisions a self-contained GitBucket container — §12), or when a behavioral run stalls, times out, or fails. Routes to the tests-v2 behavioral harness — never an ad-hoc `opencode run`."
license: MIT
provenance: AI-authored, .opencode#2517
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2517 -->

# behavioral-testing — the tests-v2 harness gate

1. **Harness only.** Behavioral evidence is produced by `.opencode/tests-v2/`
   — read [`tests-v2/AGENTS.md`](../../tests-v2/AGENTS.md) first, every time.
   Scenario scripts via `behavior_run()`, environment via `with-test-home`;
   an ad-hoc `opencode run` is never behavioral evidence.
2. **Two-SC pattern.** Artifact generation (run, produce `session.yaml`) and
   clean-room evaluation (separate sub-agent reads the artifacts) are separate
   SCs and separate dispatches — never merged.
3. **Prompts are real-domain tasks.** Interview/prose-recall prompts are a
   hard FAIL (§11).
4. **Default model is single-sourced.** `DEFAULT_TEST_MODEL` in
   `default-model.sh` runs every test; model-shopping is prohibited (R-20,
   §10.6). Remediation targets the defect classes, never model selection.
5. **Monitor every run.** Launch in background; poll the live session DB at
   30–60s intervals; record a semantic judgment on **every** poll (progressing
   vs. off-track) in the poll log. A blind wait or a mechanical-only DB read
   is a violation (§14). Abort on the hard-abort signals and record the
   diagnosis.
6. **Timeouts and recovery.** Bash-tool timeout ≥ 600000 ms; on timeout,
   session resumption (`--continue`/`--session`) is the first-line recovery
   (§10.7); the §10 remediation paths replace model excuses and blind retries.
7. **Remote API tests are self-contained.** A behavioral SC requiring real
   remote API behavior opts into the harness's provisioned GitBucket container
   (`BEHAVIOR_NEEDS_REMOTE`; mechanics in tests-v2 §12) — no external server,
   no mock stand-in by default.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
