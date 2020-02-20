#!/bin/bash
set -e

if [ -z "$INPUT_MAVEN_IMAGE" ]
then
  >&2 echo "::error No docker image for maven is given..."
  exit 1;
fi

if [ -z "$INPUT_CUCUMBER_TAGS" ]
then
  >&2 echo "::error No tags for running of cucumber tests is given..."
  exit 1;
fi

if [ -z "$INPUT_ENVIRONMENT" ]
then
  >&2 echo "::error No environment where to run cucumber tests is given..."
  exit 1;
fi

if [ ! -d "$INPUT_GITHUB_REPOSITORY" ]
then
  git clone "https://github.com/navikt/$INPUT_GITHUB_REPOSITORY"
fi

cd "$INPUT_GITHUB_REPOSITORY"
git pull

echo "Running cucumber tests with cucumber tags: $INPUT_CUCUMBER_TAGS"

docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
  -Dcucumber.options='-- tags'"\"@$INPUT_CUCUMBER_TAGS\"" \
  -DENVIRONMENT="$INPUT_ENVIRONMENT" \
  "$MAVEN_CUCUMBER_CREDENTIALS"
