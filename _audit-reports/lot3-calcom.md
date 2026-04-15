# Lot 3/6 — Prise de RDV Cal.com

## Modifications effectuees

### Pages modifiees (11 pages)

| Page | Modifications |
|------|---------------|
| **index.html** | CTA hero principal remplace par Cal.com popup, CTA Cal.com ajoute en tete de section contact, footer CTA outline, barre sticky mobile |
| **devis.html** | Bloc "Tu preferes en parler ?" avec CTA Cal.com apres le formulaire, footer CTA outline, barre sticky mobile |
| **merci.html** | Bloc "Tu veux accelerer ? Bloque 30 min maintenant." avant les cartes CTA, footer CTA outline, barre sticky mobile |
| **tarifs.html** | Footer CTA outline + script Cal.com |
| **estimateur.html** | Footer CTA outline + script Cal.com |
| **guide-tarifs.html** | Footer CTA outline + script Cal.com |
| **comparatif-tarifs.html** | Footer CTA outline (couleur verte adaptee au theme clair) + script Cal.com |
| **creation-site-web-agde.html** | Footer CTA outline + script Cal.com |
| **seo-local-herault.html** | Footer CTA outline + script Cal.com |
| **mentions-legales.html** | Footer CTA outline + script Cal.com |
| **rgpd-confidentialite.html** | Footer CTA outline + script Cal.com |

### Classes CSS ajoutees

- `.btn-cal` — Bouton plein vert accent (#39FF14), meme style que `.btn-primary` (shine effect, glow au hover)
- `.btn-cal--outline` — Bouton outline vert, utilise dans les footers (discret mais cliquable)
- `.footer-cal` — Conteneur du CTA dans le footer
- `.cal-alternative` — Bloc "Tu preferes en parler" sur devis.html
- `.cal-accelerate` — Bloc "Tu veux accelerer" sur merci.html
- `.sticky-cal` — Barre flottante mobile fixee en bas d'ecran (visible uniquement < 768px)

### Comportement mobile

Sur mobile (< 768px), une barre sticky apparait en bas d'ecran avec le CTA "Reserve ton audit gratuit" sur :
- Homepage (index.html)
- Page devis (devis.html)
- Page merci (merci.html)

Le footer a un `padding-bottom: 80px` pour ne pas etre masque par la barre sticky.

---

## Configuration Cal.com — Guide pour Cyril

### 1. Creer ton compte Cal.com

1. Va sur **cal.com** et cree un compte gratuit
2. Choisis ton username : `cyril-canon` (ou ce que tu veux)
3. Configure ton fuseau horaire : Europe/Paris
4. Connecte ton Google Calendar pour eviter les conflits de creneaux

### 2. Creer l'event type "Audit 30 min"

1. Dashboard Cal.com > **Event Types** > **New Event Type**
2. Configuration :
   - **Titre** : Audit gratuit — 30 min
   - **Slug** : `audit-30min`
   - **Duree** : 30 minutes
   - **Lieu** : Google Meet (ou telephone, ou les deux en laissant le choix)
   - **Description** : "Echange de 30 minutes pour comprendre votre projet web, vos objectifs et vous proposer un plan d'action concret. Gratuit et sans engagement."
3. **Disponibilites** : configure tes creneaux (ex: lun-ven 9h-12h / 14h-18h)
4. **Buffer** : ajoute 15 min de buffer entre les RDV
5. **Limites** : max 3 audits par jour pour ne pas te surcharger

### 3. Remplacer CAL_USERNAME dans le code

Fais un rechercher-remplacer global dans tous les fichiers HTML :

```
Chercher :  CAL_USERNAME
Remplacer : cyril-canon   (ou ton username Cal.com)
```

Fichiers concernes : index.html, devis.html, merci.html, tarifs.html, estimateur.html, guide-tarifs.html, comparatif-tarifs.html, creation-site-web-agde.html, seo-local-herault.html, mentions-legales.html, rgpd-confidentialite.html

Le lien final sera : `cyril-canon/audit-30min`

### 4. Questions de pre-qualification Cal.com

Dans Cal.com, va dans ton event type > **Additional questions** et ajoute :

| Question | Type | Obligatoire |
|----------|------|-------------|
| Quel est votre secteur d'activite ? (ex: restaurant, artisan, commerce...) | Texte court | Oui |
| Avez-vous deja un site web ? Si oui, quelle est l'adresse ? | Texte court | Non |
| Quel est votre objectif principal ? (plus de clients, visibilite Google, automatiser...) | Texte long | Oui |
| Avez-vous une enveloppe budget en tete ? | Select : Moins de 1000EUR / 1000-3000EUR / 3000-6000EUR / Plus de 6000EUR / A definir | Non |

Ces questions permettent de :
- Filtrer les curieux des vrais prospects
- Arriver au RDV deja informe du contexte
- Adapter le discours au secteur du prospect

### 5. Template d'email de confirmation Cal.com

Dans Cal.com > **Workflows** > cree un workflow "Confirmation + rappel" :

**Email de confirmation (envoye immediatement) :**

```
Objet : Votre audit gratuit est confirme — {date} a {heure}

Bonjour {nom},

Merci d'avoir reserve votre audit gratuit de 30 minutes.

Recapitulatif :
- Date : {date} a {heure}
- Lieu : {lieu} (lien Google Meet inclus si applicable)
- Duree : 30 minutes

Ce que nous allons couvrir :
1. Comprendre votre activite et vos objectifs
2. Analyser votre presence en ligne actuelle
3. Identifier les 3 actions prioritaires pour votre visibilite locale
4. Vous donner un plan d'action concret (meme si on ne travaille pas ensemble)

Pour preparer au mieux notre echange, vous pouvez reflechir a :
- Ce qui fonctionne / ne fonctionne pas avec votre site actuel
- Vos 3 concurrents locaux principaux
- Votre objectif n1 pour les 6 prochains mois

A {jour},
Cyril Canon
CC Developpement
06 20 26 21 53
```

**Email de rappel (envoye 1h avant) :**

```
Objet : Rappel — Votre audit dans 1 heure

Bonjour {nom},

Petit rappel : notre audit gratuit est prevu dans 1 heure ({heure}).

Lien de connexion : {lieu}

A tout de suite,
Cyril
```

### 6. Conseils supplementaires

- **Theme dark** : Le popup Cal.com est configure en theme sombre avec la couleur accent #39FF14 pour matcher la charte du site
- **Analytics** : Les clics sur les boutons Cal.com sont deja traces par le fichier analytics.js existant (tracking des clics CTA)
- **Google Calendar** : Pense a connecter ton agenda Google pour que Cal.com bloque automatiquement les creneaux deja pris
- **Notifications** : Active les notifications SMS en plus des emails pour ne rater aucun RDV

---

## Verification

- [ ] Compte Cal.com cree
- [ ] Event type "audit-30min" configure
- [ ] CAL_USERNAME remplace dans les 11 fichiers HTML
- [ ] Questions de pre-qualification ajoutees
- [ ] Email de confirmation personnalise
- [ ] Google Calendar connecte
- [ ] Test d'un booking complet sur le site en production
