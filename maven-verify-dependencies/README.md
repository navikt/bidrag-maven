# bidrag-actions/maven-verify-dependencies

This action will verify that the project object model (pom) contains no SNAPSHOT dependencies.

Requires a a github artifact being build with maven and a docker image of maven can be used when maven binaries are absent.

If a docker image is wanted, the name of the docker image must be supplied
