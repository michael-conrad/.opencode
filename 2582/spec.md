<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated; evidence base: design session 2026-10-11 (live-verified environment facts), developer directives recorded in §1.6; .opencode/tests-v2/AGENTS.md; .opencode/tests-v2/behaviors/helpers.sh; .opencode/tests-v2/with-test-home; .opencode#2538 -->

# [SPEC] Dockerized test environment for tests-v2 with tiered execution (clean-room probe / Docker / host)

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The tests-v2 behavioral harness isolates by host-process convention: an `env -i` allowlist, XDG redirection, `SNAP_USER_DATA` overrides, and a production-DB sha256 before/after check. Every isolation mandate in that surface is procedural — it exists because a leak happened (snap DB pollution, desktop-app SQLite session conflicts, the #2538 credential-passthrough regression) — and each violation class remains *possible*, only forbidden. Separately, GitBucket provisioning (`__ensure_gitbucket()` in `behaviors/helpers.sh`, ~270 lines) manages a host JDK download, a WAR download, `ss -tlnp`-based port discovery, a cookie-jar token mint, and pid/port state files. Separately again, `with-test-home` copies `opencode` and `uv`/`uvx` from the host's `.tools/` into every test home — pre-provisioning the test environment with agent-managed tooling, which pre-answers "can the agent set up its project directory itself" and hides agent-provisioning defects from every behavioral run. And the harness has no Docker usage at all: the developer directed an analysis of a Docker-based test environment, which produced the design this spec records. |
| 2 | **Root Cause / Motivation** | The isolation value of the current harness lies on the filesystem/environment-state axis — where every recorded incident lives — but it is enforced procedurally (greps, sha256 comparisons, allowlists) rather than structurally. The GitBucket "container" named in tests-v2/AGENTS.md §12 is not a container but a host Java process, so its lifecycle complexity is structural, not incidental. The `.tools/` copies into test homes are contamination the developer explicitly ruled against: "the test host home should absolute not have copies of .tools/ or other local only folders that the opencode agent directly manages. otherwise the tests are always contanimated with assumptions about what is already available and that it will hide any issues with the agent setting up the project directory for things like .tools/ when it needs them added." The developer further directed a three-tier testing strategy rather than a binary host/Docker choice. |
| 3 | **Approach Chosen** | Commit Dockerfiles under `.opencode/tests-v2/docker/` and run behavioral scenarios in a test container on `--network host` whose only host mount is `tmp/`. The test-agent image carries a desktop-class Ubuntu userland baseline with an Xvfb display stack and bakes the sanctioned base system tools (`opencode`, `uv`/`uvx`, git, python3, curl); the test home starts bare of agent-managed tooling. GitBucket moves into its own container built from a committed Dockerfile with the WAR staged from `tmp/` scratch, its port Docker-assigned at container creation and discovered via `docker port`. Scenario scripts carry a tier designation routing them to one of three execution tiers: tier-1 direct clean-room sub-agent probes (for simple card changes; eligibility is agent judgment), tier-2 the Docker harness (default), tier-3 the existing host harness (reserved for scenarios that fight the container). The `behavioral-testing` skill card is amended to scope its harness-only mandate per tier, host-path isolation mandates are scoped to the host tier, and the harness spec (§4, §5, §9, §10, §12, plus a new Docker isolation-contract section, of tests-v2/AGENTS.md) gains the Docker isolation contract and the Docker failure-domain playbook entries. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Bridge networking with socat reflection of host-loopback services onto a pinned-subnet gateway — discarded: the developer chose simple isolation; under bridge, Ollama's loopback-only bind (verified: `127.0.0.1:11434`) forces reflection machinery (socat unit, pinned subnet, baseURL parameterization in two seed functions, a GB_HOST split between host-ops and in-container URLs) that host networking makes unnecessary, and host networking is network-neutral relative to today's host-mode runs, so no isolation is lost on any axis where an incident occurred. (b) Rebinding Ollama to `0.0.0.0` — discarded: touches the production systemd unit and exposes an unauthenticated API on all interfaces; unnecessary under host networking. (c) The public `gitbucket/gitbucket` Docker image — discarded: the developer ruled it "very stale" (verified: the locally cached image is a JDK8-base ~2021 build, while the harness runs the current WAR on Temurin 21). (d) Baking the GitBucket WAR into a custom image — discarded: adds a rebuild-and-tag step on every WAR refresh; the committed Dockerfile + WAR staged from `tmp/` scratch at provision time keeps the existing download-and-cache logic as the version source of truth. (e) Full Cinnamon/GUI desktop stack in the image — discarded: ~3 GB of image that never renders; the developer accepted Xvfb plus screenshot tooling as the display affordance, which they explicitly requested ("can we include xvfb for it to use so it can do screenshot type stuff in container?"). (f) Mounting `.tools/` read-only into the container — discarded by developer directive: production folders are not shared with the container at all, and staging copies live under `tmp/` scratch; the image bakes the sanctioned base tools at build time via their official upstream channels, so no build-context dependency on `.tools/` exists either. (g) Docker-only cutover with wholesale retirement of host-path mandates — discarded by developer directive: three tiers, with both harnesses maintained, "use docker for tests that work well with it, reserve the test framework for tests that won't work well with docker or become excessively complication." (h) A scripted tier-1 eligibility checklist — discarded by developer directive: eligibility is "agent determination"; intent-decidable rules are never scripted (floor safety principle). |
| 5 | **Key Design Decisions** | (1) `--network host` is network-neutral versus today: the test agent can already reach every host service in host mode, so the container gains no new reach; the isolation purchased is structural on the filesystem/environment-state axes where all incidents occurred. (2) The mount boundary is exactly `tmp/`: test homes, artifacts, the live session DB, and the staging scratch all live under `tmp/`, keeping `poll-run.sh`, `__export_sqlite_to_yaml()`, the clean-room evaluator, and the two-SC pattern host-side and unchanged. (3) The test home starts bare: `with-test-home`'s binary and uv copy steps are removed on the Docker path; the image's baked tools are the harness's own instruments (the launcher must exist to launch the agent), and everything agent-managed (project `.tools/`, MCP dependencies beyond the deck's stdio servers, provisioned state) starts absent so scenarios exercise real provisioning paths. (4) The image installs its base tools at build time from official upstream channels at pinned versions — visible, reviewable, reproducible; `.tools/` continues to serve only the host tier. (5) The container runs as the host uid (`--user`): a root-in-container with a write mount of repo-adjacent paths would be a privilege escalation relative to today, and host-uid execution also avoids root-owned files in `tmp/` and git's dubious-ownership refusal when `with-test-home` inspects the mounted store. (6) Docker-assigned GitBucket port replaces `--port=0` + `ss` discovery; `docker port` is the discovery instrument; `GB_HOST`/`GITBUCKET_PORT`/`GB_TOKEN` are exported from the provisioned instance exactly as today. (7) `docker run -d` plus `docker stop`/`docker rm -f` replaces the foreground-launch + `setsid` kill dance (helpers.sh L2071–2079): container kill is a guaranteed whole-tree kill, strictly stronger than the host-mode mechanism it replaces. (8) No URL parameterization: `baseURL` stays `http://localhost:11434/v1` and `GB_HOST` keeps its existing shape, because host networking makes one URL form valid from both host and container. (9) GPU tooling stays out of the image — the developer ruled "gpu in container is not needed at this time"; the `ollama-probe hw`/`nvidia-smi` observation delta inside the container is a documented known difference. (10) Tier-1 evidence is a recorded clean-room dispatch (prompt + verdict), a sanctioned behavioral-evidence path added to the `behavioral-testing` card, whose "harness only" mandate is thereby scoped rather than deleted. (11) The Docker failure domain (daemon down, port conflict, stale container, image pull failure) enters the §10 playbook as named failure classes with fail-fast `HARNESS_FAILURE` remediation messages. |
| 6 | **User Intent / Original Prompt** | "analyze the .opencode testing framework. how workable would it be if changed to instead use docker with port reflection (so it can access host ollama)? brainstorm." — refined in-session by the developer: GitBucket in its own container going forwards; "I am wanting simple isolaton, not something complicated"; the public GitBucket image "is very stale" and unusable; both harnesses maintained with Docker for tests that work well with it and the host framework reserved for tests that won't; a third tier testing simple `.opencode` card changes "directly with a clean room sub-agent," eligibility by "agent determination"; `.tools/` and other production folders never shared with or copied into the test environment, so agent-provisioning defects stop being hidden; "opencode + uv/uvx copy is ok, those are base system tools"; baseline "something equal to ubuntu cinnamon desktop toolset"; Xvfb included "for it to use so it can do screenshot type stuff in container"; GitBucket port assigned "at time test is created"; "dockerfiles need to be committed"; "gpu in container is not needed at this time. create specs as needed." (2026-10-11) |

## 2. Not Included

- **GPU tooling in the image** (`nvidia-smi`, driver libraries) — developer-stated as not needed at this time; the in-container `ollama-probe hw` observation delta is documented (R-9), not solved.
- **Bridge networking, socat reflection, or any host-network hardening** — host networking is network-neutral versus today; if a threat model ever demands egress restriction or reflected-port allowlisting, that is a future spec (developer: "simple isolaton, not something complicated").
- **Ollama containerization** — Ollama stays a host systemd service (loopback bind, RTX 3090); the test container reaches it unchanged over `localhost:11434` via host networking.
- **Retiring the host harness** — tier-3 keeps it alive; host-path mandates are scoped, not deleted (developer: both options maintained).
- **A scripted tier-1 eligibility rule** — agent determination per developer directive; the card amendment records the judgment mandate, never a checklist.
- **Jupyter server containerization** — the host Jupyter server (:18888) is reachable from the container via host networking exactly as the desktop app reaches it today; moving it is a separate decision.
- **Changes to `floor.md` or `routing.md`** — the tier mechanism is owned by the `behavioral-testing` card; routing already reaches it at behavioral-testing intent.
- **Migrating existing scenario scripts' contents** — scenarios keep their prompts and fixtures; only the tier designation and (where needed) launch-path compatibility are touched. Whole-suite sweeps remain prohibited by §15 regardless of tier.
- **CI enablement** — the developer was asked whether CI/multi-machine portability is a goal and answered "I have no clue"; the design does not depend on the answer (the image is self-contained, which keeps CI possible), but no CI pipeline work is in scope.

## 3. Success Criteria

Each SC is a single atomic, independently verifiable claim. Evidence types are classified by the change's nature: committed-file facts, image/container state, card text, and reference resolution are structural (fact-decidable file/state facts); criteria whose verification instrument is a model run are behavioral (runtime effect, verified through the tests-v2 harness per §6a of tests-v2/AGENTS.md). Artifact-production SCs (SC-9, SC-15) assert infrastructure delivery — that the execution path produces a complete artifact set — not agent behavior, so no clean-room evaluation sub-agent is paired: there is no agent-behavior criterion for an evaluator to judge.

### Phase 1 — Image foundation

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A committed Dockerfile exists at `.opencode/tests-v2/docker/Dockerfile.test-agent` whose base image is a digest-pinned Ubuntu image, and which: installs the Ubuntu desktop-class userland via the `ubuntu-desktop-minimal` metapackage installed headless (no display manager, no Cinnamon/GNOME display stack — Xvfb replaces the display, per §1.4(e); this implements the developer's "equal to ubuntu cinnamon desktop toolset" baseline as a reviewable package line); installs, at build time from official upstream channels at pinned versions, `opencode`, `uv`, `uvx`, git, python3, curl; installs `xvfb`, `openbox`, a screenshot tool (`scrot` or ImageMagick's `import`), and `xdotool`; sets `SHELL=/bin/bash`, `LANG=C.UTF-8`, `TERM=xterm`; and installs no GPU tooling (`nvidia-smi` or driver libraries). The enumerated additions are the complete set: no other tooling is installed beyond the metapackage's userland. | structural | Inspect the committed Dockerfile for each named element, including the metapackage install line; `docker build` succeeds; `docker image inspect` confirms the base is digest-pinned |
| SC-2 | The built test-agent image's entrypoint starts Xvfb on a virtual display and exports `DISPLAY`, and a screenshot capture executed inside the container produces a non-empty image file. | structural | `docker run --rm <image>` with an exec that runs the screenshot tool against the exported `DISPLAY`; the output file exists and is non-empty (fact-decidable container state) |
| SC-3 | The test container executes as the host user's uid: `docker inspect` shows the configured user matching the invoking uid:gid, and after a container run writes into the mounted `tmp/`, no file under `tmp/` is owned by root. | structural | Compare `docker inspect --format '{{.Config.User}}'` against `id -u`/`id -g`; `find tmp/ -user root` returns nothing after a run |
| SC-4 | The test container's mounts are exactly paths under the project's `tmp/`: `docker inspect` lists the bind sources, and every source path resolves under `<project_root>/tmp/`. No production path (`.tools/`, the repo worktree outside `tmp/`, `$HOME`, either `.issues/` store) appears as a mount source. | structural | `docker inspect` mount enumeration with a path-prefix assertion |

### Phase 2 — GitBucket containerization

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-5 | A committed Dockerfile exists at `.opencode/tests-v2/docker/Dockerfile.gitbucket` whose base JRE image is pinned by digest; at provision time the GitBucket WAR is downloaded (existing release-resolution logic) into `tmp/` scratch and baked at image build from that staged copy; the built container serves HTTP on its internal port; the public `gitbucket/gitbucket` image is not used to build or to run GitBucket — the Dockerfile's `FROM` names the digest-pinned JRE base, and no executable code in `tests-v2/` runs the public image. | structural | Inspect the Dockerfile's `FROM` line (digest-pinned JRE base, not `gitbucket/gitbucket`); `docker build` from a staged WAR succeeds; HTTP readiness check inside the container; `grep -rn 'gitbucket/gitbucket' tests-v2/` returns only the release-resolution API URL (`api.github.com/repos/gitbucket/gitbucket`) and comment/doc text — no `FROM gitbucket/gitbucket` and no `docker run`/`docker create`/`docker pull` of the public image |
| SC-6 | `__ensure_gitbucket()` provisions GitBucket as a Docker container: creates the container with a Docker-assigned host port, discovers the port via `docker port`, exports `GITBUCKET_PORT`, `GB_HOST` (as `http://localhost:<discovered-port>`), `GB_REPO`, `GB_PROTOCOL`, and `GB_TOKEN` (minted against the provisioned instance), and is idempotent — a second invocation against a running container re-exports the same values without recreating the container. | structural | Invoke `__ensure_gitbucket()` twice in a sourced-harness shell; compare the exported variable sets AND the container id across invocations — an identical container id proves the container was reused, not recreated |
| SC-7 | `__reset_gitbucket()` removes the container and its staged data, then re-provisions fresh: after reset, the container is newly created (new container id), the data directory under `tmp/` is rebuilt, and the minted token is regenerated (differs from the pre-reset token). | structural | Invoke reset; compare container ids, data-directory inode/state, and the exported `GB_TOKEN` value before and after — the token must differ across the reset |
| SC-8 | A test project wired by the harness to the containerized GitBucket performs the full remote cycle — push to `origin`, API operation with the minted token (issue or label creation), and clone — with the origin URL carrying the discovered port. | structural | Execute the harness's GitBucket wiring block against a scratch test project; assert push exit 0, API response contains the created object, clone succeeds |

### Phase 3 — Tier designation and Docker integration

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-13 | Every scenario script under `.opencode/tests-v2/behaviors/` carries a machine-readable tier designation (tier-1, tier-2, or tier-3); the template used for new scenarios defaults new scenarios to tier-2 (Docker); and no scenario is left un-designated. | structural | Grep the designation marker across `behaviors/*.sh` and `template.sh`; every file matches exactly one tier value |
| SC-9 | A tier-2-designated scenario script executes end-to-end through the Docker execution path — `behavior_run` staging the harness scripts under `tmp/` scratch, launching `with-test-home` inside the container via `docker run -d --network host`, running the model — and produces the complete artifact set (`manifest.yaml`, `session.yaml` with `source_db` present, `stdout.log`, `stderr.log`, `exit_code`) under the host's `tmp/behavioral-evidence-*/`. | behavioral | Run one designated tier-2 scenario script (`bash .opencode/tests-v2/behaviors/<scenario>.sh`, bash-tool timeout ≥ 600000 ms); assert the artifact set's existence and `session.yaml` `source_db` validity — artifact production is the claim, not agent behavior |
| SC-10 | During an active Docker-mode run, the live session DB is readable from the host: `poll-run.sh` against the active run's session DB exits 0 and prints a digest. | structural | Execute `poll-run.sh <active-run-session-db>` mid-run (concurrent with SC-9's run or a dedicated short run); assert exit 0 and non-empty digest output |
| SC-11 | The abort path kills the whole run tree: `docker stop`/`docker rm -f` against a running Docker-mode run leaves no `opencode` process alive in the container and releases the flock. | structural | Launch a run, execute the abort path, then assert no container remains and a subsequent `behavior_run` acquires the lock without stale-lock contention |
| SC-12 | The Docker path's isolation holds at runtime: from inside the test container, the production home's opencode config and DB, `.tools/`, and repo files outside `tmp/` are not readable; and the test home created by a Docker-mode run contains no agent-managed tooling copies (no `.tools/` tree, no copied `opencode`/`uv` binaries inside the test home). | structural | Container-exec probes (cat/ls against production paths, expecting failure); `find` the test home for the forbidden copy patterns |
| SC-18 | The Docker path passes the harness's mandatory smoke gates inside the container: `opencode models` returns at least one `ollama/` model, and `opencode run "hello world"` produces non-empty output without errors — both executed by the Docker-mode setup against the host Ollama unchanged at `http://localhost:11434/v1`. | structural | Run `with-test-home --setup` through the Docker path (or observe the smoke section of SC-9's run output); assert the smoke-pass markers in the setup output |
| SC-19 | `with-test-home --clean-all` on the Docker path removes harness-created containers (the GitBucket container and any run containers) while preserving pulled images: after `--clean-all`, `docker ps -a` shows no harness-created containers, and `docker images` still lists every image the harness pulled or built. | structural | Provision GitBucket, then invoke `--clean-all`; assert container absence and image presence via `docker ps -a` / `docker images` |

### Phase 4 — Deck amendment, harness-spec update, host regression

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-14 | The `behavioral-testing` skill card is amended to: (a) scope the harness-only mandate — tier-2 and tier-3 behavioral evidence is produced by `tests-v2/`; tier-1 evidence is a recorded clean-room sub-agent dispatch (prompt + verdict) into the owning issue's artifact area; (b) scope the host-path isolation mandates (snap prohibitions, `USER=opencode-test-user`, production-DB sha256 check) to host-tier (tier-3) runs; (c) state the Docker-path isolation contract: only-`tmp/` mounts, no production-folder mounts or copies, host-uid execution, bare test home, baked base-tool baseline. | structural | Inspect the amended card text for all three scoping elements; `./.opencode/tools/reference-integrity --scan` passes on the edited card |
| SC-15 | The tier-1 mechanism is demonstrated on a real simple card change: a direct clean-room sub-agent dispatch verifies a card change agreed to be tier-1-eligible, and the dispatch record — the dispatch prompt, the criterion the dispatch judged, and the returned verdict — is persisted into `.opencode/.issues/2582/audit/`. | behavioral | Execute one clean-room sub-agent dispatch on a card change from this spec's own implementation; persist all three record elements under `.opencode/.issues/2582/audit/` |
| SC-16 | `tests-v2/AGENTS.md` is updated coherently: §12 rewritten for the containerized GitBucket lifecycle (Docker commands, `docker port` discovery, `docker rm -f` reset, scratch-staged WAR); a new Docker isolation-contract section (mount boundary, uid, network posture, base-tool baseline, bare test home, GPU exclusion with the documented `ollama-probe hw` delta); §10 gains the Docker failure classes (daemon down, port conflict, stale container, image pull failure) with `HARNESS_FAILURE:` remediation messages; and the §4/§9 cycle text notes the tier routing. `./.opencode/tools/reference-integrity --scan` passes on the edited file. | structural | Inspect the edited sections; run `./.opencode/tools/reference-integrity --scan` |
| SC-17 | The host path remains functional after the change: a tier-3-designated scenario executes end-to-end through the unchanged host harness and produces the complete artifact set under `tmp/behavioral-evidence-*/`, with the host-path isolation mandates still in force for that tier. | behavioral | Run one designated tier-3 scenario via the host path (bash-tool timeout ≥ 600000 ms); assert the artifact set; assert the run's isolation-verification output carries the host-path PASS markers; and assert the change's diff touches no host-path isolation-mandate code (the snap checks, `USER=opencode-test-user`, production-DB sha256 comparison remain intact) |

### Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1–SC-8, SC-10–SC-14, SC-16, SC-18, SC-19: image builds, container state checks, and card/spec text reads — minutes each. Skipping one ships an isolation boundary with a hole the next leak pays for; the entire motivation of this spec is closing exactly such holes structurally. SC-18's instrument includes one bounded smoke call (`hello world`) inside the container setup.
- SC-9 and SC-17: one bounded model run each (5–10 minutes on the default model). Skipping SC-9 ships a Docker path that has never produced evidence; skipping SC-17 ships a host path silently broken by the integration. SC-15 is a single bounded sub-agent dispatch.
- Supervision per tests-v2/AGENTS.md §14 and the behavioral-testing card: every model run in SC-9/SC-17 is monitored on the 60-second poll cycle with text-message updates.

## 4. Requirements

- R-1. The test-agent image SHALL be defined by a committed Dockerfile at `.opencode/tests-v2/docker/Dockerfile.test-agent` with its base image pinned by digest; it SHALL install the Ubuntu desktop-class userland via the `ubuntu-desktop-minimal` metapackage installed headless (no display manager, no Cinnamon/GNOME display stack — Xvfb supplies the display); it SHALL install at build time, from official upstream channels at pinned versions, the base system tools `opencode`, `uv`, `uvx`, git, python3, and curl; it SHALL install `xvfb`, `openbox`, a screenshot tool, and `xdotool`; it SHALL set `SHELL`, `LANG`, and `TERM` in the image environment; the enumerated additions beyond the metapackage SHALL be the complete set; and it SHALL install no GPU tooling.
- R-2. The test container SHALL run with `--network host` and SHALL execute as the host user's uid:gid; its host mounts SHALL be exactly paths under the project's `tmp/` — the staging scratch, test homes, and artifact directories all live under `tmp/` — and no production path (`.tools/`, the repo worktree outside `tmp/`, `$HOME`, either `.issues/` store) SHALL be mounted into, or copied into, the container from a production source. Harness scripts needed inside the container SHALL be staged as fresh copies under `tmp/` scratch at provision time, in a layout that preserves `with-test-home`'s path resolution, so staged scripts are always current with no image-rebuild dependency.
- R-3. The test home on the Docker path SHALL start bare of agent-managed tooling: the binary and uv/uvx copy steps that the host path performs are not performed on the Docker path; the image's baked base tools serve the harness as its instruments; everything the agent would manage in real work starts absent. The host path (tier-3) retains its existing `.tools/` copy behavior unchanged.
- R-4. GitBucket SHALL run as its own container defined by a committed Dockerfile at `.opencode/tests-v2/docker/Dockerfile.gitbucket` with a digest-pinned base JRE image; the WAR SHALL be downloaded by the existing release-resolution logic into `tmp/` scratch and baked at provision-time build from that staged copy; the public `gitbucket/gitbucket` image SHALL NOT be used to build or run GitBucket. The port SHALL be Docker-assigned at container creation and discovered via `docker port`; `GITBUCKET_PORT`, `GB_HOST` (`http://localhost:<discovered-port>`), `GB_REPO`, `GB_PROTOCOL`, and `GB_TOKEN` SHALL be exported from the provisioned instance; reset SHALL be container removal plus data-directory rebuild followed by re-provisioning.
- R-5. `behavior_run()` SHALL dispatch tier-2 scenarios by launching `with-test-home` inside the test container (`docker run -d --network host`) and SHALL leave unchanged every host-side mechanism that reads `tmp/` — the flock, `__export_sqlite_to_yaml()`, the §14 monitor, `poll-run.sh`, and the artifact/copy pipeline. The abort path SHALL use `docker stop`/`docker rm -f` (whole-tree kill); GNU `timeout` remains forbidden on both paths.
- R-6. Scenario scripts SHALL carry a machine-readable tier designation selecting tier-1 (clean-room sub-agent probe), tier-2 (Docker harness), or tier-3 (host harness); new scenarios SHALL default to tier-2; the host tier is by explicit designation only. Tier-1 eligibility is decided by agent judgment per case — never by a scripted checklist — and a tier-1 verification SHALL record its dispatch prompt and verdict as evidence in the owning issue's artifact area.
- R-7. The `behavioral-testing` skill card SHALL be amended so that: the harness-only mandate is scoped per tier (tier-2/tier-3 evidence through `tests-v2/`; tier-1 evidence as recorded clean-room dispatches); the host-path isolation mandates are scoped to tier-3 runs; and the Docker-path isolation contract (only-`tmp/` mounts, no production-folder mounts or copies, host-uid execution, bare test home, baked base-tool baseline) is stated. `tests-v2/AGENTS.md` SHALL be updated in the same change: §12 for the containerized GitBucket lifecycle, a Docker isolation-contract section, §10 Docker failure classes with `HARNESS_FAILURE:` remediation messages, and §4/§9 tier-routing notes.
- R-8. The Docker path SHALL pass the harness's own readiness gates inside the container: the smoke tests (`opencode models` returning at least one `ollama/` model, and `opencode run "hello world"` producing non-empty output) execute inside the container against the host Ollama unchanged at `http://localhost:11434/v1`.
- R-9. GPU tooling SHALL NOT be included in the test-agent image. The behavioral difference — an in-container agent cannot observe GPU state via `nvidia-smi`/`ollama-probe hw` — SHALL be documented in the harness spec as a known, accepted delta of the Docker tier.
- R-10. The §10 playbook SHALL gain the Docker failure domain as named classes — daemon unavailable, image pull failure, port/resource conflict, stale container by name — each with a fail-fast `HARNESS_FAILURE:`/`FATAL:` remediation message pattern consistent with the existing conventions. `--clean-all` SHALL remove harness-created containers while preserving pulled images, mirroring its existing preservation of `.tools/` caches.

## 5. Phases and Items

Per-SC item enumeration; each SC maps to exactly one item. Items are ordered so that every prerequisite an SC's verification needs exists before that item executes (tier designations precede the first Docker-mode scenario run; the image precedes everything). RED states were verified against the live tree on 2026-10-11 (design session); items later in the sequence whose RED text names an absence still absent at that point (e.g., no Docker-mode launch path exists until Item 10's GREEN) are unaffected by earlier items in other phases.

### Phase 1 — Image foundation

#### Item 1 (SC-1): Committed test-agent Dockerfile
- RED: `.opencode/tests-v2/docker/` does not exist; no Dockerfile exists anywhere under `tests-v2/`; no executable Docker usage exists in `tests-v2/` — the sole "Docker" text is a doc cross-reference in `tests-v2/AGENTS.md` §5 (Known-residual paragraph) naming this spec's planned Dockerized-execution layer, added post-verification by the 2026-10-11 #2579 commit (re-verified 2026-10-13).
- GREEN: author `Dockerfile.test-agent` (digest-pinned Ubuntu base; headless `ubuntu-desktop-minimal` userland; build-time installs of opencode/uv/uvx/git/python3/curl at pinned versions; xvfb, openbox, screenshot tool, xdotool; SHELL/LANG/TERM env; no GPU tooling) and build it.
- verify: structural inspection (including the metapackage line) + successful build + digest-pin confirmation in `docker image inspect`.
- commit: Dockerfile (+ any committed build-support files).

#### Item 2 (SC-2): Xvfb display + screenshot capability
- RED: no image exists, hence no display stack or screenshot capability (verified: no Docker usage in `tests-v2/`).
- GREEN: entrypoint starts Xvfb and exports `DISPLAY`; smoke-capture a screenshot inside a container.
- verify: screenshot file exists and is non-empty.
- commit: Dockerfile entrypoint adjustment if needed.

#### Item 3 (SC-3): Host-uid execution
- RED: nothing to inspect — no container exists; the host harness runs as the invoking user by definition, so the container must match that posture (RED is the absent container).
- GREEN: configure `--user <uid>:<gid>` via the harness wrapper (tracks the invoking user; not a Dockerfile-hardcoded uid).
- verify: `docker inspect` user match + no root-owned files in mounted `tmp/` after a run.
- commit: wrapper/config change.

#### Item 4 (SC-4): Mount boundary
- RED: no container exists; the boundary is specified here and verified at first build.
- GREEN: the wrapper mounts only `tmp/`-derived paths.
- verify: `docker inspect` mount enumeration passes the path-prefix assertion.
- commit: wrapper/config change.

### Phase 2 — GitBucket containerization

#### Item 5 (SC-5): Committed GitBucket Dockerfile + staged-WAR build
- RED: `__ensure_gitbucket()` downloads a JDK to `.tools/jdk/` and a WAR to `.tools/gitbucket/` and runs a host Java process (helpers.sh L97–197); no GitBucket Dockerfile exists; the public image is not referenced (verified).
- GREEN: author `Dockerfile.gitbucket` (digest-pinned JRE base); retarget the existing WAR download into `tmp/` scratch; build the image from the staged WAR at provision time.
- verify: `FROM`-line inspection + build succeeds from staged WAR + HTTP readiness inside the container + no executable code builds or runs the public image (the retained release-resolution API URL is not an image reference).
- commit: Dockerfile + provisioning change.

#### Item 6 (SC-6): Docker lifecycle in `__ensure_gitbucket()`
- RED: the function provisions a host process with pid/port state files and `ss -tlnp` discovery (L199–232); no Docker lifecycle exists.
- GREEN: replace with container create/run, `docker port` discovery, and the existing export set; idempotent path re-exports against a running container.
- verify: double invocation produces identical exports and an identical container id (no recreation).
- commit: helpers.sh change.

#### Item 7 (SC-7): Reset semantics
- RED: `__reset_gitbucket()` kills the host pid and deletes `tmp/gitbucket-data/` (L303+); no container-aware reset exists.
- GREEN: reset becomes `docker rm -f` + data-directory rebuild + re-provision.
- verify: new container id and a regenerated (differing) token after reset.
- commit: helpers.sh change.

#### Item 8 (SC-8): Remote-cycle verification against the container
- RED: no containerized GitBucket exists to wire.
- GREEN: execute the wiring block against a scratch project after provisioning.
- verify: push, token-authenticated API operation, and clone all succeed with the discovered port.
- commit: none (verification item; fixes found during verification are committed under their own items).

### Phase 3 — Tier designation and Docker integration

#### Item 9 (SC-13): Tier designation on scenario scripts
- RED: no scenario carries a tier designation (verified: no tier markers exist in `behaviors/*.sh`).
- GREEN: add the designation marker to every scenario script and to `template.sh` (default tier-2); designate the host-tier exception set per scenario judgment.
- verify: grep shows exactly one tier value per script; template defaults to tier-2.
- commit: scenario script markers.

#### Item 10 (SC-9): Docker-mode end-to-end artifact production
- RED: `behavior_run()` launches `with-test-home` as a host process (helpers.sh L2107–2110); no Docker-mode launch exists (still true after Item 9, which only adds markers).
- GREEN: add the Docker launch path — stage harness scripts under `tmp/` scratch, launch `docker run -d --network host` executing the staged `with-test-home`, keep artifact/export machinery unchanged.
- verify: run one tier-2-designated scenario end-to-end (designated by Item 9); assert the complete artifact set with valid `session.yaml`.
- commit: helpers.sh change.

#### Item 11 (SC-10): Live session DB host-side pollability
- RED: the DB will live under the mounted `tmp/` only after Item 10 — pollability is currently trivially true for host runs and untested for Docker runs.
- GREEN: none required beyond Item 10's mount design if poll succeeds; otherwise fix the mount/staging layout.
- verify: `poll-run.sh` digest mid-run exits 0.
- commit: only if a fix was needed.

#### Item 12 (SC-11): Abort-path whole-tree kill
- RED: the current monitor abort kills a host process group via `setsid` (L2071–2079); no container kill path exists.
- GREEN: the Docker abort path executes `docker stop`/`docker rm -f`; the setsid dance is scoped to (or replaced on) the Docker path.
- verify: post-abort container absence + flock re-acquirable without stale-lock remediation.
- commit: helpers.sh change.

#### Item 13 (SC-12): Runtime isolation probes
- RED: no container exists to probe; the isolation contract is specified in R-2/R-3 and verified at first integration.
- GREEN: none beyond Items 4/10 if probes pass; otherwise remediate the mount/staging design.
- verify: container-exec probes fail against production paths; test-home `find` shows no agent-managed tooling copies.
- commit: only if a fix was needed.

#### Item 14 (SC-18): Smoke gates inside the container
- RED: no Docker-mode setup exists before Item 10, so the smoke gates have never executed inside a container.
- GREEN: none beyond Item 10 if the setup's smoke section passes inside the container; otherwise remediate the image or setup.
- verify: `with-test-home --setup` through the Docker path shows both smoke-pass markers (`opencode models` returning an `ollama/` model; non-empty `hello world` output).
- commit: only if a fix was needed.

#### Item 15 (SC-19): `--clean-all` container semantics
- RED: `do_clean_all()` kills the GitBucket host pid and removes data dirs (with-test-home L110–140); it knows nothing of containers.
- GREEN: extend `--clean-all` to remove harness-created containers while preserving images.
- verify: provision, then `--clean-all`: no harness containers remain; pulled/built images remain.
- commit: with-test-home change.

### Phase 4 — Deck amendment, harness-spec update, host regression

#### Item 16 (SC-14): `behavioral-testing` card amendment
- RED: the card mandates harness-only for ALL behavioral evidence with no tier scoping and no Docker path (card §1 as loaded in session).
- GREEN: amend per R-7 (deck-governance admission via the skill-creator gate applies to this edit).
- verify: card text inspection for all three scoping elements + `reference-integrity --scan` pass.
- commit: card edit.

#### Item 17 (SC-15): Tier-1 mechanism demonstrated
- RED: no tier-1 dispatch mechanism or evidence form exists.
- GREEN: during this spec's own implementation, verify one simple card change (a natural candidate: the Item 16 card edit's wording) via a direct clean-room sub-agent dispatch; persist prompt + criterion + verdict.
- verify: dispatch record with all three elements exists under `.opencode/.issues/2582/audit/`.
- commit: artifact persistence via `local-issues`.

#### Item 18 (SC-16): `tests-v2/AGENTS.md` update
- RED: §12 describes the host-process GitBucket; no Docker isolation contract exists; §10 has no Docker failure classes (verified against the live spec).
- GREEN: rewrite §12; add the Docker isolation-contract section; add §10 Docker failure classes; note tier routing in §4/§9.
- verify: section inspection + `reference-integrity --scan` pass.
- commit: harness-spec edit.

#### Item 19 (SC-17): Host-path regression
- RED: not applicable — the host path works today; this SC guards the change's non-regression.
- GREEN: none required beyond ensuring the tier-3 path is untouched by Items 10–12 (its launch line remains the host one; host-path isolation code unmodified).
- verify: run one tier-3-designated scenario via the host path; assert the artifact set; assert the isolation-verification PASS markers in the run output; assert the change's diff touches no host-path isolation-mandate code.
- commit: none (verification item).

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/behaviors/helpers.sh` | carries the GitBucket lifecycle, launch path, abort path, and staging changes (R-4, R-5) | Satisfied (present, inspected 2026-10-11) |
| `.opencode/tests-v2/with-test-home` | carries the bare-test-home change on the Docker path and the unchanged host path (R-3) | Satisfied (present, inspected 2026-10-11) |
| `.opencode/tests-v2/AGENTS.md` | carries the §12/§10/isolation-contract/§4-§9 updates (R-7, R-9, R-10) | Satisfied (present) |
| `.opencode/skills/behavioral-testing/SKILL.md` | carries the tier-scoped mandate amendment (R-7) | Satisfied (present) |
| Docker 29.1.3 (rootful, systemd cgroup, verified 2026-10-11) | container runtime; `--network host` semantics depend on rootful mode | Satisfied (verified) |
| Host Ollama 0.33.0 on `127.0.0.1:11434` (verified 2026-10-11) | the model endpoint reached unchanged via host networking | Satisfied (verified) |
| `.opencode` repo public over HTTPS (verified 2026-10-11: unauthenticated `git ls-remote` succeeds) | the clean-room clone inside the container requires no credentials; recorded as a standing environment assumption — if the repo becomes private, the in-container clone breaks and its fix would need a secrets-surface decision outside this spec | Satisfied (verified; assumption recorded) |
| `eclipse-temurin:21-jre` base for the GitBucket image | the host harness already runs the current WAR on Temurin 21, proving compatibility | Satisfied (compatible; image not yet in local cache — first provision pulls, parity with today's first JDK download) |
| Ubuntu desktop-class base for the test-agent image | glibc compatibility for the baked binaries; host toolchain equivalence | Satisfied (host binaries verified dynamically-linked glibc x86-64) |
| `reference-integrity` tool | validation instrument for edited agent-facing markdown (SC-14, SC-16) | Satisfied (present) |
| `local-issues` tool | SC-15 artifact persistence and store mutations | Satisfied (present) |
| `.opencode#2582` (this issue) | the owning issue for tier-1 evidence persistence | Satisfied (filed 2026-10-11) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 1 |
| R-2 | SC-3, SC-4, SC-9, SC-12 | Phase 1, Phase 3 |
| R-3 | SC-12 | Phase 3 |
| R-4 | SC-5, SC-6, SC-7, SC-8 | Phase 2 |
| R-5 | SC-9, SC-10, SC-11 | Phase 3 |
| R-6 | SC-13, SC-15 | Phase 3, Phase 4 |
| R-7 | SC-14, SC-16 | Phase 4 |
| R-8 | SC-18 | Phase 3 |
| R-9 | SC-1, SC-16 | Phase 1, Phase 4 |
| R-10 | SC-16, SC-19 | Phase 3, Phase 4 |
| (host-path non-regression, developer-mandated dual maintenance) | SC-17 | Phase 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Design session 2026-10-11 | developer directives + brainstorm record | this session's conversation record | The authoritative record of every constraint quoted in §1.5/§1.6 |
| `tests-v2/AGENTS.md` | harness specification (v2) | `.opencode/tests-v2/AGENTS.md` | Read 2026-10-11 — §12 GitBucket lifecycle, §10 remediation playbook, §14 monitoring mandate, §9 change control |
| `behaviors/helpers.sh` | GitBucket provisioning + launch/abort machinery | `.opencode/tests-v2/behaviors/helpers.sh` L91–360, L1814–2263 | Read 2026-10-11 — RED states for Items 5–7, 9, 11 |
| `with-test-home` | env isolation + `.tools/` copy steps | `.opencode/tests-v2/with-test-home` | Read 2026-10-11 — RED state for R-3 (copy steps L560–579), snap rationale |
| Ollama bind address | environment fact | `ss -tlnp` (127.0.0.1:11434) + systemd unit | Verified live 2026-10-11 — grounds the host-networking decision and the bridge alternative's rejection |
| Docker daemon | environment fact | `docker info` (29.1.3, rootful, systemd cgroup v2) | Verified live 2026-10-11 |
| Public GitBucket image staleness | developer statement + local verification | `docker inspect gitbucket/gitbucket:latest` (JDK8 base) | Verified 2026-10-11; developer ruled it unusable |
| Binary portability | environment fact | `file`/`ldd` on `.tools/opencode/opencode` and `.tools/uv/{uv,uvx}` | Verified 2026-10-11 — dynamically-linked glibc x86-64, portable to a glibc-matching image |
| Clone credential path | environment fact | unauthenticated `git ls-remote https://github.com/michael-conrad/.opencode` | Verified 2026-10-11 — no credentials needed inside the container |
| `.opencode#2538` | isolation-incident precedent | github.com/michael-conrad/.opencode/issues/2538 | Referenced by the behavioral-testing card as the credential-passthrough regression grounding the isolation mandate |
| GPU-reference scan | environment fact | grep over `behaviors/*.sh` for nvidia-smi/ollama-probe/GPU | Verified 2026-10-11 — no scenario script references GPU tooling directly |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Edge Cases

### Input boundaries

- **Condition:** The harness is invoked on a machine where the images have not been built.
- **Expected behavior:** The Docker path builds the image(s) from the committed Dockerfiles at provision time (base layers cached after first pull) — parity with today's first-provision JDK/WAR downloads.
- **Resolution:** R-1/R-4 define the committed Dockerfiles as the reproducible source; the playbook's image-pull-failure class (R-10) covers the network-dependent first provision.

- **Condition:** Port 18080 (or any fixed candidate) is occupied at provision time.
- **Expected behavior:** No fixed-port conflict can occur — the port is Docker-assigned at container creation and discovered via `docker port`.
- **Resolution:** R-4's assignment-at-creation decision (developer: "at time test is created") eliminates the fixed-port failure class; the playbook's port-conflict class covers daemon-level resource exhaustion instead.

### State transitions

- **Condition:** The host's `.tools/opencode` binary is updated while the image's baked version stays pinned.
- **Expected behavior:** The Docker tier runs the image's pinned version; the host tier runs the updated binary. Each path is self-consistent; the image's version is visible in the committed Dockerfile and changes only through a reviewed commit.
- **Resolution:** R-1's build-time pinned installs make version skew explicit and reviewable rather than silent; no automatic coupling is introduced.

- **Condition:** A scenario currently on the host path is re-designated to tier-2 (or vice versa) later.
- **Expected behavior:** The tier designation marker is edited on the scenario script; no other change is required — both paths accept any scenario's shape.
- **Resolution:** R-6's machine-readable designation makes tier movement a one-marker edit; §15's targeted-execution mandate is tier-independent.

### Failure modes

- **Condition:** The Docker daemon is down or unreachable when a tier-2 run starts.
- **Expected behavior:** Fast, diagnosable failure — `HARNESS_FAILURE:` naming Docker and the daemon check, before any model dispatch.
- **Resolution:** R-10's playbook class; the pre-flight gate ordering (git-state gate → Docker availability check → model dispatch) matches the existing §4 gate shape.

- **Condition:** A stale container from a prior crashed run holds the GitBucket name.
- **Expected behavior:** Provisioning detects the existing container by name and reconciles (reuse if healthy, remove-and-recreate if not) — the pid-file idempotency pattern translated to `docker inspect`.
- **Resolution:** SC-6's idempotency + R-10's stale-container class.

- **Condition:** A monitored Docker-mode run goes off-track.
- **Expected behavior:** The §14 monitor behaves identically (host-side DB reads through the `tmp/` mount); the abort uses `docker stop`/`rm -f` and the §10.5-style export still works because the DB survives on the host-side mount.
- **Resolution:** R-5's unchanged-host-side-machinery clause; SC-11 verifies the kill path.

- **Condition:** The in-container agent reaches for `nvidia-smi` or `ollama-probe hw`.
- **Expected behavior:** The observation fails or reports absence — a known, documented delta of the Docker tier, not a harness defect.
- **Resolution:** R-9's documentation requirement; no scenario script depends on GPU tooling (verified 2026-10-11).

### Concurrency

- **Condition:** Two behavioral runs are attempted concurrently.
- **Expected behavior:** The single-GPU host still serializes model dispatch — the flock retains its role; containers add no new concurrency to model execution.
- **Resolution:** R-5's unchanged-flock clause; the flock file lives under the mounted `tmp/` so host- and container-side holders contend on the same inode.

### Recovery

- **Condition:** A tier-2 run is killed mid-inference (bash-tool timeout or monitor abort).
- **Expected behavior:** The test home and session DB survive on the host-side `tmp/` mount; §10.7 resumption (`--resume-home`) and §10.5 manual export operate unchanged on host-side paths.
- **Resolution:** R-2's mount design keeps every recovery path host-side; no container-specific recovery procedure is introduced.

- **Condition:** The image needs a base-tool version change.
- **Expected behavior:** The committed Dockerfile is edited (pinned versions), the image is rebuilt, and the change rides the normal spec/PR cycle — the environment definition is reviewable by construction.
- **Resolution:** R-1's committed-Dockerfile decision (developer: "dockerfiles need to be committed").

---
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
