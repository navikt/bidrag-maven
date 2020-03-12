#!/bin/bash
set -e

git remote set-url origin https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
git config --global user.email "$AUTHOR_EMAIL"
git config --global user.name "$AUTHOR_NAME"

if [ -z "$INPUT_IS_RELEASE_FILE" ]
then
  echo "No automatic release file is present. Tagging will not be done"
elif [ -f "$INPUT_IS_RELEASE_FILE" ]
then
  if [ -f "$INPUT_TAG_FILE" ]
  then
    TAG_CONTENT=$(cat "$INPUT_TAG_FILE")
    echo "Tagging new version with: $TAG_CONTENT"

    INPUT_COMMIT_MESSAGE=$(echo "$INPUT_COMMIT_MESSAGE" | sed "s/{}/$TAG_CONTENT/")

    if [ -z $INPUT_TAG_MESSAGE ]
    then
      >&2 echo ::error No message supplied for the tag!
      exit 1;
    fi

    INPUT_TAG_MESSAGE=$(echo "$INPUT_TAG_MESSAGE" | sed "s/{}/$TAG_CONTENT/")

    echo "Tagging release with tag message: $INPUT_TAG_MESSAGE"
    git tag -a "$TAG_CONTENT" -m "$INPUT_TAG_MESSAGE"
    git push origin "$TAG_CONTENT"
  else
      >&2 echo ::error $INPUT_TAG_FILE is not present!
      exit 1;
  fi
else
  echo "No file for automatic release is present, will not release"
fi

if ! git diff --quiet
then
  git diff --name-status
  echo "Commiting changes with commit message: $INPUT_COMMIT_MESSAGE"

  git add "$INPUT_PATTERN"
  git commit -m "$INPUT_COMMIT_MESSAGE"
  git push
else
  echo "No files staged for commit."
fi
