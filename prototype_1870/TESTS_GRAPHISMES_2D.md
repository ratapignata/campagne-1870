# Tests exécutés — essai 11

31 octobre 2026, Godot 4.5.1 officiel `f62fdbde1`. Modification limitée à la position de la coche et à l’identifiant de version.

## Suites relancées dans cet essai

| Suite existante | Résultat |
| --- | --- |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_header09` | 795/795 |
| `graphics/test_journal10` | 985/985 |
| `graphics/test_check10_ui` | 6/6 |

4 635 assertions headless réussies. Le scénario du test UI a également été rendu avec captures : 12/12 contrôles, dont six communs au test headless, soit **4 641 assertions distinctes** pour cette campagne ciblée. Tous les tests ci-dessus passent ; aucune suite désactivée. Les 7 494 assertions de l’essai 10 sont des résultats historiques, pas une nouvelle campagne complète de cet essai.

## Contrôles visuels exécutés

Captures avant/après dans le même état synthétique, caméra et taille 1280 × 720 : fantassin à 0,5 PA coché, cavalier à 0,5 PA encore mobile sans coche, canon à 0,5 PA coché avec riposte prête. Captures complémentaires d’un fantassin désorganisé, retranché et en double coupure aux zooms 0,6 / 1 / 2,3. Vérification visuelle du coin supérieur droit, du chiffre de force, du marqueur D, du retranchement et du contour rouge. Le journal et le bandeau supérieur passent leurs suites existantes sans changement de code.

Les captures proviennent du jeu réellement exécuté, sans retouche. États de test de trois unités et non une partie chronologique du joueur. Le script de reproduction utilisé se trouve dans la galerie/preuves. Le premier lancement a signalé l’absence de périphérique audio ; la capture finale a été relancée avec `--audio-driver Dummy`, avec succès. Le rendu logiciel signale seulement l’absence de réglage V-Sync.

## Intégrité

Comparaison avec l’essai 10 : disponibilité, journal, moteur, IA, règles, sauvegardes, animations et scènes identiques. Comparaison automatisée avec la stable V43.15 réussie : 1 333 fichiers originaux identiques, exceptions de présentation déjà documentées, aucune modification core/IA/plateforme/géographie. Pack de scénario SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

Sauvegardes réelles des essais 1 à 9 relues et réécrites sans altération des originaux : 63/63. Aucune modification de format ni de code de sauvegarde par rapport à l’essai 10. Aucune nouvelle simulation complète de bataille, aucun essai Android physique ou émulateur.

## APK et archive

APK exporté avec Godot 4.5.1, version `0.8.43.15-g2d11`, code 11, même paquet expérimental et certificat de développement. Vérification de signature, métadonnées, contenu ZIP et archive de sources : voir preuves et manifeste de livraison. Tests et captures exclus de l’APK. L’avertissement de la sonde ADB sur son répertoire personnel en lecture seule ne bloque pas l’export ; aucun appareil n’est connecté.

Archive de sources extraite et importée dans un dossier indépendant : sauvegardes 63/63, disponibilité 353/353 et intégrité avec la stable réussis. Ces répétitions ne sont pas ajoutées au total des assertions.

## Reproduire

```sh
godot --headless --path . --script res://tests/graphics/test_availability10.gd
godot --headless --path . --script res://tests/graphics/test_journal10.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/graphics/test_check10_ui.gd -- /tmp/captures
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Créer le dossier de captures et utiliser un répertoire utilisateur isolé. Les contrôles et images de l’essai 10 restent accessibles dans la livraison précédente.
