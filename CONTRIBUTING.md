# Contributing

## Before you publish a skill here — this repo is public

Never commit:
- Real client/company names, or anything that identifies a specific person by name or email.
- API keys, tokens, session IDs, spreadsheet IDs, org/team/workspace UUIDs, internal URLs.
- Business logic that only makes sense for one client's process — generalize it into placeholders instead (see `skills/missive-rule-approval-workflow/SKILL.md` for the pattern: a "Placeholders to fill in" table at the top, `{LIKE_THIS}` markers in the body).

If a skill is genuinely client-specific and not meant to be generalized, it does not belong in this repo — keep it in the private backup repo instead.

## Naming

- Directory name = `name:` field in the SKILL.md frontmatter, kebab-case, stable once published (never silently rename — treat a rename as a deprecation + new skill).
- `description:` frontmatter should say what the skill does and when to use it in one or two sentences — this is what Claude uses to decide when the skill is relevant, so be concrete about trigger phrases/situations.

## Adding a skill

1. `skills/<skill-name>/SKILL.md`, plus a `scripts/` or `references/` subfolder if needed.
2. Register it in `.claude-plugin/marketplace.json` under `thinkops-everything`.
3. Read the skill file once more specifically hunting for anything in the "never commit" list above.
4. Open a PR describing what the skill does and confirming the redaction check was done.
