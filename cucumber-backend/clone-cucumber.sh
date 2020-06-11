#!/bin/bash
set -x

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter input til script
# 2) går til runner workspace hvis true
# 3) når USE_NAIS_CONFIGURATION er true, lages mappa simple hvor <project>/nais/<q0/q1>.json sjekkes ut
# 4) sletter bidrag-cucumber-backend hvis den finnes fra før
# 5a) ved feature branch
#    - clone bidrag-cucumber-backend, branch=feature (hvis den finnes), hvis ikke brukes master
# 5b) ved master branch
#    - clone bidrag-cucumber-backend master
# 6) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
#
############################################

INPUT_USE_NAIS_CONFIGURATION=$1
INPUT_RUN_FROM_WORKSPACE=$2

if [ "$INPUT_RUN_FROM_WORKSPACE" == "true" ]; then
  cd "$RUNNER_WORKSPACE" || exit;
fi

if [ "$INPUT_USE_NAIS_CONFIGURATION" == "true" ]; then
  CLONE_CUCUMBER_FOLDER=$PWD
  SIMPLE="$RUNNER_WORKSPACE/simple"

  sudo rm -rf "$SIMPLE"
  mkdir "$SIMPLE"
  cd "$SIMPLE" || exit 1;

  git clone -n --depth 1 "https://github.com/$GITHUB_REPOSITORY"
  cd "${GITHUB_REPOSITORY#navikt/}" || exit 1;
  git checkout HEAD nais/q0.json
  git checkout HEAD nais/q1.json

  cd "$CLONE_CUCUMBER_FOLDER" || exit 1;
fi

echo "Working directory:"
pwd

sudo rm -rf bidrag-cucumber-backend

if [[ "$GITHUB_REF" != "refs/heads/master" ]]; then
  FEATURE_BRANCH=${GITHUB_REF#refs/heads/}
  # shellcheck disable=SC2046
  IS_API_CHANGE=$(git ls-remote --heads $(echo "https://github.com/navikt/bidrag-cucumber-backend $FEATURE_BRANCH" | sed "s/'//g") | wc -l)

  if [[ $IS_API_CHANGE -eq 1 ]]; then
    echo "Using feature branch: $FEATURE_BRANCH"
    # shellcheck disable=SC2086
    git clone --depth 1 --branch=$FEATURE_BRANCH https://github.com/navikt/bidrag-cucumber-backend
  else
    echo "Using /refs/heads/master"
    git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
  fi
else
  echo "Using /refs/heads/master"
  git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
fi
