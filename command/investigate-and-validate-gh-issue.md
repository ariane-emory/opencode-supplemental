---
description: Investigate/confirm a GH issue. 
agent: plan

---

Let's investigate this Github issue: 

gh issue view $ARGUMENTS;
gh issue view $ARGUMENTS --comments;

Take note of any coments on the issue, the discussion may include valuable insights on possible causes of the issue.

Find and study code in the codebase that could be related to the issue and analyze it thoroughly. Our focus isn't on thinking up a resolution for the issue yet  —  that will come later on — right now, our focus is on:

1. Firstly, confirming whether it is in fact a real issue/bug or whether the user has misunderstood or misstepped.
2. Secondly, if we can confirm that is a real issue/bug, on diagnosing the issue and determining what the root cause is that explains exactly why it is ocurring.
