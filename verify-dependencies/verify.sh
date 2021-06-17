#!/bin/bash
set -e

if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd

mvn -B dependency:tree | tee .dependency-tree

cat .dependency-tree | grep BUILD | grep -c SUCCESS > /dev/null # fails if count is 0

DEPENDENCIES=$(cat .dependency-tree | grep "\[INFO]" | grep -e "\- " -e "+-")
COUNT=$(echo "$DEPENDENCIES" | grep -c SNAPSHOT || true)

echo "Found $COUNT SNAPSHOT dependencies"

if [ "$COUNT" -gt 0 ]
  then
    >&2 echo ::error No SNAPSHOT dependencies allowed
    exit 1;
fi
