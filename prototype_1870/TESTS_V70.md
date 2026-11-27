# Tests réellement exécutés — V70

Godot officiel 4.5.1, Linux, 27 novembre 2026.

**8120 assertions techniques distinctes réussies** : 6610 en trente-cinq suites headless ; 1079 en cinq suites avec rendu, moins vingt assertions de surbrillance déjà comptées ; 179 dans le parcours BD avec rendu et 272 sur la véritable sauvegarde privée. Les répétitions de tests à froid ne sont pas ajoutées.

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
| `v43/test_v4317_rules` | 126/126 |
| `v43/test_v4317_ai` | 21/21 |
| `v43/test_v70` | 26/26 |
| `intro_bd/test_resume_direct` | 9/9 |

## Fonctionnement et règles

Tests V43 existants, Raoult/renforts, variantes de combat et charge, sauvegardes, LOS, réseaux, brouillard, score, réactions et interface réussis. Normal français comparé à la dernière V43.17 Difficile, avec les dépendances figées et les reprises de déplacement ; attentes historiques Normal ajustées à cette décision approuvée, sans suppression des contrats de coûts/règles.

Cas V70 : vrai tir d’une batterie déployée à trois hexagones, coût payé, conservation de sa position après le tir, écran réel d’infanterie, risque de cavalerie conservé, formation libre affectée à la protection et premiers défenseurs d’objectifs préservés. Même décision à observation égale et aucune mutation du monde pendant la planification vérifiées par les tests français existants.

## BD et rendu

Six vues réelles du jeu et suites de rendu Graphisme12 : journal 990/990, surbrillance 23/23 dont vingt communes, coches 9/9, terrains/silhouettes 35/35 et guidage 22/22. Lecteur BD intégré : **179/179**, six images et textes de BD 2 vérifiés, navigation tactile, trois résolutions paysage, texte défilant, trente secondes réelles de lecture automatique, pause/reprise, séquence automatique entière, libération des images, retour Android, confirmation de nouvelle partie, annulation et préservation de la sauvegarde. Reprise directe séparée 9/9 incluse dans les trente-cinq suites.

Deux premiers essais de test BD ont échoué avant validation : l’un exigeait les JPEG originaux de développement, désormais repris intégralement ; l’autre utilisait un délai fixe de 0,65 seconde pour afficher six scènes avec rendu logiciel partagé. Ce dernier a été remplacé par l’attente de la même fin réelle, bornée à dix secondes. Les contrôles de navigation et le vrai intervalle de trente secondes sont conservés. Le lecteur BD de production n’a pas été modifié pour satisfaire ce test. Seul le dernier essai complet réussi compte dans les résultats.

## Intégrité, sauvegarde et compilation

133 fichiers de moteur, plateforme, scénario et ressources identiques à V43.17 ; aucune modification de règles, données géographiques ou effectifs. Scénario inchangé : `c1b927a7c29e8a63b403df53ea6ecd00c06a0794b7fcaa8c7bd8cd8191a3faa1`. Neuf fichiers de lecteur/illustrations BD 2 repris exactement. Le prototype JPEG original est aussi archivé et vérifié. Sauvegarde personnelle T20 chargée et sauvegardée/rechargée dans un répertoire isolé : état complet et score identiques, original inchangé. Aucune copie de l’export privé n’est publiée.

Code extrait d’une archive propre, importé et testé à froid : 2643 assertions répétées, toutes réussies. Source finale comparée fichier par fichier et fichiers de production identiques à ce qui a été testé à froid.

APK 0.8.70, code 15, compilé, ZIP/signatures/alignement vérifiés ; même paquet/certificat Graphisme12. Tests, captures et ressources de développement exclus de l’APK. Aucun appareil physique ni émulateur Android. Avertissements de V-Sync logiciel, ObjectDB des anciens tests UI et sonde ADB sans appareil distingués des erreurs de script ; aucun gain de fluidité sur smartphone revendiqué.

## Comparaison tactique

Deux démarrages chronologiques T1–T8 du scénario réel de 95 unités : 3542 contrôles d’ordres/états légaux réussis, détails dans COMPARAISON_IA_V70.md. Aucune bataille complète T1–T20 exécutée pour cette livraison.

```sh
godot --headless --editor --path prototype_1870 --import
godot --headless --path prototype_1870 --script res://tests/v43/test_v70.gd
godot --headless --path prototype_1870 --script res://tests/intro_bd/test_resume_direct.gd
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v70.gd -- medium full /tmp/v70_normal.json 669381 8 4 0
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v70.gd -- hard full /tmp/v70_hard.json 669381 8 4 0
```

Utiliser des données utilisateur XDG isolées. Pour le test BD tactile, exécuter `tests/intro_bd/test_intro_flow.gd` avec un affichage réel ou Xvfb/OpenGL.
