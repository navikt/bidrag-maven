#!/bin/bash
set -e

if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd

if [ -z "$INPUT_MAVEN_IMAGE" ]; then
  mvn -B clean install
else
  docker run --rm -v "$PWD":/usr/src/mymaven -v "$HOME"/.m2:/root/.m2 -w /usr/src/mymaven \
    "$INPUT_MAVEN_IMAGE" mvn -B clean install
fi
