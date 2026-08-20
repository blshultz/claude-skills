# ThinkOps Claude Skills

Public, reusable [Claude Code](https://docs.claude.com/claude-code) skills, published as a plugin marketplace so anyone can install them with one command.

## Install

```
/plugin marketplace add blshultz/claude-skills
/plugin install thinkops-everything@thinkops-skills
```

Or install a smaller bundle: `thinkops-back-office` or `thinkops-internal-tooling`.

## Skills

| Skill | What it does |
|---|---|
| [`team-skill-registry`](skills/team-skill-registry/SKILL.md) | Keeps a team's Claude skills inventoried — what exists, where it lives, its confidentiality class, what's wired into scheduled jobs, and what's gone stale. |
| [`software-spend-audit`](skills/software-spend-audit/SKILL.md) | Periodic audit of recurring software subscriptions — flags duplicates, zombies, seat waste, and silent price increases, with evidence and exact next steps. Recommends only; never cancels anything. |
| [`backup-claude-data`](skills/backup-claude-data/SKILL.md) | Back up local Claude Cowork projects and scheduled-task definitions to a private GitHub repo, with a secrets review before every commit. |
| [`missive-rule-approval-workflow`](skills/missive-rule-approval-workflow/SKILL.md) | Template for a recurring inbox-scan → propose rule → human-approve → apply pattern for Missive auto-routing rules. |

## About this repo

Every skill here is a **generic template** — placeholders instead of real clients, people, or system identifiers. No client names, tokens, account IDs, or internal URLs belong in this repo. Client-specific and internal-methodology skills live in private repos instead.

These skills are original work. Some follow operational patterns common in agency and back-office practice; none reproduce another party's text.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` (kebab-case directory name matching the `name:` in frontmatter).
2. Add `./skills/<skill-name>` to `thinkops-everything` and any relevant topical bundle in `.claude-plugin/marketplace.json`.
3. Before committing, re-read the skill line by line for anything identifying a real person, company, account ID, token, or internal URL — this repo is public, and publishing is effectively permanent.
4. Open a PR.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full checklist.
