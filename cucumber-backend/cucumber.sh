#!/bin/bash
set -x

############################################
#
# Følgende skjer i dette skriptet:
# 1) Velger rot-katalog for runner workspace når det er angitt
# 2) Sletter bidrag-cucumber-backend hvis den finnes i RUNNER_WORKSPACE fra før
# 3a) Ved feature branch (ENVIRONMENT=q1)
#    - clone bidrag-cucumber-backend, branch=feature (hvis den finnes), hvis ikke brukes master
# 3b) Ved master branch (ENVIRONMENT=q0)
#    - clone bidrag-cucumber-backend master
# 4) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
# 5) setter påkrevde input argumenter til script
# 6a) INPUT_DO_NOT_FAIL != true
#    - kjører mvn INPUT_MAVEN_COMMAND -e på bidrag-cucumber-backend i et docker image med all konfigurasjon for
#      integeasjonstesting og reagerer på exit code fra maven kommando
# 6b)  INPUT_DO_NOT_FAIL == true
#    - kjører mvn INPUT_MAVEN_COMMAND -e på bidrag-cucumber-backend i et docker image med all konfigurasjon for
#      integeasjonstesting uten å reagere på exit code fra maven kommando
# 7) Når valgfri maven kommando er oppgitt, så kjøres også denne med docker
#
############################################

if [ "$INPUT_RUN_FROM_WORKSPACE" == "true" ]; then
  cd "$RUNNER_WORKSPACE"
  eco "running from $PWD"
fi

echo "Working directory:"
pwd
env

sudo rm -rf bidrag-cucumber-backend

if [ "$GITHUB_REF" != "refs/heads/master" ]; then
  ENVIRONMENT=q1
  FEATURE_BRANCH=$(echo "$GITHUB_REF" | sed 's;refs/heads/;;')
  IS_FEATURE=$(git ls-remote --heads "https://github.com/navikt/bidrag-cucumber-backend $FEATURE_BRANCH" | wc -l)

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

echo move to cucumber tests
pwd
cd bidrag-cucumber-backend
pwd
ls -al

if [ -z "$USER_AUTHENTICATION" ]; then
  >&2 echo "::error No USER_AUTHENTICATION (password) for a nav user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z "$TEST_USER_AUTHENTICATION" ]; then
  >&2 echo "::error No TEST_USER_AUTHENTICATION for for the test user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

INPUT_DO_NOT_FAIL=$1
INPUT_MAVEN_COMMAND=$2
INPUT_MAVEN_IMAGE=$3
INPUT_TEST_USER=$4
INPUT_USERNAME=$5

CUCUMBER_FILTER=""

if [[ -z "$INPUT_CUCUMBER_TAG" ]]; then
  echo no cucumber tag is provided, no filtering is done...
else
  CUCUMBER_FILTER="-Dcucumber.filter.tags=@$INPUT_CUCUMBER_TAG"
fi

SKIP_MAVEN_FAILURES=""

if [[ "$INPUT_DO_NOT_FAIL" == "true" ]]; then
  SKIP_MAVEN_FAILURES="-Dmaven.test.failure.ignore=true"
fi

RUN_ARGUMENT="--rm -v $PWD:/usr/src/mymaven -v $HOME/.m2:/root/.m2 -w /usr/src/mymaven $INPUT_MAVEN_IMAGE mvn"
MAVEN_ARGUMENTS="-e -DENVIRONMENT=$ENVIRONMENT -DUSERNAME=$INPUT_USERNAME -DTEST_USER=$INPUT_TEST_USER $CUCUMBER_FILTER $SKIP_MAVEN_FAILURES"

echo "docker run: $RUN_ARGUMENT $INPUT_MAVEN_COMMAND"
echo "maven args: $MAVEN_ARGUMENTS"

if [ -z "$INPUT_PIP_USER" ]; then
  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION"
else
  if [ -z "$PIP_USER_AUTHENTICATION" ]; then
    >&2 echo "::error No PIP_USER_AUTHENTICATION for for the pip user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
    exit 1;
  fi

  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION -DPIP_USER=$INPUT_PIP_USER -DPIP_AUTH=$PIP_USER_AUTHENTICATION"
fi

docker run $(echo "$RUN_ARGUMENT $INPUT_MAVEN_COMMAND $MAVEN_ARGUMENTS $AUTHENTICATION" | sed "s/'//")

if [[ -z "$INPUT_OPTIONAL_MAVEN_COMMAND" ]]; then
  echo no optional maven command are provided. additional command is not executed...
else
  docker run $(echo "$RUN_ARGUMENT $INPUT_OPTIONAL_MAVEN_COMMAND" | sed "s/'//")
fi
