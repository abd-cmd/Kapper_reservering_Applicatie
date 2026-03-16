---
trigger: always_on
---

## VERTEX

De integratie met Google Vertex AI is de intelligentie van het [PROJECT-NAAM]-portal. Om dit stabiel, snel en kostenefficiënt te houden, gelden de volgende regels (rules).

1. Architectuur & Toegang
* Geen Directe Client-side Aanroepen: De frontend praat nooit rechtstreeks met Google Cloud. Alle AI-taken verlopen via Supabase Edge Functions (zoals transcribe-vertex of rag-chat).
* Locatie & Regio: Gebruik altijd [GCP-REGIO] als GCP-locatie voor de kleinste vertraging (latency) en om data binnen de EU te houden.
* Authenticatie (Vertex): Gebruik een Service Account Key in JSON-formaat, opgeslagen als een Supabase Secret (GCP_SERVICE_ACCOUNT_KEY). 
* Authenticatie (Functie): De Edge Function valideert het inkomende JWT-token ZELF via de `authClient` (met Publishable Key). Deploy functies met `--no-verify-jwt` om de standaard Gateway-check te omzeilen.

2. Modelkeuze (Bron van Waarheid)
Dit document dient als de definitieve bron voor model-ID's. Bij upgrades passen we dit document aan, waarna de Edge Functions worden bijgewerkt.
* **Hoofdmodel:** Gebruik standaard **gemini-2.5-flash**. Dit model is leidend voor chat, transcriptie en beeldanalyse.
* **Embedding Model:** Gebruik standaard **text-embedding-004** voor alle RAG-gerelateerde taken.

3. Prompt Engineering (Systeeminstructies)
* Constraints: Geef AI-modellen altijd duidelijke beperkingen mee in de systeemprompt (bijv. "Antwoord uitsluitend in het Nederlands", "Geef alleen de ruwe transcriptie zonder inleiding").
* Context: Voor taken zoals transcriptie sturen we context mee (bijv. de laatste 20 woorden van het vorige blok) om continuïteit te waarborgen.
* Output Formatering: Forceer de AI om specifieke formaten te gebruiken (zoals pure tekst of JSON) om parsing-fouten in de backend te voorkomen.

4. Audio & Media Verwerking
* Base64 Encoding: Media-bestanden (audio, PDF, afbeeldingen) worden via Edge Functions als Base64-strings naar Vertex AI gestuurd.
* MIME-types: Geef altijd het correcte mimeType mee (bijv. audio/wav of application/pdf) zodat Gemini weet hoe de data geïnterpreteerd moet worden.
* Chunking: Voor audio-transcriptie knippen we bestanden op in behapbare stukken (chunks van 5-30 seconden) om time-outs te voorkomen en "streaming" feedback in de GUI mogelijk te maken.

5. Foutafhandeling & Kostenbeheer
* Retry Logica: Implementeer in de Edge Function basis foutafhandeling voor netwerkfouten of quota-limieten van Google Cloud.
* Filtering: Gebruik stilte-detectie of andere pre-processing filters om te voorkomen dat er API-aanroepen worden gedaan voor "lege" of onbruikbare data.
* Quota Monitoring: Houd de verbruikslimieten in de Google Cloud Console in de gaten om onverwachte uitval of kosten te voorkomen.

6. Tokens & Limieten
* Houd rekening met de maximale context-lengte van Gemini. Hoewel Flash een groot venster heeft, is het efficiënter om alleen de meest relevante informatie (via RAG) mee te sturen in plaats van hele documenten.

---

## RAG

Voor het beheer en de verdere ontwikkeling van het RAG-systeem (Retrieval-Augmented Generation) binnen het [PROJECT-NAAM]-portal hanteren we de volgende regels (rules). Dit zorgt voor een accurate AI die precies weet welke informatie uit jouw documenten gehaald moet worden.

1. Data Voorbereiding (Chunking & Embedding)
* Chunk Grootte: Gebruik standaard een chunk_size van ongeveer 2000 karakters.
* Overlap: Hanteer altijd een chunk_overlap van 200 karakters. Dit voorkomt dat cruciale informatie die precies op een knip-punt valt verloren gaat of onbegrijpelijk wordt.
* Consistentie: Gebruik uitsluitend het hierboven gedefinieerde embedding model. Het mixen van verschillende embedding-modellen maakt de zoekindex onbruikbaar.
* Metadata: Sla bij elke embedding altijd het document_id and de chunk_index op voor referentie en correcte opschoning.

2. Retrieval (Zoeklogica)
* Vector Search: Gebruik altijd de database-functie match_rag_embeddings (RPC) voor zoekacties. Deze maakt gebruik van de Cosine Similarity (<=> operator in pgvector) voor de beste resultaten.
* Threshold (Drempelwaarde):
    * Stel een standaard threshold in van 0.4.
    * Sta gebruikers toe deze te verhogen voor meer precisie (minder ruis) of te verlagen voor meer resultaten (maar risico op irrelevante info).
* Rendement: Limiteer het aantal chunks (match_count) dat wordt meegestuurd naar de AI (standaard 40). Te veel chunks vullen het context-venster onnodig en maken de AI trager.

3. Generation (Prompting & Context)
* Context Injectie: Plaats de gevonden documentgegevens altijd boven de gebruikersvraag in de prompt, duidelijk gemarkeerd (bijv. "Relevante informatie uit documenten: ...").
* Eerlijkheidscode: Instrueer de AI in de systeemprompt om eerlijk te zijn: "Als de informatie niet in de verstrekte documenten staat, geef dit dan aan en ga niet hallucineren."
* Scheiding: Zorg voor een duidelijke scheiding tussen de algemene kennis van het model en de specifieke document-data via de systeemprompt.

4. Database & Onderhoud
* **Documentbewaring:** Sla de bronbestanden (PDF, tekst, etc.) ALTIJD op in Supabase Storage.
* **Referentie Integriteit:** Sla bij elk document ALTIJD zowel de `storage_path` als de `storage_bucket` op in de `rag_documents` tabel. Dit garandeert dat we bestanden over verschillende buckets kunnen beheren.
* RLS: De tabellen `rag_documents` en `rag_embeddings` moeten strikt beveiligd zijn. Gebruikers mogen alleen data inzien of doorzoeken die van henzelf is (auth.uid() = user_id).
* Automatische Opschoning: Wanneer een rag_document wordt verwijderd, moeten alle bijbehorende records in rag_embeddings via een CASCADE delete direct worden gewist om de database schoon te houden. Verwijder ook het fysieke bestand uit Storage.
* Performance: Zorg voor een IVFFLAT of HNSW index op de embedding-kolom zodra de dataset groeit (boven de 10.000 chunks) om de zoekopdrachten razendsnel te houden.

5. UI & Configuratie
* Feedback: Toon de gebruiker altijd hoeveel document-chunks er zijn gebruikt om het antwoord te formuleren. Dit verhoogt het vertrouwen in de AI.
* Transparantie: Laat de status van de verwerking (Processing vs Completed) zien na het uploaden, zodat de gebruiker weet wanneer de data doorzoekbaar is.
* Sessiebeheer: Sla de RAG-instellingen (zoals de gebruikte prompt en threshold) op per sessie in rag_chat_sessions, zodat een gebruiker verschillende "onderzoeks-contexten" naast elkaar kan hebben.

---

## CHAT

Voor reguliere CHAT-functionaliteiten (zonder RAG) gelden de volgende regels:

1. Systeemprompt Hiërarchie
* Default Prompt: Elke chat-module heeft een "is_default" prompt in de database. Deze dient als de basis voor alle nieuwe gebruikers.
* Gebruikersinstellingen: Als een gebruiker zijn eigen standaard instelt in de instellingen-module, wordt deze overgenomen bij het openen van een nieuwe chat.
* Sessie-vastlegging: Zodra een chat start, wordt de op dat moment geldende systeemprompt hard gekopieerd naar the records in chat_summary_sessions of chat_scrape_sessions. Latere wijzigingen mogen de prompt van een bestaande chatsessie nooit overschrijven.

2. Context Beheer (Zonder RAG)
* Volledige Broninjektie: De volledige bronomschrijving wordt direct in de eerste systeemprompt of het eerste bericht meegegeven.
* Context venster: Beperken de chatgeschiedenis die wordt meegestuurd naar de AI tot de laatste 10-12 berichten.
* Samenvatting-injektie: Bij de start van een chat kan een eerdere samenvatting worden meegegeven als "geheugensteuntje" om te voorkomen dat de AI de kern van de brontekst vergeet.

3. Session Management & UI
* Session Isolation: Elke chatsessie heeft een eigen UUID.
* Naamgeving: Geef sessies automatisch een logische naam voor makkelijke terugvindbaarheid.
* Streaming: Toon de status duidelijk ("AI typt...") om de UX premium te houden.

4. Techniek (Edge Functions)
* Model: Gebruik altijd het hierboven gedefinieerde hoofdmodel.
* Persona: Definieer in de prompt de rol (bijv. "Je bent een notulist").
* Formaat: Instrueer de AI om Markdown te gebruiken voor koppen, lijsten en dikgedrukte tekst.
