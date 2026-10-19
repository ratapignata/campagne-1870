# 1870 : Frœschwiller-Wœrth — V41

Version 0.8.41, code Android 54. Lire en priorité `V41_Rapport_Tests.md`, `V41_Rapport_Performances_IA.md` et `V41_Modifications.md`. Les rapports plus anciens restent historiques.

## Ouvrir le projet

Importer `project.godot` avec Godot 4.5.1 stable. Le moteur utilise le rendu GL Compatibility. Les sources, ressources, scénarios, tests et réglages d’export sont inclus ; le cache `.godot` est régénéré à l’import.

## Tests

Voir `tests/v41/README.md`. Les résultats de la finalisation sont conservés dans `tests/results/0841/`. Le script `tests/v41/run_checks.py` offre des essais supplémentaires ; consulter le rapport pour distinguer ceux réellement achevés des bancs simplement disponibles.

## Export Android

Installer les modèles d’export Godot 4.5.1, Java 17, Android SDK build-tools 35.0.1 et platform-tools. Dans les paramètres de l’éditeur, régler les chemins Java et Android SDK. Puis, depuis le répertoire du projet :

```sh
godot --headless --editor --import --quit
godot --headless --export-debug Android /chemin/1870_v0.8.41.apk
```

Le préréglage Android utilise la clé de développement déjà fournie dans `development/`. Le package est `org.woerth1870.prototype.v02`. Les tests, captures et fichiers de développement sont exclus de l’APK. Ce paquet est destiné à l’installation directe ; ce n’est pas une publication sur un magasin d’applications.

## Installation directe

Copier l’APK sur le téléphone, l’ouvrir et autoriser si nécessaire l’installation depuis l’application utilisée. Avec un appareil déjà configuré pour le débogage USB : `adb install -r 1870_v0.8.41.apk`. Une mise à jour conserve normalement les données si le package et la signature correspondent ; les sauvegardes V40 compatibles sont prises en charge par la correction de migration.

Aucune installation sur téléphone ou émulateur n’a été réalisée dans cet environnement. Le rapport indique précisément les contrôles effectués. Aucun gain stable de vitesse de l’IA n’est déclaré validé.
