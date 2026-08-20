---
name: team-skill-registry
description: Keeps a team's Claude skills inventoried and findable — what skills exist, where each one physically lives, whether it's public or client-confidential, which are wired into scheduled jobs, and what's gone stale. Use when adding a new skill, when someone asks "do we already have something for this" or "where do our skills live", when auditing what's installed against what should be, or before onboarding a teammate.
---

# Team skill registry

## The problem this solves

Skills accumulate in several places at once — a local project folder, a personal account, a shared repo, a scheduled task definition — and within a few months nobody can answer basic questions: Do we already have one for this? Which copy is current? Is that one safe to share outside the company? Which ones silently stopped running?

This skill is the periodic reconciliation that keeps those answerable.

## The registry record

Maintain one entry per skill with these fields. The middle three are the ones that actually prevent incidents:

| Field | Why it matters |
|---|---|
| Name | Must match the skill's directory name and its frontmatter `name` exactly |
| One-line purpose | So someone can scan for "do we have this already" |
| **Location** | The path or repo that is the *source of truth* for this skill |
| **Confidentiality** | `public` / `internal` / `client-confidential` — determines where it may ever be copied |
| **Wired into** | Any scheduled job, routine, or automation that invokes it — or `on-demand` |
| Owner | The human responsible for it being correct |
| Last reviewed | Date of last verification that it still works and is still accurate |

## Confidentiality — the rule that matters most

Every skill gets classified before it goes anywhere:

- **public** — contains no client names, no real people's contact details, no account/org/tenant identifiers, no internal URLs, no credentials. Safe for a public repo.
- **internal** — safe within the company, not outside. Describes how you work, but names no specific client.
- **client-confidential** — names a client, a specific person, or real system identifiers. Never leaves private storage. Never goes in a public repo, even briefly.

A skill may always move *toward* more restriction. Moving one the other way — publishing something previously internal — requires re-reading it line by line for the items in the `public` definition above, not a keyword grep. Publishing is effectively irreversible: assume anything that goes public is cached and indexed permanently, even if deleted minutes later.

When a client-confidential skill contains a genuinely reusable pattern, don't relax its classification — write a separate generic template with placeholders instead, and register that as its own `public` entry.

## Adding a new skill

1. Name it in kebab-case; directory name and frontmatter `name` must match.
2. Check the registry for an existing skill that already covers it — extend that one rather than creating a near-duplicate.
3. Classify confidentiality *before* deciding where the file lives.
4. Write the `description` frontmatter to say both what it does and when to use it, with the words someone would actually type when they need it. This is what determines whether the skill ever gets triggered — a vague description means the skill quietly never runs.
5. Add the registry entry.
6. If it's going into a shared distribution (a plugin marketplace, a workspace upload), register it there too, and note that in "wired into."

## Periodic reconciliation

Monthly or quarterly, walk the registry and check:

- **Does each skill still exist where the registry says it does?** Moved and forgotten is the most common drift.
- **Does anything invoke a skill that no longer exists?** A scheduled job pointing at a deleted skill fails quietly.
- **Do any skills exist that aren't in the registry?** Unregistered skills are how confidential content ends up somewhere it shouldn't.
- **Are the scheduled ones still actually running?** Verify against real run history, not the presence of a definition file. A task definition on disk is not proof the scheduler still has it registered — these can be cleared independently by platform changes.
- **Is anything stale?** A skill referencing a tool, process, or person that no longer exists is worse than no skill, because it will be followed confidently.

Record the reconciliation date and what changed.

## Onboarding a teammate

The registry is the answer to "what can Claude already do here" — filtered to what that person should see. Walk them through the `public` and `internal` entries; grant `client-confidential` access per engagement, not by default.
