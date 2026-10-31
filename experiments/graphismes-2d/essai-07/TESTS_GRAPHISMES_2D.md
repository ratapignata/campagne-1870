# Tests exécutés — essai 7

31 octobre 2026, Godot 4.5.1 officiel `f62fdbde1`, GL Compatibility. **5 350 assertions finales réussies**, sans compter deux fois les assertions communes aux passes headless et graphique. Les 23 suites de régression existantes totalisent 2 487 assertions. Aucun test final échoué ou désactivé.

| Suite | Résultat final |
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
| `graphics/test_previous_save` | 42/42 |
| `graphics/test_hud06` | 85/85 |
| `graphics/test_guidance07` | 139/139 |
| `graphics/test_guidance07_render` | 22/22 |
| `graphics/test_experiment03_render` | 35/35 |
| `v43/test_animation_render` | 53/53 |
| `v43/test_rifle_animation_render` | 54/54 |

## Ce qui a été testé

- Règles, IA, sauvegardes/export, QG Raoult, renforts, isolement, reddition, variante B, cavalerie, interface et animations : suites existantes relancées. Aucun nouveau changement de doctrine ni simulation complète de bataille dans ce lot purement visuel.
- Contrat graphique : 2 400 centres d’hexagones aux quatre zooms, dix couleurs de terrain égales à la stable V43.15, atlas et transparence, toucher/glissement/pincement/ancrage, état moteur et sauvegarde/relecture. Les ressources peintes sont les mêmes que dans l’essai 6.
- Compatibilité : les véritables fichiers synthétiques des essais 1 à 6 sont chargés, validés et réécrits avec état courant et retour arrière complets ; originaux jamais écrasés. Aucun format ou champ de sauvegarde ajouté.
- Nouveau guidage : véritables événements tactiles injectés au viewport pour les cinq signes d’aide, aux tailles 1280 × 606, 1280 × 720 et 1520 × 720 ; texte lisible, fenêtre dans l’écran, aucune intersection entre zones, état moteur et sauvegarde disque inchangés. Toucher réel d’une action désactivée : raison affichée et action non exécutée. Informations inconnues : aucun signe actif et aucun détail privilégié.
- Rendu réel aux zooms 0,42 / 0,72 / 1,05 / 2,3 : sélection ivoire et contour rouge simultanément visibles, point accessible ivoire inchangé, destination dorée et trajet distinct. Les couleurs ne sont pas le seul repère : formes et textes restent présents.
- Brouillard : tests existants, jumeaux d’états cachés et nouveau blocage des aides inconnues. Aucun indicateur calculé à partir de champs ennemis cachés.

## Comparaisons avant/après

Huit situations synthétiques reproductibles : vue générale, engagement, joueur prussien, QG, détail, déplacements accessibles, trajet préparé et sélection d’une unité isolée. Même état/caméra/zoom. Captures produites par Godot, sans retouche.

En-tête et géométrie des bandeaux identiques ; tous les textes, rectangles, callbacks, visibilités et désactivations des commandes existantes identiques dans six cas. 121 zones de chiffres de force comparées : identiques. 120 bandes complètes sur 121 identiques ; l’unique différence concerne trois colonnes de pixels du drapeau de `fr_5` dans le cas QG/isolement, anciennement masquées par le contour plein. La comparaison vérifie précisément ce changement et garde une comparaison stricte de la zone numérique.

Le rendu de carte change volontairement pour les halos, la sélection et le trajet. Pas d’affirmation d’identité de tous les pixels. Palette et ressources de terrain/pions inchangées ; moyennes RGB mesurées dans `preuves/comparison.json`.

## Intégrité du code

Comparaison avec V43.15 `34d8f73` : 1 333 fichiers identiques ; les cinq fichiers existants concernés depuis le début des essais restent de présentation/configuration et le badge de version. IA, core, plateforme, scènes, règles et géographie intacts. 115 fonctions sur 128 identiques dans `main.gd`/`map_view.gd`, exceptions graphiques explicites ; `refresh()`, entrée carte, déplacements et animations intacts.

Pack SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. APK stable V43.15 identique en SHA-256. Preuves JSON jointes.

## Mesures graphiques

Rendu logiciel llvmpipe, 60 images après 15 de chauffe, deux paires en ordre inversé :

| Paire | Version | Médiane ms | P95 ms | Moyenne ms |
| --- | --- | --- | --- | --- |
| initial | before | 64.80 | 79.10 | 66.98 |
| initial | after | 67.14 | 75.00 | 67.83 |
| inverse | before | 69.03 | 82.51 | 69.70 |
| inverse | after | 67.96 | 77.74 | 67.99 |

Variabilité de la machine cloud ; aucune extrapolation à Android. Appels de dessin 2 698 → 2 716, mémoire vidéo +17 784 octets. Aucun effet continu, shader ou nouveau bitmap lourd. Le HUD se redessine lorsque ses informations changent.

## Android et incidents de vérification

APK version `0.8.43.15-g2d7`, code 7, paquet expérimental séparé ; SDK minimum 24/cible 35, ARMv7/ARM64/x86_64. Compilation terminée, ZIP APK et signature v2/v3 vérifiés, certificat identique aux essais précédents. Tests/captures/outils de développement exclus du binaire.

L’éditeur signale que sa sonde ADB ne peut créer `.android` dans le répertoire personnel en lecture seule ; cela ne bloque pas la compilation/signature. Aucun appareil ou émulateur : installation, confort tactile, lisibilité et fluidité sur smartphone restent non testés ici.

Un contrôle initial a détecté une zone d’aide dépassant de deux pixels à gauche de la fiche ; elle a été ramenée dans la fiche avant compilation et relance complète. Le comparateur a aussi détecté le drapeau voisin dégagé par le nouveau contour ; ce cas est expliqué et vérifié séparément des chiffres de force, sans ignorer arbitrairement les différences.

Archive propre du même code extraite et importée séparément avec Godot 4.5.1 : contrat 2 433/2 433, sauvegardes 42/42, aides tactiles headless 137/137, intégrité vs dossier stable réussis. Ces relances ne sont pas ajoutées aux 5 350 assertions.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/graphics/test_contract.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
godot --headless --path . --script res://tests/graphics/test_guidance07.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_guidance07_render.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/capture_experiment07.gd -- /tmp/captures_essai7
python3 tests/graphics/compare_guidance07.py /tmp/captures_essai6 /tmp/captures_essai7 /tmp/comparison.json
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Pour comparer avec l’essai 6, utiliser le même script `capture_experiment07.gd` comme lanceur externe dans ses sources figées. Chaque test doit utiliser un répertoire utilisateur isolé. Pillow requis uniquement pour le comparateur Python, pas pour le jeu.
