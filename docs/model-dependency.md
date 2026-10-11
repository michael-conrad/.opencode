<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Model Dependency: Ollama (test tooling only)

The `.opencode` deck's configuration wires no model provider at all — `opencode.jsonc` carries instructions, prompts, MCP servers, and permissions only. Provider and model selection come from the invoking opencode configuration. Ollama is a live dependency only where the deck actually touches it: the default test model for behavioral tests and the `ollama-probe` tool.

## Touchpoints

| Layer | Ollama Footprint |
|---|---|
| **Behavioral tests** (`tests-v2/behaviors/`) | Default test model: `ollama/qwen3.8:27b-256k-gguf4` (from `default-model.sh`); `helpers.sh` sources `default-model.sh` |
| **Content-verification tests** (`test-enforcement.sh`) | Default model: `ollama/qwen3.8:27b-256k-gguf4` (from `default-model.sh`) |
| **Tooling** (`tools/ollama-probe`) | Dedicated tool for probing the local Ollama server |

## Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| **Ollama** (local) | Installed, reachable at `localhost:11434` | `curl -fsSL https://ollama.com/install.sh \| sh` |
| **VRAM** (for local models) | 8 GB for a ≥7B model | 16 GB+ for multiple concurrent models |

## Configuration Points

| Setting | Mechanism | Default |
|---|---|---|
| **Default test model** | `DEFAULT_TEST_MODEL` env var (sourced from `tests-v2/default-model.sh`) | `ollama/qwen3.8:27b-256k-gguf4` |

Agent and subagent cards do not pin a model: they inherit the invoking session's provider and model configuration.

## Provider Ids

`ollama/` and `ollama-cloud/` are distinct provider ids in opencode's catalog — `ollama/` targets a local Ollama server, `ollama-cloud/` targets Ollama's cloud-hosting service. They are not aliases.

---

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
