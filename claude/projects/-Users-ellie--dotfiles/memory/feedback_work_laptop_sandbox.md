---
name: work-laptop-sandbox
description: "eford work laptop is sandboxed - can't push to personal repos, only pinternal/pinternal-dev"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 8eb1732c-6c0d-4ec0-8d90-783af6bf4e53
---

On ellie's work laptop (username: eford), git operations r sandboxed thru a ssh bastion that ONLY allows repos in th pinternal and pinternal-dev github orgs!!

personal repos like rv32ima/dotfiles will fail 2 push with "repository not allowed" errors >,<

**Why:** Work security policy restricts what repos can b accessed from work machines

**How to apply:** When on th eford work laptop (check username or that we're in a work context):
- I can still make commits nd do local git/jj operations!!
- But DON'T try to push to personal repos - it will always fail
- Tell ellie she needs 2 push outside th sandbox instead
- Only pinternal/* repos can b pushed from this machine

This doesnt apply when im on ellie's home computer (username: ellie) - tht one has full access 2 everything :3
