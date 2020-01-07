#!/bin/bash
mvn -B dependency:tree | tee .dependency-tree

DEPENDENCIES=$(cat .dependency-tree | grep "\[INFO]" | grep "\- ")
COUNT=$(echo "$DEPENDENCIES" | grep -c SNAPSHOT)

echo "Found $COUNT SNAPSHOT dependencies"

if [ "$COUNT" -gt 0 ]
  then
    >&2 echo "::error No SNAPSHOT dependencies allowed"
    exit 1;
fi
