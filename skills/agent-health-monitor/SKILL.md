---
name: agent-health-monitor
description: The watchdog over a team's recurring agents — reads the run ledger, compares it against what was supposed to run, and escalates the specific things that are broken or silently stopped. Catches the failure a per-agent error handler cannot: the agent that never fired at all. Use to set up daily monitoring of scheduled tasks, to build an agent status report, or when automations have been failing without anyone noticing.
---

# Agent health monitor

## What this is for

Individual agents can report their own failures (see `agent-run-ledger`). What no agent can report is **its own absence** — a task that never fired, or died before it could say anything, produces exactly zero output, which is indistinguishable from a quiet successful run unless something is checking.

This is the something.

## Prerequisites

- A run ledger that agents write to (see `agent-run-ledger` for the schema and the two-record pattern).
- An **expectations registry**: what is supposed to run, how often, and who owns it. Without this, the monitor can only report on runs that happened — and the whole point is catching the ones that didn't.

## The expectations registry

One row per recurring agent:

| Field | Purpose |
|---|---|
| Agent name | Matches the `agent` field in ledger records exactly |
| Expected cadence | Daily, weekly on Tuesday, first business day, etc. |
| Grace period | How late is still acceptable before it's a problem |
| Owner | The human accountable for this agent working |
| Escalate to | Who gets told, and where, when it breaks |
| Severity | How bad is silent failure here — see below |

**Severity matters** because it determines how loudly to escalate. An agent that drafts an internal summary failing quietly for a week is an annoyance. An agent that routes client invoices failing quietly for a week is a business problem. Rank them honestly when the registry is created, not during an incident.

## Each monitoring run

### 1. Read the ledger for the window since the last check

### 2. Classify every expected agent

| Classification | How it's detected |
|---|---|
| **Healthy** | End record present, `outcome: OK`, `verified: true` |
| **Needs attention** | End record with `PARTIAL`, or `OK` with `verified: false` |
| **Failed** | End record with `FAILED` |
| **Stalled** | Start record with **no matching end record** past a reasonable runtime — it began and died |
| **Missing** | No record at all, past the grace period — it never fired |

**Stalled and Missing are the two that matter most**, because they're the two no agent can self-report. Everything else the agent already told you.

### 3. Also flag these quieter patterns

- **Chronic partial** — an agent that's been `PARTIAL` several runs in a row. Each individual run looked survivable; the trend says something is actually broken.
- **Unverified drift** — `verified: false` appearing more often over time, usually meaning a primary integration is degrading and a fallback path is quietly taking over.
- **Suspiciously fast** — a run that completed far quicker than usual often means it found nothing to do because an upstream connection returned empty, not because there was genuinely nothing.
- **Unregistered agent** — ledger records from something not in the registry. Either the registry is stale or something is running that nobody accounted for. Both are worth knowing.

### 4. Escalate — specifically

For anything not healthy, report:
- Which agent, and what its owner needs to know
- What state it's in, in plain language ("last ran Tuesday, expected daily")
- The specific `needs_attention` items from its record, verbatim
- How long it's been like this
- What breaks downstream if it stays broken

**Never send a bare "a task failed."** The person receiving it should be able to act without opening anything else.

### 5. Stay quiet when everything is fine

If every agent is healthy, write the status record and **send nothing**. A monitor that pings daily regardless gets muted within a fortnight, and then it's worse than no monitor — because everyone believes it's watching.

### 6. Don't re-alert the same thing endlessly

Track what's already been escalated. A problem that's known and open gets one alert, then appears in a periodic digest — not a fresh alarm every run. Escalate again only if severity increases or it stays unresolved past a threshold worth re-raising.

## Producing a status report

Beyond alerting, produce a periodic readable summary: each agent, its last run, current state, and anything open. Keep it somewhere durable and versioned — a repo works well, because the history then shows reliability trends over time rather than just this moment.

A useful report answers three questions in the first few lines: **What's broken right now? What's been quietly degrading? What needed a human and hasn't got one?**

## Honest limits

- **The monitor only sees what's in the ledger.** An agent that was never instrumented is invisible to it, and will be reported as `MISSING` forever or not at all depending on the registry. Instrument first.
- **Cloud-scheduled agents and local ones usually can't share a filesystem.** Either they write to a common network-reachable ledger, or the monitor reads from more than one place and merges. Decide which, explicitly — a monitor that silently covers only half the fleet is worse than none, because it produces false confidence.
- **A monitor cannot see another person's agent runs unless those runs write to a shared ledger.** There is generally no administrative back door that exposes one user's task history to another. Cross-team visibility is achieved by convention — everyone's agents write to the same ledger — not by privileged access. If someone's agents don't participate, say so plainly in the report rather than letting their absence read as health.
- **The monitor itself can fail.** Give it its own ledger record, and have something check *it* — even if that something is a human glancing at a dashboard weekly. A watchdog nobody watches is just another silent agent.
