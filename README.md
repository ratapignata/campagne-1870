# Campagne 1870 — introduction BD expérimentale, essai 2

Version `0.8.43.15-bd2`, branche **v43-intro-bd-experimental**, base V43.15 + graphismes 12. Réparation des illustrations tronquées et récit historique développé, sans modification du jeu.

## Télécharger

- **[APK Android — essai BD 2](https://raw.githubusercontent.com/ratapignata/campagne-1870/v43-intro-bd-experimental/experiments/intro-bd/essai-02/1870_V43_Intro_BD_Experimental_02.apk)**.
- [Sources complètes ZIP](experiments/intro-bd/essai-02/1870_V43_Intro_BD_Experimental_02_Sources.zip).
- [Captures avant/après et six tableaux](prototype_1870/captures/introbd2/README.md).
- [Rapport](experiments/intro-bd/essai-02/INTRO_BD_EXPERIMENTAL.md), [tests exécutés](experiments/intro-bd/essai-02/TESTS_INTRO_BD.md), [repères historiques](experiments/intro-bd/essai-02/SOURCES_HISTORIQUES_BD.md), [fichiers modifiés](experiments/intro-bd/essai-02/FICHIERS_INTRO_BD.txt).

**Installer par-dessus « 1870 · Essai introduction BD » précédent sans désinstaller**, pour conserver sa partie. Même paquet/certificat, code Android 2. L’application de jeu stable et l’essai graphique restent séparés. Leur partie n’est pas transférée automatiquement dans l’application BD.

## Corrections

Les anciens JPEG étaient eux-mêmes tronqués : le cadre affichait déjà toute l’image disponible. Six compositions ont été réparées à partir des références, sans phrases coupées ni nouveau recadrage. Reconstitutions graphiques, pas récupération exacte de pixels manquants ; les six JPEG originaux restent archivés intacts dans les sources.

Six étapes conservées, récit développé : 1866 et Confédération de 1867, rivalités, retrait de la candidature espagnole le 12 juillet, Ems le 13 et diffusion du texte abrégé, crédits du 15, déclaration du 19 juillet, mobilisation. Bibliographie et limites explicites ; aucune BD de la bataille de Frœschwiller-Wœrth ajoutée.

Zone de lecture élargie, hauteur du titre ajustée, texte défilant avec indice si nécessaire. Lecture automatique **30 secondes**, avec défilement doux du paragraphe dépassant ; passage immédiat et cinq commandes conservés. Continuer reprend toujours la sauvegarde directement, sans charger les illustrations. Les règles, IA, graphismes de bataille et sauvegardes ne changent pas.

**3 085 contrôles actuels réussis**, archive extraite/importée/vérifiée indépendamment, APK compilé et signature vérifiée. Aucun essai physique ou émulateur Android, aucune nouvelle simulation complète de bataille. Pas de fusion avec main ; [branche graphique 12 conservée](https://github.com/ratapignata/campagne-1870/tree/v43-graphismes-2d-experimental). [Livraison BD 1 conservée](experiments/intro-bd/essai-01/).

![Illustration réparée et récit développé](prototype_1870/captures/introbd2/scene_1.png)

![Développement de la dépêche d’Ems](prototype_1870/captures/introbd2/scene_4.png)
