# Sprint 1B — LOT 2/4 : Encodage WhatsApp + Font Perplexity

**Date** : 2026-05-04
**Branche** : `sprint1b-hygiene-technique`
**Périmètre** : `index.html` section Assistant WhatsApp IA + recherche font orpheline
**Statut** : ⚠️ **Partie A annulée post-hoc** (revert manuel) — Partie B documentée comme énigme

---

> ## ⚠️ MISE À JOUR POST-HOC (2026-05-04 ~9h00)
>
> La Partie A (réparation encodage WhatsApp) a été **revertée manuellement** après livraison du Sprint 1B.
>
> **Raison** : la police **Morena** (utilisée pour les titres de la section WhatsApp et certains textes de feature) **ne contient pas les glyphes accentués**. Cyril avait délibérément retiré les accents pour éviter le rendu cassé / glyphes manquants.
>
> **Action** : les 11 lignes "corrigées" ont été restaurées à leur version sans accents (Réservations → Reservations, gérer → gerer, etc.). Tous les autres lots (CTAs Cal.com, RGPD résidu, Lenis local) sont conservés.
>
> **Leçon pour les futurs sprints** : avant de "réparer" un encodage, **toujours vérifier la police active** sur la zone concernée. Le mojibake apparent peut être un choix volontaire de typographie.
>
> **Action de fond ouverte** : remplacer Morena par une police équivalente avec support des accents français (sujet du sprint "audit licences fonts").

---

---

## PARTIE A — Réparation encodage section WhatsApp

### Contexte

L'audit Sprint 0 avait détecté des accents perdus dans la section Assistant WhatsApp IA
(`#assistant`, lignes ~1793-1839 de `index.html`). Le reste du site est correctement accentué.
Cause probable : copier-coller d'un éditeur tiers (note, Slack, doc) qui a stripé les diacritiques.

### Vérifications préalables

| Vérif | Résultat |
|-------|----------|
| Encodage source du fichier | `text/html; charset=utf-8` (validé via `file --mime`) |
| Validité UTF-8 du contenu binaire | OK (Python `bytes.decode('utf-8')` sans erreur) |
| Présence d'un BOM | Non (correct pour HTML) |
| Mojibake résiduel (Ã©, Ã¨, Ã¢, Ã®, Ã´, Ã») | Aucun (grep vide) |

Le fichier était donc **bien en UTF-8** : les accents n'étaient pas corrompus
par un mauvais encodage, ils étaient **simplement absents du texte source**.

### Corrections appliquées (uniquement section `#assistant`)

| Ligne | Avant | Après |
|------:|-------|-------|
| 1798 | `Il gere vos reservations, repond a vos clients` | `Il gère vos réservations, répond à vos clients` |
| 1802 | `Reservations automatiques` | `Réservations automatiques` |
| 1803 | `Vos clients reservent directement … L'assistant gere les creneaux` | `Vos clients réservent directement … L'assistant gère les créneaux` |
| 1807 | `Posts reseaux sociaux` | `Posts réseaux sociaux` |
| 1808 | `Generez vos publications … timing optimises` | `Générez vos publications … timing optimisés` |
| 1813 | `Suivi et reponses aux avis clients … propose des reponses adaptees` | `Suivi et réponses aux avis clients … propose des réponses adaptées` |
| 1817 | `Resume matinal` | `Résumé matinal` |
| 1818 | `reservations du jour, taches, meteo, evenements locaux` | `réservations du jour, tâches, météo, événements locaux` |
| 1822 | `Reponses clients 24/7` | `Réponses clients 24/7` |
| 1823 | `L'assistant repond aux questions frequentes … meme en dehors` | `L'assistant répond aux questions fréquentes … même en dehors` |
| 1828 | `Statistiques de frequentation, reservations` | `Statistiques de fréquentation, réservations` |

**Périmètre strictement respecté** : aucune autre zone du fichier n'a été modifiée.
Les autres mentions de `Réservation`, `WhatsApp`, etc. ailleurs dans `index.html` étaient
déjà correctement accentuées (ex. ligne 1849 `Réserve ton audit gratuit`, ligne 1852 `WhatsApp (réponse rapide)`).

### Vérification finale

Commande exécutée :

```bash
grep -nE 'Reservation|Reponse|frequentation|reseaux sociaux|Resume matinal|reservent|Generez|evenements|taches|meteo' index.html
```

Résultat : **`No matches found`** (toutes les variantes non accentuées ont disparu).

Re-vérification post-édition :
- `file --mime index.html` → `text/html; charset=utf-8`
- Contrôle Python `bytes.decode('utf-8')` → OK, fichier toujours UTF-8 valide
- Grep mojibake (Ã suivi de caractère diacritique) → aucun match

---

## PARTIE B — Font Perplexity orpheline (best-effort, 10 min)

### Contexte

L'audit Sprint 0 (`_audit-reports/sprint0-audit-terrain.md` ligne 93) signale un appel réseau orphelin :

```
https://frontend-cdn.perplexity.ai/_agi_assets/fonts/FKGroteskNeue.woff2
```

Cet appel retourne **503 en production**, sans bloquer le rendu, mais reste sale
côté observabilité. Sprint 0 mentionnait : « non trouvé dans le code source ».

### Recherches effectuées

#### 1. Grep brut tous fichiers (hors `.git` et `node_modules`)

```bash
grep -rIn 'perplexity\|FKGroteskNeue' . \
  --exclude-dir=.git --exclude-dir=node_modules
```

**Résultats** : seules occurrences = scripts d'audit Sprint 0/1B et leurs rapports.

| Fichier | Type |
|---------|------|
| `scripts/run-sprint0-audit.sh` | Script d'audit (le détecteur lui-même) |
| `scripts/run-sprint1b-hygiene.sh` | Script du sprint courant (mentionne le problème) |
| `_audit-reports/sprint0-audit-terrain-raw.md` | Sortie brute de l'audit |
| `_audit-reports/sprint0-audit-terrain.md` | Rapport synthétique |

**Aucune occurrence dans le code source livré** : ni HTML, ni CSS, ni JS, ni JSON, ni service worker.

#### 2. Recherches ciblées dans les fichiers les plus suspects

| Fichier | Vérifié | Référence trouvée ? |
|---------|---------|---------------------|
| `assets/js/analytics.js` | ✅ | ❌ |
| `assets/js/smooth-scroll.js` | ✅ | ❌ |
| `assets/css/*` (tous CSS, y compris minifiés) | ✅ | ❌ |
| `manifest.json` (si présent) | ✅ — n'existe pas | ❌ |
| `sw.js` (service worker) | ✅ — n'existe pas | ❌ |
| Attributs `style=` inline dans tous les HTML | ✅ | ❌ |

#### 3. Vérification de l'extension du grep aux assets binaires

Le grep avec flag `-I` exclut les binaires, mais aucun WOFF2 / OTF du repo ne référence Perplexity.

### Conclusion : énigme non résolue (ne pas dépasser 10 min)

**Statut** : font Perplexity introuvable dans le code source actuel du repo.

**Hypothèses retenues (par ordre de probabilité)** :

1. **Référence morte dans un cache navigateur ancien**
   → cookie/cache local d'un visiteur historique, requête déclenchée par un Service Worker
   tiers ou par une extension navigateur (ex. extension "Perplexity Companion")
   qui injecte ses propres assets dans toutes les pages visitées.
   → Probabilité : **élevée**, surtout si l'audit a été lancé via Comet (extension anti-tracking)
   ou un navigateur contenant l'extension Perplexity.

2. **Injection par un script tiers chargé en runtime**
   (ex. widget cal.com, snippet GA4, tag Clarity ayant chargé une font tierce)
   → Probabilité : **faible** — les requêtes des tags Cal/GA4/Clarity ont été tracées au Sprint 0
   sans appel vers `perplexity.ai`.

3. **Vestige d'un copier-coller de prototype Perplexity**
   (snippet HTML/CSS généré par Perplexity lors d'une recherche, recopié dans une ancienne version
   du site puis nettoyé sans purger toutes les références)
   → Probabilité : **faible** — `git log -S 'perplexity'` ne ramène rien dans l'historique git
   (seul le script d'audit récent introduit le mot).

**Action retenue pour Sprint 1B** : **NE RIEN MODIFIER**.
Aucun fichier du repo ne contient cette référence ; toute « suppression » serait fictive.

**Action recommandée hors Sprint 1B** :
1. Reproduire le 503 dans un **profil navigateur neuf, sans extensions** (Safari/Chrome navigation privée, profil propre).
   Si la requête disparaît → confirmation hypothèse 1 (extension/cache local), aucun nettoyage repo nécessaire.
2. Si la requête persiste sur profil propre → inspecter Network DevTools onglet « Initiator »
   pour identifier le script qui la déclenche (probablement un tiers chargé après acceptation cookies).
3. En dernier recours : ajouter une CSP `font-src` restrictive pour bloquer toute font hors `self` et providers attendus.

---

## Récapitulatif Lot 2

| Tâche | Statut | Détail |
|-------|--------|--------|
| Encodage section WhatsApp | ✅ Terminé | 11 lignes corrigées, 0 mojibake, UTF-8 préservé |
| Recherche font Perplexity | ⚠️ Documenté | Référence absente du repo, énigme cache navigateur / extension |
| Périmètre respecté | ✅ | Aucune autre zone d'`index.html` modifiée, aucun autre fichier touché |
| Vérifications post-édit | ✅ | `file --mime`, grep mojibake, grep accents manquants tous passés |

**Prochain lot** : Lot 3/4 — Lenis (smooth scroll).
