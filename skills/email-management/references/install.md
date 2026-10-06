<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2532 -->

# Details: install — checksum-verified binary, verified runtime, discovered profile

Install happens only when a session needs mail access; the binary is kept in
place afterward. The tool ships as a prebuilt release archive with no runtime
dependencies beyond two NSS libraries (needed only for send-side features).

## 1. Download and checksum-verify

Download the release archive and its `SHA256SUMS.txt` from the upstream
project's GitHub releases page (`https://github.com/avikalpa/thunderbird-cli`
→ Releases). Pick the archive for the machine's platform
(`linux_x86_64` is the common case; `linux_arm64`, `darwin_*`, `windows_*`
also exist). Verify before extracting:

```sh
grep '<archive-name>' SHA256SUMS.txt | sha256sum -c -
tar -xzf <archive-name>
```

A checksum mismatch is a hard stop — do not run an unverified binary.

## 2. Place the binary in a repo-local tools directory

Copy the extracted `tb` binary into the workspace's local tools directory
(the same convention the deck's other vendored tools use, e.g. alongside
`.tools/opencode/`), and make it executable:

```sh
cp tb <workspace-tools-dir>/tb && chmod +x <workspace-tools-dir>/tb
```

Invoke it by its explicit path for the rest of the session. `tb update` is
unsupported on Windows and only replaces the copy it runs from — re-run this
card's download step to upgrade instead.

## 3. Runtime verification — trust the live report

```sh
<workspace-tools-dir>/tb doctor
```

`doctor` checks everything live: profile discovery, cache backend, NSS
runtime libraries, send capability, and which copy of the tool a shell will
actually run (it warns when copies on `PATH` disagree — invoke by explicit
path to avoid that). On Linux, missing NSS runtime libraries for send
features are installed with the distribution packages (`libnss3`,
`libnspr4` on Debian/Ubuntu). What the doctor report says about the machine
overrides every written prerequisite.

## 4. Profile discovery — find, never configure

The tool reads existing desktop mail profiles; it never creates accounts.
Discovery order: `THUNDERBIRD_HOME` environment override, then the Flatpak
profile roots, then `~/.thunderbird`. If no profile is found on a machine
with a non-standard profile root, point `THUNDERBIRD_HOME` at it and re-run
`tb doctor`. `tb mail profiles` lists what it found; `tb mail folders` lists
folders per profile.

## No-profile-modification property

Normal operations write only to the tool's own cache (XDG state directory,
`~/.local/state/thunderbird-cli/` by default), temporary isolated
send-profile clones when a fallback send needs them, and an optional legacy
index file only when explicitly requested. Live mbox files, mail-client
SQLite files, and mail-client preferences are never rewritten during search
or read work. This property is what makes search/read safe against a
production profile.

## Source material

The upstream project's own `AGENTS.md`, `PLAYBOOK.md`, and README are
reference material for the other details cards — use their operator rules,
do not adopt them verbatim into the deck.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
