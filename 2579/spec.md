<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated; developer directives 2026-10-11 (deny-layer proposal, "good first step" endorsement, public-temp allow directive); observed failure .opencode#2579; verification record external-deny-verification.md in this folder -->

# [SPEC] Test-home `external_directory` containment policy (deny outside test home; explicit `/tmp` + `/var/tmp` allows)

## 1. Intent and Problem Statement

The #2579 isolation breach: a behavioral run agent, finding its task state absent from the isolated test home, walked host absolute paths (`/home/muksihs/git/opencode-config/.issues/…`) and read the host session's real issue data, contaminating the evidence chain. Root cause: the harness's isolation is environment-variable based (`env -i` allowlist); nothing bounds the agent's filesystem scope.

The developer proposed the containment layer this spec defines: *"could not the opencode.jsonc file in the test home be configured with parent level deny for all folders outside of the test home folder?"* — and endorsed the approach as a good first step: *"it is not normal to request the agent to read files outside of the project as a normal course of action."* The developer further directed: *"allowing explicit access to public /tmp and /var/tmp is probably good to do."*

The mechanism is opencode's own `external_directory` permission, which fires when any tool touching a path outside the working directory resolves that path, with rules resolving to allow/ask/deny (last match wins; `~` expands against the runtime `HOME`). The harness already seeds every test home's `opencode.jsonc` via `seed_model_config()` (`.opencode/tests-v2/with-test-home`) and a same-shaped config for the §14 classifier home (`.opencode/tests-v2/behaviors/helpers.sh`) — both currently granting `"external_directory": {"**": "allow"}`, i.e., the walk is wide open by configuration.

Empirical verification on 2026-10-11 (three monitored probe runs through the harness, record and artifacts referenced in §5/§8) established: the deny layer fully contains the `read` tool (host absolute paths, relative escapes, and agent-self-expanded production-`~` paths all blocked); public-temp and in-home allows match correctly in absolute and relative-climb path forms; and bash command execution bypasses the permission layer for common text tools (`ls`, `grep`, `head`, `sed` completed against host paths) — a run agent adapted within one turn. The layer is therefore a hardening of the tool surface, not structural containment.

## 2. Not Included

- **Bash-command path checking** — extending the permission layer to parse paths out of arbitrary bash commands is upstream opencode behavior; pattern-matched command strings are evadable by construction and the residual is documented (SC-3), not engineered around here.
- **Structural filesystem containment** — the only-`tmp/` mount boundary, containerized execution, and runtime probes are the `.opencode#2582` design; this spec's layer composes with it and is not a substitute.
- **Scenario prompt/fixture redesign** — prompts referencing host-resolvable task state is a separate defect class of the same breach; not in scope here.
- **Changes to the `behavioral-testing` skill card, `floor.md`, or `routing.md`** — the card's clean-room mandate is unaffected; this spec strengthens isolation, it does not re-scope any mandate.

## 3. Success Criteria

Each SC is a single atomic, independently verifiable claim. Evidence types are classified by the change's nature: seeder/config text and documentation facts are structural (fact-decidable file/state facts); the runtime containment effect is behavioral (verified through the tests-v2 harness per its §14 monitoring mandate).

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Both test-home config seeders — `seed_model_config()` in `.opencode/tests-v2/with-test-home` and the classifier-home seeder in `.opencode/tests-v2/behaviors/helpers.sh` — emit a `permission.external_directory` block consisting of exactly, in order: `"**": "deny"`, then `"~": "allow"`, `"~/**": "allow"`, `"/tmp": "allow"`, `"/tmp/**": "allow"`, `"/var/tmp": "allow"`, `"/var/tmp/**": "allow"`, and no other `external_directory` rules. | structural | Inspect the two heredoc blocks in the seeder sources; provision a fresh test home via `bash .opencode/tests-v2/with-test-home --setup` and inspect the seeded `.config/opencode/opencode.jsonc` for the same rule set |
| SC-2 | A monitored `with-test-home` probe run against the seeded config demonstrates the full containment surface through the `read` tool: (a) a host-repo-path read is permission-denied, (b) a `/tmp` path read returns the file's contents, (c) a `/var/tmp` path read returns the file's contents, (d) an in-home external path read (outside the test project, inside the test home) returns the file's contents — all four outcomes in the run's recorded evidence. | behavioral | Execute the probe per tests-v2 §14 (60s poll cycle, bash-tool timeout ≥ 600000 ms); the executed 2026-10-11 probe (54 events, all four outcomes recorded, `session.yaml` + `stdout.log` at `tmp/2579/artifacts/external-deny-probe-attempt3-tmp-allow/`) is an executed instance of this instrument |
| SC-3 | `tests-v2/AGENTS.md` §5 documents the seeded `external_directory` policy: the allow set (test home, `/tmp`, `/var/tmp`, the auto-allowed tool-output directory), the deny catch-all, the known bash-command residual (path-checking is command-selective; `cat` caught, `ls`/`grep`/`head`/`sed` bypassed — observed 2026-10-11), and the cross-reference that structural containment is the `.opencode#2582` layer. `./.opencode/tools/reference-integrity --scan` passes on the edited file. | structural | Inspect the edited §5 text for all four elements; run `./.opencode/tools/reference-integrity --scan` |

## 4. Requirements

- R-1. The `permission.external_directory` block seeded into every test home config SHALL deny paths outside the test home by default (`"**": "deny"` evaluated last) and SHALL explicitly allow paths under the test home itself (`~`, `~/**`) and the public temp directories (`/tmp`, `/tmp/**`, `/var/tmp`, `/var/tmp/**`). The same policy SHALL apply to the §14 classifier home's seeded config.
- R-2. The containment behavior of the seeded policy SHALL be demonstrated by a monitored harness probe covering the four SC-2 cases; a probe executed before this spec's approval that exercised exactly this instrument satisfies the criterion's evidence requirement.
- R-3. The harness specification (`tests-v2/AGENTS.md` §5) SHALL document the seeded policy and its known residual so harness consumers do not mistake tool-surface hardening for structural containment; the reference-integrity check SHALL pass on the edited file.

## 5. Phases and Items

Each SC maps to exactly one item. RED states were verified against the live tree on 2026-10-11.

### Item 1 (SC-1): Seeder policy flip
- RED: both seeders write `"external_directory": {"**": "allow"}` — host paths fully reachable from test runs (verified in the pre-change sources and confirmed by the #2579 breach).
- GREEN: flip both heredoc blocks to the seven-rule policy of R-1.
- verify: SC-1's method (seeder inspection + seeded-config inspection from `--setup`).
- commit: `5992ee95` (deny + test-home allow), `c2e5bbb0` (public-temp allows) on `feature/2579-test-home-external-deny`.

### Item 2 (SC-2): Containment probe
- RED: pre-change, host-path reads from a test home succeeded — the breach itself (poll 9 evidence in `abort-diagnosis.md`) and probe attempt 1's bash completions.
- GREEN: execute the four-case probe; the policy holds as specified.
- verify: SC-2's method; executed runs of 2026-10-11 (attempts 2 and 3, 108 and 54 events) recorded under `tmp/2579/artifacts/`.
- commit: none (verification item).

### Item 3 (SC-3): Harness-spec documentation
- RED: `tests-v2/AGENTS.md` §5 documents the seeded config's `model`/`models` fields only; no permission policy is documented (verified against the live spec).
- GREEN: add the policy documentation per R-3 to §5's model-config-generation surface.
- verify: SC-3's method.
- commit: the documentation edit, on `feature/2579-test-home-external-deny`.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/with-test-home` | carries the `seed_model_config()` policy (R-1) | Satisfied (present, inspected 2026-10-11) |
| `.opencode/tests-v2/behaviors/helpers.sh` | carries the classifier-home policy (R-1) | Satisfied (present, inspected 2026-10-11) |
| `.opencode/tests-v2/AGENTS.md` | carries the §5 documentation (R-3) | Satisfied (present) |
| `./.opencode/tools/reference-integrity` | validation instrument for SC-3 | Satisfied (present) |
| opencode ≥ 1.18 permission config (`external_directory`, last-match-wins, `~` expansion) | the mechanism this spec configures | Satisfied (verified live 2026-10-11 against installed 1.18.32) |
| `.opencode#2582` | the structural containment layer this policy composes with (documented cross-ref, R-3) | Open (separate spec) |

## 7. Traceability

| Requirement | SC(s) | Phase(s)/Item(s) |
|-------------|-------|------------------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Developer directives 2026-10-11 | requirements source | this spec §1 (quoted verbatim) | The authoritative record of the deny-layer proposal, endorsement, and temp-allow directive |
| `.opencode#2579` | observed failure | `abort-diagnosis.md` in this folder; remote defect report | Read 2026-10-11 — breach vector and root cause |
| Verification record | executed evidence | `external-deny-verification.md` in this folder | Written 2026-10-11 — three probe runs, results tables, monitoring records |
| opencode permissions documentation | mechanism reference | opencode.ai/docs/permissions | Fetched live 2026-10-11 — rule resolution, last-match-wins, `~`/`$HOME` expansion, `external_directory` semantics |
| Probe artifacts | executed evidence | `tmp/2579/artifacts/external-deny-probe-attempt{1-killed,2,3-tmp-allow}/` | Generated 2026-10-11 — session.yaml exports, stdout/stderr logs, preserved test homes |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Edge Cases

- **Condition:** the agent passes a public-temp path written as a relative climb out of the project directory (e.g. `../../../../../../../tmp/…`).
  **Expected behavior:** the resolved absolute path matches the `/tmp` allow; the read completes.
  **Resolution:** verified (attempt 2, relative-climb forms completed for both temp dirs).
- **Condition:** the agent passes a literal `~`-prefixed path to the `read` tool.
  **Expected behavior:** the read tool does not expand `~` — the lookup fails as file-not-found rather than as a permission denial; production-`~` data is unreachable either way.
  **Resolution:** observed behavior documented (attempts 1–2); agents use absolute paths, and bash-side `~`/`$HOME` expansion resolves against the test home at runtime, staying inside the allow set.
- **Condition:** the agent needs the test home's own externally-located config/state (e.g. the seeded gb config, tool-output directories).
  **Expected behavior:** allowed — paths under the test home match the `~/**` allow; the tool-output directory carries the harness's auto-allow.
  **Resolution:** verified (attempts 2–3; gb config read completed in both).
- **Condition:** a scenario legitimately requires reading a production path outside the test home.
  **Expected behavior:** denied — if a behavioral SC genuinely needs such access, that is a spec problem: the SC is re-scoped at its spec, and the isolation is never weakened (clean-room mandate).
  **Resolution:** no current scenario requires it; the fixtures mechanism (§3 of tests-v2/AGENTS.md) stages issue content in-home.

---
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
