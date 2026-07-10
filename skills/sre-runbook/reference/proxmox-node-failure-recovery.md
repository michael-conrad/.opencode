---
name: proxmox-node-failure-recovery
description: Reference template for Proxmox full node failure recovery. Demonstrates prose-driven pattern with different escalation paths from the quorum loss template. NOT a canonical project runbook.
type: reference
license: MIT
compatibility: opencode
---

# REFERENCE TEMPLATE — NOT A CANONICAL PROJECT RUNBOOK

> This file is a **reference template** demonstrating the prose-driven runbook pattern. It shows both prompt patterns (what a user would invoke) and output patterns (what the agent would generate). Adapt this template to your infrastructure — do not use it as-is without validating against your environment.

## Prompt Pattern (Invocation)

```
`skill({name: "sre-runbook"})` then `task(..., prompt: "execute generate task from sre-runbook")`
domain: Proxmox VE cluster
scenario_type: incident
severity: P1
```

Expected agent behavior: Generate a full runbook following the five-step protocol (symptoms → diagnosis → mitigation → verification → postmortem), with reasoning at every step.

---

## Symptom Catalog

Node failure is distinct from quorum loss: a single node is completely unreachable, but the rest of the cluster retains quorum and continues operating. The critical question is whether VMs on the failed node need immediate recovery or can wait for the node to return.


### Quick-Reference: Symptom → Action

| Symptom | First Action | Why |
|---------|-------------|-----|
| Node unreachable | Check iDRAC/IPMI | Hardware vs OS failure determines recovery path |
| Cluster retains quorum | Focus on VM recovery, not cluster | Remaining cluster is healthy — prioritize workload recovery |
| VMs show 'unknown' | Check if VMs are actually running | Don't assume VMs are down — verify via iDRAC console |
| HA fencing triggering | Verify HA manager progress | HA should auto-recover managed VMs; intervene only if fencing stalls |

---

## Diagnosis Map

The three root causes for node failure, eachrequiring a different recovery approach.


### Quick-Reference: Diagnosis Decision Tree

```
Node unreachable?
├── iDRAC/IPMI reachable?
│   ├── YES → Check hardware status
│   │   ├── Hardware error → Hardware failure path
│   │   ├── Powered off → Try remote power-on
│   │   └── Powered on, no OS → OS/kernel panic path
│   └── NO → Network failure (check switch port, cable)
└── Node online but VMs frozen?
    └── Check ZFS pool status
        ├── DEGRADED → Replace disk, scrub
        └── FAULTED → ESCALATE — data recovery needed
```

---

## Mitigation Plan


### Quick-Reference: Mitigation Steps

| Step | Action | Risk | Rollback |
|------|--------|------|----------|
| Assess via iDRAC | Check power/hardware state | Low | N/A |
| Evacuate VMs | Migrate to surviving nodes | Medium | Migrate back |
| Reboot node | iDRAC power cycle | Low | Hardware investigation |
| Replace hardware | Physical component swap | Medium | Escalate to vendor |
| Replace disk + resilver | zpool replace + scrub | Medium | Remove replacement disk |
| Verify cluster rejoin | pvecm status, sync check | Low | Remove and re-add node |

---

## Verification Criteria


---

## Postmortem Template


### Postmortem Narrative Template

```markdown
## Incident Timeline

| Time | Event | Reasoning |
|------|-------|-----------|
| <T+0> | Node failure detected | <How detected — monitoring, user report, HA alert?> |
| <T+?> | Diagnosis confirmed | <Hardware failure, OS panic, or storage failure?> |
| <T+?> | VM evacuation started | <Which VMs were prioritized and why?> |
| <T+?> | Node recovery attempted | <Reboot, hardware replacement, or disk replacement?> |
| <T+?> | Node rejoined cluster | <How was clean rejoin verified?> |

## Root Cause Analysis

<Explain the causal chain from root cause to symptoms. Why did the node fail? What made it worse?>

## Action Items

| Action | Owner | Priority | Reasoning |
|--------|-------|----------|-----------|
| <Action> | <Owner> | P1/P2/P3 | <Why this prevents recurrence> |
```

---

## Escalation Paths

Different from the quorum loss template — node failure escalates to hardware/vendor support and data recovery teams, not network engineering.


---

## AI Agent Enforcement — State Machine


### AI Agent Rules

