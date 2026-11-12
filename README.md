# StableBuild plugin for Claude Code

Lets Claude pin your project's dependencies with [StableBuild](https://stablebuild.com), so the same build gives the same result every time. Claude:

- rewrites your Dockerfile (and Python config) to pull base images, Ubuntu/Debian/Alpine packages, PyPI packages, downloaded files and HuggingFace models through StableBuild's immutable mirrors
- picks pin dates and specific image tags for you
- builds the image once, which stores every dependency in StableBuild

## Install

```
/plugin marketplace add stablebuild/claude-plugin
/plugin install stablebuild@stablebuild
```

You need a StableBuild account (the Community plan is free) at https://dashboard.stablebuild.com. Export your API key before starting Claude Code, or Claude will ask for it:

```bash
export SB_API_KEY=your-api-key
```

In a private repo, Claude writes the key into the Dockerfile as the default of `ARG SB_API_KEY`, so `docker build .` works for everyone with access to the repo. In a public repo, it sets you up with a read-only public key instead.

## Use

Ask Claude to do it, for example:

- "Pin this Dockerfile with StableBuild"
- "Make our Docker build reproducible"
- "This 2021 repo doesn't install anymore, get it working again"

Or run the skill directly: `/stablebuild:pin-dependencies`.

## Updating

Plugins from marketplaces outside Anthropic don't update automatically by default. To get new versions as they come out, open `/plugin`, go to **Marketplaces**, select **stablebuild** and choose **Enable auto-update**. New versions then load in your next session.

To update by hand, run `claude plugin update stablebuild@stablebuild`, then `/reload-plugins` or restart Claude Code.

## Help

Documentation is at https://docs.stablebuild.com. For questions, or to request a mirror or package repository we don't support yet, email support@stablebuild.com.
