# Sprint 1B — Lot 3/4 : Bundling local de Lenis

**Date** : 2026-05-04
**Branche** : `sprint1b-hygiene-technique`
**Périmètre** : remplacement de la dépendance externe `unpkg.com/lenis@1.1.18` par un fichier servi localement depuis `/assets/js/lenis.min.js`.

---

## 1. Inventaire des versions Lenis (avant modification)

Commande :
```bash
grep -hE 'unpkg.com/lenis@[^"'"'"' ]+' *.html blog/*.html | sort -u
```

Résultat :
```
<script src="https://unpkg.com/lenis@1.1.18/dist/lenis.min.js"></script>
```

**Version unique détectée : `1.1.18`** sur l'ensemble du site. Aucune version `@latest`, aucune incohérence.

13 fichiers HTML chargeaient Lenis depuis unpkg (cohérent avec l'audit Sprint 0).

---

## 2. Téléchargement et validation d'intégrité

### Téléchargement

```bash
mkdir -p assets/js
curl -sSL -o assets/js/lenis.min.js https://unpkg.com/lenis@1.1.18/dist/lenis.min.js
```

### Caractéristiques du fichier

| Propriété     | Valeur                                                              |
|---------------|---------------------------------------------------------------------|
| Chemin        | `assets/js/lenis.min.js`                                            |
| Taille        | **13 020 octets** (≈ 13 Ko, dans la plage attendue 10–100 Ko)       |
| Type          | ASCII text, with very long lines (12982) — JavaScript minifié       |
| Première ligne| `var k="1.1.18";function w(r,t,e){...` (signature Lenis 1.1.18)     |
| Balises HTML  | 0 (`grep -c '<html\|<!DOCTYPE\|<body'` → 0) — pas de page d'erreur  |

### Checksum SHA-256

```
0bf174d39b9abc304a3d501ab6457587e756d07bd824f868a5324b5cf15125b0  assets/js/lenis.min.js
```

**Validation par re-téléchargement** :
```bash
curl -sSL https://unpkg.com/lenis@1.1.18/dist/lenis.min.js | shasum -a 256
# 0bf174d39b9abc304a3d501ab6457587e756d07bd824f868a5324b5cf15125b0  -
```

✅ **Match parfait** entre fichier local et source unpkg.
✅ Le contenu inclut la chaîne `var k="1.1.18"` confirmant l'identité exacte de la version.

### Validation servi via HTTP local (port 8080)

```bash
curl -sI http://localhost:8080/assets/js/lenis.min.js
# HTTP/1.0 200 OK
# Content-type: text/javascript
# Content-Length: 13020

curl -s http://localhost:8080/assets/js/lenis.min.js | shasum -a 256
# 0bf174d39b9abc304a3d501ab6457587e756d07bd824f868a5324b5cf15125b0  -
```

Servi correctement, MIME-type JS, intégrité confirmée bout-en-bout.

---

## 3. Substitution effectuée

**Avant** :
```html
<script src="https://unpkg.com/lenis@1.1.18/dist/lenis.min.js"></script>
```

**Après** :
```html
<script src="/assets/js/lenis.min.js"></script>
```

Commande utilisée (sed BSD/macOS, in-place) :
```bash
sed -i '' 's|<script src="https://unpkg.com/lenis@1.1.18/dist/lenis.min.js"></script>|<script src="/assets/js/lenis.min.js"></script>|g' \
  index.html mentions-legales.html estimateur.html rgpd-confidentialite.html \
  seo-local-herault.html creation-site-web-agde.html guide-tarifs.html \
  tarifs.html comparatif-tarifs.html devis.html \
  blog/seo-local-herault-restaurants-artisans.html \
  blog/combien-coute-site-vitrine-tpe-2026.html \
  blog/creation-site-internet-agde-guide-complet-2026.html
```

### Fichiers modifiés (13)

**Racine (10)** :
1. `index.html`
2. `mentions-legales.html`
3. `estimateur.html`
4. `rgpd-confidentialite.html`
5. `seo-local-herault.html`
6. `creation-site-web-agde.html`
7. `guide-tarifs.html`
8. `tarifs.html`
9. `comparatif-tarifs.html`
10. `devis.html`

**Blog (3)** :
11. `blog/seo-local-herault-restaurants-artisans.html`
12. `blog/combien-coute-site-vitrine-tpe-2026.html`
13. `blog/creation-site-internet-agde-guide-complet-2026.html`

### Fichiers NON concernés (vérifié)

- `merci.html`, `guide-seo-local.html`, `blog/index.html` : aucune référence à Lenis (intentionnel).

---

## 4. Vérification post-modification

```bash
# Doit retourner 0 fichier :
grep -l 'unpkg.com/lenis' *.html blog/*.html
# (aucun)

# Doit retourner les 13 fichiers traités :
grep -l '/assets/js/lenis.min.js' *.html blog/*.html | sort
# blog/combien-coute-site-vitrine-tpe-2026.html
# blog/creation-site-internet-agde-guide-complet-2026.html
# blog/seo-local-herault-restaurants-artisans.html
# comparatif-tarifs.html
# creation-site-web-agde.html
# devis.html
# estimateur.html
# guide-tarifs.html
# index.html
# mentions-legales.html
# rgpd-confidentialite.html
# seo-local-herault.html
# tarifs.html
```

✅ 0 résidu unpkg, 13 fichiers utilisent désormais le chemin local.

---

## 5. _headers et CSP

Conformément au brief, **aucune modification de `_headers`** dans ce lot.

La directive CSP `script-src` autorise toujours `unpkg.com` (laissé intentionnellement pour ne pas casser d'éventuelles ressources futures et garder le périmètre du sprint minimal).

**Amélioration future possible** : retirer `unpkg.com` de la CSP `script-src` et `connect-src` une fois confirmé qu'aucune autre ressource externe n'en dépend (audit à refaire en fin de Sprint 1B Lot 4).

---

## 6. Observations / Points d'attention

### 6.1. Incohérence des conventions de chemins (à arbitrer plus tard)

Le brief Lot 3 demande un chemin **absolu** `/assets/js/lenis.min.js` pour Lenis. C'est cohérent avec un déploiement Cloudflare Pages servi depuis la racine du domaine et fonctionnel en local sur `http://localhost:8080`.

**Cependant**, les autres scripts du repo utilisent des chemins **relatifs** :
- `index.html` ligne 1205 : `<script src="assets/js/analytics.js" defer>` (relatif sans `/`)
- `index.html` ligne 2094 : `<script src="./smooth-scroll.js">` (relatif explicite)
- `blog/seo-local-herault-restaurants-artisans.html` ligne 206 : `<script src="../assets/js/analytics.js" defer>`
- `blog/...` ligne 468 : `<script src="../smooth-scroll.js">`

**Conséquence** : Lenis est désormais le seul script chargé en chemin absolu. Cela fonctionne correctement (Cloudflare Pages → racine domaine) mais introduit une incohérence stylistique.

**Recommandation pour Lot 4 ou Sprint 2** : uniformiser tous les scripts (soit tous absolus, soit tous relatifs). L'absolu est plus robuste si jamais une page est déplacée dans une sous-arborescence ; le relatif facilite les preview locales `file://`.

### 6.2. Bénéfices du bundling local

- ✅ **Résilience** : indépendance vis-à-vis des incidents unpkg.
- ✅ **Performance** : 1 connexion HTTP en moins (pas de DNS/TLS handshake vers `unpkg.com`).
- ✅ **CSP** : permet à terme de durcir `script-src` (suppression de `unpkg.com` envisageable).
- ✅ **Confidentialité** : aucune fuite d'IP visiteur vers un CDN tiers.
- ✅ **Cache headers maîtrisés** : sera servi avec les directives Cloudflare Pages déjà configurées (cf. `_headers`), sans dépendance à la politique unpkg.

### 6.3. Maintenance future

Pour mettre à jour Lenis :
```bash
curl -sSL -o assets/js/lenis.min.js https://unpkg.com/lenis@<NEW_VERSION>/dist/lenis.min.js
shasum -a 256 assets/js/lenis.min.js   # vérifier le checksum
git diff assets/js/lenis.min.js        # inspecter le delta
```

---

## 7. Récapitulatif

| Critère                                  | Statut |
|------------------------------------------|--------|
| Version Lenis identifiée et cohérente    | ✅ `1.1.18` partout |
| Fichier téléchargé localement            | ✅ `assets/js/lenis.min.js` (13 Ko) |
| SHA-256 validé contre source unpkg       | ✅ `0bf174d39b9abc...125b0` (match) |
| Aucune balise HTML / page d'erreur       | ✅ |
| Servi en HTTP local avec bon MIME-type   | ✅ `text/javascript`, 200 OK |
| 13 fichiers HTML mis à jour              | ✅ |
| 0 résidu `unpkg.com/lenis` dans les HTML | ✅ |
| `_headers` / CSP intacts                 | ✅ |
| `analytics.js` non touché                | ✅ |
| Polices `.otf` non touchées              | ✅ |

**Lot 3 — terminé.**
