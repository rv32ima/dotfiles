---
name: feedback-jj-push-flow
description: "always move the bookmark before pushing with jj!! commit → bookmark set → push, in that order"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 33297eea-85ef-413a-bf52-b760ca0bef81
---

the correct jj push flow is THREE steps, not two!!

1. `jj commit -m "..."` — commit the work
2. `jj bookmark set master -r @-` — move the bookmark to the commit just made
3. `jj git push --bookmark master` — now push

**Why:** after `jj commit`, @ is a new empty change and master still points at the old commit. `jj git push` with no bookmark set pushes nothing useful. ellie has had to correct luna on this multiple times >///<

**How to apply:** never go straight from commit to push!! always move the bookmark first. @- is the parent of the current empty @, which is the commit we just made.
