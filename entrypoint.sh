#! /bin/bash

# if INPUT_DOCKER_NAME is set, then run docker login
if [ -z ${INPUT_TOKEN+x} ]; then
  echo "GitHub Token must be passed to this action."
  exit 1
fi

echo GitHub repository: ${GITHUB_REPOSITORY}
echo GitHub ref: ${GITHUB_REF}
echo GitHub event_name: ${GITHUB_EVENT_NAME}

echo filename: `basename ${GITHUB_REPOSITORY}`-`basename ${GITHUB_REF}`.zip
