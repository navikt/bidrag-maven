#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) cloner bidrag-cucumber-backend direkte til RUNNER_WORKSPACE
# 2) setter q1 som miljø på feature brancher (q0 når master)
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen
# 4)
#
############################################

echo "Working directory:"
pwd

cd "$RUNNER_WORKSPACE"
sudo rm -rf bidrag-cucumber-backend
git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
cd bidrag-cucumber-backend

if [ "$GITHUB_REF" != "refs/heads/master" ]; then
  export ENVIRONMENT=q1
else
  export ENVIRONMENT=q0
fi

if [ -z "$USER_AUTHENTICATION" ]; then
  >&2 echo "::error No USER_AUTHENTICATION (password) for a nav user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z "$TEST_USER_AUTHENTICATION" ]; then
  >&2 echo "::error No TEST_USER_AUTHENTICATION for for the test user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

FILTER_TAGS=$(echo "cucmber.filter.tags=#@$INPUT_CUCUMBER_TAG#" | sed 's/#/"/g')
echo "Cucumber tag: $INPUT_CUCUMBER_TAG"
echo "Filter tags : $FILTER_TAGS"

if [ -z "$INPUT_PIP_USER" ]; then
  echo "Envrironment: $ENVIRONMENT without PIP"

  docker run --rm -v "$PWD":/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    -DUSERNAME="$INPUT_USERNAME" -DUSER_AUTH="$USER_AUTHENTICATION" \
    -DTEST_USER="$INPUT_TEST_USER" -DTEST_AUTH="$TEST_USER_AUTHENTICATION" \
    -D"$FILTER_TAGS"

else
  if [ -z "$IPIP_USER_AUTHENTICATION" ]; then
    >&2 echo "::error No PIP_USER_AUTHENTICATION for for the test user are configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
    exit 1;
  fi

  echo "Envrironment: $ENVIRONMENT with PIP"

  docker run --rm -v "$PWD":/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    -DUSERNAME="$INPUT_USERNAME" -DUSER_AUTH="$USER_AUTHENTICATION" \
    -DTEST_USER="$INPUT_TEST_USER" -DTEST_AUTH="$TEST_USER_AUTHENTICATION" \
    -DPIP_USER="$INPUT_PIP_USER" -DPIP_AUTH="$PIP_USER_AUTHENTICATION" \
    -D"$FILTER_TAGS"

fi
