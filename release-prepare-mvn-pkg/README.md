# bidrag-actions/release-prepare-mvn-pkg

This action will prepare a maven artifact to be released. It will get the
release version from the expected SNAPSHOT version of the project. The
SNAPSHOT-version will be bumped, and the release version witt be written
to the pom.xml.

Requires a github runner with maven and a github artifact being built
with maven and runs on an environment which support bash-scripts.

The following outputs will be produced, see inputs in `action.yml`:
- release_version: the release version the deploy should use
- new_snapshot_version: the snapshot version to use after deploy
