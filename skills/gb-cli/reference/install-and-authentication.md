<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: gb CLI, gb-cli, GitBucket CLI, install, version pinning, TOOL_MISSING
tier: 2
load_when: sub-agent
---

# gb CLI — Install and Authentication Reference

> Canonical home for the gb CLI install/version-pinning/TOOL_MISSING content (demoted from [`.opencode/AGENTS.md`](../../AGENTS.md), #2427 scope E). Reach this content through the one-line pointer retained in AGENTS.md. The [`gb-cli` skill](../SKILL.md) is the canonical entry point for all `gb` command operations.

## Overview

This repo uses the [`gb` CLI](https://github.com/Masahiro-Obuchi/gitbucket-cli-rs) (v0.6.1) for all GitBucket API operations. The `gb` tool replaces the previous bespoke `gitbucket-api` Python tool. Agents performing `gb` workflows MUST dispatch the [`gb-cli` skill](../SKILL.md) — it is the canonical entry point for all `gb` command operations.

## Install by Platform

| Platform | Download URL | Install Commands |
|----------|-------------|------------------|
| Linux x86_64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-x86_64-unknown-linux-gnu.tar.gz` | `curl -L <url> \| tar xz && sudo mv gb /usr/local/bin/` |
| macOS x86_64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-x86_64-apple-darwin.tar.gz` | `curl -L <url> \| tar xz && sudo mv gb /usr/local/bin/` |
| macOS arm64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-aarch64-apple-darwin.tar.gz` | `curl -L <url> \| tar xz && sudo mv gb /usr/local/bin/` |
| Windows x86_64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-x86_64-pc-windows-msvc.zip` | Expand archive and add to PATH |

## Version Pinning

Pin to `v0.6.1`. Verify with `gb --version` before use. The version check is enforced at skill entry — agents MUST NOT proceed if `gb --version` reports `< 0.6.1`.

## Authentication Verification

`gb` CLI operations without authentication checks fail silently — auth verification is REQUIRED before any `gb` command. Dispatch the [`gb-cli` skill](../SKILL.md) → `authenticate` task first; it verifies `gb --version` (>= 0.6.1) and credential liveness before any operation proceeds.

## TOOL_MISSING Detection

When `gb` is not found, skill task files return `BLOCKED` with `reason: TOOL_MISSING`. The retry pattern:

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found. Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs"
  return 1
fi
```

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*
