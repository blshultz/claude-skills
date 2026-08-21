---
name: backup-cowork-data
description: Back up local Claude Cowork project files and scheduled-task definitions to a private GitHub repo, reviewing every new or changed file for accidentally-embedded secrets before committing anything. Use this whenever the user asks to "back up" their Claude or Cowork data, mentions losing scheduled tasks or projects (e.g. after a plan upgrade wiped them), asks to push Cowork projects to GitHub, wants a recurring/automated backup of their local Claude working folder, or is setting this up fresh on a new machine or for a teammate.
---

# Backing up local Claude/Cowork data

## Why this exists

Cowork project files and scheduled-task definitions live only on the local disk — there is no automatic cloud sync for them. They can be lost to a wiped drive, a bad edit, or (confirmed firsthand) a plan upgrade silently clearing the live scheduled-task registry. This skill makes a reviewed, on-demand backup to a private GitHub repo so that loss is recoverable.

## Before running

You need:
- Git installed and already able to push to GitHub (Git Credential Manager or an SSH key configured — if `git push` prompts for a password unexpectedly, that's a sign auth isn't set up; help the user resolve it rather than guessing at credentials).
- A private GitHub repo already created for this purpose. If the user doesn't have one, walk them through creating one (github.com → New repository → set Private) before continuing.
- The local "Claude working folder" — the directory holding `Projects/` (Cowork project data) and `Scheduled/` (scheduled-task `SKILL.md` definitions). This is commonly `~/Claude` (`$HOME/Claude` on macOS/Linux, `C:\Users\<name>\Claude` on Windows), but don't assume — if it's not obvious, ask the user or look for a folder matching that shape.

## Steps

1. **Locate the working folder.** Confirm with the user if there's any ambiguity — better to ask than to back up the wrong directory.

2. **Ensure it's a git repo connected to the right remote.** If there's no `.git` folder, run `git init`, ask for the GitHub repo URL, `git remote add origin <url>`, then `git fetch origin` and reconcile any existing commits on the remote (e.g. an auto-generated README) before adding local content — don't just force-push over it.

3. **Maintain `.gitignore`.** It should exclude:
   - Any subfolder under `Projects/` that already has its own independent `.git` — check for this explicitly (`find Projects -maxdepth 2 -name .git`). Don't nest an existing project's repo inside this backup repo; that creates a mess, not a backup. If you find one, exclude it and tell the user it already has its own history elsewhere.
   - Build artifacts and dependency folders: `node_modules/`, `.next/`, and anything else that's clearly regenerable rather than authored content.
   - OS junk: `Thumbs.db`, `.DS_Store`.

4. **Stage, then review before committing anything.** Run `git add -A`, then look at `git diff --cached --name-only` — every file in that list needs a secrets check before it's allowed to survive into a commit:
   - **By filename**: does it match `token`, `secret`, `credential`, end in `.pem`, start with `id_rsa`, or is it an `.env`/`.env.*` file?
   - **By content** (skip binary files like `.docx`/`.xlsx`/`.pdf`/images — there's nothing to usefully grep there): does it contain something *shaped* like a real credential — an assignment like `key`/`token`/`secret`/`password` followed by a 12+ character value, a known provider prefix (`AKIA…`, `ghp_…`, `sk-ant-…`, or similar), or a private key header (`-----BEGIN … PRIVATE KEY-----`)?
   - The critical distinction: match the *shape* of a secret, not the bare word. A setup guide that mentions "paste your API token here" is legitimate documentation and must not be blocked just because it contains the word "token" — only flag things that look like an actual live value. (A keyword-only check will also flag itself, and any doc about credentials, as false positives — tested and confirmed this exact failure mode, so don't skip the shape requirement.)
   - Anything that matches: unstage it with `git restore --staged <file>`, and say so explicitly — name the file and why. Never silently commit a possible secret, and never silently drop it without telling the user (they need to know it exists and needs handling, e.g. rotating a token that's been sitting in plaintext).

5. **If nothing is left staged after the review, stop there and say so.** No empty commits.

6. **Commit what remains** with a short, clear message, then push to the remote's default branch.

7. **Report a summary**: what got backed up (files/count), what got skipped and why, whether the push succeeded. Remind the user of the two things this does *not* cover (below) if it's the first time running this for them.

## What this does not do

- **Does not restore or re-register live scheduled tasks.** The `Scheduled/*/SKILL.md` files on disk are just the task *definitions* — Anthropic's cloud scheduler that actually fires them is a separate system, and it can be (and has been) wiped independently, e.g. during a plan upgrade. Backing up the files preserves the content needed to recreate a task; it does not keep the task itself alive or automatically re-register it.
- **Never backs up account/credential state.** A Claude Code config file that holds OAuth session tokens or MCP server credentials is machine identity, not project data, and should never end up in a repo — even a private one.

## Setting up a recurring/automatic backup

This skill itself runs on demand — someone has to ask for it. For hands-off scheduling, that has to be *local* OS-level scheduling, not Anthropic's cloud-based routine/cron feature: cloud agents run in isolated cloud sandboxes with no access to a local disk, so they cannot see these files at all.

- **Windows**: a Task Scheduler entry running a script. `scripts/backup-claude.ps1` in this skill folder is a tested reference implementation (verified to catch a planted fake secret and to no-op cleanly when there's nothing new).
- **macOS/Linux**: the equivalent is a `cron` entry or `launchd` job invoking a shell script with the same logic, or `claude -p` pointed at this skill with pre-approved permissions for the exact git/read commands it needs (avoid a blanket permission bypass for an unattended job).

Ask the user their platform and desired interval, then set it up — don't assume Windows/PowerShell by default.

## How to invoke

Just ask in plain language: "back up my Claude Cowork projects and scheduled tasks" or "run my Claude backup now."
