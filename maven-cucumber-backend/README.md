# bidrag-actions/maven-cucumber-backend

This action will checkout and run cucumber integration tests for bidrag-cucumber-backend. If a folder already exists for bidrag-dokument-backend, it
will be deleted.

Requires a runner which can perform shell scripts and and a docker image with java and maven to run the integration tests.

The action requires two inputs, see action.yml:
- the maven image where the integration tests are to run
- the cucumber tag determining what tests to run

In addition to direct inputs, some environment variables must be provided:
- MAVEN_USER_CREDENTIALS: the credentials of a nav user: `x123456`, with password: `xxxx` (`-DUSERNAME=x123456 -DUSER_AUTH=xxxx`)
- MAVEN_TEST_USER_CREDENTIALS: the credentials of a nav test user: `z123456`, with password: `zzzz` (`-DTEST_USER=z123456 -DTEST_USER_AUTH=zzzz`)

When cucumber tag is @bidrag-sak, the following variables must also be provided:
MAVEN_PIP_USER_CREDENTIALS: the credentials of the pip machinge user: `srvbisys`, with password: `yyyy` (`-DPIP_USER=srvbisys -DPIP_AUTH=yyyy`)
