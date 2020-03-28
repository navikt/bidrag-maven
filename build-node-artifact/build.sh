#!/bin/bash
set -e

echo "Building node artifact: $INPUT_ARTIFACT_FOLDER"

cd "$RUNNER_WORKSPACE/$INPUT_ARTIFACT_FOLDER"

npm install
ncc build index.js
