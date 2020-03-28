#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) Går til angitt mappe (hvis angitt) for utføring av script
# 2) Hvis det ikke er en "release candidate", så avsluttes scriptet uten feil
# 3) Når det er en "release candidate", så oppdateres "maven project object model" (pom.xml) med release versjonj
# 4) Når det er en "release candidate", så kjøres mvn deploy uten testing
# 5) Når det er en "release candidate", så oppdateres "maven project object model" (pom.xml) med ny SNAPSHOT versjon
#
############################################

INPUT_IS_RELEASE_CANDIDATE="$1"
INPUT_NEW_SNAPSHOT_VERSION="$2"
INPUT_RELEASE_VERSION="$3"

if [ ! -z "$INPUT_SRC_FOLDER" ]
then
  cd "$INPUT_SRC_FOLDER"
fi

echo "Working directory"
pwd

if [ "$INPUT_IS_RELEASE_CANDIDATE" != "true" ]
then
  echo "The artifact is not a release candidate..."
  exit 0;
fi

# Prepares the maven artifact with the release version
echo "Setting release version: $INPUT_RELEASE_VERSION"
mvn -B -e versions:set -DnewVersion="$INPUT_RELEASE_VERSION"

echo "Running release"
mvn -B --settings maven-settings.xml deploy -e -DskipTests -Dmaven.wagon.http.pool=false

# Update to new SNAPSHOT version
echo "Setting SNAPSHOT version: $INPUT_NEW_SNAPSHOT_VERSION"
mvn -B versions:set -DnewVersion="$INPUT_NEW_SNAPSHOT_VERSION"
