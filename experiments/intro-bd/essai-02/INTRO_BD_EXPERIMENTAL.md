# Introduction BD expérimentale — essai 2

Version `0.8.43.15-bd2`, 31 octobre 2026. Même branche `v43-intro-bd-experimental`, à partir de l’essai BD 1 (source `bf21d49`, publication `dbf1601`), lui-même basé sur la dernière V43 + graphismes 12. Main et branche graphique conservées.

## Image coupée : cause et correction

Le cadre de l’essai 1 affichait déjà le JPEG entier. Les fragments tronqués étaient présents dans le fichier fourni ; agrandir le cadre ne pouvait pas récupérer la partie absente de la planche originale.

Les six illustrations présentant ce défaut ont été recomposées à partir des références, à l’aide de l’outil de génération/retouche d’images : grands textes coupés supprimés, composition élargie, sujets principaux dégagés. Il s’agit d’une reconstitution graphique, pas de la récupération exacte de pixels perdus ni d’une image d’archives. Les six JPEG d’origine sont archivés intacts dans `development/intro_bd_source/assets`, avec le prototype autonome original.

Les nouveaux PNG sont affichés entièrement, proportions respectées et sans nouveau recadrage. Le fond du premier tableau est une carte d’ambiance sans frontières politiques revendiquées. La dernière scène est un montage symbolique des deux armées ; elle ne représente pas une marche commune réelle. Voir `intro_bd/PROVENANCE.md`.

## Développement historique

Six titres et six étapes conservés ; paragraphes réécrits et développés, 59 à 65 mots chacun : Sadowa/1866 et Confédération/1867 ; rivalités d’influence sans guerre prétendument inévitable ; candidature espagnole et retrait du 12 juillet ; Ems le 13 puis diffusion du texte abrégé ; crédits du 15 et déclaration du 19 juillet ; mobilisation et concentration des armées.

Les textes ne sont pas un scénario de bataille ajouté. La BD propre à Frœschwiller-Wœrth reste non fournie et non développée. Références et limites : `SOURCES_HISTORIQUES_BD.md`. La chronologie a été recoupée dans l’ouvrage historique accessible ; aucune consultation de site institutionnel bloqué n’est revendiquée.

## Lecture sur smartphone

Répartition plus équilibrée entre image et récit ; hauteur du titre adaptée au texte pour libérer de la place. Police du récit 25 en hauteur normale, 22 en format compact. Texte défilant si nécessaire avec indication visible. Les cinq commandes restent à leur place, boutons de 58 pixels logiques, passage immédiatement disponible.

Lecture automatique portée de 9 à **30 secondes par tableau**, pour laisser lire les paragraphes développés. Si le texte dépasse, il défile doucement après huit secondes, atteint les dernières lignes en quatorze secondes supplémentaires, puis laisse un temps de lecture avant la suite. Un glissement du doigt rend la lecture manuelle. Fondus toujours 0,65 seconde ; pause/reprise en arrière-plan et arrêt des animations/timers en quittant l’introduction.

Textures importées au maximum à 1280 pixels, compression de texture qualité 0,85 ; sources PNG complètes conservées. Images chargées uniquement en lançant la BD et références libérées à la sortie. Continuer n’en charge aucune. Aucun traitement d’image par frame ni nouvelle animation pendant la bataille.

## Jeu et sauvegardes

Moteur, IA, plateforme, scénario, scène principale, contrôleur de lancement du jeu et modules graphiques 12 identiques à l’essai BD 1. Aucun coût, charge 2 PA, riposte, liaison, isolement, reddition, renfort, score 60/20/20, objectif, durée de 20 tours, sauvegarde ou animation de combat modifié. Pions historiques, coche et bandeaux conservés.

APK de **mise à jour de l’application BD**, même nom « 1870 · Essai introduction BD », paquet `org.woerth1870.prototype.introbdexp`, même certificat, code Android 2. **Installer par-dessus l’essai BD 1 sans désinstaller**, pour conserver sa partie. Les applications stable/graphique restent séparées ; leurs sauvegardes ne sont pas transférées automatiquement. Continuer charge directement une partie déjà enregistrée, sans imposer la BD.

## Livrables et limites

Sources complètes, captures `captures/introbd2/README.md`, tests `TESTS_INTRO_BD.md`, liste `FICHIERS_INTRO_BD.txt`, APK signé de développement. Anciennes galeries non dupliquées dans le ZIP ; code, ressources de jeu et originaux du prototype conservés. Aucun cache, compilation ou temporaire dans les sources.

Aucun test physique Android ou émulateur ; aucun nouveau test chronologique complet de bataille. Illustrations évocatrices, pas une expertise des uniformes, armoiries ou frontières. Aucun changement de gameplay, aucune fusion avec main.
