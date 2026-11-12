# PyPI mirror

Full docs: https://docs.stablebuild.com/mirrors-and-caches/pypi-mirror

`pip install onnx==1.14.0` isn't pinned: onnx's own dependencies (`numpy`, `protobuf>=3.20.2`, ...) resolve to whatever is newest on the day of the build. The PyPI mirror serves the complete index as it was on a given date, so the whole dependency tree resolves the same way on every build. A dependency added later also resolves against that same date, without moving the existing ones.

```dockerfile
ARG PYPI_PIN_DATE=2026-11-11

RUN pip install -i https://${SB_API_KEY}.pypimirror.stablebuild.com/${PYPI_PIN_DATE}/ -r requirements.txt
```

- Pass the index on the command line (`-i`, or `PIP_INDEX_URL=... pip install` inside the `RUN`). `ENV PIP_INDEX_URL=...` would store the key in the image config.
- `get-pip.py` takes the same flag: `python3 get-pip.py -i https://${SB_API_KEY}.pypimirror.stablebuild.com/${PYPI_PIN_DATE}/`. Download `get-pip.py` itself through the file mirror.
- `uv pip install` takes `--index-url` (or `--default-index`) in the same way.
- Dates use the form `YYYY-MM-DD`. Full daily indexes go back to 2023-09-21. Earlier dates are reconstructed, which mostly works but can't bring back deleted packages. A date later than the newest index fails, so stay at or before the date of the latest apt snapshot.

## Getting an old project working again

If a project last installed cleanly on some date, pin to that date: `pip install -i https://${SB_API_KEY}.pypimirror.stablebuild.com/2020-10-15/ -r requirements.txt`. Pip then resolves the dependency tree as it would have on that day. Use the date of the commit or release being built. The Python version also needs to match what existed then (for example a `python:3.8` base image, or `deadsnakes`).

## uv and Poetry projects

The docs suggest adding the mirror as an index in `pyproject.toml`:

```toml
[[tool.uv.index]]
name = "stablebuild"
url = "https://<key>.pypimirror.stablebuild.com/2026-11-11/"

[[tool.poetry.source]]
name = "stablebuild"
url = "https://<key>.pypimirror.stablebuild.com/2026-11-11/"
```

These files go into git, and `uv.lock` / `poetry.lock` record the index URL too, so this puts the key in the repository. That's fine in a private repo. In a public repo, use a public key.

Projects with a lock file already have fixed versions. What they still lack is protection against packages being deleted from PyPI. For that, the date `live` resolves against today's index but serves (and stores) every file from the mirror cache: `https://<key>.pypimirror.stablebuild.com/live/`.

## Other package indexes

Only PyPI has a dedicated mirror. An index that uses relative download links can be routed through the file mirror:

```bash
pip install \
    -i https://${SB_API_KEY}.pypimirror.stablebuild.com/2026-11-11/ \
    --extra-index-url=https://${SB_API_KEY}.httpcache.stablebuild.com/nvidia-2026-11-11/https://pypi.ngc.nvidia.com \
    onnx-graphsurgeon
```

Whether an index uses relative links isn't obvious until you build, so tell the user to verify it with a build.
