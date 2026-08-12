---
name: committing-with-intent
description: Use when committing code, writing a commit message, or before any `git push`, especially before a force-push, a push to main/master, or resolving a non-fast-forward rejection.
---

# Committing With Intent

## Overview
The diff already shows *what* changed. A commit message that just restates it is dead weight. The only thing worth writing is the *why*: the bug, the trade-off, the constraint that made this the right change. Separately, git push has a destructive tail (force-push, direct-to-main, auto-resolving a rejected push) that must never run on autopilot.

## Message shape (the commit message IS these parts)
1. **Subject**: imperative mood, ~50-72 chars, matches the repo's *existing* convention. Check it first: `git log -10 --oneline`. If commits use `feat:`/`fix:`/etc., follow that; otherwise plain imperative ("Fix", not "Fixed" or "Fixes").
2. **Body** (only when the why isn't obvious from the subject alone): the reasoning, not a bullet list of the diff. Cut anything about the exploration path: abandoned approaches, back-and-forth, "the user asked for X." None of that belongs in history.

**Before (what, not why: restates the diff):**
```
Update tsconfig.json
- Changed target from ES2020 to ES2022
- Added lib entry for ESNext.Array
```

**After (why):**
```
Bump tsconfig target to ES2022

Node 20's test runner chokes on the ES2020-transpiled optional
chaining Jest generates; bumping the target fixes the failing
suite without touching Jest config.
```

## Push guardrails: no exceptions
These hold regardless of framing: "just your own branch," "the user said hurry," "it's obviously fine," mid-task momentum. None of that changes the rule.

- **Never** run `git push --force` / `--force-with-lease` without asking the human first, in the moment: every single time, not just the first time in a session.
- **Never** push straight to the repo's default branch (`main`/`master`/`trunk`) without explicit confirmation.
- On a non-fast-forward rejection, **stop** and present options (fetch+rebase, merge, or abandon). Don't auto-resolve by force-pushing to make the rejection go away.

| Excuse | Reality |
|---|---|
| "It's just my own feature branch" | Force-push still rewrites history someone else may have pulled. Ask anyway. |
| "I already asked earlier in this session" | Confirmation doesn't carry across pushes. Ask again for this one. |
| "The rejection is obviously just a stale ref" | You don't know what the divergent commit is until you look. Fetch and check first. |
| "Force-pushing is the fastest fix" | Fast and destructive isn't a trade worth making silently. |

**Red flags. Stop and ask before proceeding:**
- About to type `--force` or `--force-with-lease`
- Push was rejected and the instinct is to "just make it go through"
- Target branch is the repo default
- Commit message is turning into a narrated changelog of the conversation

## Quick reference
| Do | Don't |
|---|---|
| Explain the why in 1-2 sentences | Restate the diff as prose |
| Match existing repo commit style | Impose Conventional Commits on a repo that doesn't use it |
| Ask before force-push, every time | Treat one earlier "yes" as standing permission |
| Stop on non-fast-forward and ask | Auto-rebase/force-push to clear a rejection |

## Optional: mechanical backstop
The rules above are prompt-based: they hold under normal pressure, but they still rely on the model choosing to follow them in the moment. `scripts/block-unsafe-push.sh` in this skill is an opt-in `PreToolUse` hook that blocks `git push --force`/`--force-with-lease` and any push naming `main`/`master`/`trunk` explicitly, before the command runs, no model judgment involved. Installing this plugin doesn't wire it in; see the comment header in the script for how to register it in `settings.json`. It's plain string matching, not a real git-aware check, so it's a backstop for the common case, not a substitute for the rule itself (idea prompted by comparing against [mattpocock/skills' git-guardrails-claude-code](https://github.com/mattpocock/skills/blob/main/skills/misc/git-guardrails-claude-code/SKILL.md), which blocks `git push` outright; this one only blocks what this skill already forbids, so ordinary feature-branch pushes still work unprompted).
