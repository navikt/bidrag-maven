# bidrag-actions
Github Actions spesialisert for team bidrag

### Continuous integration
![](https://github.com/navikt/bidrag-actions/workflows/build%20actions/badge.svg)

### Hovedregel for design:
Alt blir utført av bash-scripter slik at det enkelt kan testes på reell kodebase uten å måtte bygge med github. Alle "actions" som trenger input får
dette som form av tekst skrevet til enkle filer på filsystemet og dette angis som inputs til hver action (som blir oversatt til miljøvariabler i
script)

Utenom miljøvariabler for filnavn, så finnes også miljøvariabler for autentisering (når action trenger dette), eks: `GITHUB_TOKEN`, samt miljøvariabler
for commit og tag meldinger i tag-and-commit action.

Andre sider ved design av disse "actions", er at de er laget for å kjøre sammen. Dvs. at enkelte actions produserer filer som kan brukes av andre
"actions". 

#### Sterke koblinger mellom actions:

Noen av actions har sterke koblinger i form av at de produserer filer som påvirker hvordan andre actions oppfører seg. For at filene som produseres
skal være synlig av andre "actions", så må de være beskrevet i samme jobb.

 sterke koblinger | beskrivelse 
------------------|-------------
 `release-prepare-mvn-pkg` -> `release-verify-auto-deploy` | `release-prepare-mvn-pkg` lager fil til `release-verify-auto-deploy`
 `release-prepare-mvn-pkg` -> `release-mvn-pkg` | `release-prepare-mvn-pkg` lager fil til `release-mvn-pkg`
 `release-prepare-mvn-pkg` -> `git-tag-n-commit-mvn-deploy` | `release-prepare-mvn-pkg` lager fil til `git-tag-n-commit-mvn-deploy`

Det er lagt inn en workflow for å bygge alle actions med npm og ncc. Derfor er det bare filene `/<action>/index.js` og `/<action>/<bash>.sh` som skal
endres når man skal forandre logikk i "action".

### Changelog

Versjon                   | Endringstype      | Beskrivelse
--------------------------|-------------------|------------
v1-maven-cucumber-backend | new release cycle | `maven-cucumber-backend`: nye inputs (se `action.yaml`), samt feature branch for cucumber 
v5.1.0                    | Opprettet         | `maven-cucumber-backend`: action for å kjøre cucumber integration tests på en "self-hosted" GitHub Runner
v5.0.0                    | Slettet/Endret    | `verify-mvn-dependencies` -> `maven-verify-dependencies`: docker image for maven, og feil hvis ikke kjøring er SUCCESS
v5.0.0                    | Slettet/Opprettet | `setup-maven` -> `maven-setup`
v4.0.7                    | Endret            | `git-commit`: no echo statement
v4.0.6                    | Endret            | `release-prepare-mvn-pkg`: trimming whitespaces on release numbers
v4.0.5                    | Endret            | `bidrag-actions/release-mvn-pkg` will show error stack traces when maven failures
v4.0.4                    | Endret            | optional input folder on `release-mvn-pkg`, `release-prepare-mvn-pkg`, and `verify-mvn-dependencies`
v4.0.3                    | Endret            | `setup-maven`: repository `fp-felles` -> `maven-release`
v4.0.2                    | Endret            | Navigation to src folder only when set
v4.0.1                    | Endret            | Added optional src folder to action
v4.0.0                    | Endret            | `git-tag-n-commit` -> `git-tag-n-commit-mvn-deploy`
v4.0.0                    | Opprettet         | `git-tag`
v3.0.1                    | Endret            | `git-tag-n-commit`: minor refac in `git.sh`
v3.0.0                    | Endret            | `tag-and-commit` -> `git-tag-n-commit`
v3.0.0                    | Opprettet         | `git commit`
v2.0.1                    | Endret            | Messages and git diff vs git status
v2.0.0                    | Endret            | `tag-and-commit`: Enhanced with more control over execution
v1.0.1                    | Endret            | `verify-mvn-dependencies`: `run grep -c "or" true` to allow fast failing
v1.0.0                    | Opprettet         | Actions after valid maven packages on github
