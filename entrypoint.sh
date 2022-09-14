#! /bin/sh

repository=${GITHUB_REPOSITORY}
ref=${GITHUB_REF}
tag=`basename ${ref}`
event_name=${GITHUB_EVENT_NAME}
dl_filename=`basename ${repository}`-`echo ${tag} | sed -r 's/^v//g'`
cs_tar_filename=checksum_tar.txt
cs_zip_filename=checksum_zip.txt

echo GitHub repository: ${repository}
echo GitHub ref: ${ref}
echo GitHub event_name: ${event_name}

if [ "$event_name" != "release" ]; then
    echo "Triggering event must be release!"
    exit 1
fi

###
# create checksum
###

# download the assets containing the source code - zip and tar gz
echo curl -LJO https://github.com/${repository}/archive/${ref}.zip
curl -LJO https://github.com/${repository}/archive/${ref}.zip

echo curl -LJO https://github.com/${repository}/archive/${ref}.tar.gz
curl -LJO https://github.com/${repository}/archive/${ref}.tar.gz

# check that files were downloaded correctly and match expected name
if [ ! -s ${dl_filename}.zip ]; then
    echo "ERROR: Could not get zip file: ${dl_filename}.zip"
    exit 1
fi
if [ ! -s ${dl_filename}.tar.gz ]; then
    echo "ERROR: Could not get tar.gz file: ${dl_filename}.tar.gz"
    exit 1
fi

# create checksum from both files
echo Creating $cs_zip_filename with checksums for ZIP file
sha256sum ${dl_filename}.zip > $cs_zip_filename

echo Creating $cs_tar_filename with checksums for TAR file
sha256sum ${dl_filename}.tar.gz > $cs_tar_filename

# print checksum values
cat $cs_zip_filename
cat $cs_tar_filename

###
# Upload or replace asset
# logic modified from https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
###

# variables for curl commands to upload asset to release
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$repository"
GH_TAGS="$GH_REPO/releases/tags/$tag"
GH_ACCESS="$GH_REPO/collaborators/metplus-bot/permission"
AUTH="Authorization: token ${INPUT_TOKEN}"
WGET_ARGS="--content-disposition --auth-no-challenge --no-cookie"
CURL_ARGS="-LJO#"

# Validate token
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "ERROR: Invalid repo, token or network issue!";  exit 1; }

# check if metplus-bot user has push access
curl -sH "$AUTH" $GH_ACCESS | grep -A5 "permissions.:" | grep push | grep true || { echo "ERROR: User metplus-bot must have write access to $repository!";  exit 1; }

for cs_filename in $cs_tar_filename $cs_zip_filename; do
    # Read asset tags
    response=$(curl -sH "$AUTH" $GH_TAGS)

    # Get ID of the release
    eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
    [ "$id" ] || { echo "ERROR: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }
    release_id="$id"

    # Get ID of the asset based on checksum filename
    id=""
    eval $(echo "$response" | grep -C2 "name.:.\+$cs_filename" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
    assert_id="$id"
    if [ "$assert_id" = "" ]; then
        echo "No need to overwrite asset"
    else
        echo "Deleting asset($assert_id)... "
        curl "$GITHUB_OAUTH_BASIC" -X "DELETE" -H "$AUTH" "https://api.github.com/repos/$repository/releases/assets/$assert_id"
    fi

    # Upload asset
    echo "Uploading asset... "

    # Construct url
    GH_ASSET="https://uploads.github.com/repos/$repository/releases/$release_id/assets?name=$(basename $cs_filename)"

    curl "$GITHUB_OAUTH_BASIC" --data-binary @"$cs_filename" -H "$AUTH" -H "Content-Type: application/octet-stream" $GH_ASSET
done
