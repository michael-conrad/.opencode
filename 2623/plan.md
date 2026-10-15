# Plan — local-issues: ssh:// origins + per-host browser-base mapping

Resolves `.opencode#2623` (second defect of `.opencode#2620`). Consumes `.opencode/.issues/2623/spec.md`.

## Items

### Item 1 — URL-builder RED test suite (SC-1, SC-2, SC-3, SC-4, SC-6, SC-7, SC-8, SC-9)

- **Deliverable:** `tests/test_local_issues/test_remote_browser_base.py` covering the full scheme × mapping matrix: mapped family host (`tomcat-0002.newsrx.com` → `https://gitbucket.newsrx.com/gitbucket`) across ssh:// (user, port, `.git`), git+ssh://, scp-form, https, and a portless ssh variant (SC-1, SC-3, SC-6, SC-9); unmapped ssh → same-host https, unmapped scp/https → today's outputs (SC-2); missing origin / unparseable URL → exit 1 with `error: no usable origin remote for repo '<name>'` (SC-4); config absent and config-present-but-unmapped → derived conversion (SC-7); corrupt config file → stderr warn-and-skip naming path and error class, exit 0, derived URL on stdout (SC-8). Mapped-host entry wins over derived conversion (SC-7 of the spec's SC-6 family — asserted inside the mapped-host cases).
- **RED:** run the suite against current `_remote_browser_base` — ssh:// origins return `None` → error path; every mapped-host and ssh case fails.
- **GREEN:** implement in `.opencode/tools/local-issues`:
  - Extend `_remote_browser_base` parsing with `ssh://[user@]host[:port]/owner/repo(.git)` and `git+ssh://` forms (user, port, `.git` each optional).
  - Add a committed host-mapping config beside the tool (`tools/local-issues-host-maps.conf`, `key = value` lines: hostname → browser base; `#` comments). Load at parse time; hostname-keyed, scheme-independent match (entry key may carry `:port` informationally — match is on hostname); mapping wins over derived conversion.
  - Unmapped hostnames: scp/https unchanged; ssh:// falls back to same-host `https://host/owner/repo`.
  - Present-but-unparseable config: warn-and-skip via the tool's existing `_warn_skip` pattern (stderr, path + error class), proceed with derived conversion.
  - No-origin and unparseable-URL paths unchanged (exit 1, current text).
- **Instrument:** pytest run of the new suite; all cases green.

### Item 2 — Config committed and documented (SC-5)

- **Deliverable:** the config file exists committed beside the tool with the family entry (`tomcat-0002.newsrx.com` → `https://gitbucket.newsrx.com/gitbucket`); `local-issues-cli.md` documents the mapping at the `url` command entry.
- **RED:** file absent; grep of `local-issues-cli.md` for the mapping finds nothing.
- **GREEN:** author config + doc paragraph.
- **Instrument:** file inspection + grep.

## Dependencies

Item 1 → Item 2 (the doc references the mechanism Item 1 implements; both land in one per-issue commit).

## Traceability

- Item 1 → SC-1–SC-4, SC-6–SC-9. Item 2 → SC-5. All SCs covered; no untraceable items.

## Verification instruments

- `pytest tests/test_local_issues/test_remote_browser_base.py` (executed output captured).
- Structural greps per Item 2.
