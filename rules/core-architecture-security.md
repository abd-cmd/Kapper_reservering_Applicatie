---
trigger: always_on
---

# TECHNOLOGY STACK & CORE ARCHITECTURE

Dit document definieert de technische fundamenten en beveiligingsregels van de [PROJECT-NAAM]-portal.

## DE STACK (Technologieën)
1. **Frontend:** React (v18), Vite, TypeScript, Vanilla CSS.
2. **Mobiel/PWA:** Capacitor (voor iOS/Android), Vite PWA Plugin (Offline & Service Workers).
3. **Backend:** Supabase (Auth, Storage, Realtime, PostgreSQL).
4. **AI-Logic:** Supabase Edge Functions (Deno/TypeScript) acteren als proxy.
5. **AI-Modellen:** Google Vertex AI ([GCP-REGIO]): `gemini-2.5-flash` & `text-embedding-004`.
6. **Automatisering:** n8n (veilig aangeroepen via Edge Functions).

## GDPR & PRIVACY BY DESIGN
* **Data Residentie:** AI-verwerkingen en data-opslag vinden uitsluitend plaats in de EU (Regio: [GCP-REGIO]).
* **Isolatie:** Row Level Security (RLS) is verplicht op alle tabellen om strikte scheiding tussen gebruikersdata te garanderen.
* **Minimalisme:** Sla alleen functionele eind-data op. Vermijd proces-logs met PII (Personally Identifiable Information).
* **Documentbewaring:** Voor RAG-functionaliteit is het bewaren van bronbestanden toegestaan als functionele data, mits beveiligd met RLS.
* **Verwijdering:** Gebruik `CASCADE deletes` voor gekoppelde AI-data (embeddings) om volledige verwijdering te garanderen.

---

## FRONTEND BACKEND

We vormen een strikte scheiding tussen de frontend en de backend om de applicatie veilig, snel en schaalbaar te houden. Hier zijn de regels ("rules") voor hoe we hiermee omgaan:

1. Frontend Rules (React & Vite)
De frontend is verantwoordelijk voor de gebruikerservaring en visuele logica.
* Design Systeem: We gebruiken Vanilla CSS voor alle styling. Gebruik de tokens en variabelen gedefinieerd in index.css.
* TypeScript: Alles wordt geschreven in TypeScript met strikte interfaces voor API-responses en props.
* State Management: Gebruik React Context (zoals AuthContext) voor globale staat en useState voor lokale zaken.
* Beveiliging: De frontend mag nooit directe database-queries uitvoeren. Gebruik altijd de geconfigureerde supabase client.
* PWA & Mobiel: Houd rekening met de mobiele weergave (Capacitor). Gebruik safe-area variabelen.
* Headers: Elke functie-aanroep MOET expliciet de `Authorization` én `apikey` headers meesturen.

2. Backend Rules (Supabase & Edge Functions)
De backend beheert de data-integriteit, beveiliging en zware verwerkingen.
* Row Level Security (RLS): Elke nieuwe tabel MOET RLS hebben. Schrijf expliciete policies op basis van auth.uid().
* Naming Conventions: Gebruik altijd `snake_case` voor tabel- en kolomnamen. Gerelateerde tabellen krijgen een prefix (bijv. `rag_`, `chat_`, `scrape_`).
* Edge Functions (Deno):
    * Gebruik Edge Functions voor AI-aanroepen (Vertex AI) en integraties (zoals n8n).
    * Deployment: Deploy functies ALTIJD met de vlag `--no-verify-jwt`.
    * Authenticatie: De functie controleert ZELF het JWT via een `authClient`. Vereist import: `import { createClient } from "npm:@supabase/supabase-js@2"`;.
    * Database Access: Gebruik een aparte `adminClient` (geïnitialiseerd met Service Role Key) voor database-interacties. 
    * CORS: Gebruik de standaard corsHeaders.
* Database Migraties: Wijzigingen aan de structuur (DDL) verlopen altijd via migratiebestanden in supabase/migrations/.

3. Communicatie tussen Front- en Backend
* API Calls: Gebruik supabase.functions.invoke() voor veilige aanroepen.
* Real-time: Gebruik Supabase Realtime alleen als data direct moet worden bijgewerkt (bijv. in de chat).
* Data Transformatie: De backend stuurt "schone" JSON; de frontend verzorgt de weergave.

4. Rollen en Rechten (Permissions)
* De backend bepaalt de rechten via de user_roles en roles tabellen.
* De frontend gebruikt deze data om modules te tonen of te verbergen, maar de backend blijft de gatekeeper via RLS.

---

## SUPABASE

Supabase is het "hart" van de infrastructuur.

1. Database & Migraties (Schema Management)
* Infrastructure as Code: Breng nooit handmatige wijzigingen aan in het Supabase Dashboard zonder migratiebestand.
* Migratie-bestanden: Gebruik the supabase/migrations map voor alle DDL wijzigingen.
* Squashing: Grote wijzigingen worden periodiek samengevoegd tot een initiële migratie.

2. Beveiliging: RLS & Policies
* RLS is Heilig: Elke tabel in het public schema MOET RLS ingeschakeld hebben.
* Policies:
    * Gebruiker: Mag alleen eigen data inzien (auth.uid() = user_id).
    * Admin: Gebruik de helperfunctie public.is_admin(auth.uid()).
    * Service Role: Gebruik de service_role uitsluitend binnen Edge Functions voor systeemtaken.

3. Edge Functions (Deno/TypeScript)
* Single Responsibility: Elke functie heeft één specifieke taak.
* Geheimen (Secrets): Gebruik Deno.env.get() voor API-sleutels. Stel deze in via Supabase Secrets.
* Foutafhandeling: Stuur altijd een consistente JSON-response terug inclusief success status.
* JWT Validatie: Controleer altijd de identiteit van de beller via supabase.auth.getUser() met de authClient.

4. Vector Search & AI (PGVector)
* Extensies: De vector extensie moet geactiveerd zijn.
* Zoekfuncties: Complexere zoekopdrachten verlopen via Database Functions (RPC's) zoals match_rag_embeddings.

5. Frontend Integratie
* Supabase Client: Gebruik de singleton client in src/lib/supabase.ts.
* Types: Update de TypeScript-types regelmatig met `supabase gen types typescript --local`.
* Authenticatie: Gebruik de useAuth hook voor alle identiteitscontroles.

6. Opslag (Storage)
* **Geen Blobs:** Sla NOOIT grote binaire bestanden (PDF, JPG, etc.) op als BLOB/ByteA in de PostgreSQL database.
* **Storage Verplichting:** Gebruik uitsluitend Supabase Storage voor documentopslag.
* **Metadata koppeling:** Sla in de database altijd zowel de `storage_path` als de `storage_bucket` op voor elke referentie naar een bestand.
* **RLS Policies:** Zorg voor strikte RLS-policies op alle buckets; gebruikers mogen alleen bij hun eigen mappen (`auth.uid()`).
* **Unieke Pathnames**: Storage paden moeten voldoen aan: `{user_id-folder}/{timestamp}_{random_suffix}_{sanitized_filename}`.
* **Collision Prevention**: Gebruik altijd een random suffix (bijv. 8 chars) om overschrijvingen bij gelijktijdige uploads te voorkomen.
* **Bestandsnaam Sanitization**: Vervang alle non-alphanumeric tekens (behalve . en -) door underscores in de `storage_path`.
* **Opschoning Verplichting**: Bij het verwijderen van een database record MOET het fysieke bestand in Storage proactief door de code worden gewist.

---

## SECRETS & ENVIRONMENT INVENTORY

Voor een correcte werking van de Edge Functions en de frontend (met name bij project-initialisatie), MOETEN de volgende secrets en variabelen geconfigureerd zijn:

1. **Supabase Core (Edge Functions Secrets):**
   - `SUPABASE_URL`: De API URL van het project.
   - `SUPABASE_ANON_KEY`: De public anon key.
   - `SUPABASE_SERVICE_ROLE_KEY`: De geheime service role key voor systeemtaken.
   - `SUPABASE_DB_URL`: De Postgres string voor directe DB-connecties (bijv. in migraties).

2. **Google Vertex AI (Edge Functions Secrets):**
   - `GCP_PROJECT_ID`: De ID van het Google Cloud Project.
   - `GCP_LOCATION`: Gebruik altijd `[GCP-REGIO]`.
   - `GCP_SERVICE_ACCOUNT_KEY`: De volledige JSON van het Service Account (via Google Cloud Console).

3. **n8n Automation (Edge Functions Secrets):**
   - `VITE_N8N_USERNAME`: Basic Auth username voor n8n webhooks.
   - `VITE_N8N_PASSWORD`: Basic Auth password voor n8n webhooks.

4. **Frontend (.env):**
   - `VITE_SUPABASE_URL`: Gelijk aan de project URL.
   - `VITE_SUPABASE_PUBLISHABLE_KEY`: De publishable key (verplicht voor client-side componenten en Edge Function calls).

**Proactieve Check:** Bij elke nieuwe project-setup dient de AI-agent via het dashboard of CLI (`supabase secrets list`) te verifiëren of deze lijst compleet is.
