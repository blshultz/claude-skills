---
name: missive-rule-approval-workflow
description: Template for a recurring "scan inbox → propose new auto-routing rules → get a named approver's yes/no in a tracking sheet → apply approved rules in Missive" workflow. Use as a starting point when a team wants Claude to maintain a Missive inbox rule (e.g. auto-labeling or auto-forwarding vendor/customer email) with a human approval gate, rather than editing rules unsupervised. Fill in the bracketed placeholders for your own org, inbox, sheet, and approver before use.
---

# Missive rule-approval workflow (template)

## Why this pattern exists

Auto-routing rules (label/forward-on-match) are powerful but risky to let an agent edit unsupervised — a bad match condition silently misroutes real business email. This template gives Claude a bounded, auditable loop: it may *propose* new rule conditions from observed inbox activity, but a named human must mark an explicit **YES** in a tracking sheet before anything goes live, and the agent may only ever touch **one** named rule.

This is a template, not a ready-to-run skill. Copy it, fill in the placeholders below, and delete this notice.

## Placeholders to fill in

| Placeholder | What it is |
|---|---|
| `{TEAM_INBOX_NAME}` | The Missive team inbox this rule watches (e.g. "Vendor Invoices") |
| `{MISSIVE_TEAM_ID}` / `{MISSIVE_ORG_ID}` | Found in Missive's URL/settings when viewing the team |
| `{RULE_NAME}` | The exact name of the single Missive rule this skill is allowed to edit |
| `{TRACKING_SHEET_NAME}` / `{SHEET_ID}` | The Google Sheet (or other tracker) that is the system of record for candidates and approvals |
| `{APPROVER_NAME}` / `{APPROVER_EMAIL}` | The one person whose YES/NO/EDIT authorizes changes |
| `{FORWARD_TARGET}` (optional) | Downstream address the rule forwards to, if any |

## System of record

Read `{TRACKING_SHEET_NAME}` (sheet ID `{SHEET_ID}`) first, every run. Recommended tabs:
- **Active** — rule blocks currently live in Missive
- **Pending Approval** — candidates awaiting `{APPROVER_NAME}`'s YES/NO/EDIT
- **Rejected** — permanent record of declined candidates (never re-propose these)
- **Log** — one row per action taken, used as the cursor for "what's new since last run"

## Run procedure

1. **Read the sheet first.** It is the dedup source — never propose a sender/pattern that's already Active, already Pending, or previously Rejected, unless the pattern has materially changed (then add a new row referencing the original as a change).

2. **Process `{APPROVER_NAME}`'s responses** in Pending Approval:
   - **YES** → add the block to `{RULE_NAME}` in Missive via browser automation (Settings → Rules → find `{RULE_NAME}`). Verify every condition value before saving; re-open the rule after saving to visually confirm it took. Then move the row to Active with today's date, and log it.
   - **EDIT** → revise the conditions per their notes, clear the approval cell, mark "revised — awaiting approval" with today's date. Do not touch the live Missive rule.
   - **NO** → move the row to Rejected with the rejection reason. Permanent — never re-propose.

3. **Scan for new candidates.** Look at inbox activity since the last Log entry, but score each candidate against its **full history**, not just this window — a monthly sender should count its whole track record, not just what happened to fall in the last few days. Prefer From + Subject conditions; fall back to body-content conditions when the sender/subject is too generic to match reliably (e.g. a shared notification address used by many different vendors).

4. **Update the sheet**, appending new candidates to Pending Approval and a Log row summarizing the run (include the scan-window end date as next run's cursor).

5. **Notify `{APPROVER_NAME}`** only when there's something new to review or report — new candidates, revisions, or completed approvals. Keep it short: what's new, a deep link to the Pending Approval tab, and the reminder that approval happens in the sheet (YES/NO/EDIT), not by replying to the email.

## Safety rules (do not relax these)

- Only ever edit the single rule named `{RULE_NAME}` — never create, delete, or disable any other rule, label, or email.
- Nothing goes live without an explicit YES recorded in the sheet (or, if you support email approval, a clearly unambiguous reply from `{APPROVER_EMAIL}` specifically).
- If a row or a match is ambiguous, don't guess — mark it "needs clarification" and say so in your summary.
- Finish every run with a concise summary: candidates found, approvals processed, blocks added, anything needing the human's attention.

## Adapting this template

The two skills this template was distilled from also included a periodic "verify attachments still carry the expected reference/code" audit step, and a mid-week lightweight approval-only pass (no new scanning) so approvals don't wait a full week to go live. Add either pattern back in if your use case needs it.
