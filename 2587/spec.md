# Spec: .opencode#2587 — playwright-cli research routing, provisioning runbook, and skildeck symbolic-half retirement

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

Mid-cycle expansion (developer-directed during the same session, after the
card fix surfaced the tool regression live): running `skildeck analyze`
crashes on a reference to the purged `tools/impl/sym-extract`. Developer
directives: "that sym tool was purged multiple revisions ago, it should not be
referenced"; "this reads like skildeck was supposed to have been removed but
was removed incompletely or is doing other things that were supposed to have
been removed, you will need to check repo edit and issue ticket history"; "the
symbolic items are no longer in any of the active skill cards"; disposition
selected after dev review: **full retirement**; "example payloads that were
strictly for the symbolic processing are bitrot; expand the scope … into 1 or
more SCs as appropriate for separation of concerns and atomic level work
units."

## Problem

Two deck surfaces fail together. The playwright-cli card is unreachable from
research intent — nothing in the deck bridges "find information about X" to
"render the page and observe it" — and, once reached, the card cannot produce a
working invocation: it carries no provisioning mechanics at all (no tool
location, no invocation form, no install runbook, no failure-mode warning).
Because `.tools/` is gitignored (parent `.gitignore` line 26), every fresh
checkout lacks the vendored toolchain, so the missing runbook is a structural
gap, not a documentation nicety.

A third, independent defect surfaced mid-cycle: the skildeck tool's
symbolic-processing half is retired machinery left wired to purged scripts.
History: `.opencode#1838` (commit `242fe174`) removed the `yaml+symbolic`
blocks from the 64 files that carried them (the commit touches 67 files:
64 modified + 3 deleted registry files; 88 block lines removed) — the
extraction input data no longer exists in any active card; `.opencode#872` (commit `ac01ea75`) declared the entire
`sym-*` suite (15 scripts, including `sym-extract`) dead — "the AI agent never
discovers or dispatches them" — and replaced it with the Z3 solve tool (today's
vendored `formal` adapter / formal-tooling card), deleting all 15 scripts;
commit `a348eed0` added the shared `sym_extract_lib.py` and re-pointed only
`skildeck-extract` and `skildeck-gates`, leaving `skildeck-analyze`,
`skildeck-export`, `skildeck-watch`, and `skildeck-lint` loading the purged
module. Verified live: `skildeck exhaustive` → "Error: analysis script not
found"; `skildeck analyze` → `FileNotFoundError: …/tools/impl/sym-extract`;
the same purged-module load sits in `skildeck-export` and `skildeck-watch`;
`skildeck-lint` carries a dead `_load_sym_extract()`; `skildeck-lint`'s
`lint_all()` and `skildeck-verify-structure` parse `yaml+symbolic` fences and
classify `state_machines`/`gates`/`evidence_artifacts`/`decomposition` —
vocabulary that no active card carries; `schema_v2.py` ("Schema v2.0
validation for symbolic model blocks") is loaded by nothing. The only
consumer of skildeck in the entire active deck or test corpus is `lint`
(`tests-v2/test-skill-deck-completeness.sh`; the `test-enforcement.sh`
"skildeck standalone" tag). Minimal repair (re-pointing the broken loaders at
`sym_extract_lib.py`) would keep extraction/analysis tooling alive whose input
data was deleted and whose engine was declared dead and replaced — full
retirement is the developer-selected disposition.

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
7. **Full retirement of the skildeck symbolic-processing half** (developer
   disposition after dev review). The dispatcher's ANALYSIS surface, all
   symbolic-consuming scripts, the shared extraction library, the dead
   symbolic validator, and lint's symbolic residue are removed; skildeck keeps
   exactly the prose-era machinery: `lint`, `validate`, `verify-acceptance`,
   `verify-issue`. Minimal repair was rejected: extraction tooling whose input
   data no longer exists anywhere in the deck cannot produce a non-vacuous
   result.
8. **Bitrot sweep, zero payloads found.** No symbolic-processing example
   payload survives in the active deck: the `formal-tooling` card's yaml block
   is the live `formal` adapter's shared-state schema example, the
   `behavioral-testing` evaluation yaml is the live evaluation-artifact
   format, and the `#2272` fixtures (three files:
   `2272-sc1-audit-status-reconciliation.sh`,
   `2272-sc2-git-workflow-pr-status-reconciliation.sh`,
   `2272-sc3-shared-status-check-skip.sh`; two of the three use
   `evidence_artifacts`) as the
   behavioral harness's own contract vocabulary — none are symbolic-processing
   payloads. Any symbolic-processing example payload discovered during
   implementation is bitrot and is removed, not migrated.
9. **Retirement recorded in the deck-debt ledger** (`.opencode#2534`), per
   skill-creator's retirement gate: the decision, its #872/#1838 provenance,
   and the retired file list.
10. **The ragsync index is live derived data, not symbolic payload.**
    `vector_db/chroma.sqlite3` (untracked, gitignored at
    `.opencode/.gitignore:27`, 36 MB binary, `ragsync-config.yaml`
    `persist_directory: ./vector_db`, rebuilt 2026-10-11) embeds indexed
    source text including 54 historical `yaml+symbolic` occurrences — sourced
    from indexed attic content — and serves the ragsync retrieval MCP. It is
    regenerated by ragsync reindex, not by this change; deleting it would
    break live retrieval. The SC-7 and SC-9 grep instruments therefore match
    text files only (`grep -I`).

## Fix shape

Card fix:

| Artifact | Change |
|---|---|
| `skills/playwright-cli/SKILL.md` | Description gains research-adjacent intent phrases — rendering a JS-heavy page that fetch tooling returns as shell HTML, observing what a page actually renders, interactive web verification — appended after the original description string so every pre-change phrase survives contiguously. Body gains a provisioning pointer: the CLI is vendored per-project at `<project-root>/.tools/node/`, invocation is PATH-prefixed (`PATH=<project-root>/.tools/node/bin:$PATH playwright-cli …`), full setup runbook in `references/install.md`. |
| `skills/playwright-cli/references/install.md` | New file. Grounded runbook: (a) check step — PATH-prefixed `playwright-cli --version`; (b) install steps — unpack an official Node.js distribution (v22.x) to `<project-root>/.tools/node/`, then `PATH=<project-root>/.tools/node/bin:$PATH npm install -g @playwright/cli`; (c) verify step — PATH-prefixed `--version` prints the version; (d) note that `.tools/` is gitignored and never committed, matching the vendored-tooling pattern (`formal-tooling` card's `.tools/z3/` runbook is the in-deck precedent); (e) named hazard — bare invocation resolves an ambient system node and fails the Node-20 version check; always PATH-prefix. |
| `skills/research/SKILL.md` | One bridge line added to the body: JS-rendered or interaction-dependent pages → load playwright-cli (browser rendering when search/fetch tooling returns shell HTML). Nothing else in the card changes. |

Skildeck retirement:

| Artifact | Change |
|---|---|
| `tools/skildeck` (dispatcher) | `ANALYSIS` table, `SYM_DIR`, and the "Analysis modules" help block removed; the module docstring is rewritten — the `DESCRIPTION:` line ("Lint, analyze, and export symbolic models from guidelines and skills") and the five `Example:` lines invoking removed actions (`gates`, `export`, `exhaustive`, `enforcement`, `verify-structure`) lose every symbolic-processing reference; `ACTIONS` reduced to `lint`, `validate`, `verify-acceptance`, `verify-issue`; removed actions exit as unknown-action errors. |
| `tools/impl/skildeck/skildeck-analyze`, `skildeck-export`, `skildeck-watch`, `skildeck-extract`, `skildeck-gates`, `skildeck-verify-structure`, `sym_extract_lib.py`, `schema_v2.py` | Deleted — symbolic extraction/analysis/validation machinery; `schema_v2.py` is loaded by nothing. |
| `tools/impl/skildeck/skildeck-lint` | Dead `_load_sym_extract()`, the symbolic `lint_all()` with its `FENCE_PATTERN` (```yaml+symbolic parsing of rules/gates/evidence_artifacts/state_machines), and the `--gate`/`--skill`/`--scope` filters that exist solely for `lint_all` are removed; `lint_skill_frontmatter`, `lint_skill_deck_completeness`, the `.skilldeck-ignore` machinery, and `--dir`/`--json` are unchanged. |
| `.opencode#2534` (deck-debt ledger) | Comment recording the retirement decision, its #872/#1838 provenance, and the retired file list. |

Untouched: `floor.md`, `routing.md`, all other cards, the attic,
`skildeck-validate`, `skildeck-verify-acceptance`, `skildeck-verify-issue`,
the `formal` tool and its vendored binary, the two live yaml examples
(`formal-tooling` state schema, behavioral-testing evaluation format).

Reference currency: all deck paths above exist in the holding repo's deck copy
as of this session (`skills/playwright-cli/SKILL.md`,
`skills/research/SKILL.md`, and the `tools/` scripts read live;
`references/install.md` is created by this change; the validation-standards
reference under `skills/spec/references/` is live). No dead references.

## Success criteria

Work units are atomic and separation-of-concerns ordered: the card fix
(SC-1–SC-5), the dispatcher retirement (SC-6), the script deletions (SC-7),
the lint residue removal (SC-8), the bitrot sweep (SC-9), and the ledger
record (SC-10). Each unit's containment check runs at that unit's completion,
before its commit.

### SC-1 (structural) — card-fix scope containment

The card-fix work unit touches exactly `skills/playwright-cli/SKILL.md`, new
`skills/playwright-cli/references/install.md`, and `skills/research/SKILL.md`,
and nothing else anywhere in the deck repo.

- **Verify:** at the card-fix unit's completion, before its commit,
  `git status --porcelain -uall` in the deck repo shows exactly three entries
  — modified `skills/playwright-cli/SKILL.md`, modified
  `skills/research/SKILL.md`, untracked
  `skills/playwright-cli/references/install.md` — and nothing else
  (`git status --porcelain -uall` is the instrument: plain `git diff --stat`
  never shows untracked files, and without `-uall` a wholly-new directory
  collapses to a directory-level entry instead of the file-level entry named
  here).

### SC-2 (structural) — research-routing phrases present, existing phrases intact

The playwright-cli description states all three research-adjacent intents
(JS-heavy-page rendering when fetch tooling returns shell HTML; observing
rendered page content; interactive web verification) and every
browser-automation phrase from the pre-change description survives.

- **Verify:** read the card frontmatter; the three intents are present, and
  the full pre-change description string — readable via
  `git show <base>:skills/playwright-cli/SKILL.md` at the change's base commit
  — appears in full within the post-change description (substring check
  against the actual base text, not an enumerated phrase list, so no
  pre-change phrasing can be dropped while passing).

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

### SC-6 (structural) — dispatcher symbolic surface removed

`tools/skildeck` carries no symbolic-processing dispatch surface — code,
docstring, or help output.

- **Verify:** grep the dispatcher file for `ANALYSIS`, `SYM_DIR`, `sym-`,
  `symbolic`, and the removed action names (`analyze`, `export`, `watch`,
  `extract`, `gates`, `exhaustive`, `entailment`, `guards`, `enforcement`,
  `triggers`, `decomposition`, `verify-structure`) — zero hits;
  `./.opencode/tools/skildeck` with no args lists exactly `lint`,
  `validate`, `verify-acceptance`, `verify-issue` as actions and no
  "Analysis modules" section; invoking a removed action (`exhaustive`,
  `analyze`) exits non-zero with an unknown-action error naming the available
  actions.

### SC-7 (structural) — symbolic scripts deleted

The eight symbolic scripts are gone and no reference to them survives.

- **Verify:** `ls tools/impl/skildeck/` contains exactly `skildeck-lint`,
  `skildeck-validate`, `skildeck-verify-acceptance`,
  `skildeck-verify-issue`; `git status --porcelain` shows the eight `D`
  entries; a text-only grep (`grep -rIn`, binaries excluded per Decision 10)
  across the entire active deck repo — every tracked path excluding `attic/`
  and `.issues/` — for `sym-extract`, `sym_extract_lib`, `schema_v2`,
  `skildeck-analyze`, `skildeck-export`, `skildeck-watch`,
  `skildeck-extract`, `skildeck-gates`, `skildeck-verify-structure`, and
  `yaml+symbolic` returns zero hits **outside
  `tools/impl/skildeck/skildeck-lint`** — lint still carries its
  `sym-extract` residue at this checkpoint and SC-8 removes it; SC-9's
  post-SC-8 sweep re-runs this deck-wide check with no exclusions.

### SC-8 (structural) — lint symbolic residue removed, lint stays green

`skildeck-lint` retains only its prose-era machinery.

- **Verify:** grep `skildeck-lint` for `_load_sym_extract`, `lint_all`,
  `FENCE_PATTERN`, `state_machines`, `evidence_artifacts`, `gate_filter`,
  `scope_filter`, `skill_filter`, and `--gate` — zero hits; `skildeck lint`
  on the live deck reports zero findings; `skildeck lint --json` still emits
  a parseable JSON array.

### SC-9 (structural) — no symbolic example payload left behind

The deck and the retained tooling carry no symbolic-processing example
payload.

- **Verify:** a text-only grep (`grep -rIn`, binaries excluded per
  Decision 10) over the active deck surfaces (`skills/`, `guidelines/`,
  `floor.md`, `routing.md`, `AGENTS.md`, excluding `attic/`) for the
  symbolic-block key forms — `yaml+symbolic`, `state_machines`,
  `sub_agent_dispatch`, and the block-key colon forms `decomposition:`,
  `evidence_artifacts:`, `gates:`, `rules:` inside fenced yaml — zero hits
  (bare prose words such as "decomposition" in the explore/plan card
  descriptions are not block keys and are not matched); the same text-only
  grep over the whole active deck repo excluding `attic/` and `.issues/` —
  now with no path exclusions — for `sym-extract`, `sym_extract_lib`,
  `schema_v2`, `skildeck-analyze`, `skildeck-export`, `skildeck-watch`,
  `skildeck-extract`, `skildeck-gates`, `skildeck-verify-structure`, and
  `yaml+symbolic` returns zero hits, completing SC-7's deferred full sweep;
  the two live yaml examples (`formal-tooling` shared-state schema,
  behavioral-testing evaluation format) are still present, confirming the
  sweep removed nothing live.

### SC-10 (structural) — retirement recorded in the deck-debt ledger

`.opencode#2534` carries a comment recording the skildeck symbolic-half
retirement: the decision, the #872/#1838 provenance, and the retired file
list.

- **Verify:** `./.opencode/tools/local-issues read-comments --number
  .opencode#2534` shows the retirement entry.

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
- Retiring `skildeck-validate`, `skildeck-verify-acceptance`,
  `skildeck-verify-issue` — prose-era machinery, no symbolic inputs, retained
  per the developer-selected disposition.
- Attic deletion (rip stage 5, soak-gated) — separate workstream.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
