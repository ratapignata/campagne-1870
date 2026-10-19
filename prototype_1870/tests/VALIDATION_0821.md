# v0.8.21 — chariots, routes et QG distincts

## Changements

Les caisses sont remplacées par des icônes vectorielles de chariots bâchés à roues. Les deux dépôts de chaque camp restent fixes : pas de nouvelle unité logistique ni de manipulation supplémentaire. Les quatre points sont reliés au réseau routier existant par des chemins d'hexagones adjacents ; le réseau est connexe et aucune route n'ajoute de passage à travers une rivière sans pont. Les routes servent au déplacement ; la liaison de ravitaillement reste possible par les autres terrains praticables, selon les règles v0.8.20.

Un pion QG distinct est ajouté à chaque camp, sans supprimer de régiment : 7 unités par camp. Effectif d'essai de 150 hommes, 4 PA, fusil national, coût de tir 2 PA, base de pertes 16 contre 110 pour le régiment (environ 15 % dans des conditions identiques). Riposte avec le budget de réaction normal, y compris sans PA disponibles. Assaut/défense utilisent les effectifs réels et les règles habituelles. L'escorte reste en ligne, sans bouton de formation. Pas de résistance artificielle supplémentaire.

Tous ces effectifs, positions et valeurs sont des ADAPTATIONS GAMEPLAY pour les manœuvres fictives. Ils ne constituent pas un ordre de bataille historique. Le QG se déplace et se sélectionne comme les autres unités. Icône avec drapeau et lettres QG ; pas de numéro superposé au drapeau. Le brouillard identifie un QG uniquement lorsque le contact est identifié ; l'effectif exact devient connu à l'adjacence. Les cartes de commandement ennemies restent exclues de l'observation de l'IA.

Le QG est seul à assurer le commandement de sa formation : rayon de 10 hexagones, 12 pour la cavalerie, par chemin. Déroute ou destruction coupent la liaison sans transfert vers un régiment ; le ralliement du QG rétablit immédiatement le commandement si le chemin le permet. La perte de liaison ne retire pas de PA, n'empêche ni déplacement ni tir et ralentit seulement la récupération automatique de désorganisation. L'IA recherche une position de soutien en retrait de ses propres troupes ; elle n'utilise que les ennemis observés.

## Sauvegardes

Nouveaux emplacements save_classic_v0821.json et save_three_v0821.json. Les packs exacts v0.8.20 sont conservés dans legacy0820.json et legacy_three0820.json pour continuer les anciennes parties avec leurs 12 unités et anciennes routes. Commencer une nouvelle bataille pour obtenir les QG distincts et les routes des chariots. Identifiant Android et certificat inchangés : installation en mise à jour sans désinstallation.

## Validation

Godot 4.5.1 headless :
- test_hq0821.gd : 144/144. Données des deux scénarios, arêtes routières adjacentes, ponts, connexité des dépôts, puissance comparée, tir/riposte, rupture et ralliement réel du QG, sauvegarde exacte d'un QG détruit, déplacement/annulation, contacts sous brouillard, observation de l'IA et décisions aux trois difficultés.
- test_hq0821_ui.gd : 12/12. Fiches, 150 hommes, 4 PA, sélection/désélection, absence de changement de formation, description des chariots, aide et reprise des deux sauvegardes v0.8.20.
- test_trial0821_ui.gd : 11/11. Deux camps, deux scénarios, sauvegardes distinctes, sélection et relancement.

Une vérification de parcours IA a permis de corriger le cas d'une destination de soutien du QG qui n'est pas un objectif de victoire. Le test d'interface compare les PA avec leur libellé réel, qui comporte des espaces.

Partie automatique finale : TRIAL medium: 6/6 decisions=276 ms=107308 scores=[42, 18] result=minor_win. Les deux camps ont été joués par l’IA à partir de leurs observations filtrées, sans erreur de script. Sauvegarde finale rechargée à l’identique. Une seule graine, niveau Moyen ; les décisions initiales des trois niveaux ont aussi été vérifiées dans le test ciblé.

Signatures Android v2/v3 et alignement 16 Ko vérifiés. Inspection des deux packs dans l’APK : 14 unités, deux QG distincts, quatre chemins routiers de ravitaillement. Les anciens packs sont conservés octet pour octet.

## Android et limites

Version 0.8.21, code 34, package org.woerth1870.prototype.v02. APK compilé avec Godot 4.5.1, JDK 17 et build-tools 35.0.0. La clé de signature est conservée et exclue de l'APK.

Pas d'installation sur appareil Android ni d'émulateur. Contrôles d'interface en headless : lisibilité réelle des icônes et commandes tactiles à confirmer sur téléphone. Un match automatisé n'est pas une preuve d'équilibrage. La carte historique de l'atelier reste séparée des scénarios de manœuvres.
