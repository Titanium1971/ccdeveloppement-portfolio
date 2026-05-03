# Sprint 1A — RGPD Option B v2 — Rapport final

**Date** : 2026-05-03
**Branche** : `sprint1a-rgpd-consentement`
**Périmètre** : Mise en conformité RGPD du portfolio CC Développement (CNIL 2026)
**Lot** : 4/4 — Validation finale + rapport sprint
**Auteur Lot 4** : Claude Code (validation, aucun fichier de prod modifié)

---

## Décision

**Option B v2** : Conservation de Google Analytics 4 (`G-NZ2MQMB67H`) + Microsoft Clarity (`wbyffo03d6`), chargés **uniquement après consentement explicite** de l'utilisateur. Bandeau de consentement custom intégré dans `assets/js/analytics.js` (vanilla JS, sans dépendance), modale "Personnaliser" granulaire, lien permanent en footer pour reconfigurer le choix.

Pas de migration vers Cloudflare Web Analytics ni de plateforme de consentement tierce (Axeptio, Didomi, Cookiebot) — solution interne maintenable.

---

## Fichiers modifiés (Sprint 1A)

| # | Fichier | Lot | Nature |
|---|---------|-----|--------|
| 1 | `assets/js/analytics.js` | Lot 1 | Réécriture complète v2.0.0 — système consentement RGPD |
| 2 | `index.html` | Lot 2 | Suppression preconnects GA4/Clarity + ajout lien cookies footer |
| 3 | `devis.html` | Lot 2 | id. |
| 4 | `tarifs.html` | Lot 2 | id. |
| 5 | `estimateur.html` | Lot 2 | id. |
| 6 | `creation-site-web-agde.html` | Lot 2 | id. |
| 7 | `seo-local-herault.html` | Lot 2 | id. |
| 8 | `guide-seo-local.html` | Lot 2 | id. |
| 9 | `comparatif-tarifs.html` | Lot 2 | id. |
| 10 | `guide-tarifs.html` | Lot 2 | id. |
| 11 | `blog/index.html` | Lot 2 | id. |
| 12 | `blog/combien-coute-site-vitrine-tpe-2026.html` | Lot 2 | id. |
| 13 | `blog/creation-site-internet-agde-guide-complet-2026.html` | Lot 2 | id. |
| 14 | `blog/seo-local-herault-restaurants-artisans.html` | Lot 2 | Ajout lien cookies footer (pas de preconnects à retirer) |
| 15 | `mentions-legales.html` | Lot 2 | Ajout lien cookies footer uniquement |
| 16 | `merci.html` | Lot 2 | Ajout lien cookies footer uniquement |
| 17 | `rgpd-confidentialite.html` | Lot 2 + 3 | Lien cookies footer + réécriture section 6 (cookies) |
| 18 | `_audit-reports/sprint1a-lot1-analytics.md` | Lot 1 | Rapport Lot 1 (nouveau) |
| 19 | `_audit-reports/sprint1a-lot2-html-headers.md` | Lot 2 | Rapport Lot 2 (nouveau) |
| 20 | `_audit-reports/sprint1a-lot3-rgpd.md` | Lot 3 | Rapport Lot 3 (nouveau) |

**Total** : 17 fichiers de production (1 JS + 16 HTML) + 3 rapports d'audit.

**Cas `_headers`** : Cas 2 — directive `Link:` explicite GA4/Clarity ABSENTE du fichier `_headers`. Le header `Link` observé en prod sur ccdeveloppement.eu est généré automatiquement par Cloudflare Pages (Early Hints depuis le scan HTML). Une fois les preconnects retirés du HTML (Lot 2), le header HTTP sera régénéré automatiquement après purge cache Cloudflare. **`_headers` n'a donc pas été modifié.**

---

## Comportement avant

1. `assets/js/analytics.js` chargeait `gtag.js` + `clarity.ms` au chargement de chaque page, sans consentement.
2. 13 pages HTML déclaraient des `<link rel="preconnect">` vers `googletagmanager.com` / `clarity.ms` (résolution DNS prématurée).
3. Header HTTP `Link:` injecté par Cloudflare référençait `googletagmanager.com` et `clarity.ms` (Early Hints).
4. Aucun bandeau de consentement, aucun choix utilisateur possible.
5. `rgpd-confidentialite.html` contenait une phrase contradictoire ("ne utilise pas de cookies publicitaires ni d'outils de tracking marketing tiers") en présence d'un tracking actif → non-conformité CNIL.

## Comportement après

1. `gtag.js` et `clarity.ms` ne sont chargés **qu'après consentement explicite** (fonctions `loadGoogleAnalytics` ligne 288 et `loadMicrosoftClarity` ligne 333 de `analytics.js`).
2. Bandeau bottom avec 3 boutons à hiérarchie égale : `Tout refuser` → `Personnaliser` → `Tout accepter`.
3. Modale "Personnaliser" avec checkboxes **non pré-cochées** au premier passage (`initialAnalytics = existing ? !!existing.analytics : false`, ligne 194).
4. Révocation : `gtag('consent','update', denied)` et `clarity('consentv2', denied)` + `clarity('consent', false)` appelés **AVANT** `deleteAnalyticsCookies()` (handlers lignes 580-625).
5. Lien permanent `[data-cookie-preferences]` ajouté **une seule fois** dans le footer de chaque page (16 pages).
6. Section 6 de `rgpd-confidentialite.html` réécrite : mention explicite GA4 + Microsoft Clarity, droits utilisateur, durées de conservation.

Extraits de logs (Lot 4 — vérifications) :

```
$ grep -rn 'preconnect.*googletagmanager\|preconnect.*clarity' --include='*.html' .
OK aucun preconnect GA/Clarity restant dans HTML

$ grep -F 'n utilise pas de cookies publicitaires...' rgpd-confidentialite.html
OK phrase contradictoire retirée
```

---

## Résultats des 7 tâches de validation

### Tâche 1 — Aucun preconnect GA4/Clarity dans HTML — ✅ OK

```
$ grep -rn 'preconnect.*googletagmanager\|preconnect.*clarity' --include='*.html' .
OK aucun preconnect GA/Clarity restant dans HTML
```

**Statut** : ✅ OK — aucun `preconnect` résiduel dans les 16 fichiers HTML.

---

### Tâche 2 — Idempotence du lien "Gérer mes préférences cookies" — ✅ OK

```
$ for f in <12 pages> ; do echo "$f : $(grep -c 'data-cookie-preferences' $f)" ; done
index.html : 1
devis.html : 1
tarifs.html : 1
estimateur.html : 1
creation-site-web-agde.html : 1
seo-local-herault.html : 1
guide-seo-local.html : 1
comparatif-tarifs.html : 1
guide-tarifs.html : 1
mentions-legales.html : 1
rgpd-confidentialite.html : 1
blog/index.html : 1
```

Vérification complémentaire (autres pages présentes dans le repo) :
```
merci.html : 1
blog/combien-coute-site-vitrine-tpe-2026.html : 1
blog/creation-site-internet-agde-guide-complet-2026.html : 1
blog/seo-local-herault-restaurants-artisans.html : 1
```

**Statut** : ✅ OK — chaque page contient exactement **une** occurrence de `data-cookie-preferences`. Aucun doublon, aucune omission.

---

### Tâche 3 — `analytics.js` ne charge GA4/Clarity qu'après consentement — ✅ OK

**3.1 Localisation des chargements réseau**
```
$ grep -nE 'googletagmanager.com/gtag/js|clarity.ms/tag/' assets/js/analytics.js
323:      s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(GA_ID);
347:        t.src = 'https://www.clarity.ms/tag/' + encodeURIComponent(i);
```
- Ligne 323 : à l'intérieur de `loadGoogleAnalytics()` (ligne 288 → 331).
- Ligne 347 : à l'intérieur de `loadMicrosoftClarity()` (ligne 333 → 366).
- **Aucun chargement au niveau racine du fichier.** ✅

**3.2 Présence des 10 fonctions clés**
```
46:  function getConsent()
58:  function saveConsent(consent)
138: function showConsentBanner()
187: function showPreferencesPanel()
288: function loadGoogleAnalytics()
333: function loadMicrosoftClarity()
368: function revokeGoogleAnalytics()
381: function revokeMicrosoftClarity()
393: function deleteAnalyticsCookies()
530: function initConsentControlledTracking()
```
✅ 10/10 présentes.

**3.3 API Clarity v2 et révocation**
```
337,359: window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'granted' })
384:     window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'denied' })
385:     window.clarity('consent', false)
```
✅ `consentv2` granted à l'opt-in, `consentv2` denied + `consent false` au revoke.

**3.4 gtag consent denied**
```
293, 371: window.gtag('consent', 'update', {
            analytics_storage: 'denied' (revoke) / 'granted' (load),
            ad_storage: 'denied',
            ad_user_data: 'denied',
            ad_personalization: 'denied'
          })
309:      gtag('consent', 'default', { analytics_storage: 'granted', ad_storage: 'denied', ... })
```
✅ Toutes les clés `ad_*` sont denied conformément à RGPD (pas de pub).

**3.5 Clé localStorage**
```
36: var CONSENT_KEY = 'ccdev_cookie_consent_v1';
```
✅ Conforme.

**3.6 Cases non pré-cochées au premier passage**
```js
// ligne 193-195
var existing = getConsent();
var initialAnalytics = existing ? !!existing.analytics : false;
var initialClarity = existing ? !!existing.clarity : false;
```
✅ Si `getConsent() === null`, `initialAnalytics` et `initialClarity` valent `false` → checkboxes décochées.

**3.7 Ordre des boutons du bandeau**
```html
<!-- lignes 157-159 -->
<button data-action="refuse-all">Tout refuser</button>
<button data-action="customize">Personnaliser</button>
<button data-action="accept-all">Tout accepter</button>
```
✅ Ordre exact : `Tout refuser` → `Personnaliser` → `Tout accepter`.

**3.8 Ordre revoke → delete**
```
564: deleteAnalyticsCookies()                  // handleRefuseAllFromBanner — pas de revoke car rien chargé
585: if (prevA) revokeGoogleAnalytics()        // handleRefuseAllFromModal
586: if (prevC) revokeMicrosoftClarity()
589: deleteAnalyticsCookies()
600: revokeGoogleAnalytics()                    // handleSaveFromModal — granular
612: revokeMicrosoftClarity()
621: deleteAnalyticsCookies()
```
✅ Dans tous les flux de révocation, `revoke*` précède `deleteAnalyticsCookies()`.

**Statut Tâche 3** : ✅ OK.

---

### Tâche 4 — `rgpd-confidentialite.html` cohérent — ✅ OK

```
$ grep -F 'n utilise pas de cookies publicitaires ni d outils de tracking marketing tiers' rgpd-confidentialite.html
OK phrase contradictoire retirée

$ grep -i 'Google Analytics 4\|Microsoft Clarity' rgpd-confidentialite.html
<li><strong>Google Analytics 4</strong> : mesure de fréquentation, pages consultées, événements de conversion comme les demandes de devis ou clics vers WhatsApp et Cal.com.</li>
<li><strong>Microsoft Clarity</strong> : analyse de l'expérience utilisateur, cartes de chaleur et enregistrements de session afin d'améliorer l'ergonomie du site.</li>
```

**Statut** : ✅ OK — phrase contradictoire retirée, mentions GA4 + Clarity explicites.

---

### Tâche 5 — `_headers` : CSP intacte, aucune directive Link GA4/Clarity — ✅ OK

```
$ grep -n 'googletagmanager.com\|clarity.ms' _headers
7:  Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com https://www.google-analytics.com https://www.clarity.ms ... ; connect-src 'self' https://www.google-analytics.com https://analytics.google.com https://region1.google-analytics.com ... https://www.clarity.ms ...
```
✅ CSP `script-src` et `connect-src` autorisent GA4 + Clarity (nécessaire post-consentement).

```
$ grep -i '^[[:space:]]*Link:.*googletagmanager\|^[[:space:]]*Link:.*clarity' _headers
OK aucune directive Link GA4/Clarity dans _headers
```
✅ Cas 2 confirmé — aucune directive `Link:` explicite à GA4/Clarity. Le header HTTP `Link` observé en prod est généré par Cloudflare Pages (Early Hints automatiques basés sur le HTML).

**Statut** : ✅ OK.

---

### Tâche 6 — `git status` : périmètre cohérent — ✅ OK

```
$ git status --short
 M assets/js/analytics.js                                          # Lot 1
 M index.html                                                      # Lot 2
 M devis.html                                                      # Lot 2
 M tarifs.html                                                     # Lot 2
 M estimateur.html                                                 # Lot 2
 M creation-site-web-agde.html                                     # Lot 2
 M seo-local-herault.html                                          # Lot 2
 M guide-seo-local.html                                            # Lot 2
 M comparatif-tarifs.html                                          # Lot 2
 M guide-tarifs.html                                               # Lot 2
 M mentions-legales.html                                           # Lot 2
 M merci.html                                                      # Lot 2 (lien cookies seulement)
 M rgpd-confidentialite.html                                       # Lot 2 + Lot 3
 M blog/index.html                                                 # Lot 2
 M blog/combien-coute-site-vitrine-tpe-2026.html                   # Lot 2
 M blog/creation-site-internet-agde-guide-complet-2026.html        # Lot 2
 M blog/seo-local-herault-restaurants-artisans.html                # Lot 2
?? .claude/scheduled_tasks.lock                                     # bruit harness, à ignorer
?? _audit-reports/sprint1a-lot1-analytics.md                        # rapport Lot 1
?? _audit-reports/sprint1a-lot2-html-headers.md                     # rapport Lot 2
?? _audit-reports/sprint1a-lot3-rgpd.md                             # rapport Lot 3
```

**Statut** : ✅ OK
- 1 fichier JS modifié (analytics.js)
- 16 fichiers HTML modifiés (12 listés dans la Tâche 2 + merci.html + 3 inner blog)
- `_headers` non modifié → cohérent avec le Cas 2 (CSP intacte, pas de directive Link explicite à nettoyer)
- Aucun fichier hors périmètre (pas de touche aux CTAs, polices, Lenis, OG, Schema)
- `.claude/scheduled_tasks.lock` = artefact harness Claude, à exclure du commit

> Note : le brief évoquait "13 fichiers HTML". Le compte réel est **16 HTML** car le Lot 2 a aussi ajouté le lien cookies sur 3 pages qui n'avaient pas de preconnect (`mentions-legales.html`, `merci.html`, `rgpd-confidentialite.html`). Voir `sprint1a-lot2-html-headers.md` pour le détail.

---

### Tâche 7 — Commandes de test post-déploiement préparées — ✅ OK

Voir section "Commandes de vérification post-déploiement" plus bas.

---

## Tests manuels à effectuer par Cyril

À exécuter **après déploiement Cloudflare Pages** + **purge cache Cloudflare** :

### 1. Vérifier disparition des preconnects côté HTML servi
```bash
curl -sS https://ccdeveloppement.eu/ | grep -i preconnect | grep -E 'googletagmanager|clarity' && echo KO || echo OK
```
**Attendu** : `OK` (rien remonté).

### 2. Vérifier disparition des Link Headers GA4/Clarity
```bash
curl -sSI https://ccdeveloppement.eu/ | grep -i '^link:'
```
**Attendu** : la ligne `link:` ne contient PLUS `googletagmanager.com` ni `clarity.ms`. Peut encore référencer `app.cal.com` (autorisé). Si toujours présent : purger une seconde fois le cache Cloudflare.

### 3. Premier visiteur (navigation privée)
- Ouvrir Chrome / Firefox / Safari en navigation privée → `https://ccdeveloppement.eu/`.
- **Attendu** : bandeau cookies en bas avec 3 boutons (`Tout refuser` `Personnaliser` `Tout accepter`).
- Onglet **Network → DevTools** : aucune requête vers `googletagmanager.com`, `google-analytics.com`, `analytics.google.com`, `region1.google-analytics.com`, `clarity.ms`.
- Console : aucune erreur CSP.

### 4. Test "Tout refuser"
- Cliquer `Tout refuser`.
- **Attendu** : bandeau disparaît, aucun tracker chargé, `localStorage.ccdev_cookie_consent_v1` = `{analytics:false, clarity:false, ...}`.
- Recharger la page → pas de bandeau (choix mémorisé), toujours aucune requête tracker.

### 5. Test "Tout accepter"
- Vider localStorage (`localStorage.clear()`), recharger.
- Cliquer `Tout accepter`.
- **Attendu** : `gtag.js` chargé, `clarity.ms/tag/wbyffo03d6` chargé, requête `collect?...` GA4 envoyée pour le pageview, aucune erreur CSP en console.
- Onglet **Application → Cookies** : `_ga`, `_ga_*`, `_clck`, `_clsk` créés.

### 6. Test "Personnaliser"
- Vider localStorage, recharger.
- Cliquer `Personnaliser` → modale s'ouvre.
- **Attendu** : 2 checkboxes (`Google Analytics 4`, `Microsoft Clarity`) **non pré-cochées**.
- Cocher uniquement `Google Analytics 4` → `Enregistrer mes choix`.
- **Attendu** : seul GA4 chargé, Clarity reste silencieux.
- Refaire l'inverse (uniquement Clarity) après reset localStorage.

### 7. Test lien permanent footer
- Cliquer `Gérer mes préférences cookies` en pied de page.
- **Attendu** : modale s'ouvre, état actuel reflété dans les checkboxes.

### 8. Test révocation après acceptation
- Accepter tout → vérifier cookies `_ga`, `_clck` créés.
- Rouvrir modale → décocher GA4 + Clarity → `Enregistrer`.
- **Attendu via DevTools** :
  - Sur le breakpoint console : `gtag('consent','update', {analytics_storage:'denied', ...})` appelé,
  - `clarity('consentv2', {analytics_Storage:'denied', ...})` appelé,
  - `clarity('consent', false)` appelé,
  - **PUIS** `deleteAnalyticsCookies()` exécuté → cookies `_ga`, `_ga_*`, `_clck`, `_clsk` supprimés (vérifier dans `Application → Cookies`).

### 9. Test triple navigateur
Refaire les tests 3 → 8 sur **Chrome**, **Firefox**, **Safari** (cookie tiers Safari ITP comportement particulier à observer).

---

## Limites et points d'attention

- **Microsoft Clarity Consent Mode v2** : à activer côté **portail Clarity** (projet `wbyffo03d6` → Settings → Consent Management). Sans cette activation côté plateforme, les appels `clarity('consentv2', ...)` côté JS ne suffisent pas à bloquer le tracking. **À vérifier par Cyril.**
- **Cookies tiers Clarity** : peuvent persister un court délai après refus (limitation imposée par les navigateurs). `deleteAnalyticsCookies()` couvre les noms connus (`_clck`, `_clsk`, `CLID`, `ANONCHK`, `MR`, `MUID`, `SM`) sur les domaines `ccdeveloppement.eu` et `.ccdeveloppement.eu` ; les cookies déposés sur `clarity.ms` ne peuvent pas être supprimés depuis notre domaine.
- **Cas 2 `_headers`** : le header HTTP `Link:` provient de Cloudflare Early Hints (généré automatiquement à partir du HTML). **Purge complète du cache Cloudflare obligatoire après déploiement** sinon le header injecté persistera quelques heures. Tester avec `curl -sSI` après purge.
- **Tests en navigation privée** : indispensables pour simuler un premier visiteur (localStorage vide). Ne pas se contenter d'un onglet normal.
- **Régressions CSP** : la CSP autorise toujours GA4/Clarity car ils doivent pouvoir charger après consentement. Vérifier que les scripts post-consentement ne déclenchent aucune violation CSP.

---

## Commandes de vérification post-déploiement

```bash
# 1. Vérifier le header HTTP Link (ne doit plus contenir GA4/Clarity)
curl -sSI https://ccdeveloppement.eu/ | grep -i '^link:'

# 2. Vérifier l'absence de preconnect GA4/Clarity dans le HTML servi
curl -sS https://ccdeveloppement.eu/ | grep -i preconnect | grep -E 'googletagmanager|clarity' && echo KO || echo OK

# 3. Tester quelques pages clés (mêmes commandes)
for path in / /devis.html /tarifs.html /blog/ /rgpd-confidentialite.html ; do
  echo "==== $path ===="
  curl -sSI "https://ccdeveloppement.eu$path" | grep -i '^link:' | tr ',' '\n' | grep -iE 'googletagmanager|clarity' && echo "  KO preconnect tiers" || echo "  OK"
done
```

---

## Référence des rapports détaillés

- **Lot 1 — `analytics.js` v2.0.0** : [`_audit-reports/sprint1a-lot1-analytics.md`](./sprint1a-lot1-analytics.md)
  Réécriture complète : bandeau, modale, consent gate, révocation, suppression cookies.
- **Lot 2 — Nettoyage HTML + footer** : [`_audit-reports/sprint1a-lot2-html-headers.md`](./sprint1a-lot2-html-headers.md)
  26 lignes preconnect supprimées sur 13 pages, lien cookies idempotent ajouté sur 16 pages.
- **Lot 3 — RGPD section 6 réécrite** : [`_audit-reports/sprint1a-lot3-rgpd.md`](./sprint1a-lot3-rgpd.md)
  Phrase contradictoire retirée, mention GA4 + Clarity, droits utilisateur, durées de conservation.
- **Sprint 0 (référence) — Audit terrain initial** : [`_audit-reports/sprint0-audit-terrain.md`](./sprint0-audit-terrain.md)

---

## Sprint suivant recommandé

**Sprint 1B — Hygiène technique** (après validation manuelle Sprint 1A en navigation privée 3 navigateurs) :

1. **CTAs `href="#"`** : audit + remplacement par destinations réelles ou `<button>` (impact accessibilité + SEO).
2. **Polices `.otf`** : conversion en `.woff2` (gain perf, support navigateur), update CSS `@font-face` + `font-display: swap`.
3. **Lenis (smooth scroll)** : valider la nécessité (souvent dégrade UX mobile + accessibilité). Décision go/no-go.
4. **Encodage Assistant WhatsApp** : audit de l'encodage URL des messages prérédigés (caractères accentués, retours à la ligne).

**Préalable bloquant** : ne pas démarrer le Sprint 1B avant que Cyril ait validé manuellement les **9 tests** ci-dessus en navigation privée Chrome/Firefox/Safari et que le déploiement Cloudflare ait été purgé.

---

**Fin du rapport Sprint 1A.**
