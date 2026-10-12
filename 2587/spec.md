# Spec: .opencode#2587 — playwright-cli research routing and provisioning runbook

Provenance: developer directive 2026-10-12 in-session — regression report ("the
agent is not using playwright as an additional tool for web searching or other
web research, and when it is instructed to use playwright, the skill card seems
to be missing the `<project-root>/.tools/` repo setup information"), with the
scope constraint "keep the scope narrow-ish so that progressive disclosure is
maintained", the design selection "items: a2, b2", and authorization through
spec. Observed failures, verified live in the working checkout the same day:

1. Bare `playwright-cli --help` fails — the wrapper resolves ambient
   `/usr/bin/node` (18.19.1) and dies at Playwright's Node-20 version check
   ("You are running Node.js 18.19.1. Playwright requires Node.js 20 or
   higher."). `PATH=<project-root>/.tools/node/bin:$PATH playwright-cli
   --version` succeeds: vendored Node v22.14.0, `@playwright/cli@0.1.21`
   (confirmed via `npm ls -g` under the vendored toolchain).
2. No routing path reaches playwright-cli from research intent: `routing.md`
   maps "discovering information or investigating root causes" to
   `research`/`systematic-debugging`; the `research` card body never mentions
   playwright or rendered pages; the playwright-cli description matches only
   browser-automation intents. A JS-heavy page that fetch tooling returns as
   shell HTML has no on-demand fallback to rendered observation.
3. Origin: the `.opencode#2490` deck rip — stage 2c (commit `839190c1`) rewrote
   the connector card slim; the pre-rip card (preserved at
   `attic/skills/playwright-cli/SKILL.md`) explicitly covered "browsing the
   web" and carried provisioning-adjacent tooling permissions; the closed
   compliance audit `.opencode#1498` had verified the *old* description's
   coverage, so the slim rewrite is the regression point.

## Problem

Two deck surfaces fail together. The playwright-cli card is unreachable from
research intent — nothing in the deck bridges "find information about X" to
"render the page and observe it" — and, once reached, the card cannot produce a
working invocation: it carries no provisioning mechanics at all (no tool
location, no invocation form, no install runbook, no failure-mode warning).
Because `.tools/` is gitignored (parent `.gitignore` line 26), every fresh
checkout lacks the vendored toolchain, so the missing runbook is a structural
gap, not a documentation nicety.

## Decisions (developer-stated unless noted)

1. **A2 — routing depth.** Research-adjacent intent phrases go into the
   playwright-cli card description, plus a one-line bridge in the `research`
   card body. `routing.md` is not extended: it is always-injected context, and
   every phrase added there costs every session; descriptions surface at
   dispatch time and bodies on load. A3 (routing.md row extension) is held in
   reserve only if description-matching demonstrably fails to dispatch.
2. **B2 — provisioning shape.** A two-line provisioning pointer in the card
   body; the full runbook lives at
   `skills/playwright-cli/references/install.md` — the email-management
   pattern (`references/install.md`). B1 (inline runbook) rejected: the card
   stays lean and the runbook loads only when provisioning actually happens.
3. **`allowed-tools` frontmatter not restored.** Zero current cards carry it —
   it is a dead post-rip convention.
4. **Commands-reference not restored from attic.** Restoring the pre-rip
   commands reference is scope creep beyond the stated regression.
5. **Floor untouched.** playwright is not added to the floor's external-access
   table; the deck's dispatch mechanism is descriptions plus the routing index,
   both of which already present the card on demand.
6. **Structural verification only.** The remediation is deck text; behavioral
   runs (tests-v2 harness) to confirm routing fires in a live session were not
   requested and are disproportionate to a two-card text fix.

## Fix shape

| Artifact | Change |
|---|---|
| `skills/playwright-cli/SKILL.md` | Description gains research-adjacent intent phrases — rendering a JS-heavy page that fetch tooling returns as shell HTML, observing what a page actually renders, interactive web verification — while every existing browser-automation phrase is preserved verbatim. Body gains a two-line provisioning pointer: the CLI is vendored per-project at `<project-root>/.tools/node/`, invocation is PATH-prefixed (`PATH=<project-root>/.tools/node/bin:$PATH playwright-cli …`), full setup runbook in `references/install.md`. |
| `skills/playwright-cli/references/install.md` | New file. Grounded runbook: (a) check step — PATH-prefixed `playwright-cli --version`; (b) install steps — unpack an official Node.js distribution (v22.x) to `<project-root>/.tools/node/`, then `PATH=<project-root>/.tools/node/bin:$PATH npm install -g @playwright/cli`; (c) verify step — PATH-prefixed `--version` prints the version; (d) note that `.tools/` is gitignored and never committed, matching the vendored-tooling pattern (`formal-tooling` card's `.tools/z3/` runbook is the in-deck precedent); (e) named hazard — bare invocation resolves an ambient system node and fails the Node-20 version check; always PATH-prefix. |
| `skills/research/SKILL.md` | One bridge line added to the body: JS-rendered or interaction-dependent pages → load playwright-cli (browser rendering when search/fetch tooling returns shell HTML). Nothing else in the card changes. |

Untouched: `floor.md`, `routing.md`, all other cards, the attic.

Reference currency: all deck paths above exist in the holding repo's deck copy
as of this session (`skills/playwright-cli/SKILL.md` and
`skills/research/SKILL.md` read live; `references/install.md` is created by
this change; the validation-standards reference under
`skills/spec/references/` is live). No dead references.

## Success criteria

### SC-1 (structural) — scope containment

The change touches exactly `skills/playwright-cli/SKILL.md`, new
`skills/playwright-cli/references/install.md`, and `skills/research/SKILL.md`.

- **Verify:** `git diff --stat` for the change shows exactly those three paths
  (plus the new-file entry), and no others.

### SC-2 (structural) — research-routing phrases present, existing phrases intact

The playwright-cli description states all three research-adjacent intents
(JS-heavy-page rendering when fetch tooling returns shell HTML; observing
rendered page content; interactive web verification) and every
browser-automation phrase from the pre-change description survives.

- **Verify:** read the card frontmatter; the three intents are present, and the
  pre-change description's phrases (navigating pages, filling forms, capturing
  snapshots, verifying web UIs, scraping rendered content, recording browser
  traces) are each present.

### SC-3 (structural) — research-card bridge present

`skills/research/SKILL.md` contains a line directing agents to load
playwright-cli for JS-rendered or interaction-dependent pages.

- **Verify:** read the card; the bridge line is present.

### SC-4 (structural) — provisioning pointer present

The playwright-cli card body states: the tool lives vendored per-project at
`<project-root>/.tools/node/`; invocation requires the PATH prefix
`PATH=<project-root>/.tools/node/bin:$PATH`; the full runbook is at
`references/install.md`.

- **Verify:** read the card; all three statements are present.

### SC-5 (structural) — runbook grounded and executable

`skills/playwright-cli/references/install.md` contains the five content
elements (check step, install steps, verify step, gitignored-`.tools/` note,
ambient-node hazard), and its commands match the observed working state of the
vendored toolchain.

- **Verify:** read the file for the five elements; then execute the runbook's
  verify command in the working checkout and observe a version string on
  stdout; confirm the install steps match the live toolchain state
  (`npm ls -g --prefix <project-root>/.tools/node` lists `@playwright/cli`).

## Out of scope

- `routing.md` and `floor.md` changes — progressive-disclosure constraint;
  A3 held in reserve.
- `allowed-tools` frontmatter restoration — dead post-rip convention.
- Commands-reference restoration from the attic — scope creep.
- Behavioral runs confirming routing fires in a live agent session — not
  requested; the remediation is deck text and structural instruments carry
  verification.
- Provisioning the toolchain in any repo other than verifying the documented
  runbook against the working checkout.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
