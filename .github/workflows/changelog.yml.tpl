name: "Changelog"

on:
  pull_request:
    types: ["opened", "synchronize", "reopened", "edited", "labeled", "unlabeled"]

permissions:
  contents: "write"
  pull-requests: "read"

concurrency:
  group: "changelog-pr-${{ github.event.pull_request.number }}"
  cancel-in-progress: false

jobs:
  update-changelog:
    name: "Add unreleased entry"
    # GITHUB_TOKEN can never push to a fork's branch, so this only covers same-repo PRs
    # Fork support needs a bot/App token.
    if: ${{ github.event.pull_request.head.repo.full_name == github.repository }}
    runs-on: "ubuntu-latest"
    steps:
      - name: "Checkout"
        uses: "actions/checkout@v7"
        with:
          ref: "${{ github.head_ref }}"

      - name: "Add changelog entry"
        uses: "froozeify/gh-changelog-updater@v1"
        with:
          mode: "add-unreleased"
          # Commit to PR branch itself
          require-merged: "false"
          commit-branch: "${{ github.head_ref }}"
          label-mapping: |
            Added=enhancement,feature
            Fixed=fix,bug
            Security=security
            Deprecated=deprecation
            Removed=removal
            Changed=refactor,performance,breaking-change
          default-category: ""
          category-order: "Added,Changed,Deprecated,Removed,Fixed,Security"
          exclude-labels: "ignore-for-changelog,ignore-for-release,dependencies,github_actions,ci,chore,build,test,documentation,style"
