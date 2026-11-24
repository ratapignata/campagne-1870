# Tests — V43.16 + Graphisme 12

Exécutions du 24 novembre 2026, Godot officiel **4.5.1**. **7 487 assertions distinctes réussies** : 6 428 en 31 suites headless, plus 1 079 avec rendu réel, moins les vingt assertions communes du test de surbrillance. Les anciens rapports livrés avec V43.16 ne sont pas comptés comme de nouvelles exécutions.

## Suites headless réellement relancées

| Suite | Résultat |
| --- | --- |
| `v43/test_v4315` | 28/28 |
| `v43/test_v4314` | 25/25 |
| `v43/test_v4314_ui` | 14/14 |
| `v43/test_v4313` | 30/30 |
| `v43/test_assault_commitment` | 11/11 |
| `v43/test_v4312` | 247/247 |
| `v43/test_bridge_barrage` | 17/17 |
| `v43/test_assault_before_rest` | 8/8 |
| `test_ai_compat0833` | 18/18 |
| `v36/test_hidden_worlds` | 18/18 |
| `v36/test_isolation` | 45/45 |
| `v43/test_enclosed_links` | 25/25 |
| `v43/test_adjacent_reinforcements` | 32/32 |
| `v43/test_ui` | 30/30 |
| `v43_export/test_export` | 28/28 |
| `v43_export/test_android_eof` | 9/9 |
| `v43/test_cavalry_village125` | 20/20 |
| `v43/test_rifle_label` | 18/18 |
| `v43/test_v439_presentation` | 102/102 |
| `v43/test_surrender_journal` | 11/11 |
| `v43/test_variant_b` | 1701/1701 |
| `v43/test_raoult` | 42/42 |
| `v43/test_v4315_ui` | 8/8 |
| `v43/test_v4316` | 56/56 |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_header09` | 795/795 |
| `graphics/test_hud06` | 84/84 |
| `graphics/test_guidance07` | 137/137 |
| `graphics/test_feedback12` | 20/20 |

## Rendu réel Linux

Xvfb, OpenGL Compatibility, llvmpipe LLVM 19.1.7. Ce sont des exécutions de Godot avec rendu, pas des maquettes d’image générées.

| Suite | Résultat |
| --- | --- |
| `test_journal10` | 990/990 |
| `test_feedback12` | 23/23 |
| `test_check10_ui` | 9/9 |
| `test_experiment03_render` | 35/35 |
| `test_guidance07_render` | 22/22 |

Journal : filtres et défilement tactile aux tailles 1280 × 606, 1280 × 720 et 1520 × 720 ; respect des informations cachées, redditions, objectifs, renforts et relecture après chargement. Coche à 0,5 PA : fantassin/canon sans action active coché ; cavalier encore mobile disponible ; PA et riposte inchangés. Fiche : effet décoratif temporaire, aucune mutation des données par le rendu. Terrains/pions : uniformité, seuil de deux silhouettes à 2 000 hommes, aucune fuite d’effectifs ennemis cachés ; marqueurs et sélection à plusieurs zooms.

Six vues de comparaison 1280 × 720 : overview, engagement, prussiens, isolement, detail et deplacement. **6/6 identiques pixel par pixel au Graphisme 12 original**. Les états sont les fixtures synthétiques existantes, avec une nouvelle partie à graine fixe pour la vue de déplacement. Aucune partie humaine n’a été rejouée pour ces captures.

## Intégrité des corrections

Comparaison avec l’archive exacte de V43.16 publiée : 1 368 fichiers originaux identiques. Cinq fichiers existants diffèrent : `main.gd`, `map_view.gd`, badge français et métadonnées de version/export. Le moteur, tous les modules IA, la plateforme, les scènes, les ressources originales et les données du scénario restent identiques. Cent six des 128 fonctions de main/map restent identiques, dont les fonctions d’animation de combat ; les différences sont celles du rendu Graphisme 12 et de ses aides de présentation.

Les 175 fichiers transplantés depuis Graphisme 12 sont identiques à leurs blobs Git d’origine. Les tests V43.16 de défense française (56/56), les anciens tests de règles/combat/renforts/Raoult, d’isolement, de brouillard, d’export et d’UI passent. Les sauvegardes des essais graphiques 1 à 9 passent 63/63 contrôles de lecture/réécriture en copie, sans altérer les originaux.

Empreinte du scénario : `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Aucun nouveau champ de sauvegarde.

## Archive et APK

Archive de sources extraite dans un dossier neuf, importée indépendamment puis testée : contrat graphique 2 433/2 433, sauvegardes 63/63 et défense française V43.16 56/56, soit 2 552 assertions répétées, non ajoutées au total. La recompression finale ajoute les rapports/preuves ; les fichiers de code et de ressources restent identiques à ceux vérifiés dans l’archive froide. CRC et égalité entre ZIP et sources vérifiés avant publication.

APK `0.8.43.16-g2d12`, code 13, paquet expérimental historique, même certificat de développement que Graphisme 12. Export Android, signatures, contenu ZIP et alignement vérifiés ; fichiers de tests/captures/développement exclus. SDK minimum 24/cible 35, ARMv7/ARM64/x86_64. Les avertissements préexistants ObjectDB de certains tests UI sont conservés dans les logs. La sonde ADB à la fin de l’export signale l’absence de connexion ; l’export et la vérification de signature réussissent.

Aucun essai sur appareil ou émulateur Android. Pas de nouvelle simulation de bataille complète : aucun code d’IA ou de règles n’a changé par rapport à V43.16. Les captures et mesures cloud ne constituent pas une mesure de fluidité sur smartphone.

## Reproduire

```sh
# Godot 4.5.1, données utilisateur des tests isolées.
godot --headless --editor --path prototype_1870 --import
godot --headless --path prototype_1870 --script res://tests/v43/test_v4316.gd
godot --headless --path prototype_1870 --script res://tests/graphics/test_contract.gd
godot --headless --path prototype_1870 --script res://tests/graphics/test_previous_save.gd
# Avec un véritable affichage graphique, créer les dossiers de sortie :
godot --path prototype_1870 --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/graphics/capture_comparison.gd -- /tmp/comparaison
godot --path prototype_1870 --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/graphics/test_journal10.gd -- /tmp/journal
```

Preuves JSON, métadonnées APK et logs de suites dans `tests/results/0843_16_graphisme12`, captures dans `captures/v4316_graphisme12`.
