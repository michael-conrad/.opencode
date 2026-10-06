<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2532 -->

# Details: search and read — one-shot search, returned read command, attachments

All commands here are read-only against the profile (see the install card's
no-profile-modification property). Syntax shown uses `<tb>` as the binary
invocation from the install card.

## One-shot search: start with `q`

```sh
<tb> q "<what you are looking for>"
```

`q` searches every account and folder (Junk and Trash included, ranked below
real mail), refreshes a stale cache, ranks by relevance, widens the match
automatically when nothing hits — telling you which strategy worked. Piped
output is JSON; `--text` forces human output, `TB_JSON=1` forces JSON
everywhere.

Useful narrowings in one call rather than several:

```sh
<tb> q --today --important                                    # what needs attention today
<tb> q "billing dispute" --thread --body                      # whole conversation, bodies inline
<tb> q "invoice" --from billing@example.com --attachments     # by sender, attachment names listed
<tb> q "invoice" --since 2026-01 --till 2026-02 --body        # date window (today/7d/2019-07 accepted)
```

`--important` is a heuristic and prints `importance_why` for every hit —
quote those reasons, never present the ranking as fact.

## Follow the returned read command verbatim

Every result carries a `read` field with the exact next command, e.g.:

```json
{
  "message_id": "<...@example>",
  "subject": "Re: [Ticket 13421571] billing dispute ...",
  "date": "2026-07-23T11:07:51Z",
  "read": "<tb> read --message-id \"<...@example>\""
}
```

Use that command as printed rather than reassembling `--folder`/`--query`
by hand. `read --save-attachments DIR` extracts attachments to a directory
(filenames come from untrusted mail; the tool reduces them to base names and
never clobbers existing files). `read --thread` opens the whole conversation.

## Triage order for fresh or time-sensitive hunts

Automated account mail often starts from one service address and the real
human reply arrives from another address under a different subject — a narrow
keyword search on the original sender misses it. When hunting fresh mail:

```sh
<tb> mail fetch --profile default --sync
<tb> tail --limit 30 --raw --ignore-folder junk,trash
<tb> list "Junk Mail" --limit 20 --raw
<tb> read --message-id '<id-from-the-listing>'
<tb> q "<keyword you learned from the fresh mail>"
```

Inspect recent mail before trusting a guessed keyword.

## Sync and staleness caveats

- `--sync` needs a display or a running mail client to join; on a headless
  host it **fails** rather than quietly answering from stale data. Check
  `<tb> doctor | grep 'Sync display path'` before a time-sensitive hunt.
- Reading and searching an already-synced profile needs no client running.
- A sync that changed nothing reports it; a stale-lock or hidden-dialog
  situation is visible by opening the client with `-profile <path>` on a real
  display (always use `-profile <absolute path>`, never `-P <name>`).

## Negative results

A negative result is evidence only when the tool says what it searched. The
tool names the folders it read on an empty result and lists candidates for an
unknown folder name — quote that scope in any "no such mail" conclusion.
Copies of one message across accounts collapse into a single result with
`also_in`; never report them as separate mail.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
