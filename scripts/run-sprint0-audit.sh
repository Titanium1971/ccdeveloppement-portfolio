#!/usr/bin/env bash
#
# Sprint 0 — Audit terrain ccdeveloppement.eu
#
# Usage :
#   chmod +x scripts/run-sprint0-audit.sh
#   ./scripts/run-sprint0-audit.sh
#
# Sortie : _audit-reports/sprint0-audit-terrain-raw.md
#
# Ce script collecte les preuves brutes (curl headers, grep dans le repo,
# inventaire fichiers). Il ne modifie aucun fichier du site.
#
# À exécuter à la racine du repo portfolio.

set -euo pipefail

REPORT_DIR="_audit-reports"
REPORT="$REPORT_DIR/sprint0-audit-terrain-raw.md"
mkdir -p "$REPORT_DIR"

DOMAIN="ccdeveloppement.eu"
URLS_TEST=(
  "https://www.${DOMAIN}/"
  "https://www.${DOMAIN}/devis"
  "https://www.${DOMAIN}/devis?source=test"
  "https://${DOMAIN}/"
  "https://${DOMAIN}/devis"
  "https://${DOMAIN}/tarifs"
  "https://${DOMAIN}/estimateur"
  "https://${DOMAIN}/creation-site-web-agde"
  "https://${DOMAIN}/seo-local-herault"
  "https://${DOMAIN}/guide-seo-local"
  "https://${DOMAIN}/rgpd-confidentialite"
)

PAGES_LOCAL=(
  "index.html"
  "tarifs.html"
  "devis.html"
  "estimateur.html"
  "creation-site-web-agde.html"
  "seo-local-herault.html"
  "guide-seo-local.html"
  "rgpd-confidentialite.html"
  "blog/index.html"
)

# ---- LOT 1/6 — Redirections HTTP ---------------------------------------------
echo "[LOT 1/6] Redirections HTTP..."

{
  echo "# Sprint 0 — Audit terrain CC Développement (raw)"
  echo
  echo "Date : $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo "Hôte testé : $DOMAIN"
  echo "Repo : $(pwd)"
  echo
  echo "---"
  echo
  echo "## 1. Redirections HTTP"
  echo
  for url in "${URLS_TEST[@]}"; do
    echo "### $url"
    echo '```'
    curl -sSIL --max-time 20 -A "audit-bot/1.0" "$url" | sed -n '1,30p' || echo "ERREUR curl"
    echo '```'
    echo
  done
} > "$REPORT"

# ---- LOT 2/6 — Canonical / sitemap / robots / _headers / _redirects ---------
echo "[LOT 2/6] Canonical, sitemap, robots, headers..."

{
  echo "## 2. Canonical / sitemap / robots / _headers / _redirects"
  echo
  echo "### robots.txt source (repo)"
  echo '```'
  cat robots.txt 2>/dev/null || echo "robots.txt introuvable à la racine"
  echo '```'
  echo
  echo "### robots.txt en production"
  echo '```'
  curl -sS --max-time 15 "https://${DOMAIN}/robots.txt" || echo "robots.txt inaccessible"
  echo '```'
  echo
  echo "### _redirects source (repo)"
  echo '```'
  cat _redirects 2>/dev/null || echo "_redirects introuvable"
  echo '```'
  echo
  echo "### _headers source (repo) — extrait CSP et sécurité"
  echo '```'
  if [ -f _headers ]; then
    grep -E 'Content-Security-Policy|Strict-Transport-Security|Referrer-Policy|X-Frame-Options|Permissions-Policy' _headers 2>/dev/null || echo "(aucune directive sécurité trouvée dans _headers)"
  else
    echo "_headers introuvable"
  fi
  echo '```'
  echo
  echo "### sitemap.xml — URLs déclarées"
  echo '```'
  curl -sS --max-time 15 "https://${DOMAIN}/sitemap.xml" \
    | grep -oE 'https?://[^< ]+' \
    | sort -u || echo "sitemap.xml inaccessible"
  echo '```'
  echo
  echo "### Présence d'URLs www dans le sitemap (doit être vide)"
  echo '```'
  curl -sS --max-time 15 "https://${DOMAIN}/sitemap.xml" \
    | grep -oE 'https?://[^< ]+' \
    | grep -E '://www\.' || echo "(aucune URL www — OK)"
  echo '```'
  echo
  echo "### Validation XML sitemap"
  echo '```'
  if command -v xmllint >/dev/null 2>&1; then
    curl -sS --max-time 15 "https://${DOMAIN}/sitemap.xml" \
      | xmllint --noout - && echo "sitemap.xml : XML valide" || echo "sitemap.xml : XML invalide"
  else
    echo "xmllint non installé — validation XML ignorée"
  fi
  echo '```'
  echo
  echo "### Canonical déclarées dans les fichiers HTML du repo"
  echo '```'
  grep -RInE 'rel="canonical"|rel='"'"'canonical'"'"'' . \
    --include="*.html" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude-dir=".next" \
    --exclude-dir="dist" \
    --exclude-dir="build" 2>/dev/null || echo "(pas de canonical trouvée)"
  echo '```'
  echo
  echo "### Canonical pointant vers www (ne doit rien retourner)"
  echo '```'
  grep -RInE 'rel="canonical"[^>]*www\.|rel='"'"'canonical'"'"'[^>]*www\.' . \
    --include="*.html" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" 2>/dev/null || echo "(aucune canonical en www — OK)"
  echo '```'
  echo
} >> "$REPORT"

# ---- LOT 3/6 — Scripts tiers et tracking -------------------------------------
echo "[LOT 3/6] Scripts tiers et tracking..."

{
  echo "## 3. Scripts tiers et tracking"
  echo
  echo "### Recherche dans le repo (HTML + JS)"
  echo '```'
  grep -RInE 'analytics\.js|googletagmanager|google-analytics|gtag\(|dataLayer|clarity\.ms|cloudflareinsights|formspree|sibforms|cal\.com|unpkg|wa\.me|maps\.google|perplexity' . \
    --include="*.html" \
    --include="*.js" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude-dir=".next" \
    --exclude-dir="dist" \
    --exclude-dir="build" 2>/dev/null || echo "(aucune occurrence)"
  echo '```'
  echo
  echo "### Scripts effectivement servis par la home en production"
  echo '```'
  curl -sS --max-time 20 "https://${DOMAIN}/" \
    | grep -oE '<script[^>]*src="[^"]+"' \
    | grep -oE 'src="[^"]+"' \
    | sed 's/src="//;s/"$//' \
    | sort -u || echo "(impossible d'extraire)"
  echo '```'
  echo
  echo "### Identifiants tracking détectés sur la home"
  echo '```'
  curl -sS --max-time 20 "https://${DOMAIN}/" \
    | grep -oE 'G-[A-Z0-9]{8,}|GTM-[A-Z0-9]{6,}|UA-[0-9]+-[0-9]+|clarity\.ms/tag/[a-z0-9]+' \
    | sort -u || echo "(aucun identifiant détecté inline)"
  echo '```'
  echo
  echo "### Recherche font Perplexity orpheline"
  echo '```'
  grep -RInE 'perplexity|FKGroteskNeue' . \
    --include="*.html" \
    --include="*.js" \
    --include="*.css" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" 2>/dev/null || echo "(non trouvée dans le repo — investiguer assets/js/analytics.js minifié ou origine externe)"
  echo '```'
  echo
} >> "$REPORT"

# ---- LOT 4/6 — RGPD ----------------------------------------------------------
echo "[LOT 4/6] RGPD..."

{
  echo "## 4. RGPD"
  echo
  echo "### Contenu de la page /rgpd-confidentialite (repo)"
  echo '```'
  if [ -f rgpd-confidentialite.html ]; then
    sed -E 's/<[^>]+>/ /g' rgpd-confidentialite.html \
      | tr -s ' \t\n' ' ' \
      | grep -oE '[^.]*\b(cookie|tracking|analytics|google|clarity|consentement|publicitaires|traceurs)\b[^.]*\.' \
      | head -50 || echo "(rien trouvé)"
  else
    echo "rgpd-confidentialite.html introuvable"
  fi
  echo '```'
  echo
  echo "### Recherche d'un bandeau de consentement dans la home (prod)"
  echo '```'
  HOME=$(curl -sS --max-time 20 "https://${DOMAIN}/" 2>/dev/null || echo "")
  echo "$HOME" | grep -oiE 'tarteaucitron|axeptio|cookiebot|cookieconsent|orejime|didomi|onetrust' | sort -u \
    || echo "(aucun gestionnaire de consentement détecté)"
  echo
  echo "Mots-clés cookie/consent dans le HTML servi (top 10) :"
  echo "$HOME" | grep -oiE 'cookie|consent|accepter|refuser' | sort | uniq -c | sort -rn | head -10 \
    || echo "(rien)"
  echo '```'
  echo
  echo "### Diagnostic de cohérence"
  echo
  echo "À comparer manuellement :"
  echo "- la page /rgpd-confidentialite mentionne-t-elle GA4 et Clarity ?"
  echo "- des scripts GA4/Clarity sont-ils chargés (voir lot 3) ?"
  echo "- y a-t-il un bandeau de consentement (voir ci-dessus) ?"
  echo
  echo "Si GA4 ou Clarity sont chargés ET aucun bandeau ET la politique dit qu'il n'y a pas de tracking → non-conformité."
  echo
} >> "$REPORT"

# ---- LOT 5/6 — Données structurées + OG --------------------------------------
echo "[LOT 5/6] JSON-LD + Open Graph..."

{
  echo "## 5. Données structurées (JSON-LD) — repo"
  echo
  for f in "${PAGES_LOCAL[@]}"; do
    if [ -f "$f" ]; then
      TYPES=$(
        grep -oE '"@type"[[:space:]]*:[[:space:]]*"[^"]+"' "$f" 2>/dev/null \
          | sort -u \
          | tr '\n' ',' \
          | sed 's/,$//' \
        || true
      )
      echo "- \`$f\` → ${TYPES:-(aucun)}"
    fi
  done
  echo

  echo "## 6. Open Graph / Twitter Cards — repo"
  echo
  for f in "${PAGES_LOCAL[@]}"; do
    if [ -f "$f" ]; then
      echo "### $f"
      echo '```'
      grep -oE '<meta[^>]+(property|name)="(og:[^"]+|twitter:[^"]+)"[^>]*>' "$f" 2>/dev/null \
        | head -20 \
        || echo "(aucune balise OG/Twitter)"
      echo '```'
      echo
    fi
  done
} >> "$REPORT"

# ---- LOT 6/6 — Inventaire ressources lourdes + bugs UX -----------------------
echo "[LOT 6/6] Inventaire ressources + bugs UX..."

{
  echo "## 7. Inventaire ressources lourdes (repo)"
  echo
  echo "### Polices"
  echo '```'
  find . -type f \( -iname "*.otf" -o -iname "*.ttf" -o -iname "*.woff" -o -iname "*.woff2" \) \
    -not -path "./.git/*" \
    -not -path "./node_modules/*" \
    -not -path "./.next/*" \
    -exec du -h {} \; 2>/dev/null | sort -h \
    || echo "(aucune police détectée)"
  echo '```'
  echo
  echo "### Images locales > 200 Ko"
  echo '```'
  find . -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.avif" -o -iname "*.svg" \) \
    -not -path "./.git/*" \
    -not -path "./node_modules/*" \
    -size +200k \
    -exec du -h {} \; 2>/dev/null | sort -h \
    || echo "(aucune image > 200 Ko détectée)"
  echo '```'
  echo
  echo "## 8. Bugs UX et techniques"
  echo
  echo "### CTAs morts (href=\"#\")"
  echo '```'
  grep -RInE 'href="#"' . \
    --include="*.html" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude-dir=".next" 2>/dev/null \
    | head -50 \
    || echo "(aucun href=\"# \" trouvé)"
  echo '```'
  echo
  echo "### Encodage suspect (mots sans accent dans la section Assistant WhatsApp)"
  echo '```'
  grep -RInE 'Reservation|Reponse|frequentation|reseaux sociaux|automatisee' . \
    --include="*.html" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" 2>/dev/null \
    | head -20 \
    || echo "(rien — encodage propre)"
  echo '```'
  echo
  echo "---"
  echo
  echo "**Rapport brut généré : $REPORT**"
  echo
  echo "Pour consulter le rapport analysé et priorisé, voir : _audit-reports/sprint0-audit-terrain.md"
} >> "$REPORT"

echo
echo "============================================================"
echo "Rapport brut généré : $REPORT"
echo "============================================================"
echo
echo "Étape suivante : ouvrir le rapport, comparer avec _audit-reports/sprint0-audit-terrain.md"
echo "(version analysée et priorisée), puis lancer le sprint 1 de corrections."
