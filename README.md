# claude-code-skills

Personal collection of [Claude Code](https://claude.com/claude-code) plugins/skills — reusable tools I want available across projects, and share with anyone who finds them useful.

Install the whole marketplace once, then pick which skills to install:

```
/plugin marketplace add YaroslavMatushevych/claude-code-skills
/plugin install context-budget-statusline@yaroslav-skills
/plugin install committing-with-intent@yaroslav-skills
/plugin install drafting-pr-descriptions@yaroslav-skills
```

## context-budget-statusline

A statusline for Claude Code that adds cumulative session **token usage** next to the cwd/branch/model/cost segments, and color-codes it so bloated context is visible before it hurts response quality. Default thresholds follow Matt Pocock's rule of thumb: amber at 100k tokens, red at 150k — the point he recommends clearing the context window and starting fresh.

No dependencies beyond `jq` (already required by any Claude Code statusline) and a POSIX shell.

### Option 1 — copy-paste, no plugin, no clone (fastest)

```bash
curl -o ~/.claude/statusline-command.sh \
  https://raw.githubusercontent.com/YaroslavMatushevych/claude-code-skills/main/skills/context-budget-statusline/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Then add this to `~/.claude/settings.json`:

```json
{ "statusLine": { "type": "command", "command": "~/.claude/statusline-command.sh" } }
```

That's it — restart Claude Code and the statusline is live.

### Option 2 — Claude Code plugin

```
/plugin marketplace add YaroslavMatushevych/claude-code-skills
/plugin install context-budget-statusline@yaroslav-skills
```

### Customizing thresholds

Override without editing the script:

```bash
export STATUSLINE_AMBER_THRESHOLD=80000
export STATUSLINE_RED_THRESHOLD=120000
```

Colors are plain ANSI 256 vars at the top of `statusline-command.sh` — change them to match your terminal theme.

Full details: [`skills/context-budget-statusline/SKILL.md`](skills/context-budget-statusline/SKILL.md).

## committing-with-intent

Commit-message and git-push guidance distilled from what engineers actually complain about with AI-written git history (see [research notes](#where-these-came-from) below): messages should explain the *why*, not restate the diff, and match the repo's existing convention. Also hardens against the failure mode that generates the most visceral complaints — an agent force-pushing or pushing to a shared/default branch without asking, every single time, no matter how it's framed ("just handle it," "I trust you," deadline pressure).

Full details: [`skills/committing-with-intent/SKILL.md`](skills/committing-with-intent/SKILL.md).

## drafting-pr-descriptions

Structures PR descriptions around what/why, risk, and testing *actually done* — the fix for the top reviewer complaint about AI-written PRs, which isn't tone, it's effort asymmetry (a description implying review work that wasn't done). Detects and fills the repo's own `PULL_REQUEST_TEMPLATE.md` instead of replacing it with generic AI-shaped filler, and links the ticket ID from the branch name when one exists instead of fabricating one.

Full details: [`skills/drafting-pr-descriptions/SKILL.md`](skills/drafting-pr-descriptions/SKILL.md).

## Where these came from

`committing-with-intent` and `drafting-pr-descriptions` are built from recurring, sourced complaints across Hacker News, Reddit, and real GitHub issues about AI-assisted git workflows — not guesses. Themes that showed up independently across multiple threads: AI commit messages restate the diff instead of explaining intent; force-pushes and destructive git ops happen without confirmation (including a filed [Claude Code issue](https://github.com/anthropics/claude-code/issues/33402) about exactly this); AI-written PR descriptions read as generic "slop" that implies more review effort than actually happened.

## License

MIT — see [LICENSE](LICENSE).
