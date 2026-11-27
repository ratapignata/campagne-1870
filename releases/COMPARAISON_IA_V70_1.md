# Comparaison du feu français — V70 contre V70.1

## Protocole

Deux exécutions chronologiques T2–T4, six phases par exécution, scénario réel de 95 unités déclarées, arrivées normales et carte 30 × 20. Même état de départ T2, graine 669381 / style 0, difficultés françaises Difficile dans les deux cas. Le Normal n’est pas recalibré. L’adversaire prussien est le même contrôleur V43.17 Difficile, actif, soumis au brouillard et aux mêmes règles. Il réagit aux changements de positions : ses ordres ne sont donc pas forcés à rester identiques après divergence.

Le départ est reconstruit depuis les ordres de la simulation IA V70 publiée : 2170 contrôles de relecture native vérifient tous les combats et les 95 positions/effectifs finaux. Le hash canonique de départ est identique dans les deux exécutions : `034ce798907c5662a238c30df19867db42038565424622b46ccf7c82a00b381c`. Le contrôle V70 reproduit aussi les pertes et positions de son ancienne fenêtre T2–T4. Ce n’est pas une reproduction des choix du joueur dans sa partie personnelle.

## Mesures réellement obtenues

| Contrôleur français | Tirs actifs de canon T2–T4 | Pertes directes de ces tirs | Pertes de servants | Pertes militaires françaises cumulées après T4 | Pertes prussiennes cumulées après T4 |
| --- | ---: | ---: | ---: | ---: | ---: |
| V70 Difficile | 5 | 257 | 61 | 2222 | 1141 |
| V70.1 Difficile | 7 | 357 | 32 | 1744 | 1237 |

Les tirs augmentent de 40 %, les pertes directement infligées de 38,9 %. Les pertes de servants diminuent de 47,5 %. Ces nombres excluent les dégâts de riposte des canons ; les pertes militaires excluent les prisonniers. Les deux camps commencent cette fenêtre avec 104 pertes françaises et zéro prussienne ; la colonne des pertes militaires est cumulative. Les prisonniers sont nuls dans les deux cas, tous les objectifs restent français après T4. Aucun bilan de victoire finale n’est présenté.

Six batteries sont vivantes au point de mesure final, qui inclut l’arrivée française du début de T5 déclenchée par la fin du tour prussien 4. Les canons effectivement disponibles pendant les phases françaises T2/T3/T4 sont deux/cinq/cinq. La sixième n’a donc pas participé à ces tirs. Le mouvement et l’occupation des entrées peuvent modifier l’arrivée effective d’un renfort bloqué ; les dates et caractéristiques déclarées n’ont pas changé.

| Batterie | Tirs V70 | Tirs V70.1 | Pertes directes V70 | Pertes directes V70.1 |
| --- | ---: | ---: | ---: | ---: |
| art_fr_Ducrot0 | 1 | 2 | 13 | 31 |
| art_fr_Pellé0 | 2 | 3 | 160 | 241 |
| art_fr_Raoult0 | 2 | 2 | 84 | 85 |
| art_fr_Lartigue0 | 0 | 0 | 0 | 0 |
| art_fr_Conseil-Dumesnil0 | 0 | 0 | 0 | 0 |
| reserve_art_00 | 0 | 0 | 0 | 0 |

Le gain observé vient principalement de Ducrot, qui tire dès T3 au lieu de T4, et de Pellé, qui conserve un tir supplémentaire à T4. Les nouveaux emplacements et les réactions adverses expliquent le déroulement différent. La réserve et Lartigue n’ont pas encore tiré pendant cette courte fenêtre : leur efficacité ultérieure n’est pas déclarée validée.

## Cas ciblés et limites

Une batterie masquée passe de zéro à un vrai tir dans la même phase après un mouvement d’infanterie payé. Un écran double peut être dégagé par deux mouvements payés, avec le même gain zéro→un. Le cas à trois PA paie sa mise en batterie avant le prochain tour et tire réellement ensuite. Les formations retranchées et les garnisons restent en place.

Un premier prototype n’apportait pas de gain dans les phases isolées T5/T8 (trois contre trois, quatre contre quatre). Ces essais intermédiaires ne sont pas présentés comme les résultats du plan final. Le plan final ajoute la distinction de budget trois/quatre PA, la marge de portée et l’anticipation de deux déplacements ; sa comparaison complète porte sur T2–T4, avec les cas ciblés.

Une seule graine et trois tours : pas de garantie de +40 % sur vingt tours, pas de nouvelle bataille complète T1–T8 ou T1–T20, pas de taux de victoire général. Ni essai physique ni émulateur Android. Les phases et ordres complets sont dans tests/results/v70_1 ; les états de test et le relecteur sont fournis pour reproduction.
