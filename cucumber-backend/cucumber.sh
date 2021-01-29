#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter input argumenter
# 2) sjekker om miljøet har passord for nav-bruker og testbruker
# 3) går til $RUNNER_WORKSPACE og til $INPUT_CUCUMBER_PROJECT for å nå cucumber koden
# 4) setter påkrevde input argumenter til script og lager ENVIRONMENT basert på hvilken branch som bygges
# 5) - INPUT_DO_NOT_FAIL != true
#      kjører mvn INPUT_MAVEN_COMMAND -e på <cucumber-github project> i et docker image med all konfigurasjon for
#      integeasjonstesting og feiler hvis det er fail i integrasjonstestene
#    - INPUT_DO_NOT_FAIL == true
#      kjører mvn INPUT_MAVEN_COMMAND -e på <cucumber-github project> i et docker image med all konfigurasjon for
#      integeasjonstesting uten å feile ved testfeil
# 6) legger til variabel for nais konfigurasjon med maven (-DPROJECT_NAIS_FOLDER/usr/src/mymaven/$INPUT_NAIS_PROJECT_FOLDER)
# 7) Utfører mvn kommando med parametre som gitt
# 8) Når valgfri maven kommando er oppgitt, så kjøres også denne med docker
#
############################################

INPUT_CUCUMBER_TAG=$1
INPUT_DO_NOT_FAIL=$2
INPUT_CUCUMBER_PROJECT=$3
INPUT_MAVEN_COMMAND=$4
INPUT_MAVEN_IMAGE=$5
INPUT_NAIS_PROJECT_FOLDER=$6
INPUT_TEST_USER=$7
INPUT_USERNAME=$8

if [[ -z "$USER_AUTHENTICATION" ]]; then
  >&2 echo ::error:: "No USER_AUTHENTICATION (password) for a user ([a-z]123456 username) is configured"
  exit 1;
fi

if [[ -z "$TEST_USER_AUTHENTICATION" ]]; then
  >&2 echo ::error:: "No TEST_USER_AUTHENTICATION for for the test user (z123456)is configured"
  exit 1;
fi

cd "$RUNNER_WORKSPACE" || exit 1;
pwd
ls -la
echo "goto $INPUT_CUCUMBER_PROJECT"
cd "$INPUT_CUCUMBER_PROJECT" || exit 1

find . -type f -name "*.json" | grep -e main.json -e feature.json -e q..json
echo "running cucumber tests from $PWD"
pwd

if [[ "$GITHUB_REF" == "refs/heads/main" ]]; then
  ENVIRONMENT=main
else
  ENVIRONMENT=feature
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

PROJECT_NAIS_FOLDER="-DPROJECT_NAIS_FOLDER=/usr/src/mymaven/$INPUT_NAIS_PROJECT_FOLDER"

RUN_ARGUMENT="--rm -v $PWD:/usr/src/mymaven -v $HOME/.m2:/root/.m2 -w /usr/src/mymaven $INPUT_MAVEN_IMAGE mvn"
MAVEN_ARGUMENTS="-e -DENVIRONMENT=$ENVIRONMENT -DUSERNAME=$INPUT_USERNAME -DTEST_USER=$INPUT_TEST_USER $PROJECT_NAIS_FOLDER $CUCUMBER_FILTER $SKIP_MAVEN_FAILURES"

echo "docker run: $RUN_ARGUMENT $INPUT_MAVEN_COMMAND"
echo "maven args: $MAVEN_ARGUMENTS"

AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION -DPIP_AUTH=$PIP_USER_AUTHENTICATION"

# shellcheck disable=SC2046
docker run $(echo "$RUN_ARGUMENT $INPUT_MAVEN_COMMAND $MAVEN_ARGUMENTS $AUTHENTICATION" | sed "s/'//")

if [[ -z "$INPUT_OPTIONAL_MAVEN_COMMAND" ]]; then
  echo no optional maven command are provided. additional command is not executed...
else
  # shellcheck disable=SC2046
  docker run $(echo "$RUN_ARGUMENT $INPUT_OPTIONAL_MAVEN_COMMAND" | sed "s/'//")
fi
