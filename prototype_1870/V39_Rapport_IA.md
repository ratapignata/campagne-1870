# V39 — Rapport IA

## Méthode

Six comparaisons finales : deux graines (187037 et 187038), politiques prussiennes V38, Normal et Difficile, 20 tours. Les deux camps agissent. La défense française utilise le script V38 Moyen identique dans toutes les comparaisons. Le terrain et les règles sont identiques ; le scénario réduit comporte 14 unités et un déploiement synthétique sans renforts. La référence V38 est sa politique IA exécutée avec la durée commune de 20 tours, pas un APK V38 inchangé.

**Limite : ce banc ne valide pas une bataille complète de 81 unités ni la situation exacte de la capture fournie. Deux graines ne permettent pas de garantir la supériorité d’une difficulté.**

## Résultats finaux

| Politique | Graine | Objectifs PR / 3 | Score PR / 100 | Pertes FR / PR, prisonniers inclus | Tirs art. PR | Assauts PR | Art. puis tir inf. | Art. puis assaut inf. |
|---|---:|---:|---:|---|---:|---:|---:|---:|
| V38 (20 tours) | 187037 | 3 | 78.64 | 4281 / 4116 | 22 | 6 | 17 | 0 |
| Normal | 187037 | 3 | 79.25 | 4026 / 3423 | 24 | 6 | 14 | 0 |
| Difficile | 187037 | 3 | 86.03 | 5458 / 3711 | 36 | 7 | 44 | 1 |
| V38 (20 tours) | 187038 | 3 | 78.54 | 4314 / 4459 | 21 | 7 | 10 | 0 |
| Normal | 187038 | 3 | 77.87 | 3925 / 3380 | 24 | 3 | 16 | 0 |
| Difficile | 187038 | 3 | 82.16 | 4137 / 4073 | 36 | 3 | 38 | 0 |

Les séquences « artillerie puis infanterie » comptent une même cible attaquée dans le même tour : c’est une mesure de coordination observable, pas la preuve que l’artillerie a causé la réussite de l’attaque.

## Points de passage

| Mode | Graine | Tour | Objectifs PR | Distance moyenne aux objectifs (hex.) | Pertes FR / PR | Art. PR cumulée | Assauts PR cumulés | FR sans cmd. / ravit. / les deux | Débordements* |
|---|---:|---:|---:|---:|---|---:|---:|---|---:|
| Normal | 187037 | 6 | 1 | 2.00 | 1568 / 1940 | 11 | 3 | 2 / 3 / 2 | 4 |
| Normal | 187037 | 11 | 1 | 1.67 | 2769 / 2818 | 18 | 3 | 0 / 0 / 0 | 10 |
| Normal | 187037 | 15 | 1 | 1.40 | 3371 / 3098 | 24 | 5 | 0 / 0 / 0 | 12 |
| Normal | 187037 | 20 | 3 | 0.40 | 4026 / 3423 | 24 | 6 | 2 / 2 / 2 | 12 |
| Normal | 187038 | 6 | 1 | 2.00 | 1557 / 1912 | 11 | 3 | 2 / 3 / 2 | 4 |
| Normal | 187038 | 11 | 1 | 1.67 | 2610 / 2872 | 18 | 3 | 0 / 0 / 0 | 8 |
| Normal | 187038 | 15 | 1 | 1.40 | 3347 / 3144 | 24 | 3 | 0 / 0 / 0 | 10 |
| Normal | 187038 | 20 | 3 | 0.40 | 3925 / 3380 | 24 | 3 | 1 / 0 / 0 | 11 |
| Difficile | 187037 | 6 | 1 | 2.17 | 1468 / 1488 | 11 | 2 | 0 / 0 / 0 | 9 |
| Difficile | 187037 | 11 | 2 | 1.17 | 2184 / 2409 | 18 | 2 | 0 / 0 / 0 | 16 |
| Difficile | 187037 | 15 | 3 | 1.20 | 2978 / 3064 | 26 | 3 | 0 / 0 / 0 | 16 |
| Difficile | 187037 | 20 | 3 | 1.60 | 4268 / 3711 | 36 | 7 | 0 / 2 / 0 | 18 |
| Difficile | 187038 | 6 | 1 | 2.17 | 1484 / 1478 | 11 | 2 | 0 / 0 / 0 | 9 |
| Difficile | 187038 | 11 | 2 | 1.00 | 2254 / 2424 | 18 | 2 | 0 / 0 / 0 | 16 |
| Difficile | 187038 | 15 | 2 | 1.00 | 3113 / 3340 | 26 | 2 | 0 / 0 / 0 | 16 |
| Difficile | 187038 | 20 | 3 | 0.80 | 4137 / 4073 | 36 | 3 | 0 / 0 / 0 | 16 |

*Débordement : indicateur géométrique lorsqu’une unité passe du côté arrière d’un ennemi visible situé à proximité. Il ne prouve pas un encerclement. Les états de commandement/ravitaillement sont mesurés par le moteur réel, mais peuvent résulter du placement, des pertes de QG ou du terrain ; ils ne sont pas tous attribuables à une manœuvre de l’IA.

## Conclusion et réserves

Scores moyens prussiens : V38 78.59, Normal 78.56, Difficile 84.10.
Le mode Difficile obtient un meilleur score moyen que Normal sur ces deux essais ; cela reste un résultat limité à ce banc.

La première itération du lot 2 était plus rapide dans certaines captures mais moins régulière. La révision finale valorise également un objectif capturable hors de l’axe principal. Les six essais initiaux et trois paires de réessais Difficile sont conservés séparément ; aucun résultat défavorable n’a été supprimé.

Les occasions d’attaque légales laissées en fin de tour sont consignées dans idle_attacks. Une attaque légale peut être défavorable ; cet indicateur ne signifie pas automatiquement une erreur ou une unité inutilement inactive. L’inactivité sans attaque disponible n’est pas classifiée.

Les coefficients de combat, les portées, les coûts, le renseignement, les règles de riposte et les liaisons restent identiques. Le comportement cavalerie contre cavalerie n’a fait l’objet d’aucun rééquilibrage.
