# Validation — prototype 0.8.7

30 septembre 2026. Effectifs exacts après engagement rapproché ; suppression hors de vue.

## Vérifications réalisées

- 35/35 contrôles du moteur : les deux camps, tir adjacent et riposte, survie exacte
  après pertes, puissance calculée comme celle des unités amies, assaut et charge,
  simple proximité et visée sans révélation, tir distant sans révélation,
  actualisation tant que l’ennemi est observé, effacement à la perte de vue,
  absence de suivi des pertes cachées, réapparition sans restitution automatique,
  nouvelle révélation après un autre combat, sauvegarde/reprise et données invalides.
- 10/10 contrôles tactiles à 1280 × 720 : sélection, premier appui sans révélation,
  second appui déclenchant le tir et la riposte, chiffre du pion et fiche exacts,
  PA ennemis toujours cachés, ancien contact sans chiffre et réapparition avec ?.
  Deux captures inspectées : effectif exact et contact perdu.
- Régression reconnaissance : 41/41. Inclut deux mondes différents seulement par
  des informations cachées donnant les mêmes observations et décisions d’IA,
  sauvegarde exacte et bataille IA complète (145 décisions, environ 17,5 s ici).
- Régression tir intercepté/retour hors de vue : 7/7.
- Parcours applicatif de compatibilité à 1520 × 720 : 19/19, reprise d’une partie
  0.8.5, charge à 2 PA, nouvelle partie avec brouillard, sauvegarde/redémarrage,
  fiches, journal et jeu du camp prussien.
- Comparaison avec l’archive livrée 0.8.6 : les trois packs de scénario sont
  strictement identiques. L’empreinte de sauvegarde et le fichier save_v086.json
  sont conservés. Les champs exacts sont optionnels pour lire les anciennes parties.

La connaissance des effectifs se partage dans le camp ; l’IA reçoit le chiffre
exact selon la même règle que le joueur. Les révélations temporaires d’un tireur
ne suffisent pas à conserver un effectif exact lorsque l’observation visuelle cesse.
Une fiche de contact perdu ne montre ni effectif exact ni estimation mémorisée.
L’estimation de reconnaissance reste disponible avant un engagement rapproché.

## Limites

Tests sur ordinateur avec événements tactiles simulés et rendu logiciel, sans
appareil ni émulateur Android. Lisibilité, performances, batterie et sons sur
smartphone restent à vérifier par le joueur. Aucun changement d’équilibrage,
de pertes ou de victoire dans cette version. L’exercice reste fictif.

## Export Android

Version 0.8.7, code 20, paquet org.woerth1870.prototype.v02. Même clé de développement.

Signatures v2/v3 vérifiées ; certificat identique à 0.8.6. API minimum 24, cible 35.
Packs, textes et crédits comparés octet par octet dans l’APK. Moteur et module
de reconnaissance compilés présents. Tests, captures et clé exclus de l’application.

Taille : 87610515 octets.
SHA-256 : `977a5c63a2411c530b0a7f9f544b6708699999a4dc3c69f052dc0c6656f07b7c`.
