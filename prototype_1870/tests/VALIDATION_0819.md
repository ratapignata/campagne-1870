# v0.8.19 — essai jouable à trois objectifs

## Livraison

APK exporté avec Godot 4.5.1, modèle Android debug officiel, build-tools 35.0.0, JDK 17. Signature v2/v3 vérifiée avec apksigner ; alignement 16 Ko vérifié avec zipalign. Identifiant org.woerth1870.prototype.v02 conservé, versionCode 32, versionName 0.8.19. Clé de développement du projet conservée. Aucune installation sur appareil Android ou émulateur effectuée.

## Scénarios

Choix dans le menu entre Classique (un objectif) et Essai (trois objectifs). Le scénario d’essai reprend le petit secteur de la Sauer du prototype et ses 12 unités, pas la carte historique de l’atelier 08.2. Aucun ordre de bataille historique nouveau. Description explicite : bataille fictive de validation.

10 tours, six unités par camp, deux camps jouables, trois profils d’IA existants. Objectifs : position centrale 3, bois 2, passage routier 1. Le bois se trouve bien sur une case forestière. La France contrôle initialement la position centrale ; les deux autres objectifs sont neutres. Positions et pondérations : ADAPTATION GAMEPLAY. Équilibrage sur appareil encore nécessaire.

Les étoiles portent leur valeur et les fiches indiquent le nom, le propriétaire et la valeur. L’aide décrit le système. Contrôle final 40, durée 20, pertes militaires infligées 40, selon les règles multi-objectifs testées précédemment.

## Sauvegardes

Essai : save_three_v0819.json. Classique : save_v0816.json ; ancien pack exact v0.8.18 repris si son empreinte correspond. Préférence de dernier scénario sauvegardée. Le sélecteur permet de continuer la sauvegarde du scénario choisi ; créer une nouvelle partie remplace seulement celle de ce scénario. Reprise testée après recréation de la scène principale.

## Tests exécutés

- test_multi_objectives.gd : 28/28.
- test_multi_objectives_ui.gd : 7/7 (avant l’ajout du sélecteur final).
- test_trial0819_ui.gd : 11/11, sélecteur final, rectangles de boutons, France/Prusse, deux emplacements de sauvegarde, changement de scénario et relancement.
- test_trial0819.gd -- easy : 6/6, 199 décisions, 10 tours terminés, scores de durée [39,21], victoire mineure française.
- test_trial0819.gd -- medium : 6/6, 217 décisions, 10 tours terminés, scores de durée [49,11], défaite mineure française.
- test_trial0819.gd -- hard : 6/6, 261 décisions, 10 tours terminés, scores de durée [43,17], victoire mineure française.

Chaque match a fait jouer les deux camps par l’IA, via leurs observations filtrées. Une graine par niveau ; ces résultats ne constituent pas une mesure d’équilibrage ni une comparaison de force des difficultés. Le score de durée seul ne détermine pas le vainqueur : contrôle final et pertes interviennent également.

APK inspecté : pack à trois objectifs présent, libellés français v0.8.19 présents, alias terrain Prairie affiché Plaine. Les nouvelles parties utilisent uniquement Plaine. Les anciennes sauvegardes gardent leurs règles d’origine.

## Limites

Pas de contrôle visuel du rendu Android ni de test tactile réel. Les contrôles d’interface ont été exécutés en mode headless. Tests physiques à faire : installation en mise à jour, lisibilité des trois étoiles, manipulation, sons, durée et reprise après interruption.

La carte historique de Frœschwiller-Wœrth (atelier 08.2 : routes reliées, objectif dans le Bois du Niederwald) reste un travail distinct, non intégré à ce scénario d’essai.
