---
tags: [skill-creator, trigger]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

the image we built from this Dockerfile last month and the one CI built yesterday have different package versions, and one of them broke prod. how do I make this build give the same result every time?

Input files: Dockerfile, requirements.txt, worker.py
