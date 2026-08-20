# ThinkOps Claude Skills

Public, reusable [Claude Code](https://docs.claude.com/claude-code) skills, published as a plugin marketplace so anyone on the team (or anyone else) can install them with one command.

## Install

```
/plugin marketplace add blshultz/claude-skills
/plugin install thinkops-everything@thinkops-skills
```

## What's here

| Skill | What it does |
|---|---|
| [`backup-claude-data`](skills/backup-claude-data/SKILL.md) | Back up local Claude Cowork project files and scheduled-task definitions to a private GitHub repo, with a secrets review before every commit. |
| [`missive-rule-approval-workflow`](skills/missive-rule-approval-workflow/SKILL.md) | Template for a recurring inbox-scan → propose rule → human-approve → apply pattern for Missive auto-routing rules. Fill in the placeholders for your own org. |

This repo is public and intentionally generic — no client names, tokens, sheet IDs, or org-specific identifiers belong here. Client-specific variants of these skills live in a private repo instead.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` (kebab-case directory name matching the `name:` in frontmatter).
2. Add `./skills/<skill-name>` to the `thinkops-everything` bundle (and any other relevant bundle) in `.claude-plugin/marketplace.json`.
3. Before committing, re-read the skill file specifically looking for anything that identifies a real person, company, account ID, token, or internal URL — this repo is public.
4. Open a PR.
