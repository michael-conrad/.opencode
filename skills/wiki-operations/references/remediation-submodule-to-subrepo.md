<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#169; sourced from .opencode#169 spec Rev 3 (developer direction, 2026-10-06 design discussion; git-rm semantics verified against git-rm docs) -->

# Remediation: wiki submodule → ignored sub-repo (detail card)

**Trigger rule: never run this opportunistically.** Execute only when the
developer directs and authorizes it for a **specific repo**. The default
arrangement for new provisioning is the ignored sub-repo
([provisioning.md](provisioning.md)); this card converts an inherited wiki
submodule to that arrangement.

## Procedure — in order

1. **Push local wiki work first.** Git's submodule up-to-date check does not
   cover unpushed commits — unpushed wiki commits silently vanish when the
   submodule worktree is removed. Commit and push any pending wiki state from
   inside the submodule checkout.
2. **`git submodule deinit <wiki-path>`** — removes the submodule's local
   configuration.
3. **`git rm <wiki-path>`** — removes the worktree, the gitlink in the index,
   and **stages the `.gitmodules` entry removal** (verified against git-rm
   docs).
4. **Remove the leftover admin directory** `.git/modules/<wiki-path>` — `git
   rm` does not delete it.
5. **Add the ignore line for the wiki path in the same parent commit.** The
   `.gitmodules` removal and the ignore entry ride together in one real parent
   change — submodule pointer discipline holds because the commit changes the
   parent repo for real, not a pointer alone.
6. **Fresh sub-repo clone** of `<derived>.wiki.git` at the fixed in-tree path —
   it is at the remote tip by definition, and the ignore entry from step 5
   already covers it.

## Verify (all four)

- `git status` in the parent repo is clean — no untracked or modified wiki path.
- `.gitmodules` contains no wiki entry.
- The path is confirmed ignored: `git check-ignore -v <wiki-path>` matches.
- The sub-repo checkout is at the remote tip (`git -C <wiki-path> status`
  shows an up-to-date tracking branch).
