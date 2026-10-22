# V43.8 — Fiche sans nom ni portée du fusil

Android 0.8.43.8, code 65. Retire dans le panneau inférieur gauche le nom du fusil et sa portée pour l’infanterie et les QG français/prussiens. Les informations de cavalerie, d’artillerie, de munitions, de moral, de commandement, de ravitaillement, les effectifs et les PA sont conservés. Les indications de contact et de terrain restent disponibles. Aucun paramètre de tir ou de portée modifié.

Défense de cavalerie en village 1,25 de V43.7 conservée. Aucun changement de doctrine ou de coefficient IA dans cette mise à jour. Analyse du débordement proposée séparément dans audit_v43/ANALYSE_PARTIE_T20_FLANC_DROIT.md ; elle n’est pas présentée comme un correctif IA déjà appliqué.

Godot 4.5.1 : fiche 18/18 (deux camps, infanterie, QG, cavalerie et artillerie), interface 30/30, export 28/28, EOF Android 9/9 : 85 contrôles réussis. Le test de fiche met aussi en jeu les renforts pour couvrir les quatre types ; un premier montage omettait la cavalerie française encore en attente au tour 1 et a été corrigé. Rendu graphique exécuté sur serveur ; fiche française vérifiée visuellement. Le premier lancement graphique sans serveur X a échoué, puis a réussi après démarrage de Xorg. APK compilé et signé avec le certificat existant ; aucun test physique Android ni nouvelle bataille complète.

La sauvegarde T20 reçue est un export V43.6 : ses combats n’emploient pas encore la réduction de défense de cavalerie V43.7. Les sauvegardes restent compatibles, sans réécriture de l’historique. Installer la mise à jour sans désinstaller l’application.

Fichiers applicatifs modifiés : war_engine/presentation/main.gd, project.godot, export_presets.cfg, packs/1870/fr.json. Test : tests/v43/test_rifle_label.gd. Preuves : tests/results/0843_8.
