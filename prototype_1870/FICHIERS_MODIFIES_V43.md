# Fichiers V43

Base : copie exacte V42 Lot 8 finale, commit local 0f829db0231dd3addf978117aeb9c5d1085f28af.

- `COMBATS_V43.md`
- `RAOULT_V43.md`
- `README.md`
- `REPRODUIRE_V43.md`
- `TESTS_V43.md`
- `VERSION_0843.md`
- `export_presets.cfg`
- `packs/1870/fr.json`
- `packs/1870/regimental_trial_v43.json`
- `project.godot`
- `tests/test_regimental0835_ui.gd`
- `tests/v43/animation_board.gd`
- `tests/v43/animation_board.gd.uid`
- `tests/v43/probe_raoult.gd`
- `tests/v43/probe_raoult.gd.uid`
- `tests/v43/reference_v42_engine.gd`
- `tests/v43/reference_v42_engine.gd.uid`
- `tests/v43/test_animation_render.gd`
- `tests/v43/test_animation_render.gd.uid`
- `tests/v43/test_cavalry.gd`
- `tests/v43/test_cavalry.gd.uid`
- `tests/v43/test_raoult.gd`
- `tests/v43/test_raoult.gd.uid`
- `tests/v43/test_real_charges.gd`
- `tests/v43/test_real_charges.gd.uid`
- `tests/v43/test_tactical_mobile.gd`
- `tests/v43/test_tactical_mobile.gd.uid`
- `tests/v43/test_ui.gd`
- `tests/v43/test_ui.gd.uid`
- `tests/v43/test_variant_b.gd`
- `tests/v43/test_variant_b.gd.uid`
- `war_engine/ai/tactical_ai.gd`
- `war_engine/core/engine.gd`
- `war_engine/presentation/main.gd`
- `war_engine/presentation/map_view.gd`
- `FICHIERS_MODIFIES_V43.md` : ce récapitulatif.
- `tests/results/0843/` : rapports JSON, sorties exécutées, captures de rendu et échecs initiaux documentés.

Les scénarios V42 d’origine, le roster et la carte sont conservés. Le nouveau fichier regimental_trial_v43.json ajoute uniquement l’identité/version V43, sa description, le paramétrage de B et la compatibilité de sauvegarde. rules_base.gd, support.gd, intel.gd et ai_profiles.json sont inchangés. Les calculs de réaction, isolement, reddition, dégâts et portée de tir n’ont pas été modifiés. Le test de démarrage historique a une attente adaptée au remplacement demandé par V43.

## V43.1 — 20 octobre

- engine.gd : arrivée sur une case voisine si ennemi à l’entrée ; anciens scénarios inchangés.
- regimental_trial_v43.json : activation de cette règle et empreinte de compatibilité V43.
- project.godot, export_presets.cfg, fr.json : version 0.8.43.1 / code 58.
- tests/v43/test_adjacent_reinforcements.gd, sa fixture V43 antérieure et tests/results/0843_1 : nouvelles validations.
- Rapports, README et archives de livraison mis à jour.
