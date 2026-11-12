# Docker mirror

Full docs: https://docs.stablebuild.com/mirrors-and-caches/docker-mirror

Put the mirror host in front of the image. Images without a registry come from Docker Hub. For the other supported registries, keep the registry hostname in the path:

```dockerfile
ARG SB_API_KEY
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/ubuntu:noble-20261110
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/ghcr.io/astral-sh/uv:0.5.11
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/nvcr.io/nvidia/cuda:12.3.1-runtime-ubuntu22.04
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/public.ecr.aws/aws-cli/aws-cli:2.31.0
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/quay.io/prometheus/prometheus:v3.15.0
```

Supported registries: Docker Hub, `ghcr.io`, `nvcr.io`, `public.ecr.aws`, `quay.io`. Private repositories aren't supported, so leave those images as they are.

An `ARG` declared before the first `FROM` can only be used in `FROM` lines. To use the key in a stage's `RUN` commands, declare `ARG SB_API_KEY` again inside that stage.

`COPY --from=<image>` and `RUN --mount=from=<image>` pull images too, but `--from` doesn't expand variables, so `${SB_API_KEY}` can't go there. Pull the image in a stage of its own, above the stage that uses it, and refer to that stage by name. For `COPY --from=ghcr.io/astral-sh/uv:0.5.11 /uv /uvx /bin/`:

```dockerfile
ARG SB_API_KEY
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/ghcr.io/astral-sh/uv:0.5.11 AS uv

FROM ${SB_API_KEY}.dockermirror.stablebuild.com/ubuntu:noble-20261110
COPY --from=uv /uv /uvx /bin/
```

Mounts work the same way: `RUN --mount=from=uv,source=/uv,target=/bin/uv uv sync`.

## Use a specific tag

The first pull of a tag freezes it forever. `ubuntu:22.04` would then stay whatever 22.04 was on that day, and moving forward means deleting it under **Docker mirror > Cached tags** in the dashboard. A specific tag says what you're getting and lets you upgrade by changing one line. So replace broad tags (`latest`, `22.04`, `3.12-slim`, `20`) with the most specific matching tag:

- `ubuntu:22.04` → `ubuntu:jammy-20261110` (dated `<codename>-YYYYMMDD` tags)
- `debian:bookworm` → `debian:bookworm-20261104`
- `python:3.12-slim` → `python:3.12.7-slim-bookworm`
- `node:20` → `node:20.18.0-bookworm`

To find the newest specific tags, use the Docker Hub API (official images live under `library/`):

```bash
curl -s "https://hub.docker.com/v2/repositories/library/ubuntu/tags?page_size=10&name=jammy-&ordering=last_updated" | jq -r '.results[].name'
```

If there's no more specific tag, keep the current one and tell the user that it will be frozen at its first pull.

Prefer tags over `@sha256:` digests: a tag says what it is, and the mirror already makes it immutable, including every architecture (useful when developers on ARM Macs build the same image as x86 servers). If the Dockerfile already uses digests, leave them, since they work through the mirror too.

## When the Dockerfile can't change

When the user builds Dockerfiles they don't control, the mirror can be configured on the build machine instead: `"registry-mirrors": ["https://<key>.dockermirror.stablebuild.com"]` in `/etc/docker/daemon.json`, or `--registry-mirror https://<key>.dockermirror.stablebuild.com` for Kaniko.
