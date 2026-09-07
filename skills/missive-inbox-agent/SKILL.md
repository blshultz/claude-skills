---
name: missive-inbox-agent
description: Routes Missive inbox-management work between the team's Missive MCP connector and Claude in Chrome browser automation. Use this whenever a task touches Missive — reading or triaging the shared inbox, replying to or sending email through Missive, labeling/assigning/closing conversations, reading attachments, editing a Missive Rule, or posting a comment/@mention on a conversation thread — including scheduled/recurring inbox-management tasks. Always consult this before falling back to browser automation for anything Missive-related; most Missive tasks are fully served by the MCP tools and should never touch the browser.
---

# Missive inbox agent: MCP first, browser only for real gaps

Missive exposes a real REST API, wrapped by the team's `missive-mcp` server.
Browser automation through Claude in Chrome is slower, more brittle (it breaks
when Missive changes its UI), and depends on a human already being logged into
Missive in that Chrome profile. The MCP tools have none of those problems. So
the rule is simple:

**Always try the Missive MCP tools first.** Only reach for Claude in Chrome for
the specific capabilities listed as "not available" in the table below — and
even then, only after confirming the MCP tool set genuinely doesn't cover it
(check the table; don't assume from memory, since this table is kept current).

## Capability matrix

_Last verified: 2026-09-07, against Missive's published developer docs
(missiveapp.com/docs/developers). A scheduled job re-checks this monthly
against `references/api-snapshot.md` and proposes an update (as a branch +
Slack notification, not a silent push to main) only when something in this
table would actually change — not on every wording tweak in Missive's docs._

| Capability | Access path | Notes |
|---|---|---|
| List / search conversations (inbox, assigned, closed, by label, by email/domain) | MCP: `list_conversations` | |
| Get one conversation's details (assignees, labels, team) | MCP: `get_conversation` | |
| Read a conversation's full history (messages + internal posts + comments, interleaved) | MCP: `get_conversation_timeline` | |
| Read a single message's full body | MCP: `get_message` | |
| Read/download an attachment | MCP: `get_message` or `get_conversation_timeline` | Attachment objects include a signed `download_url` — fetch it directly (e.g. to hand the bytes to a Drive tool). No separate download endpoint exists. |
| List drafts on a conversation | MCP: `list_drafts` | |
| Create a draft (new or reply) without sending | MCP: `create_draft`, `draft_reply` | |
| Send an email | MCP: `send_message` | Irreversible — confirm recipients/content before calling. Rate-limited (10/min, 100/hr) across the whole team. |
| Delete an unsent draft | MCP: `delete_draft` | |
| Label a conversation (add/remove shared labels) | MCP: `create_post` | |
| Assign a conversation to a user | MCP: `create_post` | |
| Close a conversation | MCP: `create_post` | |
| Move a conversation to a team | MCP: `create_post` | |
| Leave an internal note on a conversation | MCP: `create_post` | This is a "post," visible to the team — different from a "comment" (see below). |
| Look up organization / team / user / shared-label IDs | MCP: `list_organizations`, `list_teams`, `list_users`, `list_shared_labels` | Needed to get the IDs the tools above take as parameters. |
| **Create or edit a Missive Rule** (automation rule) | **Not available via API** — use Claude in Chrome | Missive's REST API has zero endpoints for rules. Rules are a UI-only feature. See "Fallback: Rules" below. |
| **Post a comment on a conversation, optionally @mentioning a teammate** | **Not available via API** — use Claude in Chrome | The API only supports listing comments (`GET .../comments`), never creating one. Comment creation exists only through Missive's in-app JavaScript iframe API, which runs embedded inside Missive's own UI — not reachable from an external server. See "Fallback: Comments" below. |

If a task needs a capability not in this table at all, don't guess — check
Missive's actual docs (missiveapp.com/docs/developers) before deciding it's a
browser task, since the MCP server may simply not have wrapped that endpoint
yet rather than the endpoint not existing.

## Fallback: Rules (Settings → Rules)

1. Confirm the user is already logged into Missive in the Chrome profile Claude
   in Chrome will use — this flow can't authenticate on its own.
2. Go to `https://mail.missiveapp.com/` (the web app). Missive's docs don't
   publish a direct URL for the Rules page, so navigate there through the UI:
   click the avatar in the bottom-left corner of the sidebar, then
   **Settings → Rules**. Choose personal or organization rules as the task
   requires.
3. Creating a new rule: set the trigger conditions, then the actions, and save.
4. Editing an existing rule: find it in the rules list, open it, make the
   change, save.
5. Report back exactly what rule/condition/action was created or changed —
   rules affect every future matching conversation, so be precise and don't
   improvise beyond what was asked.

## Fallback: posting a comment with a mention

1. Confirm the user is already logged into Missive in that Chrome profile.
2. Go to `https://mail.missiveapp.com/` and open the specific conversation —
   search or filter the inbox for it if you only have a subject/contact, or
   use the MCP `list_conversations`/`get_conversation` tools first to confirm
   which conversation you mean before switching to the browser.
3. Open the comment sidebar (the team-discussion panel, distinct from the main
   email thread).
4. Type the comment. To mention a teammate, type `@` followed by their name and
   pick them from the autocomplete list that Missive shows — don't type a raw
   `@name` without using the autocomplete, since that's what actually creates a
   trackable mention rather than plain text.
5. Submit the comment and confirm it posted before reporting done.

## Why MCP-first matters here specifically

Every capability in the top part of the table above is faster and more
reliable through the MCP tools than through the browser: no page-load waits,
no UI-selector breakage when Missive redesigns something, and structured
JSON back instead of a screen to parse. Reserve Claude in Chrome for exactly
the two gaps above — using it for anything the MCP tools already cover is
strictly worse, not just unnecessary.
