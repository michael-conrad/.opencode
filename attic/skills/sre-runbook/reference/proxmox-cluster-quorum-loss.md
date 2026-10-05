---
name: proxmox-cluster-quorum-loss
description: Reference template for Proxmox cluster quorum loss runbook. Demonstrates prose-driven pattern with reasoning at every step. NOT a canonical project runbook.
type: reference
license: MIT
compatibility: opencode
---

# REFERENCE TEMPLATE — NOT A CANONICAL PROJECT RUNBOOK

> This file is a **reference template** demonstrating the prose-driven runbook pattern defined by the `sre-runbook` skill. It shows both prompt patterns (what a user would invoke) and output patterns (what the agent would generate). Adapt this template to your infrastructure — do not use it as-is without validating against your environment.

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

Why this matters: Quorum loss is the most dangerous Proxmox failure mode because it doesn't just break one node — it freezes the entire cluster's ability to make consensus decisions. Virtual machines may continue running, but no management operations (start, stop, migrate, snapshot) can occur. The cluster effectively becomes read-only at the management layer while VMs run in an isolated state.

The symptoms below are ordered by diagnostic priority — the symptoms that most strongly indicate quorum loss appear first.


### Quick-Reference: Symptom → Action Matrix

| Symptom | First Action | Why |
|---------|-------------|-----|
| "quorum?" error messages | `pvecm status` | Confirm quorum state before taking any other action |
| `pvecm` shows no quorum | Check which nodes are online | You need to know how many votes are available before deciding recovery path |
| Web UI "not available" | SSH to any remaining node | UI depends on quorum; SSH works locally without cluster consensus |
| VMs can't be managed | Verify VMs are still running locally | Don't assume VMs are down — check `qm list` on each node first |

### Detailed Procedural: Understanding Why Each Symptom Occurs

Proxmox uses a quorum-based consensus system built on Corosync. Every cluster state change — starting a VM, migrating storage, updating the cluster filesystem — requires a majority vote from configured nodes. When fewer than half the nodes are online, no majority exists, and the cluster enters a "frozen" state where:

1. **The cluster filesystem (pmxcfs) becomes read-only.** This is why the web UI shows errors — it can read cached configuration but cannot write any changes.

2. **HA manager stops fencing decisions.** Without quorum, the HA manager cannot safely determine which node should own a VM, so it suspends all fencing. This is actually protective — fencing without quorum could cause split-brain shutdowns.

3. **VMs continue running locally.** QEMU processes are independent of the cluster layer. A VM started on node A keeps running on node A regardless of cluster state. This is by design — a quorum failure should not automatically kill running workloads.

Understanding this architecture is critical because it determines your recovery strategy: you must restore quorum first, then address any VM state inconsistencies that occurred during the quorum loss period.

---

## Diagnosis Map

Why this matters: Quorum loss has three distinct root causes, each requiring a different recovery path. Misdiagnosis leads to wrong recovery actions — for example, trying to force quorum on a network-partitioned cluster makes the partition permanent.


### Quick-Reference: Diagnosis Decision Tree

```
Quorum lost?
├── pvecm status: Are nodes offline?
│   ├── YES → Node failure path
│   │   └── Majority offline? → Force quorum on survivor
│   └── NO → Network partition path
│       └── Can nodes ping each other?
│           ├── NO → Fix network first
│           └── PARTIAL → Isolate boundary, fix before cluster actions
│           └── YES → Corosync config path
│               └── Config looks wrong? → Fix and restart
│               └── Config looks correct? → ESCALATE
```

### Detailed Procedural: Diagnosis Reasoning

The key diagnostic principle for quorum loss is: **rule out network partitions before attempting any recovery action.** Forced quorum recovery on a network-partitioned cluster creates a permanent split-brain condition. Always verify network connectivity between all cluster nodes before deciding on a recovery path.

**Diagnostic sequence (why this order):**

1. **Run `pvecm status` first** — this tells you the objective quorum state (votes, online nodes, expected votes). All subsequent decisions depend on this information.

2. **Then check node reachability** — SSH or ping to each node shown as "offline" by pvecm. If you can reach an "offline" node, it's a network issue, not a node failure.

3. **Then check corosync logs** — these tell you the timeline and mechanism of quorum loss, which confirms the root cause category.

4. **Only then decide on recovery path** — with confirmed diagnosis, you can safely choose between forced quorum, network repair, or configuration fix.

---

## Mitigation Plan

Why this matters: Quorum recovery is destructive if done wrong. Force-quorum on the wrong node can corrupt cluster state. Recovery without verification can leave phantom quorum artifacts. Every mitigation step below includes rollback because the cost of a wrong step exceeds the cost of an extra verification.


### Quick-Reference: Mitigation Steps (Condensed)

| Step | Command | Risk | Rollback |
|------|---------|------|----------|
| Verify network | `ping <node-ip>` from each node | Low | N/A (diagnostic) |
| Force quorum (node failure only) | `pvecm expected 1` | **High** | `pvecm expected 3` |
| Fix network (partition only) | Network infrastructure repair | Medium | Revert changes after 5 min |
| Verify nodes offline | ICMP/SSH/iDRAC check | Low | N/A (diagnostic) |
| Restore expected votes | `pvecm expected 3` | Medium | `pvecm expected <online-count>` |
| Verify cluster sync | `pvecm update` on all nodes | Low | Escalate on failure |

### Detailed Procedural: Mitigation Reasoning

**Why force quorum is HIGH risk:** The `pvecm expected 1` command tells the cluster "trust this one node's decisions." If you run this on a node that's actually network-partitioned (not offline), you've just created a second cluster. Both clusters will try to manage the same VMs, storage, and network resources. This is split-brain — the single most destructive condition in clustered computing.

**Why expected votes restoration matters:** During force quorum, expected votes is 1. This means the cluster tolerates zero additional node failures. Restoring expected votes to 3 means the cluster regains its ability to survive one node failure — which is the whole point of having a 3-node cluster.

**Why cluster sync verification matters:** The cluster filesystem (pmxcfs) was in read-only mode during quorum loss. Any changes made on the quorum-holding node may not have propagated. After recovery, check that `/etc/pve/` content is consistent across all nodes. Divergence means state inconsistency that will cause future failures.

---

## Verification Criteria

Why this matters: Verification must confirm that quorum is restored AND that cluster state is consistent. Checking quorum alone is insufficient — a cluster can have quorum while still having divergent state between nodes.


### Quick-Reference: Verification Checklist

```
[ ] pvecm status shows quorum with expected votes = original count
[ ] All nodes show 'online' in pvecm status
[ ] /etc/pve/ content is identical across nodes (diff check)
[ ] VM start/stop/migrate operations succeed without errors
[ ] Corosync stable for 5 minutes (no membership changes in logs)
```

### Detailed Procedural: Verification Reasoning

**Why check /etc/pve/ consistency, not just quorum:** Quorum confirms consensus capability, but the cluster filesystem may have diverged during the outage. A cluster with quorum but divergent state will appear healthy until it tries to make a decision that conflicts with the divergent state — then it will fail in ways that are very hard to diagnose. Checking `/etc/pve/` consistency after recovery prevents this.

**Why verify VM management, not just corosync:** Corosync quorum is necessary but not sufficient for VM management. The cluster filesystem must also be writable (pmxcfs must have transitioned from read-only to read-write). Testing actual VM operations confirms the full management stack is functional.

**Why 5 minutes of stability:** Corosync membership changes indicate the cluster is still converging. If the cluster loses and regains quorum repeatedly (flapping), the underlying issue (network instability or node health problems) isn't resolved. Five minutes of stable membership is a reasonable confidence threshold.

---

## Postmortem Template


### Postmortem Narrative Template

```markdown
## Incident Timeline

| Time | Event | Reasoning |
|------|-------|-----------|
| <T+0> | First symptom detected | <What triggered detection — alert, user report, automated check?> |
| <T+?> | Diagnosis confirmed | <How was root cause identified? What evidence confirmed it?> |
| <T+?> | Mitigation started | <Which recovery path was chosen and why?> |
| <T+?> | Quorum restored | <How was quorum confirmed? What verification was run?> |
| <T+?> | Cluster fully verified | <What confirmed full recovery beyond quorum restoration?> |

## Root Cause Analysis

<Explain the causal chain from root cause to symptoms. NOT just "node X went down" — explain WHY that caused quorum loss (e.g., "Node X's failure removed 1 of 3 votes, dropping quorum below majority threshold of 2").>

## Contributing Factors

1. **<Factor>**: <Why this contributed to the incident or slowed resolution>
2. **<Factor>**: <Why this contributed>
3. **<Factor>**: <Why this contributed>

## Action Items

| Action | Owner | Priority | Reasoning |
|--------|-------|----------|-----------|
| <Action> | <Owner> | P1/P2/P3 | <Why this prevents recurrence or speeds recovery> |

## Lessons Learned

<What was surprising? What assumptions were wrong? What would we do differently?>
```

---

## Escalation Paths

Why different escalation paths matter: Quorum loss can be caused by different root causes, and each requires different expertise. Routing to the wrong team wastes time during an incident.


---

## AI Agent Enforcement — State Machine

This section defines the state machine that governs AI agent behavior when executing this runbook. Each state transition requires confirmation of the condition before proceeding.


### AI Agent Rules

