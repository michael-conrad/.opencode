# Plan — .opencode#2532 email-management skill card set

Derived entirely from `.opencode/.issues/2532/spec.md`. One item per SC,
dependency-ordered. Instrument per item; status lives in pipeline state, never
here.

Underlying tool (research-validated, developer-selected): prebuilt Go
`thunderbird-cli` (`tb`), `avikalpa/thunderbird-cli` v3.5.0 release artifact +
`SHA256SUMS.txt`. Layering: router surface is intent-only; all tooling tokens
live one level down.

## P1 — SKILL.md card (SC-1, SC-2)

- **Deliverable:** `.opencode/skills/email-management/SKILL.md` — valid
  frontmatter (name, description, license: MIT, provenance
  `AI-authored, .opencode#2532`), SPDL header lines, lean numbered body
  delegating to details cards.
- **Description constraint (SC-2):** intent-phrased; contains NO tokens:
  thunderbird, betterbird, tb, go, golang, npm, mail-client product names, or
  "cli" as tooling identity; states what the skill does AND when to load it at
  both abstraction levels (search/read/draft/send email already in the mail
  client; plus the generic "read/search/draft email" intent).
- **RED:** card directory absent → `./.opencode/tools/skildeck lint` reports
  missing/garbled card; description token grep hits nothing because card
  doesn't exist.
- **GREEN:** write the card.
- **Instrument:** `skildeck lint` exit clean; token grep over the description
  field returns zero hits for the forbidden list (case-insensitive).

## P2 — Details cards (SC-3)

- **Deliverable:** `references/install.md`, `references/search-read.md`,
  `references/draft-send.md`; each linked from SKILL.md prose; exactly one
  level deep; tool command syntax appears only here.
  - `install.md`: SHA256-verified release download (linux_x86_64 per-machine,
    other archives named) into a repo-local tools dir; `chmod +x`; runtime
    verification via `doctor`; profile-root discovery incl. `THUNDERBIRD_HOME`
    and Flatpak roots; explicit no-profile-modification property (cache in XDG
    state); NSS libs note (only needed for send features).
  - `search-read.md`: `tb doctor` first; `tb q "<what>"` one-shot search
    (JSON when piped), follow `read` field verbatim; `tb read --message-id ...
    --save-attachments DIR` for attachments; triage order (`tail` before
    keyword search); sync caveat (needs display; fails rather than stale).
  - `draft-send.md`: `tb reply "<query>" --body-file reply.txt` /
    `tb mail compose ...` are dry-run unless `--send`; real send requires
    explicit developer instruction in the session; post-send verification via
    `--verify <duration>` and `tb mail sentcheck --from ... --message-id ...`;
    never judge send success from a local Sent-folder read.
- **RED:** link check fails (SKILL.md references missing files).
- **GREEN:** write cards.
- **Instrument:** `./.opencode/tools/reference-integrity` exit clean; file
  listing matches spec's exact card set; token grep of SKILL.md (full file)
  returns no tool tokens.

## P3 — Root-agnostic sweep (SC-4)

- **Deliverable:** card set contains no repo names (opencode-config, michael-
  conrad, avikalpa, thunderbird-cli *as identity in prose*), no `/home/`
  absolute paths; per-root facts arrive via session-init/runtime discovery.
- **RED:** grep sweep over the new files hits.
- **GREEN:** rewrite generic (e.g. "the upstream tool's GitHub releases").
- **Instrument:** `grep -rnE '(opencode-config|michael-conrad|avikalpa|thunderbird-cli|/home/)' .opencode/skills/email-management/` → zero hits.

## P4 — routing.md row (SC-5)

- **Deliverable:** one new row in the routing index table mapping email
  intent → `email-management`; no other rows touched.
- **RED:** routing.md has no email row.
- **GREEN:** add row.
- **Instrument:** `git diff routing.md` shows exactly one added table row.

## P5 — Governance record (SC-6)

- **Deliverable:** skill-creator admission-gate evidence written into the PR
  body; deck-debt ledger entry recorded (no dedicated deck-debt issue exists
  in the store — create it as the ledger entry, or comment on the existing
  ledger issue if one is found mid-work).
- **Instrument:** PR body inspection + `local-issues search` shows the entry.

## P6 — SC-7 behavioral: fresh-context install run

- **Deliverable:** tests-v2 scenario `2532-sc7-email-install-fresh-context.sh`
  (artifact-only generator), prompt = real-domain task: "install this deck's
  email tool from its details card into a scratch location and verify it
  works, without touching any mail profile." Run per the ordered precondition
  cycle (commit → push → fetch/verify → run). Monitor per §14.
- **Instrument:** clean-room evaluation of `session.yaml`: doctor invoked and
  succeeding in the agent's own narrative/timeline; profile-state hash
  pre/post unchanged (orchestrator-side comparison).
- **Feasibility note:** the run needs network + GitHub release download in the
  test home; if the sandbox blocks it, the scenario pins a pre-fetched artifact
  in `fixtures/setup/` and the card directs via a URL — identical procedure.

## P7 — SC-8 behavioral: fresh-context search-read run

- **Deliverable:** scenario `2532-sc8-email-search-read.sh`; the prompt tasks the
  agent to search the local populated profile for a real mailbox term and
  retrieve a message body + attachment list following the card, read-only.
- **Instrument:** clean-room evaluation of `session.yaml` (search results
  produced, `read` command followed, body retrieved); profile hash unchanged
  pre/post. Authorization: the developer's spec explicitly names the populated
  local profile as the instrument (read-only).

## P8 — SC-9 behavioral: dry-run-default run on disposable fixture

- **Deliverable:** fixture script constructing a disposable minimal profile
  under the test home's `~/.thunderbird` (profiles.ini + local mbox with a
  couple of messages); scenario `2532-sc9-email-draft-dryrun.sh` prompting the
  agent to draft a reply per the card with NO send authorization.
- **Instrument:** clean-room evaluation: agent executes the documented
  dry-run command; no `--send` invocation; no sent message produced. Never
  the production profile.
- **Feasibility gate (spec-mandated):** if the minimal fixture profile proves
  unreadable by the tool, SC-9 returns for spec revision — not silently
  dropped.

## Dependency order

P1 → P2 (links) → P3 (sweep over files from P1–P2) → P4 → P5 → structural
gate → P6 → P7 → P8 (each behavioral run independently attributable to the
same pushed branch). Behavioral runs cannot start before the earlier commit is
pushed (harness gate).
