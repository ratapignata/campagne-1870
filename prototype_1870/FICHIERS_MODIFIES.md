# Fichiers modifiés — V36 par rapport à V35

Copie dédiée : historique Git local avec un commit de référence puis des commits séparés pour les quatre lots. Aucun changement distant.

## Fichiers applicatifs modifiés

| Fichier | Modification |
|---|---|
| `war_engine/core/rules_base.gd` | Validation numérique et LOS géométrique commune |
| `war_engine/core/engine.gd` | Validation sémantique, retraite praticable et reddition conditionnelle |
| `war_engine/core/intel.gd` | Reconnaissance utilisant le même contrôle de terrain que le tir |
| `war_engine/platform/save_store.gd` | Refus des états invalides avant écriture et secours protégé |
| `war_engine/presentation/main.gd` | Horloge de fin à 17 h 00 |
| `packs/1870/fr.json` | Badge V36 et aide mise en cohérence avec les corrections |
| `project.godot` | Version applicative 0.8.36 |
| `export_presets.cfg` | Export Android 0.8.36, code 49, nom et destination |

Le code IA, ses profils, les données des trois scénarios, les règles de charge, de tir, de déplacement, les terrains de charge et les seuils de victoire restent inchangés. Le texte et les données de la flèche Reichshoffen restent inchangés.

## Tests et rapports

Les tests historiques modifiés utilisent l'API actuelle, une fixture du pack historique pertinent, une comparaison JSON canonique ou la nouvelle attente de reddition conditionnelle. Aucun coefficient du jeu n'est modifié pour satisfaire un ancien test.

Nouveaux bancs : sauvegardes, LOS, isolement, contrat des règles, UI tactile, mondes cachés, simulations actives, rejeu et diagnostic IA. `run_suite.py` permet de les exécuter avec Godot 4.5.1. La fixture `v35_regimental.json` provient d'une exécution du code V35 avant correction. Les `.uid` sont les identifiants de scripts Godot, pas des caches ni des compilations.

Rapports ajoutés : `VERSION_0836.md`, `TESTS_V36.md`, `IA_V36.md`, ce récapitulatif et copie du rapport de référence `AUDIT_V35.md`. `README.md` reçoit une entrée V36. Les résultats durables et leurs journaux sont dans `tests/results/0836/` ; ils font partie de la livraison vérifiable.

## Liste détaillée

`M` : fichier V35 modifié. `A` : fichier ajouté. Les documents de livraison sont indiqués après la liste des commits de développement.

- `A` `AUDIT_V35.md`
- `A` `FICHIERS_MODIFIES.md`
- `A` `IA_V36.md`
- `M` `README.md`
- `A` `TESTS_V36.md`
- `A` `VERSION_0836.md`
- `M` `export_presets.cfg`
- `M` `packs/1870/fr.json`
- `M` `project.godot`
- `A` `tests/results/0836/AB_active.json`
- `A` `tests/results/0836/AB_active_analysis.json`
- `A` `tests/results/0836/AI_diagnosis.json`
- `A` `tests/results/0836/C_turn12.json`
- `A` `tests/results/0836/C_turn12_analysis.json`
- `A` `tests/results/0836/E_final.json`
- `A` `tests/results/0836/E_final_analysis.json`
- `A` `tests/results/0836/android-alignment-final.log`
- `A` `tests/results/0836/android-manifest-final.log`
- `A` `tests/results/0836/android-signature-final.log`
- `A` `tests/results/0836/final-save-protection-test_ai_compat0833.log`
- `A` `tests/results/0836/final-save-protection-test_multi_objectives.log`
- `A` `tests/results/0836/final-save-protection-test_positions_results.log`
- `A` `tests/results/0836/final-save-protection-test_regimental0835_ui.log`
- `A` `tests/results/0836/final-save-protection-v36_test_saves.log`
- `A` `tests/results/0836/final-save-protection-v36_test_ui.log`
- `A` `tests/results/0836/final-terrain-retreat-v36_test_isolation.log`
- `A` `tests/results/0836/final-test_artillery0823.log`
- `A` `tests/results/0836/final-test_cavalry085.log`
- `A` `tests/results/0836/final-test_combat_routes.log`
- `A` `tests/results/0836/final-test_exact_intel087.log`
- `A` `tests/results/0836/final-test_exchange_assault.log`
- `A` `tests/results/0836/final-test_fog086.log`
- `A` `tests/results/0836/final-test_formations08.log`
- `A` `tests/results/0836/final-test_isolation0835.log`
- `A` `tests/results/0836/final-test_morale_ai.log`
- `A` `tests/results/0836/final-test_multi_objectives_ui.log`
- `A` `tests/results/0836/final-test_release0830.log`
- `A` `tests/results/0836/final-test_revision0830.log`
- `A` `tests/results/0836/final-test_river0814.log`
- `A` `tests/results/0836/final-test_strict0833.log`
- `A` `tests/results/0836/final-test_support0820.log`
- `A` `tests/results/0836/final-test_weapons.log`
- `A` `tests/results/0836/final-v36_test_contract.log`
- `A` `tests/results/0836/final-v36_test_hidden_worlds.log`
- `A` `tests/results/0836/final-v36_test_los.log`
- `A` `tests/results/0836/lot2-los-before-v35.log`
- `A` `tests/results/0836/lot4-AB.log`
- `A` `tests/results/0836/lot4-C.log`
- `A` `tests/results/0836/lot4-E.log`
- `A` `tests/results/0836/lot4-diagnosis.log`
- `A` `tests/results/0836/lot4-replay.log`
- `A` `tests/results/0836/non_regression.json`
- `A` `tests/results/0836/portable-runner-final.log`
- `A` `tests/results/0836/project-startup-final.log`
- `A` `tests/results/0836/project-startup-verbose-final.log`
- `A` `tests/results/0836/source-preservation.json`
- `M` `tests/test_exact_intel087.gd`
- `M` `tests/test_fog086.gd`
- `M` `tests/test_formations08.gd`
- `M` `tests/test_isolation0835.gd`
- `M` `tests/test_multi_objectives.gd`
- `M` `tests/test_positions_results.gd`
- `M` `tests/test_regimental0835_ui.gd`
- `M` `tests/test_release0830.gd`
- `M` `tests/test_revision0830.gd`
- `M` `tests/test_river0814.gd`
- `M` `tests/test_strict0833.gd`
- `M` `tests/test_support0820.gd`
- `A` `tests/v36/fixtures/v35_regimental.json`
- `A` `tests/v36/run_suite.py`
- `A` `tests/v36/test_ai_active.gd`
- `A` `tests/v36/test_ai_active.gd.uid`
- `A` `tests/v36/test_ai_diagnosis.gd`
- `A` `tests/v36/test_ai_diagnosis.gd.uid`
- `A` `tests/v36/test_ai_replay.gd`
- `A` `tests/v36/test_ai_replay.gd.uid`
- `A` `tests/v36/test_contract.gd`
- `A` `tests/v36/test_contract.gd.uid`
- `A` `tests/v36/test_hidden_worlds.gd`
- `A` `tests/v36/test_hidden_worlds.gd.uid`
- `A` `tests/v36/test_isolation.gd`
- `A` `tests/v36/test_isolation.gd.uid`
- `A` `tests/v36/test_los.gd`
- `A` `tests/v36/test_los.gd.uid`
- `A` `tests/v36/test_saves.gd`
- `A` `tests/v36/test_saves.gd.uid`
- `A` `tests/v36/test_ui.gd`
- `A` `tests/v36/test_ui.gd.uid`
- `M` `war_engine/core/engine.gd`
- `M` `war_engine/core/intel.gd`
- `M` `war_engine/core/rules_base.gd`
- `M` `war_engine/platform/save_store.gd`
- `M` `war_engine/presentation/main.gd`
