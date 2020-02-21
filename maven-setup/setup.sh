#!/bin/bash
set -e

echo "Setup maven"

MAVEN_REPO=~/.m2
MAVEN_SETTINGS="<settings>
    <servers>
        <server>
           <id>maven-release</id>
           <username>$GITHUB_ACTOR</username>
           <password>$GITHUB_TOKEN</password>
      </server>
    </servers>
  <profiles>
    <profile>
      <id>default</id>
      <repositories>
        <repository>
          <id>central</id>
          <name>Maven central</name>
          <url>https://repo.maven.apache.org/maven2</url>
        </repository>
        <repository>
          <id>maven-release</id>
          <name>GitHub felles Apache Maven Packages</name>
          <url>https://maven.pkg.github.com/navikt/maven-release/</url>
        </repository>
      </repositories>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>default</activeProfile>
  </activeProfiles>
</settings>
"

if [ -d "$MAVEN_REPO" ]; then
  echo "Using existing $MAVEN_REPO"
else
  echo "Creating $MAVEN_REPO"
  mkdir "$MAVEN_REPO"
fi

echo "$MAVEN_SETTINGS" > "$MAVEN_REPO"/settings.xml
