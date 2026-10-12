<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2587 -->

# playwright-cli — provisioning runbook

The CLI is vendored per-project at `<project-root>/.tools/node/`. That path is
gitignored (matches the vendored-tooling pattern of `formal-tooling`'s
`.tools/z3/`), so a fresh checkout has no toolchain — provision it on first
use.

## 1. Check

```sh
PATH=<project-root>/.tools/node/bin:$PATH playwright-cli --version
```

A version string on stdout (observed: `0.1.21`) means the toolchain is
present and working — stop here.

## 2. Install

Unpack an official Node.js distribution (v22.x) to `<project-root>/.tools/node/`:

```sh
mkdir -p <project-root>/.tools
tar -xzf node-v22.x.y-linux-x64.tar.xz -C <project-root>/.tools
mv <project-root>/.tools/node-v22.x.y-linux-x64 <project-root>/.tools/node
```

Then install the CLI globally under the vendored toolchain:

```sh
PATH=<project-root>/.tools/node/bin:$PATH npm install -g @playwright/cli
```

## 3. Verify

```sh
PATH=<project-root>/.tools/node/bin:$PATH playwright-cli --version
```

Must print a version string. Cross-check the global install:

```sh
PATH=<project-root>/.tools/node/bin:$PATH npm ls -g
```

lists `@playwright/cli` alongside `npm` and `corepack`.

## Hazard — bare invocation

Never run bare `playwright-cli …`. It resolves the ambient system node (e.g.
Node 18) and dies at Playwright's Node-20 version check:

```
You are running Node.js 18.19.1. Playwright requires Node.js 20 or higher.
```

Always PATH-prefix with `<project-root>/.tools/node/bin:$PATH`.

---

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
