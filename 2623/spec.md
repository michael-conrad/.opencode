# [SPEC] local-issues: parse ssh:// origins and per-host browser-base mapping for `url --artifacts`

Resolves `.opencode#2623` (second defect of `.opencode#2620`).

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | `local-issues url --number repo#N --artifacts` fails on every family root with `error: no usable origin remote for repo '<name>'`. `_remote_browser_base` (`.opencode/tools/local-issues`, line ~1779) parses exactly two origin shapes — scp-style `git@host:owner/repo.git` and `https?://` — while family origins are the ssh:// form (`ssh://git@tomcat-0002.newsrx.com:29418/NewSRX-Tech-LLC/<repo>.git`). Independently, a generic ssh→same-host-https conversion is insufficient for the family: the ssh host and web host differ (`tomcat-0002.newsrx.com:29418` web face is `gitbucket.newsrx.com/gitbucket`) and no property of the URL derives that mapping. The deck's mandated blockquoted artifacts link therefore cannot be built with the documented tool on any family root. |
| 2 | **Root Cause / Motivation** | The URL builder was written for the two origin shapes of the deck's own hosting and never generalized to the ssh:// scheme or to split ssh/web host families. Motivation observed 2026-10-15 in the #2620 triage: the failure is reproducible from the source (both regexes reject the ssh:// form → `None` → exit 1), and the deck spec (`.opencode#2622`) mandates a link this tool cannot currently produce family-wide. |
| 3 | **Approach Chosen** | Extend `_remote_browser_base` to parse `ssh://[user@]host[:port]/owner/repo(.git)` and `git+ssh://` forms with the existing scp-style/https behavior untouched; add a committed, versioned host-mapping config shipped beside the tool in the deck repo, read at parse time, mapping ssh `host[:port]` → browser base — a matching entry overrides derived conversion (family entry: `tomcat-0002.newsrx.com:29418` → `https://gitbucket.newsrx.com/gitbucket`); an unmapped ssh origin falls back to same-host `https://host/owner/repo`; no-origin and unparseable-URL error paths are preserved. Unit tests cover the full scheme × mapping matrix in the existing `tests/test_local_issues/` suite. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Parse ssh:// and convert same-host always — discarded: produces `https://tomcat-0002.newsrx.com/...` for the family, a wrong URL that looks plausible; a silently-wrong link is worse than an error. (b) Hard-code the GitBucket port/shape mapping in the tool — discarded: family-specific facts do not belong in family-agnostic tool code; the deck ships to every family mount, so a committed config table carries the facts once, versioned. (c) Per-clone git-config key — discarded: unversioned, per-clone setup burden across the whole family, and the mapping is a property of the platform, not the clone. (d) Derive the web base from the remote URL path — impossible: the family's remote path carries no `/gitbucket/` segment to derive from. |
| 5 | **Key Design Decisions** | (1) Mapping is host-level (`host[:port]`), not repo-level: one entry covers all family repos on that GitBucket instance. (2) The mapping table is committed in the deck repo beside the tool — versioned, family-shared, and documented in `local-issues-cli.md` alongside the `url` command's entry. (3) Same-host https is the fallback for unmapped ssh origins (ordinary ssh hosts like `git@github.com` style already work via scp-form; the ssh:// fallback covers the rest). (4) The config is optional: absent file or absent entry → pure derived conversion, so upstream generic users see no behavior change. (5) Predicate classification: every criterion here is behavioral (the tool's runtime output) with executed-test instruments, plus one structural criterion for the config file's existence and wiring. |
| 6 | **User Intent / Original Prompt** | Session 2026-10-15: "triage .opencode#2620 and brainstorm a fix spec" → triage verified the ssh:// parse failure against the tool source; developer delegated the spec-structure analysis ("I have no clue. You are the one analyzing the requirements for the spec or specs") and approved the two-spec split with per-repo/per-host browser-base override as the mapping mechanism; "proceed" finalized the design. |

## 2. Not Included

- **The deck body-format/blockquote mandates** — companion spec `.opencode#2622`; this change only makes the documented mechanic work.
- **Other `local-issues` remote handling** — push/fetch/credential paths are untouched; no authentication surface changes.
- **Per-repo (as opposed to per-host) mapping entries** — the config maps hosts; if a future platform needs repo-level overrides, that is a separate change.
- **CLI flags for mapping** — the config file is the surface; no `--browser-base` flag is added.

## 3. Success Criteria

RED states verified on 2026-10-15: `_remote_browser_base` contains exactly two regexes (`git@host:owner/repo` scp-form, `https?://`); `ssh://` and `git+ssh://` origins match neither; the tool reads no host-mapping surface today — its only config parsing is `configparser` over `.gitmodules` for repo discovery (line ~383), which carries no URL data; the existing suite `tests/test_local_issues/` has no URL-builder test file.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | For a repo whose origin is `ssh://git@tomcat-0002.newsrx.com:29418/NewSRX-Tech-LLC/<repo>.git`, `url --number repo#N` emits `https://gitbucket.newsrx.com/gitbucket/NewSRX-Tech-LLC/<repo>/issues/N` and `url --number repo#N --artifacts` emits `https://gitbucket.newsrx.com/gitbucket/NewSRX-Tech-LLC/<repo>/tree/issues-data/N/`. | behavioral | Executed unit test with a fixture repo carrying that origin; real command output. |
| SC-2 | For an ssh origin whose host[:port] has no mapping entry, the tool emits the same-host https base (`https://host/owner/repo`). | behavioral | Executed unit test. |
| SC-3 | scp-style (`git@host:owner/repo.git`) and https origins produce outputs identical to current behavior (no regression). | behavioral | Executed unit tests asserting the current known outputs. |
| SC-4 | `git+ssh://[user@]host[:port]/owner/repo(.git)` origins parse to a base. | behavioral | Executed unit test. |
| SC-5 | A missing origin remote or an unparseable URL still exits 1 with `error: no usable origin remote for repo '<name>'`. | behavioral | Executed unit test asserting exit code and stderr text. |
| SC-6 | The host-mapping configuration file exists committed beside the tool, `_remote_browser_base` reads it at parse time, and `local-issues-cli.md` documents it at the `url` command entry. | structural | File inspection + grep of the tool and the reference doc. |
| SC-7 | A mapping entry wins over derived conversion when both would produce a base for the same host. | behavioral | Executed unit test with a mapped host that also parses generically. |
| SC-8 | An empty or absent mapping config leaves ssh:// parsing functional via the same-host fallback (config optionality). | behavioral | Executed unit test with no config file present. |

## 4. Traceability

- SC-1 traces to the observed family failure in #2620 (the exact origin form and the exact expected web URL from the defect record). SC-2/SC-4/SC-5/SC-8 trace to the developer-approved design decisions (fallback, git+ssh scope, preserved error path, config optionality). SC-3 preserves unchanged behavior the change puts at risk. SC-6 traces to the design decision that family-specific facts live in committed config, not tool code. SC-7 pins the override precedence the design states.
- The stated root causes (unparsed ssh:// scheme; underivable host mapping) are each covered: the parser extension covers the first, the mapping table covers the second.
