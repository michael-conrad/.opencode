<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Model Dependency: Ollama / Ollama-Cloud

The `.opencode` skilldeck is hard-wired to use **Ollama** as its model provider — both locally (via the `ollama` CLI) and via **ollama-cloud** (Ollama's cloud-hosting service). There is no abstraction layer or alternate provider. If Ollama is not installed and ollama-cloud is not accessible, the skilldeck cannot dispatch agents.

## Touchpoints

| Layer | Ollama Footprint |
|---|---|
| **Agent definitions** (`agents/auditor-*.md`) | All 4 auditor agents hard-code `model: ollama/:cloud` |
| **Behavioral tests** (`tests-v2/behaviors/`) | Default test model: `ollama/ornith:35b-256k`; `helpers.sh` sources `default-model.sh` |
| **Content-verification tests** (`test-enforcement.sh`) | Default model: `ollama/ornith:35b-256k` |
| **Auditor pool** (`tests-v2/qualification/qualified-auditor-pool.sh`) | 4 audited models, all `:cloud`-suffixed via Ollama |
| **Audit** (`skills/audit/`) | Cross-family cross-validation dispatches dual Ollama models per audit via `resolve-models` |
| **Tooling** (`tools/ollama-probe`, `tools/resolve-models`) | Dedicated tools for probing local Ollama server and resolving auditor model pairs |
| **Guidelines** (`020-go-prohibitions.md`) | References `ollama-probe hw` as mandatory hardware assessment step |

## Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| **Ollama** (local) | Installed, reachable at `localhost:11434` | `curl -fsSL https://ollama.com/install.sh \| sh` |
| **ollama-cloud** | Token configured (via `ollama login` or env) for cloud model access | Verified via `ollama list` — cloud models show SIZE of `"-"` |
| **VRAM** (for local models) | 8 GB for a ≥7B model | 16 GB+ for multiple concurrent models |
| **Hardware probe** | `ollama-probe hw` must return VRAM ≥ 8 GB | Run at session start to validate capacity |

## Configuration Points

| Setting | Mechanism | Default |
|---|---|---|
| **Default test model** | `DEFAULT_TEST_MODEL` env var (sourced from `tests-v2/default-model.sh`) | `ollama/ornith:35b-256k` |
| **Auditor agent models** | `model:` field in `agents/auditor-*.md` YAML frontmatter | Per-card (e.g., `ollama/deepseek-v4-flash:cloud`) |
| **Qualified auditor pool** | `tests-v2/qualification/qualified-auditor-pool.sh` | 4 models (deepseek-v4-flash, gemma4, mistral-large-3, qwen3.5) |
| **Auditor pair resolution** | `tools/resolve-models` scans cards + pool | Selects 2 auditors from different families |

## Model Name Convention

Two formats are used interchangeably:

- `ollama/:cloud` — used in agent definitions and behavioral test helpers
- `ollama-cloud/` — used in content-verification tests and guideline examples

Both resolve to the same Ollama cloud model namespace.

---

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
