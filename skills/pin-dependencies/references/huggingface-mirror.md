# HuggingFace mirror

Full docs: https://docs.stablebuild.com/mirrors-and-caches/huggingface-mirror

`huggingface_hub`, and every library built on it (`transformers`, `diffusers`, `sentence-transformers`, ...), reads `HF_ENDPOINT`. Setting it to `https://<key>.hfmirror.stablebuild.com` sends downloads through StableBuild without code changes. Paths after the domain are the same as on huggingface.co.

Also pin a revision. `main` is like `latest`: if no revision is given, the mirror records the commit `main` pointed to at the first download and keeps serving that one. The pin then exists only in the mirror and isn't visible in the code. To find the current commit of a model:

```bash
curl -s https://huggingface.co/api/models/sentence-transformers/all-MiniLM-L6-v2 | jq -r .sha
```

Then pass it in the code (`from_pretrained(..., revision="<sha>")`) or on the CLI (`hf download <repo> --revision <sha>`).

## Where the download happens

- **At build time** (preferred, because the model is then part of the image):

  ```dockerfile
  RUN HF_ENDPOINT=https://${SB_API_KEY}.hfmirror.stablebuild.com \
      hf download sentence-transformers/all-MiniLM-L6-v2 --revision 1110a24
  ```

- **When the app starts:** `HF_ENDPOINT` has to be set in the runtime environment (deployment config, `docker run -e`, compose `environment:`). Don't use `ENV` in the Dockerfile, because that stores the key in the image. Suggest moving the download to build time if that suits the app.

Datasets, Spaces, and gated or private models aren't mirrored, so leave those downloads unchanged and say so.

To move to a newer model version, download it again with the new revision. Deleting the cached model first is risky: if the repository has since disappeared from HuggingFace, the old version can't be fetched again.
