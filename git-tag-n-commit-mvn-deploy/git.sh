#!/bin/bash
set -e

git remote set-url origin https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
git config --global user.email "$AUTHOR_EMAIL"
git config --global user.name "$AUTHOR_NAME"

if [ "$INPUT_IS_RELEASE_CANDIDATE" = "true" ]
then
  echo "Tagging new version with: $INPUT_RELEASE_VERSION"

  if [ -z $INPUT_TAG_MESSAGE ]
  then
    >&2 echo ::error No message supplied for the tag!
    exit 1;
  fi

  echo "Tagging release with tag message: $INPUT_TAG_MESSAGE"
  git tag -a "$TAG_CONTENT" -m "$INPUT_TAG_MESSAGE"
  git push origin "$TAG_CONTENT"
else
  git reset --hard
fi

if ! git diff --quiet
then
  git diff status
  echo "Commiting changes with commit message: $INPUT_COMMIT_MESSAGE"

  git add "$INPUT_PATTERN"
  git commit -m "$INPUT_COMMIT_MESSAGE"
  git push
else
  echo "No files staged for commit."
fi
