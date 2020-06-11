#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) Velger rot-katalog for runner workspace når det er angitt
# 2) Sletter bidrag-cucumber-backend hvis den finnes fra før
# 3a) Ved feature branch
#    - clone bidrag-cucumber-backend, branch=feature (hvis den finnes), hvis ikke brukes master
# 3b) Ved master branch
#    - clone bidrag-cucumber-backend master
# 4) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
#
############################################

if [ "$INPUT_RUN_FROM_WORKSPACE" == "true" ]; then
  cd "$RUNNER_WORKSPACE" || exit;
fi

echo "Working directory:"
pwd

sudo rm -rf bidrag-cucumber-backend

if [[ "$GITHUB_REF" != "refs/heads/master" ]]; then
  FEATURE_BRANCH=$(echo "$GITHUB_REF" | sed 's;refs/heads/;;')
  IS_API_CHANGE=$(git ls-remote --heads "https://github.com/navikt/bidrag-cucumber-backend $FEATURE_BRANCH" | wc -l)

  if [[ $IS_API_CHANGE -eq 1 ]]; then
    echo "Using feature branch: $FEATURE_BRANCH"
    git clone --depth 1 --branch=$FEATURE_BRANCH https://github.com/navikt/bidrag-cucumber-backend
  else
    echo "Using /refs/heads/master"
    git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
  fi
else
  echo "Using /refs/heads/master"
  git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
fi
