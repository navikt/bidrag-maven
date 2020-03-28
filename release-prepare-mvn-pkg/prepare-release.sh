#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) Henter gjeldene snapshot versjon fra pom.xml for å finne release versjon
# 2) Bruker maven til å finne ny snapshot versjon som skrives til fil
# 3) Bruker maven til å oppdatere pom med release versjon som er funnet
#
############################################

if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd

# example, reads current version: 1.2.3-SNAPSHOT from pom.xml
SNAPSHOT_VERSION=$(grep version pom.xml | grep SNAPSHOT)

if [ -z "$SNAPSHOT_VERSION" ]; then
  >&2 echo ::error No snapshot version is found. Unable to determine release version
  exit 1;
fi

# - fetch 1.2.3 of `  <version>1.2.3-SNAPSHOT</version>` version from pom.xml
RELEASE_VERSION=$(echo "$SNAPSHOT_VERSION" | sed 's/version//g' | sed 's/  //' | sed 's/-SNAPSHOT//' | sed 's;[</>];;g' | xargs)

if [ -z "$RELEASE_VERSION" ]; then
  >&2 echo ::error unable to find release version from version tag
  exit 1;
fi

# updates to version 1.2.4-SNAPSHOT (using maven plugin to get the new version)
mvn -B -e release:update-versions

# updates for output: new snapshot version (1.2.4-SNAPSHOT)
NEW_SNAPSHOT_VERSION=$(grep version pom.xml | grep SNAPSHOT |  sed 's/version//g' | sed 's/  //' | sed 's;[</>];;g')

echo ::set-output name=release_version::"$RELEASE_VERSION"
echo ::set-output name=new_snapshot_version::"$NEW_SNAPSHOT_VERSION"
