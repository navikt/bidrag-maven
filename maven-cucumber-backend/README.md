# bidrag-actions/maven-cucumber-backend

This action will checkout and run cucumber integration tests for bidrag-cucumber-backend. If a folder already exists for bidrag-dokument-backend, it
will be deleted.

When the action is used on a feature branch, ie not refs/head/master, it will check if a branch named `feature` exists, and if it exists, then use
this branch. If such a feature branch do not exists, then master will be used. When the action is building a master branch, it will always use
refs/head/master as the cucumber branch to run tests on.

Requires a runner which can perform shell scripts on a docker image with java and maven to run the integration tests. It must also have nodejs on its
classpath to be able to run this action

The action requires four inputs, see action.yml:
- the maven image where the integration tests are to run
- the cucumber tag determining what tests to run
- the username of the nav user running the cucumber tests
- the username of the test user used in the cucumber tests

In addition to direct inputs, some environment variables must be provided (GITHUB.secrets):
- USER_AUTHENTICATION: the password belonging to the user stated in the input
- TEST_USER_AUTHENTICATION: the password belonging to the test user stated in the input

When cucumber tag is @bidrag-sak, the following must also be provided:
- a username for the pip user, (aka. `srv<user>`)
- PIP_USER_AUTHENTICATION: the password for this server user (GITHUB.secret)
