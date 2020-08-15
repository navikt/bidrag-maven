#!/bin/bash
set -e

######################################################################################
#
# Forutsetninger for script som lager en maven settings.xml
#
# - Maven repositories blir gitt som en kommaseparert liste med mavenrepo: id/navn=url
# - Maven home som skal inneholde setting.xml blir gitt som argument til skript
#
# Følgende skjer i dette skriptet:
# 1) setter inputs og leser kommaseparert liste inn i array
# 2) for hvert innslag i den kommaseparerte lista
#    - lag et <server>...</server> element
#    - lag et <repository>...</repository> element
# 3) legg til server og repository elementene i en settings.xml
# 4) skriver den genererte settings.xml til maven home
#
######################################################################################

INPUT_REPOS=$1
INPUT_MAVEN_HOME=$2

if [ $# -ne 2 ]; then
  echo "Usage: ./setup.sh <repo=https://repo.location>,<annet.repo=https://other.location>...,<...> <path_to_maven_home>"
  exit 1
fi

if [ -z "$INPUT_MAVEN_HOME" ]; then
  MAVEN_HOME=$HOME/.m2
else
  MAVEN_HOME=$INPUT_MAVEN_HOME
fi

IFS=','
read -ra REPOS <<< "$INPUT_REPOS"

IDS=()
REPOS_XML=""
SERVER_XML=""

for repo in "${REPOS[@]}"; do
  NAME=$(echo "$repo" | cut -d'=' -f 1)
  IDS+=("$NAME")
  URL=$(echo "$repo" | cut -d'=' -f 2)

  REPOS_XML="${REPOS_XML}
        <repository>
          <id>$NAME</id>
          <name>$NAME</name>
          <url>$URL</url>
        </repository>"
done

for id in "${IDS[@]}"; do
  SERVER_XML="${SERVER_XML}
    <server>
      <id>$id</id>
      <username>$GITHUB_ACTOR</username>
      <password>$GITHUB_TOKEN</password>
    </server>"
done

MAVEN_SETTINGS="
<settings>
  <servers>$SERVER_XML
  </servers>
  <profiles>
    <profile>
      <id>default</id>
      <repositories>$REPOS_XML
      </repositories>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>default</activeProfile>
  </activeProfiles>
</settings>
"

if [ -d "$MAVEN_HOME" ]; then
  echo "Using existing $MAVEN_HOME"
else
  echo "Creating $MAVEN_HOME"
  mkdir "$MAVEN_HOME"
fi

echo "$MAVEN_SETTINGS" > "$MAVEN_HOME/settings.xml"
