# bidrag-actions
Github Actions spesialisert for team bidrag

### Hovedregel for design:
Alt blir utført av bash-scripter slik at det enkelt kan testes på reell kodebase uten å måtte bygge med github. Alle "actions" som trenger input får
dette som form av tekst skrevet til enkle filer på filsystemet og dette angis som inputs til hver action (som blir oversatt til miljøvariabler i
script)

Utenom miljøvariabler for filnavn, så finnes også miljøvariabler for autentisering (når action trenger dette), eks: `GITHUB_TOKEN`, samt miljøvariabler
for commit og tag meldinger i tag-and-commit action.

Andre sider ved design av disse "actions", er at de er laget for å kjøre sammen. Dvs. at enkelte actions produserer filer som kan brukes av andre
"actions". Det er blant annet en sterk knytning mellom `release-verify-auto-deploy` og `git-tag-n-commit`. Hvis auto-deploy ikke kan gjøres vil ikke
noen tagging av release gjøres. Med andre ord, så er noen av disse "actions" sterk knyttet.

### Continuous integration
![](https://github.com/navikt/bidrag-actions/workflows/build%20actions/badge.svg)

Det er lagt inn en workflow for å bygge alle actions med npm og ncc. Derfor er det bare filene `/<action>/index.js` og `/<action>/<bash>.sh` som skal
endres.
