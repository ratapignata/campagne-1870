# Essai graphique 2D — V43.15-g2d1

30 octobre 2026. Branche `v43-graphismes-2d-experimental`.

## Base et périmètre

Base complète V43.15, commit `34d8f73ecdce503adc7fc149474653876176af41`. Elle comprend la défense française Difficile, l’ossature prussienne conservée, les corrections Raoult, les renforts adjacents, les exports de sauvegarde et les améliorations précédentes. La branche stable et son APK sont conservés. Aucun développement de règles dans cet essai.

## Résultat visuel

- Atlas original unique de 29 images : prairies, champs aux sillons discrets, nuances ocre/vert, feuillages irréguliers, maisons et toitures. Les motifs se répètent volontairement pour limiter la mémoire ; variantes déterministes, sans appel au générateur aléatoire du moteur.
- Relief : légère teinte selon l’altitude publique et ombrage des ruptures existantes. Les données de hauteur et les calculs de LOS demeurent inchangés. Le pack conserve `show_relief=false` pour les anciennes courbes ; le nouvel ombrage est purement visuel.
- Routes : deux traits fins sur les points et courbes existants. Sauer : eau bleue, trait de berge et quelques reflets ; extrémités et segments strictement identiques, deux noms bleus conservés. Ponts, villages, route et flèche Reichshoffen non déplacés.
- Pions : illustrations historiques d’infanterie, cavalerie, artillerie et QG conservées. Même géométrie et taille ; bordures plus nettes, léger dégradé et ombre allégée. Force, états, contours tactiques et information masquée conservés. Aucun numéro d’unité redondant.
- Fiche inférieure gauche : code de mise en page et contenu inchangés ; cinq comparaisons de son rectangle complet donnent des pixels identiques.
- Bandeaux : hauteurs inchangées, simple filet sous l’en-tête. Boutons aux mêmes emplacements et dimensions, couleurs et bordures ajustées ; aucun bouton ajouté, supprimé ou renommé. Les textes, conditions d’activation et callbacks restent identiques.

## Fichiers modifiés

Cinq fichiers existants changent :

| Fichier | Modification |
| --- | --- |
| `war_engine/presentation/map_view.gd` | Appels de dessin des terrains, routes, eau, relief et fond des pions ; initialisation de l’atlas et filtrage. |
| `war_engine/presentation/main.gd` | Styles du bouton commun et filet décoratif non interactif de l’en-tête. |
| `project.godot` | Nom et version expérimentaux, dossier utilisateur distinct. Dimensions et moteur de rendu conservés. |
| `export_presets.cfg` | APK et identifiant Android distincts, version expérimentale. Certificat et permissions conservés. |
| `packs/1870/fr.json` | Seul le badge de version devient « ESSAI GRAPHIQUE 2D · BASE V43.15 ». |

Ajouts : `graphics2d_art.gd`, atlas PNG et réglages d’import, sources SVG et générateur dans `development/graphics2d`, tests et outils de comparaison dans `tests/graphics`, ce rapport, rapport de tests et captures/preuves dans `captures/graphismes2d`.

`FICHIERS_GRAPHISMES_2D.txt` donne l’inventaire exhaustif. Les `.import` et `.uid` sont des réglages/références Godot ; les caches `.godot`, APK, temporaires et fichiers Git ne sont pas inclus dans les sources ZIP.

## Systèmes préservés

Vérification binaire contre la base : 1 333 fichiers existants identiques, dont l’intégralité des modules IA, moteur et plateforme, scènes et données géographiques/scénario. Dans les deux scripts de présentation modifiés : 123 fonctions sur 128 identiques ; seules `_ready`, `_draw`, `counter_back`, `button` et `build_ui` changent.

Les animations de combat, dessins des soldats, transformations écran/carte, gestes tactiles, affichage du brouillard et objectifs, ripostes, charge 2 PA, variante B, 20 tours, score 60/20/20, renforts, sauvegardes et IA Normal/Difficile ne changent pas. Le hash du scénario reste `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

## Installation et retour à la version actuelle

Installer `1870_V43_Graphismes_2D_Experimental_01.apk`. L’application s’appelle **1870 · Essai graphique 2D** et utilise `org.woerth1870.prototype.graphics2dexp` ; elle s’installe à côté de la version stable. Ne pas désinstaller le jeu actuel : sa partie reste dans son propre espace.

Les sauvegardes de l’essai sont séparées. Leur format est inchangé et le test de sauvegarde/relecture conserve tout l’état. Android ne transfère pas automatiquement la partie du jeu stable vers cette seconde application ; aucun nouveau bouton d’import n’a été ajouté. Pour revenir au graphisme actuel, ouvrir simplement le jeu stable.

Version Android `0.8.43.15-g2d1`, code 1 pour ce nouveau paquet, Android minimum 7.0/API 24, cible API 35. Compilation Godot 4.5.1, signature de développement vérifiée. Aucun essai physique Android réalisé.

## Limites et validation attendue

Ce prototype reste un rendu 2D illustré : textures volontairement discrètes et nombre de variantes limité. La taille des maisons est illustrative, sans effet sur l’occupation ni la couverture. Le rendu Android réel, l’échelle des détails et le confort sur votre écran restent à apprécier. Aucune intégration dans `main` avant votre validation visuelle.

Voir `TESTS_GRAPHISMES_2D.md` et `captures/graphismes2d/README.md` pour les comparaisons et les preuves.
