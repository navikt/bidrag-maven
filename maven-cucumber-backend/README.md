# bidrag-actions/maven-cucumber-backend

This action will checkout and run cucumber integration tests for bidrag-cucumber-backend. If a folder already exists for bidrag-dokument-backend, it
will be deleted.

Requires a runner which can perform shell scripts on a docker image with java and maven to run the integration tests. It must also have nodejs on its
classpath to be able to run this action

The action requires four inputs, see action.yml:
- the maven image where the integration tests are to run
- the cucumber tag determining what tests to run
- the username of the nav user running the cucumber tests
- the username of the test user used in the cucumber tests

In addition to direct inputs, some environment variables must be provided:
- USER_AUTHENTICATION: the password belonging to the user stated in the input
- TEST_USER_AUTHENTICATION: the password belonging to the test user stated in the input

When cucumber tag is @bidrag-sak, the following must also be provided:
- a username for the pip user, (aka. `srv<user>`)
- PIP_USER_AUTHENTICATION: the password for this server user
