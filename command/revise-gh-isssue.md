---
description: Revise a GH issue PR branch. 
agent: plan

---

This branch is meant to resolve this issue:

gh issue view $ARGUMENTS;

You can diff it with dev to see what was changed to resolve the issue.

Review ALL OF the recent comments on the issue and determine whether further changes are needed:

gh issue view $ARGUMENTS --comments;

Make a plan to make any needed changes. Group the plan's steps into "phases". After completing each phase, the code MUST build correctly and all tests (except the enterprise tests, you can ignore those) MUST pass. 

Do not make any changes unrelated to the changes that are required to resolve the isue.

Once you've come up with your plan, submit it to me for approval.
