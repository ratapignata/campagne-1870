# Essai graphique № 12 — lisibilité des pions, carte, fiche et journal

Version `0.8.43.15-g2d12`, 31 octobre 2026. Branche `v43-graphismes-2d-experimental`, base essai 11 (`914265f`). Essais précédents conservés dans leurs commits/livraisons ; stable/main préservées.

## Quatre retouches approuvées

1. **Pions** : même disque de rayon 7,4 unités de dessin, mêmes bordures fines et emplacements fixes pour les états. Coche en haut à droite `(18,-18)`, désorganisation D ou déroute » en haut à gauche `(-18,-18)`, retranchement à droite `(18,3)`. Le chiffre de force reste en bas. Les illustrations historiques et la distinction une/deux silhouettes sont conservées. Les contacts ennemis utilisent toujours exclusivement les états connus autorisés ; aucun nouvel indicateur ennemi.
2. **Carte au dézoom** : illustrations de forêts et villages adoucies progressivement entre les zooms 0,45 et 0,95. Un seul petit atlas 192 × 128, dérivé une fois au démarrage des illustrations existantes, est réutilisé. Les mêmes contours d’hexagones, couleurs de fond, routes, rivière, ponts, relief, localités et coordonnées sont conservés. À partir du zoom 0,95, les décors détaillés précédents sont identiques. Pas d’éclairage, de shader coûteux ou de nouvelle dépendance.
3. **Fiche d’unité** : surbrillance or discrète de 0,85 seconde sur les effectifs, les PA et l’état moral lorsqu’une valeur déjà affichée change pour la même unité du joueur. Première consultation, changement d’unité, chargement d’une partie et fiche ennemie ne déclenchent aucun signal. L’effet est décoratif, sans interception tactile ni déplacement de texte ; il s’arrête sans interrogation continue de l’état du jeu. Les couleurs tactiques et les mots restent lisibles.
4. **Journal** : fin liseré coloré à gauche des entrées et icônes coordonnées. Combats terre cuite, redditions ivoire, objectifs or, renforts bleu clair. Les intitulés, icônes, textes, filtres, horaires, informations connues et défilement restent présents : la couleur n’est jamais la seule indication.

## Conservation du jeu

Aucun changement de moteur, IA Normal/Difficile, règles, scénarios, géographie, renforts, sauvegardes ou animations de combat. Charge 2 PA, ripostes, commandement/ravitaillement, isolement/reddition, QG Raoult, variante B, 20 tours, objectifs 3/2/1 et score 60/20/20 conservés. Aucun bouton TIRER. La coche conserve exactement sa logique de l’essai 10 : aucune action active légale disponible, même avec PA restants ; une possibilité retrouvée fait disparaître la coche.

Bandeau supérieur, cadre horaire centré, dimensions et disposition de la fiche inférieure gauche et des commandes centrales conservés. Aucun bouton ajouté, supprimé, renommé ou déplacé.

## Installation et sources

Installer `1870_V43_Graphismes_2D_Experimental_12.apk` par-dessus l’essai précédent **sans désinstaller**, pour conserver la partie. Même application expérimentale, paquet et certificat ; code Android 12. Application stable séparée. Aucune intégration à main.

Archive `1870_V43_Graphismes_2D_Experimental_12_Sources.zip` : code complet, ressources, tests, rapports et preuves courantes ; caches/compilations exclus, anciennes galeries 1 à 11 non dupliquées, toujours disponibles dans les livraisons précédentes. Galerie : `captures/graphismes2d12/README.md`. Résultats : `TESTS_GRAPHISMES_2D.md`. Liste complète : `FICHIERS_GRAPHISMES_2D.txt`.

## Validation et limites

5 006 assertions distinctes dans la campagne ciblée, captures réelles Godot 4.5.1/Linux, APK compilé et signature vérifiée. Aucun essai physique ou émulateur Android, aucune nouvelle simulation complète de bataille. Les mesures de rendu logiciel jointes ne valident pas la fluidité sur smartphone. Archive indépendante : voir le rapport de tests.
