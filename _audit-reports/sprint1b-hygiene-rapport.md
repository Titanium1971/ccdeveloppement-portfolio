# Sprint 1B — Hygiène technique + résidu RGPD — Rapport final

**Date** : 2026-05-04
**Branche** : `sprint1b-hygiene-technique`
**Lots** : 1/4 (CTAs + RGPD), 2/4 (Encodage + fonts), 3/4 (Lenis), 4/4 (Validation et rapport)
**Statut global** : ✅ Tous les lots terminés. Périmètre tenu.

---

## 1. Périmètre traité

- **27+ CTAs `href="#"`** : tri par contexte appliqué (43 occurrences réelles classées en 5 règles ; 26 R2 Cal.com corrigés, 1 R3 logo, 16 R1 cookies laissés intacts avec `preventDefault` déjà géré dans `analytics.js:650`).
- **3 résidus RGPD ajoutés** à `rgpd-confidentialite.html` : transferts hors UE (DPF + CCT, États-Unis), durée GA4 (14 mois) et Clarity (90 jours), adresse RT (déjà présente, vérifiée cohérente).
- **Encodage section Assistant WhatsApp** dans `index.html` : 11 lignes corrigées (lignes 1798-1828), accents restaurés, UTF-8 préservé.
- **Font Perplexity** : statut **orpheline documentée** — référence absente du code source, attribuée à une extension navigateur (Perplexity Companion / Comet) ou cache local. Aucune modification repo.
- **Lenis bundlé localement** : `assets/js/lenis.min.js` (13 020 octets), SHA-256 `0bf174d39b9abc304a3d501ab6457587e756d07bd824f868a5324b5cf15125b0`, 13 fichiers HTML migrés depuis `unpkg.com/lenis@1.1.18`.

---

## 2. Hors périmètre (sprints à venir)

- **Audit licences fonts Brandon Grotesque / Morena** — sujet juridique séparé. Inventaire fait au pré-sprint (6 OTF, mention "Embedded" pour Morena), licence webfont à clarifier (~120-300 € ou remplacement open-source type Inter).
- **CTAs `href="#"` R1 résiduels (17 occurrences)** — tous `data-cookie-preferences`, traités par `e.preventDefault()` dans `assets/js/analytics.js:650`. Décision de design conservée (Cyril, pas de migration vers `<button>`).
- **Uniformisation des chemins de scripts** — Lenis charge en absolu (`/assets/js/lenis.min.js`) tandis que `analytics.js` et `smooth-scroll.js` utilisent du relatif. Incohérence stylistique sans impact fonctionnel, à arbitrer en Sprint 2.
- **Durcissement CSP** — `unpkg.com` reste autorisé en `script-src` / `connect-src` (aucune autre dépendance externe avérée, retrait possible après audit complémentaire).

---

## 3. Fichiers modifiés

### 3.1. HTML modifiés (16)

| Fichier | Lots concernés |
|---------|----------------|
| `index.html` | Lot 1 (CTAs, logo) + Lot 2 (encodage WhatsApp) + Lot 3 (Lenis) |
| `comparatif-tarifs.html` | Lot 1 + Lot 3 |
| `creation-site-web-agde.html` | Lot 1 + Lot 3 |
| `devis.html` | Lot 1 + Lot 3 |
| `estimateur.html` | Lot 1 + Lot 3 |
| `guide-seo-local.html` | Lot 1 |
| `guide-tarifs.html` | Lot 1 + Lot 3 |
| `mentions-legales.html` | Lot 1 + Lot 3 |
| `merci.html` | Lot 1 |
| `rgpd-confidentialite.html` | Lot 1 + RGPD Partie B + Lot 3 |
| `seo-local-herault.html` | Lot 1 + Lot 3 |
| `tarifs.html` | Lot 1 + Lot 3 |
| `blog/index.html` | Lot 1 |
| `blog/combien-coute-site-vitrine-tpe-2026.html` | Lot 1 + Lot 3 |
| `blog/creation-site-internet-agde-guide-complet-2026.html` | Lot 1 + Lot 3 |
| `blog/seo-local-herault-restaurants-artisans.html` | Lot 1 + Lot 3 |

### 3.2. Fichier nouveau

- `assets/js/lenis.min.js` (Lot 3, 13 020 octets, ASCII JS minifié)

### 3.3. Rapports d'audit (nouveaux)

- `_audit-reports/sprint1b-lot1-ctas-rgpd.md`
- `_audit-reports/sprint1b-lot2-encodage-fonts.md`
- `_audit-reports/sprint1b-lot3-lenis.md`
- `_audit-reports/sprint1b-hygiene-rapport.md` (ce document)

### 3.4. `git diff --stat`

```
 16 files changed, 58 insertions(+), 52 deletions(-)
```

Aucun fichier hors périmètre touché : `_headers` intact, `analytics.js` intact, `fonts/` intact.

---

## 4. Résultats des 7 tâches de validation

| # | Vérification | Statut | Preuve |
|---|--------------|--------|--------|
| 1 | CTAs `href="#"` résiduels limités à R1/R5 | ✅ OK | 17 résiduels, **tous** ciblés par `[data-cookie-preferences]` (R1). Cf. § 4.1. |
| 2 | Cal.com `data-cal-link` intégré | ✅ OK | 26 occurrences de `data-cal-link="cc-developpement/audit-gratuit"`. |
| 3 | Résidus RGPD ajoutés | ✅ OK | DPF + Clauses Contractuelles Types + 14 mois + 90 jours + transferts États-Unis présents. |
| 4 | Encodage WhatsApp corrigé | ✅ OK | 0 variante non-accentuée, 4 variantes accentuées présentes (`Réservations automatiques`, `Posts réseaux sociaux`, `Réponses clients 24/7`, `Statistiques de fréquentation, réservations`). |
| 5 | Lenis local en place | ✅ OK | Fichier 13 020 octets ASCII JS, SHA-256 `0bf174d39b9abc...125b0`, 0 résidu unpkg, 13 fichiers HTML utilisent `/assets/js/lenis.min.js`. |
| 6 | Cohérence des fichiers modifiés (git) | ✅ OK | 16 HTML modifiés + `assets/js/lenis.min.js` (NEW) + 3 rapports (NEW). Aucun fichier inattendu. |
| 7 | Non-régression Sprint 1A | ✅ OK | `data-cookie-preferences` ≥ 1/page, CSP `_headers` intacte (GA4 + Clarity allowlistés), `ccdev_cookie_consent_v1` toujours présent dans `analytics.js`. |

### 4.1. Détail tâche 1 — Liste exhaustive des 17 résiduels `href="#"`

Tous classés R1 (`data-cookie-preferences`, JS `preventDefault` géré) :

| Fichier | Ligne | Contexte |
|---------|------:|----------|
| index.html | 1882 | Footer cookies |
| merci.html | 209 | Footer cookies |
| mentions-legales.html | 97 | Footer cookies |
| estimateur.html | 348 | Footer cookies |
| blog/index.html | 195 | Footer cookies |
| blog/seo-local-herault-restaurants-artisans.html | 458 | Footer cookies |
| blog/combien-coute-site-vitrine-tpe-2026.html | 501 | Footer cookies |
| blog/creation-site-internet-agde-guide-complet-2026.html | 423 | Footer cookies |
| rgpd-confidentialite.html | 86 | Inline section 6 (lien initial) |
| rgpd-confidentialite.html | 87 | **Nouveau** — lien dans paragraphe DPF (ajouté par Sprint 1B Partie B) |
| guide-seo-local.html | 328 | Footer cookies |
| seo-local-herault.html | 158 | Footer cookies |
| creation-site-web-agde.html | 158 | Footer cookies |
| guide-tarifs.html | 801 | Footer cookies |
| tarifs.html | 1057 | Footer cookies |
| comparatif-tarifs.html | 846 | Footer cookies |
| devis.html | 416 | Footer cookies |

> **Note de comptage** : le rapport Lot 1 prévoyait 16 R1. Le compte réel post-Sprint 1B est **17** car la rédaction de la mention DPF (Partie B) ajoute un nouveau lien `data-cookie-preferences` dans `rgpd-confidentialite.html` ligne 87. Le handler `bindPreferenceLinks()` couvre tous les `[data-cookie-preferences]` du DOM, donc cette occurrence supplémentaire est gérée automatiquement par le `preventDefault` de `analytics.js:650`.

---

## 5. Tests manuels à effectuer par Cyril

1. **CTA Cal.com fonctionnel** — Ouvrir `http://localhost:8080/index.html` (ou production une fois déployé), cliquer sur un CTA « Réserver un audit gratuit » → la modale Cal.com doit s'ouvrir (handler `data-cal-link`). Vérifier que le `href` reste un fallback non utilisé visuellement (pas de saut vers le haut).
2. **Encodage WhatsApp** — Scroller jusqu'à la section `#assistant` d'`index.html`. Vérifier les titres/descriptions : `Réservations automatiques`, `Posts réseaux sociaux`, `Réponses clients 24/7`, `Résumé matinal`, `Statistiques de fréquentation`. Aucun caractère sans accent dans cette zone.
3. **Smooth-scroll Lenis** — Charger `index.html`, scroller à la molette ou ancre. L'effet Lenis doit fonctionner (scroll fluide). DevTools → Network : `lenis.min.js` doit charger depuis `/assets/js/` et **pas** depuis `unpkg.com`.
4. **Section Cookies RGPD** — Ouvrir `rgpd-confidentialite.html`, lire la section 6. Mentions présentes : « Data Privacy Framework (DPF) », « Clauses Contractuelles Types (CCT) », « 14 mois » (GA4), « 90 jours maximum » (Clarity), transfert vers États-Unis.
5. **Bandeau RGPD Sprint 1A** — Ouvrir une page en navigation privée, vérifier que le bandeau de consentement s'affiche bien, que les boutons Accepter / Refuser / Personnaliser fonctionnent, que `localStorage.ccdev_cookie_consent_v1` est correctement écrit. Cliquer ensuite sur « Gérer mes préférences cookies » dans le footer → la modale de préférences doit s'ouvrir, sans saut de scroll vers le haut (preuve `preventDefault`).

---

## 6. Limites et points d'attention

- **CTAs R1 et fallback `preventDefault`** — Si un développeur futur ajoute un `<a href="#" data-cookie-preferences>` *après* le chargement DOMContentReady (insertion dynamique), le handler ne sera pas attaché. À documenter dans une éventuelle convention.
- **Lenis 1.1.18** — Version figée. Si un bug ou une dépréciation est annoncée, prévoir un upgrade dans un sprint séparé. Procédure de mise à jour décrite dans `sprint1b-lot3-lenis.md` § 6.3.
- **Font Perplexity** — Tant que l'audit n'est pas refait sur un profil navigateur **sans extensions** (Safari privé, Chrome propre), la reproduction du 503 reste un signal externe au repo. Si la requête persiste sur profil propre → investiguer Network → Initiator.
- **Audit licences fonts** — Brandon Grotesque (~120-300 € webfont licence si commerciale) et Morena (variantes "Embedded"). Sujet juridique à planifier hors sprint technique.
- **Incohérence chemins JS** — Lenis en absolu, `analytics.js` et `smooth-scroll.js` en relatif. Pas de risque fonctionnel, mais à uniformiser en Sprint 2 (préférer absolu pour robustesse en sous-arborescence).
- **CSP `unpkg.com`** — Toujours autorisée bien que Lenis soit local. Retrait possible une fois confirmé qu'aucune autre ressource externe n'en dépend.

---

## 7. Commandes de vérification post-déploiement

À exécuter une fois la branche `sprint1b-hygiene-technique` mergée vers `main` et déployée sur Cloudflare Pages :

```bash
# 1) Cal.com toujours intégré en prod
curl -sS https://ccdeveloppement.eu/ | grep -c 'data-cal-link'
# attendu : > 0 (probablement 5 sur la home)

# 2) Lenis servi en local depuis le domaine
curl -sS https://ccdeveloppement.eu/assets/js/lenis.min.js | head -c 100
# attendu : "var k=\"1.1.18\";function w(r,t,e){..."

# 3) Encodage Assistant WhatsApp en prod
curl -sS https://ccdeveloppement.eu/ | grep -E 'Réservations|Réponses|fréquentation|réseaux sociaux'
# attendu : 4 lignes accentuées au moins

# 4) Aucun résidu unpkg sur la home
curl -sS https://ccdeveloppement.eu/ | grep -c 'unpkg.com/lenis'
# attendu : 0

# 5) Section RGPD à jour
curl -sS https://ccdeveloppement.eu/rgpd-confidentialite | grep -E 'Data Privacy Framework|14 mois|90 jours'
# attendu : 3 lignes (DPF + GA4 14 mois + Clarity 90 jours)

# 6) Checksum Lenis identique au local
curl -sS https://ccdeveloppement.eu/assets/js/lenis.min.js | shasum -a 256
# attendu : 0bf174d39b9abc304a3d501ab6457587e756d07bd824f868a5324b5cf15125b0
```

---

## 8. Référence des rapports détaillés

- `_audit-reports/sprint1b-lot1-ctas-rgpd.md` — détail des 43 CTAs classés R1-R5 + les 3 résidus RGPD ajoutés
- `_audit-reports/sprint1b-lot2-encodage-fonts.md` — 11 lignes corrigées dans la section Assistant WhatsApp + énigme font Perplexity
- `_audit-reports/sprint1b-lot3-lenis.md` — bundling Lenis 1.1.18 local + checksum + 13 fichiers HTML migrés

---

## 9. Sprint suivant

Plus de sprint correctif urgent. Roadmap restante par ordre de priorité :

1. **Audit licences fonts** (sujet juridique) — Brandon Grotesque, Morena ; clarifier statut webfont commerciale ou remplacer (Inter / Geist / system fonts).
2. **Page produit Assistant WhatsApp IA** (sprint produit) — section actuelle d'`index.html` à étoffer en page dédiée si vente prouvée.
3. **Google Business Profile + NAP + backlinks locaux** (sprint SEO off-site) — adresse 27 Rue Basse 34300 Agde déjà cohérente sur tout le site, prêt pour citations locales.
4. **Mesure Core Web Vitals baseline** (Lighthouse + PageSpeed Insights) — pour mesurer l'effet du bundling Lenis local + suppression preconnects GA4/Clarity du Sprint 1A.

**Fin du Sprint 1B.**
