# Tests — essai lumineux № 4

30 octobre 2026, Godot **4.5.1 stable officiel**, dossiers de sauvegarde de test isolés. Aucune sauvegarde personnelle du joueur n’a été utilisée.

## Bilan final

**5 085 assertions réussies** : 2 487 dans les 23 suites existantes, 2 435 pour le contrat graphique/tactile, 21 pour les sauvegardes des essais 1/2/3, 53 pour le rendu canon, 54 pour le fusil et 35 pour le banc de rendu. Aucun échec dans les exécutions finales. L’analyse comparative RGB et les snapshots ci-dessous ne sont pas ajoutés artificiellement à ce total.

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

Sorties exactes : `captures/graphismes2d4/preuves/regression.json`.

## Contrat et nouveaux rendus

`test_contract.gd` : **2 435/2 435**, dont 2 400 sélections des 600 centres d’hexagone aux quatre zooms 0,42 / 0,72 / 1,05 / 2,3 ; gestes injectés, ancrage, atlas, transparence, état moteur intact et sauvegarde/relecture.

`test_previous_save.gd` : **21/21** sur les fixtures synthétiques écrites par les essais 1, 2 et 3 : JSON courant/retour arrière complet conservé, nouvelle copie vérifiée et empreinte des originaux inchangée. `SaveStore` et format inchangés.

Banc hérité `test_experiment03_render.gd` : **35/35**. Seuils 1 999/2 000 pour les deux camps, autres armes conservées, force/drapeau non masqués, rapports exacts/estimés, deux mondes avec même information mais effectifs/mouvement cachés différents : images identiques. Noms et côté de rivière de Spachbach conservés. Marqueurs ivoire opaques à contour sombre toujours vérifiés sur plaine/cultures/forêt.

Une première exécution donnait 34/35 : le gain de couleur des bois amplifiait une différence de rasterisation à différentes positions écran jusqu’à 2/255. Le contrôle a été renforcé : les trois indices sont maintenant rendus successivement au **même emplacement écran**, avec exigence d’égalité exacte et non augmentation de tolérance. Résultat : écart maximal **0** pour les trois terrains. Aucun matériau ni règle de jeu modifié pour faire passer cette vérification.

Les animations canon/fusil sont réellement rendues : **53/53** et **54/54**, couleurs, phases et visibilité conservées. Zooms extrêmes 0,42 et 2,3 rendus sans erreur. Pas de nouveau shader ou post-traitement.

## Commandes et intégrité

Six snapshots identiques à la stable pour textes, rectangles, visibilité/désactivation, callbacks, filtres de souris, fiche et dimensions de bandeaux. Aucun bouton ajouté, renommé ou déplacé.

Audit source : **PASS**, référence stable `34d8f73`. 1 333 fichiers identiques, cinq fichiers existants de présentation/configuration expérimentale concernés. IA, core, plateforme, scènes, packs et géographie identiques. 118 fonctions sur 128 identiques dans les deux scripts de présentation existants. Hash du pack `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

## Six comparaisons avant/après

Essai 3/essai 4, PNG 1280 × 720. **Même état, caméra, zoom, sélection et disposition dans 6/6 cas ; 90/90 bandes de force identiques pixel par pixel.** Cinq cas utilisent une fixture T11, et le déplacement une nouvelle partie française T1 à graine fixée. Ce ne sont ni une nouvelle simulation chronologique ni la partie du joueur.

`compare_brightness.py` lit les images sans les réécrire. L’indice est une moyenne RGB pondérée 0..255, calculée dans la zone de carte et les rectangles centraux de pions visibles. Il ne mesure pas les nits, la luminosité ou la calibration d’un écran physique. Les rectangles et états sont vérifiés identiques avant comparaison. Carte et zones de pions sont plus claires dans **6/6 cas**.

| Cas | Carte avant | Carte après | Pions avant | Pions après |
| --- | ---: | ---: | ---: | ---: |
| overview | 145.31 | 161.12 | 101.12 | 129.68 |
| engagement | 136.51 | 152.87 | 99.65 | 128.42 |
| prussiens | 146.25 | 162.64 | 81.49 | 105.11 |
| isolement | 122.55 | 138.11 | 106.15 | 133.81 |
| detail | 127.46 | 143.82 | 99.81 | 125.56 |
| deplacement | 130.90 | 145.06 | 101.37 | 129.69 |

L’analyse optionnelle requiert Pillow, déjà disponible dans l’environnement de test. Le jeu et ses tests Godot n’en dépendent pas. Les PNG réels, journaux et mesures sont livrés dans `captures/graphismes2d4`.

## Coût de rendu

Vue engagement, 1280 × 720, zoom 1,05, 15 images de chauffe puis 60 redessins forcés. Exécutions successives sans tests concurrents, Linux/OpenGL Compatibility/Mesa llvmpipe : mesure globale CPU/rendu/attente, pas un profil GPU Android.

| Mesure | Essai 3 | Essai 4 |
| --- | ---: | ---: |
| Médiane | 73.242 ms | 73.626 ms |
| P95 | 98.205 ms | 95.032 ms |
| Appels de dessin | 2852 | 2852 |
| Mémoire vidéo rapportée | 42197234 octets | 42197234 octets |

Une seule passe par version ; temps comparables sans garantie de FPS sur téléphone. Aucune image supplémentaire chargée, mêmes deux planches et mêmes primitives de dessin. Le nombre d’appels et la mémoire vidéo mesurée sont identiques.

## APK et limites

Export Android réussi ; intégrité ZIP et signature v2/v3 vérifiées. Paquet `org.woerth1870.prototype.graphics2dexp`, version `0.8.43.15-g2d4`, code 4, même certificat, API 24/35, ARMv7/ARM64/x86_64. Tests/captures/outils exclus.

Fichier `1870_V43_Graphismes_2D_Experimental_04.apk`, 95168269 octets ; SHA-256 `8552d376c33eed36f348a76bbd123d07a4d3c4f90fafe1b98636a1d154b63b57`.


Avertissements du banc : V-Sync non disponible sur le pilote logiciel ; après export réussi/vérifié, sondage adb incapable de créer `/home/agent/.android` en lecture seule. Aucun appareil connecté ou testé.

Non réalisés : installation/jeu sur appareil ou émulateur Android, luminosité et colorimétrie physiques, FPS/chauffe/batterie réels, nouvelle bataille T1–T20. Brouillard et routines d’animation inchangés, validation esthétique du joueur en attente, aucune fusion dans main.

## Reproduire

Godot 4.5.1 depuis la racine des sources, avec des dossiers utilisateur de test distincts :

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/graphics/test_contract.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
# Serveur graphique nécessaire :
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_experiment03_render.gd
# Après les captures, analyse facultative avec Pillow :
python3 tests/graphics/compare_brightness.py /chemin/avant /chemin/apres /tmp/brightness.json
```

Le même `capture_comparison.gd` est utilisé sur les essais 3/4 avec deux dossiers de sortie. Il produit six PNG et leurs métriques/empreintes.
