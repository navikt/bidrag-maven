#!/bin/bash
set -e


if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd

if [ -z "$INPUT_MAVEN_BINARY" ]; then
  "$INPUT_MAVEN_BINARY" -B dependency:tree | tee .dependency-tree
else
  echo "no input binary to use"
  exit 1;
fi

DEPENDENCIES=$(cat .dependency-tree | grep "\[INFO]" | grep "\- ")
COUNT=$(echo "$DEPENDENCIES" | grep -c SNAPSHOT || true)

echo "Found $COUNT SNAPSHOT dependencies"

if [ "$COUNT" -gt 0 ]
  then
    >&2 echo "::error No SNAPSHOT dependencies allowed"
    exit 1;
fi
