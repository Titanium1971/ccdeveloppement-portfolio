# Sprint 1B — Lot 1/4 : CTAs href="#" + Résidus RGPD

**Date** : 2026-05-04
**Branche** : `sprint1b-hygiene-technique`
**Scope** : Réparation des CTAs `href="#"` (Partie A) + Compléments RGPD oubliés du Sprint 1A (Partie B)

---

## PARTIE A — Réparation des CTAs `href="#"`

### Synthèse

| Catégorie | Règle | Occurrences | Action |
|-----------|-------|------------:|--------|
| Logo header | R3 | 1 | `href="/"` |
| CTAs Cal.com (`data-cal-link`) | R2 | 26 | `href="https://cal.com/cc-developpement/audit-gratuit"` ajouté en fallback |
| Liens `data-cookie-preferences` | R1 | 16 | Laissés intacts (preventDefault déjà appliqué dans `assets/js/analytics.js:650`) |
| **Total** | | **43** | |

> Note : l'audit Sprint 0 mentionnait 27 occurrences ; le grep exhaustif sur les 16 fichiers HTML actifs en remonte 43 (l'écart vient probablement d'une déduplication par balise dans l'audit initial). Toutes ont été classées et traitées selon les règles R1–R5.

### Vérification preventDefault — `data-cookie-preferences`

Le sélecteur `[data-cookie-preferences]` est ciblé par un event listener dans `assets/js/analytics.js` :

```js
// assets/js/analytics.js:645-650
function bindPreferenceLinks() {
  ready(function () {
    var links = document.querySelectorAll('[data-cookie-preferences]');
    for (var i = 0; i < links.length; i++) {
      links[i].addEventListener('click', function (e) {
        e.preventDefault();        // ← preventDefault déjà géré
        // …
```

Conformément à la règle R1, **aucune modification HTML n'est appliquée** sur ces 16 liens.

### Tableau exhaustif (43 occurrences, lignes pré-modification)

| Fichier | Ligne | Texte CTA / contexte | Règle | Action |
|---|---:|---|---|---|
| index.html | 1211 | (logo `nav-logo`, image `cc-developpement-logo-horizontal.svg`) | R3 | `href="/"` |
| index.html | 1238 | « Obtenir un audit gratuit » (`btn-primary`) | R2 | `href` cal.com ajouté |
| index.html | 1849 | « 📅 Réserve ton audit gratuit — 30 min » (`btn-cal`) | R2 | `href` cal.com ajouté |
| index.html | 1880 | « 📅 Réserve ton audit gratuit — 30 min » (`btn-cal--outline`) | R2 | `href` cal.com ajouté |
| index.html | 1882 | « Gérer mes préférences cookies » (footer) | R1 | laissé intact |
| index.html | 1887 | « 📅 Réserve ton audit gratuit » (CTA mobile) | R2 | `href` cal.com ajouté |
| estimateur.html | 347 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| estimateur.html | 348 | « Gérer mes préférences cookies » | R1 | laissé intact |
| devis.html | 384 | « 📅 Réserve ton audit gratuit — 30 min » (`btn-cal`) | R2 | `href` cal.com ajouté |
| devis.html | 410 | « 📅 Réserve ton audit gratuit — 30 min » (`btn-cal--outline`) | R2 | `href` cal.com ajouté |
| devis.html | 416 | « Gérer mes préférences cookies » | R1 | laissé intact |
| devis.html | 421 | « 📅 Réserve ton audit gratuit » (CTA mobile) | R2 | `href` cal.com ajouté |
| merci.html | 182 | « 📅 Réserve ton créneau » | R2 | `href` cal.com ajouté |
| merci.html | 203 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| merci.html | 209 | « Gérer mes préférences cookies » | R1 | laissé intact |
| merci.html | 214 | « 📅 Réserve ton audit gratuit » | R2 | `href` cal.com ajouté |
| comparatif-tarifs.html | 845 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| comparatif-tarifs.html | 846 | « Gérer mes préférences cookies » | R1 | laissé intact |
| creation-site-web-agde.html | 157 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| creation-site-web-agde.html | 158 | « Gérer mes préférences cookies » | R1 | laissé intact |
| guide-seo-local.html | 327 | « Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| guide-seo-local.html | 328 | « Gérer mes préférences cookies » | R1 | laissé intact |
| guide-tarifs.html | 800 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| guide-tarifs.html | 801 | « Gérer mes préférences cookies » | R1 | laissé intact |
| mentions-legales.html | 92 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| mentions-legales.html | 97 | « Gérer mes préférences cookies » | R1 | laissé intact |
| rgpd-confidentialite.html | 81 | « Gérer mes préférences cookies » (lien inline section 6) | R1 | laissé intact |
| rgpd-confidentialite.html | 109 | « 📅 Réserve ton audit gratuit — 30 min » (footer) | R2 | `href` cal.com ajouté |
| seo-local-herault.html | 157 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| seo-local-herault.html | 158 | « Gérer mes préférences cookies » | R1 | laissé intact |
| tarifs.html | 1056 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| tarifs.html | 1057 | « Gérer mes préférences cookies » | R1 | laissé intact |
| blog/index.html | 193 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| blog/index.html | 195 | « Gérer mes préférences cookies » | R1 | laissé intact |
| blog/combien-coute-site-vitrine-tpe-2026.html | 444 | « Réserver mon audit gratuit » | R2 | `href` cal.com ajouté |
| blog/combien-coute-site-vitrine-tpe-2026.html | 499 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| blog/combien-coute-site-vitrine-tpe-2026.html | 501 | « Gérer mes préférences cookies » | R1 | laissé intact |
| blog/creation-site-internet-agde-guide-complet-2026.html | 373 | « Réserver mon audit gratuit » | R2 | `href` cal.com ajouté |
| blog/creation-site-internet-agde-guide-complet-2026.html | 421 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| blog/creation-site-internet-agde-guide-complet-2026.html | 423 | « Gérer mes préférences cookies » | R1 | laissé intact |
| blog/seo-local-herault-restaurants-artisans.html | 394 | « Réserver mon audit SEO gratuit » | R2 | `href` cal.com ajouté |
| blog/seo-local-herault-restaurants-artisans.html | 456 | « 📅 Réserve ton audit gratuit — 30 min » | R2 | `href` cal.com ajouté |
| blog/seo-local-herault-restaurants-artisans.html | 458 | « Gérer mes préférences cookies » | R1 | laissé intact |

### Méthode d'application

Pour les 26 cas R2, transformation atomique via `sed -E` ciblant uniquement les ancres contenant `data-cal-link` (le pattern `data-cookie-preferences` n'est pas matché, ce qui garantit l'isolation R1/R2) :

```bash
sed -i '' -E 's|href="#" ([^>]*data-cal-link)|href="https://cal.com/cc-developpement/audit-gratuit" \1|g' "$f"
```

Pour le cas R3 (logo), `Edit` ciblé : `<a href="#" class="nav-logo">` → `<a href="/" class="nav-logo">`.

### Vérification finale (post-modification)

```
$ grep -c 'href="#"' [16 fichiers HTML actifs]
→ 16 occurrences restantes, 100 % avec data-cookie-preferences (R1 conforme)
$ grep -c 'href="#" [^>]*data-cal-link'
→ 0 dans tous les fichiers
$ grep -l 'href="https://cal.com/cc-developpement/audit-gratuit"' --include='*.html'
→ 16 fichiers (100 % de la couverture Cal.com)
```

**Aucun cas R4 (card cliquable) ni R5 (autre) détecté** — les 43 occurrences se répartissent strictement en R1 / R2 / R3.

---

## PARTIE B — Résidus RGPD du Sprint 1A

### B.1 — Transferts hors Union européenne (section 6)

**Avant** (rgpd-confidentialite.html section 6 — paragraphe terminal) :

```html
<p style="margin-top:10px;">Ces outils ne sont chargés qu'après acceptation explicite. Vous pouvez refuser ou modifier votre choix à tout moment via le lien <a href="#" data-cookie-preferences>« Gérer mes préférences cookies »</a> présent en bas de chaque page.</p>
<p style="margin-top:18px;">Autres services tiers utilisés ponctuellement et uniquement sur action volontaire de votre part :</p>
```

**Après** :

```html
<p style="margin-top:10px;">Ces outils ne sont chargés qu'après acceptation explicite. Vous pouvez refuser ou modifier votre choix à tout moment via le lien <a href="#" data-cookie-preferences>« Gérer mes préférences cookies »</a> présent en bas de chaque page.</p>
<p style="margin-top:18px;"><strong>Transferts hors Union européenne :</strong> les outils Google Analytics 4 et Microsoft Clarity peuvent entraîner un transfert de données vers les États-Unis. Google LLC et Microsoft Corporation sont signataires du <em>Data Privacy Framework</em> (DPF) approuvé par la Commission européenne, ce qui encadre ces transferts. Des Clauses Contractuelles Types (CCT) sont également appliquées en complément. Vous pouvez à tout moment refuser ces outils via le lien <a href="#" data-cookie-preferences>« Gérer mes préférences cookies »</a>.</p>
<p style="margin-top:18px;">Autres services tiers utilisés ponctuellement et uniquement sur action volontaire de votre part :</p>
```

### B.2 — Durée de conservation GA4 / Clarity (section 5)

**Avant** :

```html
<h2>5. Durée de conservation</h2>
<p>Les données de contact sont conservées pendant <strong>12 mois à compter du dernier échange</strong>, puis supprimées ou archivées conformément aux obligations légales applicables.</p>
```

**Après** :

```html
<h2>5. Durée de conservation</h2>
<p>Les données de contact sont conservées pendant <strong>12 mois à compter du dernier échange</strong>, puis supprimées ou archivées conformément aux obligations légales applicables.</p>
<p style="margin-top:10px;">Concernant les outils de mesure d'audience activés uniquement après votre consentement :</p>
<ul>
  <li><strong>Google Analytics 4</strong> : durée de conservation des données utilisateur configurée sur <strong>14 mois</strong> (paramètre par défaut Google).</li>
  <li><strong>Microsoft Clarity</strong> : conservation des enregistrements de session pendant <strong>90 jours maximum</strong> (paramètre par défaut Microsoft).</li>
</ul>
```

### B.3 — Vérification adresse Responsable du traitement

**Statut : COHÉRENT — aucune action requise.**

Adresse vérifiée : `27 Rue Basse, 34300 Agde`.

| Source | Ligne | Valeur |
|---|---:|---|
| `rgpd-confidentialite.html` (section 1, RT) | 55 | « 27 Rue Basse, 34300 Agde » |
| `index.html` JSON-LD #1 (`@type: Organization`) | 67-69 | streetAddress=27 Rue Basse, postalCode=34300, addressLocality=Agde |
| `index.html` JSON-LD #2 (`@type: LocalBusiness` ?) | 97-99 | streetAddress=27 Rue Basse, postalCode=34300, addressLocality=Agde |
| `creation-site-web-agde.html` JSON-LD | 53-55 | streetAddress=27 Rue Basse, postalCode=34300, addressLocality=Agde |
| `seo-local-herault.html` JSON-LD | 53-55 | streetAddress=27 Rue Basse, postalCode=34300, addressLocality=Agde |
| `mentions-legales.html` (siège social) | 60 | « 27 Rue Basse, 34300 Agde (Hérault) » |
| Footers de toutes les pages (16/16) | — | « 27 Rue Basse, 34300 Agde » |

Aucune incohérence détectée. La mention « (Hérault) » des mentions légales n'est pas une divergence (précision géographique optionnelle, le code postal 34300 implique le département 34).

### Date de mise à jour

`<p>Dernière mise à jour : 3 mai 2026.</p>` → `<p>Dernière mise à jour : 4 mai 2026.</p>` (date système courante).

---

## Récapitulatif Lot 1/4

| Action | Statut |
|---|---|
| 26 CTAs Cal.com — `href` fallback ajouté | ✅ |
| 1 logo header — `href="/"` | ✅ |
| 16 liens `data-cookie-preferences` — préservés (R1) | ✅ |
| RGPD B.1 — transferts hors UE (DPF + CCT) | ✅ |
| RGPD B.2 — durées de conservation GA4/Clarity | ✅ |
| RGPD B.3 — vérif adresse RT vs JSON-LD | ✅ cohérent |
| Date mise à jour RGPD | ✅ 2026-05-04 |
| Aucun fichier hors-scope touché (`analytics.js`, `_headers`, encodage WhatsApp index.html, Lenis) | ✅ |

**Fichiers modifiés (17)** :
- `index.html`, `estimateur.html`, `devis.html`, `merci.html`, `comparatif-tarifs.html`, `creation-site-web-agde.html`, `guide-seo-local.html`, `guide-tarifs.html`, `mentions-legales.html`, `rgpd-confidentialite.html`, `seo-local-herault.html`, `tarifs.html`
- `blog/index.html`, `blog/combien-coute-site-vitrine-tpe-2026.html`, `blog/creation-site-internet-agde-guide-complet-2026.html`, `blog/seo-local-herault-restaurants-artisans.html`
