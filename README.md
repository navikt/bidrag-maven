# bidrag-maven
Github maven Actions spesialisert for team bidrag

### Continuous integration
![](https://github.com/navikt/bidrag-maven/workflows/build%20actions/badge.svg)

### Hovedregel for design:
Alt blir utført av bash-scripter slik at det enkelt kan testes på reell kodebase uten å måtte bygge med github.

Man må også sette miljøvariabel for autentisering, eks: `GITHUB_TOKEN`

Det er lagt inn en workflow for å bygge alle actions med npm og ncc. Derfor er det bare filene `/<action>/index.js` og `/<action>/<bash>.sh` som skal
endres når man skal forandre logikk i "action".

### Changelog

Versjon | Endringstype      | Beskrivelse
--------|-------------------|------------
v1.0.4  | Endret            | fjernet maven prefiks i action mapper
v1.0.3  | Endret            | `maven-cucumber-backend`: will mirror feature-branch name when testing in namespace q1
v1.0.2  | Endret            | `maven-verify-dependencies`: ommit " when doing logging with the echo command
v1.0.1  | Endret            | `maven-cucumber-backend`: fix use of optional input "pip_user" 
v1      | new release cycle | `maven-cucumber-backend`: nye inputs (se `action.yaml`), samt feature branch for cucumber 
