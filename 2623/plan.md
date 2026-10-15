# Plan — local-issues: ssh:// origins + per-host browser-base mapping

Resolves `.opencode#2623` (second defect of `.opencode#2620`). Consumes `.opencode/.issues/2623/spec.md`.

## Items

### Item 1 — URL-builder RED test suite and loader wiring (SC-1, SC-2, SC-3, SC-4, SC-6, SC-7, SC-8, SC-9; SC-5's parse-time reading clause)

- **Deliverable:** `tests/test_local_issues/test_remote_browser_base.py` covering the full scheme × mapping matrix: mapped family host (`tomcat-0002.newsrx.com` → `https://gitbucket.newsrx.com/gitbucket`) across ssh:// (user, port, `.git`), git+ssh://, scp-form, https, and a portless ssh variant (SC-1, SC-3, SC-6, SC-9); unmapped ssh → same-host https, unmapped scp/https → today's outputs (SC-2); missing origin / unparseable URL → exit 1 with `error: no usable origin remote for repo '<name>'` (SC-4); config absent and config-present-but-unmapped → derived conversion (SC-7); corrupt config file → stderr warn-and-skip naming path and error class, exit 0, derived URL on stdout (SC-8). Mapped-host entry wins over derived conversion — part of SC-6 — asserted inside the mapped-host cases.
- **RED:** run the suite against current `_remote_browser_base` — ssh:// origins return `None` → error path; every mapped-host and ssh case fails.
- **GREEN:** implement in `.opencode/tools/local-issues`:
  - Extend `_remote_browser_base` parsing with `ssh://[user@]host[:port]/owner/repo(.git)` and `git+ssh://` forms (user, port, `.git` each optional).
  - Implement the host-mapping loader: resolve a config file beside the tool (`tools/local-issues-host-maps.conf`, `key = value` lines: hostname → browser base; `#` comments), read at parse time; hostname-keyed, scheme-independent match (entry key may carry `:port` informationally — match is on hostname); mapping wins over derived conversion. Creating the shipped config file itself is Item 2 — Item 1's tests supply their own config fixtures.
  - Unmapped hostnames: scp/https unchanged; ssh:// falls back to same-host `https://host/owner/repo`.
  - Present-but-unparseable config: warn-and-skip via the tool's existing `_warn_skip` pattern (stderr, path + error class), proceed with derived conversion.
  - No-origin and unparseable-URL paths unchanged (exit 1, current text).
- **Instrument:** pytest run of the new suite; all cases green.
- **Fixture mechanics:** the suite sandboxes the tool the way the existing suite does (tool copied into a sandbox `.opencode/tools/`), and each test writes the host-mapping config file beside that tool copy (or leaves it absent/corrupt per case) — the loader resolves the config relative to the tool's own location, so no environment variable or shipped-file dependency is needed at test time. This also covers SC-8's corrupt-config fixture.

### Item 2 — Config committed and documented (SC-5)

- **Deliverable:** the config file exists committed beside the tool with the family entry (`tomcat-0002.newsrx.com` → `https://gitbucket.newsrx.com/gitbucket`); `local-issues-cli.md` documents the mapping at the `url` command entry.
- **RED:** file absent; grep of `local-issues-cli.md` for the mapping finds nothing.
- **GREEN:** author config + doc paragraph.
- **Instrument:** file inspection + grep.

## Dependencies

Item 1 is self-sufficient (its tests supply their own config via the fixture mechanics above); Item 2 commits the shipped config and documents it. Both land in one per-issue commit.

## Traceability

- Item 1 → SC-1–SC-4, SC-6–SC-9, plus SC-5's clause that `_remote_browser_base` reads the mapping at parse time (the wiring Item 1 implements). Item 2 → SC-5's remaining clauses (config file committed beside the tool; documented in `local-issues-cli.md`). All SCs covered; no untraceable items.

## Verification instruments

- `pytest tests/test_local_issues/test_remote_browser_base.py` (executed output captured).
- Structural greps per Item 2.
