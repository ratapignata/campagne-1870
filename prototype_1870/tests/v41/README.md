# Vérifications V41

Ces bancs complètent les tests hérités. Ils ne modifient pas les règles utilisées par l'application et sont exclus de l'APK.

- `test_balance.gd` : 5 000 tirs par arme à 2 hexagones dans des conditions identiques, puis 256 échanges complets par camp avec les ripostes existantes.
- `test_migration.gd` : sauvegardes V40 en cours et terminées, conservation du score et réenregistrement en V41.
- `test_legacy_save.gd` : sauvegarde historique V37 réellement fournie, avec la table de migration introduite en V39 ; comparaison des états après normalisation JSON des types numériques.
- `reference_v41_uncached.gd` : IA V41 fournie, avec uniquement la mise en cache du rapport de départ retirée. Les nouvelles priorités d'artillerie restent identiques. Ce fichier sert de témoin expérimental, pas d'IA de production.
- `test_optimization.gd` : décisions appariées, classement complet des candidats, absence de modification de l'observation et légalité des commandes ; ordre de mesure alterné.
- `test_performance_cpu.gd` : mesures appariées du temps processeur Linux, avec échauffement et répétitions ; vérifier `getconf CLK_TCK` avant de passer sa valeur en argument.
- `test_comparison.gd` : banc existant V38 d'artillerie, dont la condition de fin est reliée aux 20 tours du scénario. Carte originale, déploiement synthétique et 14 unités, sans renforts programmés. Ce banc n'est pas la bataille complète à 81 unités.
- `test_full_battle.gd` : copie du banc complet disponible, avec la condition de fin reliée au nombre de tours du scénario. Sa présence ne signifie pas qu'il a été exécuté ; consulter le rapport de tests.

Godot requis pour reproduire cette livraison : 4.5.1 stable. Passer le chemin de l'exécutable à `--godot`.

```sh
python3 tests/v36/run_suite.py --godot /chemin/godot --output-dir /tmp/v41-regression --timeout 1800
python3 tests/v41/run_checks.py --godot /chemin/godot --out /tmp/v41-simulations --mode simulations
python3 tests/v41/run_checks.py --godot /chemin/godot --out /tmp/v41-optimisation --mode optimization
godot --headless --path . --script res://tests/v41/test_balance.gd
godot --headless --path . --script res://tests/v41/test_migration.gd
godot --headless --path . --script res://tests/v41/test_legacy_save.gd
```

Les anciens bancs V38 qui comparent exactement une partie à 18 tours et les anciens dégâts sont des témoins historiques. Pour V41, utiliser leurs adaptations documentées ci-dessus. Conserver les journaux initiaux, y compris les erreurs et dépassements de délai, lors d'une analyse.
