#!/bin/bash
set -e


if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd

if [ -z "$INPUT_MAVEN_IMAGE" ]; then
  mvn -B dependency:tree | tee .dependency-tree
else
  docker run --rm -v "$PWD":/usr/src/mymaven -v "$HOME"/.m2:/root/.m2 -w /usr/src/mymaven \
    "$INPUT_MAVEN_IMAGE" mvn -B dependency:tree | tee .dependency-tree
fi

cat .dependency-tree | grep BUILD | grep -c SUCCESS # fails if count is 0

DEPENDENCIES=$(cat .dependency-tree | grep "\[INFO]" | grep -e "\- " -e "+-")
COUNT=$(echo "$DEPENDENCIES" | grep -c SNAPSHOT || true)

echo "Found $COUNT SNAPSHOT dependencies"

if [ "$COUNT" -gt 0 ]
  then
    >&2 echo "::error No SNAPSHOT dependencies allowed"
    exit 1;
fi
