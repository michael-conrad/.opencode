# Canonical Skill Description Pattern

## Structure

Every skill description follows a 3-part structure:

### Part 1: Role Statement (1 sentence)

A single sentence identifying the skill's role. Pattern:

```
[Role] that [purpose].
```

Examples:
- "Authorization gatekeeper that verifies scope, cascade, and halt boundaries."
- "Adversarial auditor that verifies specs, plans, code, and generated content against standards."
- "Git conflict resolver that analyzes intent, classifies tiers, and applies resolution strategies."

### Part 2: Dispatch Conditions (1-3 sentences)

Agent-intent dispatch triggers. Pattern:

```
Dispatch when [CONDITION]. Also dispatch when [CONDITION_2]. Also dispatch when [CONDITION_3].
```

- Each condition is an agent-intent trigger (what the agent determines or observes)
- Conditions are ordered from most common to least common
- Use "Also dispatch when" for secondary conditions
- Use "MUST dispatch here" or "Dispatch is MANDATORY" for non-optional gates

### Part 3: Distinction Notes (optional, 1 sentence)

For skills that overlap with other skills, a disambiguation note. Pattern:

```
— distinct from [OTHER_SKILL] ([what it does]).
```

## Canonical Template

```
[ROLE_STATEMENT]. Dispatch when [AGENT_INTENT_TRIGGER]. Also dispatch when [AGENT_INTENT_TRIGGER_2]. [MANDATORY_FLAG]. [DISTINCTION_NOTE].
```

## Key Rules

1. **No user-phrase lists.** All triggers are agent-intent conditions, not user utterance patterns.
2. **Dispatch-first.** Every condition starts with "Dispatch when" or "Also dispatch when".
3. **Mandatory flag.** Skills that are non-optional use "Dispatch is MANDATORY" or "— not optional" or "— always required".
4. **Distinction via em-dash.** Overlapping skills use "— distinct from" with a parenthetical.
5. **Single role sentence.** One sentence establishes identity before any dispatch conditions.
