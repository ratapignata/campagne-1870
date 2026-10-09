# v0.8.20 — QG et liaisons

## Périmètre livré

Les deux scénarios de manœuvres restent fictifs et conservent les unités, la carte, les combats et le calcul de victoire de la v0.8.19. Le chantier de la carte historique reste séparé.

Nouvelles parties : un QG fixe par formation, intégré à une unité existante. L'infanterie n°1 porte initialement le QG de chaque camp. Rayon par chemin : 10 hexagones pour infanterie/artillerie, 12 pour cavalerie. Aucun coût supplémentaire d'activation. Transfert si le porteur est détruit ou en déroute ; une simple désorganisation ne suffit pas. Priorité à une infanterie survivante, puis à une autre unité. Le retour du premier porteur ne lui rend pas automatiquement le QG.

L'ennemi bloque sa case et, hors déroute, les cases voisines non défendues par une unité amie. Les détours sont permis dans le rayon. Les communications et les approvisionnements franchissent les rivières par les ponts : choix de gameplay explicite, configurable, expliqué dans l'aide. Les gués d'infanterie restent disponibles pour le déplacement mais ne suffisent pas à faire passer la liaison logistique. Pas de réparation, chariot ni nouveau pion à activer.

Ravitaillement par un chemin sans limite de longueur vers au moins une des deux zones arrière, marquées de caisses. Trois niveaux de munitions conservés. Les réserves présentes ne disparaissent pas en cas de coupure. La récupération reste automatique, après un tour sans attaque volontaire, hors déroute et avec liaison maintenue ; une interruption est mémorisée pendant le cycle. Le commandement n'enlève pas de PA : seule la récupération spontanée de désorganisation est divisée par deux ; rallier coûte 2 PA.

Liaisons recalculées après déplacement/combat et changement de tour. Les données de commandement ennemies sont retirées de l'observation de l'IA. Les repères QG ne sont dessinés que pour son propre camp. Toucher Cmd./Ravit. ouvre une explication. Un transfert du QG affiche un message bref. Le tir conserve deux appuis : indication textuelle de possibilité/blocage au premier, confirmation au second. Aucun tracé de ligne de tir ni surlignement d'obstacle ajouté.

## Sauvegardes

Nouveaux emplacements : save_classic_v0820.json et save_three_v0820.json. Reprise des anciens emplacements avec leurs packs exacts legacy0819.json et legacy_three0819.json. Les empreintes des deux packs conservés sont identiques aux octets des sources livrées v0.8.19. Les parties précédentes gardent leurs anciennes règles ; démarrer une nouvelle bataille active les changements.

L'identité du QG et les états de liaison sont sauvegardés. La distance de commandement est normalisée en entier à la reprise, y compris pour les unités détruites. Ce dernier cas a été corrigé après un premier test de sauvegarde et vérifié à nouveau.

## Tests

Godot 4.5.1, exécution headless :
- test_support0820.gd : 29/29. Limites 10/12, QG stable, transfert/ralliement/destruction, ponts, coupure et détour, corridor ami, absence de ZOC d'un ennemi en déroute, confidentialité de l'IA, pénalités, sauvegarde exacte avec unités détruites, annulation de déplacement, anciens packs.
- test_ui0820.gd : 14/14. Informations de liaison, absence de fiche logistique ennemie, zones arrière, tir bloqué dès le premier appui sans consommation au second, tir valide après confirmation, notification unique, anciennes sauvegardes des deux scénarios.
- test_trial0820_ui.gd : 11/11. Sélecteur, France/Prusse, sauvegardes séparées, changement de scénario et relancement.
- test_support0813.gd : 59/59. Non-régression des règles anciennes de munitions et ravitaillement.

Parties automatisées, même scénario à trois objectifs et une graine par difficulté :
- Facile : bataille terminée, 203 décisions légales, scores de durée [30,30]. Le premier essai a détecté une différence de type entier/décimal dans les distances sauvegardées des unités détruites ; correction validée ensuite par le test de sauvegarde ciblé (29/29). La partie complète Facile n'a pas été rejouée après cette correction.
- Moyen : 6/6, 254 décisions, bataille terminée, scores de durée [40,20], sauvegarde finale exacte.
- Difficile : 6/6, 261 décisions, bataille terminée, scores de durée [43,17], sauvegarde finale exacte.

Ces matchs vérifient la progression et la validité des actions, pas la force relative des camps ou des difficultés.

## Compilation

APK Android Godot 4.5.1, JDK 17, build-tools 35.0.0. VersionCode 33, versionName 0.8.20, package org.woerth1870.prototype.v02. Même certificat de développement que la version précédente. Signatures v2/v3 et alignement 16 Ko vérifiés. Packs actifs inspectés dans l'APK : 10/12, QG et ponts activés. Clé de développement exclue de l'APK.

## Limites

Aucun appareil Android ni émulateur utilisé. Contrôle des rectangles et interactions en headless, sans validation visuelle du rendu. Lisibilité des petits repères, ouverture tactile des explications, temps de réponse de l'IA, reprise après interruption et équilibre à vérifier sur le téléphone du joueur. Les tests automatisés ne prouvent pas l'équilibrage historique.
