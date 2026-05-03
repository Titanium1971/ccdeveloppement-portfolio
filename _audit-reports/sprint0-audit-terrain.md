# Sprint 0 — Audit terrain CC Développement

**Date :** 3 mai 2026
**Périmètre :** ccdeveloppement.eu (production) + repo `portfolio/` (source)
**Méthode :** inspection live navigateur (DOM, network, performance API) + audit du code source + lecture `_headers`, `_redirects`, `robots.txt`, `sitemap.xml`. Toutes les conclusions sont appuyées par des preuves observables dans la prod et/ou le repo.
**Auteur de l'audit :** Cowork (Claude)

---

## Verdict global

L'audit initial (ChatGPT) proposait 5 tickets. Après vérification terrain :

- **2 tickets** sont déjà OK (faux problèmes, signaux propres en prod et dans le repo).
- **1 ticket** est confirmé comme **P0 critique** — le seul vrai sujet urgent.
- **1 ticket** est P3 / nice-to-have.
- **1 ticket** sort du sprint correctif (sujet produit).

**Bonne nouvelle terrain :** le repo est plus solide que je ne pensais en regardant juste la home en prod.

- Le JSON-LD est **déjà très complet** sur toutes les pages clés (Organization, ProfessionalService, WebSite, Service, OfferCatalog, ContactPoint, GeoCoordinates, OpeningHoursSpecification, BreadcrumbList, FAQPage, Article, etc.). Le ticket *« ajouter LocalBusiness + BreadcrumbList + FAQPage »* du brief initial est largement caduc.
- `_headers` Cloudflare Pages est solide : HSTS preload, CSP stricte, Permissions-Policy restrictive, X-Frame-Options.
- `robots.txt` source est bien formaté (3 lignes propres). Mon premier rapport disait l'inverse — c'était une erreur d'interprétation due à un collapsing whitespace côté lecture navigateur, pas un vrai problème côté serveur.

**Ce qui reste vraiment à corriger :**

1. RGPD (P0 critique).
2. Quelques bugs UX/encodage isolés (P1).
3. Hygiène mineure (polices, ressources orphelines en prod).

---

## 1. Redirections HTTP

**Statut : OK — non-régression à surveiller**

Preuves prod :

- Navigation sur `https://www.ccdeveloppement.eu` → la page charge sans erreur.
- `window.location.host` retourne `ccdeveloppement.eu` (sans www).
- Redirection www → apex gérée nativement par Cloudflare.

Preuves source :

- `_redirects` ne contient qu'une règle (`/historique / 301`) — la redirection www → apex n'a pas besoin d'y figurer car Cloudflare la gère au niveau DNS/proxy.

Conclusion : ticket initial *« Corriger la redirection www vers non-www »* sans objet. À conserver comme test de non-régression.

---

## 2. Canonical / sitemap / robots

**Statut : OK**

Preuves canonical (live) :

- Home → `<link rel="canonical" href="https://ccdeveloppement.eu/">`
- /devis → `<link rel="canonical" href="https://ccdeveloppement.eu/devis">`

Preuves robots.txt (fichier source `portfolio/robots.txt`) :

```
User-agent: *
Allow: /
Sitemap: https://ccdeveloppement.eu/sitemap.xml
```

Bien formaté, une directive par ligne. Le rendu sur une ligne observé en prod côté navigateur était un artefact de collapsing whitespace lors de la lecture, pas un problème serveur. **Aucune action.**

Preuves sitemap.xml (live) :

- 15 URLs détectées, toutes en `https://ccdeveloppement.eu/` sans www.
- Aucune incohérence avec les canonical.

Pages présentes : `/`, `/tarifs`, `/devis`, `/creation-site-web-agde`, `/seo-local-herault`, `/blog/`, `/guide-seo-local`, `/estimateur`, 3 articles blog, `/comparatif-tarifs`, `/guide-tarifs`, `/mentions-legales`, `/rgpd-confidentialite`.

Conclusion : ticket initial *« Harmoniser canonical, sitemap et robots »* est OK. Aucune action.

---

## 3. Scripts tiers et tracking

**Statut : NON CONFORME — chargement automatique de traceurs sans consentement**

Scripts qui se chargent automatiquement à l'ouverture de la home, observés en network prod :

| Script | Origine | Catégorie | Source |
|--------|---------|-----------|--------|
| `googletagmanager.com/gtag/js?id=G-NZ2MQMB67H` | tiers | analytics — Google Analytics 4 | injecté |
| `clarity.ms/tag/wbyffo03d6` | tiers | analytics — Microsoft Clarity (heatmap, session replay) | injecté |
| `app.cal.com/embed/embed.js` | tiers | fonctionnel — réservation Cal.com | référencé dans le HTML |
| `unpkg.com/lenis@1.1.18/dist/lenis.min.js` | tiers | fonctionnel — smooth scroll | référencé dans le HTML |
| `frontend-cdn.perplexity.ai/.../FKGroteskNeue.woff2` | tiers | **orphelin** — répond 503 en prod | non trouvé dans le code source |
| `/assets/js/analytics.js` | first-party | probable injecteur GA4 / Clarity | repo |

Confirmation par la CSP (`portfolio/_headers`) :

```
script-src 'self' 'unsafe-inline'
  https://www.googletagmanager.com
  https://www.google-analytics.com
  https://www.clarity.ms
  https://static.cloudflareinsights.com
  https://app.cal.com
  https://embed.cal.com
  https://unpkg.com
```

La CSP autorise donc aussi **Cloudflare Insights** (chargé automatiquement par Cloudflare Pages, beacon cookie-less) et **Brevo / Sendinblue** (`sibforms`, utilisé pour le lead magnet du guide SEO).

Cas particuliers :

- **Cloudflare Web Analytics** est cookie-less. La CNIL le tolère sans bandeau si la mesure d'audience est strictement nécessaire et anonymisée. À mentionner dans la politique RGPD pour transparence.
- **Brevo (sibforms)** est chargé uniquement quand l'utilisateur interagit avec le formulaire newsletter — c'est de la collecte volontaire, base légale = consentement explicite via le formulaire lui-même. OK.

À investiguer : la font Perplexity orpheline (503 en prod, absente du code source). Probablement injectée par un script tiers ou un copier-coller historique. Inspecter `/assets/js/analytics.js` ou les CSS pour la trouver.

---

## 4. RGPD

**Statut : CRITIQUE — non-conformité + politique mensongère**

Contradiction directe entre la page `/rgpd-confidentialite` et la réalité technique.

La page affirme :

> Le site n'utilise pas de cookies publicitaires ni d'outils de tracking marketing tiers sur la version actuelle.

Réalité (section 3) : GA4 + Microsoft Clarity actifs, chargement automatique, aucun bandeau de consentement.

Recherche bandeau dans le DOM (regex `cookie|consent|tarteaucitron|axeptio|cookiebot`) en prod : **0 résultat**.

Risques :

1. Mise en demeure CNIL — sanction théorique jusqu'à 20 M€ ou 4 % du CA, en pratique pour une TPE c'est avertissement + obligation de mise en conformité.
2. Crédibilité commerciale — un dev qui vend du SEO et de l'expertise digitale et qui se trompe sur sa propre politique RGPD : signal négatif fort si un prospect technique inspecte le site.
3. Plainte d'un concurrent ou d'un visiteur.

Correction P0 (au choix selon usage réel des données) :

**Option A — Suppression (recommandée, 1h)**

Si GA4 et Clarity ne servent pas activement à des décisions :

- Retirer les scripts du HTML / `assets/js/analytics.js`.
- Supprimer les domaines `googletagmanager.com`, `google-analytics.com`, `clarity.ms` de la CSP dans `_headers`.
- La page `/rgpd-confidentialite` redevient cohérente sans modification (sauf mention de Cloudflare Insights si on veut être très propre).

**Option B — Consentement propre (2-3h)**

Si les données sont utiles :

- Installer Tarteaucitron self-hosted (gratuit, FR, RGPD-friendly) ou équivalent.
- Conditionner le chargement de GA4 + Clarity à l'acceptation.
- Mettre à jour `/rgpd-confidentialite` :
  - Supprimer la phrase mensongère ;
  - Mentionner GA4, Clarity, Cloudflare Insights, Brevo ;
  - Préciser finalités, durée de conservation, retrait du consentement.
- Ajouter un lien permanent « Modifier mes choix cookies » (footer).

Recommandation : option A par défaut. Pour un site de freelance, la donnée Clarity (heatmap) a un intérêt marginal vs le coût conformité.

---

## 5. Données structurées (JSON-LD)

**Statut : très bon — aucun ajout nécessaire en P0**

Inventaire repo (preuves grep `application/ld+json` sur les fichiers HTML) :

| Page | Types détectés |
|------|----------------|
| `index.html` | Organization, ProfessionalService, WebSite, Service, OfferCatalog, ContactPoint, GeoCoordinates, OpeningHoursSpecification, AdministrativeArea, City, Country, PostalAddress, EntryPoint, ImageObject, Person, SearchAction, Offer |
| `tarifs.html` | WebPage, BreadcrumbList, ItemList, Service, Offer, PriceSpecification, FAQPage, Question, Answer, Country, ListItem |
| `devis.html` | ContactPage, BreadcrumbList, Organization, Service, Offer, PriceSpecification, ListItem, Country |
| `creation-site-web-agde.html` | WebPage, BreadcrumbList, ProfessionalService, FAQPage, Question, Answer, PostalAddress, ListItem |
| `seo-local-herault.html` | idem ci-dessus |
| `estimateur.html` | WebPage, ProfessionalService |
| `guide-seo-local.html` | WebPage, Organization, Person |
| `blog/index.html` | Blog, BreadcrumbList, Organization, ListItem |
| `blog/*.html` (3 articles) | Article, WebPage, BreadcrumbList, FAQPage, Question, Answer, Organization, Person, ListItem |

Conclusion : **le ticket P2 du brief initial *« Ajouter LocalBusiness + BreadcrumbList + FAQPage »* est largement caduc.** Le site est déjà très bien équipé. Le type `ProfessionalService` couvre la fonction SEO de `LocalBusiness` (hiérarchie Schema.org : ProfessionalService ⊂ LocalBusiness ⊂ Organization).

Restes possibles (pas critiques) :

- Validation outillée via le Rich Results Test de Google sur chaque page principale.
- Vérification de cohérence NAP (nom, adresse, téléphone) entre tous les blocs JSON-LD du site.
- Eventuellement consolidation : certaines pages ont plusieurs blocs JSON-LD séparés, on pourrait les fusionner en `@graph` unique pour la lisibilité crawler. Cosmétique.

---

## 6. Open Graph / Twitter Cards

**Statut : à valider page par page (audit incomplet en live)**

À vérifier via le script `run-sprint0-audit.sh` (lot 5) :

- Présence de og:title, og:description, og:image, og:url, twitter:card sur chaque page principale.
- Cohérence og:url avec canonical.
- Format twitter:card = summary_large_image sur les pages commerciales.

Le repo contient déjà `og-image.jpg` (165 Ko, à la racine) — bonne pratique.

---

## 7. Performance / ressources lourdes

**Statut : très bon, optimisations marginales possibles**

Mesures live home (Cloudflare cache actif) :

- DOMContentLoaded : 105 ms
- Load event : 338 ms
- 29 requêtes réseau

Inventaire polices repo (`portfolio/fonts/`) :

| Fichier | Format | Taille |
|---------|--------|--------|
| `Brandon_reg.otf` | .otf | 85 Ko |
| `Morena-Bold-Embedded.otf` | .otf | 40 Ko |
| `Morena-Embedded.otf` | .otf | 40 Ko |
| `Morena-SemiBold-Embedded.otf` | .otf | 40 Ko |
| `Morena-W300-Embedded-1.otf` | .otf | 40 Ko |
| `Morena-W400-Embedded-2.otf` | .otf | 40 Ko |
| **Total** | | **285 Ko** |

285 Ko de fonts c'est raisonnable. Conversion .otf → .woff2 reste pertinente (gain typique -50 à -70 %, soit ~140-200 Ko économisés) mais c'est du P2, pas du P0.

Ressources externes en prod :

- `frontend-cdn.perplexity.ai/.../FKGroteskNeue.woff2` → 503, orphelin, non trouvé dans le repo. À investiguer dans `assets/js/analytics.js` ou les CSS générés.
- `unpkg.com/lenis@1.1.18/dist/lenis.min.js` → CDN externe public. Bundler localement améliorerait la résilience (si unpkg tombe, le smooth scroll casse) et la perf (un round-trip TLS de moins).

Mesure Core Web Vitals réelle (Lighthouse mobile + desktop) à lancer avant toute optimisation perf — le repo contient déjà 3 PDF *PageSpeed Insights* de février 2026 mais une mesure fraîche post-corrections P0 sera utile.

---

## 8. Bugs UX / techniques détectés

**Statut : à corriger en P1**

### CTAs morts (`href="#"`)

Confirmé par grep sur le repo : **27 occurrences sur 16 fichiers.**

Distribution :

| Fichier | Occurrences |
|---------|-------------|
| `index.html` | 5 |
| `devis.html` | 3 |
| `merci.html` | 3 |
| `blog/seo-local-herault-restaurants-artisans.html` | 2 |
| `blog/combien-coute-site-vitrine-tpe-2026.html` | 2 |
| `blog/creation-site-internet-agde-guide-complet-2026.html` | 2 |
| 10 autres pages | 1 chacune |

Toutes ces ancres vides empêchent le tracking propre des clics et créent une UX cassée si la cible attendue (`#contact`, embed Cal.com, lien externe) n'existe pas. À pointer vers la cible réelle.

### Encodage cassé sur la section Assistant WhatsApp IA (`index.html`)

Lignes 1804-1830 — accents perdus :

```html
<div class="wa-feature-title">Reservations automatiques</div>
<div class="wa-feature-title">Posts reseaux sociaux</div>
<div class="wa-feature-title">Reponses clients 24/7</div>
<div class="wa-feature-desc">Statistiques de frequentation, reservations et interactions directement dans votre conversation.</div>
```

Le reste du site est correctement accentué. Probable problème d'encodage (latin-1 vs UTF-8) sur un copier-coller de cette section uniquement. Re-saisir avec accents corrects.

---

## Synthèse — Sprint 1 corrigé

### P0 — RGPD / analytics / consentement (1 à 3h selon option)

Le seul vrai P0. Risque légal + crédibilité.

- Option A (recommandée) : retirer GA4 + Clarity. La politique RGPD redevient cohérente.
- Option B : installer Tarteaucitron self-hosted, conditionner GA4 + Clarity au consentement, mettre à jour `/rgpd-confidentialite` avec mention explicite des outils, finalités, durée, retrait.

Critères d'acceptation :

- En navigation privée, avant clic « Accepter », aucun appel réseau vers `googletagmanager.com` ni `clarity.ms`.
- Après clic « Refuser », aucun appel non plus.
- Après clic « Accepter », GA4 et Clarity peuvent se charger.
- La page `/rgpd-confidentialite` ne contient plus de phrase contradictoire.

Fichiers concernés : `assets/js/analytics.js`, `_headers` (CSP), `rgpd-confidentialite.html`, `index.html` et toutes les pages qui chargent `analytics.js`.

### P1 — Hygiène technique (2 à 3h)

- Réparer les 27 CTAs `href="#"` (pointer vers `#contact`, Cal.com embed, ou suppression si pas de cible).
- Réparer l'encodage de la section Assistant WhatsApp IA dans `index.html` (lignes 1804-1830).
- Investiguer et supprimer la font Perplexity orpheline (chercher dans `assets/js/analytics.js` et CSS).
- Bundler `lenis` localement (ou justifier le CDN unpkg).
- Convertir polices `.otf` → `.woff2` (gain ~140-200 Ko).

### P2 — Mesures et validations (2 à 3h)

- Lighthouse baseline mobile + desktop (avant toute optim perf).
- Validation Rich Results Test sur chaque page principale.
- Vérification cohérence NAP entre tous les blocs JSON-LD du site.
- Audit Open Graph / Twitter Cards page par page.

### P3 — Conversion page devis (2 à 3h, optionnel)

- Bloc « Ce qui se passe après votre demande » près du formulaire.
- Bloc « Vous pouvez demander un devis pour » avec exemples concrets.
- Réassurance : réponse sous 48h, sans engagement, audit possible, accompagnement local.
- Mention RGPD courte près du formulaire.

### Sprints séparés (hors sprint correctif)

- Page produit dédiée Assistant WhatsApp IA (sprint produit, copywriting + offre).
- Google Business Profile + cohérence NAP + backlinks locaux (sprint SEO off-site).

---

## Tableau de décision rapide

| Sujet | Statut | Action | Priorité |
|-------|--------|--------|----------|
| www → non-www | OK (Cloudflare natif) | Test de non-régression | — |
| Canonical | OK | Aucune | — |
| Sitemap | OK | Aucune | — |
| robots.txt | OK | Aucune | — |
| RGPD vs tracking | KO | Option A ou B | **P0** |
| GA4 sans consentement | KO | Bloquer ou supprimer | **P0** |
| Clarity sans consentement | KO | Bloquer ou supprimer | **P0** |
| Cloudflare Insights | OK (cookie-less) | Mentionner dans politique | P2 |
| JSON-LD home | excellent | Aucune | — |
| BreadcrumbList | déjà présent | Aucune | — |
| FAQPage | déjà présent | Aucune | — |
| Polices .otf | 285 Ko total | Convertir .woff2 | P1 |
| Font Perplexity orpheline | 503 en prod | Investiguer + supprimer | P1 |
| Lenis depuis unpkg | sous-optimal | Bundler local | P1 |
| CTAs `href="#"` (27 occurrences) | UX cassée | Pointer vers cibles réelles | **P1** |
| Encodage Assistant WhatsApp | bug confirmé | Re-saisir accents (lignes 1804-1830) | **P1** |
| Open Graph | à auditer toutes pages | Audit complet | P2 |
| Page devis | OK fonctionnel | Réassurance | P3 |
| Core Web Vitals | non mesuré | Lighthouse baseline | P2 |
| Page Assistant WhatsApp IA | hors périmètre | Sprint produit | séparé |

---

## Reproductibilité

L'audit live a été effectué le 3 mai 2026 via inspection navigateur (Chrome MCP) + lecture du repo `portfolio/`. Pour reproduire les vérifications côté serveur de manière automatisée :

```bash
chmod +x scripts/run-sprint0-audit.sh
./scripts/run-sprint0-audit.sh
```

Le script `scripts/run-sprint0-audit.sh` collecte les preuves brutes (curl headers, grep dans le repo, inventaire fichiers) et écrit le rapport raw dans `_audit-reports/sprint0-audit-terrain-raw.md`. Le présent document en est la version analysée et priorisée.
