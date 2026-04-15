# LOT 5 — Fondation SEO de contenu

**Date** : 15 avril 2026
**Statut** : Terminé

---

## Résumé des actions

### Fichiers créés
- `blog/index.html` — page listing des articles
- `blog/creation-site-internet-agde-guide-complet-2026.html` — article 1 (~2 200 mots)
- `blog/seo-local-herault-restaurants-artisans.html` — article 2 (~2 400 mots)
- `blog/combien-coute-site-vitrine-tpe-2026.html` — article 3 (~2 300 mots)

### Modifications
- **Navigation** : lien "Blog" ajouté sur toutes les pages (index, tarifs, devis, estimateur, guide-tarifs, guide-seo-local, creation-site-web-agde, seo-local-herault, merci)
- **sitemap.xml** : 4 nouvelles URLs ajoutées (blog index + 3 articles)
- **Maillage interne renforcé** :
  - Homepage : nouvelle section "Derniers articles du blog" entre Services et Stack
  - Devis : carte "Guides utiles" dans la sidebar avec liens vers 2 articles
  - creation-site-web-agde.html : section "Pour aller plus loin" avec 2 liens articles
  - seo-local-herault.html : section "Pour aller plus loin" avec 2 liens articles
  - Les articles se lient entre eux et vers les pages services, tarifs, estimateur et lead magnet

### Structure technique de chaque article
- H1 unique, H2/H3 hiérarchisés
- Title < 60 caractères, meta description < 160 caractères
- JSON-LD : Article + BreadcrumbList + FAQPage (4-5 questions)
- Open Graph + Twitter Cards
- Geo meta tags (FR-34, Agde, 43.3107;3.4731)
- Mentions d'Agde, Béziers, Sète, Montpellier dans le contenu
- CTA Cal.com intégré
- Liens internes : ≥ 2 vers pages services + 1 vers lead magnet
- Design conforme à la charte graphique (couleurs, polices Morena, composants)

---

## Mots-clés ciblés et volumes estimés

| Mot-clé principal | Volume estimé (mensuel FR) | Article ciblé | Difficulté |
|---|---|---|---|
| création site internet agde | 50-100 | Article 1 | Faible |
| développeur web agde | 30-70 | Article 1 | Faible |
| créer site web hérault | 20-50 | Article 1 | Faible |
| seo local hérault | 30-70 | Article 2 | Moyenne |
| référencement restaurant agde | 20-40 | Article 2 | Faible |
| référencement local béziers | 20-50 | Article 2 | Faible |
| seo local restaurant | 100-200 | Article 2 | Moyenne |
| prix site vitrine | 500-1 000 | Article 3 | Élevée |
| tarif création site tpe | 200-400 | Article 3 | Moyenne |
| combien coûte un site vitrine | 300-600 | Article 3 | Moyenne |
| coût site internet professionnel | 200-500 | Article 3 | Élevée |
| site web pas cher tpe | 100-300 | Article 3 | Moyenne |

**Stratégie** : les articles 1 et 2 ciblent des mots-clés locaux à faible concurrence (quick wins). L'article 3 cible des mots-clés nationaux à fort volume pour capter du trafic plus large et positionner CC Développement en autorité.

---

## Plan éditorial — 6 prochains mois (12 sujets proposés)

### Mai 2026
1. **"Google Business Profile : le guide complet pour les commerçants de l'Hérault"**
   - Cibles : google business profile hérault, fiche google restaurant agde
   - Format : guide pratique pas-à-pas avec captures d'écran

2. **"5 exemples de sites vitrines qui convertissent (et pourquoi ils marchent)"**
   - Cibles : exemple site vitrine, bon site vitrine tpe
   - Format : étude de cas avec analyse de design et conversion

3. **"WordPress vs site codé sur-mesure : que choisir pour votre TPE ?"**
   - Cibles : wordpress vs code, meilleure solution site tpe
   - Format : comparatif avec tableau décisionnel

### Juin 2026
4. **"Comment choisir un développeur web : 8 questions à poser avant de signer"**
   - Cibles : choisir développeur web, questions freelance web
   - Format : checklist actionnable

5. **"Les 10 erreurs de sites web qui font fuir les clients de restaurants"**
   - Cibles : erreurs site restaurant, site restaurant optimisé
   - Format : liste avec exemples visuels

6. **"Automatiser son business local : 5 workflows Make.com pour gagner 10h/semaine"**
   - Cibles : automatisation tpe, make.com business local
   - Format : tutoriel avec captures

### Juillet 2026
7. **"Préparer la saison estivale au Cap d'Agde : checklist digitale pour restaurants"**
   - Cibles : restaurant cap d'agde, saison estivale restauration
   - Format : checklist saisonnière (SEO + timing)

8. **"Responsive design : pourquoi 65 % de vos clients vous voient sur mobile"**
   - Cibles : site mobile responsive, optimisation mobile tpe
   - Format : données + guide technique simplifié

### Août 2026
9. **"Les meilleurs outils gratuits pour gérer la e-réputation de votre restaurant"**
   - Cibles : e-réputation restaurant, gérer avis google
   - Format : revue d'outils avec notation

10. **"Faut-il un blog pour un site de TPE ? (Réponse : oui, voici pourquoi)"**
    - Cibles : blog tpe, contenu site entreprise
    - Format : argumentaire avec ROI chiffré

### Septembre 2026
11. **"Comment apparaître en position zéro sur Google avec les FAQ structurées"**
    - Cibles : position zéro google, faq structurée schema
    - Format : tutoriel technique accessible

### Octobre 2026
12. **"Bilan de saison : comment analyser les performances de votre site après l'été"**
    - Cibles : analyse site web, google analytics tpe
    - Format : guide de lecture des KPIs avec Search Console

---

## Comment vérifier le ranking avec Google Search Console

### Configuration initiale
1. Aller sur [search.google.com/search-console](https://search.google.com/search-console)
2. Ajouter la propriété `https://ccdeveloppement.eu`
3. Vérifier via le fichier HTML ou l'enregistrement DNS (Cloudflare)
4. Soumettre le sitemap : `https://ccdeveloppement.eu/sitemap.xml`

### Suivi des articles de blog
1. **Performance > Requêtes** : voir sur quels mots-clés les articles remontent
2. **Performance > Pages** : filtrer par URL d'article pour voir ses impressions et clics
3. **Position moyenne** : suivre l'évolution hebdomadaire des positions sur les mots-clés ciblés
4. **CTR (taux de clic)** : si les impressions sont hautes mais le CTR bas, optimiser le title et la meta description

### KPIs à surveiller
| KPI | Objectif à 3 mois | Objectif à 6 mois |
|---|---|---|
| Impressions totales blog | 500/mois | 2 000/mois |
| Clics organiques blog | 30/mois | 150/mois |
| Position moyenne mots-clés locaux | Top 20 | Top 10 |
| Position moyenne mots-clés nationaux | Top 50 | Top 20 |
| Pages indexées | 100 % (4/4) | 100 % (8+) |

### Fréquence de vérification
- **Hebdomadaire** : positions sur les 5 mots-clés principaux
- **Mensuelle** : rapport complet (impressions, clics, CTR, pages indexées)
- **Trimestrielle** : ajustement de la stratégie de contenu en fonction des résultats

---

## Recommandation : rythme de publication

**Objectif minimum : 1 article/semaine pendant 3 mois** (12 articles au total)

### Pourquoi 3 mois minimum ?
- Google a besoin de temps pour crawler, indexer et évaluer le contenu
- La régularité de publication est un signal de fraîcheur pour l'algorithme
- 12 articles créent une masse critique de pages indexées qui renforcent mutuellement le maillage interne
- Les résultats SEO sont exponentiels : les 3 premiers mois sont un investissement, les bénéfices arrivent à partir du mois 4-6

### Format recommandé
- **Longueur** : 1 200-2 500 mots par article
- **Structure** : H1 + 4-6 H2 + FAQ en fin d'article
- **Données structurées** : Article + BreadcrumbList + FAQPage sur chaque article
- **Maillage** : chaque article lie vers au moins 2 pages du site + 1-2 autres articles
- **CTA** : au moins 1 CTA Cal.com par article + 1 lien vers le lead magnet

### Estimation du ROI
- Coût : ~2h par article (rédaction + mise en page + SEO)
- Bénéfice attendu à 6 mois : +150-300 visites organiques/mois
- Si 2 % de conversion en demande de devis = 3-6 leads supplémentaires/mois
- Valeur estimée : 1 500-6 000 €/mois de CA potentiel additionnel

---

## Checklist de validation

- [x] 3 articles long-form publiés (1 500-2 500 mots)
- [x] H1 unique par page, H2/H3 structurés
- [x] Title < 60 caractères, description < 160 caractères
- [x] JSON-LD Article + BreadcrumbList + FAQPage
- [x] ≥ 2 liens internes vers pages services par article
- [x] 1 lien vers lead magnet par article
- [x] 1 CTA Cal.com par article
- [x] Agde, Béziers, Sète, Montpellier mentionnés
- [x] FAQ 4-5 questions par article
- [x] Blog index avec cards, extraits, dates
- [x] Lien Blog dans la navigation de toutes les pages
- [x] sitemap.xml mis à jour (4 nouvelles URLs)
- [x] Maillage interne renforcé (homepage, devis, pages services)
- [x] Charte graphique respectée (couleurs, Morena, composants)
