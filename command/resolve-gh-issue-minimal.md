---
description: Plan to resolve a GH issue (minimal). 
agent: plan

---

Let's try to come up with a plan for how to implement a resolution for this Github issue in the sst/opencode repository: 

gh issue view $ARGUMENTS;

Take note of any coments on the issue, the discussion may include valuable insights on how to best resolve the issue:

gh issue view $ARGUMENTS --comments;

IMPORTANT: Pay special attention to any comments from your user, ariane-emory, she often has good ideas!

Think the changes required to resolve the issue through thoroughly and break the changes down into small steps in order to produce a detailed, step-by-step plan for resolving the issue. 

Make the minimal change required to solve the issue. Do not make any unnecessary changes unrelated to the changes that are required to resolve the isue.

Think carefully about whether the changes necessitate re-generating either the TypeScript or Go SDKs, and if so be sure to include this step in your plan. Don't worry about the Python SDK yet, we can deal with that later on.

Group the plan's steps into "phases". After completing each phase, the code MUST build correctly and all tests (except the enterprise tests, you can ignore those) MUST pass. 

Once you've come up with your plan, submit it to me for approval.
