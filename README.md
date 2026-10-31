# Campagne 1870 — introduction BD expérimentale V43

Branche **v43-intro-bd-experimental**, version `0.8.43.15-bd1`. Base : dernières sources complètes V43.15 + graphismes expérimentaux 12. [La version graphique 12 reste inchangée sur sa branche](https://github.com/ratapignata/campagne-1870/tree/v43-graphismes-2d-experimental) ; [main reste la stable](https://github.com/ratapignata/campagne-1870/tree/main).

## Téléchargements

- **[APK Android — Essai introduction BD](https://raw.githubusercontent.com/ratapignata/campagne-1870/v43-intro-bd-experimental/experiments/intro-bd/essai-01/1870_V43_Intro_BD_Experimental_01.apk)**.
- [Sources intégrées complètes ZIP](experiments/intro-bd/essai-01/1870_V43_Intro_BD_Experimental_01_Sources.zip).
- [Captures des six tableaux et du parcours](prototype_1870/captures/introbd1/README.md) ou [galerie ZIP](experiments/intro-bd/essai-01/1870_V43_Intro_BD_Captures_01.zip).
- [Rapport d’intégration](experiments/intro-bd/essai-01/INTRO_BD_EXPERIMENTAL.md), [tests réellement exécutés](experiments/intro-bd/essai-01/TESTS_INTRO_BD.md), [fichiers modifiés](experiments/intro-bd/essai-01/FICHIERS_INTRO_BD.txt).

## Essayer sans remplacer le jeu actuel

L’APK installe une **application distincte**, « **1870 · Essai introduction BD** », paquet `org.woerth1870.prototype.introbdexp`. Ne désinstaller aucune application existante. **La partie actuelle reste dans son application ; elle n’est pas transférée automatiquement.** Les parties créées dans cet essai se reprennent directement avec Continuer, sans revoir la BD. Le format de sauvegarde V43 reste inchangé et testé.

Menu → introduction générale (six tableaux) → fiche existante de configuration de la bataille → choix du camp → scénario. Suivant, Précédent, Passer l’introduction, Lecture automatique et Retour au menu. Passage immédiat possible pendant le fondu ; lecture en arrière-plan suspendue ; images chargées à la demande et libérées en quittant l’introduction.

Les six illustrations et textes fournis sont conservés. Les fragments de texte coupés sont déjà dans les JPEG originaux. **La présentation BD spécifique de Frœschwiller-Wœrth n’a pas été fournie ; elle n’est pas développée ni considérée comme terminée.** La fiche existante le précise.

Aucun changement de gameplay, d’IA, de combat, de sauvegarde ou d’animation de bataille. Graphismes 12, pions historiques, coche en haut à droite et fonctions des bandeaux conservés. Aucune fusion avec main avant validation.

## Vérifications

Prototype seul 35/35 ; parcours intégré avec rendu/toucher 168/168 ; reprise dans un processus séparé 9/9 ; treize suites de régression 5 725 contrôles réussis. Archive extraite/importée/vérifiée séparément. APK compilé et signature vérifiée. Aucun essai Android physique ou émulateur, aucune nouvelle simulation complète de bataille. Avertissement audio de fermeture préexistant dans une ancienne suite UI, également reproduit sur la base sans introduction : détails dans le rapport.

![Premier tableau intégré](prototype_1870/captures/introbd1/scene_1.png)

![Sixième tableau intégré](prototype_1870/captures/introbd1/scene_6.png)
