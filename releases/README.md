# 1870 : Frœschwiller-Wœrth — V37

Version Android de test **0.8.37** (code 50), compilée avec Godot 4.5.1.

- [Télécharger l’APK V37](https://github.com/ratapignata/campagne-1870/raw/refs/heads/apk-v0.8.37/releases/1870_v0.8.37.apk)
- [Télécharger les sources V37 ZIP](https://github.com/ratapignata/campagne-1870/raw/refs/heads/apk-v0.8.37/releases/1870_v0.8.37_Sources.zip)
- [Consulter les sources](prototype_1870/)
- [Résultats de la bataille](releases/BATAILLE_V37.md)
- [Tests exécutés et limites](releases/TESTS_V37.md)

Bataille chronologique complète de **18 tours**, deux IA actives, scénario original de **81 unités déclarées** (80 entrées, QG Raoult bloqué par occupation de sa case). **447 mouvements, 418 tirs actifs et 30 assauts**. Victoire prussienne mineure : 77,36 contre 14,95 ; les trois objectifs sont prussiens à la fin.

26 suites de régression réussies (2 186 assertions). Rejeu exact : 2 753 contrôles réussis. Le test initial a signalé une attente incorrecte d’entrée de tous les renforts ; le test publié respecte désormais l’attente légale sur entrée occupée. Rapports et journaux initiaux conservés.

Charge de cavalerie **2 PA**, aucun bouton TIRER, confirmation au second toucher et score **60/20/20** conservés. Moteur, scénarios et doctrine IA identiques à V36.

Signature APK v2/v3 et alignement 16 Ko vérifiés. **Aucun essai sur appareil Android ou émulateur.** Une seule graine et une seule difficulté ne démontrent pas l’équilibrage global. Même identifiant et certificat de test que V36 pour permettre une mise à jour sans désinstallation.

Les sources ne contiennent ni caches ni compilations. Extraire le ZIP et ouvrir `prototype_1870/project.godot` avec Godot 4.5.1. Les empreintes des scénarios et les emplacements des sauvegardes V35/V36 sont conservés ; les sauvegardes valides restent compatibles.

Cette livraison se trouve sur la branche dédiée `apk-v0.8.37` ; V36 demeure disponible sur sa branche précédente. Empreintes des téléchargements : [SHA256SUMS.txt](releases/SHA256SUMS.txt).
