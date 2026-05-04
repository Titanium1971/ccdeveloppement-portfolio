# Sprint 2 — LOT 1 : Structure page produit AssistPro Business

**Date** : 2026-05-04
**Branche** : `sprint2-page-assistpro`
**Page créée** : `/assist-pro-business.html` (racine du repo, 56 Ko, 1392 lignes)
**Statut** : ✅ Squelette livré — placeholders LOT 2 documentés ci-dessous

---

## 1. Arborescence créée

```
portfolio/
├── assist-pro-business.html              ← NOUVEAU (1392 lignes, CSS inline)
├── fonts/
│   └── Inter-roman.var.woff2             ← NOUVEAU (344 Ko)
└── _audit-reports/
    └── sprint2-lot1-structure.md         ← NOUVEAU (ce fichier)
```

CSS spécifique : **inline dans `<style>` du `<head>`** (cohérent avec index.html, qui a aussi tout son CSS inline). Pas de fichier `assets/css/assist-pro-business.css` créé — tout est autonome dans la page pour éviter une duplication de variables/reset/nav/footer entre deux fichiers.

### Mini-arbre des sections HTML

```
<body>
├── nav (Navigation + lien actif AssistPro Business)
├── main#main-content
│   ├── section.hero-assist#hero
│   ├── section.assist-section.problem-section#probleme       (3 cards)
│   ├── section.assist-section.promise-section#promesse       (3 piliers)
│   ├── section.assist-section.features-section#features      (6 cards)
│   ├── section.assist-section.demo-assist#demo               (placeholder)
│   ├── section.assist-section.pricing-section#tarifs         (4 plans + sur-mesure)
│   ├── section.assist-section.options-section#options        (tableau 5 lignes)
│   ├── section.assist-section.compare-section#concurrence    (tableau 4 lignes)
│   ├── section.assist-section.faq-section#faq                (8 details/summary)
│   ├── section.assist-section.dpa-section#dpa                (bouton désactivé)
│   └── section.assist-section.cta-final#cta-final
├── footer (avec data-cookie-preferences)
├── div.sticky-cal (mobile)
└── scripts (analytics, lenis, smooth-scroll, Cal.com)
```

### Classes principales utilisées

- **Layout** : `section-container`, `assist-section`, `section-tag`, `section-heading`, `section-desc`
- **Boutons** : `btn-primary`, `btn-primary.btn-large`, `btn-secondary`, `btn-secondary.disabled`, `btn-cal`, `btn-cal--outline`, `btn-plan`
- **Cards** : `problem-card`, `pillar-card`, `feature-card`, `plan-card`, `plan-card.plan-featured`, `plan-badge`, `plan-bespoke`
- **FAQ** : `faq-list`, `faq-item`, `faq-answer`
- **Tableaux** : `options-table`, `compare-table`
- **Nav** : `nav-logo`, `nav-links`, `nav-cta`, `mobile-toggle`, `[aria-current="page"]`

---

## 2. Variables CSS reprises d'`index.html`

Toutes les variables `:root` du sprint 1A/1B sont strictement reprises (mêmes hex, mêmes noms) :

| Variable | Valeur | Utilisée dans cette page |
|---|---|---|
| `--accent` | `#39FF14` | CTAs, hover, badge "Recommandé", bordure plan featured |
| `--accent-glow` | `rgba(57,255,20,0.28)` | shadow boutons primary, hero glow |
| `--accent-dim` | `rgba(57,255,20,0.10)` | section-tag bg, problem-icon, banner |
| `--black` | `#09090B` | body bg, btn-primary text |
| `--dark` | `#111113` | sections alternées (problem, features, pricing, compare, dpa) |
| `--dark-2` | `#18181B` | cards bg, table bg |
| `--dark-3` | `#27272A` | bordures, separators |
| `--gray-light` | `#B6B6C0` | muted text, captions |
| `--gray` | `#D4D4D8` | corps de texte secondaire |
| `--white` | `#FFFFFF` | titres, body text |
| `--radius` | `16px` | border-radius cards et tables |
| `--green` | `#22C55E` | (déclarée — non utilisée dans cette page) |
| `--blue` | `#3B82F6` | (déclarée — non utilisée dans cette page) |
| `--amber` | `#F59E0B` | (déclarée — non utilisée dans cette page) |
| `--purple` | `#A855F7` | (déclarée — non utilisée dans cette page) |

Les 4 dernières (green/blue/amber/purple) sont **incluses pour cohérence** mais non utilisées : elles servent dans index.html pour des badges de status projets et restent disponibles si LOT 2 ajoute des éléments visuels supplémentaires.

---

## 3. Police Inter Variable — détails techniques

| Champ | Valeur |
|---|---|
| **URL source utilisée** | `https://rsms.me/inter/font-files/InterVariable.woff2?v=4.1` |
| **URL note** | L'URL `Inter-roman.var.woff2` du brief retourne 404 — le fichier officiel actuel s'appelle `InterVariable.woff2` (v4.1, format renommé). Téléchargé puis sauvegardé sous le nom demandé `fonts/Inter-roman.var.woff2`. |
| **Fichier local** | `fonts/Inter-roman.var.woff2` |
| **Taille** | 352 240 octets (≈ 344 Ko) — légèrement au-dessus du `<350 Ko` attendu, normal pour la version 4.1 récente avec glyphes étendus |
| **SHA-256** | `693b77d4f32ee9b8bfc995589b5fad5e99adf2832738661f5402f9978429a8e3` |
| **Licence** | SIL Open Font License (OFL) — autorisée commercialement, redistribution et hébergement libres |
| **Auteur** | Rasmus Andersson (rsms) |
| **Glyphes FR** | ✅ Couverture complète (è, é, à, â, ê, î, ô, û, ç, ï, ü, œ, æ, etc.) |

### Déclaration `@font-face`

```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-roman.var.woff2') format('woff2-variations'),
       url('/fonts/Inter-roman.var.woff2') format('woff2');
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

### Préchargement dans `<head>`

```html
<link rel="preload" as="font" href="/fonts/Inter-roman.var.woff2" type="font/woff2" crossorigin>
```

### Application

`body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, ... }` — la police s'applique à **toute la page** (titres + corps), pas Morena/Brandon. Stack de fallback en cas d'échec de chargement : système.

`font-feature-settings: 'cv11', 'ss01', 'ss03';` activé pour exploiter les variantes typographiques d'Inter (chiffres tabulaires, alternates) qui améliorent la lisibilité des prix et tableaux.

---

## 4. Tableau exhaustif des PLACEHOLDERS À REMPLIR LOT 2

| # | ID / Classe | Type | Suggestion / Contexte |
|---|---|---|---|
| 1 | `.hero-baseline` (section #hero) | Texte 2 lignes | Promesse claire (assistant 24/7 sur canal n°1 FR) + bénéfice business principal (libérer du temps, ne plus rater de client). Ton commercial mais authentique. |
| 2 | `.hero-visual` (section #hero) | Visuel produit | Capture mockup WhatsApp Business OU démo conversation animée. Pour l'instant, `Images/AssistPro-1200.webp` est utilisée comme fallback visuel. |
| 3 | `.section-desc` (section #probleme) | Texte 1-2 lignes | Phrase d'intro posant les 3 douleurs récurrentes des restaurateurs / commerçants / PME. |
| 4 | `.problem-card p` ×3 (section #probleme) | Paragraphe pain point | Décrire la friction concrète pour chaque pain point (appels coup de feu, avis sans réponse, 5h/semaine community). |
| 5 | `.section-desc` (section #promesse) | Texte 1-2 lignes | Intro qui annonce les 3 piliers (numéro dédié, 50 fonctions, setup 7 jours). |
| 6 | `.pillar-card p` ×3 (section #promesse) | Phrase pilier | Détail chaque pilier (Twilio BSP, fonctions packagées, parcours setup J+7). |
| 7 | `.section-desc` (section #features) | Texte 1-2 lignes | Intro 6 super-pouvoirs déjà packagés. |
| 8 | `.feature-card p` ×6 + `<ul>` ×6 (section #features) | Pitch 1-2 lignes + 3 micro-bénéfices par card | Pour chaque feature : 1 phrase pitch + 3 puces micro-bénéfices (réservations, posts IA, avis Google, briefing matinal, support 24/7, dashboard). |
| 9 | `.demo-placeholder` (section #demo) | Démo HTML/CSS ou vidéo | Démo conversationnelle WhatsApp simulée (style chat, comme la démo IA d'index.html) ou vidéo capture MP4/WebM. Scénario type : client demande horaires → IA répond → client réserve → IA confirme. |
| 10 | FAQ — questions 4 à 8 | 5 paires Q/R | "Combien ça coûte tout compris ?", "Est-ce que ça remplace mon staff ?", "Quelle assistance fournie ?", "Mes données sont-elles sécurisées ?", "Puis-je essayer avant de payer ?" — réponses honnêtes, alignées sur les décisions business. |
| 11 | (à intégrer LOT 4) | DPA PDF | `assets/downloads/dpa-cc-developpement-2026.pdf` à produire et brancher sur les 2 boutons `data-dpa-disabled` (FAQ Q3 + section #dpa). Retirer `aria-disabled`, `disabled`, `data-dpa-disabled` à ce moment-là. |

**Total placeholders LOT 2** : 10 zones rédactionnelles + 1 démo visuelle.
**Total à brancher LOT 4** : 1 PDF DPA (2 liens).

---

## 5. Décisions / écarts par rapport au brief

| Sujet | Décision prise | Raison |
|---|---|---|
| Nom de fichier de police | `fonts/Inter-roman.var.woff2` (nom du brief conservé) | URL source réelle = `InterVariable.woff2?v=4.1` (l'ancien nom `Inter-roman.var.woff2` retourne 404 sur rsms.me). Téléchargé puis renommé pour respecter le brief. |
| Position du CSS spécifique | Inline dans `<head>` | Cohérent avec index.html (tout inline). Évite de dupliquer variables/reset/nav/footer entre fichiers ou de devoir refactorer index.html en parallèle. La page reste à 56 Ko, raisonnable. |
| Path `lenis.min.js` | `/assets/js/lenis.min.js` (absolu) | Identique à index.html ligne 2093. |
| Path `smooth-scroll.js` | `./smooth-scroll.js` (relatif racine) | Le fichier est à la racine du repo (`portfolio/smooth-scroll.js`), pas dans `assets/js/`. Brief mentionnait `/assets/js/smooth-scroll.js` mais ce chemin retournerait 404 — j'ai aligné sur le chemin réel utilisé par index.html ligne 2094. |
| Path `analytics.js` | `assets/js/analytics.js` (relatif sans slash initial) | Identique à index.html ligne 1205, avec `defer`. |
| Nav | Reprise complète + lien actif "AssistPro Business" inséré | Items "Stack" et "Assistant IA" remplacés par "AssistPro Business" (la page est elle-même la cible naturelle de "Assistant IA"). Les ancres `#parcours`, `#projets`, `#services` transformées en liens absolus `/#parcours`, etc. pour fonctionner depuis cette page. CTA "Réserver un audit" transformé en lien Cal.com direct (au lieu de `#contact` qui n'existe pas ici). |
| Open Graph | `og:image` = `Images/AssistPro-1200.webp` | Image produit existante (52 Ko, déjà dans le repo). Format WebP supporté par tous les crawlers OG modernes (Facebook, LinkedIn, X, Slack). |
| JSON-LD | `Service` avec `OfferCatalog` 4 plans (sans `aggregateRating`) | Brief indiquait "ne pas inventer aggregateRating" — pas inclus. Les 4 prix sont exactement ceux de `pricing.md` (139, 239, 389, 789 €/mois HT, `valueAddedTaxIncluded: false`). |
| Cookie-prefs | 1 lien dans le footer avec `data-cookie-preferences` | Strictement identique à index.html ligne 1882. |

---

## 6. Vérifications automatiques effectuées

| Vérif | Commande / Méthode | Résultat |
|---|---|---|
| HTML5 — équilibre des tags | `grep -oE` ouvertures vs fermetures sur `html, head, body, main, nav, footer, section, article, ul, li, details, summary, table, thead, tbody, tr, div` | ✅ **Tous équilibrés** (div : 64/64, section : 11/11, etc.) |
| Encodage UTF-8 propre | `grep -c 'Ã\|â€\|Â '` (mojibake patterns) | ✅ **0 occurrence** — tous les accents propres |
| Footer cookie-prefs | `grep -c "data-cookie-preferences"` | ✅ **1** (footer) |
| Lenis local | `grep "/assets/js/lenis.min.js"` | ✅ Présent en fin de body |
| smooth-scroll local | `grep "./smooth-scroll.js"` | ✅ Présent en fin de body |
| analytics.js (consent v2) | `grep "assets/js/analytics.js" defer` | ✅ Présent dans `<head>` avec `defer` |
| Cal.com handle | `grep -c "data-cal-link=\"cc-developpement/audit-gratuit\""` | ✅ **10 occurrences** (nav, hero ×1, plans ×4, plan-bespoke ×1, cta-final ×1, footer-cal ×1, sticky-cal ×1) — toutes avec `data-cal-config='{"layout":"modal"}'` |
| Cal.com init snippet | Présent en fin de body | ✅ Identique à index.html (theme dark, brandColor `#39FF14`) |
| Aucun `href="#"` non autorisé | `grep -n 'href="#"'` → 3 résultats, tous avec `data-dpa-disabled` ou `data-cookie-preferences` | ✅ Conforme |
| Liens externes — target/rel | `grep 'target="_blank"'` → 0 | ✅ Aucun lien externe `_blank` (tous les Cal.com restent même onglet, comme index.html) |
| Police Inter — preload | `<link rel="preload" as="font" href="/fonts/Inter-roman.var.woff2" type="font/woff2" crossorigin>` | ✅ Présent dans `<head>` |
| Police Inter — @font-face | font-family `Inter`, weight `100 900`, font-display `swap` | ✅ Conforme au brief |
| Police Inter — application | `body { font-family: 'Inter', ... }` | ✅ Toute la page (titres + corps) |
| JSON-LD valide | Service + OfferCatalog avec 4 Offer (Essentiel/Pro/Premium/Custom) | ✅ Présent, prix HT, `priceCurrency: EUR`, `valueAddedTaxIncluded: false` |
| Variables CSS d'index.html | Toutes recopiées dans `:root` | ✅ 16 variables, ordres et valeurs identiques |

---

## 7. Limites connues / dette LOT 1

1. **Pas de validation visuelle navigateur effectuée** — la page est livrée structurellement complète, mais aucune capture/test Playwright n'a été lancé (ce sera plus pertinent après LOT 2 quand le copy + démo seront en place). L'audit visuel manuel (mobile + desktop) reste à faire avant la mise en production.
2. **Image hero = `Images/AssistPro-1200.webp` existante** — bouche-trou pour ne pas avoir une div vide. Probablement à remplacer LOT 2 par un vrai mockup conversationnel WhatsApp ou une scène plus produit.
3. **Démo conversationnelle vide** — section #demo a un placeholder `[À INTÉGRER LOT 2]`. À implémenter avec animation chat (style index.html) ou vidéo.
4. **`aggregateRating` JSON-LD absent** — brief explicite : ne pas inventer. À ajouter dès qu'on a 5+ avis clients réels documentés.
5. **Bouton DPA désactivé** — 2 liens `data-dpa-disabled` (FAQ Q3 et section #dpa) à brancher LOT 4 quand le PDF sera produit.
6. **Animations / scroll reveal** — pas implémenté ici (la classe `.reveal` d'index.html n'a pas été reprise pour cette page). À considérer si LOT 2 veut harmoniser l'animation à l'arrivée des sections.
7. **Pas de meta CSP locale** — comme prévu : la CSP est appliquée globalement par Cloudflare via `_headers` (sprint 1A intact). Les ressources externes utilisées (`app.cal.com`) sont déjà autorisées.
8. **Police 344 Ko** — légèrement au-dessus de la fourchette `< 350 Ko` du brief (352 240 octets exactement). C'est la version officielle 4.1 actuelle d'Inter, marge tolérable. Compression Brotli/gzip côté Cloudflare réduira l'impact réseau réel.

---

## 8. Fichiers livrés / non touchés

### Livrés (créés)
- `assist-pro-business.html` (1392 lignes, 56 Ko)
- `fonts/Inter-roman.var.woff2` (344 Ko)
- `_audit-reports/sprint2-lot1-structure.md` (ce rapport)

### Non touchés (conformément au brief)
- `index.html`, `tarifs.html`, `devis.html`, `mentions-legales.html`, `rgpd-confidentialite.html`, `merci.html`, `comparatif-tarifs.html`, `estimateur.html`, `creation-site-web-agde.html`, `seo-local-herault.html`, `guide-seo-local.html`, `guide-tarifs.html`, `blog/*`
- `assets/js/analytics.js`, `assets/js/lenis.min.js`, `_headers`, `_redirects`, `smooth-scroll.js`
- `fonts/Brandon_reg.otf`, `fonts/Morena-*.otf` (intacts)
- `~/Projets/cc-whatsapp-assistant/docs/pricing.md` (lecture seule, non modifié)

---

## 9. Prochaine étape — LOT 2

LOT 2 doit produire :
1. Le copywriting des 10 zones placeholders listées en §4
2. La démo conversationnelle WhatsApp (HTML/CSS animée recommandé pour rester léger)
3. Optionnel : un mockup hero plus produit pour remplacer l'image actuelle
4. Optionnel : harmonisation animations `.reveal` avec le reste du site

Le squelette HTML est stable et n'a pas besoin d'être modifié structurellement pour LOT 2 — tous les hooks (classes, IDs, sections) sont en place.
