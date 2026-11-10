name: "Continuous integration"

# Code coverage is automatically enabled when a `.glpi-coverage.json` file
# is present at the root of the plugin directory.

on:
  push:
    branches:
      - "main"
    tags:
       - "*"
  pull_request:
  schedule:
    - cron: "0 0 * * *"
  workflow_dispatch:

concurrency:
  group: "${{ github.workflow }}-${{ github.ref }}"
  cancel-in-progress: true

jobs:
  generate-ci-matrix:
    name: "Generate CI matrix"
    uses: "glpi-project/plugin-ci-workflows/.github/workflows/generate-ci-matrix.yml@v1"
    with:
      glpi-version: "12.0.x"
  ci:
    name: "GLPI ${{ matrix.glpi-version }} - php:${{ matrix.php-version }} - ${{ matrix.db-image }}"
    needs: "generate-ci-matrix"
    strategy:
      fail-fast: false
      matrix: ${{ fromJson(needs.generate-ci-matrix.outputs.matrix) }}
    uses: "glpi-project/plugin-ci-workflows/.github/workflows/continuous-integration.yml@v1"
    with:
      plugin-key: "{LNAME}"
      glpi-version: "${{ matrix.glpi-version }}"
      php-version: "${{ matrix.php-version }}"
      db-image: "${{ matrix.db-image }}"

  coverage-report:
    needs: "ci"
    uses: "glpi-project/plugin-ci-workflows/.github/workflows/coverage-report.yml@v1"
    with:
      plugin-key: "{LNAME}"
