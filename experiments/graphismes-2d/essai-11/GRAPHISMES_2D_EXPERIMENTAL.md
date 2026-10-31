# Essai graphique № 11 — coche en haut à droite

Version `0.8.43.15-g2d11`, 31 octobre 2026. Branche `v43-graphismes-2d-experimental`, base essai 10 (`76e96df`). Stable/main et essai 10 préservés dans leurs commits et livraisons.

## Changement demandé

La coche de fin d’action passe du milieu droit au coin supérieur droit du pion : centre local `(18, -18)` au lieu de `(9, 3)`, multiplié par le zoom existant. Même dessin, même taille, mêmes couleurs et mêmes conditions d’affichage. Elle reste dans les dimensions du pion, au-dessus de la force et à l’opposé du marqueur de désorganisation. Aucun numéro d’unité réintroduit.

La coche signifie toujours qu’aucune action active légale accessible ne reste, même avec 0,5 PA ou un autre budget positif. Aucun PA retiré ou `done` forcé ; elle peut disparaître lorsqu’un passage se libère. Les ripostes restent inchangées.

Le journal de l’essai 10 conserve ses cinq filtres fonctionnels : Tous, Combats, Redditions, Objectifs et Renforts, son défilement tactile et ses restrictions de brouillard. Tous les autres graphismes et commandes restent ceux de l’essai 10.

## Périmètre

Une seule modification de rendu : `war_engine/presentation/graphics2d_art.gd`, fonction `action_check`. Métadonnées de l’essai 11 dans `project.godot`, `export_presets.cfg` et le badge de `packs/1870/fr.json`. Rapports, liste des fichiers et captures actualisés. Aucun changement au moteur, à l’IA, aux scènes, données de bataille, disponibilité des actions, sauvegardes ou animations.

## Livraison

- `1870_V43_Graphismes_2D_Experimental_11.apk`.
- `1870_V43_Graphismes_2D_Experimental_11_Sources.zip` : code et ressources complets du jeu, tests, rapports, preuves actuelles ; anciens dossiers de captures 1 à 10 non dupliqués. Aucun cache ni fichier de compilation inclus.
- Galerie comparative : `captures/graphismes2d11/README.md`.
- Résultats : `TESTS_GRAPHISMES_2D.md`.

Installer par-dessus l’essai précédent **sans désinstaller**, pour conserver sa partie. Paquet `org.woerth1870.prototype.graphics2dexp`, même certificat de développement, code Android 11. Application stable séparée ; aucune intégration à main.

## Limites

Captures réelles sous Godot 4.5.1/Linux dans des états synthétiques, vérifications automatisées et signature APK contrôlées. Aucun test sur appareil physique ou émulateur Android. Les suggestions d’amélioration d’interface ne sont pas intégrées à cet essai.
