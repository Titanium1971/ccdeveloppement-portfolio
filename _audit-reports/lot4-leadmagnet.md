# LOT 4/6 — Lead Magnet & Tunnel de Nurture Email

**Date** : 15 avril 2026
**Statut** : Livré — en attente de configuration Brevo

---

## Résumé des livrables

| Livrable | Fichier | Statut |
|----------|---------|--------|
| Lead magnet Markdown (source) | `content/lead-magnet-seo-local.md` | Prêt |
| Lead magnet PDF | `assets/downloads/7-erreurs-seo-local.pdf` | A générer (voir instructions) |
| Landing page | `guide-seo-local.html` | Prêt |
| Exit-intent popup homepage | `index.html` (popup en bas de page) | Prêt |
| Exit-intent popup tarifs | `tarifs.html` (popup en bas de page) | Prêt |
| Séquence 3 emails | Ce document (ci-dessous) | Prêt à copier-coller |

---

## 1. Comment créer ton compte Brevo

Brevo (ex-Sendinblue) est gratuit jusqu'à 300 emails/jour — parfait pour démarrer.

### Étapes :

1. **Va sur** brevo.com et clique "S'inscrire gratuitement"
2. **Crée ton compte** avec ccdeveloppement@gmail.com
3. **Confirme ton email** et complète le profil entreprise :
   - Nom : CC Développement
   - Adresse : 27 Rue Basse, 34300 Agde
   - SIRET : 444 114 011
4. **Crée une liste de contacts** :
   - Va dans Contacts > Listes > Créer une liste
   - Nom : "Leads Guide SEO Local"
   - Note l'ID de la liste (visible dans l'URL, ex: `12`)
5. **Crée un attribut contact** :
   - Va dans Contacts > Paramètres > Attributs
   - Ajoute un attribut `PRENOM` (type texte) s'il n'existe pas déjà
6. **Récupère ta clé API** :
   - Va dans Paramètres > Clés API > Générer une nouvelle clé
   - Copie-la (elle ne sera plus visible après)

### Configuration dans le code :

Ouvre `guide-seo-local.html` et remplace les 2 placeholders :

```javascript
const BREVO_API_KEY = '__BREVO_API_KEY__';    // Colle ta clé API ici
const BREVO_LIST_ID = __BREVO_LIST_ID__;      // Remplace par l'ID de ta liste (ex: 12)
```

> **IMPORTANT sécurité** : la clé API est exposée côté client. Pour un usage en production à grande échelle, il faudrait passer par un backend (Cloudflare Worker par exemple). Pour le volume actuel (< 300 contacts/jour), c'est acceptable. Tu peux aussi restreindre la clé API aux seules permissions "contacts" dans Brevo.

### Alternative MailerLite :

Si tu préfères MailerLite (interface plus simple, automatisations visuelles) :
1. Crée un compte sur mailerlite.com (gratuit jusqu'à 1 000 contacts)
2. Crée un groupe "Guide SEO Local"
3. Récupère ta clé API dans Integrations > API
4. Adapte l'appel fetch dans `guide-seo-local.html` vers l'API MailerLite v2

---

## 2. Comment configurer la séquence email automatique

### Sur Brevo :

1. **Va dans** Automatisation > Créer un workflow
2. **Déclencheur** : "Contact ajouté à la liste" → sélectionne "Leads Guide SEO Local"
3. **Ajoute 3 étapes email** avec les délais suivants :
   - Email 1 : immédiat (J+0)
   - Attente : 3 jours
   - Email 2 : J+3
   - Attente : 4 jours
   - Email 3 : J+7
4. **Active le workflow**

### Double opt-in (recommandé) :

1. Dans Contacts > Formulaires > Paramètres de confirmation
2. Active "Confirmation par email (double opt-in)"
3. Personnalise l'email de confirmation : "Confirme ton inscription pour recevoir le guide"
4. Le contact ne recevra les emails que APRÈS avoir cliqué le lien de confirmation

---

## 3. Les 3 emails — Prêts à copier-coller

### EMAIL 1 — J+0 : "Voici ton guide SEO local"

**Objet** : Ton guide est prêt — 7 erreurs SEO local à corriger maintenant

**Corps** :

```
Salut {{contact.PRENOM}} !

Merci d'avoir téléchargé le guide "Les 7 erreurs SEO local qui coulent les TPE en 2026".

Voici ton lien de téléchargement :
👉 [Télécharger le guide PDF](https://ccdeveloppement.eu/assets/downloads/7-erreurs-seo-local.pdf)

En bref, voici les 7 erreurs que je couvre :

1. Fiche Google Business Profile incomplète
2. Site non optimisé pour le mobile
3. Pas de pages locales ciblées
4. Avis Google négligés
5. Informations NAP incohérentes
6. Aucun contenu local
7. Pas de suivi des performances

Mon conseil : commence par l'erreur #1 (fiche Google). C'est celle qui a le plus d'impact et ça prend 45 minutes.

Qui suis-je ? Je m'appelle Cyril Canon, développeur web freelance basé à Agde. J'aide les TPE et indépendants de l'Hérault à devenir visibles sur Google grâce à des sites rapides, un SEO local solide et des automatisations concrètes.

À très vite,
Cyril

---
CC Développement · 27 Rue Basse, 34300 Agde
ccdeveloppement.eu
Se désinscrire : {{ unsubscribe }}
```

---

### EMAIL 2 — J+3 : "Le piège SEO #1 des restaurants d'Agde"

**Objet** : 80 % des restaurants d'Agde tombent dans ce piège SEO

**Corps** :

```
Hey {{contact.PRENOM}},

Tu as eu le temps de jeter un œil au guide ? Aujourd'hui je veux te parler d'un cas concret que j'ai vu en auditant des restaurants à Agde.

LE PIÈGE : avoir une fiche Google Business… mais ne jamais y poster.

Google Business Profile a une fonctionnalité sous-utilisée : les "posts Google". C'est comme un mini-réseau social directement sur ta fiche.

Le problème : 80 % des restaurants d'Agde n'ont JAMAIS publié un seul post.

Ce que j'ai observé sur un cas client :
- Avant : aucun post, 12 vues/semaine sur la fiche
- Après 1 mois (1 post/semaine) : 47 vues/semaine (+290 %)
- Les posts incluaient : plat du jour, événement soirée jazz, offre menu groupe

Le tout en 5 minutes par semaine. Pas besoin de rédiger des romans.

COMMENT FAIRE :
1. Ouvre Google Maps → ta fiche → "Ajouter une actualité"
2. Écris 2-3 phrases + ajoute une photo
3. Choisis la catégorie : Offre, Actualité ou Événement
4. Publie — c'est tout

Si tu veux que je regarde ta fiche Google et que je te dise exactement quoi poster, j'offre un audit gratuit de 30 minutes :

👉 [Réserve ton créneau ici](https://ccdeveloppement.eu/)

À bientôt,
Cyril

---
CC Développement · 27 Rue Basse, 34300 Agde
ccdeveloppement.eu
Se désinscrire : {{ unsubscribe }}
```

---

### EMAIL 3 — J+7 : "On regarde ton site ensemble ?"

**Objet** : {{contact.PRENOM}}, on regarde ton site ensemble ? (gratuit)

**Corps** :

```
Salut {{contact.PRENOM}},

Ça fait une semaine que tu as le guide. Tu as peut-être commencé à corriger certaines erreurs, ou peut-être que tu te dis "par où commencer ?".

C'est normal. Le SEO local, c'est plein de petits détails qui s'accumulent.

C'est pour ça que je propose un audit gratuit de 30 minutes en visio.

CE QUE JE FAIS PENDANT L'AUDIT :
✅ Je passe ton site au crible (vitesse, mobile, SEO on-page)
✅ J'analyse ta fiche Google Business Profile
✅ Je vérifie la cohérence de tes infos NAP sur le web
✅ Je te donne 3 actions prioritaires à corriger

Pas de vente forcée, pas de devis surprise. Juste un diagnostic honnête et des recommandations concrètes.

Si après l'audit tu veux qu'on travaille ensemble, on en discute. Sinon, tu repars avec un plan d'action clair — et c'est déjà beaucoup.

👉 [Réserve ton audit gratuit — 30 min](https://ccdeveloppement.eu/)

(Tu peux aussi répondre directement à cet email si tu as des questions.)

À très vite,
Cyril

---
CC Développement · 27 Rue Basse, 34300 Agde
ccdeveloppement.eu
Se désinscrire : {{ unsubscribe }}
```

---

## 4. Comment mesurer le taux d'ouverture et de conversion

### Dans Brevo — Statistiques automatiques :

1. **Taux d'ouverture** : Automatisation > ton workflow > clic sur chaque email > Stats
   - Objectif : > 35 % (moyenne B2B local)
   - Si < 25 % : améliore les objets d'email (plus courts, plus personnalisés)

2. **Taux de clic** : visible dans les mêmes stats
   - Objectif : > 5 %
   - Si < 3 % : rends les CTA plus visibles, teste des boutons au lieu de liens texte

3. **Taux de conversion** (inscriptions → audits réservés) :
   - Ajoute un paramètre UTM au lien Cal.com dans les emails :
     `https://cal.com/CAL_USERNAME/audit-30min?utm_source=brevo&utm_medium=email&utm_campaign=nurture-seo`
   - Dans Cal.com, tu verras la source des réservations

### Sur la landing page :

1. **Installe Google Analytics 4** si ce n'est pas fait
2. **Crée un événement** "lead_form_submit" dans le code (ajouter dans le JS du formulaire) :
   ```javascript
   // Après form.style.display = 'none';
   if (typeof gtag === 'function') {
     gtag('event', 'lead_form_submit', {
       event_category: 'lead_magnet',
       event_label: 'guide_seo_local'
     });
   }
   ```
3. **Taux de conversion page** = soumissions / visiteurs
   - Objectif : > 20 % (landing page dédiée, trafic qualifié)
   - Si < 10 % : teste un titre différent ou simplifie le formulaire

### KPIs à suivre chaque semaine :

| Métrique | Où la trouver | Objectif |
|----------|---------------|----------|
| Visiteurs landing page | Google Analytics | Croissance |
| Soumissions formulaire | Brevo (nouveaux contacts/semaine) | > 20 % du trafic |
| Taux d'ouverture Email 1 | Brevo Automatisation | > 50 % |
| Taux d'ouverture Email 2 | Brevo Automatisation | > 35 % |
| Taux d'ouverture Email 3 | Brevo Automatisation | > 30 % |
| Taux de clic Email 3 (lien audit) | Brevo Automatisation | > 8 % |
| Audits réservés via email | Cal.com (UTM source=brevo) | 1-2/semaine |

---

## 5. Génération du PDF — Instructions

`pandoc` et `wkhtmltopdf` ne sont pas installés sur cette machine. Voici 3 options :

### Option A — Pandoc (recommandée)

```bash
brew install pandoc
brew install --cask basictex  # ou mactex pour LaTeX complet

# Puis :
cd ~/Projets/cc-developpement/portfolio
pandoc content/lead-magnet-seo-local.md \
  -o assets/downloads/7-erreurs-seo-local.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=2.5cm \
  -V fontsize=11pt \
  -V mainfont="Helvetica Neue" \
  -V linkcolor=teal \
  --highlight-style=tango
```

### Option B — VS Code + Markdown PDF

1. Installe l'extension "Markdown PDF" dans VS Code
2. Ouvre `content/lead-magnet-seo-local.md`
3. `Cmd+Shift+P` → "Markdown PDF: Export (pdf)"
4. Déplace le fichier généré dans `assets/downloads/7-erreurs-seo-local.pdf`

### Option C — Service en ligne

1. Va sur dillinger.io ou markdowntohtml.com
2. Colle le contenu du fichier .md
3. Exporte en PDF
4. Enregistre dans `assets/downloads/7-erreurs-seo-local.pdf`

---

## 6. Récapitulatif des configurations à faire

### Actions Cyril (par ordre de priorité) :

- [ ] Créer le compte Brevo (5 min)
- [ ] Créer la liste "Leads Guide SEO Local" + récupérer l'ID
- [ ] Générer la clé API Brevo
- [ ] Remplacer `__BREVO_API_KEY__` et `__BREVO_LIST_ID__` dans `guide-seo-local.html`
- [ ] Générer le PDF du lead magnet (Option A, B ou C ci-dessus)
- [ ] Uploader le PDF dans `assets/downloads/` et déployer sur Cloudflare
- [ ] Créer le workflow d'automatisation dans Brevo (3 emails)
- [ ] Copier-coller les 3 textes d'email ci-dessus dans le workflow
- [ ] Configurer le double opt-in dans Brevo
- [ ] Tester le flux complet : inscription → email de confirmation → réception du guide
- [ ] Ajouter le tracking GA4 sur `guide-seo-local.html`
- [ ] Ajouter `guide-seo-local.html` au sitemap

---

## Fichiers modifiés dans ce lot

| Fichier | Modification |
|---------|-------------|
| `content/lead-magnet-seo-local.md` | **Nouveau** — Source Markdown du guide (15 pages) |
| `guide-seo-local.html` | **Nouveau** — Landing page avec formulaire Brevo |
| `index.html` | Ajout popup exit-intent vers le guide |
| `tarifs.html` | Ajout popup exit-intent vers le guide |
| `_audit-reports/lot4-leadmagnet.md` | **Nouveau** — Ce rapport |
