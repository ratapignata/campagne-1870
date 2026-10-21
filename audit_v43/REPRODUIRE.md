# Reproduire le diagnostic

Utiliser Godot **4.5.1**. Décompresser l’archive de diagnostic. `prototype_1870` désigne la copie instrumentée, qui conserve toutes les règles de V43.1 et n’ajoute que des diagnostics IA et des scripts de test. Ne pas utiliser un répertoire de sauvegarde personnel pour les tests.

Sous Linux, donner à chaque test des répertoires XDG_CONFIG_HOME/XDG_DATA_HOME/XDG_CACHE_HOME écrits dans un dossier de test. Importer d’abord :

```sh
godot --headless --path prototype_1870 --editor --import --quit
godot --headless --path prototype_1870 --script res://tests/audit_v43/test_mechanisms.gd
godot --headless --path prototype_1870 --script res://tests/audit_v43/test_observed_reaction.gd
godot --headless --path prototype_1870 --script res://tests/v43/test_tactical_mobile.gd -- hard 430012
godot --headless --path prototype_1870 --script res://tests/v42_lot8/test_mobile_campaign.gd -- hard 430012
```

Le dernier test exécute réellement vingt tours avec les 95 unités et peut prendre environ 45 minutes dans l’environnement de cet audit. Le libellé final hérité « V42 FULL BATTLE » est celui du runner ; le pack exécuté est bien `regimental_trial_v43.json`.

Les sorties sont placées dans le répertoire utilisateur Godot `1870-prototype-v02`. Après la campagne :

```sh
godot --headless --path prototype_1870 --script res://tests/audit_v43/analyse_windows.gd -- /chemin/sorties/full_battle_report.json /chemin/sorties
godot --headless --path prototype_1870 --script res://tests/audit_v43/compare_traces.gd -- /chemin/sorties
godot --headless --path prototype_1870 --script res://tests/audit_v43/test_objective_retention.gd -- /chemin/sorties
godot --headless --path prototype_1870 --script res://tests/audit_v43/probe_snapshot.gd -- /chemin/sorties/trace_T12_A0986.json
```

Les scripts de rétention et la sonde ci-dessus ciblent les indices de commandes de la graine 430012. Les autres graines peuvent changer ces indices : adapter les noms aux traces réellement créées, sans prétendre reproduire cette campagne.

Pour tester l’export tardif : employer le projet de production **V43.2**, dont SaveStore possède l’export, et le script `test_late_export.gd` fourni dans le dossier de rapport :

```sh
godot --headless --path /chemin/V43.2/prototype_1870 --script /chemin/rapport/test_late_export.gd -- /chemin/rapport/data/trace_T12_A0986.json
```

Les snapshots de ce rapport sont des états de simulation, pas une sauvegarde personnelle du joueur. Le rapport détaille les hypothèses des microcas et les mesures réellement exécutées. Les scripts ne font aucun appel réseau et ne publient rien.
