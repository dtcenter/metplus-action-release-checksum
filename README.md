# metplus-action-release-checksum
Add a checksum to a release

## Inputs - Required

## `token`

GitHub token

## Outputs

None.

## Example usage

Create a new workflow YAML file in .github/workflows and add the following:

```
name: Add checksum to release

on:
  release:
    types:
      - published

jobs:
  add-checksum:
    runs-on: ubuntu-latest
    steps:
      - uses: dtcenter/metplus-action-release-checksum@v1
        with:
          token: ${{ secrets.METPLUS_BOT_TOKEN }}

```
