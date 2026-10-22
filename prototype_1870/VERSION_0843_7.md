# V43.7 — Cavalerie en défense dans un village

Réglage explicitement validé par l’utilisateur le 22 octobre 2026 : facteur de défense de la cavalerie en village réduit de 1,50 à **1,25**. Version Android 0.8.43.7, code 64.

## Règle appliquée

Le profil de cavalerie du scénario V43 définit désormais terrain_assault_defence.village = 1.25. Le moteur utilise cette surcharge pour les puissances de mêlée en défense. Elle s’applique aux deux camps et aux différents types d’assaillants, uniquement lorsque le défenseur est une cavalerie sur un village. Ce n’est pas une réduction générale des effectifs ou un bonus national.

Les terrains des scénarios archivés et leurs profils restent inchangés. L’infanterie conserve le facteur 1,50 en village, l’artillerie ses règles existantes. Pas de changement en plaine ou sur les autres terrains. Charge à 2 PA, pénalité de charge vers un village 0,55, tirs, ripostes, moral, isolement, reddition, score 60/20/20, 20 tours et variante B 0,90 conservés. Aucune modification des scripts IA ; leur évaluation de puissance bénéficie normalement du même calcul corrigé que les combats.

## Sauvegardes

Nouvelle empreinte du scénario ; l’empreinte précédente V43.1–V43.6 est explicitement acceptée dans save_migrations et les anciennes compatibilités restent présentes. Aucun format modifié. Les positions, pertes, état et historique existants sont conservés ; les futurs combats emploient le nouveau coefficient. Le chargement ne rejoue pas les combats passés.

Ta sauvegarde réelle T14 V43.6 a été chargée par le moteur actuel, validée, copiée dans un emplacement de test et rechargée à l’identique ; fichier original resté intact. Cette sauvegarde personnelle n’est pas publiée dans les sources.

## Vérifications

Godot 4.5.1 : 229/229 contrôles de non-régression sur neuf suites : nouveau facteur village et migration 20 ; encerclement 25 ; liaisons strictes 22 ; isolement/retraite/reddition 45 ; brouillard 18 ; renforts voisins/Raoult 32 ; interface 30 ; export 28 ; retour EOF Android 9.

Le banc comparatif de 256 configurations (64 graines, deux camps, anneau initial complet ou ouvert d’une case) est relancé sur le moteur livré, sans modifier les terrains du banc pour obtenir artificiellement 1,25. Il réussit 4 596/4 596 contrôles, avec des événements identiques au banc expérimental validé : la position est prise dans 49/64 graines par camp et par disposition, et tient dans 15/64. Le total des contrôles automatisés est de **4 825**. Ses résultats et les événements complets sont fournis dans tests/results/0843_7. Il utilise des cavaliers frais de 400 hommes, aucun retranchement ; les retraites peuvent ouvrir l’anneau. Ces situations synthétiques ne remplacent pas une bataille complète.

APK compilé et signé avec le même certificat de développement. Aucune nouvelle bataille complète ni test physique Android réalisé pour ce correctif. Les vérifications sur serveur ne constituent pas une certification de l’équilibre global.

## Installation

Installer l’APK par-dessus la version existante, sans la désinstaller, pour conserver les sauvegardes. Corrections V43.5/V43.6, chiffres de force sur les pions et export JSON conservés.

## Fichiers modifiés

war_engine/core/engine.gd ; packs/1870/regimental_trial_v43.json ; project.godot ; export_presets.cfg ; packs/1870/fr.json. Nouveau test : tests/v43/test_cavalry_village125.gd et fixture du scénario précédent. Rapport et preuves : VERSION_0843_7.md et tests/results/0843_7.
