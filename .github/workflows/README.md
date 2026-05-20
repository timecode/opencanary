# README.md

Avoid needless abuse of the account's [GitHub Actions billing](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions). Use [`act`](https://github.com/nektos/act) to run actions locally! Great for dev, sometimes great for specific manual prod invocations too.

## Setup

There are various ways to [install `act`](https://nektosact.com/installation/index.html). Build and install from cloned source, or use a package manager. For example:

```sh
# brew (linux, mac)
brew install act

# GitHub CLI extension
gh extension install https://github.com/nektos/gh-act
```

Optionally, a configuration file (`.actrc`) allows common options to be annexed. This example shows some default values too; adjust to taste:

```sh
--rm
--container-architecture=linux/amd64
# --bind
# --dryrun

### path to working directory (the target / repo root)
# --directory=../../../

### further paths are relative to --directory
# --workflows=.github/.idea/local/
# --secret-file=.github/.idea/local/.secrets
# --var-file=.vars
# --env-file=.env
```

Then...

```sh
act --help
Run GitHub actions locally by specifying the event name (e.g. `push`) or an action name directly.

Usage:
  act [event name to run] [flags]

If no event name passed, will default to "on: push"
If actions handles only one event it will be used as default instead of "on: push"
...
```

To replicate github's actions secrets management, ensure a `.secrets` ENV file exists at the root of the repo (locally, never commit it of course!).
Add/replicate any necessary values there and they'll be accessible just as they will be from a github runner (i.e. `secrets.ENV_NAME`):

```sh
LOCAL_WORKFLOW=true
GITHUB_TOKEN=ghp_etc...
ABC_API_TOKEN=123456...
XYZ_ADMIN_KEY=f1e2d3...
```

## General usage examples

```sh
act -h                              # --help        show act help
act -l                              # --list        view the execution graph
act -n                              # --dryrun      check syntax / modules

act                                 #               run the entire pipeline (default: `push` event)
act -q                              # --quiet       run the entire pipeline (default: `push` event) quietly
act pull_request                    #               run the entire pipeline, triggering a `pull_request` event

act -j run-linter                   # --job         run a specific job (by job ID)
# e.g. act -j precommit-tests --bind
# e.g. act -j opencanary-tests-local
# e.g. act -j build-and-publish
act -W .github/workflows/tests.yml  # --workflows   run a specific workflow (by path to file(s)) (default: "./.github/workflows/")
```

## Use a local-only workflow

```sh
# Create, and run act from, a directory named to ensure any local files won't show up in git
# Where possible, try to choose a dir name that's already in .gitignore (anything vaguely suitable will do)
# e.g. .github/.idea/local/
#              ^ .gitignore references the directory .idea/

# to start...
cd .github/.idea/local/
# tree -a .
# .
# ├── .actrc        # act options (see example above)
# ├── .secrets      # act secrets
# ├── docker.yml    # local workflow(s)
# └── README.md     # this file

# once setup, check act is referencing the correct directory
act --list
# ^ should only show jobs from the local workspace dir (e.g. those in docker.yml here)

# run all jobs
act

# run a specific job
act --job build-and-publish

# to initiate a 'production-like' versioned build and publish...
#   act -j build-and-publish --env GITHUB_REF=refs/tags/v1.2.3
# for an interim/update version ...
#   act -j build-and-publish --env GITHUB_REF=refs/tags/v1.2.3+1

##### confirm remote repo builds
docker pull --platform linux/amd64 ghcr.io/timecode/opencanary
docker run --platform linux/amd64 --rm -it --init --name opencanary -v $(pwd)/opencanary/test/opencanary.conf:/etc/opencanaryd/opencanary.conf ghcr.io/timecode/opencanary

##### check dev builds locally
docker build --platform linux/amd64 --progress=plain --no-cache-filter builder --file ./timecode/Dockerfile-alpine.latest --tag opencanary-dev .
# ^ adjust [--progress], [--no-cache|--no-cache-filter builder|final] to suit
docker run --platform linux/amd64 --rm -it --init --name opencanary-dev -v $(pwd)/opencanary/test/opencanary.conf:/etc/opencanaryd/opencanary.conf opencanary-dev
```

## Make packages public on ghcr.io

GitHub repository > Settings > General > Scroll down to the "Danger Zone"

- Find the option to "Change repository visibility". Click on this button.
- Select "Public" from the options presented.
- Confirm your choice when prompted.
- GitHub Packages Visibility (if applicable):
- If you are using GitHub Packages to host your Docker image, make sure to check the visibility settings on that specific package as well.
  - Go to the Packages section of your repository
  - Click on your package
  - Adjust the settings accordingly to ensure it is public.
