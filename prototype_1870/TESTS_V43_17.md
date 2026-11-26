# Tests réellement exécutés — V43.17

26 novembre 2026. Godot officiel **4.5.1**, Linux. **7651 assertions techniques distinctes réussies** : 6574 en 33 suites headless, 1079 avec rendu, moins vingt assertions de surbrillance communes, plus 18 contrôles de l’export personnel et de l’isolement. Répétitions et essais rejetés non additionnés.

| Suite headless finale | Résultat |
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

## Contrats nouveaux et adaptés

Normal français exactement comparé au code V43.16 figé sur plusieurs décisions et reprises de trajet ; autres politiques prussiennes préservées ; tir Chassepot réel à quatre hexagones dans les deux difficultés et les deux camps humains, quatrième bande affaiblie, riposte à quatre refusée/trois autorisée ; coûts de tir natifs. Deux calendriers français identiques pour le joueur prussien. Ancienne empreinte de sauvegarde, résultat terminé et normalisation entière vérifiés.

Artillerie : tir réel avant la préparation ordinaire de l’infanterie, absence de cible cachée, mise en batterie à trois PA puis tir au tour suivant, batterie initialement masquée quittant son verrou d’objectif et tirant réellement, aucun déploiement ou tir gratuit. Préparation d’un bois avant contact, réserve attaquant légalement un pillard, premiers défenseurs d’objectifs conservés, une seule réserve forte pour une petite incursion, repli d’un point secondaire au premier constat, maintien prudent du point majeur. Monde caché modifié sans changer les décisions autorisées ; aucune mutation du monde par la planification.

Les anciennes assertions de politique Normal française ont été remplacées par la référence V43.16 expressément approuvée ; celles du premier constat d’isolement distinguent maintenant point secondaire et objectif majeur. Les assertions de coûts, de règles, de riposte, de Raoult/renforts, d’isolement, de sauvegarde et de Prusse ne sont pas retirées pour masquer un échec.

## Graphisme12 et rendu

Cinq suites avec rendu réel OpenGL/llvmpipe : journal 990/990, surbrillance 23/23 (vingt communes), coches 9/9, terrains et silhouettes 35/35, guidage/zoom 22/22. Six captures de vues usuelles produites réellement, avec les nouvelles portées. Les 96 ressources/scripts graphiques originaux sont identiques à V43.16 Graphisme12 ; seuls les textes de mode/aide/version changent. Il n’est pas annoncé que la portée dessinée reste celle de trois hexagones.

## Simulations et intégrité

Quatre batailles complètes synthétiques de 29 unités sur vingt tours (plan 2×2), quatre cas de batterie sur six tours, deux démarrages du scénario réel de 95 unités sur deux tours. **8394 contrôles de légalité/état et fin de phase réussis**, séparés des assertions techniques. Aucun dépassement du plafond d’actions dans ces cas finaux. Protocoles et limites dans `COMPARAISON_IA_V43_17.md`.

Carte, unités, règles et armes hors Chassepot identiques à la base, vérifiées structurellement. Nouvelle empreinte du scénario : `c1b927a7c29e8a63b403df53ea6ecd00c06a0794b7fcaa8c7bd8cd8191a3faa1`. Ancienne empreinte explicitement migrable. L’original personnel reste intact ; copie et reprise préservent état et score, y compris la durée d’une partie terminée.

Archive du code extraite et importée à froid ; contrat graphique, anciennes sauvegardes et deux nouvelles suites réussis : 2642 assertions répétées, non ajoutées au total. La recompression finale ne modifie que les rapports/preuves ; égalité des fichiers de code/ressources vérifiée.

APK 0.8.43.17-g2d12, code 14, même paquet expérimental et certificat que Graphisme12. Export, intégrité ZIP, signatures et alignement vérifiés ; tests/captures/développement exclus. Aucun essai physique ou émulateur Android. Anciens avertissements ObjectDB UI et sonde ADB sans appareil conservés dans les journaux ; pas de gain de fluidité Android revendiqué.

## Reproduction

```sh
godot --headless --editor --path prototype_1870 --import
godot --headless --path prototype_1870 --script res://tests/v43/test_v4317_rules.gd
godot --headless --path prototype_1870 --script res://tests/v43/test_v4317_ai.gd
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4317.gd -- medium pincer /tmp/normal4.json 918536 20 4 1
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4317.gd -- hard pincer /tmp/hard4.json 918536 20 4 1
```

Utiliser des données utilisateur XDG isolées. Remplacer 4 par 3 pour la variante témoin, `pincer` par `full` et 20 par 2 pour reproduire les démarrages du scénario principal. Ne pas présenter `full ... 2` comme une bataille complète.
