# Lesson catalog — session 2026-11-16

## Lesson: remote-surface notices carry the URL, first

**Classification:** systemic

**What happened:** The session filed michael-conrad/.opencode#2745 (pull request) and reported it in chat as "PR filed: michael-conrad/.opencode#2745" — a qualified reference, no URL. The developer read "no URL" as "there is no PR" and concluded the artifact was being hidden ("there is no fucking URL so there is no PR"). The PR existed; the notification form made it undiscoverable. The same defect recurred across the completion notice and the follow-up acknowledgment before the developer surfaced it.

**Root cause:** The chat completion report defaulted to issue-reference form (`owner/repo#N`) for a newly created remote surface. A reference that only resolves after navigation is not a notice for the party being notified — the resolvable URL is the notice.

**Remediation — applied in this session:** Every chat notice of a created or updated remote artifact (PR, issue, release, comment) leads with its full resolvable URL, before the qualified reference. This is agent reporting behavior; no deck file governs it yet — if the deck warrants a rule, it belongs to the correspondence card's channel form and goes through governance with the developer's direction.

**Remediation target:** agent chat notice form (this session onward); no file changed.

consumed: 2026-11-16 (behavior applied in-session; deck-level rule deferred to developer direction)
