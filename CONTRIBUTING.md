# Contributing

This is for StableBuild's developers. User doc goes in `README.md`.

## Layout

- `.claude-plugin/plugin.json`: the plugin manifest. Its `version` decides what users get.
- `.claude-plugin/marketplace.json`: makes this repo a marketplace that lists the plugin (`"source": "./"`).
- `skills/pin-dependencies/SKILL.md`: the workflow Claude follows (take stock, handle the key, choose pin dates, rewrite, build, report).
- `skills/pin-dependencies/references/`: one page per mirror, plus API key handling. Claude reads them on demand.
- `skills/pin-dependencies/scripts/`: look up the latest apt/Alpine snapshot and the available Node.js versions from the public listing at http://debmirror.stablebuild.com/.

The skill downloads `sb-apt.sh` from the dashboard when it runs, so fixes to `sb-apt.sh` in the main repo reach users without a plugin release.

## Validating

```bash
claude plugin validate --strict --profile directory .claude-plugin/plugin.json
claude plugin validate --strict .claude-plugin/marketplace.json
claude plugin validate --strict skills
```

## Testing

Test cases live in `evals/`, one folder per case: `prompt.md` (the user's request), `case.yaml`, `graders/` (one check per file) and `files/` (the project Claude works on). Three cases check the skill's output: an Ubuntu 20.04 Dockerfile with deadsnakes, a Python app with Node.js, a model and npm, and a 2021 TensorFlow project. Three check when the skill triggers: two requests that don't name StableBuild, and an image-size request that shouldn't use the skill.

### Eval runs

```bash
claude plugin eval . --runs 1 -j 4 --scaffold --trust-plugin --no-publish --allow-tools Write,Edit,Bash
```

Each case runs with and without the plugin, and a judge model grades the checks. Results and an HTML report go to `evals/results/`, which git ignores. Without `--no-publish`, the report is also published to claude.ai.

The eval sandbox blocks network access, so these runs can't reach the StableBuild mirrors, Docker Hub or HuggingFace. Checks that depend on live lookups (pin dates, image tags, `sb-apt.sh`) fail there for that reason alone. The trigger checks and the rest are still meaningful.

### Live runs

To test with network access, run a case as a normal headless session with the plugin loaded, then grade the result against the case's `graders/` by hand:

```bash
PLUGIN=$PWD CASE=pins-ubuntu-deadsnakes-dockerfile
WORK=$(mktemp -d) && cp -R "evals/$CASE/files/." "$WORK"
(cd "$WORK" && claude -p "$(awk 'f>=2; /^---$/{f++}' "$PLUGIN/evals/$CASE/prompt.md")" \
    --plugin-dir "$PLUGIN" --allowedTools "Bash,Read,Write,Edit,Glob,Grep,Skill" --max-turns 40)
```

### Real builds

Build what a live run produced with a real key: `docker build --build-arg SB_API_KEY="$SB_API_KEY" .`. Build logs contain the key, because apt prints full mirror URLs, so redact them before sharing.

## Releasing

Users only receive a new version when `version` in `.claude-plugin/plugin.json` changes. Commits without a version bump don't reach anyone.

1. Bump `version` in `.claude-plugin/plugin.json`, following semver. Don't add `version` to `marketplace.json`, since `plugin.json` overrides it.
2. Run the validation above.
3. Commit and push.
4. Tag the release with `claude plugin tag --push`. This creates `stablebuild--v<version>`. It refuses if the working tree has uncommitted changes, so the tag always points at what you released.
