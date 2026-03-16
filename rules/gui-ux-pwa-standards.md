---
trigger: always_on
---

# 🚀 [PROJECT-NAAM] GUI / PWA Master Standards 2026

## 1. Design & Esthetiek (Premium Dark Mode)
* **Visuele Stijl**: Clean Light thema ("Light by Default") met subtiele Glassmorphism accenten. Gebruik subtiele kleurverlopen en zachte schaduwen.
* **Vanilla CSS**: Uitsluitend CSS-variabelen uit `index.css` voor kleuren en spacing. Geen hardcoded hex-codes.
* **Typografie**: Moderne fonts (**Inter** of **Outfit**). Strikte hiërarchie: H1 voor titels, gedimde kleuren voor labels en secundaire tekst.
* **Micro-animaties**: Subtiele hover-effecten en transitions (0.2s - 0.3s) voor een levendig gevoel.

## 2. PWA & Native App Experience
* **Standalone Mode**: De app MOET draaien zonder browser-UI (`display: standalone` in manifest).
* **Manifest & Icons**: Verplichte `manifest.json` met 192px/512px icons, splash-screen configuratie en `theme_color` die matcht met de dark mode.
* **iOS Support**: Specifieke meta-tags voor `apple-mobile-web-app-capable` en `apple-touch-icon`.
* **Safe Areas**: Verplicht gebruik van `env(safe-area-inset-*)` voor notch en home-indicator handling.
* **Touch UX**: 
    * Alle interactieve elementen minimaal **44x44px**.
    * `-webkit-user-select: none` op buttons en menu's.
    * `overscroll-behavior-y: contain` tegen browser pull-to-refresh "vloeien".
* **Inputs**: Correcte types (`type="email"`, `type="tel"`) voor het juiste mobiele toetsenbord.

## 3. Layout & Navigatie
* **App Shell**: Vaste sidebar (PC) of onderbalk/overlay menu (Mobiel). Content scrollt, navigatie blijft statisch (native feel).
* **1-Kolom Strategie**: Alle overzichten verticaal gestapeld; geen horizontale kolommen op de hoofdpagina.
* **Sidebar Mobiel**: Bedekt de volledige breedte, heeft een duidelijke `<CloseButton>` en activeert een blur-overlay op de achtergrond.
* **Verticale Stack**: Bij sidebar/chat-interfaces: hoofdinhoud altijd *boven* de chat plaatsen.

## 4. Component Standards

### Buttons & Action Groups
* **Component**: Verplicht `<Button>` component (uitzondering: custom tabs).
* **Varianten**: `primary`, `secondary`, `danger`, `success`, `ghost`.
* **Maten**: `sm` (icon), `md` (standaard), `lg` (CTA).
* **Layout**: `minWidth: 140px-180px`, `gap: 12px`, `justifyContent: 'flex-start'`. Geen `flex: 1`.
* **Loading**: `isLoading` prop activeert witte spinner (16px, 2px border, 0.6s). Toon pas als actie > 500ms duurt.
* **Tekst**: Kort en krachtig. Emoji's **IN** de tekst (bijv. "🚀 Start").

### List Items (Sessies/Scrapes/Meetings)
* **Classes**: `session-row` en `session-card`.
* **Interactie**: Delete button (🗑️) **ALTIJD links** van de kaart. Geen confirm-dialogs bij delete.
* **Elementen**: `session-icon`, `session-info` (`session-title` + `session-date`), `session-arrow`.

### Chat Component
* **Structuur**: Conform `src/components/modules/RAGModule.tsx`.
* **Messages**: User rechts (blauw `#3b82f6`), Assistant links (wit/glass). Max-breedte 80%. Timestamps (HH:MM) onder elk bericht.
* **Input**: `<textarea>` met auto-resize, min-hoogte 44px, border-radius 1.5rem, Enter-to-send.
* **States**: Empty state (icoon + titel + beschrijving). Loading: animated dots (bounce animatie).

### Modals & Sluiten
* **Overlays**: Semi-transparante achtergrond met `backdrop-filter: blur(10px)`.
* **Close Button**: Verplicht `<CloseButton>` (32px, circulair) via `headerAction` prop van Card.
* **Toasts**: Discreet, 2-3 seconden, boven- of onderaan het scherm.
* **Modal Layout**: Alle instellingen-modals MOETEN `max-height: 90vh` en `overflow-y: auto` hebben om te voorkomen dat content van het scherm valt op kleine devices.
## 5. Meldingen & Data Filosofie (Minimalisme)
* **No-Alert Policy**: Nooit `alert()`, `confirm()` of `prompt()` gebruiken.
* **Silence is Golden**: 
    * Alleen kritieke fouten melden. Geen "succes-moeheid".
    * Gebruik visuele feedback (vinkje op knop) i.p.v. pop-ups voor opslaan.
* **Optimistic UI**: Interface direct updaten bij actie. Bij server-fout: stilletjes terugdraaien of dán pas subtiele melding.
* **Data-Minimalisme**: Sla geen proces-logs op. Gebruik React state voor tijdelijke info. Verwerk data in-memory in Edge Functions.

## 6. Code & Performance
* **Service Worker**: Verplichte `sw.js` voor offline support en caching van kritische resources (App Shell).
* **Vite Optimization**: Optimaliseer afbeeldingen; gebruik SVG's voor iconen (maximale scherpte).
* **Z-index**: Sidebar = 100, Modal = 200, Toast = 300.
* **Taal**: Nederlands. Alleen eerste woord hoofdletter (bijv. "Nieuwe chat"). Uitzondering: eigennamen en afkortingen (AI, PDF).
### 9. Cards & Overlays
* **Visual Definition**: Alle cards en overlays MOETEN een zichtbare border hebben (`1px solid #cbd5e1`) om los te komen van de achtergrond
* **Rationale**: Zachte schaduwen alleen zijn vaak onvoldoende, vooral op lichte achtergronden; een border zorgt voor een strakke, gedefinieerde rand

### 10. Button Visibility Standards
* **Secondary Buttons**: MOETEN een donkere border hebben (`#94a3b8`) en donkere tekst (`#0f172a`) voor maximaal contrast en leesbaarheid.
* **Geen Ghost**: Gebruik GEEN `variant="ghost"` voor functionele standaard-acties (zoals Kopieer/Bewerk); gebruik altijd `secondary` zodat de knop zichtbaar is als clickable area.
* **Ghost Usage**: Ghost is ALLEEN toegestaan voor icons-only in toolbars of zeer subtiele secundaire acties (zoals een X-sluitknop zonder achtergrond).

### 11. Secondary Button Style (Definitief)
* **Background**: Gebruik `#f1f5f9` (Slate 100) - dus NIET wit - om altijd een zichtbaar vlak te vormen op witte achtergronden.
* **Border**: `#94a3b8` (Slate 400) voor harde afkadering.
* **Tekst**: `#0f172a` (Slate 900) voor maximaal leesbaar contrast.
* **Shadow**: Subtiele `box-shadow` toevoegen om diepte te suggereren.

### 12. Input Fields in Cards
* **Width**: Gebruik voor inputs binnen een card nooit de volle breedte (`100%`) als er label-tekst naast staat. Beperk tot `60%` of `max-width: 600px` voor een gebalanceerde layout.
* **Spacing**: Zorg voor voldoende witruimte (`margin-bottom: 32px`) tussen headers/exit-buttons en de content daaronder.

### 13. Settings & Auto-Save
* **Tabs**: Gebruik voor instellingen-context (Mijn vs Systeem) de standaarde `<Button>` group pattern (Primary vs Ghost), géén losse HTML tabs.
* **Auto-Save**: Geef de voorkeur aan auto-save (`onBlur`) boven handmatige "Opslaan" knoppen. Verwijder Footer save-knoppen. Toon tijdens het opslaan een subtiele indicator (bijv. "⏳ Opslaan...") in de header van de sectie.

### 14. Inline Editing
* **Auto-Save**: Gebruik voor het bewerken van velden (zoals titels) **geen** expliciete 'Opslaan/Annuleren' (✅/❌) knoppen.
* **Interactie**: Klik om te bewerken -> Input verschijnt -> Wijziging wordt opgeslagen bij `onBlur` of `Enter`.
* **Visuals**: Geef de input in edit-mode een duidelijke border (bijv. `2px solid #3b82f6`) en beperk de breedte (`max-width: 400px`) om uitrekking te voorkomen.

### 15. Standard Utility Action Buttons
* **Kopieer**: Gebruik altijd `<Button variant="secondary" size="sm">📋 Kopieer</Button>` voor kopieer-acties. Dit zorgt voor herkenbaarheid door de hele app.
* **Consistentie**: Voorkom het maken van nieuwe varianten (zoals "Kopieer tekst" of "Copy").
* **Opschonen**: Gebruik altijd `<Button variant="secondary" size="sm">🧹 Opschonen</Button>` voor het leegmaken van content. Gebruik niet "Leegmaken" of "Wissen".

### 16. Detail Cards
* **Styling**: Alle detail-views en formulieren gebruiken een witte container met `border: 1px solid #cbd5e1`, `border-radius: var(--radius-lg)` en `padding: 24px`.
* **Header**: De header binnen de kaart heeft altijd een `border-bottom: 1px solid #f1f5f9` en `margin-bottom: 32px` voor een consistente structuur.

### 17. Defensive Content Handling (Anti-Break)
* **Overflow Protection**: Elementen met variabele content (zoals bestandsnamen, user-input of externe titels) MOETEN begrensd worden. Gebruik `text-overflow: ellipsis`, `overflow: hidden` en `white-space: nowrap` in combinatie met een `max-width` of flex-shrink.
* **Containers**: Zorg dat knoppen en labels nooit de layout breken of buiten het scherm vallen (horizontal scroll vermijden).
