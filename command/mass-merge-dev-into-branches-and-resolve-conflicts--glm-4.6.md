---
description: Mass merge dev into all branches of origin using GLM.
agent: build
model: zai-coding-plan/glm-4.6
---
!`cat ~/.config/opencode/md/mass-merge-dev-into-branches--prologue.md`
!`git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed '/^origin$/d' | sed 's/^origin\///' | grep -v ^dev$ | grep -v ^integration\/ | grep -v ^merged\/ | grep -v ^obsolete\/ | grep -v ^failed\/`
!`cat ~/.config/opencode/md/mass-merge-dev-into-branches--epilogue.md`
