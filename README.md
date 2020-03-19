# bidrag-actions
Github Actions spesialisert for team bidrag

### Continuous integration
![](https://github.com/navikt/bidrag-actions/workflows/build%20actions/badge.svg)

### Hovedregel for design:
Alt blir utført av bash-scripter slik at det enkelt kan testes på reell kodebase uten å måtte bygge med github. Noen "actions" produserer "output" som
må settes som inputs til hver action andre actions (se `action.yml` for en action)

Utenom miljøvariabler for filnavn, så finnes også miljøvariabler for autentisering (når action trenger dette), eks: `GITHUB_TOKEN`, samt miljøvariabler
for commit og tag meldinger i tag-and-commit action.

Andre sider ved design av disse "actions", er at de er laget for å kjøre sammen. Dvs. at enkelte actions lager output som kan brukes av andre "actions". 

#### Sterke koblinger mellom "actions":

Noen av "actions" har sterke koblinger i form av at de produserer outputs som påvirker hvordan andre actions oppfører seg.

produserer output             | output                 | actions som bruker output
------------------------------|------------------------|--------------------------
`release-prepare-mvn-pkg`     | `release_version`      | `release-mvn-pkg`, `release-verify-auto-deploy`
`release-prepare-mvn-pkg`     | `new_snapshot_version` | `release-mvn-pkg`, `release-verify-auto-deploy` 
`release-verify-auto-deployg` | `is_release_candidate` | `release-mvn-pkg`

Det er lagt inn en workflow for å bygge alle actions med npm og ncc. Derfor er det bare filene `/<action>/index.js` og `/<action>/<bash>.sh` som skal
endres når man skal forandre logikk i "action".

### Changelog

Versjon      | Endringstype      | Beskrivelse
-------------|-------------------|------------
v2-git.      | Endret.           | `git-commit`: push without sed communication with file system
v1.0.2-maven | Endret            | `maven-verify-dependencies`: ommit " when doing logging with the echo command
v1-git       | Endret            | `git-tag`: ommit " when doing logging with the echo command 
v1-git       | Endret            | `git-tag-n-commit-mvn-deploy`: ommit " when doing logging with the echo command 
v1-release   | Endret            | `release-mvn-package`: ommit " when doing logging with the echo command 
v1-release   | Endret            | `release-prepare-mvn-package`: ommit " when doing logging with the echo command 
v1-release   | Endret            | `release-verify-auto-deploy`: ommit " when doing logging with the echo command 
v1.0.1-maven | Endret            | `maven-cucumber-backend`: fix use of optional input "pip_user" 
v1-maven     | new release cycle | `maven-cucumber-backend`: nye inputs (se `action.yaml`), samt feature branch for cucumber 
v5.1.1       | Endret            | `release-prepeare-mvn-pkg`: Error stacktrace, logging, and failure checking
v5.1.0       | Opprettet         | `maven-cucumber-backend`: action for å kjøre cucumber integration tests på en "self-hosted" GitHub Runner
v5.0.0       | Slettet/Endret    | `verify-mvn-dependencies` -> `maven-verify-dependencies`: docker image for maven, og feil når maven feiler
v5.0.0       | Slettet/Opprettet | `setup-maven` -> `maven-setup`
v4.0.7       | Endret            | `git-commit`: no echo statement
v4.0.6       | Endret            | `release-prepare-mvn-pkg`: trimming whitespaces on release numbers
v4.0.5       | Endret            | `bidrag-actions/release-mvn-pkg` will show error stack traces when maven failures
v4.0.4       | Endret            | optional input folder on `release-mvn-pkg`, `release-prepare-mvn-pkg`, and `verify-mvn-dependencies`
v4.0.3       | Endret            | `setup-maven`: repository `fp-felles` -> `maven-release`
v4.0.2       | Endret            | Navigation to src folder only when set
v4.0.1       | Endret            | Added optional src folder to action
v4.0.0       | Endret            | `git-tag-n-commit` -> `git-tag-n-commit-mvn-deploy`
v4.0.0       | Opprettet         | `git-tag`
v3.0.1       | Endret            | `git-tag-n-commit`: minor refac in `git.sh`
v3.0.0       | Endret            | `tag-and-commit` -> `git-tag-n-commit`
v3.0.0       | Opprettet         | `git commit`
v2.0.1       | Endret            | Messages and git diff vs git status
v2.0.0       | Endret            | `tag-and-commit`: Enhanced with more control over execution
v1.0.1       | Endret            | `verify-mvn-dependencies`: `run grep -c "or" true` to allow fast failing
v1.0.0       | Opprettet         | Actions after valid maven packages on github
