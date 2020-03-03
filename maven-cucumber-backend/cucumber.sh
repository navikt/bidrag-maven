#!/bin/bash
set -e

echo "Working directory:"
pwd

if [ -z "$INPUT_MAVEN_IMAGE" ]; then
  >&2 echo "::error A name of an image cantaining java and maven must be provided, see https://hub.docker.com/_/maven"
  exit 1;
fi

cd "$RUNNER_WORKSPACE"
sudo rm -rf bidrag-cucumber-backend
git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
cd bidrag-cucumber-backend

if [ "$GITHUB_REF" != "refs/heads/master" ]; then
  export ENVIRONMENT=q1
else
  export ENVIRONMENT=q0
fi

if [ -z "$MAVEN_USER_CREDENTIALS" ]; then
  >&2 echo "::error No MAVEN_USER_CREDENTIALS for a nav user to set up security of the tests are provided, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z "$MAVEN_TEST_USER_CREDENTIALS" ]; then
  >&2 echo "::error No MAVEN_TEST_USER_CREDENTIALS for for the test suite are provided, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z "$MAVEN_PIP_USER_CREDENTIALS" ]; then
  echo "Running in $ENVIRONMENT without PIP credentials"
  docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    "$MAVEN_USER_CREDENTIALS" \
    "$MAVEN_TEST_USER_CREDENTIALS" \
    -Dcucumber.options='--tags "@bidrag-dokument"'
else
  echo "Running in $ENVIRONMENT with PIP credentials"
  docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    "$MAVEN_USER_CREDENTIALS" \
    "$MAVEN_TEST_USER_CREDENTIALS" \
    "$MAVEN_PIP_USER_CREDENTIALS" \
    -Dcucumber.options='--tags "@bidrag-sak"'
fi
