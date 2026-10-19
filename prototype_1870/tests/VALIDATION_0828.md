# 0.8.28 — Essai régimentaire partiel

45 pions français, 36 prussiens. France : 19 régiments d’infanterie, 5 bataillons de chasseurs, 10 régiments de cavalerie, 6 groupes d’artillerie, 5 QG. Prusse : 16 régiments d’infanterie, 2 bataillons de chasseurs, 4 régiments de cavalerie, 10 groupes d’artillerie, 4 QG. Les contingents bavarois et wurtembergeois ne sont pas encore intégrés. Ce n’est donc pas l’ordre de bataille complet de Wœrth.

Noms issus du registre documentaire atelier06/13. Effectifs de simulation, positions, rattachements de cavalerie aux QG d’infanterie, regroupements de batteries et tours d’arrivée sont des ADAPTATIONS GAMEPLAY. Aucun effectif affiché n’est présenté comme un état historique vérifié. Les fractions absentes du 21e, 50e, 74e de ligne et du 6e lanciers sont prises en compte par des réductions de test, non par une prétendue conversion exacte des effectifs historiques. Voir historical_roster.json dans le dossier de préparation pour les références Kunz pages 2–4 et réserves documentaires.

Renforts disponibles aux tours 1, 3, 4 ou 5 selon groupe, au début de leur camp. Une case occupée retarde l’entrée jusqu’à un prochain début de tour ; aucun occupant n’est déplacé. Les unités en attente ne combattent pas, ne sont pas visibles et ne sont pas transmises à l’IA. Leurs effectifs ne sont pas comptés comme pertes. Un bref message annonce les entrées du joueur.

Sauvegarde séparée save_regimental0828.json. L’ancienne carte d’essai reste dans les sources et dans la recherche de sauvegardes. Les modes classique et trois objectifs restent disponibles. Le nouveau mode occupe le troisième choix « Régiments · Essai ».

Tests automatiques : moteur 181/181, interface 23/23, régression ancien scénario historique 68/68. Sauvegardes avant/après arrivées, cases d’entrée occupées, observation IA sans réserves, début et fin des 18 tours, sélection/déploiement des canons, reprise après fermeture du banc d’interface. Deux décisions IA initiales : 764 ms / 1092 ms sur la machine de développement. Ce n’est pas un test complet de combat ni une mesure Android.

Le banc UI signale à sa fermeture deux ressources encore utilisées, comme dans la version précédente ; ses assertions passent. Aucun test visuel ou physique Android réalisé ici. Équilibrage et durée réelle à tester par le joueur.

APK : package conservé, versionCode 41, versionName 0.8.28. Signature et alignement vérifiés. Installer par-dessus sans désinstaller.
