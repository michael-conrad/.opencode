# 2648 — with-test-home resume boot wipes the stored gb credential and strips GB_TOKEN when BEHAVIOR_NEEDS_REMOTE is unset

## Problem

`with-test-home`'s `seed_gb_config()` (SC20) unconditionally rewrites
`$TEST_HOME/.config/gb/config.toml` at every boot — including resume boots —
and writes the stored token only when `BEHAVIOR_NEEDS_REMOTE=1`:

```bash
local gb_token=""
if [ "${BEHAVIOR_NEEDS_REMOTE:-0}" = "1" ]; then
    gb_token="${GB_TOKEN:-}"
fi
cat > "$TEST_HOME/.config/gb/config.toml" << TOML
...
token = "$gb_token"
TOML
```

The same guard strips `GB_TOKEN` from the agent's `env -i` (`GB_ENV_ARGS`
block, with-test-home ~line 705–710 on main, verified 2026-11-02). A
recovery/resume launch of a remote-dependent scenario that omits
`BEHAVIOR_NEEDS_REMOTE` therefore produces a test home where **both
credential surfaces are empty**: every REST call 401s regardless of the
launcher's `GB_TOKEN`.

## Observed (2026-10-20, .opencode#2639 SC-8 recovery passes)

- Recovery pass 8: the run agent's recorded `gb pr create` failed 401 ("Bad
  credentials") on both the create and a read-gate check, while the identical
  token authenticated host-side. The run agent independently diagnosed the
  mechanism: `config.toml` mtime = the resume boot time, token field empty.
- The recurring "stored token emptying across container relaunches"
  observations across earlier passes (agent halt records repeatedly verified
  the token key empty on file read) were this defect misread as gb state
  loss — the config was being rewritten at each boot, not emptied in place.
- With `BEHAVIOR_NEEDS_REMOTE=1` present (pass 9), the boot wrote the token
  into the profile and the recorded create succeeded on the first attempt
  (PR root/test-repo#1 OPEN).

## Scope

The fix targets the recovery path of the remote-dependent scenario
(2639-sc8-second-directive-rides-open-pr), which defaults
`BEHAVIOR_NEEDS_REMOTE` ON so resume boots seed the credential and pass
`GB_TOKEN` into the agent env.

Out of scope: whether `seed_gb_config` should preserve an existing
non-empty stored token instead of unconditionally overwriting (overwrite-on-boot
is what turns a flag omission into an active credential wipe) — named residual
design question, left for a future hardening pass.

## Requirements

- R-1: The scenario recovery block (2639-sc8-second-directive-rides-open-pr)
  SHALL default `BEHAVIOR_NEEDS_REMOTE` to ON via
  `export BEHAVIOR_NEEDS_REMOTE="${BEHAVIOR_NEEDS_REMOTE:-1}"`, so a resume
  boot of that remote-dependent scenario writes the stored `GB_TOKEN` into
  `$TEST_HOME/.config/gb/config.toml` and passes `GB_TOKEN` into the agent's
  env.
  - Verification instrument: a tests-v2 harness recovery run of the scenario
    with `GB_TOKEN` set at launch and `BEHAVIOR_NEEDS_REMOTE` unset until the
    recovery block executes; the harness-recorded evidence must show both
    surfaces non-empty after the boot (the `config.toml` token field, and the
    agent env's `GB_TOKEN`).

## Impact

- Consumers: recovery/resume launches of remote-dependent scenarios through
  with-test-home — the observed instances being the #2639 SC-8 recovery
  passes. The mechanism triggers whenever such a launch omits
  `BEHAVIOR_NEEDS_REMOTE`.
- Risk if unfixed: both credential surfaces are empty after the resume boot —
  every REST call 401s regardless of host-side token validity; the recurrence
  presents as "stored token emptying across container relaunches" and reads
  as gb state loss, misdirecting diagnosis.
- Blast radius: tests-v2 harness surfaces only — the scenario script's
  recovery block; `with-test-home` itself is unchanged by the fix. No deck
  code, no library consumers.

## Delivery and verification record

- Authored fix: `e85ca39bd906abc6f97a127377d42941a057bdf2`
  (2026-10-20T22:39:42-04:00, branch `feature/2639-scope-boundary-stacked-pr`;
  commit message titled fix(#2646), the stacked ride-along numbering). The
  branch and that commit are no longer reachable from any ref.
- Delivered to main via `b71a8c1c4` ("feat(#2639): scope-boundary provisions
  and stacked-PR behavioral scenarios", 2026-10-20T23:42:49-04:00), carrying
  the identical recovery-default line — verified against
  `main:tests-v2/behaviors/2639-sc8-second-directive-rides-open-pr.sh`
  (line 56) and the working tree on 2026-11-02.
- `seed_gb_config`'s conditional-token/unconditional-rewrite mechanism remains
  present on main (`tests-v2/with-test-home`, verified 2026-11-02), consistent
  with the residual design question's out-of-scope status.
- Behavioral evidence artifacts under
  `tmp/behavioral-evidence-2639-sc8-second-directive-rides-open-pr-GREEN-*`
  (project root tmp/) were transient; not present as of 2026-11-02. The
  pass-8/pass-9 observations above are the dated record.