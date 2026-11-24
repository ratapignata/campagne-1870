# Analyse de la sauvegarde V43.15 et comparaison de la défense

## Partie personnelle réellement examinée

Export `1870_V43_T20_2026-11-24T19-11-00.json`, version 0.8.43.15, joueur prussien, Difficile/style 0, vingt tours achevés. Checksum et chargement de production vérifiés. Résultat réel : victoire majeure prussienne **90,17 contre 12,78**. Les champs `scores=[59,61]` sont les cumuls de contrôle, pas le score pondéré final.

- Français : 16 574 pertes hors prisonniers, 28 976 prisonniers, aucun homme restant sur le plateau. Le moteur ne distingue pas morts et blessés.
- Prussiens : 13 900 pertes hors prisonniers, 120 prisonniers, 80 980 hommes restants.
- Captures prussiennes : Wœrth T2, Niederwald T13, Frœschwiller T16.
- Neuf redditions françaises au T10, soit 12 889 prisonniers dans cette seule vague. Plusieurs régiments avaient encore presque leur effectif initial, par exemple 1 982 hommes pour `fr_10`.
- Premières coupures de la droite française relevées dès T6–T7 ; QG Lartigue détruit au T7. Les autres QG français sont détruits aux T13–T14.

Ces informations confirment l’effondrement par isolement et perte des réseaux, au-delà de la seule attrition. Le fichier final ne contient pas tous les déplacements humains ni un état complet à chaque tour : **la partie personnelle n’a pas été rejouée exactement**. Son export original n’est pas publié dans les sources.

## Causes dans le code

`tactical_ai.gd / choose` bloque la sortie d’une garnison qui tient son objectif avec ses deux liaisons. `french_defence.gd / movement` protège fortement une position retranchée ou un couvert doté d’un tir. Ces décisions raisonnables contre une attaque frontale ne considéraient pas assez la fermeture progressive des arrières. Les missions de secteur ne suffisaient pas à traiter une pénétration vers les QG ou l’entrée de ravitaillement.

La correction est limitée aux décisions françaises Difficile. Elle utilise l’observation nettoyée de production, les règles existantes de trajet, les liaisons propres connues et des estimations de risque. Elle ne révèle ni ennemi caché ni véritable réseau ennemi.

## Réglage initial rejeté

Cinq réglages intermédiaires ont été rejetés : les premiers ont fait tomber Frœschwiller trop tôt, dès T7 au lieu de T11 ; les suivants ne préservaient pas suffisamment les objectifs ou encourageaient des replis trop profonds. Aucun n’a été livré. Le rejeu des ordres d’un essai rejeté a identifié une garnison évacuant trop tôt un objectif majeur sous menace et des missions de protection insuffisamment limitées. Le réglage retenu privilégie désormais un décrochage court vers une seconde ligne sûre, garde si possible des PA et une ligne de tir, protège le premier défenseur affecté à chaque objectif, limite la réserve à l’entrée de ravitaillement fixe et conserve la garnison de trois points tant que ses liaisons sont bonnes. Il tient compte de la valeur de l’objectif avant de décider le repli. La dernière révision réutilise aussi la puissance défensive réelle du moteur au lieu des seuls effectifs bruts, pour ne pas abandonner une position dont le couvert et les retranchements compensent la pression adverse. Les tests des réglages abandonnés ne sont pas comptés comme des résultats finaux.

## Fermeture ciblée d’un piège

Dix unités de caractéristiques originales, carte de test en plaine avec deux bois, six tours. Les Prussiens exécutent les mêmes mouvements légaux de fermeture autour de l’hexagone d’origine, puis tiennent l’anneau. L’IA française joue ses vraies décisions. Ce cas vérifie une anticipation précise, pas un taux de victoire contre un adversaire adaptatif.

| Graine | Prisonniers du régiment V43.15 | V43.16 | Hommes restant au régiment V43.16 |
| --- | ---: | ---: | ---: |
| 18704316 | 1947 | 0 | 1934 |
| 18704317 | 1945 | 0 | 1933 |

Les mouvements et les redditions sont résolus par le véritable moteur. Pas de téléportation, de neutralisation des ZOC ou de bonus de force.

## Deux simulations sur vingt tours contre l’IA prussienne active

Scénario **synthétique de 29 unités** sélectionnées dans l’ordre de bataille, avec positions modifiées et arrivées avancées à T1. Carte 30 × 20, Sauer, terrains, trois objectifs et caractéristiques individuelles conservés. 14 750 Français contre 25 500 Prussiens. Il ne s’agit ni de la partie personnelle ni de la bataille chronologique principale de 95 unités. Dans les JSON, l’identifiant historique `elsasshausen` désigne l’objectif Wœrth de deux points, conservé sans modification. Même adversaire prussien V43.15 Difficile, même graine et style 0 ; l’adversaire adapte ses ordres aux positions effectivement rencontrées.

| Graine / défense | Pertes France hors prisonniers | Pertes Prusse hors prisonniers | Prisonniers français | Unités françaises restantes | QG français restants | Objectifs français finaux | Score final Prusse |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: |
| 18704316 / V43.15 | 9512 | 6094 | 0 | 7 | 3 | Aucun | 84.73 |
| 18704316 / V43.16 | 10187 | 5927 | 0 | 7 | 3 | Aucun | 86.31 |
| 18704317 / V43.15 | 8968 | 5990 | 0 | 7 | 2 | Aucun | 83.99 |
| 18704317 / V43.16 | 9437 | 6058 | 0 | 8 | 3 | Aucun | 84.80 |

Le score prussien moyen passe de 84.36 à 85.55. Sur ces deux déploiements synthétiques, la correction ne démontre donc pas une défense globalement plus difficile : le gain ciblé contre la fermeture du piège ne se traduit pas par un meilleur résultat final. La candidate reste séparée de la stable et ne constitue pas un remplacement validé de V43.15.

Première capture prussienne de chaque objectif (`None` signifie non capturé dans le cas) :

| Graine / défense | Wœrth | Frœschwiller | Niederwald |
| --- | ---: | ---: | ---: |
| 18704316 / V43.15 | 4 | 11 | 14 |
| 18704316 / V43.16 | 4 | 10 | 12 |
| 18704317 / V43.15 | 4 | 11 | 14 |
| 18704317 / V43.16 | 4 | 11 | 13 |

Le test de fermeture confirme une correction ciblée. Les deux simulations avec adversaire adaptatif ne suffisent pas à démontrer une hausse générale de difficulté : les résultats complets ci-dessus doivent être lus avec cette réserve. Aucune fusion avec la branche stable n’est réalisée.

Les historiques complets et les reprises éventuelles figurent dans les JSON ; une première capture ne signifie pas nécessairement un contrôle final. Les redditions peuvent aussi rester nulles dans les deux variantes : le test ciblé précédent sert à mesurer le cas précis de fermeture.

## Performances et limites

- 18704316 / V43.15 : médiane 626.0 ms, maximum 2318 ms par décision française.
- 18704316 / V43.16 : médiane 511.0 ms, maximum 2223 ms par décision française.
- 18704317 / V43.15 : médiane 596.0 ms, maximum 2319 ms par décision française.
- 18704317 / V43.16 : médiane 601.0 ms, maximum 2450 ms par décision française.

Temps cloud Linux partagé avec processus concurrents et charges variables, pas benchmark Android ni preuve d’un écart intrinsèque de vitesse. Aucun test sur appareil ou émulateur. Style 0 et deux graines sur ce scénario : pas de taux de victoire universel.

Le scénario principal de 95 unités a été lancé chronologiquement sur **deux tours** avec chaque politique, mêmes graine et adversaire. Cela vérifie son démarrage et ses décisions légales, pas une bataille principale complète T1–T20. Le scénario, ses renforts, ses 95 000 Allemands et ses règles restent byte-identiques. La difficulté globale face à un humain doit être confirmée lors d’une nouvelle partie.
