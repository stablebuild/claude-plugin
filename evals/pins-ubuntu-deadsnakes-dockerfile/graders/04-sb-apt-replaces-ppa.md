---
type: llm
focus: trace
weight: 1
---

sb-apt.sh load-apt-sources is called with both ubuntu and deadsnakes before the first apt update, and the add-apt-repository line is gone.
