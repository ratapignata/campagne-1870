# V39 — Rapport technique

## Environnement
Godot 4.5.1.stable.official.f62fdbde1. Tests moteur headless. Contrôle graphique 1280 × 720, OpenGL Compatibility avec Mesa llvmpipe et écran virtuel. Export APK avec Java 17, templates officiels 4.5.1, Android build-tools 35.0.1.

## Résultats
- Import et 26 suites de régression : succès après adaptation des assertions de durée. Deux tests attendaient encore la fin au tour 18 / 17 h ; ils vérifient désormais le tour 20 / 18 h. Toutes les assertions restent actives.
- Lot 1 : 33/33 contrôles, y compris sauvegarde finale, import d’une ancienne sauvegarde réelle, migration des difficultés, durée, horloge et score.
- Contrat de règles : 110/110, également compté dans les 26 suites.
- Lot 2 : 30/30 contrôles tactiques.
- Mondes cachés : 18/18, également compris dans les régressions ; rejoué sur la révision finale.
- Capture d’un objectif secondaire hors de l’axe principal : 3/3.
- Résultats des simulations, graines, mesures et réserves : V39_Rapport_IA.md et tests/results/0839/simulation_summary.json.

## Absence de modification des combats
Comparaison des sources avec V38 : seuls new_game, normalize, validate et result_for changent dans engine.gd ; ajout de normalize_difficulty et battle_turn_limit. Les fonctions de combat sont identiques. rules_base.gd, support.gd, intel.gd et edge_navigation.gd restent identiques. Armes, unités, cartes et règles hors durée identiques dans les scénarios actuels. Les suites couvrent notamment cavalerie, artillerie, formations, échanges d’assaut, morale, brouillard et liaisons.

## Interface
Les menus ont été instanciés et les deux boutons Normal/Difficile vérifiés. Les interactions tactiles simulées passent. Géométrie des deux noms Sauer vérifiée à quatre zooms ; captures graphiques inspectées à 0,72, 1,18 et 2,3. Une marge supplémentaire a corrigé le risque de coupure au zoom maximal. La ligne suivie par les lettres a été lissée pour empêcher leur rapprochement excessif dans les virages au zoom éloigné. Les captures se trouvent dans tests/results/0839.

## APK
Version attendue : 0.8.39, versionCode 52, identifiant org.woerth1870.prototype.v02. Export debug signé avec la clé de développement existante. Architectures conservées : armeabi-v7a, arm64-v8a, x86_64. Les vérifications de signature v2/v3, ZIP, métadonnées et alignement 16 Ko sont consignées dans les fichiers apk_* du dossier des preuves. Les ressources de tests et de développement sont exclues de l’APK ; la licence de police est incluse.

## Limites
Aucun téléphone ou émulateur Android testé : installation, performance réelle, lisibilité et gestes sur appareil restent à vérifier. Les simulations comparatives portent sur 14 unités ; aucune campagne complète de 81 unités n’a été rejouée en V39. Les états de liaison mesurés ne prouvent pas à eux seuls une manœuvre d’isolement intentionnelle. Aucun équilibrage des coefficients de cavalerie n’a été effectué.

## Reproduction
Ouvrir project.godot avec Godot 4.5.1. Exécuter les scripts tests/v39/test_lot1.gd, test_lot2.gd et test_capture_opportunity.gd avec --headless --script. tests/v36/run_suite.py lance les régressions ; tests/v39/run_simulations.py lance les six comparaisons et run_balanced.py les deux essais Difficile finaux (run_refined.py conserve le banc des itérations précédentes). Passer le chemin absolu de Godot comme argument aux scripts v39. Les données utilisateur des bancs sont isolées sous /tmp ; les résultats sont copiés dans tests/results/0839.

Les rapports et preuves V38 inclus restent des documents historiques et ne sont pas présentés comme des tests V39.
