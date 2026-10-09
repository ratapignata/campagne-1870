# Tests V38 — résultats exécutés

Godot réellement utilisé : 4.5.1.stable.official.f62fdbde1. Java 21, SDK Android 35, build-tools 35.0.1, templates officiels Godot 4.5.1. Exécution headless, données utilisateur isolées hors des sources.

## Régressions

Les 26 suites de référence ont été exécutées. Résultat final : 26 suites réussies, 2 186 assertions validées. Les tests historiques restent inchangés.

La première passe a échoué dans test_multi_objectives, test_cavalry085 et test_morale_ai : le champ facultatif d’historique était mal validé après lecture JSON, qui transforme les nombres en décimaux. Le contrôle accepte désormais les nombres entiers JSON avant normalisation ; les trois suites concernées ont été réexécutées avec succès, ainsi que les sauvegardes. Les sorties initiales et corrigées sont conservées dans les preuves. Aucun test n’a été désactivé pour obtenir ce résultat.

## Tests V38

- Stabilisation : 140/140. Reproduction des 74 premières commandes de la bataille V37 puis correction du cycle Sandrart ; coûts de déplacement réels ; intention périmée refusée ; danger de cavalerie observée ; observation inchangée ; aucun calendrier de renfort ennemi ; sauvegarde avec événements d’historique ; champs absents acceptés et événements invalides refusés ; géométrie de Sauer ; déplacement du texte et de chaque extrémité de la flèche à quatre zooms ; terrain inchangé.
- UI : 9/9. Objectifs nommés, captures chronologiques et capitulations, anciennes sauvegardes, objectif sans name_key, indications de PA et reddition, historique inaccessible pendant la bataille.
- Renforts : 5/5. Entrée dégagée par un mouvement légal, aucun renfort anticipé, arrivée réelle au tour prévu et sur la case originale.
- Sauvegarde V37 réelle : 5/5. Le fichier de fin de bataille livré en V37 charge, demeure exactement identique et peut être sauvegardé puis repris par V38.
- Budget d’artillerie : 9/9. Sur une situation synthétique sans commandement mais ravitaillée, le canon français dispose réellement de 3 PA à son nouveau tour ; une cible est réellement observée ; déploiement à 1 PA ce tour, aucun tir gratuit, tir à 3 PA au suivant.

Le premier test de lecture UI cherchait des Label alors que le composant utilise RichTextLabel ; son échec a été corrigé dans le test et les assertions maintenues. Le premier montage du test de budget utilisait le premier tour avant application de la pénalité et une cible hors reconnaissance ; le montage a été corrigé en passant réellement au nouveau tour et en plaçant une cible observée. Ces échecs de montage ne sont pas présentés comme des anomalies du moteur.

## Simulations

Les scénarios réduits utilisent 14 unités, une implantation synthétique sur la vraie carte et les règles actuelles, sans renforts. Ils ne constituent pas une reproduction chronologique de la bataille historique à 81 unités. France moyenne active, Prusse facile/moyenne/difficile : deux graines identiques 187037 et 187038, chacune jusqu’au tour 18. Les scénarios français difficiles sont également comparés à V37 avec une Prusse moyenne active.

Les décisions faciles et moyennes sont identiques à V37 sur les deux graines de référence. Les six simulations terminées valident 5 090 contrôles, sans échec. Les deux simulations avec défense française difficile valident 1 558 contrôles. Le mode difficile n’est pas systématiquement plus performant : voir BATAILLE_V38.md.

C_turn12 est un état synthétique débutant au tour 12, pas une chronologie rejouée depuis 08 h 00. E_final débute synthétiquement au tour 17. Les deux simulations ont réellement terminé : C_turn12 18/18 et E_final 8/8. Le nom V36 du banc historique est conservé dans ses sorties ; ces exécutions utilisent les sources V38.

La campagne historique réelle termine les 18 tours : 1 434 décisions, 1 547/1 547 contrôles. Les deux camps moyens jouent activement. Une reprise au checkpoint du tour 4 a permis de poursuivre après correction de validation JSON ; les commandes des 18 tours sont conservées. Le rejeu indépendant depuis le scénario initial réussit 2 877/2 877 contrôles, reproduit la sauvegarde finale et vérifie une sauvegarde/reprise réelle au tour 12. Sur 81 unités déclarées, 80 sont entrées ; le QG Raoult reste en attente à son entrée occupée. Ce n’est pas une disparition d’unité.

Les cinq nouveaux bancs totalisent 168 assertions ; avec les 26 suites historiques, 2 354 assertions passent. Les contrôles de simulation et de rejeu sont comptés séparément.

## Archive et Android

Une préarchive propre a été extraite dans un autre dossier : import réussi, sauvegardes 43/43, contrat 110/110, interface tactile 11/11. Le contrôle indépendant de l’archive finale est consigné dans tests/results/0838/archive_verification.json. Son contenu est comparé aux sources publiées.

L’APK 0.8.38, versionCode 51, est exporté en mode debug et signé avec le certificat de développement identique à V37. Contrôles exécutés : vérification ZIP, signature v2/v3, zipalign avec pages de 16 Ko, inspection des segments ELF des bibliothèques 64 bits, métadonnées Android et présence de la licence de police. Ces vérifications ne constituent pas un essai sur appareil.

## Non réalisés et limites

Aucun téléphone ou émulateur Android n’est disponible : installation, essai tactile physique, lisibilité finale de Sauer et cadrage de Reichshoffen sur appareil ne sont pas validés. La flèche est ancrée sur la carte ; elle peut nécessiter un défilement selon le zoom. Les performances mesurées sont celles du cloud, pas celles d’un smartphone.

Aucune doctrine n’est qualifiée de systématiquement supérieure à partir de deux graines. Les coûts, les ripostes, les scénarios, les seuils de victoire et les profils de coefficients sont conservés. Les fonctions mécaniques du moteur restent identiques : 78 fonctions inchangées, cinq modifiées uniquement pour l’historique, sa validation et l’observation ; une surcouche de capture enregistre l’événement après la capture existante.

L’import de l’archive dans une configuration vierge signale que le répertoire Android build-tools n’y est pas configuré. Cela n’empêche ni l’import ni les tests ; l’export réel utilise la configuration Android installée et réussit.
