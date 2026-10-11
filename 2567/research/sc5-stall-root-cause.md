# Root cause — SC-5 behavioral stall (2026-10-11)

## Findings (R-18 cause analysis)

**Signature.** Every dispatch of the rebuilt `visual-design-agent` stalls:
the child session is created with `agent: visual-design-agent` and the
invoking primary's model, produces zero (or a few) parts, then goes silent —
flat event stream, idle GPU, held HTTP connection to Ollama, task tool stuck
`running`. Dispatch of an unmodified card (`math-ops`) completes cleanly.

**Isolation sequence.**

1. Probe A (visual-design-agent, file-write task): child progressed to a
   `Write` tool call, then stalled. (`tmp/test-home-20261011-125526`)
2. Probe B (math-ops, same harness): completed. → card-specific.
3. Probe C (visual-design-agent, no-write task): stalled at zero parts.
   → not the Write tool; request-level hang.
4. Socket check during stall: ESTAB connection opencode→ollama:11434, no
   data flowing, GPU 0% — Ollama accepted a request it never answers.
5. Direct API probes against the running default test model
   (`ollama/qwen3.8:27b-256k-gguf4`):
   - `/api/chat` + card options (`temperature 1.0, top_p 0.95,
     reasoning_effort max`): OK — the native endpoint ignores unknown options.
   - `/v1/chat/completions` (the path opencode's provider uses) plain, and
     with `temperature`/`top_p` only: OK (~1 s).
   - `/v1` + `reasoning_effort: low` / `none`: OK.
   - `/v1` + `reasoning_effort: max`: **HTTP 500, deterministic (3/3)** —
     the model's chat template crashes on the `max` effort literal.

**Causal chain.** The card pins `reasoningEffort: max` (SC-2, GLM-5.3-Flash
vendor recommendation) → opencode normalizes it to `reasoning_effort` on the
wire (research card finding) → Ollama's `/v1` endpoint 500s because the
qwen3.8 template rejects that literal → opencode's subagent execution path
does not surface the error; the request hangs silently (consistent with the
open ticket anomalyco/opencode#43293 — Ollama reasoning models hang through
opencode while direct `/v1` calls are fast; and #21632/#25026 on the
subagent reasoningEffort path).

**Upstream filing (SC-7):** anomalyco/opencode#54568 —
https://github.com/anomalyco/opencode/issues/54568 (filed 2026-10-11; no
duplicate found at filing time).

## Consequence for the spec

SC-2 (`reasoningEffort: max` in the card) and SC-5 (the behavioral dispatch
must complete on `DEFAULT_TEST_MODEL`) are **mutually unsatisfiable on the
current test model**: the GLM-aligned effort literal crashes that model's
template, and the single-sourced default test model may not be changed
without developer direction (R-20). BLOCKED per the SC-fidelity rule — the
criteria are not modified by the implementor.

## Evidence artifacts

- `tmp/issue-2567/artifacts/` — run-1 artifacts (session.yaml, monitor.log,
  console.log, clean-room evaluation `evaluation-1791737526.yaml` → FAIL).
- Probe DBs: `tmp/test-home-20261011-125526` (A), `…-132920` (C);
  probe B console in `tmp/2567-probe2.log`.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
