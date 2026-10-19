# Raoult — diagnostic et correction V43

Base exacte : archive V42 Lot 8 finale du 18 octobre, application 0.8.42.1, code 56. Les sources originales restent dans une copie distincte, inchangées. Godot utilisé : 4.5.1.

## Reproduction déterministe

Graine 187037, style 0, scénario Lot 8 non modifié, France immobile. Le scénario contient 95 identifiants uniques. Raoult porte l’identifiant qg_fr_Raoult, camp français, effectif 250, entrée (15,4) prévue au tour 3. Il n’est donc pas attendu aux tours 1 ou 2.

Une politique de test dirige uniquement la cavalerie pru_55 vers cette entrée avec les fonctions réelles de cheminement, de déplacement, de découverte et de changement de phase. Ce n’est pas une preuve que l’IA choisit toujours cet itinéraire. La cavalerie commence en (17,15), atteint (22,7) au tour 1 et (15,4) au tour 2, après plusieurs interruptions de reconnaissance. Aucun PA ni position n’est restauré artificiellement. L’autre cavalerie testée, pru_54, ne bloque pas cette entrée avant le tour 3 dans ce parcours.

Les commandes et PA effectivement consommés figurent dans tests/results/0843/raoult_report.json. Les états intermédiaires sont validés. Au début français du tour 3, l’hexagone est occupé par pru_55 : Raoult demeure pending, avec force zéro, et n’occupe pas la case. Aucun échange d’identité ou empilement n’a lieu.

Une fois la cavalerie déplacée légalement au tour prussien 3, Raoult entre au prochain début français, tour 4, exactement en (15,4). Sa visibilité pour son propre camp est immédiate. La sauvegarde physique de l’attente, son chargement et la poursuite de l’arrivée sont testés. Un QG détruit ne réapparaît pas comme renfort.

## Cause et portée de la correction

Le report d’un renfort sur une entrée occupée est un comportement explicitement prévu dans arrive_reinforcements, pas une disparition par brouillard. Cette reproduction ne révèle aucun défaut de déplacement ni de déploiement. Modifier le tour, déplacer le QG, expulser l’occupant ou réserver cette case aurait changé les règles : aucune de ces modifications n’est faite.

Le défaut d’information est confirmé : V42 n’expliquait pas le report du QG. V43 affiche son arrivée prévue dans le journal, puis son entrée occupée et la prochaine tentative au début du tour suivant. Un avis apparaît au changement de tour. Seuls les calendriers des QG du joueur sont exposés ; le message n’identifie pas l’occupant caché. Le terrain du défenseur est maintenant explicite dans l’aperçu d’une charge.

La case (15,4) est un **village**, élévation 2. Les cases d’attaque (16,4) et (15,5) sont de la plaine : cela ne transforme pas la case défendue en plaine. Le pion masque visuellement une partie du village. La force de charge de 400 cavaliers est ainsi 400 × 1,6 × 0,55 = 352, contre 400 × 1,5 = 600 en défense. Les deux premiers assauts de la reproduction réelle sont repoussés avec respectivement 32/76 puis 32/70 pertes défenseur/attaquant, sans tir de riposte au sabre.

## Limite explicite

V43 ne garantit pas l’entrée de Raoult tant que la case reste occupée. C’est la règle conservée, désormais expliquée. Aucun « correctif » ne supprime artificiellement la présence prussienne. Si un autre cas survient en véritable plaine avec des caractéristiques différentes, il faudra sa sauvegarde pour le reproduire exactement.

Validation ciblée : 40/40 contrôles. Les comparaisons de cavalerie, les sauvegardes et l’interface sont détaillées dans COMBATS_V43.md et TESTS_V43.md.
