---
description: Verify solution to a GH issue.
agent: plan
model: github-copilot/claude-opus-4.5
---

This branch is meant to implement a resolution to this GH issue: 

gh issue view $ARGUMENTS;
gh issue view $ARGUMENTS --comments;

First, analyze the changes in this branch relative to the upstream/dev branch:

!`git diff dev..HEAD`
!`cat ~/.config/opencode/md/verify-gh-issue-resolution--epilogue.md`
