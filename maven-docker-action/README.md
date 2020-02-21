# bidrag-actions/maven-build

This action will run maven clean install with a docker image

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires the maven image where maven is going to build. See `action.yaml`. An optional src folder can be added or else the action will
perform in the current working directory.
