---
name: software-spend-audit
description: A periodic audit that inventories every recurring software subscription being paid for, then flags duplicates, unused seats, forgotten renewals, and tier downgrades — each with the evidence behind it and the exact next step to act on it. Use quarterly, when someone asks where software spend is going, during budget review, or when a renewal invoice arrives unexpectedly.
---

# Software spend audit

## What this produces

A ranked list of specific savings, each backed by evidence a skeptical person can check, and each ending in a concrete next step. Not a spreadsheet of everything — a short list of what to actually do.

The output is a recommendation, never an action: **this skill does not cancel, downgrade, or modify any subscription.** It hands a human the list.

## Placeholders

| Placeholder | What it is |
|---|---|
| `{ENTITY}` | Whose spend is being audited — your own company, or a client's |
| `{SOURCES}` | Where recurring charges are visible — accounting platform, card statements, bill pay history |
| `{OWNER}` | The human who decides what actually gets cancelled or changed |
| `{TRACKER}` | Where the audit record and prior findings live |

## Phase 1 — Build the inventory

Pull recurring charges from `{SOURCES}` across at least the last 12 months. Twelve months matters: annual renewals are exactly the charges people forget, and a 90-day window misses them entirely.

For each subscription capture: vendor, what it's for, billing frequency, amount per period, annualized cost, last charge date, next expected charge, and which internal owner (if any) it belongs to.

Where the accounting platform's vendor names are cryptic (payment processors and resellers often obscure the real product), resolve them to the actual product before analyzing. An unresolved line item is reported as unresolved — never guessed at.

## Phase 2 — Flag findings

Work through these categories, and attach evidence to every flag:

- **Duplicates** — two or more tools doing substantially the same job. Evidence: both vendors named, both costs, what overlaps.
- **Zombies** — still billing, apparently unused. Evidence: what indicates non-use (no owner, no recent activity, tied to a departed employee, no charges to any project). Be careful here — low usage is not no usage, and some tools are legitimately dormant until needed.
- **Seat waste** — paying for more seats than people using it. Evidence: seats billed vs. seats you can account for.
- **Tier mismatch** — on a plan whose distinguishing features aren't being used. Evidence: which tier, what the tier above/below costs, which features justify the gap.
- **Silent increases** — the per-period amount rose without a corresponding change. Evidence: the before and after amounts and the date it changed.
- **Upcoming renewals** — anything renewing within 60 days, especially annual ones. Evidence: last charge date and expected next.

## Phase 3 — Rank and hand off

Sort findings by annual dollars at stake, highest first. For each, give:
- The finding in one sentence
- The evidence
- Estimated annual savings
- **The exact next step** — the specific place `{OWNER}` goes to act, and what they'll need to decide
- Risk of acting: what breaks or who is disrupted if this is cancelled or downgraded

Then state the total identified savings — clearly labeled as *identified*, not *realized*. Nothing is saved until a human acts.

## Rules

- **Never cancel, downgrade, or modify anything.** Recommend only. Handing `{OWNER}` the list is the deliverable.
- **Never flag something as unused without saying what evidence supports that.** "I couldn't find usage" and "I confirmed it's unused" are different claims — use the accurate one.
- When auditing a client's spend, remember you're looking at their business decisions. Flag the finding neutrally with the evidence; don't editorialize about past choices.
- Log the audit in `{TRACKER}`, including findings `{OWNER}` explicitly declined — a declined finding shouldn't resurface as new next quarter. Note the reason it was declined.

## Cadence

Quarterly works for most. Move it earlier if a surprise renewal shows up, or if headcount changed meaningfully since the last audit.
