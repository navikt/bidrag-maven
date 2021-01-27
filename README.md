# bidrag-maven
Github maven Actions spesialisert for team bidrag

### Continuous integration
![](https://github.com/navikt/bidrag-maven/workflows/build%20actions/badge.svg)

### Hovedregel for design:
Alt blir utført av bash-scripter slik at det enkelt kan testes på reell kodebase uten å måtte bygge med github.

Man må også sette miljøvariabel for autentisering, eks: `GITHUB_TOKEN`

Det er lagt inn en workflow for å bygge alle actions med npm og ncc. Derfor er det bare filene `/<action>/index.js` og `/<action>/<bash>.sh` som skal
endres når man skal forandre logikk i "action".

### Relase log

Versjon | Endringstype | Beskrivelse
----|---|---
v5.1.0 | Endret | `cucumber-backend`: removed hard coding of NAIS_PROJECT_FOLDER, can be specified - defaults to apps 
v5.0.0 | Endret | `cucumber-backend`: environment is main or feature (the configurations of these determine namespace)
v4.0.0 | Endret | `setup`: dynamic configuration using repositories as input argument
v3.0.1 | Endret | `cucumber-backend`: streamlined for cucumber-testing of simple repository and use of navikt/bidrag-integration/cucumber-clone
v3.0.0 | Endret | `cucumber-backend`: run cucumber without cloning and with nais configuration 
v2.1.2 | Endret | `verify-dependencies`: new action core and run `verify.sh` from sub directory
v2.1.1 | Endret | `cucumber-backend`: new action core and fix of echo statement
v2.1.0 | Endret | `cucumber-backend`: run from workspace true/false
v2.0.0 | Endret | `cucumber-backend`: run test without tag and add optional maven command after first run
v1.0.5 | Endret | la til credentials i settings.xml for github-package-registry-navikt
v1.0.4 | Endret | fjernet maven prefiks i action mapper
v1.0.3 | Endret | `cucumber-backend`: will mirror feature-branch name when testing in namespace q1
v1.0.2 | Endret | `verify-dependencies`: ommit " when doing logging with the echo command
v1.0.1 | Endret | `cucumber-backend`: fix use of optional input "pip_user" 
v1 | new release cycle | `cucumber-backend`: nye inputs (se `action.yaml`), samt feature branch for cucumber 
