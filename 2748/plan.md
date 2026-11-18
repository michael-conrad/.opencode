<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2748; spec .opencode#2748 -->

# Plan — Deck hygiene (.opencode#2748)

## 1. Goal

Implements spec `.opencode#2748`: rewrite the deck README for the
post-replacement deck, remove the retired `.guidelines/` fragment-registry
directory, fix the deck `.gitignore` duplicate, record the plugin
verification finding, and document the set in CHANGELOG.md. Surfaces
touched: `README.md`, `.guidelines/` (deletion), `.gitignore`,
`CHANGELOG.md` — all in the deck repository.

## 2. Execution surface

Deck repository (`michael-conrad/.opencode`, checked out at `.opencode/`),
feature branch `feature/2748-deck-hygiene` cut from the remote trunk tip
(`main`) per `git-workflow-branch`. The working tree is clean at start;
the deck's own tooling (`tools/reference-integrity`, `tools/skildeck
lint`) runs unmodified. All instruments are read-only fact checks — no
test suite, no model run, no fixture.

## 3. Items

### Item 1 — README rewrite

- **Deliverable**: `README.md` rewritten to describe the current deck.
- **RED**: the current README's install section names
  `opencode-config.git` (the parent repo, not the deck upstream
  `michael-conrad/.opencode.git`); its architecture sections describe the
  pre-rip deck (guidelines series, fragment-manager, pair mode,
  dev-branch tracking, a stale `opencode.jsonc` example, a stale tools
  inventory); its plugin documentation predates V2 auto-discovery.
- **GREEN**: rewrite with these sections — deck identity and install
  (correct upstream URL, submodule usage); architecture (`floor.md` as
  the sole always-injected instruction surface, on-demand card loading:
  37 skills, 2 guidelines, 4 agent cards); configuration (`opencode.jsonc`
  shape: agents build/plan, four MCP servers, permission-deny pattern
  routing gmail/math/notebook to their subagents); plugins (V2
  auto-discovery from `.opencode/plugins/*.ts`, config `plugins` array =
  extra paths, env-loader and session-enforcement purposes); tools
  inventory (current); testing (tests-v2 harness summary, pytest suite,
  `skildeck lint`, `reference-integrity`); governance (provenance
  headers, upstream PR process, human-merge boundary, CHANGELOG
  convention); submodule tracking (main branch); testing model named via
  its single source of truth (`tests-v2/default-model.sh`,
  `DEFAULT_TEST_MODEL`) without hardcoding the model string; license MIT.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: SC-1 grep install URL vs `.gitmodules`; SC-2 README
  architecture vs `opencode.jsonc` instructions + `ls skills/
  guidelines/ agents/`; SC-3 README plugin section vs
  `plugins/AGENTS.md`; SC-4 grep for dev-branch guidance (absent) and
  main tracking statement vs `.gitmodules` `branch = main`; plus
  `tools/reference-integrity` single-file mode on the new README before
  commit.

### Item 2 — `.guidelines/` removal

- **Deliverable**: the 6 tracked `.guidelines/` files deleted
  (`git rm -r .guidelines`).
- **RED**: `git ls-files .guidelines` returns 6 files; the directory
  exists.
- **GREEN**: remove the directory; no other change. The dated RED-phase
  history comment in
  `tests-v2/behaviors/fixtures/setup/commit-trailer-placement.sh` stays
  untouched (comment-only reference, named in the spec).
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: SC-5 `git ls-files .guidelines` empty + `test -d
  .guidelines` fails; SC-6 `grep -rn "\.guidelines"` over tracked deck
  files excluding `attic/` and the stores — only the named fixture
  comment remains.

### Item 3 — `.gitignore` dedupe

- **Deliverable**: the duplicated `/.issues/` line removed (exactly one
  occurrence remains; no other change).
- **RED**: `grep -c "^/\.issues/$" .gitignore` returns 2.
- **GREEN**: delete the duplicate line.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: SC-7 count = 1 and `sort .gitignore | uniq -d` empty;
  SC-8 `git check-ignore -v` on `.tools/ .node/ .pytest_cache/
  vector_db/ .issues/ .venv/ .ruff_cache/` with recorded match sources
  (root rules for the first five; internal `.gitignore` `*` for the last
  two); SC-9 `git status --porcelain -uall` empty.

### Item 4 — CHANGELOG entry

- **Deliverable**: CHANGELOG.md Unreleased section documents the change
  set.
- **RED**: the Unreleased section carries no entry for this work.
- **GREEN**: entries under Changed (README rewrite) and Removed
  (`.guidelines/`) plus the `.gitignore` fix and the plugin verification
  finding, each citing `.opencode#2748`.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: SC-10 read the Unreleased section.

## 4. Dependency order

Item 1 → Item 2 → Item 3 → Item 4. The order is commit-chain order on one
branch: the README rewrite lands first (largest reviewed surface; no
item's RED depends on it), the deletion and gitignore fix follow as
independent mechanical changes, and the CHANGELOG entry lands last
because it documents all three. No item's RED or GREEN depends on a
later item.

## 5. Traceability

| Item | Implements |
|---|---|
| Item 1 | SC-1, SC-2, SC-3, SC-4 |
| Item 2 | SC-5, SC-6 |
| Item 3 | SC-7, SC-8, SC-9 |
| Item 4 | SC-10 |

## 6. Verification summary

All four items verify through fact checks (grep/git/read) at cycle time;
no authored tests exist in this plan (content-only change, no behavioral
criteria), and no dispatch-tier evidence is used. `tools/reference-integrity`
(single-file mode on README.md, per tests-v2 AGENTS.md §6c) runs before
the item-1 commit; `tools/skildeck lint` runs once at branch completion
as the deck's consistency gate. The PR carries the executed instrument
outputs.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
