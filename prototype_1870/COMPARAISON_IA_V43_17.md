# Comparaison reproductible V43.17

## Protocole principal

Quatre simulations T1–T20 complètes, graine 918536/style 1, même adversaire prussien V43.16 Difficile, observation nettoyée et mêmes règles de déplacement, combat et réseau. Politique française Normal (V43.16 figée) ou nouvelle Difficile, chacune avec portée Chassepot 3 puis 4. Le calendrier moteur est commun. Ce sont des déploiements synthétiques de **29 unités**, dont **deux batteries françaises**, sur la carte originale 30 × 20 : 14 750 Français contre 25 500 Prussiens, positions modifiées et arrivées à T1. Ce ne sont ni la partie personnelle rejouée ni quatre batailles chronologiques du scénario principal de 95 unités.

| France / portée | Tirs canon | Retranchements | Assauts | Pertes France hors prisonniers | Pertes Prusse hors prisonniers | Prisonniers français | Français restants | Score Prusse |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Normal / 3 | 12 | 36 | 1 | 8730 | 6780 | 0 | 6020 | 84.17 |
| Difficile / 3 | 18 | 48 | 1 | 8532 | 5881 | 0 | 6218 | 84.40 |
| Normal / 4 | 7 | 35 | 1 | 9438 | 5972 | 0 | 5312 | 86.63 |
| Difficile / 4 | 17 | 51 | 2 | 7126 | 4984 | 779 | 6845 | 85.39 |

À portée quatre commune, l’activité des canons passe de **7 à 17 tirs**, soit **×2.43**. Les retranchements passent de 35 à 51. Il s’agit d’ordres réellement exécutés par le moteur, pas de scores de préférence ou de tirs supposés. Le nombre de retranchements ne mesure pas à lui seul leur utilité : un même régiment peut reconstruire après déplacement.

Première capture prussienne :

| France / portée | Wœrth | Frœschwiller | Niederwald |
| --- | ---: | ---: | ---: |
| Normal / 3 | 4 | 10 | 13 |
| Difficile / 3 | 4 | 9 | 12 |
| Normal / 4 | 4 | 8 | 10 |
| Difficile / 4 | 4 | 7 | 8 |

Les reprises et pertes ultérieures figurent dans `comparison.json` et les historiques complets : une première capture ne signifie pas toujours un contrôle final. Les objectifs finaux et les pertes doivent être lus ensemble. L’adversaire adapte ses décisions au monde effectivement rencontré ; mêmes conditions initiales ne signifie pas mêmes actions ultérieures.

## Portée des conclusions

La priorité à l’artillerie et l’activité de préparation sont mesurées. Le comportement défensif global doit aussi être jugé sur les captures, les pertes, les prisonniers et le score, pas seulement sur le nombre de coups de canon. Certains cas perdent leurs objectifs tôt malgré davantage de survivants et de tirs. Aucun taux de victoire général ni garantie de difficulté supérieure dans chaque situation n’est revendiqué sur cette seule graine et ce déploiement.

Passer à quatre hexagones n’améliore pas automatiquement le résultat : la ligne de tir, les positions, la formation et les réactions de l’adversaire modifient le déroulement. La variante reste une expérience à comparer en jeu.

## Cas ciblé de batterie masquée

Six unités de caractéristiques originales, une batterie française déployée sur un objectif, son écran d’infanterie retranché immobile bloquant la LOS, un QG, deux attaquants prussiens et leur QG. Terrain de test en plaine, un objectif, visibilité complète, six tours. Seule la batterie est pilotée par les politiques françaises ; l’écran conserve ses ripostes. Les Prussiens sont un attaquant scripté actif identique dans les deux cas, soumis aux vrais coûts/LOS/combats. Ce cas isole le repositionnement et n’est pas une simulation de toute la doctrine.

| Graine | Tirs Normal | Tirs Difficile |
| --- | ---: | ---: |
| 918536 | 2 | 2 |
| 18704317 | 2 | 2 |

Ce contrôle peut ne montrer aucun gain de volume malgré un repositionnement différent : les pertes, l’approche de l’ennemi et les budgets réels limitent les occasions. Il n’est pas utilisé pour annoncer artificiellement un multiplicateur général.

## Scénario principal et limites

Deux démarrages chronologiques du véritable scénario de **95 unités**, sur T1–T2 : un par politique à portée quatre. Vérification des arrivées, préparations, décisions et états légaux. Cela ne remplace pas une bataille principale complète T1–T20. La partie humaine T20 fournie a été chargée et contrôlée, pas rejouée exactement : tous les mouvements historiques ne sont pas enregistrés.

Plusieurs réglages intermédiaires ont été écartés pendant les mesures de positionnement et de conservation des objectifs. Leurs simulations interrompues ou leurs résultats partiels ne sont pas comptés comme finaux. Les derniers changements réduisent la suraffectation des réserves contre de petites incursions et évitent l’évacuation réflexe d’un point majeur au premier constat non confirmé.

Les contrôles Normal ont démarré avant une correction de conversion du seul champ optionnel `completed_turn_limit` lors du chargement des parties terminées. Les simulations sont toutes de nouvelles parties et n’utilisent pas ce champ ; leurs politiques et leurs règles effectives sont identiques à celles de la livraison. La correction de chargement a été vérifiée séparément, notamment sur l’export personnel. Pas de nouvelle mécanique en cours de simulation.

Temps cloud Linux partagé, sans comparaison de fluidité Android. Aucun essai physique ou émulateur. Le comportement face à un joueur humain actif reste à confirmer sur de nouvelles parties.
