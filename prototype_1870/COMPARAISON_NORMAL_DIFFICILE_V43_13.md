# V43.13 — comparaison Normal / Difficile, joueur français

## Conditions

Deux simulations autonomes réellement lancées depuis T1 jusqu’à la fin T10, scénario complet de 95 unités avec renforts. Même carte, mêmes positions initiales, mêmes objectifs Frœschwiller 3 / Wœrth 2 / Niederwald 1, même graine 18704311 et style 0. Godot 4.5.1 officiel. Les deux parties sont encore en cours au T11 : ce ne sont pas des batailles complètes de vingt tours.

Le Normal utilise l’IA Difficile V43.11 conservée, qui réagit aux nouveaux objectifs. Le Difficile utilise les corrections V43.13 et conserve son calendrier prussien avancé d’un tour, déjà autorisé en V43.12. La comparaison mesure l’ensemble du mode ; elle n’isole pas l’effet de chaque modification.

La défense française est active : une politique de test cherche à tenir Wœrth par déplacements légaux, tirs, ralliement et retranchement. Les autres unités emploient l’IA française défensive de production et peuvent manœuvrer et contre-attaquer. Ce n’est pas une reproduction des décisions d’un joueur humain. Aucun soldat, bonus de dégâts, PA ou renseignement n’est ajouté.

## Activité prussienne cumulée, dix tours

| Mesure | Normal | Difficile |
|---|---:|---:|
| Tirs de canon actifs | 117 | **144** |
| Tirs d’infanterie actifs | 91 | **106** |
| Tirs actifs totaux | 208 | **250** |
| Assauts | 15 | **29** |
| Mouvements | 297 | 315 |
| Mises en batterie | 13 | 13 |
| Attelages | 9 | 3 |

Le Difficile effectue **23,1 % de tirs de canon supplémentaires** et **93,3 % d’assauts supplémentaires**, avec les mêmes coûts d’action. Les tirs d’infanterie augmentent de 16,5 %. Les chiffres comptent les ordres actifs réellement exécutés par le moteur, hors ripostes automatiques ; ils ne comptent pas les projectiles cosmétiques de l’animation.

## Situation en fin T10

| Mesure | Normal | Difficile |
|---|---|---|
| Wœrth | Prussien, première prise T4 | Prussien, première prise T4 |
| Niederwald | Prussien, contrôle en fin T8 | Prussien, contrôle en fin T8 |
| Frœschwiller | Encore français | **Prussien en fin T8** |
| Valeur totale d’objectifs prussienne | 3 sur 6 | **6 sur 6** |
| Pertes françaises, hors prisonniers | 11 976 | 15 407 |
| Prisonniers français | 2 427 | 327 |
| Pertes prussiennes, hors prisonniers | 9 041 | 9 899 |
| Prisonniers prussiens | 1 090 | 275 |

Pertes militaires totales (casualties + prisonniers, définition du moteur) : Français 14 403 en Normal contre 15 734 en Difficile ; Prussiens 10 131 contre 10 174. L’augmentation des assauts comporte donc des pertes de combat prussiennes supplémentaires, compensées en grande partie par moins de prisonniers prussiens dans cet essai.

Le score calculé au T10 reste **provisoire**, niveau pending : Normal 39,30 pour les Français / 39,16 pour les Prussiens ; Difficile 7,81 / 71,24. Ce n’est pas un résultat final de bataille. Le contrôle des objectifs peut encore changer pendant les dix tours restants.

## Cause confirmée du défaut des batteries

Dans la précédente simulation V43.12, les quatre batteries Schachtmeyer/Gersdorff n’avaient effectué aucun tir et avaient poursuivi leurs mouvements jusqu’aux arrières français. Sur un test de position identique, l’ancienne décision attelle ou déplace une batterie malgré un tir légal dans son secteur ; la nouvelle décision tire ou déploie puis tire. La mission de pont centrale ne détourne plus inutilement une batterie de l’aile droite.

Sur la présente comparaison, les quatre batteries de l’aile droite totalisent **46 tirs en Difficile contre 26 en Normal**. Leur stabilisation dans des positions utiles contribue à la hausse globale. Les autres batteries totalisent 98 contre 91. Le détail par batterie est dans tests/results/0843_13/comparison.json.

Pour l’infanterie, un test contrôlé montre qu’un mouvement conserve les 3 PA d’assaut nécessaires et qu’une instance d’IA rétablie depuis le plan sérialisé lance ensuite l’assaut légal. Un plan avec des PA déjà dépensés est rejeté. Cela évite de remplacer cette attaque préparée par un simple tir contre une autre cible.

## Interprétation et limites

Dans ce protocole, le Difficile exerce une pression nettement supérieure sur le camp français : davantage de tirs de canon et d’assauts, davantage de pertes françaises et Frœschwiller pris avant la fin du test. Les résultats ne prouvent pas une supériorité pour toutes les graines, styles ou défenses humaines. Une validation sur vingt tours et sur smartphone reste utile.

La position des objectifs a changé pour les deux modes : les anciens chiffres V43.12 avec Elsasshausen à deux points ne doivent pas servir de comparaison directe de difficulté. Les données map, units, weapons et rules restent identiques à V43.12 ; seuls les objectifs et les métadonnées de compatibilité du scénario changent.

Les données brutes de propriétaires conservent l’identifiant interne elsasshausen pour le deuxième objectif, afin de préserver les historiques des sauvegardes. Dans ces nouvelles parties, cet identifiant correspond à **Wœrth**, comme le précisent les définitions du scénario et les métadonnées d’export. Les anciennes parties chargées conservent au contraire leur ancienne disposition et leurs scores.

Aucun essai physique Android et aucun benchmark fiable de performances sur appareil. Les durées serveur incluent des validations après chaque ordre et des exécutions concurrentes.
