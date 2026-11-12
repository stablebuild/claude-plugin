---
name: pin-dependencies
description: Make Docker builds and Python environments reproducible with StableBuild by pinning base images, apt/Alpine packages, PyPI packages, downloaded files and HuggingFace models to immutable mirrors. Use this whenever the user mentions StableBuild, wants deterministic or reproducible Docker builds, asks to pin or freeze what a Dockerfile installs, has a build that broke because an upstream image, package or URL changed or disappeared, or wants an old Python project working again with the dependencies from its time — even if they don't name StableBuild.
---

# Pin dependencies with StableBuild

StableBuild runs pull-through mirrors that never change once something is cached: the first fetch stores the file, and every later fetch returns exactly the same bytes, even after upstream overwrites or deletes it. The apt/Alpine and PyPI mirrors also keep a full daily snapshot, so a project can be pinned to a date. Pinning a project means routing every download its build makes through the matching mirror.

| What the project uses | Mirror | Rewrite to | Read |
|---|---|---|---|
| `FROM image:tag` | Docker mirror | `FROM ${SB_API_KEY}.dockermirror.stablebuild.com/image:<specific tag>` | `references/docker-mirror.md` |
| `apt install`, PPAs, `apk add` | OS package mirror | `sb-apt.sh` + `APT_PIN_DATE` (Ubuntu/Debian), `/etc/apk/repositories` + `APK_PIN_DATE` (Alpine) | `references/os-packages.md` |
| `pip install`, requirements files, uv, Poetry | PyPI mirror | `-i https://${SB_API_KEY}.pypimirror.stablebuild.com/<YYYY-MM-DD>/` | `references/pypi-mirror.md` |
| `curl`/`wget`/`ADD` of a URL, `git clone` | File mirror | prefix `https://${SB_API_KEY}.httpcache.stablebuild.com/<cache-key>/` | `references/file-mirror.md` |
| HuggingFace models | HuggingFace mirror | `HF_ENDPOINT=https://${SB_API_KEY}.hfmirror.stablebuild.com` + a pinned revision | `references/huggingface-mirror.md` |

Read the reference for each kind of dependency before rewriting it: they hold the exact syntax and the details that make a build fail.

There is no mirror for npm, Go modules, Cargo, Maven, RubyGems or conda. Say so plainly instead of making up a mirror URL. The file mirror can sometimes stand in for a package index (see "Other package indexes" in the PyPI reference), and support@stablebuild.com takes requests for new mirrors.

## Workflow

### 1. Take stock

Find every place where the build downloads something: each stage of each Dockerfile, `docker-compose` build sections, `requirements*.txt`, `pyproject.toml`, scripts run from `RUN`, and application code that downloads models when it starts. Map each one to a mirror from the table, or mark it as not covered.

### 2. Handle the API key

Each mirror URL has the user's API key as its subdomain. The key both authenticates and bills the account.

- Take the key from `$SB_API_KEY` in the environment. If it isn't set, ask the user for it: the key is under **Keys** on https://dashboard.stablebuild.com, and there's a free Community plan if they don't have an account yet.
- In a private repo, commit the key as the default of a build argument, as the StableBuild docs do, so `docker build .` works on every machine and in CI without extra setup. Declare `ARG SB_API_KEY=<key>` before the first `FROM` (so `FROM` can use it), and `ARG SB_API_KEY` again in every stage that uses it in a `RUN`. Refer to it as `${SB_API_KEY}` in every URL, so the key appears in one place and rotating it is a one-line change.
- In a public repo, a private key lets anyone download on the user's bill. Suggest a public API key instead: it's read-only and meant to be committed. If you can't tell whether the repo is public, ask. If the image itself will be pushed to a public registry, the key ends up inside it. `references/keys.md` covers both cases.

### 3. Choose pin dates

- **apt and Alpine:** run `scripts/latest-pin-date.sh` to get the newest snapshot (e.g. `2026-11-11T08:40:01Z`). Some OS releases are no longer mirrored (Ubuntu 20.04, for example, only exists in snapshots before 2026-07-24). Check the availability table in `references/os-packages.md`, and when it applies run `scripts/latest-pin-date.sh --before <date>`.
- **PyPI:** use the date part of the apt snapshot (`2026-11-11`). Any date up to the PyPI mirror's newest index works; a later date fails. If pip can't find the index, go back a day.
- **An old project that no longer builds:** pin PyPI to when it last worked, such as the date of the commit or release being built. Installing old code against the registry of that day is the most reliable way to get it working again. The apt and Alpine snapshots only start in 2023 (2023-09-06 for Ubuntu and Debian, 2023-12-17 for Alpine), so for an older project use the oldest snapshot that still has its OS release.
- Put the dates in `ARG`s with defaults (`APT_PIN_DATE`, `PYPI_PIN_DATE`), so moving to newer packages later is a one-line change. They aren't secret and belong in git. Declare them after `FROM`: an `ARG` before the first `FROM` is only visible to `FROM` lines, and `sb-apt.sh` reads `APT_PIN_DATE` inside `RUN`.

### 4. Rewrite

Keep the edits small and keep the user's structure, comments and layer order. If the project uses apt, download `sb-apt.sh` next to the Dockerfile:

```bash
curl -fsSL -o sb-apt.sh https://dashboard.stablebuild.com/download/sb-apt.sh
```

Every StableBuild-specific edit should be easy to recognize, because the user will review the diff.

### 5. Build it

If Docker is available, run the build right away. It proves the setup works, and it's also what pins everything: the Docker, file and HuggingFace mirrors freeze an image tag, file or model at its first download, so nothing is stored until the first build.

```bash
docker build -t <name> .
```

Add `--build-arg SB_API_KEY="$SB_API_KEY"` if the key isn't in the Dockerfile. Large builds, such as ML images that pull PyTorch, can take several minutes, so run them in the background.

When it works, apt fetches from `debmirror.stablebuild.com` and pip from `pypimirror.stablebuild.com`. Afterwards the dashboard lists what got cached. If Docker isn't available, tell the user to run the build soon, because that first build is what stores their dependencies.

### 6. Report

End with:

1. A table with one row per dependency: what it was, and how it's pinned now or why it isn't.
2. The build command. If the key isn't in the Dockerfile, also list where it has to be passed in (CI secrets, `build.args` in `docker-compose.yml`).
3. Anything still unpinned, and what the user can do about it.
