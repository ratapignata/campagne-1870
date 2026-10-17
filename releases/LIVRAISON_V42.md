# Livraison V42 expérimentale — 17 octobre 2026

APK compilé depuis sources_reference_tests dans l’archive fournie 1870_V42_Tests_IA_MAJ_2026-10-17.zip, sans modification du code du jeu. Ce projet n’est pas une fusion des variantes visuelles mentionnées dans le rapport d’origine.

Godot 4.5.1, APK de test debug signé avec le certificat de développement historique ; versionName 0.8.42, versionCode 55, identifiant Android org.woerth1870.prototype.v02 conservé.

## Contrôles réellement exécutés pendant cette livraison

- Import Godot : réussi, aucune erreur de script relevée.
- Démarrage headless : réussi ; avertissement ObjectDB et deux ressources restant utilisées à la fermeture forcée.
- Contrat V42 : 415/415.
- Interface V42 : 112/112.
- Coordination IA V42 : 19/19.
- Sauvegardes, banc historique V36 : 43/43.
- Total de ces quatre bancs : 589 contrôles réussis.
- Export Android : réussi ; signature v2/v3, métadonnées, alignement ZIP 16 Ko et intégrité ZIP vérifiés.

Le processus adb signale un répertoire /home/agent/.android non inscriptible. Cela n’empêche pas la compilation ni la vérification de l’APK ; aucun appareil n’est connecté.

## Limites

Aucune installation ni mesure de performances sur téléphone. Aucune nouvelle simulation intégrale pendant cette livraison : les deux campagnes de 20 tours décrites dans le rapport fourni sont des résultats antérieurs reçus, pas des tests nouvellement exécutés ici.

Le scénario expérimental à 45 unités françaises et 50 allemandes, 95 000 hommes allemands et 20 tours est celui des sources jointes. Les unités allemandes de 4 577 hommes et les renforts génériques ont un impact d’équilibre non validé historiquement. Aucune règle ou donnée n’a été rééquilibrée pour cette compilation. La version est livrée pour essais.

L’archive Sources contient le projet complet sans caches ni compilations, le certificat public de développement déjà fourni, ce rapport et les preuves des vérifications de livraison.
