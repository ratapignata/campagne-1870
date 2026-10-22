# Partie réelle T20 — débordement de l’aile droite française

## Sources et limites

Deux sauvegardes personnelles réellement examinées : export T20 du 22 octobre à 18:09:13 et export T14 précédent. Les deux proviennent de V43.6, avant le réglage cavalerie de V43.7. La capture est T13. Le fichier T20 ne contient pas tous les états de position intermédiaires : on ne peut pas prétendre reproduire exactement la capture T13.

Checksum T20 correct, état final chargé et validé avec Godot 4.5.1. Aucun fichier personnel brut ni capture personnelle republié. Les fichiers originaux ne sont pas modifiés.

## Résultat final confirmé

Victoire mineure française : 69,359509 contre 27,821368. Objectifs finaux français : Frœschwiller (3) et Elsasshausen (2). Niederwald (1) pris par la Prusse au tour 19. Décomposition dans l’ordre objectifs / durée / pertes adverses : France 50 + 15,666667 + 3,692842 ; Prusse 10 + 4,333333 + 13,488035. Le moteur refuse la victoire majeure faute d’avantage militaire requis, malgré la marge au score.

Pertes enregistrées : France 30 396 pertes militaires et 323 prisonniers sur 45 550 hommes initiaux ; Prusse 15 634 pertes militaires et 1 907 prisonniers sur 95 000. Ces chiffres expliquent pourquoi il faut distinguer manque de conquêtes et absence d’efficacité des tirs : le feu prussien a infligé des pertes importantes.

## Activité prussienne réellement enregistrée

| Tour | Tirs | Dont artillerie | Assauts d’infanterie | Charges |
|---|---:|---:|---:|---:|
| 6 | 29 | 18 | 2 | 0 |
| 9 | 30 | 16 | 0 | 0 |
| 12 | 30 | 16 | 0 | 0 |
| 15 | 18 | 13 | 1 | 0 |
| 18 | 24 | 10 | 3 | 0 |
| 19 | 33 | 12 | 1 | 0 |
| 20 | 33 | 15 | 2 | 1 |

Ces événements ne fournissent pas les mouvements individuels historiques. Ils confirment une forte activité de feu mais une faible conversion en assauts et conquêtes, notamment aux tours 9 et 12.

## Le passage proposé existe

Niederwald est en (18,6), Albrechtshäuser en (22,7). Dans le T14 réel, la bande des colonnes 20 à 22 et rangées 7 à 10 comprend plusieurs cases libres de cultures/plaine à l’est du bois. Les cases (21,7), (21,8), (21,9), (22,8) sont libres. Cela rend plausible un axe de débordement ; ce n’est pas une preuve qu’une attaque y réussirait sans protection des liaisons.

Un test supplémentaire utilise une copie instrumentée du moteur courant et le T14 réel. Hypothèse explicite : terminer la phase française sans nouvel ordre, puis demander UNE décision prussienne. Ce n’est ni le tour réel T13 ni une bataille complète, et la suite des choix du joueur n’est pas connue. L’instrumentation rend exactement la même première décision que l’IA originale.

Les règles de cheminement donnent alors :

- pru_41 en (19,10) peut atteindre légalement (21,8) par (20,11), (21,10), (21,9). Elle ne peut pas atteindre (21,7) dans ce même budget.
- pru_47 en (18,11) et reserve_07 en (18,10) peuvent atteindre (21,9), mais pas (21,8) dans ce budget. Le transit ordinaire par un ami est permis ; la destination doit rester libre.

L’approche existe donc sur plusieurs tours : elle nécessite une planification, pas une nouvelle règle de mouvement ou un bonus de PA.

## Freins constatés dans l’IA

1. **Détours évalués à trop court terme.** pru_47 a 17 destinations libres, mais son meilleur mouvement reçoit −113,525 ; la composante de progression est −67,025. Elle propose un changement de formation. Le détour latéral peut être utile à l’axe tout en éloignant temporairement de l’objectif.
2. **Liaisons.** reserve_07 a 24 destinations libres, mais sa meilleure destination reçoit −40,245, dont −90 liés au commandement. La solution est d’amener un QG et de préparer le passage, pas de supprimer la pénalité. reserve_08 est déjà en double coupure, avec 2 PA et des assauts refusés pour isolement.
3. **Tirs préférés à un assaut accepté.** reserve_04 estime un assaut contre fr_9 à 1,3579 pour un seuil 1,25. L’offre d’assaut est 136,161, mais le tir vaut 138,05. L’algorithme peut donc consommer les PA d’un assaut acceptable dans une succession de tirs.
4. **Objectifs plutôt qu’axes de manœuvre collectifs.** mission_goal choisit les objectifs par valeur, coût d’approche, pression visible et centre du groupe. Il n’existe pas de mission persistante « déborder entre Niederwald et Albrechtshäuser », avec unités affectées, QG, batteries et cases à libérer.
5. **Artillerie active mais coordination partielle.** Les batteries orientales ont des cibles légales et proposent des tirs. Il serait faux de dire qu’elles ne tirent pas. Il manque surtout une liaison explicite entre leur cible, le verrou de l’axe et l’assaut à effectuer ensuite.

Fonctions concernées : war_engine/ai/tactical_ai.gd choose, mission_goal, approach_distances, exploitation_value ; planification de QG et conservation d’axe à examiner dans war_engine/ai/planning_engine.gd. Aucun script IA de production n’est modifié dans cette livraison.

## Correction proposée pour validation

P0 : attribuer en Difficile un axe secondaire à un groupe lorsque l’axe principal est saturé et qu’un itinéraire légal vers un objectif existe. Conserver une mission sur plusieurs tours, accepter un détour temporaire justifié par cet itinéraire, réserver/libérer les débouchés. Éviter les oscillations et ne pas disperser toute l’armée.

P0 : accompagner l’axe par son QG via des mouvements légaux et vérifier les liaisons aux étapes projetées. Affecter de l’artillerie aux défenseurs observés qui bloquent ce passage. Ne pas pénétrer volontairement en double coupure sans solution réaliste.

P1 : comparer les séquences feu–assaut aux tirs répétés ; conserver assez de PA pour l’assaut lorsque celui-ci est légal et tactiquement acceptable. Ne pas diminuer aveuglément les seuils de rapport de forces.

P1 : intensifier progressivement la pression selon le temps restant et les objectifs encore nécessaires. Préserver Normal, n’introduire aucun renseignement caché ni bonus de dégâts, de PA ou de riposte.

Validation nécessaire : mêmes états T14 et scénarios contrôlés d’aile faible, aile piégée, passage occupé, QG trop loin et défense française active ; comparer objectifs, mouvements, franchissements, assauts, pertes, PA inutilisés et temps de calcul sur plusieurs graines. Vérifier les états avancés sans les présenter comme un historique complet. Ne pas modifier les seuils de victoire majeure pour obtenir artificiellement un autre résultat.
