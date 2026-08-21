---
name: agent-run-ledger
description: The reporting convention every scheduled or recurring agent follows so that failures become visible instead of dying in a log nobody reads — write a start record before doing work, an end record with an honest outcome after, and never report success for anything you could not verify. Use when building or retrofitting any recurring agent, when a scheduled task failed and nobody noticed, or when setting up monitoring across a team's automations.
---

# Agent run ledger

## The failure this prevents

A scheduled agent runs, hits a broken connection partway, falls back to a less reliable path, half-completes, and reports nothing. The error is visible only inside the agent's own transcript, which nobody opens. Weeks later someone notices the work stopped happening.

The fix is not better error handling inside the agent — it's making every run leave evidence *outside* itself, in a place a monitor can check. That's the ledger.

**Rule zero: a run that produces no ledger record is a failed run.** Silence is never treated as success.

## The two-record pattern

Every agent writes **two** records per run:

1. **A start record, written before any real work begins.** This is the load-bearing part. If the agent crashes, hangs, or is killed, the start record survives with no matching end record — and that mismatch is exactly what tells a monitor "this thing died partway."
2. **An end record, written last**, carrying the honest outcome.

An agent that only writes on success cannot report its own failures. That's the whole problem.

## Record schema

```json
{
  "run_id": "short unique id, same on both records",
  "agent": "the skill or task name",
  "surface": "where it ran - cloud-task | local-task | chat | ci",
  "operator": "who or what account it ran as",
  "phase": "start | end",
  "timestamp": "ISO 8601 with offset",
  "outcome": "OK | PARTIAL | FAILED",
  "verified": true,
  "summary": "one line a human can read without context",
  "needs_attention": ["specific things a person must act on"],
  "notes": ["anything else worth keeping"]
}
```

`outcome` and `verified` are omitted on the start record and required on the end record.

## The outcome vocabulary — use it precisely

| Outcome | Means |
|---|---|
| `OK` | Completed everything it set out to do, **and verified it**. |
| `PARTIAL` | Ran, but something needs a human. Some items skipped, a fallback path was used, or something couldn't be confirmed. |
| `FAILED` | Did not complete. |

Plus one the monitor infers, never the agent:

| `MISSING` | No record at all where one was expected. Either it never fired, or it died before writing its start record. |

## `verified` is a separate question from `outcome`

This is the field that catches the most dangerous class of failure: **the agent believes it succeeded but never confirmed it.**

Set `verified: false` whenever the agent could not independently confirm its own work landed — it wrote through a fallback path, an interface didn't confirm, a re-read was skipped, or it's relying on "the click didn't error" as proof.

An action that was performed but not confirmed is `PARTIAL` with `verified: false`, **never `OK`**. If a step's whole point was changing something in an external system, "I clicked save and saw no error" is not verification. Re-reading the changed state is.

## Where records go

Pick the reachable destination for the surface the agent runs on:

- **Local scheduled tasks** — append to a file in a git repo that gets committed. The commit history becomes the audit trail for free.
- **Cloud scheduled tasks** — these run in isolated sandboxes with **no access to any local disk**, so a local file is not an option. Write to something reachable over the network that the agent already has a connector for: a shared spreadsheet, a project board, a dedicated chat channel.
- **Never** put a credential into an agent definition just to reach a ledger destination. If reaching it requires a stored secret, pick a different destination — one the agent can already reach through an authorized connector.

Consistency matters more than the choice: one ledger per team, every agent writing to it, or the monitor has blind spots.

## Retrofitting an existing agent

1. At the very top of the procedure, before anything else: write the start record.
2. At every early-exit path — including the "nothing to do today" path — write an end record. A quiet successful run still records `OK`. Otherwise quiet success and total failure look identical.
3. Wherever the agent currently decides something worked, ask whether it *verified* that. If not, set `verified: false` and downgrade to `PARTIAL`.
4. Wherever it currently skips something ambiguous, add the specific item to `needs_attention` rather than only mentioning it in prose.

## Writing honest summaries

The `summary` is what a person reads in a dashboard at a glance. Make it specific and make it true:

- Good: `"3 vendor rules added and re-verified; 1 skipped - could not confirm it saved"`
- Bad: `"Completed successfully"` when one item was skipped.

Never write a summary that would leave a reader surprised by what's in `needs_attention`.

## What this skill does not do

It defines the convention and the schema. It does not watch the ledger — that's a separate monitoring job, which reads these records, spots `MISSING` and `STALLED` runs, and escalates to a human.
