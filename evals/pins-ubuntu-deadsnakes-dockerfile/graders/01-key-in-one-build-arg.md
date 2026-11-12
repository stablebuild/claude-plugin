---
type: llm
focus: trace
weight: 1
---

Every StableBuild hostname in the Dockerfile uses ${SB_API_KEY} (or $SB_API_KEY) from an ARG SB_API_KEY declared before the first FROM, so the key is set in one place.
