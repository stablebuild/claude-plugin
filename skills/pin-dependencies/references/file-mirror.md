# File mirror

Full docs: https://docs.stablebuild.com/mirrors-and-caches/file-mirror

Prefix any URL with the file mirror and a cache key. The first request fetches the file and stores it, and later requests return the stored copy, even after the upstream file changes or disappears.

```dockerfile
RUN curl -fsSL "https://${SB_API_KEY}.httpcache.stablebuild.com/my-app/https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" -o awscliv2.zip
ADD https://${SB_API_KEY}.httpcache.stablebuild.com/my-app/https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 /usr/local/bin/jq
```

- **Cache key:** every key is a separate cache. Use the project or image name, so different projects can hold different versions of the same URL. To get a newer upstream file later, the user deletes the cached copy in the dashboard or switches to a new key.
- Shell expansion in the URL (`$(arch)`, `${VERSION}`) works as usual. Quote the whole URL.
- **`git clone`** can't be cached. Download an archive of the exact commit or tag instead: `https://github.com/<org>/<repo>/archive/<commit-sha>.zip` or `.../archive/refs/tags/<tag>.tar.gz`, then extract it. If the Dockerfile clones a branch, ask the user which commit to pin.
- **Authentication:** headers (`-H "x-api-key: ..."`) and basic auth in the URL (`https://user:pass@host/...`) are forwarded upstream on the first fetch only. After that, the URL alone identifies the cached file.
- Files over 5GB (or over 100MB without a `Content-Length` header) are cached in the background, which can take a few minutes after the first download.

## Installer scripts

With `curl ... | sh` installers (rustup, nvm, get.docker.com, ...) only the script itself gets pinned. Whatever the script downloads still comes from upstream. Check whether the installer accepts an option or environment variable for its download URL, and point that at the file mirror too. If it doesn't, say in the report that this step isn't fully pinned. Often there's a better route: for example `docker-ce` through `sb-apt.sh` instead of get.docker.com, or Node.js through `sb-apt.sh install-node-js` instead of nvm.
