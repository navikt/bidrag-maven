#!/bin/bash
set -e

############################################
#
# CUCUMBER_Følgende skjer i dette skriptet:
# 1) Sletter bidrag-dokument-journalpost hvis den finnes i RUNNER_WORKSPACE fra før
# 2a) Ved feature branch (ENVIRONMENT=q1)
#    - clone bidrag-cucumber-backend, branch=feature (hvis den finnes), hvis ikke brukes master
# 2b) Ved master branch (ENVIRONMENT=q0)
#    - clone bidrag-cucumber-backend master
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
# 4) kjører mvn test -e på bidrag-cucumber-backend i et docker image med all konfigurasjon for integeasjonstesting
#
############################################

cd "$RUNNER_WORKSPACE"

echo "Working directory:"
pwd

sudo rm -rf bidrag-cucumber-backend

if [ "$GITHUB_REF" != "refs/heads/master" ]; then
  ENVIRONMENT=q1
  FEATURE_BRANCH=$(echo "$GITHUB_REF" | sed 's;refs/heads/;;')
  IS_FEATURE=$(git ls-remote --heads https://github.com/navikt/bidrag-cucumber-backend $FEATURE_BRANCH | wc -l)

  if [ $IS_FEATURE -eq 1 ]; then
    echo "Using feature branch: $FEATURE_BRANCH"
    git clone --depth 1 --branch=$FEATURE_BRANCH https://github.com/navikt/bidrag-cucumber-backend
  else
  echo "Using /refs/heads/master"
    git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
  fi
else
  ENVIRONMENT=q0
  echo "Using /refs/heads/master"
  git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
fi

cd bidrag-cucumber-backend

if [ -z "$USER_AUTHENTICATION" ]; then
  >&2 echo "::error No USER_AUTHENTICATION (password) for a nav user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z "$TEST_USER_AUTHENTICATION" ]; then
  >&2 echo "::error No TEST_USER_AUTHENTICATION for for the test user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

RUN_ARGUMENT="--rm -v $PWD:/usr/src/mymaven -v $HOME/.m2:/root/.m2 -w /usr/src/mymaven $INPUT_MAVEN_IMAGE mvn test"
MAVEN_ARGUMENT="-e -DENVIRONMENT=$ENVIRONMENT -DUSERNAME=$INPUT_USERNAME -DTEST_USER=$INPUT_TEST_USER -Dcucumber.filter.tags=@$INPUT_CUCUMBER_TAG"

echo "docker run: $RUN_ARGUMENT"
echo "maven arg.: $MAVEN_ARGUMENT"

if [ -z "$INPUT_PIP_USER" ]; then
  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION"
else
  if [ -z "$PIP_USER_AUTHENTICATION" ]; then
    >&2 echo "::error No PIP_USER_AUTHENTICATION for for the pip user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
    exit 1;
  fi

  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION -DPIP_USER=$INPUT_PIP_USER -DPIP_AUTH=$PIP_USER_AUTHENTICATION"

fi

docker run `echo "$RUN_ARGUMENT $MAVEN_ARGUMENT $AUTHENTICATION"`
