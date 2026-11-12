# OS package mirror (Ubuntu, Debian, Alpine)

Full docs: https://docs.stablebuild.com/mirrors-and-caches/os-package-registry-ubuntu-debian-alpine

StableBuild keeps a daily copy of the complete Ubuntu, Debian and Alpine package registries, plus a set of third-party repositories. Pinning to a snapshot date makes `apt install curl` return the same package on every build, and newly added packages are resolved against that same day.

## Ubuntu and Debian

`sb-apt.sh` reads `SB_API_KEY` and `APT_PIN_DATE` from the environment and rewrites the apt sources. Both values reach it as build `ARG`s:

```dockerfile
ARG SB_API_KEY
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/ubuntu:jammy-20261110
ARG SB_API_KEY
ARG APT_PIN_DATE=2026-11-11T08:40:01Z

COPY ./sb-apt.sh /opt/sb-apt.sh
RUN bash /opt/sb-apt.sh load-apt-sources ubuntu deadsnakes

RUN apt update && apt install -y curl python3.12
```

Run `load-apt-sources` before the first `apt update` in each stage that installs packages. Download the script with `curl -fsSL -o sb-apt.sh https://dashboard.stablebuild.com/download/sb-apt.sh`.

Arguments to `load-apt-sources`:

| Argument | Repository | Works on |
|---|---|---|
| `ubuntu`, `ubuntu-src`, `ubuntu-backports` | Ubuntu archive (backports from 2026-10-09) | Ubuntu |
| `debian`, `debian-src`, `debian-backports` | Debian archive (backports: 12 and 13 from 2026-10-09, 11 from 2026-10-13) | Debian |
| `deadsnakes` | Deadsnakes PPA (newer Python versions) | Ubuntu |
| `docker-ce` | Docker CE | Ubuntu, Debian |
| `nvidia-cuda` | NVIDIA CUDA (amd64, arm64) | Ubuntu |
| `chromium` | Chromium as a real apt package, from Debian; not on 26.04 | Ubuntu |
| `postgres` | apt.postgresql.org | Ubuntu |
| `ubuntu-toolchain-test` | ubuntu-toolchain-r/test PPA (newer gcc) | Ubuntu |
| `ros1` | ROS 1 | Ubuntu 20.04 only |
| `ros2` | ROS 2 | Ubuntu 22.04+, from 2026-07-24 |
| `qcom-iot` | Qualcomm IoT PPA (arm64) | Ubuntu |

Node.js from NodeSource isn't installed through `load-apt-sources`. Use `RUN bash /opt/sb-apt.sh install-node-js <exact version>`, which needs `wget` in the image. `scripts/node-versions.sh <major> <APT_PIN_DATE>` lists the versions in a snapshot.

Replace each upstream repository setup with its argument above, and remove the lines it replaces: `add-apt-repository ppa:deadsnakes/ppa`, `curl ... | gpg --dearmor`, `echo "deb ..." > /etc/apt/sources.list.d/...`, `curl ... setup_20.x | bash`. Apt sources left in `sources.list.d` aren't pinned, and `sb-apt.sh` prints a warning for them. Once the PPA line is gone, `software-properties-common` might no longer be needed. Remove it only if nothing else uses it, and mention it in the report.

If a repository isn't in the table, leave its setup in place, tell the user its packages aren't pinned, and point them to support@stablebuild.com, which adds public repositories on request.

Pinned versions like `apt install curl=7.68.0-1ubuntu2.20` keep working, as long as the version exists in the snapshot.

## Alpine

```dockerfile
ARG SB_API_KEY
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/alpine:3.22.2
ARG SB_API_KEY
ARG APK_PIN_DATE=2026-11-11T08:40:01Z

RUN printf "http://${SB_API_KEY}.debmirror.stablebuild.com/${APK_PIN_DATE}/alpine/v$(cut -d. -f1,2 /etc/alpine-release)/main\nhttp://${SB_API_KEY}.debmirror.stablebuild.com/${APK_PIN_DATE}/alpine/v$(cut -d. -f1,2 /etc/alpine-release)/community\n" > /etc/apk/repositories

RUN apk update && apk add curl
```

Alpine uses the same snapshot dates as apt (from 2023-12-17), so `scripts/latest-pin-date.sh` works for it too.

## Which snapshots have which releases

Pick a pin date inside the release's window. Otherwise apt fails to find the release.

| Release | Snapshots available |
|---|---|
| Ubuntu 18.04, Debian 10 | up to 2025-12-06 |
| Ubuntu 20.04 (and ROS 1) | up to 2026-07-23 |
| Ubuntu 26.04 (and ROS 2) | from 2026-07-24 |
| Alpine 3.16 to 3.20 | up to 2026-05-12 |
| All other releases | every snapshot since the release came out |

The first snapshots are from 2023-09-06 for Ubuntu and Debian, and from 2023-12-17 for Alpine.

So for Ubuntu 20.04, run `scripts/latest-pin-date.sh --before 2026-07-24`.

Anyone can browse the snapshots at http://debmirror.stablebuild.com/. To configure apt by hand without `sb-apt.sh`, the source lines look like `deb [trusted=yes] http://<key>.debmirror.stablebuild.com/<APT_PIN_DATE>/archive.ubuntu.com/ubuntu/ jammy main restricted`.
