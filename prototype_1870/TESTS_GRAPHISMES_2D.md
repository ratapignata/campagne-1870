# Vérifications exécutées — essai 9

Godot 4.5.1 officiel `f62fdbde1`, 31 octobre 2026. **3 369 assertions finales réussies**, sans compter deux fois les contrôles communs headless/graphique. Aucun échec final ni test désactivé.

| Suite | Résultat |
| --- | --- |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_previous_save` | 56/56 |
| `graphics/test_hud06` | 84/84 |
| `graphics/test_header09` | 796/796 |

En-tête : 795/795 headless et 796/796 avec capture. Alignement exact des centres du cadre et des trois boutons ; titre complet sans chevauchement ; heure/tours lisibles aux tours 1 à 20 et après la fin, deux camps/deux phases, tailles 1280 × 606, 1280 × 720, 1520 × 720. Les trois commandes s’ouvrent par événements tactiles simulés via `Input.parse_input_event`, sans mutation de l’état moteur. Polices 24/22 conservées.

Contrat : 2 400 centres d’hexagones aux quatre zooms, palette, atlas, transparence, toucher/glissement/pincement/ancrage, sauvegarde/relecture. Fixtures des essais 1 à 8 : état courant + retour arrière relus/réécrits, originaux intacts. Tests HUD : états, PA fractionnaires, liaisons, brouillard et rendu d’informations autorisées.

Huit comparaisons réelles avant/après avec les mêmes états synthétiques/cadrages que l’essai 8. Tous les pixels sous y=92 (carte et bandeau inférieur), états et 121 bandes de force identiques. Seul l’en-tête change. Captures Godot sans retouche.

Intégrité vs stable : 1 333 fichiers identiques, modules IA/core/plateforme/scènes et données de jeu intacts. 114/128 fonctions identiques dans `main.gd`/`map_view.gd`, exceptions de présentation explicites. `refresh()`, mouvements et animations inchangés. Pack SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. APK stable inchangé.

Aucune nouvelle simulation de bataille complète, campagne de combats/IA ou mesure de fluidité Android : ces systèmes sont inchangés depuis l’essai 8. Les anciens résultats ne sont pas comptés comme exécutions de cet essai.

APK code 9/version `0.8.43.15-g2d9`, paquet expérimental séparé, certificat identique, signature v2/v3 et ZIP interne vérifiés. Export Android terminé ; la sonde ADB de l’éditeur conserve son avertissement de répertoire personnel en lecture seule après l’export. Aucun essai sur appareil ou émulateur.

Archive extraite et importée séparément : contrat 2 433/2 433, sauvegardes 56/56, en-tête 795/795 et intégrité vs dossier stable réussis. Ces répétitions ne sont pas ajoutées aux 3 369 assertions.

Reproduire avec Godot 4.5.1 et un répertoire utilisateur isolé :

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/graphics/test_header09.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_header09.gd -- /tmp/header.png
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```
