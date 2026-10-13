## Summary

During the 2026-10-13 release-gate incident (spec #2590, PR #2591), the agent created a release branch and release PR inside the submodule repo and ran the clean-room gate by cloning the submodule directly — twice: once bare at an arbitrary root, once with a path-named fake parent. Root cause is wording, not judgment: the PR and release cards model a single-repo world. The correct principle already exists in the deck — the implementation-workflow reference's Submodule execution boundary — but it lives only on the implement side and loses the intent match at PR/release dispatch.

### Defects (per card, live text)

1. **release-promoter** (SKILL.md + references/operating-protocol.md): the gate's clone step says "the SAME parent URL the root project repo itself is cloned from" — for a repo that is itself a submodule, this is ambiguous between the submodule's own origin and its parent's URL. The card never states that the initial clone is of the parent repository, that `git submodule update --init --depth 1` resolves the candidate through the parent's recorded pointers, that sibling submodules ride along, or that build/test runs through the parent's build framework in the composed layout.
2. **git-workflow-pr**: states the pointer ride-along invariant but never the exclusive rule that release PRs exist only at the parent repo.
3. **changelog-generator / version-manager**: repo-local framing ("since the last release tag", "scan for version patterns") with no parent-release placement rule — the changelog card is what directed release work into the submodule.

The origin ambiguity is inherited from spec #2590 §2 ("the identical remote URL the project itself is cloned from").

## Mandated fix

Duplicate the Submodule execution boundary in adjusted form:

- **Release PRs are parent-repo artifacts only.** A submodule repository never hosts its own release PR, changelog release section, version bump, or tag; its content ships via the parent's pointer capture.
- **The clean-room gate's initial clone is of the parent repository** — its remote URL, shallow, `--branch <branch>` on the parent's release branch — and submodule resolution (`git submodule update --init --depth 1`, never `--remote`/`--recursive`) populates the candidate and its siblings through the parent's recorded pointers in the composed consumption layout. Build/test executes through the parent's build framework inside that layout.
- **Referent discipline:** wherever the current text says "the parent URL the repo is cloned from" or "a checkout of the release commit/branch", the wording names the parent repository and its relationship explicitly (referent-binding class; recorded in the writing-discipline review as the candidate fifth ambiguity family).

### Placement

git-workflow-pr; release-promoter SKILL.md + references/operating-protocol.md (Phase A rewrite); changelog-generator; version-manager; guidelines/ainglish-writing-discipline.md. Whole-card-on-touch applies to each touched artifact.

### Scope addition — Ainglish writing-discipline updates (2026-10-13, developer directive)

- **R1 — fifth ambiguity family:** add *referent binding through possessive/relational compounds* to the writing-discipline guideline, with the #2590-flow "parent URL" misbind as the recorded failure. Family rule: name the referent directly and completely — state the topology (which repositories exist, which contains which, which hosts releases) before using relational nouns, and never leave a compound like "parent URL" to resolve the relationship by inference.
- **R2 — cover-claim anchor:** the guideline's "These families cover the deck's recorded misbinding classes" is an unhedged evergreen claim that the #2592 class falsifies until amended; anchor it with an as-of date (the guideline's own family-4 discipline applied to itself).
- **R3 — adoption trigger:** the whole-card-on-touch adoption rule explicitly names specification creation and revision as conversion triggers — the #2590 ambiguity was authored in the spec and survived five revisions unconverted because the trigger read card-local.
- **R4 (out of deck scope):** the register-side observation — no ratified form covers referent binding in unmarked prose — is recorded as an upstream ainglish.org proposal candidate only; the deck cites the register, never mirrors it.

## Evidence

- Session record 2026-10-13: two gate invocations cloning the submodule directly; one submodule-level release branch (`release/v0.3.0`, parked) and changelog commit; developer rulings: "you can't build and test submodules without their potential siblings and the parent's build framework"; "release PRs are only for the parent repo".
- Deck-debt ledger entry recorded on #2534 (governance decision, admission gate: first-hand observed failure, existing consumers, intent-decidable predicate, root-agnostic, replaces the repo-local wording).
