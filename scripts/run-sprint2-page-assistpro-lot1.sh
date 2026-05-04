#!/bin/bash
# =============================================================================
# run-sprint2-page-assistpro-lot1.sh — v1
# Sprint 2 — Page produit AssistPro Business (LOT 1/4 : structure HTML)
# =============================================================================
#
# Objectif LOT 1 :
#   - Créer assist-pro-business.html (squelette complet avec placeholders)
#   - Charger la police Inter LOCALEMENT dans fonts/ (cohérent sprint 1B Lenis)
#   - Reprendre le design system d'index.html (--accent #39FF14, --black, etc.)
#   - Préserver les modifs sprint 1A (CSP, cookie consent) et 1B (lenis local, Cal.com)
#
# HORS PÉRIMÈTRE LOT 1 :
#   - Le copywriting fini (sera fait LOT 2 en mode chat conversationnel)
#   - La démo conversationnelle interactive (LOT 2)
#   - Le DPA-type PDF (LOT 4 dédié)
#   - L'intégration finale (LOT 3)
#
# Décisions business validées par Cyril (2026-05-04) :
#   - Engagement : SANS ENGAGEMENT (incitation annuelle = setup offert + 2 mois)
#   - Numéro WA à résiliation : portabilité possible (frais 99€) sinon recyclage 30j
#   - DPA-type : à inclure dans le sprint (LOT 4)
#
# Usage :
#   chmod +x scripts/run-sprint2-page-assistpro-lot1.sh
#   ./scripts/run-sprint2-page-assistpro-lot1.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
REPORTS_DIR="$PROJECT_DIR/_audit-reports"
mkdir -p "$REPORTS_DIR"

cd "$PROJECT_DIR"

echo ""
echo "============================================================"
echo "  SPRINT 2 — PAGE PRODUIT ASSISTPRO BUSINESS"
echo "  LOT 1/4 : structure HTML + design system + Inter locale"
echo "============================================================"
echo ""
echo "Projet : $PROJECT_DIR"
echo ""

# --- Garde-fou Git -----------------------------------------------------------
echo ">>> Vérification de l'état Git du repo"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "KO : ce répertoire n'est pas un repo Git."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "KO : le repo contient déjà des modifications non commitées :"
  git status --short
  echo ""
  echo "Action requise : commit ou stash avant de lancer Sprint 2 LOT 1."
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TARGET_BRANCH="sprint2-page-assistpro"

if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
  echo "Création / bascule sur la branche $TARGET_BRANCH"
  git checkout -b "$TARGET_BRANCH" 2>/dev/null || git checkout "$TARGET_BRANCH"
fi

echo "OK repo propre, branche $(git rev-parse --abbrev-ref HEAD)"
echo ""

# -----------------------------------------------------------------------------
# LOT 1/4 — Structure HTML + design system + police Inter locale
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 1/4 — Création assist-pro-business.html (structure + design + Inter locale)"
echo ""

PROMPT_FILE="$(mktemp -t sprint2-lot1-prompt.XXXXXX)"
trap 'rm -f "$PROMPT_FILE"' EXIT

cat > "$PROMPT_FILE" <<'PROMPT_EOF'
Tu es dans le projet CC Développement, site statique HTML/CSS/JS hébergé sur Cloudflare Pages.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 1/4 — Créer la page produit "AssistPro Business" : structure HTML complète + design system aligné avec le portfolio + police Inter chargée localement.

CONTEXTE PRODUIT :
AssistPro Business = offre B2B SaaS de CC Développement. Assistant WhatsApp IA pour restaurateurs, commerçants, PME locales. 4 plans + sur-mesure (139€/mois Essentiel à 789€/mois Custom). Documenté dans ~/Projets/cc-whatsapp-assistant/docs/pricing.md (consultable en lecture, ne pas le modifier).

URL DE LA PAGE : /assist-pro-business.html (à la racine du repo, comme index.html, tarifs.html, etc.)

DÉCISIONS BUSINESS DÉJÀ TRANCHÉES (à intégrer dans la structure FAQ/sections) :
- ENGAGEMENT : sans engagement, résiliable à tout moment. Incitation = annuel (setup offert + 2 mois offerts).
- NUMÉRO WA À RÉSILIATION : portabilité possible vers infra Meta du client (frais admin 99€). Sinon recyclage 30 jours.
- RGPD : CC Développement agit en sous-traitant. DPA-type à signer avec contrat de service. (Le PDF DPA sera produit LOT 4, ici on prévoit juste le bouton de download désactivé.)

CONTRAINTE NON NÉGOCIABLE 1 — Charte graphique
Reprendre EXACTEMENT les variables CSS d'index.html :
  --accent: #39FF14
  --accent-glow: rgba(57,255,20,0.28)
  --accent-dim: rgba(57,255,20,0.10)
  --black: #09090B
  --dark: #111113
  --dark-2: #18181B
  --dark-3: #27272A
  --gray-light: #B6B6C0
  --gray: #D4D4D8
  --white: #FFFFFF
  --radius: 16px
  --green: #22C55E
  --blue: #3B82F6
  --amber: #F59E0B
  --purple: #A855F7

CONTRAINTE NON NÉGOCIABLE 2 — Police Inter chargée LOCALEMENT
Pourquoi Inter et pas Morena/Brandon : la police Morena ne contient pas les glyphes accentués français (è, é, à, etc.). Cette page produit a un copy commercial RICHE en accents (Réservations, Réponses, fréquentation, événements, etc.). Donc Inter pour CETTE page uniquement. Le reste du site garde Morena/Brandon.

Étapes obligatoires :
1. Télécharger Inter Variable depuis https://rsms.me/inter/font-files/Inter-roman.var.woff2 dans fonts/Inter-roman.var.woff2 (curl ou wget). Source officielle Rasmus Andersson, licence SIL Open Font License (autorisée commercialement, conversion libre, hébergement libre).
2. Vérifier la taille raisonnable (< 350 Ko attendu) et calculer le SHA-256.
3. Déclarer @font-face dans la page :
   @font-face {
     font-family: 'Inter';
     src: url('/fonts/Inter-roman.var.woff2') format('woff2-variations'),
          url('/fonts/Inter-roman.var.woff2') format('woff2');
     font-weight: 100 900;
     font-style: normal;
     font-display: swap;
   }
4. Utiliser Inter sur TOUTE la page (titres + corps), pas Morena/Brandon.
5. Ajouter <link rel="preload" as="font" href="/fonts/Inter-roman.var.woff2" type="font/woff2" crossorigin> dans le <head> pour le perf.

CONTRAINTE NON NÉGOCIABLE 3 — Préserver sprint 1A et 1B
- Reprendre la MÊME CSP que les autres pages HTML (regarder le _headers pour info, mais la CSP est appliquée globalement par Cloudflare via _headers, donc pas besoin de meta CSP locale)
- Charger /assets/js/analytics.js (consent v2 RGPD sprint 1A)
- Charger /assets/js/lenis.min.js (sprint 1B, chemin absolu)
- Charger /assets/js/smooth-scroll.js (cohérent index.html)
- TOUS les CTAs Cal.com doivent avoir : href="https://cal.com/cc-developpement/audit-gratuit" + data-cal-link="cc-developpement/audit-gratuit" + data-cal-config='{"layout":"modal"}' (cohérent sprint 1B)
- Footer doit comporter le lien "Gérer mes préférences cookies" avec data-cookie-preferences (cohérent sprint 1A)
- Aucun href="#" sauf si data-cookie-preferences (preventDefault déjà géré dans analytics.js)

STRUCTURE HTML COMPLÈTE (avec placeholders [À RÉDIGER LOT 2] pour le copywriting fini) :

<head> :
- <meta charset="UTF-8">, viewport
- <title>Assistant WhatsApp IA pour restaurants & PME — AssistPro Business | CC Développement</title>
- <meta name="description" content="Assistant WhatsApp IA 24/7 pour restaurants, commerces, PME. Numéro WhatsApp Business dédié inclus, 4 plans dès 139€/mois HT, setup 7 jours, sans engagement. Audit gratuit 30 min.">
- <link rel="canonical" href="https://ccdeveloppement.eu/assist-pro-business">
- Open Graph : og:type=product, og:title, og:description, og:url, og:image (réutiliser une image existante du repo Images/, ex: AssistPro-1200.webp si elle existe)
- Twitter Card summary_large_image
- Favicon (cohérent avec les autres pages)
- Preload Inter
- Inline <style> ou <link> vers /assets/css/assist-pro-business.css (au choix selon le volume)
- JSON-LD : schema.org/Service avec provider, areaServed, hasOfferCatalog (4 plans), aggregateRating si dispo (sinon omettre, ne pas inventer)

<body> :

1. HEADER (cohérent index.html) :
   - Logo CC Développement (cliquable href="/")
   - Menu nav (mêmes liens que index.html, ajouter "AssistPro Business" dans les items si la nav est éditée — sinon laisser tel quel et juste s'aligner sur le pattern)
   - CTA principal "Réserver un audit" en haut à droite (data-cal-link)

2. SECTION HERO (#hero) :
   <section class="hero-assist">
     <div class="section-tag">Nouveau</div>
     <h1>Votre assistant <span class="muted">WhatsApp IA,</span><br>prêt en 7 jours.</h1>
     <p class="hero-baseline">[À RÉDIGER LOT 2 — baseline 2 lignes : promesse + bénéfice principal, ton commercial mais authentique]</p>
     <div class="hero-ctas">
       <a href="https://cal.com/cc-developpement/audit-gratuit" data-cal-link="cc-developpement/audit-gratuit" data-cal-config='{"layout":"modal"}' class="btn-primary">Audit gratuit 30 min</a>
       <a href="#tarifs" class="btn-secondary">Voir les tarifs</a>
     </div>
     <div class="hero-visual">[À INTÉGRER LOT 2 — capture mockup WhatsApp Business ou démo conversation]</div>
   </section>

3. SECTION PROBLÈME (#probleme) : 3 cards "pain points" en grid (responsive 3 col desktop / 1 col mobile). Chaque card :
   - Icône SVG ou emoji
   - Titre placeholder ("Pain point #N")
   - Paragraphe placeholder [À RÉDIGER LOT 2]
   Suggestions de pain points pour LOT 2 :
   - "Vos clients vous appellent pendant le coup de feu"
   - "Les avis Google restent sans réponse"
   - "Le community management vous prend 5h/semaine"

4. SECTION PROMESSE (#promesse) : 3 piliers en grid horizontal 3 col :
   - "Numéro WhatsApp Business dédié" (Twilio BSP, votre logo, votre nom d'affichage, votre site web)
   - "50 fonctions IA prêtes à l'emploi" (réservations, posts, avis, support, briefing matinal...)
   - "Setup en 7 jours" (vous fournissez vos infos, on s'occupe du reste)
   Chaque pilier : titre + 1 phrase placeholder + icône.

5. SECTION FEATURES (#features) : grid 6 cards (3 col x 2 lignes desktop, 2x3 tablet, 1x6 mobile). Pour chaque card :
   - Émoji
   - Titre (sans accents si tu veux matcher index.html, OU avec accents puisqu'on est en Inter — préférer AVEC accents puisque c'est Inter)
   - Paragraphe court placeholder
   - (optionnel) liste de 3 micro-bénéfices [À RÉDIGER LOT 2]
   Les 6 features (ordre + émojis) :
   📅 Réservations automatiques
   📱 Posts réseaux sociaux IA
   ⭐ Gestion avis Google
   ☀️ Briefing matinal personnalisé
   💬 Réponses clients 24/7
   📊 Tableau de bord analytics

6. SECTION DÉMO (#demo) :
   <section id="demo" class="demo-assist">
     <h2>Voyez l'assistant en action</h2>
     <div class="demo-placeholder" aria-label="Démo conversationnelle WhatsApp">
       <p>[À INTÉGRER LOT 2 — démo conversationnelle WhatsApp simulée (HTML+CSS) ou vidéo capture en MP4/WebM]</p>
     </div>
   </section>

7. SECTION TARIFS (#tarifs) :
   - Bandeau au-dessus : "Sans engagement, résiliable à tout moment. Setup offert + 2 mois offerts si annuel."
   - 4 cards plans en grid responsive (4 col desktop, 2 col tablet, 1 col mobile). Plan Pro (le 2e) avec class="plan-featured" et badge "Recommandé" en accent vert.
   - Pour chaque card :
     <div class="plan-card">
       <h3>Nom du plan</h3>
       <div class="plan-price">
         <span class="amount">139€</span>
         <span class="period">/mois HT</span>
       </div>
       <div class="plan-setup">+ 249€ setup HT (offert si annuel)</div>
       <ul class="plan-features">
         <li>Numéro WhatsApp Business dédié</li>
         <li>~20 fonctions IA</li>
         <li>12 posts IA / mois (Instagram)</li>
         <li>Support email</li>
         <li>etc.</li>
       </ul>
       <a href="https://cal.com/cc-developpement/audit-gratuit" data-cal-link="..." class="btn-plan">Commencer</a>
     </div>
   - 4 plans avec leurs prix et features (depuis pricing.md) :
     ESSENTIEL : 139€/mois HT, setup 249€, ~20 fonctions, 12 posts/mois Instagram, support email
     PRO (FEATURED) : 239€/mois HT, setup 399€, ~35 fonctions, 20 posts/mois Insta+FB, réservation WhatsApp, support email + WhatsApp
     PREMIUM : 389€/mois HT, setup 499€, 50 fonctions, 30 posts/mois Insta+FB+GBP, avis Google auto, support prioritaire + appel mensuel
     CUSTOM : 789€/mois HT, setup 999€, 50+ fonctions, multi-canal, dédié
   - Sous les 4 cards, mention "Plan sur-mesure (dev spécifique) → sur devis" + CTA "Demander un devis personnalisé"

8. SECTION OPTIONS À LA CARTE (#options) : tableau 5 lignes, 2 colonnes (option / prix) :
   - Post supplémentaire | 5€/post
   - Langue additionnelle | +49€/mois
   - Image IA (DALL-E) | +79€/mois
   - Dashboard analytics | +29€/mois
   - Canal supplémentaire (Telegram, Instagram DM, Messenger) | +29€/mois/canal

9. SECTION COMPARAISON CONCURRENCE (#concurrence) :
   - Intro 1 phrase : "Comparé à un standard téléphonique externalisé qui coûte 800-1500€/mois pour quelques heures de prise d'appels, AssistPro Business répond 24/7 sur le canal préféré de vos clients (WhatsApp = 1er canal de messagerie en France) dès 139€/mois."
   - Tableau 4 lignes, 3 colonnes (Alternative / Coût mensuel / AssistPro Business) :
     Standard téléphonique externalisé | 800-1 500€/mois (quelques heures) | dès 139€/mois (24/7)
     Assistant + Community Manager salariés | 2 800-4 300€/mois | dès 389€/mois
     SMS marketing classique (Brevo) | 50-200€/mois | conversationnel bidirectionnel inclus
     Chatbot web (Tidio, Intercom) | 50-300€/mois | sur WhatsApp (canal n°1 en France)

10. SECTION FAQ (#faq) : 8 questions / réponses. Inclure OBLIGATOIREMENT les 3 questions critiques (réponses RÉELLES, pas placeholders) :

    Q1 : "Y a-t-il un engagement ?"
    R : "Non. Tous nos plans sont sans engagement, résiliables à tout moment. Si vous choisissez le paiement annuel, vous bénéficiez du setup offert + 2 mois offerts (équivalent à 10 mois payés sur 12)."

    Q2 : "Que devient mon numéro WhatsApp si je résilie ?"
    R : "Vous pouvez demander la portabilité de votre numéro WhatsApp Business vers votre propre infrastructure Meta (frais administratifs 99€). Si aucune portabilité n'est demandée dans les 30 jours suivant la résiliation, le numéro est recyclé."

    Q3 : "Comment se passe le RGPD avec mes clients ?"
    R : "CC Développement agit en sous-traitant RGPD vis-à-vis de vos clients. Nous fournissons un Data Processing Agreement (DPA) à signer avec votre contrat de service, conforme au modèle CNIL. Vous restez responsable de traitement, nous garantissons la sécurité technique et la conformité."
    Lien : "Télécharger notre DPA-type (PDF)" → href="#" data-dpa-disabled (sera activé LOT 4)

    + 5 autres questions placeholders [À RÉDIGER LOT 2 — questions/réponses sur les sujets : "Combien ça coûte vraiment tout compris ?", "Est-ce que ça remplace mon staff ?", "Quelle assistance fournie ?", "Mes données sont-elles sécurisées ?", "Puis-je essayer avant de payer ?"]

11. SECTION DPA DOWNLOAD (#dpa) :
    <section id="dpa" class="dpa-section">
      <h2>RGPD : transparence totale</h2>
      <p>Téléchargez notre Data Processing Agreement type, conforme CNIL, à intégrer à votre contrat de service.</p>
      <a href="#" class="btn-secondary disabled" aria-disabled="true" title="Disponible après LOT 4">📄 Télécharger notre DPA-type (PDF) — bientôt disponible</a>
    </section>

12. SECTION CTA FINAL (#cta-final) :
    <section class="cta-final">
      <h2>Prêt à automatiser votre WhatsApp ?</h2>
      <p>Audit gratuit 30 min, sans engagement. On regarde ensemble si AssistPro Business correspond à votre activité.</p>
      <a href="https://cal.com/cc-developpement/audit-gratuit" data-cal-link="cc-developpement/audit-gratuit" data-cal-config='{"layout":"modal"}' class="btn-primary btn-large">Réserve ton audit gratuit</a>
    </section>

13. FOOTER : reprendre EXACTEMENT le footer d'index.html (cohérence visuelle et fonctionnelle), y compris le lien "Gérer mes préférences cookies" avec data-cookie-preferences.

14. SCRIPTS en fin de body :
    - <script src="/assets/js/lenis.min.js"></script>
    - <script src="/assets/js/smooth-scroll.js"></script>
    - <script src="/assets/js/analytics.js"></script>
    - Init Cal.com (snippet identique à index.html, regarder pour copier)

CSS — où mettre :
- Variables CSS et reset : reprendre celles d'index.html (peut-être en lien CSS commun /assets/css/base.css si tu en crées un, sinon inline)
- CSS spécifique à cette page : créer assets/css/assist-pro-business.css OU inline en <style> dans le <head>. Choisis selon le volume — si > 200 lignes CSS spécifiques, externe. Sinon inline.

CONTRAINTES TECHNIQUES :
- HTML5 valide (vérifier avec un grep ou inspection mentale, pas de tags non fermés)
- Mobile-first : breakpoints 640px / 768px / 1024px alignés sur le reste du site
- Accessibilité WCAG AA : alt sur toutes les images, aria-label sur boutons icônes, contrastes vérifiés (text/bg = ratio 4.5:1 min)
- Pas de href="#" sauf pour le DPA placeholder (avec aria-disabled)
- Tous les liens externes : rel="noopener noreferrer" target="_blank"

LIVRABLES EXIGÉS :
1. assist-pro-business.html (page complète, structure prête, placeholders explicites)
2. fonts/Inter-roman.var.woff2 (police téléchargée localement)
3. (optionnel) assets/css/assist-pro-business.css si tu choisis CSS externe
4. _audit-reports/sprint2-lot1-structure.md décrivant :
   - Structure créée (sections + ID + classes principales) avec un mini-arbre
   - Variables CSS reprises d'index.html (lister celles utilisées)
   - Police Inter : URL source utilisée, taille (Ko), checksum SHA-256, déclaration @font-face
   - Tableau exhaustif des PLACEHOLDERS À REMPLIR LOT 2 : (id/classe | type | suggestion)
   - Vérifs auto effectuées (HTML5 valide, footer cookie-prefs OK, lenis local OK, Cal.com handle OK)
   - Limites connues / décisions prises pendant le LOT

NE TOUCHE PAS :
- Aux autres fichiers HTML existants
- À analytics.js, _headers (sprints 1A/1B intacts)
- Aux fichiers .otf existants
- Aux pricings concurrence (utilise ceux fournis ci-dessus, ne pas inventer)
- À pricing.md (lecture seule pour info, ne pas modifier)

Si tu hésites sur un détail copywriting ou design, mets `[À RÉDIGER LOT 2]` ou documente l'ambiguïté dans le rapport plutôt que d'écrire à l'aveugle. L'objectif du LOT 1 = squelette + design system + structure + placeholders, PAS le copywriting fini.
PROMPT_EOF

claude -p "$(< "$PROMPT_FILE")" --dangerously-skip-permissions

echo ""
echo "============================================================"
echo "  SPRINT 2 LOT 1/4 TERMINÉ"
echo "============================================================"
echo ""
echo "Branche Git : $(git rev-parse --abbrev-ref HEAD)"
echo ""
echo "Livrables attendus :"
echo "  - assist-pro-business.html (squelette complet avec placeholders)"
echo "  - fonts/Inter-roman.var.woff2 (police téléchargée)"
echo "  - (optionnel) assets/css/assist-pro-business.css"
echo "  - _audit-reports/sprint2-lot1-structure.md (rapport)"
echo ""
echo "ÉTAPES MANUELLES :"
echo "  1. Lire _audit-reports/sprint2-lot1-structure.md"
echo "  2. git diff pour relecture complète"
echo "  3. Tester en local : python3 -m http.server 8080 → http://localhost:8080/assist-pro-business.html"
echo "  4. Vérifier visuellement que le squelette tient debout (sections bien posées, design cohérent CC)"
echo "  5. Vérifier que les accents s'affichent correctement (Inter chargée)"
echo ""
echo "Si OK : on enchaîne LOT 2 (copywriting) en mode chat conversationnel — pas de claude -p autonome."
echo "Si KO : retour de feedback à Claude Code dans le chat, ajustements ciblés."
