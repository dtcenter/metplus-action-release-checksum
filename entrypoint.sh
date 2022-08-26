#! /bin/sh

# if INPUT_DOCKER_NAME is set, then run docker login
if [ -z ${INPUT_TOKEN+x} ]; then
  echo "GitHub Token must be passed to this action."
  exit 1
fi

repository=${GITHUB_REPOSITORY}
ref=${GITHUB_REF}
event_name=${GITHUB_EVENT_NAME}
filename=`basename ${repository}`-`basename ${ref}`

echo GitHub repository: ${repository}
echo GitHub ref: ${ref}
echo GitHub event_name: ${event_name}

if [ "$event_name" != "release" ]; then
    echo "Triggering event must be release!"
    exit 1
fi

curl -LJO https://github.com/${repository}/archive/${ref}.zip
curl -LJO https://github.com/${repository}/archive/${ref}.tar.gz

ls ${filename}.zip
ls ${filename}.tar.gz

sha256sum ${filename}.zip > checksum.txt
sha256sum ${filename}.tar.gz > checksum.txt

cat checksum.txt

curl \
  -X PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token ${INPUT_TOKEN}" \
  https://api.github.com/repos/${repository}/releases/assets/99 \
  -d '{"name":"checksum.txt","label":"checksum"}'
