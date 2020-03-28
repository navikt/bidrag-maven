#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1)  Hvis det er en "release"-kandidat
# 1a) Konfigurerer git, AUTHOR_EMAIL og AUTHOR_NAME blir satt av index.js (javascript delen av avtion)
# 1b) commit endringer i INPUT_COMMIT_PATTERN
# 1c) tag release med INPUT_TAG_MESSAGE
#
############################################

INPUT_COMMIT_MESSAGE=$1
INPUT_TAG_MESSAGE=$2
INPUT_PATTERN=$3
INPUT_IS_RELEASE_CANDIDATE=$4
INPUT_RELEASE_VERSION=$5

if [ "$INPUT_IS_RELEASE_CANDIDATE" = "true" ]
then
  git remote set-url origin https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
  git config --global user.email "$AUTHOR_EMAIL"
  git config --global user.name "$AUTHOR_NAME"

  echo "Tagging new version with: $INPUT_RELEASE_VERSION"
  echo "Tagging release with tag message: $INPUT_TAG_MESSAGE"

  git tag -a "$INPUT_RELEASE_VERSION" -m "$INPUT_TAG_MESSAGE"
  git push origin "$INPUT_RELEASE_VERSION"

  echo "Commiting changes with commit message: $INPUT_COMMIT_MESSAGE"

  git add "$INPUT_PATTERN"
  git commit -m "$INPUT_COMMIT_MESSAGE"
  git status | grep -v "Your branch is" | grep -v "Changes not staged" | grep -v "(use \"git"
  git push
else
    echo "Not a release candidate, nothing will be committed or tagged..."
fi
