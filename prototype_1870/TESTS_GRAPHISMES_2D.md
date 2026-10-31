# Tests exécutés — essai 8

31 octobre 2026, Godot 4.5.1 officiel `f62fdbde1`. **5 971 assertions finales réussies**, sans compter deux fois les contrôles communs aux passes headless et graphique. Les 23 suites existantes totalisent 2 487 assertions. Aucun test final échoué ou désactivé.

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
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_previous_save` | 49/49 |
| `graphics/test_hud06` | 84/84 |
| `graphics/test_guidance07` | 137/137 |
| `graphics/test_header08` | 781/781 |

## Bandeau agrandi

Nouveau test `test_header08.gd` : 780/780 headless puis 781/781 avec rendu et capture. Les textes réels de camp, heure et tours sont mesurés avec leur police ; deux camps, deux phases, tours 1 à 20 et état final. Trois formats : 1280 × 606 / 1280 × 720 / 1520 × 720. Boutons et horloge dans le bandeau, absence de chevauchement, icônes/textes complets, carte et hauteur des bandeaux inchangées.

Les trois commandes sont activées par des événements tactiles simulés via `Input.parse_input_event`, en conservant l’émulation souris du projet. Les modales Journal/Aide/Menu s’ouvrent, l’état moteur reste identique. Le premier lanceur injectait directement dans le viewport et contournait cette émulation : la simulation du test a été corrigée, les callbacks du jeu restent inchangés.

## Comparaisons et conservation

Huit captures réelles avant/après, mêmes états/cadrages : vue générale, engagement, joueur prussien, QG, détail, cases accessibles, trajet, sélection isolée. Tous les pixels de la carte et du bandeau inférieur sont identiques à l’essai 7 ; 121 bandes de force identiques. La modification reste dans l’en-tête. Captures sans retouche, états synthétiques ; aucune prétention de simulation chronologique complète.

Six instantanés de commandes : les seuls rectangles modifiés sont les trois boutons d’en-tête, élargis à la demande. Textes, callbacks, filtres, états actifs/inactifs, commandes du bas et dimensions des bandeaux identiques.

Contrat : centres des 600 hexagones aux quatre zooms, palette V43.15, atlas, transparence, toucher/glissement/pincement/ancrage, sauvegarde et relecture. Sauvegardes des essais 1 à 7 : état courant + retour arrière comparés, originaux conservés. Aides tactiles de l’essai 7 et états/brouillard du HUD relancés.

## Intégrité et tests non relancés

1 333 fichiers de la stable identiques ; IA/core/plateforme/scènes et données de jeu intacts. 114/128 fonctions identiques dans `main.gd`/`map_view.gd`, exceptions de présentation explicites ; `refresh()`, entrées carte, règles et animations inchangées. Pack SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

Pas de nouvelle simulation complète de bataille, de nouveau test de performances Android ou de nouvelle campagne de rendu des tirs : ces systèmes et leurs ressources sont inchangés depuis l’essai 7. Les anciens résultats restent dans l’historique ; ils ne sont pas comptés comme exécutions de cet essai. Les petites mesures llvmpipe des captures sont des observations de la machine cloud, pas une validation de fluidité sur smartphone.

## Android et archive

APK code 8/version `0.8.43.15-g2d8`, paquet expérimental et certificat identiques. SDK minimum 24/cible 35, ARMv7/ARM64/x86_64, signature v2/v3 et ZIP interne vérifiés. APK stable V43.15 inchangé en SHA-256. La sonde ADB de l’éditeur affiche son avertissement de répertoire personnel en lecture seule après l’export ; compilation et signature terminées. Aucun essai sur appareil ou émulateur Android.

Archive extraite et importée séparément : contrat 2 433/2 433, sauvegardes 49/49, en-tête headless 780/780 et intégrité vs dossier stable réussis. Ces répétitions ne sont pas ajoutées aux 5 971 assertions.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/graphics/test_header08.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_header08.gd -- /tmp/header.png
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Utiliser des répertoires utilisateur isolés pour les tests. Les scripts de capture de l’essai 7 sont réutilisables à l’identique pour les deux versions ; comparer la zone `(0,92)-(1280,720)` en pixels RGB.
