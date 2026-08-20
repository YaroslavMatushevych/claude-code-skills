---
name: context-budget-statusline
description: Use when setting up or customizing a Claude Code statusLine to surface the current context window's token count and cache freshness, or when applying Matt Pocock's rule of clearing the context window around 150k tokens via color-coded thresholds.
---

# Context Budget Statusline

## Overview
A Claude Code `statusLine` script that adds two things to the default statusline segments (cwd, git branch, model, context %, cost): the current context window's token count, and cache freshness.

**Token count** (input + output, in absolute tokens rather than a percentage) is color-coded so bloated context is visible before it degrades responses. This is the same underlying number as the `ctx:%` segment, just in raw tokens instead of a percentage. It reflects what's in the context window right now, not a lifetime total, and it drops after `/compact` or `/clear` same as `ctx:%` does. Defaults follow Matt Pocock's rule of thumb: amber at 100k tokens, red at 150k tokens, the point he recommends clearing the window and starting a fresh session.

**Cache freshness** answers "is my next message about to miss the cache and re-index the whole conversation at full price?" That's the real cost of not clearing a huge context window, beyond degraded output quality. One merged segment, built from two real Claude Code statusline fields, no polling or external state:
- **Reactive**: whether the last completed turn's `cache_creation_input_tokens` outweighed its `cache_read_input_tokens`, meaning that turn was mostly a fresh, full-price write rather than a cheap hit.
- **Proactive**: a countdown to cache expiry, from the last assistant turn's own timestamp against a configurable TTL (default 3600s / 1hr, Anthropic's subscription cache lifetime). Lower it to 300s if you're drawing on usage credits, where the lifetime drops to 5 minutes.

These are deliberately one segment, not two side by side (v1.1.0 shipped them separately, fixed in v1.1.1). A miss resets both signals at once, so right after a real cache miss the countdown alone would read `cache: 59m left`. That's accurate for the *next* window, but easy to mistake for "still fully warm" when a full-price re-index just happened. When a miss is detected, the label leads with that and states real elapsed time rather than assuming "now": `cache: missed just now (7% hit) → 59m left`, or `cache: missed 12m ago (7% hit)` if the last turn we have data for wasn't recent. Otherwise it's just the countdown: `cache: 42m left` / `cache: expired 12m ago`.

Both signals are read from the same last-assistant-turn line in the transcript (v1.1.2). Earlier versions used the transcript file's mtime for the countdown, and Claude Code's own periodic background writes (`away_summary`, for the `--resume` feature) quietly kept refreshing that mtime regardless of real activity.

## When to use
- You want a visual nudge to `/clear` or start a new session before context bloat hurts response quality.
- You want to know a cold-cache turn is about to happen (or just happened). This is a real, measurable cost, not just a quality nudge: a cache-miss re-read is billed at full input rate, about 10x a cache-hit read.
- You're building a `statusLine` command and want token-usage and cache-hit tracking, not just context %.
- You want the thresholds configurable rather than hardcoded to someone else's rule of thumb.

## Quick reference
| Threshold | Default | Color | Env var override |
|---|---|---|---|
| Amber | 100,000 tokens | orange | `STATUSLINE_AMBER_THRESHOLD` |
| Red | 150,000 tokens | red | `STATUSLINE_RED_THRESHOLD` |
| Cache TTL | 3600 seconds | (none) | `STATUSLINE_CACHE_TTL_SECONDS` |
| Cache countdown, 5 min or less left | (none) | amber | (derived from TTL above) |
| Cache countdown, expired | (none) | red | (derived from TTL above) |

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
Colors are plain ANSI 256 vars near the top of the script (`PRIMARY`, `ACCENT`, `WHITE`, `GREY`, `AMBER`, `RED`). Change the escape codes to match your own terminal theme. Don't bake a specific employer's brand colors or wordmark into a personal/shared copy of this script. Keep it generic so it's safe to publish.

## Common mistakes
- Forgetting `chmod +x`: the statusline just won't render, with no error surfaced.
- `jq` not installed: same failure mode, a blank statusline with no error. Install it (`brew install jq` / `apt install jq`) before debugging the script itself.
- Editing the hardcoded numbers instead of the env vars, then losing the override when the script is updated.
- Assuming the token segment is a lifetime/cumulative session total: it's the current context window's contents (`context_window.total_input_tokens` + `total_output_tokens`), the same number `ctx:%` is computed from. It drops after `/compact` or `/clear`, it doesn't just keep climbing.
- Assuming the 100k/150k defaults scale with context window size: they're absolute token counts. On a 1M-token extended-context model they still fire at around 100k/150k tokens, roughly 10-15% of capacity, not 50-75%. Raise the env var overrides if you're on an extended-context model and want the same relative trigger point.
- Assuming `STATUSLINE_CACHE_TTL_SECONDS` auto-detects your plan's actual cache lifetime. It doesn't. 3600s (1hr) matches Anthropic's default subscription lifetime, but it drops to 300s once you're drawing on usage credits (or on API/cloud-provider billing by default). If your countdown never seems to hit "expired" when you'd expect, you're probably on the shorter lifetime, so set the env var to 300.
- The cache segment is silent, not missing, on the very first turn of a session or right after `/compact`. There's no assistant turn with usage data yet to read. That's expected, not a bug.
- Don't compute the countdown from the transcript file's mtime (v1.1.1 and earlier did). Claude Code periodically appends background bookkeeping entries, `away_summary` among them, part of the `claude --resume` feature, that touch the file's mtime without being a real, cache-relevant turn. That silently made the countdown read close to the full TTL almost permanently, regardless of how long it had actually been since the last real API response. Use the last assistant entry's own `timestamp` field instead: confirmed by checking real `away_summary` timestamps against real turn timestamps in an actual transcript, where they don't line up.
- Use `printf '%s\n' "$var"` to pipe a variable into `jq`, never `echo "$var"`. `echo` interprets a literal `\n` inside the JSON (extremely common: any assistant message quoting a multi-line shell command has one) as a real newline instead of passing it through, corrupting otherwise-valid JSON before `jq` ever sees it. The failure is silent too, since it only shows up as an empty `jq` result once you've redirected stderr away. `printf`'s `%s` never reinterprets escapes in its argument.
- Even with the `printf` fix above, a single transcript line can still fail to parse for an unrelated reason: genuinely raw control bytes captured in tool output, for instance a shell command that echoed ANSI color codes. Scan back through the last few candidate lines for one that actually parses instead of trusting the single most-recent line. A script that silently goes quiet on the busiest, most information-dense turns is worse than one that falls back a turn or two.
