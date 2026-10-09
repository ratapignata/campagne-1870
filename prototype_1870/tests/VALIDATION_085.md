# Validation — prototype 0.8.5

30 septembre 2026. Cavalerie montée et charge dans l’exercice fictif.

## Règles

- 41/41 contrôles dédiés cavalerie : deux camps, coûts selon terrain, mouvement et
  annulation, impossibilité de tirer/se retrancher/changer de formation, charge
  adjacente et coût, feu défensif, pertes bilatérales, recul, prise d’objectif,
  état valide et sauvegarde. Une bataille IA contre IA de six tours se termine,
  sans commande rejetée ni état invalide. Scénarios ciblés d’IA : évite une ligne
  intacte, charge une infanterie affaiblie et désorganisée.
- Régressions : échanges/assauts 45/45 ; formations 39/39 ; positions/résultats 34/34.
- Migration 0.8.1 : 32/32 sur le pack archivé `legacy084.json`. Le test historique
  cible ce pack à dix unités, et non le nouveau scénario à douze unités.

## Interface et reprise

- Suite tactile générale : 179/179 à 1280 × 720, y compris formations, artillerie,
  assaut, ralliement, retranchement, annulation, confirmations et appuis longs.
- Contrôles tactiles dédiés : 22/22 à 1280 × 720 ; 23/23 au format
  1520 × 720, dont la reprise au redémarrage de la nouvelle sauvegarde.
- Démarrage réel sur une sauvegarde 0.8.4 : reprise des dix unités, PA et formations
  inchangés. Nouvelle partie : douze unités et nouveau fichier de sauvegarde.
- Contrôle visuel des captures : pion cavalier, fiche, confirmation et résultat de
  charge, carte initiale. L’aide utilise le panneau défilant existant.

## Limites

Tests exécutés sur ordinateur, rendu OpenGL logiciel et événements tactiles
simulés. Aucun essai sur téléphone ou émulateur Android dans cet environnement.
Il reste à vérifier la lisibilité, les sons, la durée, la batterie et l’équilibre
sur appareil. La partie IA contre IA confirme le fonctionnement, pas l’équilibre.
Les silhouettes, effectifs, placement et coefficients sont des adaptations de jeu.
Pas de brouillard/reconnaissance ni de trois difficultés dans cette livraison.
Le son de charge réutilise le son d’assaut ; aucun nouveau son historique annoncé.

## Export Android

APK debug signé : `org.woerth1870.prototype.v02`, version 0.8.5, code 18.
Signature v2/v3 vérifiée, même certificat que 0.8.4. API minimum 24, cible 35 ;
ARMv7, ARM64 et x86_64. Aucune permission Internet. Packs courant et précédent,
textes et crédits vérifiés dans l’APK ; moteur compilé présent. Tests, captures
et clé de développement exclus. Carte, règles précédentes, dix unités d’origine
et armements comparés exactement à l’archive 0.8.4 et conservés.

Taille : 87589796 octets.
SHA-256 : `9571d36bf5b6bb4d110fe42629e177fb1dadf848432aa1b2c06ad02cb42eb29a`.
