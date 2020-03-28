# bidrag-actions/release-mvn-pkg

En github action som vil legge en ny maven artefakt i github packages for navikt.

Det forventes at steget blir kjørt på en linux/unix maskin og har installert maven.
Prosjektet må derfor også bygges med maven.

Det er forventet at prosjektet har blitt klargjort for en release og at den nye
SNAPSHOT-versjonen er å finne i filsystemet, se inputs under `action.yml`.

Det som blir utført er en `mvn deploy` og etterpå settes versjon (`mvn versions:set`)
med den nye snapshot versjonen lest fra fil
