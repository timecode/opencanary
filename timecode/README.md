# README.md

## Docker Build/Publish Workflow

- Local build

    1. Ensure a file named `.secrets` exists at the (local) repo root (DO NOT COMMIT IT!). It should contain at least the following keys:

       ```txt
       LOCAL_WORKFLOW=true
       GITHUB_TOKEN=ghp_...
       ```

       Note: the `GITHUB_TOKEN` should include the scope `write:packages`

    2. Use [ACT](https://github.com/nektos/act) to run github actions locally.

        - dev build: `act --container-architecture linux/amd64 --bind`
        - versioned build: `act --container-architecture linux/amd64 --bind --env GITHUB_REF=refs/tags/v1.2.3`

- Remote build: triggered by a versioned (release) tag push

    1. Add an empty commit (normal for "release" commits / no files modified; provides a commit with the desired message and a distinct SHA)...

        ```sh
        git checkout main
        git pull origin main

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

        # push to origin (will cause the github actions workflow `docker-alpine-publish.yml` to run)
        git push origin main
        git push origin v1.2.3
        ```

    3. Create a GitHub Release (associates notes with the tag)

        ```sh
        gh release create v1.2.3 --title "v1.2.3" --notes "Release notes here"
        # or
        gh release create v1.2.3 --title "v1.2.3" --notes-file ./RELEASE_NOTES.md
        # `./RELEASE_NOTES.md` would be a file in the build context (currently root of this repo)
        ```

        Or, via the web UI: go to Releases > Draft a new release > pick tag (v1.2.3) > publish.

        See [list of release](https://github.com/timecode/docker-build-example/releases)
