## Closure: Defective Premise

The initial analysis assumed deduplication was possible by extracting DISPATCH_GATE content to a shared location. This is architecturally unsound: skills are loaded independently via `skill()`. Extracted content would not be in context when the skill loads, causing context loss and behavioral defects. The repetition in SKILL.md files is a structural cost of independent skill loading — not a bug to be fixed.

Closing as not_planned. Best outcome: keep the current architecture, accept the ~2,500 chars of DISPATCH_GATE content per SKILL.md as the price of reliable agent behavior at skill-load time.
