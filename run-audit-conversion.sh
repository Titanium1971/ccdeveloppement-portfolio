#!/bin/bash
# =============================================================================
# run-audit-conversion.sh
# Audit complet + optimisation conversion du site CC Développement
# Objectif : transformer la vitrine en machine à leads
# =============================================================================

set -e

PROJECT_DIR="/Users/cyril/Projets/cc-developpement/portfolio"
REPORTS_DIR="$PROJECT_DIR/_audit-reports"
mkdir -p "$REPORTS_DIR"

cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  CC DEV - AUDIT & OPTIMISATION CONVERSION"
echo "=========================================="
echo ""

# -----------------------------------------------------------------------------
# LOT 1/6 — Audit + fix du formulaire de devis
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 1/6 — Audit & fix du formulaire devis"
echo ""

claude -p "Tu es dans le projet CC Développement (site vitrine Next.js/HTML statique Cloudflare Pages).

MISSION LOT 1/6 — Audit et réparation du formulaire de devis.

1. Ouvre devis.html (et tout autre fichier contenant un formulaire : contact, index).
2. Vérifie :
   - Existe-t-il un endpoint backend (API route, Formspree, Netlify Forms, Cloudflare Worker) ?
   - Que se passe-t-il au submit ? Le JS envoie-t-il réellement les données ?
   - Y a-t-il un message de confirmation explicite après soumission ?
   - Y a-t-il un email automatique envoyé au prospect ET à Cyril ?
3. Si le formulaire est CASSÉ ou non connecté :
   - Implémente une solution avec Formspree (https://formspree.io) OU un Cloudflare Worker qui envoie un email via Resend/SendGrid vers canon@ccdeveloppement.eu
   - Ajoute un écran de confirmation visible après submit (message + redirection vers /merci.html)
   - Crée la page /merci.html avec un design cohérent + 2 CTA (lire cas client, réserver audit)
4. Améliore les champs : ajoute 'budget estimé' (select : <1500€ / 1500-3000€ / 3000-6000€ / >6000€), 'deadline' (select : ASAP / 1 mois / 3 mois / flexible), 'volume de pages' (number).
5. Ajoute une validation côté serveur (anti-spam : honeypot + rate limit simple).

Écris un rapport détaillé dans _audit-reports/lot1-formulaire.md :
- État avant
- Modifications apportées
- Comment tester
- Ce qui reste à faire manuellement par Cyril (créer compte Formspree, configurer clés API, etc.)

Ne casse rien. Si tu hésites, documente dans le rapport plutôt que de modifier à l'aveugle." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 2/6 — Installation du tracking (GA4 + événements conversion)
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 2/6 — Installation tracking GA4 + événements"
echo ""

claude -p "Tu es dans le projet CC Développement.

MISSION LOT 2/6 — Mettre en place le tracking d'acquisition et de conversion.

1. Intègre Google Analytics 4 via gtag.js dans toutes les pages HTML du site.
   - Crée un fichier assets/js/analytics.js réutilisable
   - Utilise le placeholder GA_MEASUREMENT_ID (Cyril remplacera par son vrai ID)
   - Inclus-le dans toutes les pages via <script> en fin de <head>
2. Ajoute le respect du consentement cookies (Consent Mode v2) : analytics_storage='denied' par défaut, activé après acceptation du bandeau cookies existant.
3. Configure les événements de conversion :
   - form_start (focus premier champ formulaire devis)
   - form_submit (soumission réussie)
   - cta_click (clic WhatsApp, téléphone, email, Cal.com)
   - scroll_depth (25%, 50%, 75%, 100%)
   - outbound_click (clic vers LinkedIn, portfolio externe)
4. Ajoute Microsoft Clarity (gratuit, heatmaps + session replay) — placeholder CLARITY_PROJECT_ID.
5. Crée un fichier _audit-reports/lot2-tracking-setup.md expliquant à Cyril :
   - Comment créer son compte GA4 + récupérer le Measurement ID
   - Comment créer son compte Clarity
   - Où remplacer les placeholders
   - Les événements qu'il pourra tracker dans l'onglet 'Événements' de GA4
   - Comment configurer les conversions dans GA4 (form_submit = conversion principale)
   - Lien vers la doc officielle

Ne modifie pas les autres aspects du site." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 3/6 — Intégration Cal.com + CTA audit gratuit
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 3/6 — Intégration Cal.com + CTA audit gratuit"
echo ""

claude -p "Tu es dans le projet CC Développement.

MISSION LOT 3/6 — Ajouter la prise de RDV en un clic.

1. Intègre le widget Cal.com (embed inline ou popup) sur :
   - La homepage (CTA principal ou secondaire bien visible)
   - La page devis (alternative au formulaire : 'Préfères-tu en parler ? Réserve 30 min')
   - Le footer de toutes les pages
2. Utilise le placeholder CAL_USERNAME (ex: cyril-canon) que Cyril configurera.
3. Code recommandé : popup script officiel Cal.com (https://cal.com/docs/embed/embed-core).
4. Crée un bouton réutilisable avec classe .btn-cal, style cohérent avec la charte (utilise les couleurs/fonts existantes du site).
5. Texte du CTA : 'Réserve ton audit gratuit — 30 min' (pas 'prendre RDV' qui sonne trop commercial).
6. Après soumission du formulaire devis (page /merci.html créée en lot 1), ajoute aussi un CTA Cal.com : 'Tu veux accélérer ? Bloque 30 min maintenant.'
7. Sur mobile, le CTA Cal.com doit être sticky en bas d'écran (comme WhatsApp) — ajoute une barre flottante ou bouton rond.

Écris _audit-reports/lot3-calcom.md :
- Comment Cyril crée son compte Cal.com + configure son event type 'Audit 30 min'
- Où remplacer CAL_USERNAME
- Conseils sur les questions à poser dans le formulaire de pré-qualification Cal.com (secteur, budget, objectif)
- Template d'email de confirmation Cal.com à configurer

Ne casse pas le design existant, reste cohérent avec la charte." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 4/6 — Lead magnet + landing page nurture
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 4/6 — Lead magnet + tunnel nurture"
echo ""

claude -p "Tu es dans le projet CC Développement.

MISSION LOT 4/6 — Créer un lead magnet et un tunnel de nurture email.

1. Rédige un lead magnet PDF : 'Les 7 erreurs SEO local qui coulent les TPE en 2026'
   - 10-15 pages, style pro (fond blanc, structure claire)
   - Contenu concret : chaque erreur + exemple local Agde/Hérault + solution actionnable
   - Crée le fichier source en Markdown dans content/lead-magnet-seo-local.md
   - Génère un PDF propre dans assets/downloads/7-erreurs-seo-local.pdf (utilise pandoc ou une solution équivalente ; si tu ne peux pas générer le PDF, laisse le .md et indique-le dans le rapport)
2. Crée une landing page dédiée : /guide-seo-local.html
   - Hero avec promesse claire + mockup du PDF
   - Formulaire email unique (nom + email)
   - Double opt-in recommandé
   - Connecté à Brevo (ex-Sendinblue, gratuit jusqu'à 300 emails/jour) OU MailerLite — placeholder API key
3. Configure une séquence email automatique (3 emails) :
   - J+0 : 'Voici ton guide' + lien PDF + présentation rapide de Cyril
   - J+3 : 'Le piège SEO #1 que font 80% des restaurants d'Agde' (mini cas client)
   - J+7 : 'Tu veux qu'on regarde ton site ensemble ?' + lien Cal.com
4. Crée des pop-ups d'exit-intent sur les pages clés (homepage, pricing) proposant le lead magnet.

Écris _audit-reports/lot4-leadmagnet.md :
- Comment Cyril crée son compte Brevo/MailerLite
- Comment importer la séquence email
- Les 3 textes d'email prêts à copier-coller
- Comment mesurer le taux d'ouverture et de conversion

Si le PDF ne peut pas être généré automatiquement, donne à Cyril les instructions exactes pour le faire (commande pandoc ou service en ligne)." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 5/6 — SEO content : articles long-form + maillage
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 5/6 — SEO content + maillage interne"
echo ""

claude -p "Tu es dans le projet CC Développement.

MISSION LOT 5/6 — Créer la fondation SEO de contenu.

1. Crée un dossier /blog/ avec une structure propre (index.html + articles).
2. Rédige 3 articles long-form (1500-2500 mots chacun) ciblés SEO local :
   - blog/creation-site-internet-agde-guide-complet-2026.html
     → cible : 'création site internet Agde', 'développeur web Agde'
   - blog/seo-local-herault-restaurants-artisans.html
     → cible : 'SEO local Hérault', 'référencement restaurant Agde'
   - blog/combien-coute-site-vitrine-tpe-2026.html
     → cible : 'prix site vitrine', 'tarif création site TPE'
3. Chaque article doit :
   - Avoir un H1 unique, H2/H3 structurés, metadata complète (title < 60 car, description < 160 car)
   - Inclure au moins 2 liens internes vers les pages services + 1 vers le lead magnet + 1 CTA Cal.com
   - Intégrer un JSON-LD Article + BreadcrumbList
   - Mentionner Agde, Béziers, Sète, Montpellier (SEO local)
   - Se terminer par une FAQ (4-5 questions) avec JSON-LD FAQPage
4. Crée la page /blog/index.html listant les 3 articles (thumbnails, extraits).
5. Ajoute un lien 'Blog' dans la navigation principale de toutes les pages.
6. Met à jour le sitemap.xml pour inclure les nouvelles URLs.
7. Renforce le maillage interne : depuis la homepage, la page devis, et les pages services, ajoute 1-2 liens vers les articles pertinents.

Écris _audit-reports/lot5-seo-content.md :
- Liste des mots-clés ciblés + volume de recherche estimé
- Plan éditorial pour les 6 prochains mois (12 sujets proposés)
- Comment vérifier le ranking avec Google Search Console
- Recommandation : publier 1 article/semaine minimum pendant 3 mois pour voir des résultats

Reste fidèle à la charte graphique existante." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 6/6 — Consolidation + rapport final + plan d'action
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 6/6 — Consolidation + plan d'action 30 jours"
echo ""

claude -p "Tu es dans le projet CC Développement.

MISSION LOT 6/6 — Consolider tous les rapports et livrer un plan d'action.

1. Lis tous les fichiers dans _audit-reports/ (lot1 à lot5).
2. Crée un rapport consolidé : _audit-reports/RAPPORT-FINAL.md avec :
   - Résumé exécutif (10 lignes max)
   - État avant / après chaque lot
   - Check-list complète des actions manuelles à faire par Cyril (créer comptes, récupérer clés API, remplacer placeholders) — un tableau clair avec colonnes : Action / Service / Temps estimé / Priorité / Lien
   - Plan d'action chronologique sur 30 jours (semaine par semaine)
   - KPIs à mesurer après 30 / 60 / 90 jours (traffic, leads, taux de conversion, positionnement SEO)
3. Crée un fichier DEMARRAGE.md à la racine du projet : le guide step-by-step que Cyril suit pour tout activer (dans l'ordre, sans réfléchir).
4. Fais un audit final rapide :
   - Le site se build-il toujours correctement ?
   - Pas de lien cassé ?
   - Pas de placeholder oublié qui casserait le rendu ?
5. Liste dans RAPPORT-FINAL.md les 3 prochaines choses à faire APRÈS ces 30 jours (ex : vidéos cas clients, refonte portfolio, campagne Google Ads local).
6. Rappelle à Cyril que sans formation en vente/closing, même les meilleurs leads ne convertiront pas — recommande 2-3 ressources francophones sérieuses (livre, formation, chaîne YouTube) pour se former au closing B2B freelance.

Ton rapport final doit être honnête, chiffré, actionnable. Pas de langue de bois." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# FIN
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  AUDIT TERMINÉ"
echo "=========================================="
echo ""
echo "Rapports disponibles dans : $REPORTS_DIR"
echo "Guide de démarrage : $PROJECT_DIR/DEMARRAGE.md"
echo ""
echo "Prochaine étape : ouvre DEMARRAGE.md et suis les instructions dans l'ordre."
echo ""
