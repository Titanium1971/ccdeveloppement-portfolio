# Lot 2/6 — Tracking d'acquisition et de conversion

**Date** : 15 avril 2026
**Statut** : Implemente — en attente des IDs de production

---

## Resume des modifications

| Fichier | Description |
|---------|-------------|
| `assets/js/analytics.js` | Script unique : GA4 + Consent Mode v2 + bandeau cookies + evenements de conversion + Microsoft Clarity |
| 11 pages HTML | Ajout de `<script src="assets/js/analytics.js" defer>` dans le `<head>` |

---

## 1. Creer ton compte Google Analytics 4

1. Va sur [analytics.google.com](https://analytics.google.com/)
2. Connecte-toi avec ton compte Google (ccdeveloppement@gmail.com)
3. Clique **Commencer les mesures**
4. Cree un compte : `CC Developpement`
5. Cree une propriete : `Portfolio CC Dev`
6. Choisis **Web** comme plateforme
7. Renseigne l'URL du site (ex. `https://ccdeveloppement.com`) et le nom du flux (`Portfolio`)
8. Tu obtiens un **Measurement ID** au format `G-XXXXXXXXXX`

### Ou remplacer le placeholder

Dans `assets/js/analytics.js`, ligne 13 :
```js
var GA_ID = 'GA_MEASUREMENT_ID';
```
Remplace `GA_MEASUREMENT_ID` par ton vrai ID, ex. :
```js
var GA_ID = 'G-ABC123XYZ';
```

**Doc officielle** : [support.google.com/analytics/answer/9304153](https://support.google.com/analytics/answer/9304153)

---

## 2. Creer ton compte Microsoft Clarity

1. Va sur [clarity.microsoft.com](https://clarity.microsoft.com/)
2. Connecte-toi (compte Microsoft ou Google)
3. Cree un nouveau projet : `CC Developpement Portfolio`
4. Renseigne l'URL du site
5. Tu obtiens un **Project ID** (ex. `abcdef1234`)

### Ou remplacer le placeholder

Dans `assets/js/analytics.js`, ligne 14 :
```js
var CLARITY_ID = 'CLARITY_PROJECT_ID';
```
Remplace `CLARITY_PROJECT_ID` par ton vrai ID.

**Doc officielle** : [learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-setup](https://learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-setup)

---

## 3. Consent Mode v2 (RGPD)

Le script respecte le Consent Mode v2 de Google :

- **Par defaut** : `analytics_storage = 'denied'` — aucun cookie pose avant acceptation
- Un **bandeau cookies** s'affiche a la premiere visite
- Si l'utilisateur clique **Accepter** : `analytics_storage` passe a `'granted'`, le choix est sauvegarde dans `localStorage`
- Si l'utilisateur clique **Refuser** : le choix est sauvegarde, le bandeau ne reapparait plus

Meme en mode `denied`, GA4 recoit des pings anonymises (mode consent, sans cookies) ce qui permet d'avoir des donnees modelisees.

---

## 4. Evenements de conversion configures

| Evenement | Declencheur | Categorie |
|-----------|-------------|-----------|
| `form_start` | Premier focus sur un champ du formulaire devis | engagement |
| `form_submit` | Soumission du formulaire devis + chargement de `merci.html` | conversion |
| `cta_click` | Clic sur lien WhatsApp, telephone, email ou Cal.com | engagement |
| `scroll_depth` | Scroll a 25%, 50%, 75%, 100% de la page | engagement |
| `outbound_click` | Clic vers LinkedIn ou tout lien externe | engagement |

### Voir les evenements dans GA4

1. Va dans **Rapports > Temps reel** pour voir les evenements en direct
2. Va dans **Configurer > Evenements** pour voir tous les evenements recus
3. Les parametres personnalises (`cta_type`, `depth`, `form_name`, etc.) apparaissent dans le detail de chaque evenement

---

## 5. Configurer les conversions dans GA4

L'evenement le plus important est `form_submit` — c'est ta conversion principale (demande de devis).

1. Dans GA4, va dans **Admin > Evenements**
2. Trouve l'evenement `form_submit`
3. Active le toggle **Marquer comme conversion** (ou **Evenement cle** dans la nouvelle interface)
4. Tu peux aussi marquer `cta_click` comme conversion secondaire

### Entonnoir de conversion recommande

```
Visiteur → form_start (intention) → form_submit (conversion) → merci.html (confirmation)
```

Tu pourras creer un **entonnoir personnalise** dans GA4 > Explorer pour visualiser ce parcours.

---

## 6. Ce que Clarity t'apporte en plus

- **Heatmaps** : ou les visiteurs cliquent et scrollent sur chaque page
- **Session Replay** : rejoue les sessions pour comprendre le comportement
- **Dead clicks** : detecte les clics sur des elements non-cliquables
- **Rage clicks** : detecte la frustration (clics repetes au meme endroit)
- **Gratuit et illimite**

---

## 7. Checklist de mise en production

- [ ] Creer le compte GA4 et recuperer le Measurement ID
- [ ] Creer le compte Clarity et recuperer le Project ID
- [ ] Remplacer `GA_MEASUREMENT_ID` dans `assets/js/analytics.js`
- [ ] Remplacer `CLARITY_PROJECT_ID` dans `assets/js/analytics.js`
- [ ] Deployer sur Cloudflare Pages
- [ ] Verifier dans GA4 > Temps reel que les evenements remontent
- [ ] Verifier dans Clarity que les sessions s'enregistrent
- [ ] Marquer `form_submit` comme conversion dans GA4
