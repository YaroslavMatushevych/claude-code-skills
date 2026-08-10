---
name: crafting-presentations
description: Use when building a slide-deck presentation in any tool (Keynote, PowerPoint, Google Slides, Marp/reveal.js, LaTeX Beamer, or code), structuring on-slide text versus speaker notes, choosing type scale and colors, pacing reveals and animation, adding memes, or slide-to-slide flow.
---

# Crafting Presentations

## Overview
A slide is a companion to a live speaker, not a document. On-slide text competes with the speaker for attention and loses if it says more than a phrase or a number. Everything explanatory (the story, the caveats, why it matters) goes in speaker notes, never on the slide. This holds regardless of tool.

## The split: slide vs. notes
| Goes on the slide | Goes in speaker notes |
|---|---|
| A number, a stat, a short label | The story behind it |
| A headline phrase (3-8 words) | Context, caveats, sources |
| A comparison (three logos, three numbers) | The argument for why it matters |
| A meme or diagram | The setup and timing for the joke |

Every presentation tool has a speaker-notes field: PowerPoint's and Keynote's notes pane, Google Slides' speaker notes, a Marp/reveal.js `<!-- notes -->` comment, LaTeX Beamer's `\note{}`, or a `notes` field if the deck is code. Use it; don't fold explanation into the slide because the notes field is easy to forget.

Write notes in first-person spoken voice with real specifics ("Jarred Sumner, 22, taught himself Zig because he hated how long Babel took"), not a summary of the slide. **Run all new copy, on-slide text and notes both, through the `humanizer` skill before calling a deck done.** Notes should sound like a person talking, not a teleprompter script; if you have a sample of how you actually talk, use humanizer's voice-calibration mode with it.

## Type scale
Relative hierarchy, independent of tool:

| Use | Relative size | Weight |
|---|---|---|
| Big stat callout (punchline number) | Largest on the slide, often bigger than the title itself | Heaviest weight available |
| Hero/slide title | Second largest | Bold to heaviest |
| Section subtitle | About a third of the title | Medium |
| Emphasis line | Slightly larger than body | Bold |
| Lead/body | Smallest text still readable from the back of the room | Regular |
| Meta/caption, badge/label | Small, often uppercase with wide letter-spacing | Bold |
| Chart axis/micro-label | Smallest text on the slide, only for axis ticks etc. | Regular, monospace if numeric |

A punchline number outsizing its own title is the one hierarchy inversion worth deliberately building in: the number is the point, the title is just the label for it.

## Color pattern
Neutral base (dark text on light, or light text on near-black for punchy data slides) plus one accent color per thing being compared, reused everywhere it appears (badges, chart lines, underlines) so the audience learns the color-coding within the first few slides. Three or four colors total (one per compared entity, one general accent) is enough; don't add a color that isn't tied to a recurring subject.

## Pacing: builds, animations, fragments
Most tools have a name for "reveal one element at a time": PowerPoint/Keynote "appear" animations, Google Slides "build" order, Marp/reveal.js `class="fragment"`, or entrance animation in code (framer-motion, CSS). The principle is the same regardless of tool: elements fade or slide in with a small offset, staggered by group rather than appearing all at once, so the audience's eye lands where the speaker currently is instead of the whole slide at once.

For a joke or a reveal, sequence it as explicit timed phases (appear, hold, exit, punchline-appears) rather than one blended animation. A wrong claim swinging on screen, falling, then the correction rising in its place lands harder than a static caption ever would.

## Progressive reveal within a slide
Advance one point at a time with the same input that advances slides (click, right arrow, space), falling through to the next slide once a slide's points run out. In slideware this is a build-order checkbox; in code it's a step index and a render function keyed to it. Either way: don't put a slide's whole argument on screen before the speaker has said the first part of it.

## Memes
One meme earns its place if it's the analogy the audience already has in their head before you show it. Caption it on the image itself, not in a separate text block. If you can't say where an image came from, don't ship it as if it proves something (the `dont-lie` rule applies to visuals too).

## Slide-to-slide flow
Write the notes for the whole talk end to end first, then split them into per-slide fields, not slide by slide in isolation; a deck written slide-by-slide reads like a stack of disconnected posts instead of one talk. Each slide's closing note should set up the next slide's premise. A working example: a slide's last note line is "next slide we'll see what actually fixed this," and the next slide is exactly that.

## If you're building this as code
The principles above hold regardless of stack. One concrete, working reference (React + Tailwind + Framer Motion): a `SlideLayout` wrapper component, a `slides` array of `{ id, label, component, steps?, render?, notes }`, a keyboard handler where right-arrow/space advances `subStep` before advancing `current`, and a toggleable notes panel bound to a `notes` key. Font sizes in that deck run roughly 64px (hero title) down to 36-38px (slide title), 68-72px for stat callouts, 20px subtitles, 15px body, 11-13px badges, and 7.5-9px chart labels, which is where the relative scale above came from. Treat this as one worked example to copy from, not the only valid stack; the same structure (layout wrapper, ordered slide list with notes, a step index for reveals) translates directly to Marp/reveal.js, Beamer, or plain HTML.

## Quick reference
| Situation | Fix |
|---|---|
| Text doesn't fit as a short phrase | Move it to notes, or split into two slides |
| Explaining a caveat on the slide | Wrong place, that's a note |
| A slide is one static wall of exposition | Give it a step-by-step progressive reveal instead |
| New copy just written | Run it through `humanizer` before shipping |
| A meme without a joke a stranger gets instantly | Cut it |
