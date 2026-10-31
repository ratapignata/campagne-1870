# Introduction BD expérimentale — V43, essai 1

Version `0.8.43.15-bd1`, 31 octobre 2026. Branche **`v43-intro-bd-experimental`**, issue des dernières sources complètes disponibles : V43.15 + graphismes expérimentaux 12, commit source `a8652b5` / publication `ec50397`. Vérification des branches distantes réalisée avant modification. Ni main ni la branche graphique ne sont modifiées.

## Prototype examiné et testé seul

Le ZIP fourni contient un projet Godot 4.3+, une scène `intro.tscn`, un script, un README et six JPEG de 850 × 590. Il s’agit d’une scène qui enchaîne **six tableaux**, et non de six fichiers de scène distincts. Import et exécution indépendante sous Godot 4.5.1 réussis : 35/35 contrôles, six captures et un vrai intervalle automatique de neuf secondes.

Limites confirmées : pas de retour au menu, boutons de 31 pixels de haut, navigation suivante restant désactivée après la fin puis un retour en arrière. Les JPEG contiennent déjà des fragments de texte coupés sur leurs bords. Les six fichiers image, titres et textes historiques sont conservés à l’identique ; aucun nouveau recadrage ni image recréée. Leurs empreintes sont fournies. Les textes demeurent ceux du prototype, sans nouvelle validation historique revendiquée.

## Parcours intégré

Menu principal → introduction générale → fiche de configuration du scénario existante → choix du camp → début du scénario.

La BD comporte : une Europe en transformation ; deux puissances rivales ; la candidature Hohenzollern ; la dépêche d’Ems ; la déclaration de guerre ; la mobilisation. Navigation Suivant/Précédent, passage immédiat, lecture automatique activable/désactivable (9 s par tableau), retour au menu. Retour Android renvoyant au menu. Fin/passage émis une seule fois ; timers et fondus arrêtés en quittant l’écran. La lecture se suspend en arrière-plan.

La fiche de configuration conserve les difficultés, paramètres et choix de camp existants. **La présentation BD particulière de Frœschwiller-Wœrth n’a pas été fournie et n’est pas développée ni considérée comme terminée.** Cette absence est indiquée dans la fiche. Aucun nouveau récit de bataille n’est inventé.

Continuer/reprendre une sauvegarde donne directement accès à la partie. Une nouvelle partie reste soumise à la confirmation existante lorsqu’une sauvegarde est présente. Consulter puis abandonner l’introduction ne remplace pas cette sauvegarde ; seul le choix explicite d’un camp lance la nouvelle partie.

## Présentation et ressources

Paysage, images entières sans déformation dans un cadre, texte séparé lisible/défilant, boutons de 58 pixels logiques de haut, style bleu nuit/ivoire/or de la V43, fondu de 0,65 s. Tests de disposition à 1280 × 606, 1280 × 720, 1520 × 720.

Chargement à la demande : reprendre une sauvegarde ne charge aucune des six illustrations. Les références aux images sont libérées après la sortie de l’introduction, avant de jouer. Un timer et un fondu léger ; aucune nouvelle animation pendant la bataille, aucun traitement d’image par frame. Pas de voix, de musique supplémentaire ou d’animation de personnages ajoutée. Pas de benchmark Android ni promesse de fluidité sur appareil non testé.

## Préservation du jeu

Code core, IA, plateforme, scènes de jeu, données de bataille, animations et modules graphiques 12 inchangés. `main.tscn` reste la scène principale. Dans le script principal, seules les entrées de menu/nouvelle partie, le bouton de nouvelle partie au résultat, le retour Android pendant l’introduction et la note sur la BD manquante changent. `new_game`, `resume`, combats, sauvegarde et IA conservent leur code.

IA Normal/Difficile, charge 2 PA, artillerie, ripostes, liaisons, isolement/reddition, QG Raoult, variante B, 20 tours, trois objectifs 3/2/1 et score 60/20/20 conservés. Pions historiques, coche en haut à droite, bandeaux et commandes de l’essai 12 conservés ; aucun bouton TIRER ajouté.

## Installation et sauvegardes

L’APK est une **application distincte**, « **1870 · Essai introduction BD** », paquet `org.woerth1870.prototype.introbdexp`, code Android 1. Il s’installe à côté de la stable et de l’essai graphique ; ne désinstaller aucune application existante. Répertoire desktop séparé `1870-prototype-introbd`.

L’application actuelle et sa partie restent intactes. **Ses sauvegardes ne sont pas transférées automatiquement** dans la nouvelle application Android. Le format V43 reste compatible ; chargement direct testé avec une sauvegarde V43 dans l’espace de l’application d’essai, ainsi qu’avec les anciennes fixtures. Les parties créées dans cet essai se reprennent avec Continuer, sans introduction.

## Livraison et limites

Sources complètes intégrées, captures `captures/introbd1/README.md`, tests `TESTS_INTRO_BD.md`, liste des fichiers `FICHIERS_INTRO_BD.txt`, APK signé de développement. Les anciennes galeries graphiques ne sont pas dupliquées dans le ZIP ; aucun code ni ressource nécessaire au jeu n’est omis. Caches, compilations et temporaires exclus.

Aucun test sur appareil Android physique ou émulateur. Aucune nouvelle simulation complète de bataille. Fragments de texte coupés déjà présents dans les illustrations originales ; une nouvelle planche propre serait une amélioration future, hors de cette intégration. Aucun contenu spécifique de bataille inventé, aucune fusion avec main.
