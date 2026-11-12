---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

this repo of ours is from early 2021 and `pip install -r requirements.txt` blows up now (numpy / h5py / tensorflow version hell). it's open source on github and outside contributors need to be able to build it too. can you set it up with stablebuild so it installs like it did back then? there's no Dockerfile yet, add one

Input files: requirements.txt, README.md, stylize.py, GIT_LOG.txt
