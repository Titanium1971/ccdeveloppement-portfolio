#!/bin/bash
# =============================================================================
# run-sprint1b-hygiene.sh — v1
# Sprint 1B — Hygiène technique + résidu RGPD du Sprint 1A
# =============================================================================
#
# Objectif :
#   - Réparer les 27 CTAs href="#" avec règles de tri par contexte.
#   - Ajouter les 3 résidus RGPD oubliés au Sprint 1A.
#   - Réparer l'encodage cassé section Assistant WhatsApp dans index.html.
#   - Investiguer / supprimer la font Perplexity orpheline (best-effort).
#   - Bundler Lenis localement (suppression dépendance unpkg).
#
# RETIRÉ DU PÉRIMÈTRE :
#   - Conversion polices .otf → .woff2 : pas de licence webfont confirmée
#     (suffixe "Embedded" suggère extraction PDF, fonderies surveillent).
#     → Sujet juridique à part dans un sprint dédié "Audit licences fonts".
#
# Cal.com handle utilisé : cc-developpement/audit-gratuit
#
# Usage :
#   chmod +x scripts/run-sprint1b-hygiene.sh
#   ./scripts/run-sprint1b-hygiene.sh
# =============================================================================

set -e

# --- Résolution du chemin projet ---------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
REPORTS_DIR="$PROJECT_DIR/_audit-reports"
mkdir -p "$REPORTS_DIR"

cd "$PROJECT_DIR"

echo ""
echo "============================================================"
echo "  SPRINT 1B — HYGIÈNE TECHNIQUE + RÉSIDU RGPD"
echo "  CTAs href=# / encodage / Lenis local / RGPD résidu"
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
  echo "Action requise : commit ou stash avant de lancer Sprint 1B."
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TARGET_BRANCH="sprint1b-hygiene-technique"

if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
  echo "Création / bascule sur la branche $TARGET_BRANCH"
  git checkout -b "$TARGET_BRANCH" 2>/dev/null || git checkout "$TARGET_BRANCH"
fi

echo "OK repo propre, branche $(git rev-parse --abbrev-ref HEAD)"
echo ""

# -----------------------------------------------------------------------------
# LOT 1/4 — CTAs href="#" avec règles de tri + résidu RGPD
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 1/4 — Réparation CTAs href=# (27 occurrences) + résidu RGPD 1A"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML/CSS/JS Cloudflare Pages.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 1/4 — Deux actions distinctes :
  A. Réparer les 27 CTAs href=\"#\" avec règles de tri par contexte
  B. Ajouter les 3 résidus RGPD oubliés du Sprint 1A à rgpd-confidentialite.html

==========================================
PARTIE A — Réparation CTAs href=\"#\"
==========================================

CONTEXTE :
27 occurrences de href=\"#\" identifiées dans 16 fichiers HTML par l'audit Sprint 0.
Cal.com handle confirmé : cc-developpement/audit-gratuit
Le snippet d'init Cal.com est déjà présent dans toutes les pages :
  Cal(\"init\", {origin:\"https://app.cal.com\"});

RÈGLES DE TRI PAR CONTEXTE — IMPORTANT, dans cet ordre de priorité :

Règle 1 — Bouton avec event listener JS attaché (PRIORITÉ ABSOLUE)
  Si le bouton/lien a déjà un onclick=\"...\", un id ciblé ailleurs dans le code,
  ou est référencé par addEventListener / querySelector dans le JS de la page :
    → LAISSER href=\"#\" intact (modifier casserait le JS).
    → Si pas déjà présent dans le handler JS, AJOUTER e.preventDefault()
      pour éviter le scroll-to-top par défaut.
  Recherche : pour chaque ancre href=\"#\", grep dans le même fichier (et dans
  assets/js/*.js) si l'élément a un id ciblé ou un sélecteur attaché.

Règle 2 — Texte contient \"audit\", \"réserver\", \"rdv\", \"contact\", \"prendre rendez-vous\" (case-insensitive sur l'innerText du bouton/lien)
    → Remplacer href=\"#\" par data-cal-link=\"cc-developpement/audit-gratuit\"
      ET conserver href=\"https://cal.com/cc-developpement/audit-gratuit\"
      en fallback (au cas où le JS Cal.com ne se charge pas).
    → Concrètement : <a href=\"https://cal.com/cc-developpement/audit-gratuit\" data-cal-link=\"cc-developpement/audit-gratuit\" ...>

Règle 3 — Logo header ou footer (image ou texte du logo)
    → Remplacer par href=\"/\".

Règle 4 — Card cliquable (blog, projet, service)
    → Si une page de détail existe et est identifiable depuis le contexte :
      pointer dessus.
    → Sinon, documenter dans le rapport et ne pas modifier (préférer un état
      explicitement non-traité plutôt qu'un mauvais lien).

Règle 5 — Tout autre cas non couvert
    → Ne pas modifier.
    → Documenter ligne + contexte HTML dans le rapport pour décision manuelle.

PROCESSUS :
1. Pour chaque fichier HTML du repo (à la racine + dans blog/), lister tous les href=\"#\".
2. Pour chaque occurrence, capturer :
   - fichier + numéro de ligne
   - texte du bouton/lien (innerText)
   - 2 lignes de contexte HTML avant et après
   - règle appliquée (1, 2, 3, 4 ou 5)
   - action prise (modifié / laissé + preventDefault ajouté / non touché)
3. Appliquer la modification.
4. Ne JAMAIS dédupliquer ou supprimer un bloc HTML : seulement modifier l'attribut href ou ajouter data-cal-link.

LIVRABLE PARTIE A :
Section dans le rapport _audit-reports/sprint1b-lot1-ctas-rgpd.md avec un tableau exhaustif :

| Fichier | Ligne | Texte CTA | Règle | Action |
|---------|-------|-----------|-------|--------|
| index.html | 234 | Réserver un audit | R2 | data-cal-link ajouté + href cal.com |
| ...

Et un grep de vérification finale : pour chaque page, lister les href=\"#\" restants après modification (doit être limité aux cas R1 et R5).

==========================================
PARTIE B — Résidus RGPD du Sprint 1A
==========================================

3 mini-ajouts à rgpd-confidentialite.html :

B.1 — Transferts hors UE
Ajouter dans la section Cookies et mesure d audience (ou en sous-section) :
  Les outils Google Analytics 4 et Microsoft Clarity peuvent entraîner un transfert
  de données vers les États-Unis. Google LLC et Microsoft Corporation sont signataires
  du Data Privacy Framework (DPF) approuvé par la Commission européenne, ce qui
  encadre ces transferts. Des Clauses Contractuelles Types (CCT) sont également
  appliquées en complément. Vous pouvez à tout moment refuser ces outils via le
  lien Gérer mes préférences cookies.

B.2 — Durée de conservation GA4 / Clarity
Ajouter dans la section Durée de conservation existante (ou créer une sous-section) :
  - Google Analytics 4 : durée de conservation des données utilisateur configurée
    sur 14 mois (paramètre par défaut Google).
  - Microsoft Clarity : conservation des enregistrements de session pendant 90 jours
    maximum (paramètre par défaut Microsoft).

B.3 — Vérification adresse responsable de traitement
Lire la section actuelle Responsable du traitement :
  - Confirmer que l'adresse est bien : 27 Rue Basse, 34300 Agde.
  - Vérifier la cohérence avec les blocs JSON-LD du site (PostalAddress dans index.html
    et autres pages — déjà confirmé par audit Sprint 0).
  - Si incohérence détectée, signaler dans le rapport sans modifier (Cyril doit valider).

CONTRAINTES :
- Préserver la mise en page HTML existante (h2/h3, ul/li, structure).
- Ne pas casser le style.
- Mettre à jour la date de dernière mise à jour avec la date système courante.

LIVRABLE PARTIE B :
Section dans le même rapport _audit-reports/sprint1b-lot1-ctas-rgpd.md :
- diff avant / après de la section Cookies et mesure d audience
- diff avant / après de la section Durée de conservation
- statut de la vérification adresse RT (cohérent / à vérifier manuellement)

==========================================
NE TOUCHE PAS :
  - aux fichiers analytics.js, _headers
  - à index.html sauf pour les CTAs href=# (l'encodage WhatsApp est dans LOT 2)
  - aux fichiers Lenis (LOT 3)

Si tu hésites, documente dans le rapport plutôt que de modifier à l'aveugle." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 2/4 — Encodage section WhatsApp + recherche font Perplexity
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 2/4 — Réparation encodage WhatsApp + recherche font Perplexity (best-effort)"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 2/4 — Deux actions :
  A. Réparer l'encodage cassé de la section Assistant WhatsApp IA dans index.html
  B. Recherche best-effort de l'origine de la font Perplexity orpheline (10 min max)

==========================================
PARTIE A — Encodage section WhatsApp
==========================================

CONTEXTE :
L'audit Sprint 0 a détecté des accents perdus dans la section Assistant WhatsApp IA
de index.html, lignes 1804-1830 environ. Le reste du site est correctement accentué.

CORRECTIONS À APPLIQUER (uniquement dans index.html, section concernée) :
  Reservation → Réservation (singulier ou pluriel selon contexte)
  Reservations → Réservations
  Reponse → Réponse
  Reponses → Réponses
  reseaux sociaux → réseaux sociaux
  frequentation → fréquentation
  Resume matinal → Résumé matinal
  reservations → réservations
  evenements → événements
  Generez → Générez
  reservent → réservent
  gere → gère
  taches → tâches
  meteo → météo

PROCÉDURE :
1. Lire la section concernée (chercher 'wa-feature-title' ou 'Assistant WhatsApp' dans index.html).
2. Identifier toutes les chaînes sans accent qui devraient être accentuées.
3. Corriger UNIQUEMENT dans cette section (ne pas toucher au reste du fichier).
4. Vérifier que l'encodage du fichier est UTF-8 (file -i index.html).
5. Vérifier qu'aucun caractère mojibake (Ã©, Ã¨, etc.) n'a été introduit.

CONTRAINTES :
- Ne corriger QUE dans la section Assistant WhatsApp IA.
- Si un mot apparaît ailleurs dans le fichier sans accent ET avec un autre sens, ne pas le toucher (chercher le contexte).
- Préserver la structure HTML, classes CSS et balises.

==========================================
PARTIE B — Font Perplexity orpheline (best-effort)
==========================================

CONTEXTE :
L'audit Sprint 0 a détecté un appel réseau vers
  https://frontend-cdn.perplexity.ai/_agi_assets/fonts/FKGroteskNeue.woff2
qui retourne 503 en prod, mais ne se trouve pas dans les fichiers du repo via grep.

PROCÉDURE BEST-EFFORT (10 minutes maximum) :
1. grep récursif dans le repo en incluant TOUS les types de fichiers (pas seulement html/js/css) :
   bash -c \"grep -rIn 'perplexity\\|FKGroteskNeue' . --exclude-dir=.git --exclude-dir=node_modules\"
2. Si trouvé : supprimer la référence et documenter.
3. Si non trouvé : chercher dans :
   - les CSS minifiés (assets/css/*)
   - smooth-scroll.js
   - analytics.js
   - tout fichier .json (manifest, sw.js)
   - les attributs style= inline dans les HTML
4. Si toujours non trouvé après ces recherches : documenter dans le rapport
   comme énigme non résolue, hypothèse : référence morte dans un service worker
   ou un cache navigateur ancien. Ne PAS perdre plus de temps.

LIVRABLE LOT 2 :
Crée _audit-reports/sprint1b-lot2-encodage-fonts.md avec :
- Partie A : liste des corrections d'encodage (avant → après) avec numéro de ligne
- Partie B : statut recherche font Perplexity (trouvée et supprimée / non trouvée + hypothèses)
- commande grep de vérification : grep -E 'Reservation|Reponse|frequentation|reseaux sociaux' index.html
  → ne doit retourner que les variantes accentuées (ou rien si pas d'accent dans le grep pattern)

NE TOUCHE PAS :
  - aux autres fichiers HTML (LOT 1 traite les CTAs)
  - aux fichiers Lenis (LOT 3)
  - à analytics.js / _headers / rgpd-confidentialite.html

Si tu hésites, documente plutôt que de modifier à l'aveugle." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 3/4 — Lenis local (avec checksum)
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 3/4 — Bundle Lenis localement avec validation checksum"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 3/4 — Bundler Lenis localement et remplacer la dépendance unpkg dans tous les fichiers HTML.

CONTEXTE :
L'audit Sprint 0 a détecté que toutes les pages chargent Lenis depuis :
  https://unpkg.com/lenis@1.1.18/dist/lenis.min.js
Risque : si unpkg tombe ou change, le smooth-scroll casse partout. Bundler localement.

PROCÉDURE :

1. Vérifier la version Lenis exacte actuellement utilisée
   grep -hE 'unpkg.com/lenis@[^/]+' *.html blog/*.html | sort -u
   La version est attendue 1.1.18 mais vérifier qu'aucune page n'utilise une version différente
   ou une version @latest. Toute incohérence doit être documentée.

2. Télécharger Lenis localement (HTTPS via curl ou wget) :
   bash -c \"mkdir -p assets/js && curl -sSL -o assets/js/lenis.min.js https://unpkg.com/lenis@1.1.18/dist/lenis.min.js\"

3. Validation checksum SHA-256 :
   - Calculer le SHA-256 du fichier téléchargé : sha256sum assets/js/lenis.min.js
   - Le comparer avec celui servi par unpkg via Header X-Checksum-Sha256 ou en re-téléchargeant et comparant.
   - Si mismatch : alerter dans le rapport et NE PAS poursuivre la substitution.
   - Si match : noter le checksum dans le rapport comme preuve d'intégrité.

4. Vérifier que le fichier téléchargé est bien du JS valide :
   - file assets/js/lenis.min.js (doit être ASCII text ou JavaScript)
   - taille raisonnable (entre 10 Ko et 100 Ko)
   - ne contient pas de balises HTML (signe d'une page d'erreur déguisée)

5. Remplacement dans tous les fichiers HTML qui utilisent Lenis :
   Avant :
     <script src=\"https://unpkg.com/lenis@1.1.18/dist/lenis.min.js\"></script>
   Après :
     <script src=\"/assets/js/lenis.min.js\"></script>
   ATTENTION : pour les pages dans blog/, utiliser le chemin absolu /assets/js/lenis.min.js
   (et pas ../assets/js/...) pour rester cohérent avec les autres scripts qui utilisent
   déjà des chemins absolus dans le repo.

   Liste des fichiers à modifier (basé sur audit Sprint 0) :
     index.html, mentions-legales.html, estimateur.html, rgpd-confidentialite.html,
     seo-local-herault.html, creation-site-web-agde.html, guide-tarifs.html,
     tarifs.html, comparatif-tarifs.html, devis.html
     blog/seo-local-herault-restaurants-artisans.html
     blog/combien-coute-site-vitrine-tpe-2026.html
     blog/creation-site-internet-agde-guide-complet-2026.html
   À vérifier : grep -l 'unpkg.com/lenis' *.html blog/*.html avant modification.

6. Mettre à jour _headers si nécessaire :
   La CSP actuelle autorise unpkg.com dans script-src et connect-src. Ces autorisations
   peuvent être conservées (au cas où d'autres ressources unpkg seraient ajoutées plus tard)
   OU retirées si on veut un nettoyage strict.
   DÉCISION : laisser unpkg.com dans la CSP pour ce sprint (pas de nettoyage CSP, périmètre
   minimal). Le notir dans le rapport comme amélioration possible future.

7. Test post-modification :
   - grep -l 'unpkg.com/lenis' *.html blog/*.html (doit retourner 0 fichiers)
   - grep -l '/assets/js/lenis.min.js' *.html blog/*.html (doit lister tous les fichiers traités)
   - vérifier que la page index.html se charge sans erreur en local (file:// ou serveur dev)

LIVRABLE LOT 3 :
Crée _audit-reports/sprint1b-lot3-lenis.md avec :
- version Lenis vérifiée (attendue 1.1.18, vérifier toutes les pages)
- checksum SHA-256 du fichier local et confirmation match avec unpkg
- liste des fichiers HTML modifiés
- taille du fichier lenis.min.js téléchargé
- commande de vérification post-modification

NE TOUCHE PAS :
- aux fichiers traités par LOTs 1 et 2 (sauf pour le remplacement Lenis dans leurs <script>)
- au _headers (laisser CSP intacte)
- à analytics.js
- aux polices (.otf — sujet juridique à part, retiré du périmètre Sprint 1B)

Si le téléchargement échoue ou si le checksum ne correspond pas, ARRÊTER LE LOT et
documenter dans le rapport. Ne pas modifier les HTML si le fichier Lenis local n'est
pas validé." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# LOT 4/4 — Validation + rapport sprint final
# -----------------------------------------------------------------------------
echo ""
echo ">>> LOT 4/4 — Validation et rapport sprint consolidé"
echo ""

claude -p "Tu es dans le projet CC Développement, site statique HTML.
Repo : /Users/cyril/Projets/cc-developpement/portfolio

MISSION LOT 4/4 — Valider le travail des lots 1, 2 et 3 du Sprint 1B, puis consolider en un rapport sprint final.

ÉTAT ATTENDU APRÈS LOTS PRÉCÉDENTS :
  - 27 CTAs href=\"#\" traités selon les 5 règles (Cal.com, /, page détail, ou laissé+preventDefault)
  - 3 résidus RGPD ajoutés à rgpd-confidentialite.html (transferts hors UE, durées, RT)
  - Encodage section Assistant WhatsApp IA dans index.html corrigé
  - Recherche font Perplexity terminée (trouvée+supprimée OU documentée comme orpheline)
  - Lenis bundlé localement dans assets/js/lenis.min.js
  - 13 fichiers HTML pointent vers /assets/js/lenis.min.js au lieu d'unpkg
  - _headers laissé intact (CSP minimal)

TÂCHES DE VALIDATION :

1. CTAs href=\"#\" résiduels (doit être limité aux cas R1 = JS attaché et R5 = non couvert) :
   bash -c \"grep -rn 'href=\\\"#\\\"' --include='*.html' . | wc -l\"
   bash -c \"grep -rn 'href=\\\"#\\\"' --include='*.html' . \"
   Comparer avec le rapport sprint1b-lot1-ctas-rgpd.md pour vérifier que chaque résiduel
   est bien dans la catégorie R1 (avec preventDefault) ou R5 (documenté).

2. Cal.com link bien intégré :
   bash -c \"grep -rn 'data-cal-link=\\\"cc-developpement/audit-gratuit\\\"' --include='*.html' . | wc -l\"
   Doit lister plusieurs occurrences (les CTAs audit/réserver/contact).

3. Résidus RGPD ajoutés :
   bash -c \"grep -i 'Data Privacy Framework\\|DPF\\|Standard Contractual\\|14 mois\\|90 jours\\|transferts.*États-Unis' rgpd-confidentialite.html\"
   Doit retourner les nouveaux paragraphes.

4. Encodage WhatsApp corrigé :
   bash -c \"grep -E 'Reservations|Reponses|frequentation|reseaux sociaux' index.html\"
   Doit ne retourner AUCUNE occurrence (toutes les variantes non-accentuées corrigées).
   bash -c \"grep -E 'Réservations|Réponses|fréquentation|réseaux sociaux' index.html\"
   Doit retourner les variantes accentuées.

5. Lenis local en place :
   bash -c \"ls -la assets/js/lenis.min.js && file assets/js/lenis.min.js\"
   bash -c \"sha256sum assets/js/lenis.min.js\"
   bash -c \"grep -l 'unpkg.com/lenis' *.html blog/*.html || echo 'OK aucune référence unpkg'\"
   bash -c \"grep -l '/assets/js/lenis.min.js' *.html blog/*.html\"

6. Cohérence des fichiers modifiés via git :
   bash -c \"git status --short\"
   Lister tous les fichiers modifiés et confirmer qu'ils correspondent au périmètre Sprint 1B :
     - 16 fichiers HTML (CTAs + Lenis + encodage index.html)
     - rgpd-confidentialite.html (résidu RGPD)
     - assets/js/lenis.min.js (NEW)
   Aucun fichier inattendu (pas de modification à analytics.js, _headers, fonts/, etc.).

7. Intégrité non-régression :
   - bash -c \"grep -c 'data-cookie-preferences' *.html blog/*.html\" → toujours 1 par page (Sprint 1A préservé)
   - bash -c \"grep 'googletagmanager.com\\|clarity.ms' _headers\" → CSP toujours présente (Sprint 1A préservé)
   - bash -c \"grep 'ccdev_cookie_consent_v1' assets/js/analytics.js\" → analytics.js intact

LIVRABLE PRINCIPAL :
Crée _audit-reports/sprint1b-hygiene-rapport.md qui consolide :

  ## Sprint 1B — Hygiène technique + résidu RGPD — Rapport final

  ### Périmètre traité
  - 27 CTAs href=\"#\" : tri par contexte appliqué
  - 3 résidus RGPD ajoutés à rgpd-confidentialite.html
  - Encodage Assistant WhatsApp dans index.html corrigé
  - Font Perplexity : statut [trouvée et supprimée / orpheline documentée]
  - Lenis bundlé localement avec checksum SHA-256

  ### Hors périmètre (sprints à venir)
  - Audit licences fonts Brandon / Morena (sujet juridique séparé)
  - CTAs href=\"#\" R1/R5 résiduels documentés (décision manuelle Cyril)

  ### Fichiers modifiés
  Lister précisément.

  ### Résultats des 7 tâches de validation
  Statut OK / KO / À VÉRIFIER pour chacune avec preuve.

  ### Tests manuels à effectuer par Cyril
  1. Ouvrir index.html en local → cliquer sur un CTA \"Réserver un audit\" → la modale Cal.com doit s'ouvrir.
  2. Vérifier les sections Assistant WhatsApp IA → les accents sont corrects.
  3. Vérifier que le smooth-scroll fonctionne (Lenis chargé en local).
  4. Lire la section Cookies de rgpd-confidentialite.html → mention DPF / 14 mois / 90 jours présentes.
  5. Tester le bandeau RGPD du Sprint 1A → toujours fonctionnel (non-régression).

  ### Limites et points d'attention
  - Si certains CTAs R1 (JS attaché) n'ont pas de e.preventDefault() dans leur handler JS existant, le scroll-to-top peut encore se produire. Documenté dans rapport lot 1.
  - Lenis : si la version 1.1.18 a un bug ou est dépréciée, prévoir un upgrade dans un sprint séparé.
  - Sprint Audit licences fonts à planifier (Brandon Grotesque ~120-300€ webfont licence ou remplacement open-source type Inter).

  ### Commandes de vérification post-déploiement
  Bloc bash :
    curl -sS https://ccdeveloppement.eu/ | grep -c 'data-cal-link' (doit être > 0)
    curl -sS https://ccdeveloppement.eu/assets/js/lenis.min.js | head -c 100 (doit retourner du JS)
    curl -sS https://ccdeveloppement.eu/ | grep -E 'Réservations|Réponses' (doit retourner les chaines accentuées)

  ### Référence des rapports détaillés
  - sprint1b-lot1-ctas-rgpd.md
  - sprint1b-lot2-encodage-fonts.md
  - sprint1b-lot3-lenis.md

  ### Sprint suivant
  Plus de sprint correctif urgent. Roadmap restante :
  1. Audit licences fonts (sujet juridique)
  2. Page produit Assistant WhatsApp IA (sprint produit)
  3. Google Business Profile + NAP + backlinks locaux (sprint SEO off-site)
  4. Mesure Core Web Vitals baseline (Lighthouse)

NE MODIFIE AUCUN FICHIER DE PRODUCTION dans ce lot. C'est exclusivement de la validation et du reporting." --dangerously-skip-permissions

# -----------------------------------------------------------------------------
# Synthèse finale
# -----------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "  SPRINT 1B TERMINÉ"
echo "============================================================"
echo ""
echo "Branche Git : $(git rev-parse --abbrev-ref HEAD)"
echo ""
echo "Rapports générés dans $REPORTS_DIR :"
echo "  - sprint1b-lot1-ctas-rgpd.md"
echo "  - sprint1b-lot2-encodage-fonts.md"
echo "  - sprint1b-lot3-lenis.md"
echo "  - sprint1b-hygiene-rapport.md  (rapport final consolidé)"
echo ""
echo "ÉTAPES MANUELLES :"
echo "  1. Lire _audit-reports/sprint1b-hygiene-rapport.md"
echo "  2. git diff pour relecture complète"
echo "  3. Tester en local : index.html, modale Cal.com, smooth-scroll, bandeau RGPD non-régressé"
echo "  4. Si OK : git commit + push + deploy + purge cache Cloudflare"
echo "  5. Test post-deploy : curl -sS https://ccdeveloppement.eu/ | grep data-cal-link"
echo ""
echo "Ne reste alors que les sprints non-correctifs :"
echo "  - Audit licences fonts (juridique)"
echo "  - Page produit Assistant WhatsApp IA"
echo "  - SEO off-site (GBP + NAP + backlinks)"
echo "  - Lighthouse baseline"
echo ""
