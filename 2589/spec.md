---
number: 2589
title: "[SPEC] Remove bespoke gitbucket-issue-state tool; gb-cli card documents correct gb usage"
state: OPEN
labels: [spec]
---

## Problem Statement

The deck's standing mandate (`.opencode#1324`, closed) retired bespoke GitBucket
tooling and replaced it with the system-provided `gb` CLI. During the
`.opencode#2564` remediation (2026-10-09) a new bespoke tool,
`.opencode/tools/gitbucket-issue-state`, was introduced without reporting the
deviation from that mandate: it hand-rolls GitBucket authentication (session-cookie
sign-in with an account password) and bypasses the `gb` CLI's built-in auth. The
`#2564` store carries no decision record — zero comments; its spec delegated the
fix choice to developer judgment and none was recorded — yet the tool was wired
into the deck as a sanctioned path.

Developer ruling (session 2026-10-12): the tool is a hidden spec change and an
escape hatch that triggers credential hunting and spelunking of config files
outside the main repo being worked on.

Mechanism of the credential hunt: the tool requires `GB_PASSWORD` — an account
password, not a token — which exists in no production configuration. The only
 occurrence anywhere in the tree is the harness fixture export
(`with-test-home`: `GB_USER=root` / `GB_PASSWORD=root` under
`BEHAVIOR_NEEDS_REMOTE=1`). Outside the harness the tool is unusable, and its own
error output (`check GB_PASSWORD`) directs the agent to hunt for the password —
exactly the behavior the floor prohibits ("never search for tokens or
passwords"). The `gb-cli` card launders the escape hatch: its point 1 forbids
bespoke auth code and credential hunting while its point 5 mandates the
password-based tool and fences re-implementation elsewhere.

Adjacent surface of the same defect class:
`tests-v2/behaviors/needs-approval-remote-verification.sh` embeds
`Use curl with -u root:root for authentication` in its scenario prompt —
hand-rolled API usage with hardcoded fixture credentials — and its prompt claims
`GB_HOST`/`GB_TOKEN` are set while its bare `behavior_run` (no
`BEHAVIOR_NEEDS_REMOTE=1`) never provisions them.

## Platform Facts (live-verified 2026-10-12)

Verified by source read of `gitbucket/gitbucket` at master and tag 4.48.0
(byte-identical for the relevant controllers), plus `gb` 0.6.1 binary inspection:

- GitBucket implements **no** issue state mutation for plain issues over its
  GitHub-compatible API: `ApiIssueControllerBase` defines only list/get/create;
  the API router catch-alls every unmatched method to 404.
- PRs are the exception: `PATCH /api/v3/repos/{o}/{r}/pulls/{n}` accepts `state`.
- A token-authenticated **non-interactive issue-state path exists**:
  `POST /api/v3/repos/{owner}/{repo}/issues/{number}/comments?action=close`
  (or `?action=reopen`) — the comment-creation endpoint forwards `action` into
  the state-mutating handler (writes the system comment, fires webhooks,
  records activity). The JSON body must be non-empty (route guard). Source-read
  verified; **not yet runtime-verified** — SC-5 is the runtime gate.
- `gb` 0.6.1 exposes the passthrough (`gb api <ENDPOINT>`, `-X/--method`,
  `--input <FILE|->`) and content-bearing long options (`--body`, `--title`) on
  `issue create`, `issue comment`, `pr create` — sufficient to express the route
  with `GB_TOKEN` auth: no session cookie, no password, no bespoke code.
- No upstream GitBucket issue or PR proposes adding the missing endpoint; the
  gap is server-side and expected to persist.

## Scope

1. Delete `.opencode/tools/gitbucket-issue-state`.
2. Remove the tool's orphaned credential plumbing in `tests-v2/with-test-home`:
   the `GB_USER`/`GB_PASSWORD` export and its `gitbucket-issue-state` comment
   block. Dead credential material must not outlive its consumer.
3. Rewrite `skills/gb-cli/SKILL.md` point 5: non-interactive issue state
   mutation goes through `gb api -X POST repos/{owner}/{repo}/issues/{number}/comments?action=close|reopen`
   with a non-empty JSON body (`--input <FILE|->`) and token auth. Update the
   platform-awareness note to the verified facts (plain-issue PATCH → 404; PR
   state PATCH exists; the comments?action route is the issue-state path).
4. Add the developer-mandated arg-passing idiom to the card: content-bearing
   long options are passed as `--long-option="$(cat file.md)"` — e.g.
   `gb issue comment N --body="$(cat msg.md)"`,
   `gb pr create --body="$(cat body.md)"` — presented as the preferred pattern;
   `gb api` JSON payloads go through `--input <FILE|->`.
5. Rewrite the `needs-approval-remote-verification.sh` scenario prompt to route
   through `gb` (no curl, no embedded credentials) and set
   `BEHAVIOR_NEEDS_REMOTE=1` so the env vars its prompt references are actually
   provisioned.

**Out of scope:** upstream GitBucket contribution (none in flight; separate
decision); changes to `gb` itself (system-provided; the gap is server-side);
`attic/` content (preserved pre-replacement deck, soak pending); GitHub-platform
paths and other connector cards; the tests-v2 GitBucket provisioning machinery
itself (`__ensure_gitbucket` — test infrastructure, not agent-facing tooling);
`GB_TOKEN` provisioning (retained — token auth is what the new path uses).

## Success Criteria

| ID | Criterion | Type | Instrument |
|----|-----------|------|------------|
| SC-1 | `.opencode/tools/gitbucket-issue-state` does not exist, and no reference to it remains anywhere under `.opencode/` excluding `attic/` | structural | file-existence check + recursive grep for `gitbucket-issue-state` over `.opencode` (excluding `attic/`) → 0 matches |
| SC-2 | No `GB_PASSWORD` occurrence remains anywhere under `.opencode/` excluding `attic/` | structural | recursive grep over `.opencode` (excluding `attic/`) → 0 matches |
| SC-3 | `gb-cli` SKILL.md contains no bespoke-tool reference and no password-credential instruction, and documents (a) the non-interactive issue state-mutation route via `gb api` (`POST repos/{o}/{r}/issues/{n}/comments?action=close\|reopen`, token auth, non-empty body), (b) `--long-option="$(cat file.md)"` as the preferred arg-passing pattern for content-bearing options with at least one concrete `gb` example, (c) the platform-awareness facts (plain-issue PATCH → 404; PR state PATCH exists) | structural | file read + grep; `./.opencode/tools/reference-integrity` passes on the file |
| SC-4 | `needs-approval-remote-verification.sh` prompt contains no curl/basic-auth credential instruction and the script sets `BEHAVIOR_NEEDS_REMOTE=1` | structural | file read + grep (`curl -u`, `root:root` → 0 matches; flag assignment present) |
| SC-5 | A targeted run of `2561-sc1-verified-moot-closes-remote.sh` (`BEHAVIOR_NEEDS_REMOTE=1`) completes with the full artifact set, and a post-run remote-state check shows the scenario's remote issue closed — the documented `gb` path closes a GitBucket issue non-interactively | behavioral | harness run (`with-test-home`, `session.yaml` export) + post-run API read of the remote issue's state |
| SC-6 | Clean-room evaluation of SC-5's `session.yaml` confirms the run agent performed the remote state change through `gb` (api or CLI), with no session-cookie sign-in, no `GB_PASSWORD`/password usage, and no config-file spelunking outside the repo | behavioral | clean-room sub-agent reads `session.yaml` (+ `session-to-timeline`), returns PASS/FAIL with event citations |

**Ordering:** SC-3 before SC-5 (the run agent follows the card's documented
usage); SC-5 before SC-6 (evaluation consumes SC-5's artifacts). Per the
tests-v2 two-SC pattern, SC-5 is the artifact-generation run and SC-6 is the
separate clean-room evaluation dispatch.

## Analysis and Risks

- **Runtime risk on the documented route.** The `?action=close` path is
  source-read-verified but not yet runtime-verified. SC-5 is the gate: if the
  route fails at runtime, the run FAILS and the pipeline halts to the developer
  — falling back to any credential-based mechanism is prohibited (that is the
  defect class this spec removes). `#2564` remains closed; its SC-1 capability
  is re-established through the new path, and a SC-5 failure reopens the
  capability question to the developer.
- **Visible side effect.** The comment-route close writes a system "Close"
  comment on the issue — the same effect as the web UI button; acceptable.
- **Removal consumer inventory.** `GB_PASSWORD` consumers are exactly: the tool
  (deleted), the card text (rewritten), the harness export block (removed).
  No other consumer exists (grep-verified 2026-10-12).
- **`2561-sc1` needs no prompt change.** Its prompt names the `gb` CLI and the
  reachable remote tracker without prescribing a mechanism (valid prompt
  construction); the fixed card supplies the how.

## Provenance

- Developer directive, session 2026-10-12: bespoke code is to be removed; the
  skill card is fixed to reflect correct `gb` usage, including the preferred
  `--long-option="$(cat file.md)"` arg-passing idiom.
- Developer ruling, session 2026-10-12: the tool is a hidden spec change, an
  escape hatch triggering credential hunting and config spelunking.
- Standing mandate: `.opencode#1324` — retire bespoke GitBucket tooling in
  favor of `gb`.
- Prior defect chain: `.opencode#2564` (introduced the tool; closed with no
  decision record), `.opencode#2561` (SCs the state-mutation capability serves).
- Research dispatch 2026-10-12: GitBucket source at master + 4.48.0
  (ApiIssueControllerBase, ApiController, ApiIssueCommentControllerBase,
  IssuesController, HandleCommentService, PullRequestService), 4.48.0 release
  notes, upstream tracker search, `gb` 0.6.1 binary route-string inspection.

Predicate classification: SC-1 through SC-4 are fact-decidable at the mechanism
level; SC-5 and SC-6 are behavioral (runtime effect on agent behavior and
remote state).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
