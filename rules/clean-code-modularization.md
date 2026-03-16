---
trigger: always_on
---

## CODE MODULARISATIE & OPTIMALISATIE

Dit document bevat de regels voor het structureren van de codebase. Het doel is om het project overzichtelijk, onderhoudbaar en compact te houden ("Clean & Lean").

1. Component Slicing (De 300-regels grens)
* **Opsplitsen:** Geen enkel .tsx bestand mag groter zijn dan 300 regels. Wordt een module groter? Splits sub-secties dan op in kleine, herbruikbare sub-componenten.
* **Locatie:** Specifieke sub-componenten voor een module komen in een submap `[ModuleName]/bespreking/` of `[ModuleName]/` binnen de `src/components/modules/` directory.

2. Hooks voor Logica (Hooks Pattern)
* **Scheiding:** UI componenten zijn voor de weergave. Zware logica (API calls, opname-logica, complexe staats-transformaties) verhuist naar custom hooks in `src/hooks/` (bijv. `useAudioRecorder.ts`, `useMeetings.ts`).
* **Clean Components:** De hoofdcomponent moet voornamelijk bestaan uit het aanroepen van hooks en het renderen van de layout.

3. Shared UI Library (DRY - Don't Repeat Yourself)
* **Herbruikbaarheid:** Gebruik ALTIJD de componenten in `src/components/ui/` (zoals `Button`, `Card`, `Notification`).
* **Nieuwe UI Componenten:** Als je een nieuw herbruikbaar patroon ziet, maak dan een generieke component aan in `src/components/ui/` met bijbehorende CSS.
* **Consistentie:** Alle modules MOETEN gebruikmaken van deze centrale bibliotheek voor een premium, consistente uitstraling en minder CSS-overhead.

4. Styling Architectuur (Design Tokens)
* **Tokens:** Gebruik uitsluitend de CSS-variabelen uit `index.css` (:root) voor kleuren, spacing en effecten.
* **Geen Hardcoded Kleuren:** Gebruik `--primary-gradient`, `--text-main`, etc. in plaats van hex-codes in module-specifieke CSS.
* **Utility Classes:** Voor veelvoorkomende effecten (zoals "Glassmorphism" of "DarkCard") maken we één globale class aan in `index.css` in plaats van dit per module-CSS te dupliceren.

5. Hygiëne & Performance
* **Dode Code:** Verwijder ongebruikte imports, uitgecommenteerde code en tijdelijke test-logs onmiddellijk.
* **Optimization:** Gebruik `React.memo` of `useMemo` alleen op plekken waar dit echt zinvol is voor de performance in zware lijsten.
* **Bundle Size:** Houd rekening met de grootte van externe libraries; kies bij voorkeur voor lichtgewicht npm-pakketten of bouw eenvoudige zaken zelf.

6. Samenvatting voor Ontwikkeling
* **Analyseren:** Voordat je een nieuwe feature bouwt, bepaal je wat gedeeld kan worden.
* **Refactoren:** Als je merkt dat een bestaande module een "monoliet" wordt, is je eerste taak om deze te splitsen volgens bovenstaande regels.
