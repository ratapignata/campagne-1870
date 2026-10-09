# Fichiers modifiés depuis les sources V36 livrées

## Application

- `project.godot` : version affichée 0.8.37.
- `export_presets.cfg` : export 0.8.37, code Android 50, nom et destination APK.
- `packs/1870/fr.json` : badge 0.8.37.

## Tests et documentation

- `tests/v37/test_full_battle.gd` : simulation chronologique complète et sauvegardes.
- `tests/v37/run_full_battle.py` : lanceur reproductible avec reprise.
- `tests/v37/test_replay.gd` : rejeu et analyse des occasions tactiques observables.
- `tests/results/0837/` : résultats, décisions et journaux réellement produits.
- `README.md`, `VERSION_0837.md`, `TESTS_V37.md`, `BATAILLE_V37.md`, ce récapitulatif : documentation V37.

Aucun fichier du moteur `war_engine` modifié. Les trois scénarios et `ai_profiles.json` sont conservés ; les rapports V36 restent présents. Les identifiants générés `.gd.uid` des nouveaux tests sont inclus s’ils sont créés par l’import Godot.
