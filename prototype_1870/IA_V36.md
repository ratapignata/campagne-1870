# Évaluation IA V36

Godot 4.5.1. Aucun changement de `tactical_ai.gd`, `legacy_ai.gd` ou `ai_profiles.json` par rapport à V35 ; aucun bonus caché. IA prussienne offensive, IA française défensive. Les deux camps prennent leurs décisions avec `observation(side)` ; le moteur arbitre ensuite les actions légales.

## Scénarios reproductibles

`tests/v36/test_ai_active.gd` définit exactement 14 unités : 7 françaises (5 infanteries dont trois garnisons, un QG, un canon français), 7 prussiennes (4 infanteries, une cavalerie, un QG, un Krupp). Les effectifs proviennent des unités V35 retenues. La carte historique 30 × 20, ses reliefs, ses bois/villages, sa rivière et ses objectifs restent inchangés ; les déploiements et le regroupement de commandement sont des **fixtures de test**, pas une reconstitution historique.

- **A/B — AB_active** : départ au tour 1, graine 187036, difficulté moyenne, deux IA actives pendant les 18 tours. Défense française occupée aux trois objectifs, tirs et reprise d'objectif possibles. Le résultat évalue simultanément l'attaque prussienne et la défense française.
- **C — C_turn12** : état synthétique au tour 12, graine 187012, difficulté moyenne. Elsasshausen déjà prussien, pertes de 30 % pour quatre unités, moral dégradé et munitions partiellement dépensées. Sept tours réellement joués, aucune affirmation sur les onze tours précédents.
- **D — brouillard** : 18 comparaisons de mondes cachés (deux camps × trois difficultés × observation/décision/absence de mutation). Une position ou des pertes ennemies cachées différentes produisent la même observation et la même décision. Les cas de LOS testent aussi une unité masquée par le relief.
- **E — E_final** : état synthétique au tour 17, graine 187018, difficulté difficile. Deux tours réellement joués jusqu'à la fin. Le score utilise les coefficients 60/20/20 sans créditer une durée de contrôle fictive avant le départ.

Les renforts du scénario complet de 81 unités sont vérifiés séparément par le contrat et le banc UI. Ces trois batailles actives **ne démontrent pas** l'efficacité sur une simulation chronologique complète de 81 unités.

## Mesures exécutées

Les nombres comptent les commandes acceptées ; les assauts comprennent les charges lorsque choisies. Les pertes sont les pertes de personnel calculées par le moteur ; les prisonniers sont relevés séparément.

| Scénario | Tours terminés | Mouvements FR / PR | Tirs FR / PR | Assauts FR / PR | Pertes FR / PR | Prisonniers FR / PR | Maximum d'unités en déroute FR / PR |
|---|---:|---:|---:|---:|---:|---:|---:|
| A/B | 18 | 28 / 81 | 78 / 85 | 0 / 2 | 3513 / 3367 | 0 / 0 | 1 / 1 |
| C | 7 (12–18) | 16 / 39 | 44 / 23 | 1 / 1 | 2122 / 3033 | 0 / 0 | 1 / 0 |
| E | 2 (17–18) | 5 / 13 | 14 / 4 | 0 / 1 | 1256 / 1899 | 0 / 0 | 1 / 0 |

Les pertes C/E incluent l'attrition injectée dans l'état synthétique de départ. Aucune reddition dans ces trois simulations. Les redditions sont couvertes par les tests spécifiques du lot 3.

**Captures constatées :**

- A/B : Frœschwiller pris par la Prusse au tour 2, repris par la France au tour 4, repris par la Prusse au tour 7. Elsasshausen prussien au tour 18. Niederwald reste français.
- C : Elsasshausen déjà prussien dans la fixture ; Frœschwiller capturé au tour 13 et Niederwald au tour 14. Les trois objectifs finissent prussiens.
- E : Elsasshausen déjà prussien ; Frœschwiller capturé au tour 18. Niederwald reste français.

| Scénario | Score FR / PR | Résultat PR | Cause d'absence de victoire majeure |
|---|---:|---|---|
| A/B | 28,2652 / 65,7851 | Victoire mineure | Avantage de pertes 0,06118 inférieur au seuil 0,10 |
| C | 6,7031 / 71,4649 | Victoire mineure | Avantage de pertes −0,05820 |
| E | 14,5431 / 54,0267 | Victoire mineure | Avantage de pertes −0,04434 |

Le score C/E est celui d'un état synthétique dont seuls sept/deux tours de durée ont été enregistrés. Il n'est pas comparable au score d'une bataille chronologique de 18 tours. Les parties finales, durées et pertes sont conservées dans les JSON de résultats.

Répartition finale : nombre d'unités vivantes classées par l'objectif le plus proche, **pas une affectation de mission**.

| Scénario | France : Frœschwiller / Elsasshausen / Niederwald | Prusse : Frœschwiller / Elsasshausen / Niederwald |
|---|---|---|
| A/B | 2 / 3 / 1 | 1 / 3 / 3 |
| C | 3 / 4 / 0 | 2 / 3 / 1 |
| E | 2 / 4 / 1 | 1 / 4 / 2 |

## Inactivité et diagnostic

Le rejeu observe les possibilités autorisées à la fin de chaque demi-tour. Aucun tir/assaut immédiatement légal n'est laissé inutilisé dans les trois simulations. En revanche, 30 occurrences unité/demi-tour dans A/B, 10 dans C et 6 dans E disposent d'un déplacement légal rapprochant d'un objectif ennemi. Ce compteur est un **indicateur**, pas une preuve qu'une réserve aurait dû avancer : il ne juge pas tout le risque tactique. Des garnisons sont volontairement conservées en place (2, 5 et 5 de ces occurrences).

Un cas préoccupant est reproduit : **`pru_38` en [13,4], tours 10 à 17, 16 quarts de PA inutilisés**, avec Elsasshausen [15,4] comme objectif assigné. Au tour 10, l'IA termine le tour. Le script `test_ai_diagnosis.gd` rejoue les décisions et instrumente une copie du code IA **en mémoire seulement**, sans modifier le fichier de production.

Cause observée : les déplacements sont notés pour un seul objectif assigné (`mission_goal`), puis filtrés par `score > minimum_move`. Les 53 candidats légaux de cette unité ont tous une note inférieure au seuil 3. Meilleure note : **−3,2833** ; le déplacement vers [16,4], qui améliore le chemin vers Elsasshausen, vaut **−15,3583**, avec une menace observée passant de 0 à 230. La combinaison progression/couverture/menace/liaisons, ainsi que la concentration sur un objectif unique, explique l'absence d'ordre. Ce n'est pas un manque de PA ni un ordre refusé.

**Proposition pour une version ultérieure :** lorsqu'une unité offensive n'a aucun mouvement acceptable vers son objectif prioritaire, évaluer également un autre objectif encore ennemi. Garder les mêmes règles d'information, budgets et contrôles de danger, puis comparer exactement les mêmes graines avant/après. Ce choix affecterait la coordination et nécessite une validation de doctrine. Il n'est **pas implémenté** dans V36. Aucun coefficient d'agressivité n'est modifié, aucune comparaison après correction n'est revendiquée.

## Validation et fichiers

- A/B : 40/40 assertions ; C : 18/18 ; E : 8/8. Toutes les commandes ont été acceptées et les états aux frontières de tour validés.
- Rejeu des trois batailles : 660/660 assertions ; résultats finaux identiques.
- Diagnostic au tour 10 : 258/258 assertions.
- Mondes cachés V35/V36 : 18/18 ; compatibilité IA : 18/18.
- Quatre batailles supplémentaires du test historique moral/IA : 544 actions, 244 tirs, 16 assauts, 43/43 assertions. Elles utilisent leur fixture historique réduite et ne constituent pas des simulations à 81 unités.

`tests/results/0836/AB_active.json`, `C_turn12.json` et `E_final.json` contiennent graines, commandes exactes, compteurs, captures et mesures à chaque frontière. Les fichiers `*_analysis.json` contiennent les occasions d'inactivité, déroute maximale et actions tactiques. `AI_diagnosis.json` contient les scores des candidats du cas immobile.

Reproduction, après import du projet :

```sh
godot --headless --path . --script res://tests/v36/test_ai_active.gd -- AB_active
godot --headless --path . --script res://tests/v36/test_ai_active.gd -- C_turn12
godot --headless --path . --script res://tests/v36/test_ai_active.gd -- E_final
godot --headless --path . --script res://tests/v36/test_ai_replay.gd
godot --headless --path . --script res://tests/v36/test_ai_diagnosis.gd
```

Utiliser Godot **4.5.1**. Les nouvelles simulations écrivent leurs mesures dans `user://`; elles ne remplacent pas automatiquement les résultats livrés dans `res://tests/results/0836/`.
