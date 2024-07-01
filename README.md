# metplus-action-release-checksum
Add a checksum to a release

## Release History

* **v2** - 20240701 -
  Fixed failure because GITHUB_OAUTH_BASIC is no longer set by GitHub.
  Authentication is handled by input token, so this is not needed anyway.
* **v1** - 20220914 -
  Initial tag

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
      - uses: dtcenter/metplus-action-release-checksum@v2
        with:
          token: ${{ secrets.METPLUS_BOT_TOKEN }}

```
