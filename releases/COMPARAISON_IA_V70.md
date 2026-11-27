# Comparaison V70 — scénario réel T1–T8

Deux simulations chronologiques du scénario complet, 95 unités déclarées, carte originale, arrivées et caractéristiques originales, graine 669381/style 0 et Chassepot quatre dans les deux cas. France : Normal (ancienne V43.17 Difficile figée) ou nouvelle Difficile V70. Prusse : même contrôleur V43.17 Difficile figé, attaquant actif soumis à l’observation autorisée et aux règles natives. Aucune défense ou attaque immobile.

Ces simulations utilisent la graine de l’export humain, mais ne reproduisent pas les choix du joueur prussien. Elles ne sont ni sa partie rejouée exactement ni deux campagnes complètes à vingt tours. La même situation initiale et le même contrôleur adverse ne signifient pas des actions identiques après divergence des positions.

| Politique française | Tirs de canon T1–T8 | Pertes directes infligées par ces tirs | Batteries vivantes après la phase prussienne T8 | Servants restants | Attelages | Pertes militaires France hors prisonniers | Pertes Prusse hors prisonniers |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Normal / V43.17 figée | 22 | 853 | 6 | 1300 | 5 | 7199 | 5780 |
| Difficile V70 | 21 | 741 | 6 | 1382 | 5 | 7985 | 6762 |

| Politique | Première capture prussienne de Wœrth | Frœschwiller | Niederwald | Contrôle après T8 : Wœrth / Frœschwiller / Niederwald |
| --- | ---: | ---: | ---: | --- |
| Normal | 3 | — | — | Prusse / France / France |
| Difficile | 5 | — | — | Prusse / France / France |

La clé interne `elsasshausen` désigne bien Wœrth dans les JSON, avec deux points ; noms, positions et pondérations ne sont pas modifiés. Une première capture ne garantit pas une occupation continue, d’où le contrôle après T8.

## Lecture des résultats

Le nouveau Difficile retarde Wœrth de deux tours et inflige au total 6 762 pertes militaires aux Prussiens contre 5 780 (+17 %). Il subit lui-même 7 985 pertes contre 7 199 ; les prisonniers français passent de 587 à zéro. Les trois objectifs ont les mêmes propriétaires à la fin de T8. Ce sont des échanges et une durée de résistance différents, pas une victoire générale démontrée.

**L’artillerie est mieux préservée dans cet essai, mais son activité et ses dégâts ne progressent pas : 21 tirs contre 22, 741 pertes directes contre 853.** Les pertes de servants passent de 200 à 118 (−41 %), avec six batteries vivantes dans les deux cas. Les attelages restent au nombre de cinq : aucune réduction de leur total n’est démontrée. Les nouvelles décisions de placement/protection fonctionnent dans les cas ciblés ; un gain général de puissance de feu n’est pas validé. V70 doit être considérée comme un essai à comparer en partie, avec cette limite connue, sans bonus artificiel ajouté pour masquer le résultat.

Les compteurs portent sur des ordres réellement exécutés, pas des préférences. Les tirs de canon sont actifs, hors ripostes. Un attelage peut être nécessaire ; son nombre seul ne mesure pas l’inefficacité. Le compteur de tir légal en fin de phase contrôle les PA, l’état, la portée, la visibilité et la LOS au moment où l’IA décide de finir, pas toutes les occasions antérieures.

Les objectifs, prisonniers et captures par tour figurent dans `tests/results/v70/comparison.json`, et les deux rapports complets conservent toutes les phases et ordres. Le détail par batterie indique ses tirs, ses positions au moment des tirs, ses pertes et ses effectifs restants. Les pertes directes de canon excluent les ripostes et les prisonniers. Une meilleure activité ou une meilleure survie des canons n’implique pas automatiquement une meilleure tenue des objectifs. Les résultats doivent être lus ensemble et confirmés face à un joueur humain.

Temps mesurés sur Linux cloud partagé, pas mesures de fluidité Android. Une seule graine et huit tours par politique ; pas de taux de victoire général. Les diagnostics ajoutés sont exclusivement des scripts de test, sans instrumentation permanente dans le moteur de combat.
