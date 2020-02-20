#!/bin/bash
set -e


if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd
env

if [ -z "$INPUT_MAVEN_BINARY" ]; then
  mvn -B dependency:tree | tee .dependency-tree
else
  "$INPUT_MAVEN_BINARY" -B dependency:tree | tee .dependency-tree
fi

DEPENDENCIES=$(cat .dependency-tree | grep "\[INFO]" | grep "\- ")
COUNT=$(echo "$DEPENDENCIES" | grep -c SNAPSHOT || true)

echo "Found $COUNT SNAPSHOT dependencies"

if [ "$COUNT" -gt 0 ]
  then
    >&2 echo "::error No SNAPSHOT dependencies allowed"
    exit 1;
fi
