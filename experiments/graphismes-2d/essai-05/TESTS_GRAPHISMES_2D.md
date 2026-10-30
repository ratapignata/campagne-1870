# Tests — essai № 5, référence V43.15

30 octobre 2026, Godot **4.5.1 stable officiel**, dossiers utilisateur isolés. Aucune sauvegarde personnelle du joueur utilisée.

## Bilan final

**5 090 assertions réussies** : 2 487 dans 23 suites existantes, 2 433 pour le contrat graphique/tactile, 28 pour les sauvegardes des essais 1/2/3/4, 53 pour le rendu canon, 54 pour le fusil et 35 pour le banc des silhouettes/terrains/brouillard. Aucun échec dans les exécutions finales. Les analyses RGB et snapshots ci-dessous sont supplémentaires, sans gonfler le total.

| Suite existante réexécutée | Résultat |
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

Les sorties exactes sont dans `captures/graphismes2d5/preuves/regression.json`.

## Palette, gestes et sauvegardes

`test_contract.gd` : **2 433/2 433**. Contrôle de l’atlas d’illustrations, de la transparence et des dix couleurs de fond : `base_color` retourne exactement la couleur du pack V43.15. L’ancienne planche des sols n’est plus chargée. Sélection des 600 centres d’hexagone aux quatre zooms 0,42 / 0,72 / 1,05 / 2,3 : 2 400 contrôles ; toucher/glissement/pincement/ancrage, état moteur et sauvegarde/relecture conservés.

`test_previous_save.gd` : **28/28** sur les fixtures synthétiques effectivement générées par les essais 1 à 4. JSON courant/retour arrière complet relu et réécrit à l’identique, originaux inchangés. Format et `SaveStore` identiques.

Banc hérité de l’essai 3 : **35/35**. Seuils 1 999/2 000 pour les deux camps, mêmes bandes de force ; autres armes conservées. Même image pour des effectifs réels ennemis différents lorsqu’un rapport autorisé identique est utilisé ; même rendu après mouvement masqué avec contact mémorisé fixe. Trois indices de chaque terrain rendus au même emplacement écran : égalité exacte, écart maximal 0. Marqueurs ivoire opaques à contour sombre et placement des noms contrôlés. Le banc est isolé, pas une situation de bataille.

Animations réellement rendues : canon **53/53**, fusil **54/54** ; phases, trajectoires et couleurs conservées. Zooms extrêmes 0,42 et 2,3 rendus sans erreur.

## Commandes et intégrité

Six snapshots de commandes identiques à la stable : textes, rectangles, visibilité/désactivation, callbacks, filtres de souris, fiche et bandeaux. Aucun bouton ajouté, déplacé ou renommé.

Audit source **PASS**, référence `34d8f73` : 1 333 fichiers identiques dont IA, core, plateforme, scènes, packs et géographie. 118 fonctions sur 128 identiques dans les deux scripts de présentation existants. Hash du scénario `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

## Comparaison réelle avec V43.15

Galerie à trois colonnes : stable V43.15 / essai 4 / essai 5, mêmes états, zooms, caméra et sélection. **6/6 états et dispositions identiques ; 90/90 bandes de force identiques pixel par pixel.** Le cas déplacement est une nouvelle partie française T1 à graine fixée ; les cinq autres utilisent une fixture T11 existante. Aucune nouvelle simulation chronologique ni reproduction d’une partie du joueur.

L’analyse lit les PNG sans les modifier. Indices RGB pondérés 0..255, pas des mesures de nits, de calibration ou de luminosité physique. Rectangles identiques contrôlés avant comparaison. Les illustrations et la densité des bois étant différentes, la luminosité moyenne des régions ne peut être identique à chaque pixel ; les couleurs de fond des hexagones le sont.

| Cas | Carte V43.15 | Carte essai 5 | Pions V43.15 | Pions essai 5 |
| --- | ---: | ---: | ---: | ---: |
| overview | 173.55 | 174.97 | 127.72 | 133.17 |
| engagement | 164.51 | 167.07 | 127.02 | 131.45 |
| prussiens | 175.47 | 177.28 | 104.17 | 109.78 |
| isolement | 153.39 | 154.21 | 131.73 | 136.67 |
| detail | 154.38 | 156.99 | 125.28 | 128.65 |
| deplacement | 166.41 | 164.08 | 131.09 | 133.67 |

Les valeurs montrent une carte proche de la stable et des pions légèrement plus lumineux. Le style des nouveaux soldats reste différent. Le réglage de l’écran du joueur n’est pas mesuré. Analyse facultative reproductible avec Pillow ; aucune dépendance Python dans le jeu.

## Rendu et mémoire

Vue engagement 1280 × 720, zoom 1,05, 15 images de chauffe puis 60 redessins forcés. Linux/OpenGL Compatibility/Mesa llvmpipe, mesure CPU/rendu/attente, pas un profil Android.

Médiane essai 5 : 65.480 ms ; P95 : 79.467 ms ; appels : 2667 ; mémoire vidéo rapportée : 35879141 octets.


La suppression de la texture verte du sol réduit les changements de texture. La sous-couche claire réutilise le même atlas transparent, sans nouvel éclairage, shader ni post-traitement. L’ancienne planche de sol reste dans les sources, sans préchargement. Une passe logicielle par version, bruit de charge possible, aucune garantie de FPS sur téléphone.

## APK et limites

Export Android réussi, intégrité ZIP et signature v2/v3 vérifiées. Paquet `org.woerth1870.prototype.graphics2dexp`, version `0.8.43.15-g2d5`, code 5, même certificat ; API 24/35, ARMv7/ARM64/x86_64. Tests/captures/outils exclus de l’APK.

Fichier `1870_V43_Graphismes_2D_Experimental_05.apk`, 95168269 octets ; SHA-256 `63c95ebf4d7f50a9da1eb38995114be07a9b1d88afbf5ec1e1b9a7c848f86bf4`.


Avertissements habituels du banc : V-Sync non disponible sur le pilote logiciel ; après export réussi, sondage adb incapable de créer `/home/agent/.android` en lecture seule. Aucun appareil connecté ou testé.

Non réalisés : installation/jeu sur appareil ou émulateur Android, calibration/couleurs physiques, FPS/chauffe/batterie réels, nouvelle bataille complète T1–T20. Règles, IA, brouillard et animations inchangés ; aucune fusion dans main. Des noms peuvent encore se recouvrir en zone très dense.

## Reproduire

Godot 4.5.1, depuis la racine des sources avec des sauvegardes de test distinctes :

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/graphics/test_contract.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
# Serveur graphique nécessaire :
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_experiment03_render.gd
# Analyse facultative, Pillow requis :
python3 tests/graphics/compare_reference_palette.py /chemin/stable /chemin/essai5 /tmp/reference.json
```

Utiliser le même `capture_comparison.gd` sur les projets stables et expérimentaux avec des dossiers de sortie distincts. Les PNG, métriques, bancs et journaux sont fournis dans `captures/graphismes2d5`.
