---
name: context-budget-statusline
description: Use when setting up or customizing a Claude Code statusLine to surface running session token usage, or when applying Matt Pocock's rule of clearing the context window around 150k tokens via color-coded thresholds.
---

# Context Budget Statusline

## Overview
A Claude Code `statusLine` script that adds cumulative session token usage (input + output) to the default statusline segments (cwd, git branch, model, context %, cost) and color-codes it so bloated context is visible before it degrades responses. Defaults follow Matt Pocock's rule of thumb: amber at 100k tokens, red at 150k tokens — the point he recommends clearing the window and starting a fresh session.

## When to use
- You want a visual nudge to `/clear` or start a new session before context bloat hurts response quality.
- You're building a `statusLine` command and want token-usage tracking, not just context %.
- You want the thresholds configurable rather than hardcoded to someone else's rule of thumb.

## Quick reference
| Threshold | Default | Color | Env var override |
|---|---|---|---|
| Amber | 100,000 tokens | orange | `STATUSLINE_AMBER_THRESHOLD` |
| Red | 150,000 tokens | red | `STATUSLINE_RED_THRESHOLD` |

## Install
1. Copy `statusline-command.sh` to `~/.claude/statusline-command.sh` and make it executable: `chmod +x ~/.claude/statusline-command.sh`.
2. Point Claude Code at it in `~/.claude/settings.json`:
   ```json
   { "statusLine": { "type": "command", "command": "~/.claude/statusline-command.sh" } }
   ```
3. (Optional) Override the thresholds without editing the script:
   ```sh
   export STATUSLINE_AMBER_THRESHOLD=80000
   export STATUSLINE_RED_THRESHOLD=120000
   ```

## Customizing colors
Colors are plain ANSI 256 vars near the top of the script (`PRIMARY`, `ACCENT`, `WHITE`, `GREY`, `AMBER`, `RED`). Change the escape codes to match your own terminal theme. Don't bake a specific employer's brand colors or wordmark into a personal/shared copy of this script — keep it generic so it's safe to publish.

## Common mistakes
- Forgetting `chmod +x` — the statusline just won't render, with no error surfaced.
- Editing the hardcoded numbers instead of the env vars, then losing the override when the script is updated.
- Assuming `context_window.total_input_tokens` includes prior turns beyond the session — it's whatever Claude Code reports for the current session in the hook payload.
