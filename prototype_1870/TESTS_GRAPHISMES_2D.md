# Tests réellement exécutés — essai 6

31 octobre 2026, Godot 4.5.1 officiel `f62fdbde1`. Sources V43.15 + essai 5 `75c0aae`. **5 183 assertions finales réussies**, sans compter deux fois les 84 assertions HUD communes aux passes headless et graphique. Aucun test final échoué ou désactivé.

## Régression existante : 23 suites, 2 487 assertions

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

Les comparaisons internes avant/après IA des anciennes suites sont leurs contrôles de référence, pas des modifications de l’IA dans cette livraison. Aucun nouveau benchmark de bataille complète : moteur et IA sont conservés à l’identique.

## Graphismes, sauvegardes et animations

| Suite | Résultat final |
| --- | --- |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_previous_save` | 35/35 |
| `graphics/test_hud06` | 86/86 |
| `graphics/test_experiment03_render` | 35/35 |
| `v43/test_animation_render` | 53/53 |
| `v43/test_rifle_animation_render` | 54/54 |

Le contrat contrôle notamment les 2 400 centres d’hexagones aux quatre zooms, les couleurs de terrain V43.15, le toucher/glissement/pincement et l’état/sauvegarde. Le test rendu contrôle les terrains uniformes, marqueurs contrastés, seuil 1/2 soldats, informations ennemies et bandes de force. Les anciens essais 1 à 5 se rechargent et se réécrivent sans perte : état courant + retour arrière comparés, originaux conservés.

Nouveau test HUD : état normal/désorganisé/en déroute ; commandement seul perdu, ravitaillement seul perdu, double coupure ; informations inconnues sans indicateur trompeur ; jumeaux avec états ennemis cachés différents et rendu identique. Aucun changement de l’état moteur après décor, mises à jour idempotentes. PA fractionnaires, fin du tour 20, noms complets et boutons avec icônes contrôlés aux tailles 1280 × 606, 1280 × 720 et 1520 × 720. Les décorations ignorent les entrées, les deux lignes d’aide conservent leurs callbacks tactiles.

Six instantanés de toutes les commandes (infanterie, cavalerie, artillerie, QG, isolement, trajet) : textes, rectangles, visibilité, désactivation, callbacks et filtres de souris strictement identiques à l’essai 5. Bandeau supérieur et inférieur de mêmes dimensions. Commandes du bandeau central inchangées.

## Captures et intégrité

Six situations synthétiques reproductibles, mêmes états et cadrages : vue générale, engagement, camp prussien, isolement, détail, déplacement. Toute la zone de carte et 90 bandes de force identiques en pixels ; état moteur et rectangle de fiche identiques. Les seules différences attendues sont dans les bandeaux. Captures réellement produites par Godot, sans retouche. La capture supplémentaire de double coupure est explicitement synthétique.

Intégrité vs stable : 1 333 fichiers identiques ; tous les fichiers IA/core/plateforme/scènes/données géographiques intacts. 116/128 fonctions identiques dans `main.gd`/`map_view.gd`. Pack SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Vérification par `check_source_integrity.py`, sans élargir les exceptions aux règles ou à `refresh()`.

## Performances mesurées

Rendu logiciel `llvmpipe`, GL Compatibility, 60 images après 15 de chauffe. Pas une mesure Android. Deux paires, la seconde dans l’ordre inverse ; variabilité de la machine cloud :

| Paire | Version | Médiane ms | P95 ms | Moyenne ms |
| --- | --- | --- | --- | --- |
| initial | before | 65.11 | 79.71 | 66.57 |
| initial | after | 86.13 | 103.43 | 87.52 |
| inverse | before | 69.16 | 88.68 | 71.19 |
| inverse | after | 72.21 | 82.65 | 72.69 |

Sur la deuxième paire sans autres tests actifs, moyenne 71,19 → 72,69 ms (+2,1 %). L’écart plus grand de la première paire ne permet pas d’affirmer une performance identique ; aucune extrapolation au téléphone. Appels de dessin 2 667 → 2 698 (+31), mémoire vidéo +34 616 octets. Aucun polling par image, nouveau bitmap lourd, shader ou éclairage. L’IA elle-même est inchangée.

## Compilation Android

APK code 6/version `0.8.43.15-g2d6`, paquet expérimental séparé, ARMv7/ARM64/x86_64, SDK minimum 24/cible 35. ZIP interne vérifié, signature v2/v3 vérifiée, certificat identique aux essais précédents. L’APK stable V43.15 reste identique en SHA-256. Tests/captures/outils de développement exclus de l’APK.

La sonde ADB de l’éditeur affiche un avertissement de répertoire `.android` non accessible ; la compilation et la vérification de signature se terminent. Aucun appareil ou émulateur disponible : installation, reprise réelle de partie, lisibilité et fluidité Android restent à essayer par le joueur.

Lors de la mise au point, une propriété d’icône a été corrigée vers la constante de thème Godot et une invocation a utilisé un nom de script de test erroné. Les relances finales emploient les bons fichiers et passent ; ces incidents ne sont pas comptés comme tests réussis. Résultats détaillés JSON dans `captures/graphismes2d6/preuves`.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/graphics/test_contract.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_hud06.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/capture_comparison.gd -- /tmp/captures_essai6
python3 tests/graphics/compare_hud06.py /tmp/captures_essai5 /tmp/captures_essai6 /tmp/comparison.json
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Pillow nécessaire uniquement au comparateur Python de captures. Pour les tests, utiliser un répertoire utilisateur isolé afin de ne pas toucher une partie réelle. L’archive propre du même code a été extraite dans un dossier séparé, importée avec Godot 4.5.1 puis vérifiée : contrat 2 433/2 433, sauvegardes 35/35, HUD headless 84/84 et intégrité vs dossier stable réussis. Ces répétitions ne sont pas ajoutées aux 5 183 assertions.
