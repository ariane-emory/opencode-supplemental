---
description: Fix this.
---

The features from both of these branches seem to now be broken: 

#### fix/nonfatal-missing-key-commands 

Partially broken: unknown key commands are correctly not treated as  a fatal error, but the expected initial warning popup on start up does not appear, nor does the 'Unknown key command: whatever' toast when the bound key is struck.

#### feat/keybindable-commands

Completely broken: the keys bound to custom slash commands in my config aren't doing anything at all

The /reconcile-keybindable-commands-warnings branch was meant to make the prior two work properly together, but it does not appear to have worked.

$ARGUMENTS
