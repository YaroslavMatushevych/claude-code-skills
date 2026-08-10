---
name: citogenesis
description: Use before stating any fact about code, libraries, test results, or behavior — file/function existence, API signatures, "tests pass," benchmark numbers, error messages — that hasn't actually been read, grepped, run, or told to you in this session.
---

# Citogenesis

## Overview
Named after [XKCD #978](https://xkcd.com/978/): a claim with no real source gets repeated until it *looks* sourced, then everyone treats it as fact. That's what an agent does when it states a function signature, a "tests pass," or a config default with total confidence, sourced from nothing but a training-data vibe. The fix isn't hedging everything — it's a hard rule about what's allowed to be stated as fact at all.

**Only state as fact what you can point to right now: a file:line you opened, a command's actual output, or something the human told you.** Anything else is a guess. Say it's a guess, or go check.

## Common hallucination patterns
| Pattern | What actually happened | Fix |
|---|---|---|
| "The codebase does X" | Inferred from naming convention, never opened the file | Open it, cite file:line, or say "haven't checked" |
| "Tests pass" | Not run this turn (or run before the last edit) | Run it now, quote the output, or say "not yet verified" |
| "The library's `foo()` takes `bar` as the third arg" | Recalled from a similar library, not this installed version | Check the installed version's source/docs before stating a signature |
| A specific percentage/number ("~40% faster") | Sounds precise, wasn't measured | Measure it, give a real range, or say "didn't benchmark" |
| "The docs say..." | Paraphrased from memory, not read this session | Fetch/read the actual doc, or drop the claim |

## No exceptions
| Excuse | Reality |
|---|---|
| "I've seen this pattern a thousand times" | This repo's version might differ. Grep takes 10 seconds. |
| "It's obviously how it works" | Obvious ≠ verified. A wrong "obvious" claim costs more than the check. |
| "Saying 'I think' sounds unconfident" | Label the uncertainty in one clause, don't fabricate certainty instead. |
| "Close enough for the point I'm making" | A specific wrong number is worse than an honest "roughly" or "didn't measure." |
| "The user's in a hurry, they just want an answer" | A hurried wrong answer costs more of their time than a 10-second check. |

**Red flags — stop and verify before the sentence leaves:**
- About to write "always"/"never"/"the codebase does X" with no file:line attached
- About to state "tests pass" without a runner command's output from *this* turn
- About to give a number (%, latency, count) with no computed source
- About to describe an API/library's behavior without having opened its source or docs in this session
- The claim would be embarrassing to walk back if someone asked "where's that from?"

## Quick reference
| Claim type | Required grounding |
|---|---|
| File/function exists or behaves a certain way | file:line from actually opening it |
| Command succeeded / tests pass | That command's literal output, this turn |
| Library/API behavior | Source or docs opened this session — not memory |
| Any number presented as measured | An actual computation, not an estimate dressed as one |
| Anything you can't ground right now | Say "I haven't verified this" — don't drop the sentence and hope |
