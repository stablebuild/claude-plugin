# StableBuild plugin for Claude Code

Lets Claude pin a project's dependencies with [StableBuild](https://stablebuild.com): Docker base images, Ubuntu/Debian/Alpine packages, PyPI packages, downloaded files and HuggingFace models. It rewrites your Dockerfile (and Python config) to use StableBuild's immutable mirrors, so the same build gives the same result every time.

## Install

```
/plugin marketplace add stablebuild/claude-plugin
/plugin install stablebuild@stablebuild
```

You need a StableBuild account (the Community plan is free) at https://dashboard.stablebuild.com. To let Claude run test builds, export your API key before starting Claude Code:

```bash
export SB_API_KEY=your-api-key
```

The plugin never writes your key into files. Dockerfiles get `ARG SB_API_KEY`, and you pass the key at build time with `--build-arg SB_API_KEY="$SB_API_KEY"`.

## Use

Ask Claude to do it, for example:

- "Pin this Dockerfile with StableBuild"
- "Make our Docker build reproducible"
- "This 2021 repo doesn't install anymore, get it working again"

Or run the skill directly: `/stablebuild:pin-dependencies`.

## What's inside

- `skills/pin-dependencies/SKILL.md`: the workflow (take stock, handle the key, choose pin dates, rewrite, build, report).
- `skills/pin-dependencies/references/`: one page per mirror, plus API key handling.
- `skills/pin-dependencies/scripts/`: look up the latest apt/Alpine snapshot and the available Node.js versions.
