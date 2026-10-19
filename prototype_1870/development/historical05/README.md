# Atelier historique 05 — Sauer

Ajout de préparation après v0.8.13. Aucune nouvelle version Android livrée.

`war_engine/core/edge_navigation.gd` calcule des itinéraires avec terrains et franchissements. Le module est testé indépendamment, mais n’est pas encore branché aux déplacements, assauts, retraites, ravitaillement, IA ou sauvegardes de la bataille. Ne pas activer le scénario historique dans le menu avant ces intégrations.

`sector.json` couvre 255 cases dans la grille validée de 600 cases. Les autres cases sont inactives, sans terrain inventé. Les positions d’arêtes, la classification des terrains, les coûts et niveaux de relief sont des ADAPTATIONS GAMEPLAY. Le recalage historique reste approximatif (RMS du dossier 02 : environ 267 m).

Les passages C2 et C3 sont représentés ici par deux arêtes voisines ; leur secteur est proche à cette échelle. Ne pas interpréter ces arêtes comme des coordonnées géographiques précises. Les réparations ultérieures restent à dater ; pas de pontons inventés.

Tests : Godot 4.5, `--headless --path . --script tests/test_historical05.gd`. 1475 assertions, essentiellement de voisinage, et contrôles fonctionnels de franchissement, budget, fermeture, continuité et arrêt au gué. Ce total ne correspond pas à 1475 scénarios indépendants.

L’outil HTML autonome réplique le calcul pour examen visuel ; les résultats de référence sont comparés au module Godot. Ce n’est pas une partie jouable : ni combat, ni unités de l’ordre de bataille, ni brouillard, ni états tactiques complets.
