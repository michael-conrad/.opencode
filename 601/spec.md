# Fork-aware repo identity — informational `fork_of` annotation in session-init

## Problem

`session-init` resolves each repo entry's `owner`/`repo` from the clone's git
remote URL and emits them in the `## Repo Information` section
(`.opencode/tools/session-init` — `collect_repo_info()`, emission block
"Emit unified ## Repo Information"). When the origin URL points at a fork —
a forked root repo, or a submodule tracking a fork — the emitted identity is
the fork's, and the agent has no way to know an upstream parent exists. Issue
routing therefore targets the fork silently. Whether that is correct depends
on the developer's workflow, so the fix is to expose the fact, not to redirect.

## Design

Normative summary of the decided behavior:

- **Inform, never route.** Fork status and the upstream parent are surfaced as
  a factual annotation on the existing repo notices. All routing rules stay
  exactly as they are.
- **Detection lives in the session-init identity pipeline** — one
  implementation surface; every agent and sub-agent sees the annotation for
  free through the session prompt.
- **The probe is background and best-effort.** session-init never performs
  synchronous network access; a detached background process probes and stamps
  results for future sessions.
- **Results are cached locally inside `.git/`** so steady-state sessions make
  zero API calls.
- **Failure is fully silent.** Any probe failure leaves the annotation absent
  and the output clean.

### Detection

- For each distinct repo resolved by the identity pipeline (root repo and
  mapped submodules, deduplicated), probe fork status and parent via the
  platform's authenticated CLI:
  - GitHub: `gh repo view <owner/repo> --json isFork,parent` (fields verified
    live against github.com).
  - GitBucket: the authenticated `gb` interface (e.g. `gb repo view` or
    `gb api repos/{owner}/{repo}`); exact command chosen at implementation.
- No hand-rolled HTTP/API code. The probe carries its own hard timeout and
  spawns detached (survives session-init exit). Stamp writes are atomic
  (temp file + rename).
- GitBucket specifics: an absent `parent` field on a fork-true response, or an
  unreachable/unreliable instance, is recorded as a negative result — treated
  as "no annotation", never as an error.

### Cache (stamp)

- Location: `<git-common-dir>/opencode/fork.json` — inside `.git/`, therefore
  auto-ignored, invisible to `git status`, per-clone, and worktree-safe. Never
  committed, never in tracked files, never in the upstream repo (writing
  upstream requires push access that may not exist, and it is a different
  working copy).
- Key: the origin remote URL that produced the resolved identity.
- Contents: `fork` (bool), `parent` (`owner/repo`, present only when forked),
  probed-at timestamp, and negative results ("probed: not a fork"; "probed:
  parent absent") recorded when the API actually answered.
- Freshness: entries older than 30 days (TTL) are treated as absent. A changed
  origin URL invalidates the entry. Offline sessions still read a valid stamp —
  the annotation works without network.

### Exposure

- When a valid stamp says fork, the repo's `## Repo Information` entry gains
  exactly one line: `fork_of: <parent_owner>/<parent_repo>`. Otherwise the
  entry is byte-identical to today's output.
- The annotation is purely factual. It is context for judgment, never a
  routing directive, and no consumer may treat it as an input to any decision
  mechanism.
- Accepted cost: the first session in a fresh clone may show no annotation
  until the background probe lands. For informational data with a 30-day
  freshness window this is the intended trade.

### Failure and interference policy

- Best effort end to end: no retries, no tombstones, no warnings. A failed
  probe writes nothing; the next session's background attempt is the only
  retry.
- session-init's runtime and output structure are identical regardless of
  network status; the only observable difference is the presence or absence of
  `fork_of` lines.
- The stamp is local, untrusted context. It informs routing judgment; it is
  never authorization.

## Analysis

The inform-only decision dissolves the failure scenarios the investigatory
phase enumerated: intentional fork workflows, forks without upstream access,
submodules deliberately pinned to patched forks, and fork-as-canonical
workflows cannot be violated because nothing is redirected — the agent simply
sees the parentage and routes by existing judgment. Multiple remotes are
unchanged: the probe follows the origin-resolved identity, as today. An
unreliable GitBucket `parent` field is absorbed by negative caching plus
silent degradation rather than becoming a routing hazard.

## Out of Scope

- No default routing change, no parent/fork default, no redirect logic
  anywhere.
- No configuration directive for preferred issue routing (unnecessary without
  a redirect).
- No opt-in marker file; the background probe is always-on and cost-free to
  the session.
- No edits to skills, guidelines, floor, or routing files.
- No tombstones, retry queues, or failure bookkeeping.

## Success Criteria

All criteria trace to the developer's stated requirements: fork annotation in
the session-init repo notices; a locally stamped probe result inside `.git/`
so sessions do not re-probe; best effort throughout; failure ignored; purely
informative use; and no blocking or interference with normal operations
regardless of network status.

**SC-1 — Fork annotation renders (behavioral).** With a valid stamp declaring
a repo a fork of `P`, the `## Repo Information` entry for that repo contains
exactly one added line `fork_of: P`; repos without a valid fork stamp are
unchanged. Instrument: execute `tools/session-init` in fixture clones with
prepared stamps — root-repo case and mapped-submodule case — and assert the
emitted section.

**SC-2 — Network independence (behavioral).** With the probe endpoint
unreachable, session-init completes promptly and its output is structurally
identical to the online run except for stamp-derived `fork_of` lines.
Instrument: run session-init with the probe endpoint unreachable in a fixture
and compare output structure and completion against an online run.

**SC-3 — Fire-and-forget probe (structural).** The probe path performs no
synchronous network access: it is spawned detached, carries a hard timeout,
writes stamps atomically, and uses only the authenticated CLIs (`gh`/`gb`) —
no raw HTTP client code. Instrument: fact-decidable code inspection (spawn
mechanism, timeout, atomic rename; grep for absence of hand-rolled HTTP).

**SC-4 — Silent failure (behavioral).** Any probe failure (non-zero exit,
timeout, malformed or missing fields) yields no annotation, no error or
warning text in session-init output, and an unchanged stamp. Instrument:
fixture with a forced-failing probe; assert output identical to the
stamp-absent case.

**SC-5 — Stamp location and schema (structural).** The stamp exists at
`<git-common-dir>/opencode/fork.json`, keyed on origin URL, holding fork
status, parent, timestamp, and negative results recorded only when the API
answered. Instrument: trigger one probe in a fixture and inspect the file
path and JSON schema.

**SC-6 — TTL and negative caching (behavioral).** A stamp older than the TTL
is treated as absent (annotation suppressed, background re-probe triggered);
a valid negative result suppresses re-probing until expiry. Instrument:
backdate a fixture stamp's mtime and run twice; assert suppression on
staleness and zero probe invocations on the run following a cached negative
result.

**SC-7 — Informative-only scope (structural).** The change is confined to the
session-init identity/repo-information surface; no skill, guideline, floor, or
routing file is modified, and `fork_of` appears only as emitted context.
Instrument: diff-scope check plus grep verifying no routing rule or other
consumer references `fork_of`.

**SC-8 — Platform coverage, best-effort (behavioral).** GitHub: the annotation
renders for a stamped fork via `gh`. GitBucket: the annotation renders when
obtainable through the authenticated `gb` interface and is silently absent
otherwise — both branches hold without error noise. Instrument: live GitHub
fixture; GitBucket obtainable/not-obtainable cases as the `gb` capability
permits, asserting silence on the not-obtainable branch.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
