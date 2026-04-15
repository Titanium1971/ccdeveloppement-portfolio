# Guide de demarrage — CC Developpement

Suis ce guide etape par etape, dans l'ordre. Temps total : ~3h30.

---

## ETAPE 1 — Formspree (formulaire de devis)

**Temps : 10 min**

1. Va sur **formspree.io** → cree un compte gratuit avec ccdeveloppement@gmail.com
2. Clique **New Form** → choisis un nom (ex: "Devis CC Dev")
3. Copie le **Form ID** (format: `xyzabcde`)
4. Ouvre `devis.html` dans VS Code
5. Cherche `VOTRE_FORM_ID` → remplace par ton Form ID
6. Dans Formspree > Settings > Email : verifie que l'email de destination est correct
7. Active les notifications email

**Test** : ouvre devis.html dans le navigateur, soumets un test → tu dois recevoir l'email dans ta boite.

---

## ETAPE 2 — Cal.com (prise de RDV)

**Temps : 30 min**

1. Va sur **cal.com** → cree un compte gratuit
2. Choisis ton username (ex: `cyril-canon`)
3. Configure ton fuseau horaire : Europe/Paris
4. Connecte ton **Google Calendar** (Settings > Calendar)
5. Cree un **Event Type** :
   - Titre : `Audit gratuit — 30 min`
   - Slug : `audit-30min`
   - Duree : 30 min
   - Lieu : Google Meet
   - Buffer : 15 min entre les RDV
   - Limite : max 3/jour
6. Ajoute les **questions de pre-qualification** (Event > Additional questions) :
   - "Quel est votre secteur d'activite ?" (texte court, obligatoire)
   - "Avez-vous deja un site web ? Si oui, l'adresse ?" (texte court, optionnel)
   - "Quel est votre objectif principal ?" (texte long, obligatoire)
   - "Budget en tete ?" (select: <1000 / 1000-3000 / 3000-6000 / >6000 / A definir, optionnel)
7. Configure les emails (Workflows) : voir les templates dans `_audit-reports/lot3-calcom.md`
8. **Remplace CAL_USERNAME dans le code** :
   - Dans VS Code : `Cmd+Shift+H` (chercher-remplacer global)
   - Chercher : `CAL_USERNAME`
   - Remplacer : ton username (ex: `cyril-canon`)
   - Remplace tout (26 occurrences dans 12 fichiers)

**Test** : ouvre index.html, clique "Reserve ton audit gratuit" → le popup Cal.com doit s'ouvrir.

---

## ETAPE 3 — Google Analytics 4 (tracking)

**Temps : 15 min**

1. Va sur **analytics.google.com** → connecte-toi avec ccdeveloppement@gmail.com
2. Cree un compte : `CC Developpement`
3. Cree une propriete : `Portfolio CC Dev`
4. Plateforme : Web → URL : `https://ccdeveloppement.eu`
5. Copie le **Measurement ID** (format: `G-XXXXXXXXXX`)
6. Ouvre `assets/js/analytics.js` dans VS Code
7. Ligne 13 : remplace `GA_MEASUREMENT_ID` par ton ID

**A faire apres deploiement** : dans GA4 > Admin > Evenements > trouve `form_submit` > marque-le comme conversion.

---

## ETAPE 4 — Microsoft Clarity (heatmaps)

**Temps : 5 min**

1. Va sur **clarity.microsoft.com** → connecte-toi
2. Cree un projet : `CC Developpement Portfolio`
3. URL : `https://ccdeveloppement.eu`
4. Copie le **Project ID**
5. Dans `assets/js/analytics.js`, ligne 14 : remplace `CLARITY_PROJECT_ID` par ton ID

---

## ETAPE 5 — Brevo (email marketing)

**Temps : 30 min**

1. Va sur **brevo.com** → cree un compte avec ccdeveloppement@gmail.com
2. Complete le profil : CC Developpement, 27 Rue Basse, 34300 Agde, SIRET 444 114 011
3. Va dans **Contacts > Listes** → cree une liste "Leads Guide SEO Local" → note l'ID
4. Va dans **Parametres > Cles API** → genere une cle → copie-la
5. Ouvre `guide-seo-local.html` dans VS Code :
   - Remplace `__BREVO_API_KEY__` par ta cle API
   - Remplace `__BREVO_LIST_ID__` par l'ID de ta liste (2 occurrences)
6. Va dans **Automatisation > Creer un workflow** :
   - Declencheur : "Contact ajoute a la liste" → "Leads Guide SEO Local"
   - Email 1 (immediat) : copie le texte de l'email 1 depuis `_audit-reports/lot4-leadmagnet.md`
   - Attente 3 jours
   - Email 2 : copie le texte de l'email 2
   - Attente 4 jours
   - Email 3 : copie le texte de l'email 3
7. Active le workflow
8. Active le **double opt-in** dans Contacts > Parametres

---

## ETAPE 6 — Generer le PDF du lead magnet

**Temps : 10 min**

### Option rapide (VS Code) :
1. Installe l'extension "Markdown PDF" dans VS Code
2. Ouvre `content/lead-magnet-seo-local.md`
3. `Cmd+Shift+P` → "Markdown PDF: Export (pdf)"
4. Deplace le fichier dans `assets/downloads/7-erreurs-seo-local.pdf`

### Option pro (Pandoc) :
```bash
brew install pandoc && brew install --cask basictex
pandoc content/lead-magnet-seo-local.md \
  -o assets/downloads/7-erreurs-seo-local.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=2.5cm -V fontsize=11pt
```

---

## ETAPE 7 — Google Search Console

**Temps : 10 min**

1. Va sur **search.google.com/search-console**
2. Ajoute la propriete `https://ccdeveloppement.eu`
3. Verifie via enregistrement DNS (Cloudflare) ou fichier HTML
4. Soumets le sitemap : `https://ccdeveloppement.eu/sitemap.xml`

---

## ETAPE 8 — Deployer

**Temps : 10 min**

1. Verifie que tous les placeholders sont remplaces :
   ```bash
   grep -r "VOTRE_FORM_ID\|CAL_USERNAME\|GA_MEASUREMENT_ID\|CLARITY_PROJECT_ID\|__BREVO_API_KEY__\|__BREVO_LIST_ID__" --include="*.html" --include="*.js" .
   ```
   → Cette commande ne doit rien renvoyer.
2. Commit et push sur GitHub
3. Deploie sur Cloudflare Pages

---

## ETAPE 9 — Tests finaux

**Temps : 20 min**

- [ ] Formulaire devis : soumets un test → verifier reception email Formspree
- [ ] Page merci.html : s'affiche bien apres soumission
- [ ] Cal.com : reserve un audit test → verifier dans Google Calendar
- [ ] Lead magnet : inscris-toi avec une adresse test → verifier email Brevo + lien PDF
- [ ] GA4 : va dans Temps reel → naviguer sur le site → verifier que les evenements remontent
- [ ] Clarity : attends 5 min → verifier qu'une session apparait
- [ ] Search Console : verifier que le sitemap est soumis et accepte
- [ ] Mobile : tester les 3 pages principales sur telephone (homepage, devis, blog)

---

## C'est fait ?

Bravo. Ton site est maintenant une machine a leads. Prochaines etapes :

1. **Cette semaine** : partage les 3 articles de blog sur LinkedIn
2. **Chaque semaine** : publie 1 nouvel article (plan editorial dans `_audit-reports/lot5-seo-content.md`)
3. **Chaque mois** : consulte le rapport dans RAPPORT-FINAL.md pour suivre tes KPIs

Le rapport complet avec KPIs et plan 30/60/90 jours est dans `_audit-reports/RAPPORT-FINAL.md`.
