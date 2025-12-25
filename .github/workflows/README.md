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
--container-architecture=linux/amd64
# --secret-file=.secrets
# --var-file=.vars
# --env-file=.env
# --bind
--rm
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
act -W .github/workflows/tests.yml  # --workflows   run a specific workflow (by path to file(s)) (default: "./.github/workflows/")
```
