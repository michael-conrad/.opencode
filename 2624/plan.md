<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, derived from the validated 2624/spec.md (revision 3) -->

# Plan — 2624: Harden the ragsync retrieval launch path

## 1. Goal

Implement the validated spec's four-part hardening of the deck's ragsync MCP launch path inside the deck-owned layer, and prove it on the family host: a watchdog launch wrapper (`.opencode/tools/ragsync-launch.py`) that reaps the server tree on client death (SC-1), enforces a configured peak-memory ceiling (SC-2) and thread-pool cap (SC-3) on the supervised tree, applies a host-memory admission gate (SC-4), serializes heavyweight work across the host user via a runtime-dir lock with a journal (SC-5), optionally self-reaps a clientless idle tree (SC-6/SC-7), while preserving retrieval (SC-8) and the co-location contract (SC-9). Surfaces touched: `.opencode/opencode.jsonc`, `.opencode/ragsync-config.yaml` (unchanged except where noted below), new `.opencode/ragsync-hardening.yaml`, new `.opencode/tools/ragsync-launch.py`, `.opencode/docs/ragsync-service.md` (documented-parameter updates riding the items that introduce the parameters).

## 2. Execution surface

- Repository: the `.opencode` deck submodule (all changed files resolve under its path prefix); work runs from the composed parent layout, branch `2624-ragsync-hardening` created in the submodule per the `git-workflow-branch` card after trunk freshness.
- Runtime surfaces: the wrapper is a Python 3 stdio launcher run as `uv run --script` (deck precedent: the `ollama-web-search` registration's `web-search-mcp.py` pattern); the family host provides `/proc` sampling, `prctl`, flock on a user runtime directory (`$XDG_RUNTIME_DIR`, fallback `/tmp/runtime-<user>`), and a warm fastembed model cache (`Qwen/Qwen3-Embedding-0.6B-Q`, ~3.15 GB resident baseline observed live).
- Build/test commands: the parent repo's canonical `cd .opencode && uv sync` / `uv run pytest` for the deck unit suite; the SC instruments are runtime fixtures executed per the behavioral-testing card's tests-v2 harness at PR-check time (`pr-validation` tier — never in the default run; they launch/kill real processes and need minutes).
- Upstream facts already fixed: ragsync `AppConfig` (jsbroks/ragsync-mcp, `src/ragsync_mcp/config.py`) validates its YAML with pydantic `extra="forbid"` — `ragsync-config.yaml` cannot carry hardening keys; hardening defaults live in the wrapper-owned `.opencode/ragsync-hardening.yaml` (SC-9).

## 3. Items — one item per success criterion

Daisy-chained: each item's RED precondition is the previous item's commit. Defaults named GREEN-but-recorded are fixed in `.opencode/ragsync-hardening.yaml` (with inline rationale comments) and mirrored in `docs/ragsync-service.md` by the same item; the values below are the recorded deck defaults, adjustable once during their own item's fixture run with the recorded rationale.

- **Item 1**
  - **Deliverable** — `.opencode/tools/ragsync-launch.py`: launch wrapper that spawns the ragsync service command as its supervised child in its own POSIX process group, with the spec §1.3(a) belt-and-suspenders placed to compose: (i) the **supervised child sets `prctl(PR_SET_PDEATHSIG, SIGTERM)` in its own pre-exec step** (so the server process itself dies directly when its parent — the wrapper — dies, whichever side kills the wrapper: client death taking the wrapper's poll path, or wrapper termination; the pre-exec race window is closed by the child's own getppid check plus the wrapper's side loop); (ii) the **wrapper runs a PPID-poll side loop** that on detected client death terminates the *entire* child process group (`killpg`) within the deadline — covering the group members PDEATHSIG cannot reach directly (uvx-internal descendants) and closing the prctl race; neither mechanism is the sole guarantee because each covers the other's blind spot exactly as the spec records. Stdout/stderr pass through transparently (stdio MCP transport preserved). `.opencode/opencode.jsonc` `mcp.ragsync.command` rewired to `["uv","run","--script","--python-preference","only-managed",".opencode/tools/ragsync-launch.py", "--", "uvx", "--with", "mcp<2", "ragsync", "--config", ".opencode/ragsync-config.yaml"]`. Reap deadline recorded as `reap_deadline_seconds: 30` (rationale: must fall inside the documented 30 s connect window envelope so a dead client's replacement start is not wedged by zombie wrappers).
  - **RED** — Launching the registered command shape with a stub client against a fixture config, then SIGKILLing the stub client while the tree is stdout-quiet/busy: `pgrep -f ragsync` scoped to the fixture tree still shows live processes after the reap deadline — under the current raw-`uvx` registration the orphaned server survives 3+ hours (the incident's first leg).
  - **GREEN** — With the wrapper registered, the same fixture kills the stub client and every process of the tree (wrapper + uvx + python) is gone within `reap_deadline_seconds` (30 s) — reaped with zero stdout dependence.
  - **Tier marks** — authors no default-suite test; instrument is a pr-validation lifecycle fixture (tests-v2 harness), run at PR-check only. Wrapper-internal unit checks (reap-state transitions) are ephemeral scratch if used.
  - **Instrument** — Fixture: launch registered shape against a workspace-scoped fixture config (stub client = a stdio MCP client process the fixture controls), SIGKILL mid-run, poll `pgrep -f ragsync` scoped to the fixture tree until empty; assert full exit ≤ 30 s. One variant runs the kill during the connect/cold-load window (spec §9 row 1).
- **Item 2 (SC-2 — memory ceiling)**
  - **Deliverable** — Ceiling enforcement in `ragsync-launch.py`: a sampler loop reads each tree process's `VmHWM`/`VmRSS` (and thread count via `/proc/<pid>/status`) from `/proc` and, when the tree's summed RSS exceeds `memory_ceiling_bytes`, terminates the whole tree (SIGTERM, then SIGKILL after a grace period) and exits non-zero with the breach logged to stderr (not stdout — transport preserved). Hardening default `memory_ceiling_bytes: 17179869184` (16 GiB; rationale: above the ~3.15 GB embedding baseline with ~5× headroom for growth of the two deck corpora, but 2.4× below the incident's smaller-instance demand of ~39.4 GB observed peak RSS so the incident shape dies, not thrashes). Fixture run records the run-time ceiling value it configures.
  - **RED** — Against the item-1 state the wrapper accepts but ignores hardening keys, so the following SC-2 assertion fails on the fixture: with the ceiling configured (between the embedding-model resident baseline and the uncapped run's sampled peak), the rerun's sampled peak RSS exceeds the configured ceiling — the cap has no enforcement surface, so the fixture's capped rerun behaves identically to its uncapped run.
  - **GREEN** — With `memory_ceiling_bytes` implemented, the same fixture's capped rerun's sampled peak stays ≤ the ceiling; the deliberately-tiny-ceiling variant witnesses tree termination within its grace window (enforcement is active, not decorative).
  - **Tier marks** — pr-validation sampling instrument (tests-v2); no default-suite test.
  - **Instrument** — Fixture run comparison per spec SC-2: one uncapped baseline run recording peak sampled RSS, then the capped rerun asserting `peak ≤ ceiling`; plus a deliberately-tiny-ceiling run witnessing tree termination (proves enforcement is active, not decorative).
- **Item 3 (SC-3 — thread cap)**
  - **Deliverable** — Thread enforcement in the same sampler loop: when the tree's summed live-thread count exceeds `thread_cap`, terminate the whole tree with the breach logged to stderr. Hardening default `thread_cap: 32` (rationale: ≈2× a sane ONNX/tokenizer pool shape for the 2-source deck layout, and 4.7× below the 151 threads observed in the incident's unbounded run; the cap is lethal-by-design — a thread explosion is the incident's second leg and a server that ignores a soft cap has no enforceable cap).
  - **RED** — Against the item-2 state the wrapper ignores `thread_cap`, so the following SC-3 assertion fails on the co-executed fixture run: with the cap configured (between a typical warm-thread count and the run's sampled max), the tree's observed summed thread count exceeds the configured maximum during the run.
  - **GREEN** — With `thread_cap` implemented, the same capped fixture run's thread sampling reports max ≤ 32; the deliberately-tiny-cap variant run witnesses tree termination.
  - **Tier marks** — pr-validation sampling instrument, co-executed on the item-2 fixture runs (near-zero marginal cost per spec §8 SC-3 row); no default-suite test.
  - **Instrument** — Thread sampling during the SC-2 capped run (`/proc/<pid>/status Threads`, summed over the tree); assert observed max ≤ configured cap; tiny-cap variant run witnesses termination.
- **Item 4 (SC-4 — host-memory admission gate)**
  - **Deliverable** — Admission gate in the wrapper before any child spawn: read `MemAvailable` from `/proc/meminfo`; when free host memory is below `admission_min_free_bytes`, the wrapper refuses to admit heavyweight work — it exits non-zero before spawning ragsync, printing a single-line structured refusal to stderr (observably distinguishable: non-zero exit + stderr reason vs a started service). Hardening default `admission_min_free_bytes: 21474836480` (20 GiB; rationale: sized so that admitted heavy work has room for the 16 GiB ceiling plus the resident baseline and normal host load — admission refuses whenever the ceiling itself could not be honored). Re-read per launch/defer-cycle — never a latched refusal (spec §9 row).
  - **RED** — Against the item-3 state the wrapper ignores `admission_min_free_bytes`, so the following SC-4 assertion fails on the fixture: with the threshold set above the host's actual free memory, the launch admits heavyweight work anyway (no refusal state is observable — the process tree starts and produces reindex/vector-store writes).
  - **GREEN** — With the threshold configured above the host's actual free memory, a fixture launch exits non-zero before spawn with the stderr refusal, and no reindex/HNSW work exists in the fixture's artifacts (no vector store writes, no child process ever created).
  - **Tier marks** — pr-validation fixture (tests-v2); one fast launch, no indexing performed; no default-suite test.
  - **Instrument** — Fixture: set `admission_min_free_bytes` above `/proc/meminfo` `MemAvailable`; launch via the wrapper; assert non-zero exit, stderr refusal line, and absence of any child tree (`pgrep` scoped empty) and of vector-store writes in the fixture workspace.
- **Item 5 (SC-5 — same-host heavyweight serialization)**
  - **Deliverable** — Host slot in the wrapper: an `flock(LOCK_EX)` lock on `<runtime_dir>/<lock_name>` is held by the wrapper for exactly the tree's heavyweight-work window and released after it; both the lock path's components are hardening defaults — `lock_name: ragsync-heavyweight.lock` and `runtime_dir: ""` (empty = `$XDG_RUNTIME_DIR`, falling back to a per-user `/tmp/runtime-<uid>` created with 0700) — so the lock path lives in `.opencode/ragsync-hardening.yaml` per SC-9. The heavy-work window is defined observably — from child spawn until the tree settles (sampled summed-RSS growth <5% over a 60 s window) or the tree exits, bounded by `heavy_window_seconds: 1800` (hard failure of the window bound terminates the tree and releases the lock; rationale: covers any plausible full reindex of the two deck corpora with 10× margin over observed warm syncs, while guaranteeing a crashed/wedged holder cannot hold the host's single slot forever). Acquisition honors the client's connect window: a waiter exceeding `lock_wait_seconds: 25` releases without acquiring and exits non-zero with a stderr honest-unavailable line (CON-7 semantics — never wedges startup; spec §9 row). Hold-state facts (window start/end, holder pid) are appended to `<runtime_dir>/ragsync-heavyweight.journal` — this is SC-5's zero-overlap evidence surface. Stale-lock takeover rule (spec §9 row): flock is released by the kernel on holder death, and the journal entry is closed with a `holder-died` record by the next acquirer.
  - **RED** — Against the item-4 state the fixture assertion "the two concurrent instances' heavy-work windows do not overlap" fails when run with external window sampling (per-tree summed-RSS growth windows measured from outside, since the journal surface does not exist yet): both instances reindex concurrently and the windows overlap — the incident's exact multiplication shape.
  - **GREEN** — With the slot and journal live, instance B launched while instance A holds the slot either waits (inside `lock_wait_seconds`) and starts after A releases, or surfaces the honest-unavailable exit — in no run do the two trees' heavy-work windows overlap (journal-verified; the fixture's cross-check uses the same external window sampling, which now agrees with the journal).
  - **Tier marks** — pr-validation two-instance fixture (tests-v2); no default-suite test.
  - **Instrument** — Two-instance fixture per spec SC-5: instance A reindexing holds the slot; instance B launched concurrently (fixture config distinct workspace/ports, same lock); assert from the journal that A's hold window and any B hold window do not overlap, and that B's wait/decline path is one of the two specified outcomes.
- **Item 6 (SC-6 — clientless idle reaper, SHOULD level)**
  - **Deliverable** — Idle self-reaper in the wrapper's poll loop: when the client (parent) is gone *and* the tree performs no work for `idle_timeout_seconds`, the wrapper terminates the tree normally. Work-idleness is read the same way as the ceiling sampler: no growth in summed tree CPU time (`/proc/<pid>/stat` `utime+stime`) and no RSS growth across an `idle_poll_seconds` interval. Hardening default `idle_timeout_seconds: 900` (rationale: comfortably longer than any live MCP request or watch-burst cycle at deck corpus scale, short against the incident's 3-hour orphan window; complements — never replaces — the item-1 watchdog, which covers the busy-clientless class). `idle_poll_seconds: 60`.
  - **RED** — Against the item-5 state, a clientless idle tree runs forever: the SC-6 assertion "self-terminates after the configured idle duration" fails — nothing in the wrapper terminates an idle tree.
  - **GREEN** — With the reaper live, the stub client killed and the tree left idle past `idle_timeout_seconds` + margin: the tree self-exits without any injected signal.
  - **Tier marks** — pr-validation fixture (tests-v2); no default-suite test.
  - **Instrument** — Fixture per spec SC-6: launch, kill stub client, wait idle-timeout + margin, assert tree exit with no signal injection (wrapper log/journal shows the idle-reap path, not the watchdog path — the two reapers must be distinguishable).
- **Item 7 (SC-7 — connected instance survives the idle window)**
  - **Deliverable** — No new artifact: this item verifies the item-6 reaper is not false-positive-prone (spec §8 SC-6 skip cost names a false positive reaping live sessions as worse than not shipping it). The reaper's client-gone condition (PPID poll, not stdout activity) is the guard; documentation of the guarded semantics rides the docs update of item 6.
  - **RED** — Against the item-6-enabled state, the companion fixture (stub client alive and idle beyond the SC-6 window) fails if the reaper terminates a client-connected tree or if the tree stops answering past the window — this RED is only meaningful post-item-6, which the daisy-chain provides.
  - **GREEN** — The connected tree survives the window and still answers a query at window + margin.
  - **Tier marks** — pr-validation companion fixture (tests-v2); no default-suite test.
  - **Instrument** — Companion run of the SC-6 fixture shape with the stub client alive; same window; assert tree alive and an MCP `list_sources` (or trivial tool) call succeeds at window + margin.
- **Item 8 (SC-8 — retrieval preserved under the hardened path)**
  - **Deliverable** — No new artifact beyond any fix this item's run forces: the full hardened path (items 1–7 registered shape) starts and serves its designated corpora. Any startup-path regression found here is fixed inside the owning item's surface (wrapper/registration), never by a new parallel mechanism.
  - **RED** — This item's cycle is the run itself: against the item-7 state, the hardened registered shape has never been exercised end-to-end by an MCP client, so the SC-8 assertion's outcome on that path is unverified — running the instrument is the RED step (a failure here is a silent hardening regression breaking retrieval: transport broken by pass-through, admission misfire, or lock wedge), and the raw-uvx pre-work path it retired is deliberately not re-run to satisfy the check.
  - **GREEN** — The hardened registered shape answers MCP `list_sources` with exactly the fixture's designated sources and a seeded `search` returns ≥1 hit, inside the documented connect envelope.
  - **Tier marks** — pr-validation MCP-invocation fixture (tests-v2); no default-suite test.
  - **Instrument** — Fixture: MCP stdio client (python `mcp<2` client lib via `uv run --with "mcp<2"`) against the fixture config through the wrapper; assert `list_sources` tool content equals the fixture's sources and the seeded `search` returns at least one hit.
- **Item 9 (SC-9 — structural co-location and config placement)**
  - **Deliverable** — `.opencode/docs/ragsync-service.md` final-state pass: the service doc's configuration section describes the wrapper registration, every hardening default and its rationale, the admission-refusal and honest-unavailable semantics, and the hardening-config location — edited in the same diff as the items above (the doc rows ride items 1–6; this item verifies the assembled state). `ragsync-config.yaml` is verified to still pass upstream `AppConfig.from_yaml` untouched.
  - **RED** — Under the pre-work registration, the parse+grep finds no wrapper in the registered command, no `.opencode/ragsync-hardening.yaml`, and no hardening defaults anywhere — the SC-9 assertions fail on every clause.
  - **GREEN** — `opencode.jsonc`'s `ragsync` entry references the wrapper and the wrapper/registered args still name `--config .opencode/ragsync-config.yaml`; `.opencode/ragsync-hardening.yaml` carries all hardening defaults recorded by items 1–6 — `reap_deadline_seconds`, `memory_ceiling_bytes`, `thread_cap`, `admission_min_free_bytes`, `idle_timeout_seconds`, `idle_poll_seconds`, `heavy_window_seconds`, `lock_wait_seconds`, `lock_name`, `runtime_dir` (the lock path's config-resident components, closing SC-9's lock-path clause); `ragsync-config.yaml` parses clean under upstream `AppConfig.from_yaml` with zero hardening keys; the service doc documents the assembled state.
  - **Tier marks** — structural fact checks; no test authored.
  - **Instrument** — Parse `opencode.jsonc` (JSONC-valid, e.g. strip comments then `jq`); assert wrapper + `--config .opencode/ragsync-config.yaml` present; grep `ragsync-hardening.yaml` for the ten recorded defaults enumerated in the item's GREEN; run upstream `AppConfig.from_yaml` against `ragsync-config.yaml` and assert success (and, by `extra="forbid"`, that no hardening key leaked in); read the doc section for the defaults' documentations.

## 4. Dependency order

1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9. Item 1's wrapper is the supervised-child and sampler substrate every later item extends (2–6 add loops inside the item-1 process shape; they rewire the same registration). Item 3's thread sampling co-executes on item 2's fixture runs. Item 7's RED requires item 6's reaper to exist (daisy-chain precondition). Item 8 runs the assembled registered shape, requiring 1–7. Item 9 checks the assembled structural state including defaults recorded by 1–6. No item's RED or GREEN depends on a later item; no cycles.

## 5. Traceability

| Item | SC(s) |
|------|-------|
| 1 | SC-1 (R-1, R-8; R-6 groundwork) |
| 2 | SC-2 (R-2) |
| 3 | SC-3 (R-3) |
| 4 | SC-4 (R-4) |
| 5 | SC-5 (R-5) |
| 6 | SC-6 (R-6) |
| 7 | SC-7 (R-6; R-7 guard semantics) |
| 8 | SC-8 (R-7) |
| 9 | SC-9 (R-8; R-2/R-3/R-4/R-6 default placement) |

Every SC-1..SC-9 covered exactly once; no orphan items.

## 6. Verification summary

- Authored tests: none in the default suite. All SC instruments are runtime behavioral fixtures authored as tests-v2 harness scenarios, tier `pr-validation` — executed at PR-check time only, never in the default run (test-discipline: heavy runtime fixtures launching/killing real processes are never per-commit). Scratch probes during development stay ephemeral.
- Fact checks (runnable at cycle time): item 9's parse/grep/`from_yaml` checks; `cd .opencode && uv run pytest` deck unit suite remains green after the change.
- PR-check-time runs: the nine SC fixtures' executed outputs are the PR body's test evidence.
- No recorded-dispatch evidence classes in this plan.

## 7. Status boundary

No status fields, completion markers, or progress indicators in this plan; implementation state lives in the pipeline, measured cycle history in `.issues/2624/audit/validation.yaml`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
