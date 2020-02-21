# bidrag-actions/maven-docker-action

This action will run maven commands on a docker image

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires the maven image and maven commands to execute. See `action.yaml`. An optional src folder can be added or else the action will
perform in the current working directory.
