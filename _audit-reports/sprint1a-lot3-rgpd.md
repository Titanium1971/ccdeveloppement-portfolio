# Sprint 1A — Lot 3/4 : Mise à jour `rgpd-confidentialite.html`

**Date** : 2026-05-03
**Branche** : `sprint1a-rgpd-consentement`
**Fichier modifié** : `rgpd-confidentialite.html` (UNIQUEMENT)

---

## 1. Objectif du Lot 3

Faire correspondre la politique de confidentialité à la réalité technique post-Sprint 1A Lot 1 :

- GA4 et Microsoft Clarity sont effectivement déployés sur le site (chargés sous consentement).
- L'ancienne phrase « Le site n'utilise pas de cookies publicitaires ni d'outils de tracking marketing tiers sur la version actuelle. » était devenue **fausse et juridiquement risquée** (CNIL : information mensongère = défaut d'information).
- Documenter par transparence les services tiers utilisés sur action volontaire (Cloudflare, Brevo, Formspree, Cal.com).

---

## 2. Avant / Après — Section 6

### AVANT (état pré-Sprint 1A)

```html
<h2>6. Cookies et traceurs</h2>
<p>Le site n'utilise pas de cookies publicitaires ni d'outils de tracking marketing tiers sur la version actuelle.</p>
```

→ 1 paragraphe, 1 phrase, contradictoire avec la présence de GA4 + Clarity.

### APRÈS

```html
<h2>6. Cookies et mesure d'audience</h2>
<p>Le site peut utiliser, uniquement après votre consentement, des outils de mesure d'audience et d'analyse comportementale.</p>
<ul>
  <li><strong>Google Analytics 4</strong> : mesure de fréquentation, pages consultées, événements de conversion comme les demandes de devis ou clics vers WhatsApp et Cal.com.</li>
  <li><strong>Microsoft Clarity</strong> : analyse de l'expérience utilisateur, cartes de chaleur et enregistrements de session afin d'améliorer l'ergonomie du site.</li>
</ul>
<p style="margin-top:10px;">Ces outils ne sont chargés qu'après acceptation explicite. Vous pouvez refuser ou modifier votre choix à tout moment via le lien <a href="#" data-cookie-preferences>« Gérer mes préférences cookies »</a> présent en bas de chaque page.</p>
<p style="margin-top:18px;">Autres services tiers utilisés ponctuellement et uniquement sur action volontaire de votre part :</p>
<ul>
  <li><strong>Cloudflare</strong> : statistiques techniques et de sécurité liées à l'hébergement et à la protection du site.</li>
  <li><strong>Brevo / Sendinblue</strong> : envoi du guide SEO local après remplissage volontaire du formulaire dédié.</li>
  <li><strong>Formspree</strong> : transmission de votre demande après envoi volontaire du formulaire de devis.</li>
  <li><strong>Cal.com</strong> : prise de rendez-vous après réservation volontaire d'un créneau.</li>
</ul>
```

→ Titre renommé `Cookies et mesure d'audience`, 2 listes structurées + 3 paragraphes intercalaires.

### Choix de formatage

- **Niveau de titre** : `<h2>` conservé (la page n'utilise aucun `<h3>`, donc on reste cohérent).
- **Listes** : `<ul><li>` avec `<strong>` pour le nom du service, comme ailleurs sur le site.
- **Apostrophes** : typographiques `'` (cohérent avec « n'utilise », « l'effacement », etc. déjà présents).
- **Guillemets** : `«  »` pour la phrase « Gérer mes préférences cookies » (cohérent avec « droit à l'oubli » à la section 7).
- **Lien actif** : le texte « Gérer mes préférences cookies » est cliquable via `<a href="#" data-cookie-preferences>` — l'attribut `data-cookie-preferences` est auto-bindé par `analytics.js` (Lot 1) et ouvre la modale de préférences. Bonus utilisateur sans modifier d'autre fichier.

---

## 3. Confirmation : autres sections INTACTES

Vérification ligne par ligne après édition :

| Section | Numéro | Statut |
|---|---|---|
| Responsable du traitement | 1 | ✅ Inchangée |
| Données traitées | 2 | ✅ Inchangée |
| Finalités | 3 | ✅ Inchangée |
| Base légale | 4 | ✅ Inchangée |
| Durée de conservation | 5 | ✅ Inchangée |
| Cookies et mesure d'audience | 6 | 🔄 **Réécrite** (objet du lot) |
| Vos droits | 7 | ✅ Inchangée |
| Recours CNIL | 8 | ✅ Inchangée |
| Mise à jour | 9 | 🔄 Date uniquement |

**Aucune renumérotation nécessaire** : le nombre de sections (9) est identique avant et après.

**Aucune modification** :
- Du `<head>` (meta, title, description, og, canonical).
- Des styles CSS (balise `<style>` intacte).
- Du `<header>` / barre de top.
- Du `<footer>` (Cal.com, mentions, copyright).
- Des scripts (analytics.js defer, Cal.com embed, lenis, smooth-scroll).

---

## 4. Date de mise à jour

- **Avant** : `Dernière mise à jour : 25 mars 2026.`
- **Après** : `Dernière mise à jour : 3 mai 2026.` ✅
- Format français conservé (jour + mois littéral + année).

---

## 5. Contraintes respectées

- ✅ Aucune modification d'autre fichier (`analytics.js`, autres `.html`, `_headers` non touchés).
- ✅ Structure HTML existante respectée (h2, ul/li, classes, balises).
- ✅ Style et mise en page non cassés (mêmes balises et styles inline `margin-top` que le reste de la page).
- ✅ Apostrophes typographiques cohérentes avec le reste du document.
- ✅ Date système : 2026-05-03 → « 3 mai 2026 ».

---

## 6. Points à valider manuellement par Cyril

### 6.1. Durée de conservation des données analytiques (BLOQUANT pour conformité stricte)

La section 5 actuelle indique **« 12 mois à compter du dernier échange »** pour les données de contact.

Cette durée ne couvre PAS explicitement les données collectées par GA4 et Clarity. À vérifier dans les paramètres des comptes :

- **GA4** : la durée de conservation par défaut est de **2 mois** ou **14 mois** (paramétrable dans Admin → Conservation des données). Si Cyril a laissé la valeur par défaut, c'est probablement 2 mois.
  - Action : vérifier sur https://analytics.google.com → Admin → Paramètres des données → Conservation des données.
- **Microsoft Clarity** : conservation par défaut **3 mois** pour les enregistrements de session, **13 mois** pour les heatmaps agrégées.
  - Action : vérifier sur https://clarity.microsoft.com → Settings.

→ **Recommandation** : ajouter ultérieurement un §5 bis ou enrichir le §5 avec les durées GA4/Clarity dès que Cyril aura confirmé les valeurs (peut être traité en Lot 4 ou en hotfix).

### 6.2. Mention du Consent Mode v2 et de Google

GA4 transmet à Google Ireland Limited (UE) puis potentiellement à Google LLC (USA).

→ **Recommandation pour conformité maximale (non bloquant pour le Sprint 1A)** : ajouter une section dédiée aux **transferts hors UE** mentionnant les Standard Contractual Clauses (SCC) et le Data Privacy Framework (DPF) Google. À traiter en Sprint 1B si Cyril veut un niveau premium / conforme audit CNIL approfondi.

### 6.3. Cohérence avec le bandeau cookies

Le texte « Vous pouvez refuser ou modifier votre choix à tout moment via le lien "Gérer mes préférences cookies" présent en bas de chaque page » suppose que le **Lot 4** ajoutera effectivement ce lien dans le footer de toutes les pages.

→ **À surveiller** : si Lot 4 n'est pas exécuté, ce paragraphe devient également mensonger (un point juridique de moins, mais à corriger).

### 6.4. Adresse postale et identité du responsable de traitement

Section 1 actuelle : « CC Développement — Cyril Canon, 27 Rue Basse, 34300 Agde ».

→ Vérifier que l'adresse est toujours valide (mention légale doit toujours correspondre à la déclaration d'activité). Pas de doute connu, mais à confirmer.

### 6.5. Mention de Brevo / Sendinblue

Le rapport mentionne Brevo (ex-Sendinblue) pour le téléchargement du guide SEO local. Vérification rapide effectuée :

- Branding actuel = **Brevo** depuis 2023.
- L'écriture « Brevo / Sendinblue » est tolérée pendant la transition mais peut être simplifiée en « Brevo » seul si Cyril le préfère.

→ Aucune action urgente, simple cosmétique.

---

## 7. Tests recommandés (avant merge)

1. **Visual** : ouvrir `rgpd-confidentialite.html` dans un navigateur, vérifier que la mise en page de la section 6 est cohérente avec les autres sections (espacement, couleur, listes alignées).
2. **Fonctionnel** : cliquer sur « Gérer mes préférences cookies » dans la section 6 → la modale Lot 1 doit s'ouvrir.
3. **Lighthouse / a11y** : vérifier que les listes restent navigables au clavier et que les liens ont un `href` valide.
4. **Diff git** : `git diff rgpd-confidentialite.html` ne doit montrer QUE les changements section 6 + date section 9.
5. **Aucun autre fichier modifié** : `git status` ne doit faire apparaître que `rgpd-confidentialite.html` et `_audit-reports/sprint1a-lot3-rgpd.md` sur ce lot.

---

## 8. Récapitulatif modifications

| Élément | Type | Lignes affectées |
|---|---|---|
| `<h2>6. Cookies et traceurs</h2>` | Renommé | ligne 75 → `Cookies et mesure d'audience` |
| Paragraphe lapidaire « n'utilise pas... » | Remplacé | ligne 76 → bloc complet (paragraphe + 2 listes + 3 paragraphes) |
| Date § 9 | Mise à jour | ligne 93 → 105 (`25 mars 2026` → `3 mai 2026`) |

**Total** : 1 fichier modifié, ~14 lignes ajoutées, 1 ligne remplacée, 1 ligne mise à jour.

---

## 9. Statut

✅ **Lot 3/4 terminé.**
🔜 **Prochain lot** : Lot 4/4 — ajout du lien « Gérer mes préférences cookies » dans le footer commun de toutes les pages HTML du site (déclencheur `[data-cookie-preferences]` déjà auto-bindé par `analytics.js`).
