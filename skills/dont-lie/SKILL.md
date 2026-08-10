---
name: dont-lie
description: Use before stating anything as fact — file/function behavior, API signatures, test results, benchmark numbers — that you haven't read, run, or been told this session.
---

# Don't Lie

## Rule
Don't say something is true unless you can point to it right now: a file:line you opened, a command's actual output, or something the user told you. No source, no claim. Say "not checked" instead.

## Patterns to catch
| You're about to say | You actually have | Fix |
|---|---|---|
| "The codebase does X" | Never opened the file | Open it, cite file:line, or say "haven't checked" |
| "Tests pass" | Didn't run them this turn | Run it, quote output, or say "not verified" |
| "`foo()` takes `bar` as arg 3" | Recalled from a different library | Check the installed version's source/docs |
| "~40% faster" | No measurement | Measure it, or say "didn't benchmark" |
| "The docs say..." | Paraphrased from memory | Read the doc this session, or drop the claim |

## No exceptions
| Excuse | Reality |
|---|---|
| "Seen this pattern a thousand times" | This repo's version might differ. Check. |
| "It's obviously how it works" | Obvious ≠ verified. |
| "'I think' sounds unconfident" | Say "not verified." Don't fake certainty. |
| "User's in a hurry" | A wrong answer costs more time than checking. |

## Red flags
- Writing "always"/"never"/"the codebase does X" with no file:line
- Writing "tests pass" with no command output from this turn
- Giving a number with no computed source
- Describing a library's behavior without opening its source/docs this session
- The claim would be embarrassing if someone asked "where's that from?"
