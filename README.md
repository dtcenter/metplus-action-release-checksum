# metplus-action-release-checksum
Add a checksum to a release

## Inputs - Required

## `token`

GitHub token

## Outputs

None.

## Example usage

```
- uses: dtcenter/metplus-action-release-checksum@v1
  with:
    token: ${{ secrets.METPLUS_BOT_TOKEN }}
```
