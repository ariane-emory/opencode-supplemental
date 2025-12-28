---
description: Integrate feature branches.
agent: build
new_session: true
---
!`cat ~/.config/opencode/md/integrate-branches--prologue.md`
integration/!`date +%Y-%m-%d-%H-%M`
!`cat ~/.config/opencode/md/integrate-branches--body.md`
$ARGUMENTS!`cat ~/.config/opencode/md/yoink-branches.md`
!`cat ~/.config/opencode/md/integrate-branches--epilogue.md`
