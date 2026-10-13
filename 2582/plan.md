<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; derived entirely from .opencode/.issues/2582/spec.md (validated PASS round 5, 2026-10-13) -->

# Implementation Plan — .opencode#2582 (Dockerized test environment, tiered execution)

Spec source: `.opencode/.issues/2582/spec.md` — every item below traces to exactly one SC.
Branch: `feature/2582-dockerized-test-environment`. One item per SC; RED/GREEN per item.
All behavioral runs (SC-9, SC-17) supervised per tests-v2/AGENTS.md §14 / behavioral-testing card.

## Cross-cutting implementation decisions (from the spec, no new scope)

- **Tier marker format:** `SCENARIO_TIER="2"` (bash variable assignment line near
  `SCENARIO_NAME` in every scenario script). Machine-readable via grep; exactly one
  value per scenario-invoking file. `SCENARIO_TIER` values: 1 (clean-room probe),
  2 (Docker harness), 3 (host harness).
- **Docker gate in `behavior_run()`:** read the scenario's tier from a helper
  `__scenario_tier()` (parsed by the caller or via an env contract). Tier-2 →
  Docker launch path; tier-3 → existing host path untouched; tier-1 → behavior_run
  is never invoked (tier-1 scenarios are dispatched as clean-room sub-agents, the
  script records that fact and exits 0).
- **Docker launch path mechanics (R-2/R-5):** stage `with-test-home` + `helpers.sh`
  + `default-model.sh` into `tmp/docker-staging-<ts>/`; `docker run -d --network host
  --user <uid>:<gid> --env-file <staged env file> -v <tmp-derived mounts only>
  <test-agent-image> bash <staged>/with-test-home opencode run ...`; the run
  container is named `tests-v2-run-<scenario>-<ts>`; abort = `docker stop` +
  `docker rm -f` (R-5). Docker-mode export env var `TEST_ENV=docker` switches
  `with-test-home` to the bare-home branch (skips binary/uv copies, R-3).
- **GitBucket container:** name `tests-v2-gitbucket`; image built at provision time
  from staged WAR under `tmp/` scratch (`tmp/gitbucket-staging/gitbucket.war`);
  port via `docker run -d -P` + `docker port`; data dir `tmp/gitbucket-data` mounted
  at the container's GitBucket home.
- **Host-uid:** `--user "$(id -u):$(id -g)"` computed by the harness at container
  create time; never hardcoded in the Dockerfile.

## Items

### Item 1 (SC-1) — test-agent Dockerfile
- RED: no `tests-v2/docker/`, no Dockerfile anywhere under `tests-v2/`.
- GREEN: author `.opencode/tests-v2/docker/Dockerfile.test-agent` — digest-pinned
  Ubuntu base; headless `ubuntu-desktop-minimal` (no display manager/display stack);
  pinned-version installs of opencode, uv, uvx, git, python3, curl; xvfb, openbox,
  scrot, xdotool; `SHELL/LANG/TERM` env; no GPU tooling. Build it; record the base
  digest.
- verify: structural inspection incl. metapackage line; `docker build` success;
  `docker image inspect` digest-pin confirmation.

### Item 2 (SC-2) — Xvfb display + screenshot
- RED: no image exists.
- GREEN: entrypoint/launcher starts Xvfb, exports DISPLAY; smoke screenshot inside
  a container.
- verify: screenshot file exists and is non-empty.

### Item 3 (SC-3) — host-uid execution
- RED: no container exists.
- GREEN: harness wrapper passes `--user uid:gid`; run writes into mounted `tmp/`.
- verify: `docker inspect` user == host uid:gid; `find tmp/ -user root` empty after run.

### Item 4 (SC-4) — mount boundary
- RED: no container exists.
- GREEN: wrapper mounts only `tmp/`-derived paths.
- verify: `docker inspect` mount enumeration passes path-prefix assertion; no
  production source paths.

### Item 5 (SC-5) — GitBucket Dockerfile + staged-WAR build
- RED: `__ensure_gitbucket()` provisions a host JDK/WAR/process (helpers.sh L97–197).
- GREEN: author `Dockerfile.gitbucket` (digest-pinned JRE base, NOT
  `gitbucket/gitbucket`); retarget WAR download into `tmp/gitbucket-staging/`;
  build image from the staged WAR at provision time.
- verify: FROM-line inspection; build success; HTTP readiness in-container;
  `grep -rn 'gitbucket/gitbucket' tests-v2/` shows only the release API URL + docs.

### Item 6 (SC-6) — Dockerized `__ensure_gitbucket()`
- RED: host-process provisioning with `ss -tlnp` discovery (L199–232).
- GREEN: container create/run with `-P`; `docker port` discovery; export
  `GITBUCKET_PORT`, `GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GB_TOKEN`; idempotent
  re-export against a running container (no recreate).
- verify: double invocation → identical exports + identical container id.

### Item 7 (SC-7) — reset semantics
- RED: reset kills a host pid (L303+).
- GREEN: reset = `docker rm -f` + data-dir rebuild + re-provision.
- verify: new container id + regenerated `GB_TOKEN` after reset.

### Item 8 (SC-8) — remote-cycle verification
- RED: no containerized GitBucket to wire.
- GREEN: execute the wiring block against a scratch project.
- verify: push exit 0; token-authenticated API operation visible; clone succeeds.

### Item 9 (SC-13) — tier designation on scenario scripts
- RED: no tier markers anywhere under `behaviors/` (recursive).
- GREEN: add `SCENARIO_TIER` to every scenario script at any depth under
  `behaviors/` (fixtures excluded) and to `template.sh` (default `"2"`);
  designate the host-tier exception set per scenario judgment.
- verify: recursive enumeration (fixtures excluded) — every `behavior_run`-invoking
  file matches exactly one tier value; `template.sh` carries the tier-2 default.

### Item 10 (SC-9) — Docker-mode end-to-end artifact production
- RED: `behavior_run()` launches `with-test-home` as a host process (L2107–2110).
- GREEN: add the tier-2 Docker launch path (staging under `tmp/` scratch,
  `docker run -d --network host`, host-side artifact/export machinery unchanged).
- verify: one tier-2 scenario end-to-end (timeout ≥ 600000 ms); complete artifact
  set with valid `session.yaml` (`source_db` present). Supervised per §14.

### Item 11 (SC-10) — live session DB host-side pollability
- RED: untested for Docker runs.
- GREEN: none beyond Item 10's mount design if poll succeeds; else fix staging.
- verify: `poll-run.sh <active-run-session-db>` mid-run exits 0, prints digest.

### Item 12 (SC-11) — abort-path whole-tree kill
- RED: abort kills a host process group via setsid (L2071–2085); no container kill.
- GREEN: Docker abort path = `docker stop` + `docker rm -f`; setsid dance scoped
  to the host path.
- verify: post-abort container absence + flock re-acquired without stale lock.

### Item 13 (SC-12) — runtime isolation probes
- RED: no container to probe.
- GREEN: none beyond Items 4/10 if probes pass; else remediate mount/staging.
- verify: container-exec probes fail against production home config/DB, `.tools/`,
  repo-outside-`tmp/`; test-home `find` shows no `.tools/` tree or copied
  opencode/uv binaries.

### Item 14 (SC-18) — smoke gates inside the container
- RED: smoke gates never executed in a container.
- GREEN: none beyond Item 10 if the setup smoke section passes; else remediate.
- verify: `with-test-home --setup` via Docker path shows both smoke-pass markers
  (`ollama/` model; non-empty `hello world`) against host Ollama at
  `http://localhost:11434/v1`.

### Item 15 (SC-19) — `--clean-all` container semantics
- RED: `do_clean_all()` knows nothing of containers (with-test-home L110–140).
- GREEN: extend `--clean-all` to remove harness-created containers
  (`tests-v2-gitbucket`, `tests-v2-run-*`) while preserving images.
- verify: provision → `--clean-all`: no harness containers in `docker ps -a`;
  images still in `docker images`.

### Item 16 (SC-14) — `behavioral-testing` card amendment
- RED: card mandates harness-only for ALL behavioral evidence; no tier scoping.
- GREEN: amend per R-7 — (a) harness-only scoped: tier-2/3 evidence via
  `tests-v2/`, tier-1 evidence = recorded clean-room dispatch (prompt + verdict)
  into the owning issue's artifact area; (b) host-path isolation mandates scoped
  to tier-3; (c) Docker isolation contract stated (only-`tmp/` mounts, no
  production mounts/copies, host-uid, bare test home, baked baseline). Deck
  governance (skill-creator gate) applies to this edit.
- verify: card text inspection + `./.opencode/tools/reference-integrity --scan`.

### Item 17 (SC-15) — tier-1 mechanism demonstrated
- RED: no tier-1 dispatch mechanism or evidence form exists.
- GREEN: verify one simple card change from this implementation (the Item 16 edit)
  via a direct clean-room sub-agent dispatch; persist prompt + criterion + verdict
  into `.opencode/.issues/2582/audit/`.
- verify: dispatch record with all three elements exists under the audit dir.

### Item 18 (SC-16) — `tests-v2/AGENTS.md` update
- RED: §12 describes the host-process GitBucket; no Docker isolation contract;
  §10 has no Docker failure classes.
- GREEN: rewrite §12 (containerized lifecycle: `docker port` discovery,
  `docker rm -f` reset, scratch-staged WAR); add Docker isolation-contract section
  (mount boundary, uid, network posture, base-tool baseline, bare test home, GPU
  exclusion + documented `ollama-probe hw` delta); §10 Docker failure classes
  (daemon down, port conflict, stale container, image pull failure) with
  `HARNESS_FAILURE:` remediation messages; §4/§9 tier-routing notes.
- verify: section inspection + `./.opencode/tools/reference-integrity --scan`.

### Item 19 (SC-17) — host-path regression
- RED: N/A (non-regression guard).
- GREEN: ensure Items 10–12 leave the host launch line and host-path isolation
  code untouched.
- verify: one tier-3 scenario end-to-end via the host path (timeout ≥ 600000 ms);
  complete artifact set; host-path isolation PASS markers in output; diff touches
  no host-path isolation-mandate code.

## Dependency order

1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → (11, 12, 13, 14, 15) → 16 → 17 → 18 → 19.

## Verification instruments summary

- Structural SCs: docker inspect/build/exec probes, grep instruments, file
  inspection, `reference-integrity --scan` (SC-14, SC-16).
- Behavioral SCs: SC-9 and SC-17 — one bounded model run each, supervised on the
  60-second poll cycle with text-message updates (tests-v2 §14 + behavioral-testing
  card); SC-15 — one bounded clean-room sub-agent dispatch with persisted record.

## Cost frame

Per spec §3 Cost Frame: structural checks are minutes each; SC-9/SC-17 one bounded
run each (5–10 min, supervised); SC-15 one sub-agent dispatch. Correctness is the
only metric; every skipped structural check ships an isolation hole.
