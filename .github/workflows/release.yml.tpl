name: "Release"

on:
  pull_request:
    types: ["opened", "synchronize"]
    paths:
      - "setup.php"
  push:
    branches:
      - "main"
      - "**/bugfixes"
    tags:
      - "*"

permissions:
  contents: "write"

concurrency:
  group: "release-${{ github.event.pull_request.head.ref || github.ref }}"
  cancel-in-progress: false

jobs:
  # Promotes CHANGELOG.md as part of the version-bump PR itself, so it lands in the same merge
  # commit as the bump. Promote is only done from a PR made in the original repo, not a fork.
  promote-changelog:
    name: "Promote changelog for release PR"
    if: >-
      ${{ github.event_name == 'pull_request' &&
          github.event.pull_request.head.repo.full_name == github.repository &&
          (github.event.pull_request.base.ref == 'main' || endsWith(github.event.pull_request.base.ref, '/bugfixes')) }}
    runs-on: "ubuntu-latest"
    steps:
      - name: "Checkout PR branch"
        uses: "actions/checkout@v7"
        with:
          ref: "${{ github.head_ref }}"

      - name: "Extract version"
        run: |
          VERSION=$(grep -oP "define\('PLUGIN_\w+_VERSION', '\K[^']+" setup.php)
          echo "VERSION=${VERSION}" >> "$GITHUB_ENV"

      - name: "Skip if this version is already tagged"
        run: |
          PROMOTE=no
          if [[ -n "${{ env.VERSION }}" ]] && ! git ls-remote --exit-code --tags origin "refs/tags/${{ env.VERSION }}" > /dev/null; then
            PROMOTE=yes
          fi
          echo "PROMOTE=${PROMOTE}" >> "$GITHUB_ENV"

      - name: "Promote Unreleased changelog section"
        if: ${{ env.PROMOTE == 'yes' }}
        uses: "froozeify/gh-changelog-updater@v1"
        with:
          mode: "promote-unreleased"
          version: "${{ env.VERSION }}"
          # If this plugin ships -alpha/-beta/-rc pre-release tags too, set this to "false" so
          # those get a changelog section as well.
          skip-prerelease: "true"
          skip-if-empty: "true"
          keep-unreleased: "true"
          commit-branch: "${{ github.head_ref }}"

  auto-tag-new-version:
    name: "Automatically tag new version"
    if: ${{ github.event_name == 'push' && !startsWith(github.ref, 'refs/tags/') }}
    uses: "glpi-project/plugin-release-workflows/.github/workflows/auto-tag-new-version.yml@v1"
    secrets:
      github-token: "${{ secrets.AUTOTAG_TOKEN }}"

  publish-release:
    name: "Publish release"
    if: ${{ startsWith(github.ref, 'refs/tags/') }}
    permissions:
      contents: "write"
    uses: "glpi-project/plugin-release-workflows/.github/workflows/publish-release.yml@v1"

  release-notes:
    name: "Append generated notes"
    needs: ["publish-release"]
    if: ${{ startsWith(github.ref, 'refs/tags/') }}
    runs-on: "ubuntu-latest"
    permissions:
      contents: "write"
    steps:
      - name: "Append GitHub's label-categorised notes"
        env:
          GH_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
          TAG_NAME: "${{ github.ref_name }}"
        run: |
          set -euo pipefail

          # publish-release already wrote the compat line + "See CHANGELOG.md" pointer — keep
          # it, and append GitHub's own notes below (categorised per .github/release.yml).
          EXISTING_BODY=$(gh release view "${TAG_NAME}" --repo "${GITHUB_REPOSITORY}" --json body --jq '.body')
          GENERATED_NOTES=$(gh api "repos/${GITHUB_REPOSITORY}/releases/generate-notes" \
            --method POST \
            -f "tag_name=${TAG_NAME}" \
            --jq '.body')

          if [[ -n "${EXISTING_BODY}" ]]; then
            printf '%s\n\n---\n\n%s\n' "${EXISTING_BODY}" "${GENERATED_NOTES}" > notes.md
          else
            printf '%s\n' "${GENERATED_NOTES}" > notes.md
          fi
          gh release edit "${TAG_NAME}" --repo "${GITHUB_REPOSITORY}" --notes-file notes.md
