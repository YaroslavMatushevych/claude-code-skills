# claude-code-skills

Personal collection of [Claude Code](https://claude.com/claude-code) skills — reusable techniques, tools, and configs I want available across projects.

## Skills

- [`context-budget-statusline`](skills/context-budget-statusline/) — statusLine script that tracks cumulative session token usage and color-codes it against configurable thresholds, so you clear context before it bloats (default: amber at 100k tokens, red at 150k — after Matt Pocock's rule of thumb).

## Usage

Each skill lives in `skills/<name>/` with its own `SKILL.md` describing what it does and when to use it. Copy the relevant files into `~/.claude/` (or your project's `.claude/`) per that skill's install instructions.
