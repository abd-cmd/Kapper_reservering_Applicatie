---
trigger: always_on
---

## N8N  

Voor een gestroomlijnde samenwerking met n8n hanteren we de volgende regels (rules). Deze zorgen ervoor dat automatiseringen betrouwbaar zijn en de security gewaarborgd blijft:
1. Architectuur: De "Proxy" Regel
* Geen Directe Frontend Aanroepen: De frontend (React) roept nooit direct een n8n webhook aan. Dit stelt namelijk je n8n URL en credentials bloot.
* Edge Function Brug: Gebruik altijd een Supabase Edge Function als veilige bridge. De Edge Function controleert de gebruiker (JWT) en stuurt het verzoek pas daarna door naar n8n.
2. Security & Authenticatie
* Basic Auth: Alle n8n webhooks moeten beveiligd zijn met Basic Authentication.
* Secrets Management: Gebruik de omgevingsvariabelen VITE_N8N_USERNAME en VITE_N8N_PASSWORD. Deze mogen nooit in de code staan, maar moeten in Supabase Secrets worden opgeslagen.
* HTTPS: Gebruik uitsluitend de beveiligde URL's ([N8N-INSTANCE-URL]/...).
3. Database Interactie
* Directe Schrijfacties: n8n mag direct in de Supabase Postgres database schrijven via de Postgres-node.
* Permissions: Gebruik voor n8n bij voorkeur een specifieke database-connectie of de service_role (voorzichtig!), zodat n8n taken kan uitvoeren die buiten de normale gebruikersrechten vallen (zoals bulk-updates of system-wide scraping).
* Schema Hygiëne: Vermijd het aanmaken van "n8n-only" tabellen in het public schema van de database. Probeer gebruik te maken van bestaande structuren. Eventuele tijdelijke hulp-tabellen moeten na gebruik direct worden opgeschoond.
4. Workflow Design (Binnen n8n)
* Foutafhandeling: Elke n8n-workflow moet een response-node hebben. Zorg dat bij een fout de juiste HTTP-statuscode (bijv. 500) wordt teruggestuurd.
* Timeouts: n8n is bedoeld voor taken die langer duren. Gebruik bij hele lange taken een status-veld in de database of stuur een ID terug voor polling.
* Documentatie: Geef elke node in n8n een duidelijke naam en beschrijf bovenaan de workflow wat het doel is.
5. Onderhoud & Opschoning
* Logging: Gebruik de n8n execution log voor debugging, maar zorg dat er geen privacy-gevoelige data (GDPR) onnodig lang in de n8n-geschiedenis blijft staan.
Door deze regels te volgen, houden we n8n als een krachtig en veilig verlengstuk van het portal, zonder dat het een "black box" wordt die de rest van het systeem vervuilt.
