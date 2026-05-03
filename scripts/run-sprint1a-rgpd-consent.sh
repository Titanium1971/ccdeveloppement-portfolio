#!/bin/bash
# =============================================================================
# run-sprint1a-rgpd-consent.sh — v2
# Sprint 1A — RGPD Option B : conserver GA4 + Microsoft Clarity avec consentement
# =============================================================================
#
# v2 — corrections appliquées suite à la revue ChatGPT du 3 mai 2026 :
#   1. Lot 2 traite aussi _headers (Link preconnect GA4/Clarity).
#   2. Lot 4 ne vérifie plus que _headers est intact, mais que seules les
#      preconnects GA4/Clarity ont été retirées et que la CSP est conservée.
#   3. Clarity API consentv2 (ad_Storage / analytics_Storage).
#   4. Révocation GA4 : gtag consent update denied AVANT deleteAnalyticsCookies.
#   5. Modale Personnaliser : cases décochées par défaut si aucun consentement.
#   6. Bandeau : ordre [Tout refuser] [Personnaliser] [Tout accepter] même niveau.
#   7. Idempotence du lien footer (ne pas ajouter de doublon).
#   8. Garde-fou Git : refus si repo sale + branche dédiée sprint1a-rgpd-consentement.
#   9. PROJECT_DIR robuste via BASH_SOURCE.
#  10. Test post-déploiement : curl -sSI ... | grep '^link:'
#
# Objectif :
#   - Garder GA4 et Clarity actifs APRÈS acceptation utilisateur.
#   - Aucun appel réseau vers Google ou Clarity AVANT consentement / APRÈS refus.
#   - Bandeau "Tout refuser / Personnaliser / Tout accepter".
#   - Lien permanent "Gérer mes préférences cookies" en footer.
#   - Page /rgpd-confidentialite cohérente avec la réalité technique.
#
# Périmètre : analytics.js, preconnects GA4/Clarity dans HTML et _headers,
# rgpd-confidentialite.html, lien footer.
#
# HORS périmètre (Sprint 1B) : CTAs href="#", polices, Lenis, OG, Schema, devis.
#
# Usage :
#   chmod +x scripts/run-sprint1a-rgpd-consent.sh
#   ./scripts/run-sprint1a-rgpd-consent.sh
# =============================================================================

set -e

# --- Résolution du chemin projet (correction #9) -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
REPORTS_DIR="$PROJECT_DIR/_audit-reports"
mkdir -p "$REPORTS_DIR"

cd "$PROJECT_DIR"

echo ""
echo "============================================================"
echo "  SPRINT 1A — RGPD OPTION B v2 (consentement propre)"
echo "  GA4 + Microsoft Clarity conservés + bandeau de consentement"
echo "============================================================"
echo ""
echo "Projet : $PROJECT_DIR"
echo ""

# --- Garde-fou Git (correction #8) -------------------------------------------
echo ">>> Vérification de l'état Git du repo"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "KO : ce répertoire n'est pas un repo Git."
  echo "Le sprint 1A doit être lancé depuis un repo propre pour permettre relecture et rollback."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "KO : le repo contient déjà des modifications non commitées :"
  git status --short
  echo ""
  echo "Action requise : commit ou stash avant de lancer Sprint 1A."
  echo "  git add -A && git commit -m 'pré-sprint 1a' "
  echo "  ou"
  echo "  git stash"
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TARGET_BRANCH="sprint1a-rgpd-consentement"

if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
  echo "Création / bascule sur la branche $TARGET_BRANCH"
  git checkout -b "$TARGET_BRANCH" 2>/dev/null || git checkout "$TARGET_BRANCH"
fi

echo "OK repo propre, branche $(git rev-parse --abbrev-ref HEAD)"
echo ""

# -----------------------------------------------------------------------------
# LOT 1/4 — Réécriture de assets/js/analytics.js avec bandeau de consentement
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 1/4 — Réécriture analytics.js + bandeau de consentement custom"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML/CSS/JS hébergé sur Cloudflare Pages.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 1/4 — Réécrire complètement assets/js/analytics.js pour implémenter un bandeau de consentement custom RGPD-conforme qui contrôle le chargement de GA4 et Microsoft Clarity.

CONTRAINTE NON NÉGOCIABLE :
Avant tout consentement explicite, AUCUN appel réseau ne doit partir vers :
  - googletagmanager.com
  - google-analytics.com
  - analytics.google.com
  - region1.google-analytics.com
  - clarity.ms
Idem après refus. Vérifié par onglet Network en navigation privée.

ÉTAT ACTUEL du fichier assets/js/analytics.js :
  - Charge gtag.js et clarity.js automatiquement au chargement de page.
  - Contient déjà un Consent Mode v2 mais sans bandeau pour appeler 'consent update'.
  - Possède des events form_start, form_submit, cta_click, scroll_depth, outbound_click qui dépendent de gtag.

NOUVEAU COMPORTEMENT À IMPLÉMENTER :

1. Au chargement, le fichier ne charge AUCUN script tiers. Il définit uniquement :
   - les constantes GA_ID = 'G-NZ2MQMB67H' et CLARITY_ID = 'wbyffo03d6'
   - la clé localStorage CONSENT_KEY = 'ccdev_cookie_consent_v1'
   - les fonctions listées ci-dessous
   - puis appelle init() qui décide quoi faire selon le state actuel

2. Fonctions à implémenter :
   - getConsent() → lit localStorage, retourne objet {version, analytics, clarity, timestamp} ou null si absent ou version ancienne
   - saveConsent(consent) → écrit dans localStorage avec timestamp ISO et version 1
   - showConsentBanner() → injecte dans le DOM le bandeau bas de page avec le texte exact :
       'Nous utilisons des cookies de mesure d audience et d analyse comportementale afin de comprendre l utilisation du site et d améliorer nos pages. Vous pouvez accepter, refuser ou personnaliser votre choix. Vous pourrez le modifier à tout moment.'
     et 3 boutons côte à côte au MÊME NIVEAU HIÉRARCHIQUE, dans cet ordre :
       [Tout refuser] [Personnaliser] [Tout accepter]
     Aucun bouton n'est caché derrière 'Personnaliser'. 'Tout refuser' a le même poids visuel que 'Tout accepter' (taille, padding, contraste) — seul l'accent de couleur peut différer (refus en gris foncé, accepter en bleu accent). Pas de bouton refuser en lien texte minuscule.
   - showPreferencesPanel() → injecte une modale centrée avec :
       2 cases à cocher :
         'Google Analytics 4 — mesure d audience et événements de conversion'
         'Microsoft Clarity — cartes de chaleur et enregistrements de session'
       3 boutons en bas : 'Enregistrer mes choix', 'Tout refuser', 'Tout accepter'
       1 bouton de fermeture en haut à droite.
     IMPORTANT cases pré-cochées : utiliser getConsent() ; si null (premier choix utilisateur), les cases sont DÉCOCHÉES par défaut. Si un consentement existe déjà, reprendre l'état existant.
   - loadGoogleAnalytics() → injecte dynamiquement <script src=https://www.googletagmanager.com/gtag/js?id=G-NZ2MQMB67H>, initialise dataLayer + gtag, fait gtag('consent','default',{analytics_storage:'granted',ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied'}), gtag('js', new Date()), gtag('config', GA_ID, { send_page_view: true, anonymize_ip: true }).
   - loadMicrosoftClarity() → injecte dynamiquement le snippet Clarity standard. APRÈS chargement, appeler la Clarity Consent API v2 :
       window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'granted' });
     ad_Storage reste 'denied' systématiquement (pas de pub personnalisée).
   - revokeGoogleAnalytics() → si window.gtag existe, appeler :
       window.gtag('consent', 'update', { analytics_storage: 'denied', ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied' });
   - revokeMicrosoftClarity() → si window.clarity existe :
       window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'denied' });
       window.clarity('consent', false);
   - initConsentControlledTracking() → si analytics accepté, branche les event listeners sur :
       form#devisForm focus premier input → gtag('event','form_start')
       form#devisForm submit → gtag('event','form_submit')
       a[href*=wa.me], a[href*=cal.com], a[href^=tel:], a[href^=mailto:] click → gtag('event','cta_click', {channel: 'wa'/'cal'/'tel'/'email', destination: href})
       scroll 25/50/75/100% → gtag('event','scroll_depth', {percent})
       a[href^=http]:not([href*=ccdeveloppement.eu]) click → gtag('event','outbound_click', {destination: href})
     Si analytics refusé, ces listeners ne sont jamais branchés (ou si déjà branchés et user change d'avis vers refus, les ignorer via flag).
   - deleteAnalyticsCookies() → supprime les cookies _ga, _ga_*, _gid, _gat, _clck, _clsk, CLID, ANONCHK, MR, MUID, SM sur le domaine courant et sur .ccdeveloppement.eu en mettant expires=Thu, 01 Jan 1970 00:00:00 GMT et path=/.
   - openPreferences() → exposée sur window pour le lien permanent.

3. Logique init() au chargement :
   - const c = getConsent()
   - Si c === null : showConsentBanner()
   - Sinon :
       Si c.analytics : loadGoogleAnalytics() puis initConsentControlledTracking()
       Si c.clarity : loadMicrosoftClarity()
   - Dans tous les cas, brancher les listeners sur les liens [data-cookie-preferences] pour qu'ils appellent showPreferencesPanel() au clic et préviennent default.

4. Handlers des boutons :
   - 'Tout accepter' (bandeau) → saveConsent({analytics: true, clarity: true}) puis loadGoogleAnalytics() + loadMicrosoftClarity() + initConsentControlledTracking() puis fermer le bandeau.
   - 'Tout refuser' (bandeau) → saveConsent({analytics: false, clarity: false}) puis deleteAnalyticsCookies() puis fermer le bandeau.
   - 'Personnaliser' → fermer le bandeau et showPreferencesPanel().
   - 'Enregistrer mes choix' (modale) → lit les checkboxes. Pour chaque service :
       Cas analytics passe à false alors qu'il était true précédemment :
         revokeGoogleAnalytics() PUIS deleteAnalyticsCookies()
       Cas clarity passe à false alors qu'il était true précédemment :
         revokeMicrosoftClarity() PUIS deleteAnalyticsCookies()
       Cas service passe à true alors qu'il n'était pas chargé :
         loadGoogleAnalytics() ou loadMicrosoftClarity() selon le cas
       Pas de reload de page forcé.
       Puis saveConsent({analytics: x, clarity: y}). Fermer la modale.
   - 'Tout accepter' / 'Tout refuser' (modale) → comme bandeau + fermer modale. En 'Tout refuser' depuis une session post-acceptation, appeler revokeGoogleAnalytics() et revokeMicrosoftClarity() avant deleteAnalyticsCookies().

5. CSS du bandeau et de la modale :
   - Injecté dynamiquement via document.head.appendChild(style) au début de l'exécution.
   - Style sobre cohérent avec le design CC Développement : fond blanc, texte gris foncé, accent bleu (#0066cc) pour le bouton 'Tout accepter', gris (#6b7280) pour 'Personnaliser', bouton 'Tout refuser' avec même padding/taille que 'Tout accepter' mais couleur de fond gris foncé (#374151) ou bordure visible — NE PAS faire un simple lien texte. Ombre légère, bord radius 8px, padding généreux.
   - Bandeau : position fixed bottom 0, full width, flex layout, max-width 1200px centré, z-index élevé. Ordre HTML des boutons : Tout refuser, Personnaliser, Tout accepter (de gauche à droite).
   - Modale : position fixed centrée, backdrop noir 50% opacity, panel max-width 500px.
   - Responsive : sur mobile (max-width 640px), boutons en colonne mais en conservant l'ordre, modale full screen.
   - IMPORTANT : utiliser un préfixe ccdev-cookie- sur toutes les classes pour éviter collisions avec le CSS existant du site.

6. Accessibilité minimale :
   - Bandeau et modale ont role='dialog' et aria-label.
   - Boutons sont vrais <button>.
   - Focus trap dans la modale (basique : focus le premier élément à l'ouverture, fermeture par Escape).

7. Le script doit être autonome : pas de dépendance externe, pas de framework. Vanilla JS pur.

8. Gestion d'erreur défensive : try/catch autour de chaque chargement de script tiers (échec réseau ne doit pas casser le site).

9. En haut du fichier, conserver / réécrire un commentaire d'en-tête expliquant : version, date, comportement, contraintes RGPD.

LIVRABLE :
1. Réécris entièrement assets/js/analytics.js avec le nouveau comportement.
2. Crée _audit-reports/sprint1a-lot1-analytics.md décrivant :
   - état avant / après en quelques lignes
   - schéma des fonctions et de leurs interactions
   - comment tester en navigation privée
   - limites connues (ex: certains cookies tiers Clarity peuvent persister un certain temps sur les sous-domaines, mention du paramètre compte Clarity à vérifier).

NE TOUCHE PAS :
- aux fichiers HTML (autre lot)
- au _headers (autre lot — le lot 2 le traite)
- à rgpd-confidentialite.html (autre lot)

Si tu hésites sur un détail, documente dans le rapport plutôt que de modifier à l'aveugle." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 2/4 — Nettoyage preconnects HTML + _headers + ajout lien footer
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 2/4 — Suppression preconnects (HTML + _headers) + lien footer idempotent"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML/CSS/JS Cloudflare Pages.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 2/4 — Trois actions :
  A. Supprimer les preconnects GA4/Clarity dans les fichiers HTML.
  B. Supprimer les preconnects GA4/Clarity dans _headers (header Link s'il y est déclaré).
  C. Ajouter le lien permanent 'Gérer mes préférences cookies' en footer de chaque page, de manière IDEMPOTENTE (relancer le script ne crée pas de doublon).

PARTIE A — Suppression des preconnects HTML

Dans les fichiers HTML suivants, supprimer EXACTEMENT ces deux lignes (et seulement celles-ci) :
  <link rel=\"preconnect\" href=\"https://www.googletagmanager.com\">
  <link rel=\"preconnect\" href=\"https://www.clarity.ms\">

Conserver intacte la ligne :
  <link rel=\"preconnect\" href=\"https://app.cal.com\">

Liste des fichiers à traiter (vérifié par audit Sprint 0) :
  index.html
  estimateur.html
  blog/index.html
  blog/seo-local-herault-restaurants-artisans.html
  blog/combien-coute-site-vitrine-tpe-2026.html
  blog/creation-site-internet-agde-guide-complet-2026.html
  guide-seo-local.html
  seo-local-herault.html
  creation-site-web-agde.html
  guide-tarifs.html
  tarifs.html
  comparatif-tarifs.html
  devis.html

Soit 13 fichiers, jusqu'à 26 lignes à retirer au total.

Avant chaque modification, vérifier par grep que les deux lignes ciblées existent bien. Après modification, vérifier qu'elles ont disparu. Si une ligne n'existe pas dans un fichier, le noter dans le rapport mais ne pas planter.

PARTIE B — Nettoyage de _headers

Le rapport Sprint 0 montre que la production renvoie un header HTTP Link contenant les preconnects GA4/Clarity. Deux cas possibles :

  Cas 1 : _headers contient une directive Link explicite avec googletagmanager / clarity.ms
    → Modifier _headers pour retirer SEULEMENT les preconnects GA4/Clarity du header Link.
    → Conserver app.cal.com.
    → CRUCIAL : ne PAS toucher à la directive Content-Security-Policy.
       La CSP doit continuer à autoriser script-src www.googletagmanager.com www.google-analytics.com www.clarity.ms et connect-src www.google-analytics.com analytics.google.com region1.google-analytics.com www.clarity.ms (chargement post-consentement).

  Cas 2 : _headers ne contient AUCUNE directive Link
    → Le header HTTP Link observé en prod est injecté automatiquement par Cloudflare (Speed Brain / Early Hints) à partir des <link rel=preconnect> du HTML.
    → Dans ce cas la suppression des preconnects HTML (Partie A) résoudra automatiquement le header HTTP Link après purge cache Cloudflare.
    → Documenter explicitement ce cas dans le rapport et ne PAS modifier _headers à l'aveugle.

Procédure :
  1. Lire intégralement _headers.
  2. grep -i 'Link:' _headers — si match, on est en Cas 1, modifier la directive Link.
  3. Si pas de match, on est en Cas 2, ne pas modifier _headers, le noter dans le rapport.

PARTIE C — Ajout du lien footer (idempotent)

Dans toutes les pages HTML du repo (à la racine ET dans blog/), ajouter UN SEUL lien permanent dans le footer existant.

Pattern à ajouter :
  <a href=\"#\" data-cookie-preferences class=\"footer-cookie-link\">Gérer mes préférences cookies</a>

PROTOCOLE D'IDEMPOTENCE — IMPORTANT :
  Pour chaque fichier :
    1. grep 'data-cookie-preferences' \"\$f\"
    2. Si 0 occurrence → ajouter le lien (1 fois)
    3. Si 1 occurrence → ne rien faire, fichier déjà conforme
    4. Si 2+ occurrences → ANOMALIE, supprimer les doublons et n'en garder qu'un
  Le script doit être relançable plusieurs fois sans empiler les liens.

Stratégie de placement :
  1. Lis le fichier HTML.
  2. Repère le footer (<footer>...</footer> ou un div pied de page contenant déjà 'Mentions légales' ou 'Politique de confidentialité').
  3. Ajoute le lien à un endroit cohérent, dans la même liste/zone que les liens existants vers /mentions-legales et /rgpd-confidentialite.
  4. Pour les pages sans footer visible (ex: merci.html minimaliste), juger : si pas de footer du tout, ne pas ajouter et le noter dans le rapport.

Le style CSS du lien : si possible, ajouter dans le CSS global (assets/css/...) une règle minimale qui le rend cohérent visuellement avec les autres liens du footer (couleur, taille, hover). Si le CSS est par page ou inline, faire au plus juste sans casser le design existant.

CONTRAINTES :
- Ne pas toucher à autre chose dans les fichiers (pas de réécriture de blocs voisins, pas de reformatage).
- Préserver l'indentation existante.
- Ne pas modifier analytics.js, ni rgpd-confidentialite.html (autres lots).
- Sur _headers, ne JAMAIS toucher à la CSP.

LIVRABLE :
Crée _audit-reports/sprint1a-lot2-html-headers.md avec :
  - Partie A : liste des 13 fichiers HTML modifiés, nature de la modification (preconnect GA4 retiré, preconnect Clarity retiré)
  - Partie B : statut Cas 1 ou Cas 2, et si Cas 1, diff de _headers ; si Cas 2, explication que Cloudflare gère le Link header automatiquement
  - Partie C : liste des fichiers où le lien a été ajouté, déjà présent (idempotence), ou non applicable
  - commande grep de vérification : grep -c 'preconnect.*googletagmanager\\|preconnect.*clarity' *.html blog/*.html (doit retourner 0 partout)
  - commande grep de vérification : grep -l 'data-cookie-preferences' *.html blog/*.html (doit lister toutes les pages traitées sans doublon)
  - commande grep de vérification CSP intacte : grep 'googletagmanager.com\\|clarity.ms' _headers (doit retourner les lignes CSP)

Si tu hésites, documente dans le rapport plutôt que de modifier à l'aveugle." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 3/4 — Mise à jour rgpd-confidentialite.html
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 3/4 — Mise à jour de la page RGPD"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 3/4 — Mettre à jour rgpd-confidentialite.html pour refléter la réalité technique post-Sprint 1A.

ÉTAT ACTUEL :
La section 6 'Cookies et traceurs' contient cette phrase contradictoire :
  'Le site n utilise pas de cookies publicitaires ni d outils de tracking marketing tiers sur la version actuelle.'
Or GA4 et Microsoft Clarity sont déployés (chargés sur consentement après Sprint 1A).

OBJECTIF :
Réécrire la section 6 pour qu'elle décrive précisément :
  - GA4 (mesure d audience, événements de conversion : demandes de devis, clics WhatsApp, Cal.com)
  - Microsoft Clarity (cartes de chaleur, enregistrements de session, ergonomie)
  - le fait que ces outils ne se chargent qu'après consentement explicite
  - la possibilité de modifier le choix via le lien 'Gérer mes préférences cookies'

Et ajouter par transparence :
  - Cloudflare : statistiques techniques et sécurité de l'hébergement.
  - Brevo / Sendinblue : utilisé uniquement quand l'utilisateur remplit volontairement le formulaire de téléchargement du guide.
  - Formspree : utilisé uniquement quand l'utilisateur envoie volontairement une demande de devis.
  - Cal.com : utilisé uniquement quand l'utilisateur réserve volontairement un rendez-vous.

TEXTE EXACT À INTÉGRER pour la section principale (adapter au formatage HTML existant — paragraphes, titres h2/h3, listes ul/li selon ce que la page utilise déjà) :

Titre de section (h2 ou équivalent du niveau utilisé pour les autres sections) :
  6. Cookies et mesure d audience

Paragraphe d'intro :
  Le site peut utiliser, uniquement après votre consentement, des outils de mesure d audience et d analyse comportementale.

Liste des outils sous consentement :
  - Google Analytics 4 : mesure de fréquentation, pages consultées, événements de conversion comme les demandes de devis ou clics vers WhatsApp et Cal.com.
  - Microsoft Clarity : analyse de l expérience utilisateur, cartes de chaleur et enregistrements de session afin d améliorer l ergonomie du site.

Paragraphe d'engagement :
  Ces outils ne sont chargés qu'après acceptation explicite. Vous pouvez refuser ou modifier votre choix à tout moment via le lien 'Gérer mes préférences cookies' présent en bas de chaque page.

Sous-section ou paragraphe additionnel pour les autres services (transparence) :
  Autres services tiers utilisés ponctuellement et uniquement sur action volontaire de votre part :
  - Cloudflare : statistiques techniques et de sécurité liées à l'hébergement et à la protection du site.
  - Brevo / Sendinblue : envoi du guide SEO local après remplissage volontaire du formulaire dédié.
  - Formspree : transmission de votre demande après envoi volontaire du formulaire de devis.
  - Cal.com : prise de rendez-vous après réservation volontaire d'un créneau.

Les autres sections de la page (Responsable du traitement, Données traitées, Finalités, Base légale, Durée de conservation, Vos droits, Recours CNIL, Mise à jour) doivent rester INTACTES sauf renumérotation si nécessaire.

Mettre à jour la date de dernière mise à jour si elle figure en bas de page : remplacer la date actuelle par la date du jour au format français ('Dernière mise à jour : 3 mai 2026.' — ou la date système courante si différente).

CONTRAINTES :
- Respecter le HTML existant (structure, classes CSS, balises).
- Ne pas casser le style ni la mise en page.
- Apostrophes typographiques : utiliser ' ou apostrophes droites selon ce que la page utilise déjà.
- Ne pas modifier d'autres fichiers (analytics.js et HTML autres pages : autres lots).
- Ne pas modifier _headers.

LIVRABLE :
Crée _audit-reports/sprint1a-lot3-rgpd.md avec :
  - extrait avant / après de la section modifiée
  - confirmation que les autres sections n'ont pas été touchées
  - confirmation de la date de mise à jour
  - éventuels points à valider manuellement par Cyril (ex: durée exacte de conservation des données GA4 selon ses paramètres compte)

Si tu hésites, documente dans le rapport plutôt que de modifier à l'aveugle." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 4/4 — Tests de validation + rapport sprint final
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 4/4 — Tests de validation et rapport sprint consolidé"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 4/4 — Valider le travail des lots 1, 2 et 3 du Sprint 1A RGPD Option B v2, puis consolider en un rapport sprint final.

ÉTAT ATTENDU APRÈS LOTS PRÉCÉDENTS :
  - assets/js/analytics.js réécrit : ne charge GA4/Clarity QUE après consentement
    ordre boutons bandeau : Tout refuser / Personnaliser / Tout accepter
    cases modale décochées par défaut si premier choix
    Clarity API consentv2 implémentée
    révocations gtag consent update et clarity consent false avant deleteAnalyticsCookies
  - 26 lignes preconnect GA4/Clarity supprimées dans 13 fichiers HTML
  - _headers : si directive Link explicite contenait GA4/Clarity, nettoyée ; sinon laissée telle quelle (cas Cloudflare auto)
  - CSP _headers INTACTE pour autoriser GA4/Clarity post-consentement
  - lien 'Gérer mes préférences cookies' ajouté UNE SEULE FOIS dans le footer de chaque page (idempotent)
  - rgpd-confidentialite.html mis à jour avec section 6 réaliste

TÂCHES DE VALIDATION (à exécuter via bash + grep + lecture de fichiers) :

1. Vérifier qu'aucun preconnect GA4/Clarity ne subsiste dans le HTML :
   bash -c \"grep -rn 'preconnect.*googletagmanager\\|preconnect.*clarity' --include='*.html' . || echo 'OK aucun preconnect GA/Clarity restant dans HTML'\"

2. Vérifier la présence UNIQUE du lien 'Gérer mes préférences cookies' sur les pages principales (idempotence) :
   bash -c \"for f in index.html devis.html tarifs.html estimateur.html creation-site-web-agde.html seo-local-herault.html guide-seo-local.html comparatif-tarifs.html guide-tarifs.html mentions-legales.html rgpd-confidentialite.html blog/index.html ; do COUNT=\$(grep -c 'data-cookie-preferences' \"\$f\" 2>/dev/null || echo 0) ; echo \"\$f : \$COUNT\" ; done\"
   Chaque ligne doit afficher \"1\". Toute valeur 0 ou 2+ doit être listée comme anomalie.

3. Vérifier que assets/js/analytics.js NE charge plus gtag.js / clarity automatiquement :
   - Lire le fichier et confirmer que les chaînes 'googletagmanager.com/gtag/js' et 'clarity.ms/tag/' apparaissent UNIQUEMENT dans des fonctions appelées sur consentement (loadGoogleAnalytics, loadMicrosoftClarity), JAMAIS au niveau racine du fichier.
   - Confirmer la présence des 10 fonctions clés : getConsent, saveConsent, showConsentBanner, showPreferencesPanel, loadGoogleAnalytics, loadMicrosoftClarity, revokeGoogleAnalytics, revokeMicrosoftClarity, initConsentControlledTracking, deleteAnalyticsCookies.
   - Confirmer la présence de window.clarity('consentv2', ...) et window.clarity('consent', false).
   - Confirmer la présence de gtag('consent', 'update', { analytics_storage: 'denied', ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied' }).
   - Confirmer que la clé localStorage est bien 'ccdev_cookie_consent_v1'.
   - Confirmer que dans showPreferencesPanel les checkboxes ne sont PAS pré-cochées si getConsent() === null.
   - Confirmer que l'ordre HTML des boutons du bandeau est : Tout refuser, Personnaliser, Tout accepter.

4. Vérifier que rgpd-confidentialite.html ne contient plus la phrase contradictoire :
   bash -c \"grep -F 'n utilise pas de cookies publicitaires ni d outils de tracking marketing tiers' rgpd-confidentialite.html && echo 'KO phrase contradictoire toujours présente' || echo 'OK phrase contradictoire retirée'\"
   Vérifier la présence des nouvelles mentions :
   bash -c \"grep -i 'Google Analytics 4\\|Microsoft Clarity' rgpd-confidentialite.html\"

5. Vérifier que _headers conserve la CSP GA4/Clarity (post-consentement) :
   bash -c \"grep 'googletagmanager.com\\|clarity.ms' _headers\"
   Doit retourner au moins les lignes script-src et connect-src.
   Vérifier qu'aucune directive Link explicite avec googletagmanager.com ou clarity.ms ne subsiste :
   bash -c \"grep -i '^[[:space:]]*Link:.*googletagmanager\\|^[[:space:]]*Link:.*clarity' _headers || echo 'OK aucune directive Link GA4/Clarity dans _headers'\"

6. Vérifier la cohérence des fichiers modifiés via git :
   bash -c \"git status --short\"
   Lister tous les fichiers modifiés et confirmer qu'ils correspondent au périmètre Sprint 1A :
     assets/js/analytics.js
     13 fichiers HTML (preconnects + lien footer)
     _headers (si Cas 1)
     rgpd-confidentialite.html
   Aucun fichier inattendu (CTAs, polices, Lenis, OG, Schema, devis hors lien footer).

7. Préparer les commandes de test post-déploiement pour Cyril :
   - bash -c \"curl -sSI https://ccdeveloppement.eu/ | grep -i '^link:'\"
       Le résultat ne doit PLUS contenir googletagmanager.com ni clarity.ms.
       Peut encore contenir app.cal.com.
   - bash -c \"curl -sS https://ccdeveloppement.eu/ | grep -i preconnect | grep -E 'googletagmanager|clarity' && echo KO || echo OK aucun preconnect GA/Clarity en prod\"
   - Test navigation privée nouveau visiteur : doit voir le bandeau, et l'onglet Network doit être vierge de tout appel à googletagmanager.com / google-analytics.com / analytics.google.com / region1.google-analytics.com / clarity.ms.
   - Test 'Tout refuser' : pas de tag chargé, choix mémorisé, recharger la page maintient le refus.
   - Test 'Tout accepter' : gtag.js et clarity chargés, GA4 reçoit pageview, pas d'erreur console CSP.
   - Test 'Personnaliser' : possibilité de choisir GA4 oui / Clarity non et inversement, cases NON pré-cochées au premier passage.
   - Test lien permanent 'Gérer mes préférences cookies' : ouvre la modale, permet de changer.
   - Test révocation : après acceptation puis refus via Personnaliser, vérifier que gtag('consent','update',denied) et clarity('consent',false) sont appelés AVANT deleteAnalyticsCookies(), puis effacement effectif des cookies _ga, _ga_*, _clck, _clsk, etc.

LIVRABLE PRINCIPAL :
Crée _audit-reports/sprint1a-rgpd-rapport.md qui consolide :

  ## Sprint 1A — RGPD Option B v2 — Rapport final

  ### Décision
  Conservation de GA4 + Microsoft Clarity, chargés uniquement après consentement explicite. Bandeau custom intégré dans analytics.js.

  ### Fichiers modifiés
  Lister précisément tous les fichiers touchés avec une ligne par fichier.

  ### Comportement avant
  Synthèse en 5 lignes max.

  ### Comportement après
  Synthèse en 5 lignes max + extraits de logs des vérifications grep.

  ### Résultats des 7 tâches de validation
  Statut OK / KO / À VÉRIFIER pour chacune avec preuve (commande exécutée + output).

  ### Tests manuels à effectuer par Cyril
  Liste numérotée avec étapes précises et résultat attendu.

  ### Limites et points d'attention
  - Mode consentement Microsoft Clarity à valider côté compte (paramètres projet wbyffo03d6) — Consent v2 doit être activé.
  - Cookies third-party Clarity peuvent persister un délai après refus (limitation navigateur).
  - À tester en navigation privée chrome/firefox/safari avant déploiement prod.
  - Si _headers n'a pas été modifié (Cas 2), purger le cache Cloudflare après déploiement pour que le header HTTP Link injecté automatiquement soit régénéré sans GA4/Clarity.

  ### Commandes de vérification post-déploiement
  Bloc bash :
    curl -sSI https://ccdeveloppement.eu/ | grep -i '^link:'
    curl -sS https://ccdeveloppement.eu/ | grep -i preconnect

  ### Référence des rapports détaillés
  Pointeurs vers _audit-reports/sprint1a-lot1-analytics.md, sprint1a-lot2-html-headers.md, sprint1a-lot3-rgpd.md.

  ### Sprint suivant recommandé
  Sprint 1B — hygiène technique (CTAs href=#, polices .otf, Lenis, encodage Assistant WhatsApp). Ne pas démarrer avant validation manuelle de ce Sprint 1A en navigation privée.

NE MODIFIE AUCUN FICHIER DE PRODUCTION dans ce lot. C'est exclusivement de la validation et du reporting." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# Synthèse finale
# -----------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "  SPRINT 1A v2 TERMINÉ"
echo "============================================================"
echo ""
echo "Branche Git : $(git rev-parse --abbrev-ref HEAD)"
echo ""
echo "Rapports générés dans $REPORTS_DIR :"
echo "  - sprint1a-lot1-analytics.md"
echo "  - sprint1a-lot2-html-headers.md"
echo "  - sprint1a-lot3-rgpd.md"
echo "  - sprint1a-rgpd-rapport.md  (rapport final consolidé)"
echo ""
echo "ÉTAPES MANUELLES CRITIQUES :"
echo "  1. Lire _audit-reports/sprint1a-rgpd-rapport.md"
echo "  2. git diff pour relecture complète"
echo "  3. Tester en navigation privée local ou preview Cloudflare avant deploy prod"
echo "  4. Vérifier dans le compte Microsoft Clarity que Consent API v2 est activé"
echo "  5. Si tout est OK : git commit + push + deploy + purge cache Cloudflare"
echo "  6. Test post-deploy : curl -sSI https://ccdeveloppement.eu/ | grep -i '^link:'"
echo "     → ne doit PLUS contenir googletagmanager.com ni clarity.ms"
echo ""
echo "Critères de succès en navigation privée AVANT acceptation cookies :"
echo "  → onglet Network ne doit montrer AUCUN appel vers googletagmanager.com,"
echo "    google-analytics.com, analytics.google.com, region1.google-analytics.com,"
echo "    clarity.ms"
echo ""
