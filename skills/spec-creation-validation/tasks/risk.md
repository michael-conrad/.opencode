# Task: risk

## Purpose

Analyze risk, blast radius, failure propagation, and operational requirements (logging, metrics, alerts, deployment).

## Entry Criteria

- Requirements extraction completed
- (Recommended) Decomposition completed for interface-level risk analysis

## Exit Criteria

- Risk assessment with severity and probability
- Blast radius analysis for high-risk components
- Operational requirements documented
- Mitigation strategies identified

## Procedure

### Step 1: Risk Assessment

For each component/change, assess:
- What risks exist (technical, integration, data, security)
- Severity of each risk (low/medium/high/critical)
- Probability of each risk occurring
- Mitigation strategy for each risk

### Step 2: Blast Radius Analysis

For high-risk components (severity HIGH or CRITICAL):
- If this component fails, what breaks?
- How far does the failure propagate?
- What is the rollback strategy?

### Step 3: Failure Propagation Map

Identify cascading failures:
- Component A fails → Components B, C affected
- Component B fails → Components D, E affected
- Where are the circuit breakers?

### Step 4: Operational Requirements

Document operational needs:
- **Logging:** What to log, at what level, structured or unstructured
- **Metrics:** What to measure, aggregation strategy
- **Alerts:** When to alert, threshold configuration
- **Deployment:** Rollout strategy, blue/green, canary, feature flags
- **Data migration:** Schema changes, data transformation, rollback

## Content Coverage

Does the risk assessment cover:
- Severity and probability for each risk?
- Blast radius for high-risk components (what breaks, how far it spreads, rollback strategy)?
- Failure propagation paths?
- Operational requirements (logging, metrics, alerts, deployment)?

**Any format that communicates these concerns effectively is acceptable.** Formal risk tables with severity/probability matrices work well for complex specs. Prose descriptions work well for simple specs with few risks. The agent chooses the format that best serves the spec.

## Concurrency / Race Condition Analysis (MANDATORY for concurrent specs)

When the spec involves concurrent access, shared state, or asynchronous operations, perform a structured race condition analysis:

### Step 5a: Identify Shared Mutable State

- List every data structure, file, database row, or cache entry that multiple threads/processes/nodes access concurrently
- For each shared resource, document: access pattern (read/write/read-modify-write), locking strategy (if any), and whether the spec defines ordering guarantees

### Step 5b: Race Condition Threat Modeling

For each shared resource, assess:

| Race Type | Condition | Example | Mitigation |
|---|---|---|---|
| Read-modify-write (TOC/TOU) | Two readers see the same value, both modify, one write is lost | Counter increment without atomic operation | Atomic compare-and-swap, optimistic locking, or mutex |
| Check-then-act | State checked as valid, then acted upon, but state changed between check and act | "If file not exists, create" without exclusive create | Exclusive create flag, advisory lock, or transaction |
| Write-write conflict | Two writers overwrite each other's data | Concurrent config file writes | Write lease, version vector, or append-only log |
| Read-write inconsistency | One thread reads while another writes partially | Reading a half-updated struct | Immutable snapshots, RCU, or copy-on-write |
| Ordering violation | Operations must happen in a specific order but no ordering guarantee exists | Event A must fire before event B but both are async | Explicit happens-before barrier, channel, or sequencer |

### Step 5c: Document Concurrency Guarantees

- What ordering guarantees does the spec provide? (total order, partial order, none)
- What consistency model applies? (strong, eventual, causal, read-your-writes)
- What is the failure mode under contention? (graceful degradation, error, crash)

## Backward Compatibility Impact Analysis (MANDATORY)

When the spec changes an existing interface, data format, or behavior, assess what existing consumers would break:

### Step 6a: Identify Changed Interfaces

- API signatures (function names, parameter types, return types, error types)
- Data formats (message schemas, file formats, wire protocols, serialization)
- Configuration keys (env vars, config file fields, CLI flags)
- Behavioral contracts (ordering guarantees, latency promises, error semantics)

### Step 6b: Consumer Impact Assessment

For each changed interface, identify:

| Consumer Type | How to Find | Breakage Mode | Severity |
|---|---|---|---|
| Direct callers in same repo | `srclight_get_callers` on the changed function | Compile error, runtime type error, behavioral change | critical / high / medium / low |
| Indirect callers (via interface) | `srclight_get_implementors` on the changed interface | Same as above | critical / high / medium / low |
| External consumers (API clients) | API docs, changelog, deprecation notices | HTTP error, deserialization failure, behavioral change | critical / high / medium / low |
| Config file consumers | `grep` for the changed config key across the codebase | Startup failure, silent misconfiguration | critical / high / medium / low |
| Data format consumers | `srclight_search_symbols` for deserialization of the changed format | Parse error, data loss, silent corruption | critical / high / medium / low |

### Step 6c: Migration Strategy

For each breakage mode with severity HIGH or CRITICAL, document:

- Deprecation period (if applicable): how long the old interface is supported
- Migration path: what consumers must do to adapt
- Coexistence strategy: can old and new interfaces exist simultaneously? (versioned endpoints, feature flags, adapter layer)
- Rollback plan: how to revert if migration causes production issues

## Security Threat Modeling (MANDATORY for security-relevant specs)

When the spec involves authentication, authorization, data at rest, data in transit, user input, or external system integration, perform structured security analysis:

### Step 7a: Attack Surface Analysis

Identify every entry point where external input enters the system:

| Attack Surface | Entry Point | Input Type | Trust Level | Threat |
|---|---|---|---|---|
| API endpoint | `POST /api/v1/users` | JSON body | Untrusted (external) | Injection, deserialization, excessive payload |
| File upload | `POST /api/v1/documents` | Multipart form | Untrusted (external) | Path traversal, malware, zip bomb |
| Webhook receiver | `POST /webhooks/github` | JSON with HMAC | Semi-trusted (signed) | Replay, spoofing, payload injection |
| Config file read | Startup config load | YAML/TOML | Trusted (local) | No threat (local only) |
| Inter-process communication | Unix socket | Protobuf | Trusted (same host) | Socket hijacking (if permissions wrong) |

For each untrusted or semi-trusted entry point, document:
- Input validation requirements (schema validation, allowlist, sanitization)
- Authentication requirements (API key, JWT, mTLS, HMAC)
- Rate limiting / throttling requirements
- Audit logging requirements

### Step 7b: Trust Boundary Mapping

Map the trust boundaries in the system architecture:

```
[External Client] --untrusted--> [API Gateway] --semi-trusted--> [Application Server] --trusted--> [Database]
                                    |                                  |
                                    v                                  v
                              [Auth Service]                     [Cache Layer]
                              (semi-trusted)                      (trusted)
```

For each trust boundary crossing, document:
- What authentication/authorization is enforced at the boundary
- What data validation is performed before crossing
- What encryption is required (TLS, application-level encryption)
- What audit events are generated at the boundary

### Step 7c: Threat Enumeration (STRIDE per Component)

For each component, enumerate threats using STRIDE:

| Threat | What It Targets | Example | Mitigation |
|---|---|---|---|
| Spoofing | Identity | Attacker impersonates a valid user | Authentication (JWT, API key, mTLS) |
| Tampering | Data integrity | Attacker modifies a request in transit | TLS, HMAC signing, checksums |
| Repudiation | Audit | Attacker performs an action with no log | Audit logging, non-repudiation |
| Information Disclosure | Confidentiality | Attacker reads sensitive data from response | Encryption, least-privilege, field-level access control |
| Denial of Service | Availability | Attacker floods an endpoint with requests | Rate limiting, resource quotas, circuit breakers |
| Elevation of Privilege | Authorization | Attacker escalates from user to admin | Role-based access control, principle of least privilege |

## Context Required

- Preceded by: `requirements`, optionally `decompose`
- Feeds into: `write`
- Note: Creation-time operational requirements are enforced here. `spec-auditor` verifies completeness as a second pass.

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/risk-assessment.yaml" |
| blocker_reason | "..." |