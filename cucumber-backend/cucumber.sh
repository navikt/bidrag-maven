#!/bin/bash
set -x

############################################
#
# Følgende skjer i dette skriptet:
# 1) går til bidrag-backend-cucumber hvis mappa finnes
# 2) sjekker om miljøet har passord for nav-bruker og testbruker
# 3) setter påkrevde input argumenter til script og lager ENVIRONMENT basert på hvilken branch som bygges
# 4) - INPUT_DO_NOT_FAIL != true
#      kjører mvn INPUT_MAVEN_COMMAND -e på bidrag-cucumber-backend i et docker image med all konfigurasjon for
#      integeasjonstesting og feiler hvis det er fail i integrasjonstestene
#    - INPUT_DO_NOT_FAIL == true
#      kjører mvn INPUT_MAVEN_COMMAND -e på bidrag-cucumber-backend i et docker image med all konfigurasjon for
#      integeasjonstesting uten å feile ved testfeil
# 5) legger til variabel for nais konfigurasjon med maven (-DPROJECT_NAIS_FOLDER=$RUNNER_WORKSPACE/simple) man
#    skal bruke nais konfigurasjon
# 6) Utfører mvn kommando med parametre som gitt
# 7) Når valgfri maven kommando er oppgitt, så kjøres også denne med docker
#
############################################

if [[ -d bidrag-cucumber-backend ]]; then
  echo goto bidrag-cucumber-backend
  cd bidrag-cucumber-backend || exit 1
fi

echo "running cucumber tests from $PWD"
pwd

if [[ -z "$USER_AUTHENTICATION" ]]; then
  >&2 echo ::error:: "No USER_AUTHENTICATION (password) for a nav user is configured"
  >&2 echo ::error:: "see bidrag-maven/cucumber-backend/README.md"
  exit 1;
fi

if [[ -z "$TEST_USER_AUTHENTICATION" ]]; then
  >&2 echo ::error:: "No TEST_USER_AUTHENTICATION for for the test user is configured"
  >&2 echo ::error:: "see bidrag-maven/cucumber-backend/README.md"
  exit 1;
fi

INPUT_CUCUMBER_TAG=$1
INPUT_DO_NOT_FAIL=$2
INPUT_MAVEN_COMMAND=$3
INPUT_MAVEN_IMAGE=$4
INPUT_TEST_USER=$5
INPUT_USE_NAIS_CONFIGURATION=$6
INPUT_USERNAME=$7

if [[ "$GITHUB_REF" != "refs/heads/master" ]]; then
  ENVIRONMENT=q1
else
  ENVIRONMENT=q0
fi

CUCUMBER_FILTER=""

if [[ -z "$INPUT_CUCUMBER_TAG" ]]; then
  echo no cucumber tag is provided, no filtering is done...
else
  CUCUMBER_FILTER="-Dcucumber.filter.tags=@$INPUT_CUCUMBER_TAG"
fi

SKIP_MAVEN_FAILURES=""

if [[ "$INPUT_DO_NOT_FAIL" == "true" ]]; then
  SKIP_MAVEN_FAILURES="-Dmaven.test.failure.ignore=true"
else
  echo will fail if integrationstests have errors
fi

PROJECT_NAIS_FOLDER=""

if [[ -z "$INPUT_USE_NAIS_CONFIGURATION" ]]; then
  echo will find configuration from fasit...
else
  PROJECT_NAIS_FOLDER="-DPROJECT_NAIS_FOLDER=$RUNNER_WORKSPACE/simple"
fi

RUN_ARGUMENT="--rm -v $PWD:/usr/src/mymaven -v $HOME/.m2:/root/.m2 -w /usr/src/mymaven $INPUT_MAVEN_IMAGE mvn"
MAVEN_ARGUMENTS="-e -DENVIRONMENT=$ENVIRONMENT -DUSERNAME=$INPUT_USERNAME -DTEST_USER=$INPUT_TEST_USER $PROJECT_NAIS_FOLDER $CUCUMBER_FILTER $SKIP_MAVEN_FAILURES"

echo "docker run: $RUN_ARGUMENT $INPUT_MAVEN_COMMAND"
echo "maven args: $MAVEN_ARGUMENTS"

if [[ -z "$INPUT_PIP_USER" ]]; then
  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION"
else
  if [[ -z "$PIP_USER_AUTHENTICATION" ]]; then
    >&2 echo ::error:: "No PIP_USER_AUTHENTICATION for for the pip user is configured"
    >&3 echo ::error:: "see bidrag-actions/maven-cucumber-bidrag/README.md"
    exit 1;
  fi

  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION -DPIP_USER=$INPUT_PIP_USER -DPIP_AUTH=$PIP_USER_AUTHENTICATION"
fi

# shellcheck disable=SC2046
docker run $(echo "$RUN_ARGUMENT $INPUT_MAVEN_COMMAND $MAVEN_ARGUMENTS $AUTHENTICATION" | sed "s/'//")

if [[ -z "$INPUT_OPTIONAL_MAVEN_COMMAND" ]]; then
  echo no optional maven command are provided. additional command is not executed...
else
  # shellcheck disable=SC2046
  docker run $(echo "$RUN_ARGUMENT $INPUT_OPTIONAL_MAVEN_COMMAND" | sed "s/'//")
fi
