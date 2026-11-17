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

## 4. Default browser channel — msedge presence check

The default browser session doctrine (channel + durable profile + posture)
is owned by the skill card:
Read [the browser-session defaults](../SKILL.md).

Check for the Microsoft Edge channel:

```sh
command -v msedge || test -x /opt/microsoft/msedge/msedge && /opt/microsoft/msedge/msedge --version
```

A version string means the channel is present. If the check fails, jump to
[7. Absent channel](#7-absent-channel---provision-a-vendor-build-into-toolstree).

## 5. Default launch command

Command per current CLI options:

```sh
PATH=<project-root>/.tools/node/bin:$PATH \
  playwright-cli open --browser msedge --persistent \
  --profile ~/.cache/ms-playwright/daemon/ud-bl-persist --headed
```

- `--browser msedge` — the Microsoft Edge channel (default).
- `--persistent --profile …` — the durable saved profile of record; the live
  login-bearing path (`~/.cache/ms-playwright/daemon/ud-bl-persist`). Never
  rewrite the path here if the daemon cache moves — the card text and this
  runbook change together at that time.
- `--headed` — the default posture for interactive web surfaces; headless is
  a non-default fallback for clean API-shape checks only.

The doctrine — when msedge applies, its per-site exception, and when headless
is acceptable — is stated once in the card;
Read [the browser-session defaults](../SKILL.md).

## 6. Login once — plant saved logins in the profile

One developer-performed step per site; the deck never touches credentials:

1. Launch the default headed window (command above) against the target site.
2. The developer signs in manually in the browser window.
3. Cookies/session state land in the durable profile and persist across
   sessions — every later launch of the default command reuses them, on any
   site previously signed in.

## 7. Absent channel — provision a vendor build into `.tools/` tree

Only when the presence check (§4) fails on the machine: the sanctioned
target is the gitignored `<project-root>/.tools/` tree (mirroring the
vendored-Node pattern of §2), never a system-package or `/opt` install and
never an improvised alternate channel. Absence is a provisioning trigger —
not a license to switch channels (the card's per-site exception answers
observed site function, not channel absence).

Download the official vendor build (Microsoft Edge for Linux) into the
gitignored tree and unpack it:

```sh
mkdir -p <project-root>/.tools
# fetch the official vendor distribution for the platform and unpack it:
# e.g. microsoft-edge-stable_*_amd64.deb → extracted under <project-root>/.tools/msedge/
```

Then point the channel at the `.tools/` build via the CLI's JSON config
(`--config`, default `.playwright/cli.config.json`), whose `browser`
section takes `launchOptions` (the settings surface for `channel`,
`executablePath`, `headless`, etc.) — the launchOptions point at the unpacked
`.tools/` binary. The profile of record stays unchanged (§5's command,
same `--profile` path).

---

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
