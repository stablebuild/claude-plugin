# API keys

Full docs: https://docs.stablebuild.com/product/public-api-keys and https://docs.stablebuild.com/tutorials/protecting-your-keys-in-public-docker-containers

## Private keys (the default)

A private key can download anything, and all of its traffic is billed to the organization. Keep it out of git: use `ARG SB_API_KEY` with no default, and pass it with `--build-arg`. In CI, store it as a secret. In `docker-compose.yml`, use `build.args: { SB_API_KEY: ${SB_API_KEY} }`, so it comes from the environment.

BuildKit warns `SecretsUsedInArgOrEnv` about `ARG SB_API_KEY`. That's expected for images that stay internal. The warning is about what the next section covers.

If a key might have leaked, the user can check **Billing > Raw usage logs** (every request lists its key) and rotate the key under **Keys**.

## Open-source repos: public keys

A public key (`<prefix>-pub-<name>`) is read-only. It only serves files that are on its allow-list and already cached, so it's safe to commit as the `ARG` default:

1. In the dashboard: **Keys > Add new key**, check **Public key**.
2. Open a write window on the key (1 hour, 24 hours or 7 days). While it's open, the key works like a normal key and everything it downloads is added to its allow-list.
3. Build once with the public key, then close the window.

When the dependencies change, open a new window and build again. All traffic through the key is still billed to the organization.

## Images pushed to a public registry

A key used during the build ends up in the image: in the image config (via `FROM`), in the history of every `RUN` that uses the `ARG`, and in files such as `/etc/apt/sources.list` and `/var/lib/apt/lists/`. To keep it out:

```dockerfile
ARG SB_API_KEY
FROM ${SB_API_KEY}.dockermirror.stablebuild.com/ubuntu:jammy-20261110 AS base
FROM scratch
COPY --from=base / /

ARG APT_PIN_DATE=2026-11-11T08:40:01Z
COPY ./sb-apt.sh /opt/sb-apt.sh
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
RUN --mount=type=secret,id=sb-api-key,target=/run/secrets/sb-api-key \
    SB_API_KEY=$(cat /run/secrets/sb-api-key) bash /opt/sb-apt.sh load-apt-sources ubuntu && \
    apt update && apt install -y curl && \
    cp /etc/apt/sources.list.bak /etc/apt/sources.list && \
    rm -r /var/lib/apt/lists/
```

Build it with `docker build --secret id=sb-api-key,env=SB_API_KEY .`. The `FROM scratch` stage drops the key from the image config. The secret mount keeps it out of the history. Cleaning up in the same `RUN` keeps it out of the layers.

Note that the global `ARG SB_API_KEY` is still needed for the first `FROM`, so the key still has to be passed with `--build-arg`. This is safe because the `FROM scratch` stage doesn't keep that `ARG`.

Kaniko has no build secrets. There, write the key to a file under `/kaniko/` before calling the executor, and mount that path instead.

Afterwards, check the result: `docker save <image> -o out.tar`, extract it, and `grep -R <key>` should find nothing. Other mirrors need the same treatment, so tell the user to run this check.
