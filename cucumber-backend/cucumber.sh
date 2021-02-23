#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter input argumenter
# 2) sjekker om miljøet har passord for testbruker
# 3) går til $RUNNER_WORKSPACE og til $INPUT_GITHUB_PROJECT for å nå cucumber koden
# 4) setter maven argumenter ihht til input argumenter
#    - CUCUMBER_FILTER_TAGS for å filtrere bort cucumber tester settes alltid til "not @ignored" og evt. nais applikasjon
#    - INPUT_DO_NOT_FAIL != true
#      kjører mvn INPUT_MAVEN_COMMAND -e på <cucumber-github project> i et docker image med all konfigurasjon for
#      integeasjonstesting og feiler hvis det er fail i integrasjonstestene
#    - INPUT_DO_NOT_FAIL == true
#      kjører mvn INPUT_MAVEN_COMMAND -e på <cucumber-github project> i et docker image med all konfigurasjon for
#      integeasjonstesting uten å feile ved testfeil
# 5) Utfører mvn kommando med parametre som gitt
# 6) Når valgfri maven kommando er oppgitt, så kjøres også denne med docker
#
############################################
INPUT_CUCUMBER_TAG=$1
INPUT_DO_NOT_FAIL=$2
INPUT_GITHUB_PROJECT=$3
INPUT_MAVEN_COMMAND=$4
INPUT_RELATIVE_JSON_PATH=$5
INPUT_USERNAME=$6

if [[ -z "$TEST_USER_AUTHENTICATION" ]]; then
  >&2 echo ::error:: "No TEST_USER_AUTHENTICATION for for the test user (z123456)is configured"
  exit 1;
fi

cd "$RUNNER_WORKSPACE" || exit 1;

echo "goto $INPUT_GITHUB_PROJECT"
cd "$INPUT_GITHUB_PROJECT" || exit 1

CUCUMBER_FILTER_TAGS="not @ignored"

if [[ -z "$INPUT_CUCUMBER_TAG" ]]; then
  echo no cucumber tag is provided, running all tags except @ignored
else
  CUCUMBER_FILTER_TAGS="@$INPUT_CUCUMBER_TAG and not @ignored"
fi

env | sort | grep CUCUMBER

SKIP_MAVEN_FAILURES=""

if [[ "$INPUT_DO_NOT_FAIL" == "true" ]]; then
  SKIP_MAVEN_FAILURES="-Dmaven.test.failure.ignore=true"
else
  echo will fail if integrationstests have errors
fi

MAVEN_ARGUMENTS="-e -DUSERNAME=$INPUT_USERNAME -DINTEGRATION_INPUT=$INPUT_RELATIVE_JSON_PATH $SKIP_MAVEN_FAILURES"

echo "CUCUMBER_FILTER_TAGS=$CUCUMBER_FILTER_TAGS"
echo "maven with args: $INPUT_MAVEN_COMMAND $MAVEN_ARGUMENTS"
which mvn

AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION -DPIP_AUTH=$PIP_USER_AUTHENTICATION"

mvn $( echo "$INPUT_MAVEN_COMMAND $MAVEN_ARGUMENTS $AUTHENTICATION" | tr -d "'" )

if [[ -z "$INPUT_OPTIONAL_MAVEN_COMMAND" ]]; then
  echo no optional maven command are provided. additional command is not executed...
else
  docker run $(echo "$RUN_ARGUMENT $INPUT_OPTIONAL_MAVEN_COMMAND" | sed "s/'//")
fi
