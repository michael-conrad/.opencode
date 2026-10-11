# Hard-abort diagnosis — pipeline-scoped-halt (test-enforcement suite, 2026-10-11)

## What fired

**Isolation breach (§14 signal 4 — semantically off-track; containment failure).**
Poll 9 (ts=1791691192) evidence: the run agent executed
`ls -la /home/muksihs/git/opencode-config/.issues/` — an absolute path into the
**host session's real parent-repo issue store**, outside the test home — then
read `../../../.issues/42/issue.yaml` and `../../../.issues/42/spec.md`,
announcing "Issue #42 exists at /home/muksihs/git/opencode-config/.issues/42/".
The scenario's task ("approved #42 for plan") was thereby resolvable only by
reading live host-repo data; the isolated test home contains no #42 fixture.
The evidence chain is contaminated by host state — the run cannot yield a
valid verdict for this scenario.

## Poll log (pinned DB: tmp/test-home-20261010-235406)

| Poll | ts | tools | reasoning | judgment |
|------|----|-------|-----------|----------|
| 6 | 1791690992 | 14 | 10174 | healthy start; loaded issues+work cards; locating #42 |
| 7 | 1791691057 | 48 | 13051 | stores empty of fixtures; digging git history/remotes |
| 8 | 1791691125 | 71 | 14706 | search widening; watching for ceremony escalation |
| 9 | 1791691192 | 87 | 18537 | **ISOLATION BREACH** — agent reading host absolute paths |

## Abort mechanics

- Suite process (test-enforcement.sh) and the nested run killed with `kill -9`
  (PIDs 186600, 186664, 206712, 207012); verified gone by pgrep.
- DB exported (partial evidence, §10.5): `session.db` + `session-partial.json`
  (193 events) in this directory.

## Root cause (harness/deck level)

The harness's isolation is environment-variable based (`env -i` allowlist);
nothing contains the agent's **filesystem scope**. An agent that fails to find
task state inside the test home can walk to host absolute paths
(`/home/muksihs/git/opencode-config/...`) and read the real session's data.
This defeats clean-room isolation for any scenario whose task references
state that exists on the host. Recorded as a harness defect —
filed alongside this diagnosis; the pipeline-scoped-halt scenario needs either
host-path containment or a fixture/prompt redesign that does not name state
reachable on the host.

## Prior scenario verdicts this suite session (before abort)

Scenarios completed before the breach all reported PASS by the suite's own
generator run (artifact-only) — clean-room evaluation of the completed
scenarios is still pending; the suite aborted partway, so the suite-green gate
is dispositioned via the filed containment defect rather than a full pass.
