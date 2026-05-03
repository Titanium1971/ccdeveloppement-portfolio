# Sprint 1a — Lot 2/4 : Nettoyage preconnects HTML + ajout lien footer cookies

**Date** : 2026-05-03
**Branche** : `sprint1a-rgpd-consentement`
**Périmètre** : 13 HTML preconnects + `_headers` + lien footer "Gérer mes préférences cookies" (15 pages)

---

## Partie A — Suppression des preconnects GA4 / Clarity dans les fichiers HTML

Lignes supprimées dans chaque fichier :

```html
<link rel="preconnect" href="https://www.googletagmanager.com">
<link rel="preconnect" href="https://www.clarity.ms">
```

Ligne préservée intacte (Cal.com utilisé en production) :

```html
<link rel="preconnect" href="https://app.cal.com">
```

### Fichiers modifiés (13 / 13)

| # | Fichier | preconnect GA4 retiré | preconnect Clarity retiré | preconnect cal.com préservé |
|---|---|---|---|---|
| 1  | `index.html`                                              | ✅ | ✅ | ✅ |
| 2  | `estimateur.html`                                         | ✅ | ✅ | ✅ |
| 3  | `blog/index.html`                                         | ✅ | ✅ | ✅ |
| 4  | `blog/seo-local-herault-restaurants-artisans.html`        | ✅ | ✅ | ✅ |
| 5  | `blog/combien-coute-site-vitrine-tpe-2026.html`           | ✅ | ✅ | ✅ |
| 6  | `blog/creation-site-internet-agde-guide-complet-2026.html`| ✅ | ✅ | ✅ |
| 7  | `guide-seo-local.html`                                    | ✅ | ✅ | ✅ |
| 8  | `seo-local-herault.html`                                  | ✅ | ✅ | ✅ |
| 9  | `creation-site-web-agde.html`                             | ✅ | ✅ | ✅ |
| 10 | `guide-tarifs.html`                                       | ✅ | ✅ | ✅ |
| 11 | `tarifs.html`                                             | ✅ | ✅ | ✅ |
| 12 | `comparatif-tarifs.html`                                  | ✅ | ✅ | ✅ |
| 13 | `devis.html`                                              | ✅ | ✅ | ✅ |

Total : **26 lignes retirées** (2 × 13 fichiers), 13 lignes `app.cal.com` préservées.

### Méthode

Pour chaque fichier, replacement atomique du bloc 3 lignes (cal.com + GA4 + Clarity) par la ligne unique cal.com via le tool `Edit`. Indentation et lignes voisines strictement inchangées.

### Vérification (commande)

```bash
grep -c 'preconnect.*googletagmanager\|preconnect.*clarity' *.html blog/*.html
```

**Résultat** : 0 sur les 16 fichiers HTML inspectés (13 modifiés + 3 non concernés `mentions-legales.html`, `merci.html`, `rgpd-confidentialite.html`). Voir log dans la section Vérifications globales.

---

## Partie B — Nettoyage de `_headers`

### Statut : **Cas 2 — pas de directive `Link:` dans `_headers`**

#### Procédure exécutée

1. Lecture intégrale de `_headers` (60 lignes).
2. `grep -i 'Link:' _headers` → **aucun match**.
3. Constat : aucune directive `Link:` (préconnexions, preload ou prefetch) n'est déclarée explicitement par le repo.

#### Conclusion

Le header HTTP `Link:` contenant les preconnects GA4/Clarity observé en production lors de l'audit Sprint 0 est **injecté automatiquement par Cloudflare** (fonctionnalité Speed Brain / Early Hints) à partir des balises `<link rel="preconnect">` présentes dans le HTML servi.

➡️ La suppression effectuée en **Partie A** retire la source des Early Hints de Cloudflare. Après purge cache Cloudflare (ou expiration TTL Early Hints), le header HTTP `Link:` cessera automatiquement de mentionner `googletagmanager.com` et `clarity.ms`.

➡️ **Aucune modification de `_headers` n'a été faite.** Toucher à `_headers` à l'aveugle aurait été risqué (CSP critique).

#### CSP préservée (vérification explicite)

La directive `Content-Security-Policy` reste intacte :

- `script-src` autorise toujours `https://www.googletagmanager.com`, `https://www.google-analytics.com`, `https://www.clarity.ms` → permet le chargement des SDK GA4/Clarity **après consentement**.
- `connect-src` autorise toujours `https://www.google-analytics.com`, `https://analytics.google.com`, `https://region1.google-analytics.com`, `https://www.clarity.ms` → permet l'envoi des hits **après consentement**.

Aucune régression possible sur le pipeline analytics consenti.

### Vérification (commande)

```bash
grep 'googletagmanager.com\|clarity.ms' _headers
```

**Résultat** : 1 match sur la ligne 7 (CSP). Voir log dans la section Vérifications globales.

---

## Partie C — Lien footer "Gérer mes préférences cookies" (idempotent)

### Pattern ajouté

```html
<a href="#" data-cookie-preferences class="footer-cookie-link">Gérer mes préférences cookies</a>
```

Lorsque les liens voisins (`/mentions-legales`, `/rgpd-confidentialite`) utilisaient un `style="..."` inline, le même style a été reproduit pour conformité visuelle. Sinon, le lien hérite simplement de la couleur du footer parent.

### Protocole d'idempotence appliqué

Avant chaque ajout : `grep 'data-cookie-preferences' "$f"` → 0 occurrence dans tous les fichiers ciblés (vérifié pré-modification). Après ajout : 1 occurrence par fichier (vérifié post-modification). Le lien est unique sur chaque page ; relancer la procédure ne créerait pas de doublon (le `Edit` échouerait sur le bloc déjà modifié).

### Fichiers traités (15)

| # | Fichier | Statut | Style appliqué |
|---|---|---|---|
| 1  | `index.html`                                               | ✅ ajouté | hérité (pas de style adjacent) |
| 2  | `estimateur.html`                                          | ✅ ajouté | hérité |
| 3  | `blog/index.html`                                          | ✅ ajouté | hérité |
| 4  | `blog/seo-local-herault-restaurants-artisans.html`         | ✅ ajouté | hérité |
| 5  | `blog/combien-coute-site-vitrine-tpe-2026.html`            | ✅ ajouté | hérité |
| 6  | `blog/creation-site-internet-agde-guide-complet-2026.html` | ✅ ajouté | hérité |
| 7  | `guide-seo-local.html`                                     | ✅ ajouté | inline `color:var(--gray-dim);text-decoration:none;` |
| 8  | `seo-local-herault.html`                                   | ✅ ajouté | inline `color:#71717A;text-decoration:none;` |
| 9  | `creation-site-web-agde.html`                              | ✅ ajouté | inline `color:#71717A;text-decoration:none;` |
| 10 | `guide-tarifs.html`                                        | ✅ ajouté | inline `color:var(--gray-dim);text-decoration:none;` |
| 11 | `tarifs.html`                                              | ✅ ajouté | inline `color:#D4D4D8;text-decoration:none;` |
| 12 | `comparatif-tarifs.html`                                   | ✅ ajouté | inline `color:var(--gray-dim);text-decoration:none;` (entités HTML utilisées) |
| 13 | `devis.html`                                               | ✅ ajouté | hérité |
| 14 | `mentions-legales.html`                                    | ✅ ajouté | inline `color:#71717A;text-decoration:none;` |
| 15 | `merci.html`                                               | ✅ ajouté | hérité |

### Fichiers exclus (1)

| Fichier | Raison |
|---|---|
| `rgpd-confidentialite.html` | **Hors périmètre Lot 2** — explicitement traité par Lot 4 (refonte page RGPD). Aucune modification. |

### CSS global

Aucun `assets/css/` dédié dans le repo (CSS inline / `<style>` par page). Pas de feuille de style globale modifiée. Une classe `footer-cookie-link` est posée sur le lien : elle pourra recevoir une règle CSS commune dans un lot ultérieur si besoin (par ex. effet hover global). Pour l'instant, l'apparence est suffisante par héritage ou `style` inline reproduit.

### Vérification (commande)

```bash
grep -l 'data-cookie-preferences' *.html blog/*.html
```

**Résultat** : 15 fichiers listés, exactement 1 occurrence par fichier (pas de doublon). `rgpd-confidentialite.html` non listé (exclu volontairement).

---

## Vérifications globales (logs bruts)

```text
=== Vérif A : preconnects GA4/Clarity (doit être 0 partout) ===
comparatif-tarifs.html:0
creation-site-web-agde.html:0
devis.html:0
estimateur.html:0
guide-seo-local.html:0
guide-tarifs.html:0
index.html:0
mentions-legales.html:0
merci.html:0
rgpd-confidentialite.html:0
seo-local-herault.html:0
tarifs.html:0
blog/combien-coute-site-vitrine-tpe-2026.html:0
blog/creation-site-internet-agde-guide-complet-2026.html:0
blog/index.html:0
blog/seo-local-herault-restaurants-artisans.html:0

=== Vérif C : pages avec data-cookie-preferences (1 occurrence chacune) ===
comparatif-tarifs.html:1
creation-site-web-agde.html:1
devis.html:1
estimateur.html:1
guide-seo-local.html:1
guide-tarifs.html:1
index.html:1
mentions-legales.html:1
merci.html:1
rgpd-confidentialite.html:0
seo-local-herault.html:1
tarifs.html:1
blog/combien-coute-site-vitrine-tpe-2026.html:1
blog/creation-site-internet-agde-guide-complet-2026.html:1
blog/index.html:1
blog/seo-local-herault-restaurants-artisans.html:1

=== Vérif B : CSP intacte avec googletagmanager + clarity ===
  Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com https://www.google-analytics.com https://www.clarity.ms https://static.cloudflareinsights.com https://app.cal.com https://embed.cal.com https://unpkg.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' data: https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://www.google-analytics.com https://analytics.google.com https://region1.google-analytics.com https://cloudflareinsights.com https://www.clarity.ms https://app.cal.com https://formspree.io https://sibforms.com https://5d1a602f.sibforms.com https://unpkg.com; frame-src 'self' https://app.cal.com https://www.google.com; object-src 'none'; base-uri 'self'; form-action 'self' https://formspree.io https://sibforms.com https://5d1a602f.sibforms.com
```

---

## Bilan Lot 2/4

| Action | Statut |
|---|---|
| **A.** Suppression preconnects GA4/Clarity dans 13 HTML | ✅ **Terminé** (26 lignes retirées, cal.com préservé) |
| **B.** Nettoyage `_headers` | ✅ **Sans objet — Cas 2 documenté** (Cloudflare Early Hints, suppression HTML suffit) |
| **C.** Lien footer "Gérer mes préférences cookies" idempotent | ✅ **Terminé** (15 pages, `rgpd-confidentialite.html` exclu Lot 4) |
| **CSP intacte** | ✅ **Vérifiée** (script-src + connect-src GA4/Clarity préservés pour chargement post-consentement) |

### Suite (Lot 3/4 et Lot 4/4 — hors périmètre de ce rapport)

- Lot 3 : intégration UI bandeau cookies + écouteur `data-cookie-preferences` qui ouvre la modale de gestion.
- Lot 4 : refonte page `rgpd-confidentialite.html` (mention nouvelle base légale, mécanisme retrait du consentement).
- Action ops après merge en prod : purger le cache Cloudflare → vérifier que le header HTTP `Link:` n'inclut plus `googletagmanager.com` ni `clarity.ms`.

### Branchement attendu

Le code Lot 1 (`analytics.js` v2.0.0) écoute déjà sur `[data-cookie-preferences]` (à confirmer Lot 3) pour rouvrir la modale de préférences. Lot 2 prépare donc proprement les points d'attache.
