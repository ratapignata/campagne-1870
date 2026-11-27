# Tests réellement exécutés — V70.1

Godot officiel 4.5.1, Linux, 27 novembre 2026.

**6 933 assertions techniques réussies** : 6 653 en 36 suites headless, huit sur l’interface avec rendu réel,272 sur la sauvegarde personnelle. Les2170 contrôles de relecture de la référence et les 1 208 contrôles des fenêtres tactiques sont comptés séparément. 2 666 assertions répétées après extraction/import à froid, non ajoutées au total.

| Suite finale | Résultat |
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
| `v43/test_v4317_ai` | 20/20 |
| `v43/test_v70` | 26/26 |
| `intro_bd/test_resume_direct` | 9/9 |
| `v43/test_v701` | 44/44 |

## Contrats nouveaux

V70.1 artillerie 44/44 : batterie masquée puis vrai tir après déplacement payé ; double écran réellement dégagé ; hausse de tirs contre la référence V70 sur le même état ; aucune modification de l’observation ; positions d’objectifs conservées ; absence de déplacement des formations retranchées ; demi-PA insuffisant pour un mouvement d’un PA ; mise en batterie réellement payée à la limite de trois PA ; vrai tir au prochain tour ; absence de tir sur ennemi caché.

Normal français et Prusse comparés aux références antérieures par les tests V43/V70. Le moteur et les données n’ont pas changé. Sauvegarde personnelle V43.17 T20 chargée, sauvegardée/rechargée dans une copie isolée : 272/272, état et score conservés, original intact. Aucun export privé intégral publié.

## Rendu et introduction

Nouveau contrôle V70.1 avec rendu OpenGL logiciel : 8/8, captures du menu, de la BD2 et du choix de bataille. Ouverture et passage de l’introduction laissent la partie et son fichier intacts. Reprise directe d’une sauvegarde 9/9 et export JSON 28/28 inclus dans les 36 suites.

Les 149 fichiers contrôlés de moteur/plateforme/scénario/ressources/BD sont identiques à V70. Le lecteur et les six images de BD2, les ressources Graphisme 12 et les animations n’ont pas changé. Les 179 contrôles BD et 1 079 contrôles de rendu détaillé de V70 restent des résultats historiques : ils ne sont pas annoncés réexécutés pour V70.1.

## Relecture, simulations et compilation

Relecture native de la trace IA V70 : 2170/2170. Un premier comparateur opposait directement les tableaux d’entiers aux nombres JSON flottants ; il a été corrigé pour comparer les indices d’hexagones. Aucun état de jeu ni résultat de combat n’a été modifié pour faire passer ce contrôle.

Deux fenêtres chronologiques T2–T4 du scénario de 95 unités déclarées, même état initial et adversaire actif : 1208/1208, aucune limite d’actions atteinte. Détails et résultats dans COMPARAISON_IA_V70_1.md. Ce ne sont pas des batailles complètes à vingt tours ni la partie humaine rejouée.

Archive de code extraite, importée et testée à froid :2 666 assertions répétées réussies. Production finale comparée à l’archive testée. APK 0.8.70.1/code 16 compilé, ZIP/signature/alignement vérifiés, même paquet et certificat Graphisme 12. Tests, captures et développement exclus. Aucun essai physique ou émulateur Android. Avertissements de sonde ADB sans appareil et V-Sync logiciel conservés dans les logs, sans gain de fluidité sur téléphone revendiqué.

## Reproduction

```sh
mkdir -p /tmp/v701_relecture
godot --headless --editor --path prototype_1870 --import
godot --headless --path prototype_1870 --script res://tests/v43/test_v701.gd
godot --headless --path prototype_1870 --script res://tests/v43/replay_v70_artillery.gd -- res://tests/results/v70/full_hard_669381.json /tmp/v701_relecture
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v701.gd -- v70 res://tests/fixtures/v701/v70_ai_T2.json /tmp/v701_old.json 4
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v701.gd -- v701 res://tests/fixtures/v701/v70_ai_T2.json /tmp/v701_new.json 4
```

Isoler les répertoires de données utilisateur XDG. Les fixtures sont générées par les simulations IA, sans données de la partie humaine. Le hash du scénario reste `c1b927a7c29e8a63b403df53ea6ecd00c06a0794b7fcaa8c7bd8cd8191a3faa1` ; aucun nouveau format de sauvegarde.
