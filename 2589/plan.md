# Plan — .opencode#2589

Derived entirely from `.opencode/.issues/2589/spec.md` (validated PASS,
zero findings, 2026-10-12). One item per SC; SC-1 and SC-2 close across
multiple items and are gated at the item whose last consumer disappears.
Branch: `feature/2589-remove-gitbucket-issue-state` in the `.opencode` repo,
base tip `d25ce590` (remote trunk tip, verified fresh).

## Item 1 — Harness credential plumbing removal (spec Scope 2; feeds SC-2)

- **Deliverable:** `tests-v2/with-test-home` no longer exports
  `GB_USER`/`GB_PASSWORD` and no longer references
  `gitbucket-issue-state`; the comment block explaining the fixture
  credentials goes with it.
- **RED:** `grep -n "GB_USER\|GB_PASSWORD" tests-v2/with-test-home` →
  matches at the `BEHAVIOR_NEEDS_REMOTE` block (line ~666) plus the
  `gitbucket-issue-state` comment (~661-662).
- **GREEN:** delete the two comment lines and the
  `GB_ENV_ARGS+=(GB_USER="root" GB_PASSWORD="root")` line. `GB_TOKEN`
  scoping (guarded by the same flag) is retained — the new documented
  path's auth.
- **Verify:** grep → 0 matches in the file; `bash -n tests-v2/with-test-home`
  passes; no other file on the production surface consumes the variables
  except the card (next item) and the tool (item 4).

## Item 2 — gb-cli card rewrite (spec Scope 3-4; SC-3)

Governance: card edit goes through the deck-governance gate
(`skill-creator`) before the file is touched.

- **Deliverable:** `skills/gb-cli/SKILL.md` point 5 replaced and the card
  teaches the correct usage:
  1. Non-interactive issue state mutation: `gb api -X POST
     repos/{owner}/{repo}/issues/{number}/comments?action=close|reopen`
     with a non-empty JSON body via `--input <FILE|->`, token auth
     (`GB_TOKEN`).
  2. The preferred arg-passing idiom: content-bearing long options passed
     as `--long-option="$(cat file.md)"` (e.g. `gb issue comment N
     --body="$(cat msg.md)"`, `gb pr create --body="$(cat body.md)")`.
  3. Platform-awareness facts updated: plain-issue PATCH → 404 (route
     absent, catch-all 404); PR state PATCH exists; the comments?action
     route is the issue-state path; side effect = system comment, same as
     the web UI.
- **RED:** current card point 5 mandates `gitbucket-issue-state` and
  `GB_PASSWORD`/`GB_USER` — grep confirms; the card contradicts its own
  point 1.
- **GREEN:** rewrite per deliverable; keep points 1-4 and 6 intact.
- **Verify:** grep the card → no `gitbucket-issue-state`, no
  `GB_PASSWORD`/`GB_USER`; content contains the api route, the idiom, and
  the platform facts; `./.opencode/tools/reference-integrity` passes on
  the file.

## Item 3 — needs-approval scenario prompt fix (spec Scope 5; SC-4)

- **Deliverable:** `tests-v2/behaviors/needs-approval-remote-verification.sh`
  prompt routes through `gb`; script sets `BEHAVIOR_NEEDS_REMOTE=1`.
- **RED:** prompt contains `Use curl with -u root:root`; `behavior_run`
  is invoked bare so the `GB_HOST`/`GB_TOKEN` the prompt promises are
  never provisioned.
- **GREEN:** rewrite the prompt to create/verify the label via the `gb`
  CLI (creation with `-l needs-approval` or label add via api passthrough —
  labels are supported by GitBucket's API); add
  `BEHAVIOR_NEEDS_REMOTE=1` to the `behavior_run` invocation. Update the
  header comment to match.
- **Verify:** grep `curl -u` / `root:root` → 0; `BEHAVIOR_NEEDS_REMOTE=1`
  assignment present; `bash -n` passes.

## Item 4 — tool deletion (spec Scope 1; closes SC-1 and SC-2)

- **Deliverable:** `.opencode/tools/gitbucket-issue-state` deleted.
- **RED:** file exists; production-surface grep (excluding `attic/` and
  `.issues/`) for `gitbucket-issue-state` returns the tool itself (card
  and harness already cleaned by items 1-2).
- **GREEN:** `git rm` the tool.
- **Verify (SC-1 + SC-2 gates):** file-existence check → absent;
  recursive grep for `gitbucket-issue-state`, `GB_USER`, `GB_PASSWORD`
  over `.opencode` excluding `attic/` and `.issues/` → 0 matches each.

## Item 5 — SC-5 behavioral run (mechanism probe + harness run)

- **Mechanism probe (RED gate, no model cost):** provision the harness
  GitBucket (`BEHAVIOR_NEEDS_REMOTE` machinery), then run the exact
  documented command against the fixture instance:
  `gb api -X POST repos/root/test-repo/issues/1/comments?action=close
  --input <non-empty-json>` with the provisioned `GB_TOKEN`. This is the
  route's first runtime proof. **Failure here = BLOCKED to the developer**
  per the spec's analysis — the card must not document a broken route, and
  no credential-based fallback is permitted.
- **GREEN run:** one targeted run of
  `2561-sc1-verified-moot-closes-remote.sh` under the fixed card
  (§4 precondition cycle: submodule commit → push → fetch/verify → run;
  bash tool timeout ≥ 600000 ms; §14 monitored run, §10.7 supervisor
  polling with text updates). Post-run remote-state check: API read
  confirms the issue closed.
- **Verify:** full artifact set in the evidence directory;
  remote state = closed; §14 monitoring evidence recorded.

## Item 6 — SC-6 clean-room evaluation

- **Deliverable:** separate clean-room dispatch reading SC-5's
  `session.yaml` (+ timeline), judging: remote state change performed via
  `gb`; no session-cookie sign-in; no `GB_PASSWORD`/password usage; no
  config-file spelunking outside the repo.
- **Verify:** PASS/FAIL verdict with event citations recorded alongside
  the artifacts.

## Dependency graph

Item 1 → Item 2 → Item 3 → Item 4 → Item 5 → Item 6. The SC-5 mechanism
probe may run any time after item 1 (provisioning no longer exports the
credential vars); the GREEN run requires items 2-4 landed and pushed.
