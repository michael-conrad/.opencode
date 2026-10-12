# SC-5 mechanism probe — 2026-10-12

Runtime proof of the spec's documented route (first runtime verification;
source-read finding confirmed against live GitBucket 4.48.0 provisioned by
the tests-v2 harness, `__reset_gitbucket` + `__ensure_gitbucket`).

## Result: PASS

| Step | Command | Observed |
|------|---------|----------|
| create | `gb issue create -t "mechanism probe 2589" -b "probe body"` | `✓ Created issue #1` |
| read (auth as-provisioned) | `gb api repos/root/test-repo/issues/1` | 200, `"state": "open"` — the harness's `gb auth login -H $GB_HOST -t $GB_TOKEN` wiring sufficed; no explicit re-login, no password, no session cookie |
| **close** | `gb api -X POST repos/root/test-repo/issues/1/comments?action=close --input close.json` (`{"body":"closing via api route probe (.opencode#2589)"}`) | comment created (id 1); `"state": "closed"` |
| **reopen** | `gb api -X POST repos/root/test-repo/issues/1/comments?action=reopen --input reopen.json` | comment created (id 2); `"state": "open"` |
| negative control | `gb api -X PATCH repos/root/test-repo/issues/1 --input {"state":"closed"}` | `Error: API error (404): {"message":"Not Found"}` — matches the source-read (route absent, catch-all 404) |

## Facts established for the card

- The route works exactly as the spec documents: token auth (`GB_TOKEN`
  via gb's auth wiring), non-empty JSON body required, `action=close|reopen`
  query parameter drives state.
- Side effect confirmed: each state change writes a visible comment (same
  effect as the web UI button).
- Plain-issue PATCH remains 404 — the platform-awareness fact stands.
- `gb issue create` prints `✓ Created issue #N` + URL — useful for
  scripted flows.

Probe run: clean fixture instance on port 43305, torn down after the run.
