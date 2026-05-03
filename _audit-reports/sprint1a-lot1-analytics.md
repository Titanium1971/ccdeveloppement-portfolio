# Sprint 1A — Lot 1/4 : refonte `assets/js/analytics.js` (RGPD Option B)

**Date** : 2026-05-03
**Branche** : `sprint1a-rgpd-consentement`
**Périmètre** : `assets/js/analytics.js` (uniquement)
**Hors périmètre lot 1** : HTML pages, `_headers`, `rgpd-confidentialite.html`

---

## 1. État avant / après

### Avant (v1.x)

- `analytics.js` chargeait **automatiquement** `gtag.js` et `clarity.js` au chargement de page,
  **avant tout consentement utilisateur**.
- Un Consent Mode v2 était initialisé en `denied`, mais **aucun mécanisme** n'appelait
  `gtag('consent', 'update', ...)` après acceptation : le bandeau écrivait juste
  `cc_cookie_consent=granted` dans `localStorage` puis appelait `gtag('consent','update',...)`,
  mais les scripts tiers étaient déjà chargés réseau (cf. requêtes `googletagmanager.com` /
  `clarity.ms` visibles en navigation privée avant clic).
- Le bandeau ne proposait que **deux** boutons : `Accepter` / `Refuser`, avec le bouton refuser
  en simple lien gris peu contrasté → non conforme CNIL "refuser aussi simple qu'accepter".
- Aucun moyen de personnaliser (granularité GA4 vs Clarity).
- Aucun lien permanent pour modifier ses préférences.
- Aucune révocation : un user qui changeait d'avis vers refus n'avait pas ses cookies supprimés.

**Verdict CNIL** : non conforme — appels réseau pré-consentement, refus pas équivalent à acceptation.

### Après (v2.0.0)

- **Aucun appel réseau** vers `googletagmanager.com`, `google-analytics.com`,
  `analytics.google.com`, `region1.google-analytics.com`, `clarity.ms` tant que l'utilisateur
  n'a pas explicitement coché/cliqué pour accepter.
- Bandeau avec **3 boutons à hiérarchie visuelle équivalente** :
  `[Tout refuser]` `[Personnaliser]` `[Tout accepter]` — même padding, même taille,
  contraste équivalent (gris foncé `#374151` vs bleu accent `#0066cc`).
- Modale de personnalisation avec 2 cases à cocher granulaires (GA4, Clarity), 3 boutons
  d'action (Enregistrer / Tout refuser / Tout accepter), bouton fermeture, support Escape.
- **Cases pré-décochées** au premier passage (consentement = null), reprennent l'état
  enregistré sinon.
- Révocation propre :
  - GA4 → `gtag('consent','update',{analytics_storage:'denied', ...})`
  - Clarity → `clarity('consentv2',{ad_Storage:'denied', analytics_Storage:'denied'})`
    + `clarity('consent', false)`
- Suppression des cookies `_ga`, `_ga_*`, `_gid`, `_gat`, `_clck`, `_clsk`, `CLID`, `ANONCHK`,
  `MR`, `MUID`, `SM` sur le domaine courant **et** `.ccdeveloppement.eu`.
- Lien permanent : tout élément avec `[data-cookie-preferences]` rouvre la modale.
- Clé `localStorage` versionnée : `ccdev_cookie_consent_v1` (incrément sémantique permettra
  de redemander le consentement après un changement majeur de politique).

---

## 2. Schéma des fonctions

```
init()
 ├─ bindPreferenceLinks()           [écoute clics sur [data-cookie-preferences]]
 ├─ getConsent()                    [lit localStorage, valide version]
 │
 ├─ Si consent === null
 │   └─ showConsentBanner()
 │       ├─ injectStyles()          [CSS prefixé .ccdev-cookie-*]
 │       ├─ DOM bandeau (3 boutons)
 │       │   ├─ [Tout refuser]      → handleRefuseAllFromBanner()
 │       │   │   ├─ saveConsent({analytics:false, clarity:false})
 │       │   │   ├─ deleteAnalyticsCookies()
 │       │   │   └─ closeBanner()
 │       │   ├─ [Personnaliser]      → closeBanner() + showPreferencesPanel()
 │       │   └─ [Tout accepter]      → handleAcceptAllFromBanner()
 │       │       ├─ saveConsent({analytics:true, clarity:true})
 │       │       ├─ loadGoogleAnalytics()
 │       │       ├─ loadMicrosoftClarity()
 │       │       ├─ initConsentControlledTracking()
 │       │       └─ closeBanner()
 │
 └─ Si consent existe
     ├─ Si consent.analytics
     │   ├─ loadGoogleAnalytics()    [injecte gtag.js + dataLayer + config]
     │   └─ initConsentControlledTracking()
     │       ├─ bindFormStart()      [#devisForm focus]
     │       ├─ bindFormSubmit()     [#devisForm submit + /merci]
     │       ├─ bindCtaClicks()      [wa.me / cal.com / tel: / mailto:]
     │       ├─ bindScrollDepth()    [25/50/75/100%]
     │       └─ bindOutboundClicks() [hors ccdeveloppement.eu]
     └─ Si consent.clarity
         └─ loadMicrosoftClarity()   [injecte snippet + clarity('consentv2', ...)]

showPreferencesPanel()                [modale, déclenchée via openPreferences()]
 ├─ Cases pré-cochées selon getConsent() (décochées si null)
 ├─ [Tout refuser]      → handleRefuseAllFromModal()
 │   ├─ revokeGoogleAnalytics() si prev.analytics
 │   ├─ revokeMicrosoftClarity() si prev.clarity
 │   ├─ saveConsent({false, false})
 │   ├─ deleteAnalyticsCookies()
 │   └─ closeModal()
 ├─ [Enregistrer]        → handleSaveFromModal(wantA, wantC)
 │   ├─ Pour analytics : revoke si transition true→false, load si false→true
 │   ├─ Pour clarity   : idem
 │   ├─ saveConsent({wantA, wantC})
 │   ├─ deleteAnalyticsCookies() si l'un des deux passe à false
 │   └─ closeModal()
 └─ [Tout accepter]      → handleAcceptAllFromModal()
     ├─ load des deux services (idempotent)
     └─ initConsentControlledTracking()

API publique :
 - window.openPreferences()
 - window.ccdevCookieConsent.{openPreferences, getConsent}
```

### Flag interne `trackingActive`

- Évite que des events `gtag('event', ...)` partent après une révocation dans la session
  courante (les listeners ont été branchés mais `safeGtag` court-circuite si le flag tombe
  à `false`).
- Set à `true` par `initConsentControlledTracking()`, à `false` par
  `handleRefuseAllFromModal()` / `handleSaveFromModal()` quand analytics passe à `false`.

### Idempotence

- `loadGoogleAnalytics()` et `loadMicrosoftClarity()` sont protégés par `gaLoaded` /
  `clarityLoaded` : un second appel ne réinjecte pas le `<script>`, mais réémet un
  `consent update granted` au cas où l'état Consent Mode aurait été révoqué entretemps.
- `initConsentControlledTracking()` est protégé par `trackingListenersBound` : les
  listeners ne sont attachés qu'une seule fois, le flag `trackingActive` gère
  l'activation/désactivation logique.

---

## 3. Comment tester en navigation privée

### Test 1 — premier passage, aucun consentement

```bash
# Ouvrir le site en fenêtre privée Chrome / Firefox / Safari
# DevTools > Network, filtrer "Other" + "JS" + "XHR"
# Recharger la page
```

**Attendu** :
- Aucune requête vers `googletagmanager.com`, `google-analytics.com`, `clarity.ms`.
- Bandeau visible en bas de page avec 3 boutons côte à côte.
- `localStorage.getItem('ccdev_cookie_consent_v1')` = `null`.

### Test 2 — refus

- Cliquer `Tout refuser`.
- Bandeau disparaît. Aucune requête réseau analytics.
- `localStorage` : `{"version":1,"analytics":false,"clarity":false,"timestamp":"..."}`
- Recharger la page : pas de bandeau, toujours aucune requête analytics.
- Cookies `_ga*`, `_clck`, `_clsk`, `MUID` absents.

### Test 3 — acceptation totale

- Vider `localStorage`, recharger.
- Cliquer `Tout accepter`.
- Network : requêtes `gtag/js?id=G-NZ2MQMB67H` + `clarity.ms/tag/wbyffo03d6` apparaissent.
- Cookies `_ga`, `_ga_NZ2MQMB67H`, `_clck` créés.
- Test events : focus champ `#devisForm` → event `form_start`. Scroller 25% → `scroll_depth`.

### Test 4 — granularité (Personnaliser)

- Vider `localStorage`, recharger, cliquer `Personnaliser`.
- Cases **toutes décochées** (premier passage).
- Cocher uniquement `Google Analytics 4`. Cliquer `Enregistrer mes choix`.
- Network : seul `gtag.js` est chargé. Aucune requête vers `clarity.ms`.
- Recharger : cohérent (GA4 reload, Clarity non).

### Test 5 — révocation (changement d'avis)

- Avec analytics + clarity acceptés, cliquer le lien footer
  `[data-cookie-preferences]` (lot 4 ajoutera ce lien).
- Décocher les deux, cliquer `Enregistrer`.
- Vérifier console réseau : pas de **nouvelles** requêtes analytics.
- Vérifier cookies : `_ga*`, `_clck` supprimés (`Application > Cookies`).
- Note : les requêtes déjà parties dans la session avant révocation ne peuvent
  évidemment pas être annulées (limite intrinsèque navigateur).

### Test 6 — Escape modale

- Ouvrir la modale, presser `Esc`.
- Modale se ferme, focus revient sur l'élément précédent.
- Si aucun consentement enregistré, le bandeau réapparaît.

### Test rapide en console

```js
// Vider l'état et rejouer
localStorage.removeItem('ccdev_cookie_consent_v1');
location.reload();

// Forcer la modale
window.openPreferences();

// Lire l'état actuel
window.ccdevCookieConsent.getConsent();
```

---

## 4. Limites connues / points de vigilance

### 4.1 — Cookies Clarity persistants

- `MUID` est un cookie **Microsoft 1st-party** posé par Clarity sur le domaine ; il peut
  être également posé par d'autres services Microsoft (Bing, Outlook). La suppression côté
  `document.cookie` fonctionne pour le domaine courant, mais si l'utilisateur a navigué
  Bing/Outlook récemment, `MUID` peut être recréé via leurs propres scripts (hors de notre
  contrôle).
- **Action côté compte Clarity à vérifier (manuel, hors lot 1)** :
  - Dashboard Clarity > Settings > Privacy > activer "GDPR consent mode" si dispo.
  - Vérifier que "Mask sensitive content" est activé pour limiter la collecte de PII.
  - Vérifier la durée de rétention (par défaut 13 mois).

### 4.2 — Cookies sur sous-domaines

- La suppression cible `domain=ccdeveloppement.eu` et `domain=.ccdeveloppement.eu` mais
  ne peut pas effacer un cookie posé sur un sous-domaine inaccessible depuis le scope
  courant (ex: cookie posé par un widget tiers sur `widget.ccdeveloppement.eu`).
- En pratique, le portfolio CC Développement est servi exclusivement depuis le domaine
  apex `ccdeveloppement.eu` (Cloudflare Pages), donc cette limite est théorique.

### 4.3 — `_ga_*` et streams GA4 multiples

- GA4 crée un cookie `_ga_<STREAM_ID>` par stream. Le code détecte les cookies préfixés
  `_ga_` via parsing `document.cookie` et tente leur suppression. Si `document.cookie`
  est filtré par le navigateur (ex: cookies `httpOnly`, ce qui n'est pas le cas pour GA4),
  la suppression échouerait silencieusement.

### 4.4 — Consent Mode v2 et "wait_for_update"

- L'ancien code utilisait `wait_for_update: 500` pour permettre au tag GA4 de patienter
  500ms avant d'envoyer le 1er hit. La nouvelle implémentation **ne charge pas du tout**
  GA4 avant consentement, donc ce mécanisme est inutile : pas de hit en attente à patcher.
  C'est plus simple et plus sûr.

### 4.5 — Single Page Apps

- Le site portfolio est un site statique multi-pages (HTML pur) : chaque navigation
  recharge la page → `init()` est rejoué → cohérent.
- Si un jour le site passe en SPA, il faudra ajouter un trigger de `gtag('event', 'page_view')`
  au changement de route. Hors scope sprint 1A.

### 4.6 — Focus trap modale

- L'implémentation est minimale : focus initial sur le bouton de fermeture + écoute Escape.
- Pas de cycle Tab/Shift+Tab maintenu strictement à l'intérieur de la modale (le navigateur
  peut sortir focus vers la barre d'URL ou autre extension).
- Suffisant pour conformité de base ; un focus trap complet (lib `focus-trap`) ne serait
  utile que pour une UX accessibilité avancée.

### 4.7 — Microsoft Clarity Consent API v2

- L'API `clarity('consentv2', { ad_Storage, analytics_Storage })` est documentée et
  remplace l'ancienne `clarity('consent', true|false)`. On appelle aussi
  `clarity('consent', false)` à la révocation par sécurité (rétro-compatibilité avec
  les versions antérieures du tag distribué par Microsoft).
- `ad_Storage` reste **systématiquement à `'denied'`** (le portfolio ne fait pas de pub
  personnalisée et n'a pas vocation à en faire).

### 4.8 — Clé localStorage versionnée

- `ccdev_cookie_consent_v1` : si la liste des services change (ajout d'un 3e tracker,
  ou changement de finalité majeur), incrémenter en `_v2` invalide automatiquement les
  consentements précédents → bandeau réaffiché. Conforme RGPD si finalités modifiées.

---

## 5. Hors scope lot 1 (à traiter dans les lots suivants)

- **Lot 2** : retirer `<link rel="preconnect" href="https://www.googletagmanager.com">`
  et équivalent Clarity dans HTML + `_headers`. Conserver la CSP. Sans ce lot, le bandeau
  fonctionne mais le navigateur établit quand même une connexion TCP/TLS pré-consentement
  vers GTM/Clarity → fuite réseau résiduelle.
- **Lot 3** : ajouter le lien permanent `<a data-cookie-preferences href="#">Gérer mes
  préférences cookies</a>` dans le footer global (idempotent : ne pas ajouter de doublon).
- **Lot 4** : mettre à jour `rgpd-confidentialite.html` pour refléter la réalité technique
  (consentement préalable, granularité, services, durée, droit de retrait).

---

## 6. Vérifications automatiques recommandées

```bash
# Aucun chargement automatique de gtag/clarity hors fonction de chargement contrôlé
grep -nE "googletagmanager\.com|clarity\.ms" assets/js/analytics.js

# Doivent apparaître UNIQUEMENT dans loadGoogleAnalytics() / loadMicrosoftClarity()
# Pas dans le scope global du IIFE.

# Vérifier l'ordre des boutons HTML dans le bandeau (gauche → droite)
grep -nE 'data-action="(refuse-all|customize|accept-all)"' assets/js/analytics.js
# Attendu : ordre refuse-all, customize, accept-all (cf. CNIL)

# Vérifier suppression cookies
grep -nE "deleteAnalyticsCookies|expires=Thu, 01 Jan 1970" assets/js/analytics.js
```

---

**Statut lot 1** : ✅ Implémenté.
**Prochaine étape** : lot 2 (preconnects HTML + `_headers`).
