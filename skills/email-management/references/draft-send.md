<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2532 -->

# Details: draft and send — dry-run by default, explicit send authorization, server-verified delivery

Syntax shown uses `<tb>` as the binary invocation from the install card.
Sending is irreversible and outward-facing: **every real send requires an
explicit developer instruction in the current session.** Without one, stop at
the dry-run output and report it. This rule is intent-decidable — no script
enforces it; judgment decides. The same applies to mailbox moves
(`mail move`), which refile mail on the server.

## Reply — the default draft path

```sh
printf '%s\n' "Reply body here" > reply.txt
<tb> reply "support ticket" --body-file reply.txt        # prints what it WOULD send — nothing is sent
```

The reply command resolves the thread from the same query syntax as the
one-shot search, answers the newest *inbound* message (never your own last
word), and derives From (the identity that received it), Subject,
`In-Reply-To`, and the full `References` chain itself. Never hand-assemble
those headers — a reply without threading headers opens a new ticket instead
of continuing the existing one.

For anything longer than a line use `--body-file` (`-` reads stdin); inline
`--body` is a quoting hazard.

## Compose — a new message

```sh
<tb> mail compose --to a@example.org --subject "Ping" --body "Hello"      # dry run
```

## The send boundary

When — and only when — the developer explicitly instructs a send in the
session, re-run the same command with `--send` added:

```sh
<tb> reply "support ticket" --body-file reply.txt --send --verify 60s
```

A successful send prints the Message-ID, transport, and Sent-copy status.
`--verify <duration>` polls the Sent mailbox **on the server** for the
Message-ID before returning.

## Post-send verification

- Confirm delivery with the sent-check command:
  `<tb> mail sentcheck --from <sender> --message-id '<id-from-the-send>'`.
- Never conclude a send failed (or succeeded) from a local Sent-folder read —
  the local mbox cache lags, and re-sending off a stale read has produced
  duplicate mail. Ask the server instead.
- Threading headers require a direct-send identity; when the tool refuses the
  combination rather than sending unthreaded, report that as the tool working
  as designed, not a bug to work around.

## Move (also outward-facing)

Reclassifying a provider's filing — e.g. pulling a message out of Junk — is a
real mailbox move on the server and requires the same explicit instruction:

```sh
<tb> mail move --source-mailbox Junk --dest-mailbox INBOX --message-id '<id>'
```

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
