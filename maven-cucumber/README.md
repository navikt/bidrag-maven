# bidrag-actions/cucumber-jvm

This action will run cucumber integration tests for provided cucumber tags and credentials

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires cucumber tags, maven image and environment. See `action.yaml`. An optional
github repository can also be stated, if not `bidrag-cucumber-backend` will be used.
