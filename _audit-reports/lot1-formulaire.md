# Lot 1/6 — Audit et réparation du formulaire de devis

**Date** : 2026-04-15
**Fichiers modifiés** : `devis.html`, `merci.html` (créé)
**Fichiers analysés** : `index.html`, `estimateur.html`, tous les HTML du projet

---

## État avant

### Formulaire devis.html
- **Endpoint backend** : aucun. Le formulaire utilisait un lien `mailto:` qui ouvrait le client mail du visiteur.
- **Ce qui se passait au submit** : validation JS côté client → construction d'un lien `mailto:canon@ccdeveloppement.eu` → `window.location.href = mailto` → affichage d'un message de succès après 800ms.
- **Problème critique** : aucun email n'était réellement envoyé. Le visiteur devait avoir un client mail configuré (Outlook, Thunderbird, Apple Mail). Sur mobile ou avec Gmail web, le lien ne fonctionnait souvent pas. Le message "Demande envoyée !" s'affichait même si l'email n'avait pas été envoyé.
- **Email automatique au prospect** : non.
- **Email automatique à Cyril** : non (dépendait du client mail du visiteur).
- **Message de confirmation** : un `div.success-state` inline dans la page, affiché après timeout — trompeur car l'envoi n'était pas garanti.
- **Anti-spam** : aucun.

### Autres formulaires
- `index.html` : aucun formulaire.
- `estimateur.html` : pas un formulaire de contact — c'est un calculateur interactif qui génère aussi un `mailto:`. Non modifié dans ce lot.

### Champs existants
- Nom et prénom (required)
- Adresse e-mail (required)
- Téléphone (optionnel)
- Type de projet (required, select)
- Budget envisagé (optionnel, select — 6 options)
- Délai souhaité (optionnel, select — 4 options)
- Description du projet (required, textarea)
- **Manquant** : volume de pages

---

## Modifications apportées

### 1. Intégration Formspree (devis.html)
- Ajout de `action="https://formspree.io/f/VOTRE_FORM_ID"` et `method="POST"` sur le `<form>`.
- Ajout d'un champ caché `_subject` pour l'objet de l'email reçu par Cyril.
- Ajout d'un champ caché `_next` pointant vers `https://ccdeveloppement.eu/merci.html` (redirection Formspree native).
- Remplacement du `mailto:` par un `fetch()` avec `Accept: application/json` pour soumission AJAX.
- En cas de succès : redirection vers `./merci.html`.
- En cas d'erreur : message d'alerte avec détails + réactivation du bouton.

### 2. Anti-spam
- **Honeypot** : champ `_gotcha` caché (`display:none`), invisible pour les humains, rempli par les bots → Formspree rejette la soumission.
- **Rate limit côté client** : 1 soumission max par minute (variable `lastSubmit`).
- **Note** : Formspree inclut aussi son propre anti-spam côté serveur (reCAPTCHA invisible sur les plans payants).

### 3. Nouveau champ : volume de pages
- Champ `<input type="number" name="pages">` ajouté entre "Délai souhaité" et "Décrivez votre projet".
- Placeholder : "Ex : 5", min: 1, max: 200.
- Optionnel.

### 4. Page de confirmation (merci.html — créée)
- Design cohérent avec le reste du site (même fonts, couleurs, navbar, footer).
- Contenu : checkmark, titre "Demande bien reçue", description rassurante, 3 badges de confirmation.
- **2 CTA** :
  - "Voir mes réalisations" → `index.html#realisations`
  - "Réserver un appel" → `devis.html` (coordonnées téléphone/WhatsApp)
- `noindex,nofollow` pour ne pas indexer cette page.

### 5. Champs budget et délai
- Déjà présents avec des options pertinentes. Non modifiés (les fourchettes existantes sont plus granulaires que celles demandées dans le brief, ce qui est mieux pour qualifier les prospects).

---

## Comment tester

### Test local
1. Ouvrir `devis.html` dans un navigateur.
2. Remplir le formulaire et soumettre → **erreur attendue** tant que `VOTRE_FORM_ID` n'est pas remplacé par un vrai ID Formspree.
3. Vérifier que la validation fonctionne (champs requis, email invalide, message trop court).
4. Vérifier que le champ honeypot est bien invisible.
5. Ouvrir `merci.html` directement pour vérifier le design et les liens.

### Test avec Formspree
1. Créer un formulaire sur [formspree.io](https://formspree.io).
2. Remplacer `VOTRE_FORM_ID` dans `devis.html` (ligne du `<form action=...>`).
3. Soumettre un test → vérifier la réception dans le dashboard Formspree ET dans la boîte mail configurée.
4. Vérifier la redirection vers `merci.html`.

---

## Ce qui reste à faire manuellement par Cyril

### Obligatoire
- [ ] **Créer un compte Formspree** sur [formspree.io](https://formspree.io) (plan gratuit = 50 soumissions/mois, suffisant pour démarrer).
- [ ] **Créer un formulaire** dans le dashboard Formspree et récupérer le Form ID (format : `xyzabcde`).
- [ ] **Remplacer `VOTRE_FORM_ID`** dans `devis.html` par le vrai ID. Chercher `formspree.io/f/VOTRE_FORM_ID` dans le fichier.
- [ ] **Configurer l'email de destination** dans Formspree : `canon@ccdeveloppement.eu`.
- [ ] **Tester une soumission** complète et vérifier la réception.
- [ ] **Déployer** sur Cloudflare Pages.

### Optionnel (recommandé)
- [ ] Activer les notifications email dans Formspree (pour recevoir chaque soumission par mail).
- [ ] Configurer un auto-répondeur Formspree (pour envoyer un email de confirmation au prospect — disponible sur plan payant).
- [ ] Activer reCAPTCHA dans Formspree pour un anti-spam renforcé (plan payant).
- [ ] Mettre à jour l'URL `_next` si le domaine change (actuellement `https://ccdeveloppement.eu/merci.html`).

### Estimateur (hors scope de ce lot)
- `estimateur.html` utilise aussi un `mailto:` pour envoyer les devis estimés. À convertir dans un lot futur si souhaité.

---

## Fichiers créés/modifiés

| Fichier | Action |
|---------|--------|
| `devis.html` | Modifié — Formspree, honeypot, rate limit, champ pages |
| `merci.html` | Créé — page de confirmation post-soumission |
| `_audit-reports/lot1-formulaire.md` | Créé — ce rapport |
