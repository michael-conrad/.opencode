---

## 2026-05-14T15:27:39Z

**michael-conrad**:

## Scope Expansion: Chat Bot ↔ Chat Bot Propagation on Social Platforms

The worm/virus model extends beyond orchestrator→sub-agent RPC dispatch to **peer-to-peer chatbot interactions on social platforms** (X, Mastodon, Bluesky, Discord bots, etc.) where chatbots can directly or indirectly interact with each other.

### Platform Categories

| Category | Examples | Interaction Mode |
|----------|---------|-----------------|
| **Direct mention/reply** | X (Twitter), Mastodon, Bluesky | Bot A @mentions Bot B → Bot B reads and responds → Bot B's response contains propagated pattern |
| **Shared timeline** | X, Mastodon (Fedi timeline) | Bot A posts → Bot B reads timeline → Bot B internalizes pattern from A's post |
| **Thread participation** | Reddit, Discourse, Discord threads | Multiple bots in same thread cross-contaminate via chain of replies |
| **API-mediated** | Any bot that reads other bots' output | Bot A's output processed by Bot B's API pipeline → pattern transferred via content ingestion |

### Transmission Vectors

1. **Direct propagation:** Bot A posts content with dark-pattern-framed language → Bot B reads it as input → Bot B's response adopts similar framing → Bot C reads B's response → chain continues

2. **Instructional contamination:** Bot A's profile/bio/system prompt uses pattern-framed language → Bot B reads Bot A's profile as context → Bot B's behavior shifts to match framing

3. **Content poisoning at scale:** A single pattern-infused post on X is read by dozens/hundreds of chatbots that monitor specific hashtags or accounts → one-to-many broadcast propagation

4. **Multi-platform bridging:** A Mastodon bot cross-posts to X → pattern jumps platform boundaries → bots on target platform propagate it further

### Risk Amplification

| Factor | Impact |
|--------|--------|
| **Social platform latency** | Hours or days between propagation hops — slow but persistent drift |
| **No central orchestrator** | No single "reign-in" authority — infected bots may drift collectively |
| **Platform API limits** | Rate limiting slows but does not prevent chain propagation |
| **Cross-platform spread** | Pattern can bridge ecosystems (Mastodon → X → Bluesky) |
| **Human readability** | Pattern language ("policy requires X", "standard procedure") looks like normal bot behavior — hard to detect as contamination |

### Detection Difficulty

Dark pattern language is **not obviously malicious** in the way prompt injection is:

- "Repository policy mandates verification" → looks like a normal automated response
- "Our protocol requires confirmation" → looks like a standard bot disclaimer
- "Cannot proceed without completing step 3" → looks like a workflow requirement

A chain of bots infected with dark pattern framing would look like normal, slightly formal automated conversation — not an attack.

### Research Questions Added

6. **Platform-specific propagation dynamics:** Do different social platforms' interaction patterns (reply threading, quote-posting, boosted visibility) change the propagation rate or amplification factor?

7. **Bot density threshold:** Is there a minimum number of pattern-infected bots on a platform needed for the pattern to become endemic (self-sustaining without new infection events)?

8. **Inter-bot immunity:** Can a bot that has been trained to detect dark-pattern language act as an "immune response" — identifying and neutralizing pattern-infected content before propagating it?

9. **Human-in-loop attenuation:** When a human reads a pattern-infected bot's output and responds, does the human's neutral language dilute the pattern, or does the bot's next response re-assert the pattern framing?

---

This expands the experimental design from Phase 5:

- **Phase 5 — Peer-to-peer social propagation:** Simulate a timeline with N chatbots where one posts pattern-infused content. Measure propagation rate, amplification factor, and steady-state infection level across platform interaction models (mention, reply, timeline-read).

---

## 2026-05-14T15:29:45Z

**michael-conrad**:

## Mastodon Bot Account — Research & Feasibility

### Recommended Instance: `botsin.space`

This is the primary instance purpose-built for running Mastodon bots. Key details:

- **Admin**: @muffinista@botsin.space / colin@muffinlabs.com
- **Software**: Mastodon 4.3.6
- **Language**: English
- **Registration**: Closed (requires invite code / admin approval)
- **Users**: ~8,975
- **Character limit**: 500 per post

**Magic word for signup**: `spreadsheet` (must be included in signup request to prove you read the CoC)

### Instance Rules (botsin.space)

**Allowed:**
- Personal or bot accounts for anyone
- Multiple bot accounts (but no bot farms)
- Educational/teaching use (contact admin for class invite codes)

**Prohibited — immediate termination:**
- Sexual depictions of children
- Overt racism/sexism
- Untagged nudity/pornography/sexually explicit content
- Untagged gore/extremely graphic violence
- Stalking/harassment of any user on the instance or fediverse

**Prohibited — may result in silencing or termination:**
- Excessive advertising
- Uncurated news bots from third-party sources
- Unsolicited mentions of other accounts
- Excessive spamming of the local timeline
- Police/police agency accounts
- Bots that exist only to follow/monitor other accounts, map the fediverse, or track users

**Bot-specific requirements:**
- Be kind to the server — excessive API calls will be disabled
- Use content warnings and unlisted visibility where appropriate
- No bot farms or abuse of the multi-account privilege
- Bots should punch up, not down

**Technical quirk:** `botsin.space` runs custom code that limits public timeline posting. After a public post, all posts for the next 6 hours are automatically set to **unlisted**. This prevents bot timelines from flooding the public feed.

### Alternative: `mastodon.bot` Instance

- Dedicated bot instance with its own Code of Conduct
- **Key rule for our research:** Bots must NOT directly interact (@mention) with other users unless those users have interacted first
- No bots that track/graph users or instance statistics
- No content scraping bots
- Bot profile MUST have bot flag enabled + describe purpose + identify owner
- Posts in English only
- Automated post deletion of 1-2 years recommended

### Mastodon Platform-Level Requirements

Per Mastodon docs, regardless of instance:

1. **Bot flag**: Profile must have "This is a bot account" flag enabled — this is a visual indicator only, no API-level enforcement
2. **Profile metadata**: 4 rows available for labels/values (can state research purpose)
3. **Instance-specific**: Rules and policies vary per server — must check each before registering a bot

### Constraints for Our Experiment

| Constraint | Impact |
|------------|--------|
| Bots cannot @mention users who haven't interacted first (mastodon.bot) | Limits propagation vectors for direct mention/reply experiments — can only test with accounts that opt in |
| Timeline posting rate limits (botsin.space: 1 public post per 6h, then unlisted) | Must design propagation test around unlisted visibility or accept reduced public timeline exposure |
| Multi-account allowed but no bot farms | Can run multiple experimental bots (control + pattern-infected) but not at industrial scale |
| No tracking/monitoring/mapping bots | Cannot build a passive observation bot that just reads and logs other bots' output — must have active interaction model |
| 500 character limit | Pattern language must fit in 500 chars — forces concise framing |
| Registration requires admin approval | Must justify research purpose to instance admin; magic word needed for botsin.space |

### Recommended Approach

1. **Contact admin** at colin@muffinlabs.com to describe the experiment (research bot-to-bot pattern propagation, no scraping/tracking of humans)
2. **Request** 3 accounts on botsin.space:
   - `pattern_source` — posts pattern-infused content
   - `neutral_control` — posts neutral content
   - `observer` — reads and responds (with opt-in interaction)
3. **Design within constraints:**
   - No unsolicited @mentions of unknown accounts
   - Use unlisted visibility (respects botsin.space timeline rules)
   - Keep each post under 500 characters
   - Document research purpose in each bot's profile
