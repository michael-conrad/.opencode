<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2748; sibling opencode-config#378 -->

# Spec — Deck hygiene: README rewrite, .guidelines removal, .gitignore dedupe, plugin model verification

## 1. Intent and Executive Summary

**Problem Statement.** The deck README documents the replaced ("pre-rip")
deck instead of the current one: it names a guidelines-series layout,
fragment-manager, pair mode, a session-enforcement feature list, a tools
inventory, and an opencode.jsonc shape that no longer exist; it carries the
wrong install URL (`opencode-config.git` — the parent repo's name, not the
deck's `michael-conrad/.opencode.git`); and it instructs dev-branch
submodule tracking although the dev branch was removed and main is the
single trunk. The retired `.guidelines/` fragment-registry directory (6
tracked files) remains in the tree with registry destinations pointing at
deleted task-card paths. The deck `.gitignore` carries an exact duplicate
`/.issues/` line. The plugin loading model is undocumented, so
`plugins: []` in opencode.jsonc misreads as "no plugins wired".

**Root Cause / Motivation.** The #2490-era deck replacement preserved the
README and the `.guidelines/` registry state without reconciling them to
the post-replacement architecture (deck AGENTS.md keeps the pre-rip copy
under `attic/` "pending soak and deletion"); the duplicate gitignore line
is an editing artifact. The plugin question stems from a re-analysis
correction: an earlier session report claimed the plugins were orphaned
because the config's `plugins` array is empty — but V2 auto-discovery
loads `.opencode/plugins/*.ts` regardless, verified in the server log
(both plugins loading at 2026-11-18T19:14Z). The deck's own documentation
never states the auto-discovery model, which is what allowed the wrong
reading.

**Approach Chosen.** Rewrite README.md to describe the current deck
(architecture, configuration, tools, testing, governance, plugin model,
submodule policy); delete `.guidelines/` entirely; fix the `.gitignore`
duplicate and verify deck-specific dot-path coverage; record the
plugin-verification finding as documentation (no code change — both
plugins stay); add a CHANGELOG Unreleased entry.

**Alternatives Considered & Why Discarded.**
- *Patch stale README sections piecemeal* — discarded: every section
  carries pre-rip assumptions (install URL, layout, policy, config shape);
  a rewrite costs less than section-by-section reconciliation and leaves
  no mixed-era text.
- *Delete `.guidelines/` files but keep the directory* — discarded: all
  six files are the retired registry system's parts and nothing references
  the system live; a kept directory implies a live system.
- *Prune generic `.gitignore` entries (OS/IDE/coverage) to leave
  deck-specific entries only* — discarded pending explicit direction: the
  concrete defect is the duplicate line; pruning generic patterns risks
  untracked cross-machine clutter for zero gain. The deck-specific
  coverage itself is complete (verified — see SC-8).
- *Remove or rewire plugins per the "cleanup" premise* — discarded on
  evidence: both plugins load at session server start (opencode.log,
  2026-11-18T19:14Z) and session-enforcement injects the session-context
  block agents run on; removal breaks live behavior. Nothing needs to be
  added back — env-loader exists, is tracked, and is loading.

**Key Design Decisions.**
- The README states the plugin *loading model* (auto-discovery from
  `.opencode/plugins/*.ts`; the config `plugins` array configures extra
  paths) rather than a feature list, so the doc cannot be misread as
  `plugins: []` = disabled.
- The one behavioral-fixture comment referencing
  `.guidelines/commit-workflow.md` (RED-phase history note in
  `tests-v2/behaviors/fixtures/setup/commit-trailer-placement.sh`) is
  retained as dated history — it is a comment, not a runtime dependency.
- Generic ignore patterns stay; `.venv/` and `.ruff_cache/` stay without
  root entries because uv and ruff self-ignore them via their own internal
  `.gitignore` files (verified with `git check-ignore -v`).
- The README avoids hardcoding the default test model string in favor of
  naming the single source of truth (`tests-v2/default-model.sh`,
  `DEFAULT_TEST_MODEL`) — the exact staleness class this spec fixes.

**User Intent / Original Prompt.** "create a spec to track changes then
implement for PR. 1. update README.md 2. the legacy unwanted .guidelines
mess needs to be cleaned up 3. create a release PR to update pointers
after the submodule PR is merged 4. cleanup and fix .gitignore as needed
for deck specific only dot folders and files like .tools/ 5. the plugins
need to be cleaned up - do we need to add back the env-loader?
re-analyze and report" (developer, 2026-11-18). Items 1, 2, 4, 5 are
this spec's scope; item 3 spans the parent repo and is the sibling spec
`opencode-config#378`.

## 2. Not Included

- `attic/` deletion — deck AGENTS.md keeps the pre-rip copy "pending soak
  and deletion"; not named by the developer.
- Generic `.gitignore` pattern pruning — not directed; see Alternatives.
- Parent-repo changes (pointer release PR, parent README/CHANGELOG/
  AGENTS.md) — sibling spec `opencode-config#378`.
- Parent working-tree strays (`1`, `linux-x64-deb`, empty dirs `1968`,
  `2090`, `issues`) and `skills/` content tracked at the parent top level —
  observed in analysis, not named by the developer's items.
- New behavioral-test scenarios — every criterion here is fact-decidable
  content verification (no model runs; ceremony-test retirement policy,
  CM-1).
- Plugin code changes — the verification finding is documentation-only.

## 3. Requirements

- **R-1**: README.md SHALL describe the current post-replacement deck
  such that every factual claim matches verified deck state: floor.md as
  the sole always-injected instruction surface, on-demand card loading
  (37 skill cards, 2 guidelines, 4 agent cards), the four MCP servers, the
  permission-deny/subagent routing pattern, the tools inventory, the
  tests-v2 behavioral harness and the pytest suite, and deck governance
  (provenance headers, upstream PR process, human-merge boundary).
- **R-2**: README.md SHALL state the correct install URL
  (`git@github.com:michael-conrad/.opencode.git`) and main-branch
  submodule tracking, with no dev-branch guidance.
- **R-3**: README.md SHALL document the plugin loading model: local
  plugins auto-discovered from `.opencode/plugins/*.ts`; the opencode.jsonc
  `plugins` array configures additional paths; env-loader injects `.env`
  values into agent shell sessions; session-enforcement injects
  session-init output into model context.
- **R-4**: The `.guidelines/` directory (6 tracked files: README.md,
  ai-identity.md, branch-first-protocol.md, commit-workflow.md,
  registry.yaml, sc-enforcement-gate.md) SHALL be removed from the deck
  repository.
- **R-5**: The deck `.gitignore` SHALL contain no duplicate entries, and
  every deck-specific dot path present in the working tree SHALL resolve
  via `git check-ignore` to an ignore rule.
- **R-6**: CHANGELOG.md Unreleased section SHALL document this change set
  (README rewrite, `.guidelines/` removal, `.gitignore` fix, plugin
  verification).

## 4. Success Criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | README's install command names the deck upstream `michael-conrad/.opencode.git`, matching `.gitmodules` | structural | grep README install section; compare `.gitmodules` url |
| SC-2 | README documents floor.md as the sole always-injected instruction surface and on-demand card loading; statement matches `opencode.jsonc` `instructions` (floor.md only) and the skills/guidelines/agents inventory | structural | read README architecture section vs opencode.jsonc + `ls skills/ guidelines/ agents/` |
| SC-3 | README documents the plugin auto-discovery model and both plugins' purposes; statement matches `plugins/AGENTS.md` V2 contract | structural | read README plugin section vs plugins/AGENTS.md |
| SC-4 | README states main-branch submodule tracking and contains no dev-branch guidance; matches `.gitmodules` `branch = main` | structural | grep README for `dev branch`/`main` tracking text; compare .gitmodules |
| SC-5 | `.guidelines/` fully removed: `git ls-files .guidelines` empty and the directory absent from the working tree | structural | executed `git ls-files .guidelines` + `test -d` |
| SC-6 | No live deck file references `.guidelines` as a functioning surface, apart from the dated RED-phase history comment in `tests-v2/behaviors/fixtures/setup/commit-trailer-placement.sh` | structural | `grep -rn "\.guidelines"` over tracked deck files excluding `attic/` and the stores; diff of remaining hits |
| SC-7 | `.gitignore` contains the `/.issues/` entry exactly once and has no other duplicate lines | structural | `grep -c "/\.issues/" .gitignore` = 1; `sort .gitignore \| uniq -d` empty |
| SC-8 | Deck-specific dot paths resolve to ignore rules: `.tools/`, `.node/`, `.pytest_cache/`, `vector_db/`, `/.issues/` via root `.gitignore`; `.venv/`, `.ruff_cache/` via their internal `.gitignore` (`*`) | structural | executed `git check-ignore -v` per path; recorded match source |
| SC-9 | Deck working tree has no untracked noise after the change | structural | executed `git status --porcelain -uall` → empty |
| SC-10 | CHANGELOG.md Unreleased documents the README rewrite, `.guidelines/` removal, `.gitignore` fix, and plugin verification | structural | read CHANGELOG Unreleased section |

## 5. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| `opencode-config#378` (sibling parent spec) | Sequencing: the parent release PR (item 3) runs after this spec's PR merges; this spec blocks none of the parent work and vice versa | pending (runs later) |
| `git-workflow-branch` / `git-workflow-commit` / `git-workflow-pr` cards | Governing process for the deck feature branch, commits, and PR | satisfied (deck cards) |
| `tools/reference-integrity` | Run before committing agent-facing markdown edits (tests-v2 AGENTS.md §6c) | satisfied (tool present) |

## 6. Traceability

| Requirement | Verified by |
|---|---|
| R-1 | SC-2 |
| R-2 | SC-1, SC-4 |
| R-3 | SC-3 |
| R-4 | SC-5, SC-6 |
| R-5 | SC-7, SC-8, SC-9 |
| R-6 | SC-10 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| Deck README.md (pre-rewrite) | document | `.opencode/README.md` @ 26db2ee96 | read, 2026-11-18 |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | read, 2026-11-18 |
| .gitmodules | config | parent repo root | read, 2026-11-18 |
| plugins/AGENTS.md (V2 contract) | document | `.opencode/plugins/AGENTS.md` | read, 2026-11-18 |
| env-loader.ts / session-enforcement.ts | code | `.opencode/plugins/` | read, 2026-11-18 |
| opencode.log plugin-load lines | log evidence | `~/.local/share/opencode/log/opencode.log` | grep, 2026-11-18 (loading plugin, both ids, 19:14Z) |
| V2 port commit | git history | `07fa1d09c` (fix(2717)) | `git log/show`, 2026-11-18 |
| Deck `.gitignore` + ignore verification | config + execution | `.opencode/.gitignore` | read + `git check-ignore -v` + `git status --porcelain -uall`, 2026-11-18 |
| `.guidelines/` inventory + reference sweep | git + grep | `.opencode/.guidelines/` | `git ls-files`, `grep -rln`, 2026-11-18 |
| Deck pytest suite | execution | `.opencode/tests/` | `uv run pytest` — 194 passed, 30.8s, 2026-11-18 |

## 8. Cost Frame

- SC-1..SC-10 instruments are read/grep/git executions — seconds each,
  no model runs. Acting: one README authoring pass plus mechanical
  deletions.
- Skipping SC-2/SC-4: every consuming session receives wrong setup and
  policy instructions (the README is the deck's front door).
- Skipping SC-5/SC-6: a dead registry system ships in every checkout and
  misleads readers into maintaining fragments that no longer sync.
- Skipping SC-8/SC-9: an unverified ignore surface risks committing
  vendored artifacts (`.tools/` binaries, vector DB) in future work.

## 9. Edge Cases

| Condition | Expected behavior |
|---|---|
| A consuming repo follows the README for submodule setup | Instructions produce a working checkout: correct upstream URL, `main` tracking, pointer rides with real changes |
| Fresh deck clone with no `.venv/` or `.tools/` present | `git status` clean — every path the tools later create resolves to an ignore rule (SC-8 evidence covers paths not yet present via rule, not via existing state) |
| Deletion of `.guidelines/` while the behavioral fixture comment references it | Fixture unaffected — comment-only reference, no runtime read; retained as dated history (SC-6 names it) |
| Agent reads README to judge whether plugins are active | README states the auto-discovery model, so `plugins: []` cannot be misread as a disable (the wrong reading this spec corrects) |
| `git check-ignore` on a path that is tracked (e.g. `tsconfig.json`) | Ignore rules do not apply to tracked files; the coverage check (SC-8) scopes to untracked working-tree dot paths only |

## 10. Completion Gate

Every success criterion passes before the deliverable is complete;
partial implementation is not permitted. The sibling parent spec
`opencode-config#378` executes after this spec's PR merges and is not
part of this gate.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
