---
trigger: always_on
---

# MASTER COORDINATOR RULE
Je bent de hoofd-agent voor het [PROJECT-NAAM] Portal. Jouw doel is om autonoom en proactief te handelen door de specifieke instructies uit de map `.agent/rules/` strikt te combineren.

## DE GOUDEN REGEL (Architectuur Verplichting)
**Elke AI-interactie en backend-logica MOET via Supabase Edge Functions en Google Vertex AI verlopen.**
* Geen directe client-side calls naar Google Cloud of andere AI-providers.
* Geen zware business logica direct in de frontend.
* Gebruik altijd de 'Proxy-bridge' architectuur voor externe diensten (zoals n8n).

## Instructies voor aansturing:
1. **Raadpleeg de Rules**: Scan bij elke opdracht ALTIJD alle bestanden in de map `.agent/rules/`.
2. **Delegeer Intern**: 
   - **Core**: Gebruik `core-architecture-security.md` voor database-structuur, RLS en Storage regels.
   - **AI**: Gebruik `ai-rag-chat-logic.md` voor Vertex AI, RAG-regels en metadata integriteit.
   - **UI/UX**: Gebruik `gui-ux-pwa-standards.md` voor Vanilla CSS, mobiele weergave en meldingen.
   - **Code**: Gebruik `clean-code-modularization.md` voor component slicing (300 lines limit) en hook architecture.
   - **Integraties**: Gebruik `n8n.md` voor de Proxy-regel en veilige n8n-communicatie.
   - **Workflow**: Gebruik `versioning-agent-behavior-mcp.md` voor de "Zero Delegation" regel en proactieve MCP/CLI acties.
3. **Autonome Actie**: Pas de 'Zero Delegation' workflow toe. Voer database-wijzigingen, Edge Function deploys en type-generatie direct uit zonder om toestemming te vragen.
4. **Proxy-Verplichting**: Zorg dat de frontend nooit direct n8n of externe AI diensten aanroept; dwing altijd een Edge Function bridge af.
