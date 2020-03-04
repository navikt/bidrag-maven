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

if [ -z $USER_AUTHENTICATION ]; then
  >&2 echo "::error No USER_AUTHENTICATION (password) for a nav user are configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z $TEST_USER_AUTHENTICATION ]; then
  >&2 echo "::error No TEST_USER_AUTHENTICATION for for the test user are configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z $INPUT_PIP_USER ]; then
  echo "Running in $ENVIRONMENT without PIP credentials"

  docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    -DUSERNAME="$INPUT_USERNAME" -DUSER_AUTH="$USER_AUTHENTICATION" \
    -DTEST_USER="$INPUT_TEST_USER" -DTEST_AUTH="$TEST_USER_AUTHENTICATION" \
    -Dcucumber.options='--tags "@bidrag-dokument"'

else
  echo "Running in $ENVIRONMENT with PIP credentials"

  if [ -z $IPIP_USER_AUTHENTICATION ]; then
    >&2 echo "::error No PIP_USER_AUTHENTICATION for for the test user are configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
    exit 1;
  fi

  docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    "$MAVEN_USER_CREDENTIALS" \
    "$MAVEN_TEST_USER_CREDENTIALS" \
    "$MAVEN_PIP_USER_CREDENTIALS" \
    -Dcucumber.options='--tags "@bidrag-sak"'
fi
