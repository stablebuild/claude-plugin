---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

make our docker build reproducible w/ stablebuild pls. we had an outage last week because something in the image changed under us without anyone touching the repo. we build with docker compose locally and in CI

Input files: Dockerfile, requirements.txt, app.py, docker-compose.yml, frontend/package.json, frontend/package-lock.json
