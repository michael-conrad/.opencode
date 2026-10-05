# [DEFECT] Remote-first issue-number reservation absent from spec/issues cards

**Repo**: michael-conrad/.opencode · **Remote**: .opencode#2494 (number authority) · **Discovered**: 2026-10-05

## Problem

The canonical `.issues/` workspace guide mandates remote-first issue-number reservation (every issue type when a remote tracker exists) and defines the mirror doctrine (local store primary — full spec + artifacts; remote = detailed exec summary with why + final what). But the doctrine exists in exactly one surface. The two deck cards the platform actually presents at issue-filing time are silent:

- `spec` card step 3: "Write and persist. `local-issues create` (or update); `spec.md` in the issue directory" — no numbering guidance.
- `issues` card step 2 (Creation): "Title states the work; body carries the spec/proposal with attribution byline" — no number-provenance guidance.

Live recurrence (2026-10-05): `opencode-config#373` was minted locally from the stale parent-store counter (373) while remote-synced issues had reached 2161. The filing agent read the parent store's drifted guide, which still taught counter-first reservation. The issue was deleted unfiled and refiled remote-first as `opencode-config#374`. Recorded precedent in the canonical guide: issue 2450's local-vs-remote number divergence.

## Success criteria

| SC | Requirement | Instrument |
|----|-------------|------------|
| SC-1 | `spec` card persist step states: remote issue filed first to reserve the number (when a remote tracker exists), local `{N}/` folder set up afterward and linked (`update --github`); remote body = detailed exec summary (why + final what); full spec and artifacts live locally; local counter reserves numbers only in remoteless stores | Read the card; grep for reservation + mirror language |
| SC-2 | `issues` card Creation step states the same reservation rule for every issue type; labels guidance unchanged | Read the card; grep |
| SC-3 | Card wording is root-agnostic: references "the store's remote tracker" via session-init platform facts and `gh`/`gb` — no platform or store-specific names | grep for hardcoded owner/repo/platform |
| SC-4 | Net-zero deck growth: the cards replace silent wording; no new sections, no size regression | skildeck lint 0 findings; byte-delta ≈ 0 |
| SC-5 | The store guides are consistent with the cards: canonical guide carries the all-types mandate (synced 2026-10-05, commit 6f9eeb24); parent store guide is a thin pointer (commit 71867cde) | Read both guides; check the doctrine exists in exactly one full copy |

SC-1..SC-4 are structural (fact-decidable). Verification is content-check at PR review plus skildeck lint.

## Approach

Edit the two card bodies on a submodule feature branch; admission-gate analysis in the commit; PR for human merge.

## Governance admission (skill-creator gate)

1. **Observed failure**: the 2026-10-05 recurrence (opencode-config#373) + recorded 2450 divergence.
2. **Consumer**: every agent filing any issue or writing a spec.
3. **Mechanism**: card wording — documentation enforcement (developer decision: documentation, not tool mechanism).
4. **Predicate classification**: number provenance is fact-decidable (verifiable against the tracker at review); chosen enforcement is intent-decidable (judgment + review backstop) — stated honestly.
5. **Domain match**: n/a (no imported protocol).
6. **Root-agnostic**: store-agnostic wording; per-root facts via session-init.
7. **What it replaces**: the silent/counter-first flow wording — net-zero.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
