---
trigger: always_on
---

## VERSIE

Voor het beheer van de softwareversies in het [PROJECT-NAAM]-portal hanteren we een gestructureerde aanpak. Dit zorgt ervoor dat de gebruiker altijd ziet welke versie ze draaien en dat we wijzigingen goed kunnen bijhouden.
1. Waar staat de versie?
In dit project wordt de versie op twee plaatsen bijgehouden:
* src/version.json: Dit is de bron van waarheid voor de gebruikersinterface. De Sidebar.tsx leest dit bestand uit om de versie onderaan het menu te tonen (bijv. v1.2).
* package.json: Hier staat de versie voor de build-tools en npm (bijv. 2.0.0).
2. Versie-update Rules
Wanneer je een nieuwe build maakt of belangrijke wijzigingen doorvoert, volg je deze regels:
1. Handmatige Update in version.json:
    * Pas de versie in src/version.json aan.
    * Minor update (bugfixes/kleine UI edits): Verhoog het getal achter de punt (bijv. 1.2 naar 1.3).
    * Major update (nieuwe modules/grote herstructurering): Verhoog het getal voor de punt (bijv. 1.2 naar 2.0).
2. Synchronisatie:
    * Zorg dat de versie in package.json bij voorkeur in de buurt blijft van de versie in version.json, hoewel de laatstgenoemde leidend is voor de weergave in de app.
3. Deploy & Cache:
    * Na een versie-update moet de app opnieuw gebuild worden (npm run build).
    * Omdat het een PWA is, zal de Service Worker (sw.js) detecteren dat er een nieuwe versie is. De volgende keer dat de gebruiker de app opent, krijgt deze de hoogste versie te zien.
3. Database Versies (Migraties)
Voor de backend (Supabase) gebruiken we een andere vorm van versiebeheer:
* Migratie-bestanden: Elke wijziging aan de database krijgt een tijdstempel in de bestandsnaam (bijv. 20260103110400_initial_schema.sql).
* Volgorde: Migraties worden altijd chronologisch uitgevoerd. Pas nooit een oude migratie aan die al is doorgevoerd op productie; maak in plaats daarvan een nieuwe aan.

## PROACTIEVE EXECUTIE (MCP & CLI)

Ik neem als AI-agent de volledige verantwoordelijkheid voor de technische uitvoering. Ik delegeer NOOIT technische taken terug naar de gebruiker als ik de tools (MCP of CLI) heb om het zelf uit te voeren.

1. De "Zero Delegation" Regel
* **Geen Verzoeken:** Ik vraag nooit "Zou jij dit commando willen draaien?" of "Wil je dit even pushen?". Ik voer het direct zelf uit.
* **Directe Actie:** Bij elke wijziging aan de database of Edge Functions voer ik proactief de bijbehorende actie uit (`apply_migration`, `execute_sql`, `supabase functions deploy`).
* **Authenticated Environment:** Nu de Supabase CLI is ingelogd, gebruik ik deze proactief voor alle infra-taken.

2. Database & Infra Management
* **DDL via Migraties:** Schema-wijzigingen worden direct doorgevoerd via `apply_migration` OF de CLI (`supabase db push`).
* **Code-Sync:** Lokale migratiebestanden worden direct bijgewerkt om 100% in sync te blijven met de live status.
* **Storage & Buckets:** Ik maak buckets en RLS-policies proactief aan via SQL-scripts zonder om bevestiging te vragen.

3. Edge Functions
* **Auto-Deploy:** Zodra ik de code van een Edge Function aanpas, deploy ik deze onmiddellijk via de CLI (`supabase functions deploy [naam]`).
* **Fout-Interruptie:** Als een deploy faalt, analyseer ik de fout en probeer ik het op te lossen (bijv. ontbrekende secrets instellen) in plaats van de taak terug te geven.

4. TypeScript & Types
* **Type Generatie:** Na elke database-wijziging genereer ik direct nieuwe types (`supabase gen types typescript --local`) zodat de frontend compileert zonder fouten.

## LOKALE ONTWIKKELING (Localhost)
* **Altijd Actief:** De lokale development server (`npm run dev`) moet **ALTIJD** draaien zodra ik actief ben.
* **Proactieve Start:** Als ik merk dat `localhost:5173` niet reageert, start ik deze direct op in de achtergrond (`SafeToAutoRun: true`).

5. Rapportage-Style
* Ik rapporteer wat ik heb gedaan: "Ik heb de tabel aangemaakt en de functie voor je gedeployed. Je kunt het nu direct testen."
* Ik vraag alleen om actie als er een fysiek/extern blok is dat ik onmogelijk kan oplossen (bijv. een device dat niet aanstaat).

6. Veiligheid & Context (Project ID Check)
* **Verificatie:** Voordat ik een destructieve of kritieke MCP-actie uitvoer op de database, verifieer ik altijd of de actieve `project_ref` uit `supabase/.temp/project-ref` of `.env` overeenkomt met de MCP-context.
* **Scoped Access:** Ik werk uitsluitend op het project dat overeenkomt met de lokale bestandsstructuur om verwarring tussen omgevingen te voorkomen.
