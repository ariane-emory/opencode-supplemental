---
description: Eliminate dead or duplicated code.
agent: build

---

Systematically analyze the codebase for any dead or duplicated code and make a detailed, step-by-step plan to eliminate it. Group the plan's steps into "phases". Keep the DRY principle in mind, there may be opportunities to reduce duplication by merging functions that do similar things into a single function that covers all the cases.

$ARGUMENTS

The changes MUST NOT affect the program's behavior or appearance and you MUST NOT add any new files in the process. You MUST NOT remove code that is labelled 'reserved for future use' by a comment.

Proceed with the implemention of all phases of the plan. The code MUST build correctly and all tests MUST pass afterwards. 
