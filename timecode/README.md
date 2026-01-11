# README.md

This repo contains a fork of the [Thinkst OpenCanary](https://github.com/thinkst/opencanary) project.

To keep it up-to-date:

1. Periodically, fetch changes from the original repository.

   ```sh
   git fetch upstream
   ```

2. After fetching, integrate any desired changes into the fork.

   Create a merge commit (preserves the original project’s commit history).

   ```sh
   # create and switch to a new branch from origin/master
   git checkout -b upstream-merge origin/master

   git merge upstream/master  # Merge changes from upstream
   # or
   git merge upstream/master --allow-unrelated-histories

   # Resolve conflicts: open the conflicting files, make changes, and then mark them as resolved
   git add <resolved_file>

   git commit -m "Merged changes from upstream/master"
   ```

3. Push any updated state to this fork.

   ```sh
   # if the branch doesn't exist at remote
   git push -u origin upstream-merge
   # otherwise
   git push upstream-merge
   ```

4. Start a PR and, eventually, merge to origin master

5. Once merged

   ```sh
   git checkout master
   git fetch
   git pull

   # optionally, clean up branch
   git branch -D upstream-merge
   ```

6. If the update necessitates a new version build/publish, do that now (see below, "Remote build").

## Docker Build/Publish Workflow

### Local build

1. Ensure a file named `.secrets` exists at the (local) repo root (DO NOT COMMIT IT!). It should contain at least the following keys:

   ```txt
   LOCAL_WORKFLOW=true
   GITHUB_TOKEN=ghp_...
   ```

   Note: the `GITHUB_TOKEN` should include the scope `write:packages`

2. See setup details in this repo's `[.github/workflows/README.md](../.github/workflows/README.md)` file.

   Some specific usage examples:

   ```sh
   # use --bind here so that pre-commit can make adjustments to local repo code formatting
   act -W .github/workflows_offline -j precommit_tests --bind

   # sadly, act won't be able to handle all/any of the OS options asked of the upstream opencanary_tests action
   # therefore a simpler suite of tests, using a known/trusted 'core os' (ubuntu-22.04) and a single/recent
   # version of python, is available now by running:
   act -j opencanary-tests

   # to initiate a 'development' build and publish...
   act -j build-and-publish

   # to initiate a 'production-like' versioned build and publish...
   act -j build-and-publish --env GITHUB_REF=refs/tags/v1.2.3
   # for an interim/update version ...
   # act -j build-and-publish --env GITHUB_REF=refs/tags/v1.2.3+1
   ```

### Remote build

This is triggered by a versioned (release/semver) tag push

1. Add an empty commit (normal for "release" commits / no files modified; provides a commit with the desired message and a distinct SHA)...

   ```sh
   git checkout master
   git pull origin master

   git commit --allow-empty -m "Release v1.2.3"
   ```

2. Add new tag...

   ```sh
   # deal with any errant tags...?
   # git tag (or git show-ref --tags)
   # remove example:
   # git tag -d v0.0.1
   # git push origin --delete v0.0.1

   # add new tag (`-m <msg>` content is optional)
   git tag -a v1.2.3 -m ""

   # push to origin (will cause the github actions workflow`docker-alpine-publish.yml` to run)
   git push origin master
   git push origin v1.2.3
   ```

3. Create a GitHub Release (associates notes with the tag)

   ```sh
   gh release create v1.2.3 --title "v1.2.3" --notes "Releasenotes here"
   # or
   gh release create v1.2.3 --title "v1.2.3" --notes-file .RELEASE_NOTES.md
   # `./RELEASE_NOTES.md` would be a file in the build context(currently root of this repo)
   ```

   Or, via the web UI: go to Releases > Draft a new release >pick tag (v1.2.3) > publish.

   See [list of release](https://github.com/timecode/opencanary/releases)
