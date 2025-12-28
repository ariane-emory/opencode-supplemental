---
description: Fetch latest integration branch.
agent: build
model: opencode/big-pickle
---

Fetch origin and then check out the latest integration branch so that it's available locally. 

Steps:
1. Run `git fetch origin` to get the latest branches
2. List all remote integration branches with `git branch -r | grep integration`
3. Sort the branches chronologically and identify the newest one (look for the most recent timestamp)
4. Create a local tracking branch for the newest integration branch using `git checkout -b integration/YYYY-MM-DD-HH-MM origin/integration/YYYY-MM-DD-HH-MM`

Note: The integration branches are named with timestamps, so the "latest" branch is the one with the most recent date/time in the name. 
