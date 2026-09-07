# Missive REST API snapshot

This is the baseline the monthly maintenance check diffs against (see the
scheduled task "Missive API capability check"). It is **not** documentation
for humans to read casually — it exists so an automated check can tell
whether anything changed since last time. When the maintenance check finds a
real difference, it updates this file to match the new baseline alongside
any resulting change to `SKILL.md`'s capability matrix.

Last captured: 2026-09-07

## Endpoints documented at missiveapp.com/docs/developers/rest-api/endpoints.md

- POST /v1/analytics/reports
- GET /v1/analytics/reports/:id
- POST /v1/contacts
- PATCH /v1/contacts/:id1,:id2,:id3,...
- GET /v1/contacts
- GET /v1/contacts/:id
- GET /v1/contact_books
- GET /v1/contact_groups
- GET /v1/conversations
- GET /v1/conversations/:id
- PATCH /v1/conversations/:id
- GET /v1/conversations/:id/messages
- GET /v1/conversations/:id/comments
- GET /v1/conversations/:id/drafts
- GET /v1/conversations/:id/posts
- POST /v1/conversations/:id/merge
- POST /v1/drafts

(Note: this page's own listing omits several endpoints the working MCP server
actually calls successfully — /v1/organizations, /v1/teams, /v1/users,
/v1/shared_labels, /v1/posts, /v1/messages/:id — so this page is known to be
an incomplete index, not the full API surface. Treat a *new* entry appearing
here as signal; don't treat the continued absence of the above as signal.)

## Rules and comments — confirmed not part of the developer API (2026-09-07)

- Full sitemap under `/docs/developers/` (missiveapp.com/docs/sitemap.md):
  readme, rest-api, rest-api/rate-limits, rest-api/endpoints,
  ui-iframe-integrations (+javascript-api, no-code-and-ai), webhooks,
  custom-channels (+setup), contact. No rules or comment-creation page exists
  in this list.
- All "rule" URLs in the sitemap live under `/docs/advanced-features/rules/*`
  — product/UI documentation, not `/docs/developers/*`.
- Comment attachment objects include a `mentions` array (id/index/length) for
  reading, confirmed via `GET /v1/conversations/:id/comments`, but no POST
  endpoint for creating a comment is documented anywhere.

## What would count as a relevant change

The monthly check should flag (update the matrix + open a PR + notify) only
if one of these becomes true — not for unrelated doc edits (pricing, feature
announcements, wording):

1. A rules-related endpoint appears anywhere under `/docs/developers/`.
2. A POST (or similar write) endpoint for comments appears.
3. Any endpoint the MCP server actually calls (`organizations`, `teams`,
   `users`, `shared_labels`, `conversations`, `conversations/:id`,
   `conversations/:id/messages`, `conversations/:id/drafts`,
   `conversations/:id/posts`, `messages/:id`, `drafts`, `posts`) is removed,
   renamed, or gets new *required* parameters.
4. The attachment object's `url` field (used for downloads) is renamed,
   removed, or its signing/expiry behavior changes in a documented way.
5. The outgoing-message-rules-trigger-on-send behavior (see
   rest-api/endpoints.md's notes on `send: true`) changes in a way that
   would surprise `send_message` callers.

A doc page simply moving URL, or prose being reworded without a functional
change, is not a relevant change — don't fire on that alone.
