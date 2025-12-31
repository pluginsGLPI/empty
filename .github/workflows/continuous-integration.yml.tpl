name: "Continuous integration"

# To enable code coverage reporting,
# ensure that the project variable "CODE_COVERAGE" is set to "true"

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
      glpi-version: "11.0.x"
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
      code-coverage: ${{ vars.CODE_COVERAGE == 'true' }} # Value is obtained from project variables

  coverage-report:
    needs: "ci"
    if: vars.CODE_COVERAGE == 'true' && github.event_name == 'pull_request'
    runs-on: "ubuntu-latest"
    name: "Coverage report"
    steps:
      - name: "Download coverage report"
        uses: "actions/download-artifact@v4"
        with:
          name: "coverage-report"

      - name: "Generate coverage summary"
        uses: "irongut/CodeCoverageSummary@v1.3.0"
        with:
          filename: cobertura.xml
          badge: true
          fail_below_min: false
          format: markdown
          hide_branch_rate: false
          hide_complexity: true
          indicators: true
          output: both
          thresholds: '50 75'

      - name: "Add coverage comment"
        uses: "marocchino/sticky-pull-request-comment@v2"
        if: ${{ github.event_name == 'pull_request' }}
        with:
          header: coverage
          path: code-coverage-results.md
