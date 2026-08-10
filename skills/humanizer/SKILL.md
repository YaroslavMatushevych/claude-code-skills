---
name: humanizer
description: Use when writing or reviewing prose, comments, docstrings, commit messages, or PR text to strip AI writing tells and sound like a person actually wrote it.
---

# Humanizer

Inspired by Wikipedia's [Signs of AI Writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) project and [blader/humanizer](https://github.com/blader/humanizer).

## Rule
Never invent a fact, name, number, date, or citation that isn't in the source. Cutting AI-sounding filler doesn't excuse adding fake specificity — ask for a real detail, or leave the plain version.

## Tells (prose)
| Category | Watch for | Fix |
|---|---|---|
| Significance inflation | "marks a pivotal moment", "a testament to" | State the fact, drop the ceremony |
| Copula avoidance | "serves as/boasts/features" | "is/has" |
| Negative parallelism | "It's not just X, it's Y", "..., no guessing" | Say the point once, directly |
| Rule of three | forced triads ("innovation, inspiration, insight") | Use however many items there actually are |
| AI vocabulary | delve, testament, landscape, tapestry, underscore, pivotal, crucial | Plain word, or cut |
| Filler | "in order to", "due to the fact that", "at this point in time" | "to", "because", "now" |
| Hedging stack | "could potentially possibly" | "may" |
| Signposting | "let's dive in", "here's what you need to know" | Start with the content |
| Sycophancy | "Great question! You're absolutely right!" | Respond to the point |
| Chatbot artifacts | "I hope this helps!", "let me know if..." | Delete |
| Em/en dashes (—, –) | any use, including spaced/double-hyphen | Period, comma, colon, or parens — hard cut, no "sparingly" |
| Inline-header lists | "**Performance:** Performance improved" | Convert to prose or a plain list |
| Title Case headings | "## Strategic Negotiations And Partnerships" | Sentence case |
| Emoji as bullets | 🚀 **Launch:** ... | Remove |

## Tells (code — comments, docstrings, commits, PRs)
| Watch for | Fix |
|---|---|
| Comment restates the line (`// increment counter` above `i++`) | Delete, or explain why not what — see [`committing-with-intent`](../committing-with-intent/SKILL.md) |
| Docstring padding ("This function is responsible for handling the logic of...") | State what it does in one plain clause |
| PR/commit filler ("This PR improves code quality and maintainability") | See [`drafting-pr-descriptions`](../drafting-pr-descriptions/SKILL.md) — name the real change |
| Emoji in commit/PR titles | Remove |

## Don't over-flag
Perfect grammar, formal vocabulary, one em dash, one "however", curly quotes, unsourced claims — none of these alone mean AI wrote it. Flag **clusters**, not single tells.

## Voice calibration
Given a writing sample, match its sentence length, vocabulary, and punctuation habits instead of the defaults above. A real sample outranks every rule here, including the em dash cut — if the sample uses them, keep them at the sample's rate.

## Process
1. Draft the rewrite.
2. Ask: "what in this rewrite would still read as AI?" and "did I add any fact not in the source?"
3. Fix both, then scan the draft for em/en dashes — any hit means it isn't done.
