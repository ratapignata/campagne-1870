# Test V43.11 depuis le début jusqu’au tour 10

Exécuté le 26 octobre 2026, Godot 4.5.1 officiel, Linux headless. Sources V43.11 commit a9a3d95 ; aucun changement des règles ni de l’IA pendant ces essais. Scénario complet regimental_trial_v43.json : 95 unités déclarées avec leurs renforts, carte et positions initiales intactes. Difficulté Difficile, graine 18704311, style 0. Dix tours chronologiques complets par simulation (20 phases), pas une situation synthétique avancée au tour 10.

## Réponse à la question

**Oui : dans l’essai avec une défense française consacrée à Wœrth, la V43.11 occupe le village au tour 9 et le tient toujours à la fin du tour 10.** Le premier occupant est pru_52, avec 554 hommes. Le village est encore prussien après la phase française du tour 10, puis à la fin de la phase prussienne.

Il s’agit d’une possibilité démontrée avec une graine et une politique défensive de test, pas d’une garantie face à un joueur humain ni d’une fréquence de succès estimée.

## Protocole et résultats

| Essai | Défense française | Première occupation prussienne | Wœrth fin T10 | Contrôles réussis |
|---|---|---|---|---:|
| V43.11 standard | IA française de production, doctrine défensive | T2, village vide | Vide | 1965/1965 |
| Référence V43.10 | Même IA française et mêmes conditions | T2, village vide | Vide | 1965/1965 |
| V43.11 défense de Wœrth | Politique de garnison décrite ci-dessous + IA française habituelle pour les autres unités | **T9** | **Prussien** | 1959/1959 |

Les deux essais standard produisent exactement la même séquence de décisions. Ils ne démontrent donc aucun avantage de la V43.11 par rapport à la V43.10 dans ces conditions. Le village n’est pas initialement défendu et l’IA française privilégie les trois objectifs de victoire : son occupation au T2 ne valide pas une capacité à forcer une garnison.

Pour rendre le second essai plus exigeant, une politique française de test cherche à envoyer légalement une unité d’infanterie sur Wœrth lorsqu’il est vide. Une garnison présente reste sur place pour tirer, rallier, se retrancher ou récupérer des munitions. Les autres unités utilisent l’IA française de production, qui peut manœuvrer et contre-attaquer. Une unité peut ne pas parvenir au village si aucun chemin améliorant sa distance n’est disponible. Aucun soldat n’est ajouté, déplacé par affectation directe ou renforcé artificiellement. L’IA prussienne de production reçoit seulement son observation habituelle et ignore cette politique particulière.

### Chronologie de la défense dédiée

- T1 : fr_9 rejoint Wœrth par déplacements légaux ; 1966 hommes en fin de phase prussienne.
- T4 : la première garnison quitte le village après les tirs prussiens ; Wœrth est vide en fin de phase.
- T5 : pru_43 traverse effectivement Wœrth, puis poursuit jusqu’à l’hexagone 344. Cette traversée est confirmée par rejeu ; elle n’est pas comptée comme une garnison sur place.
- T6 : les Français remettent fr_13 à Wœrth ; le village redevient vide après la phase prussienne.
- T8 : fr_3 occupe Wœrth à la fin du tour, avec 1004 hommes.
- T9 : pru_52 termine un mouvement à Wœrth ; première occupation prussienne après un ordre complet. Elsasshausen et Niederwald sont également prussiens en fin de tour.
- T10 : Wœrth reste occupé par pru_52 ; les trois objectifs de victoire sont prussiens à la fin du tour.

Wœrth reste un passage tactique, **pas un quatrième objectif de score**. « Occupation » signifie présence d’une unité sur son hexagone (13,10) ; un hexagone vide n’a pas de propriétaire persistant pour ce village dans le moteur.

### Actions cumulées, défense dédiée, tours 1 à 10

| Actions | Français | Prussiens |
|---|---:|---:|
| Mouvements | 137 | 244 |
| Tirs d’artillerie | 18 | 111 |
| Tirs d’infanterie | 124 | 79 |
| Assauts | 0 | 9 |
| Pertes militaires selon le moteur | 10902 | 8855 |
| Prisonniers selon le moteur | 524 | 213 |
| Unités en déroute en fin T10 | 1 | 0 |

Les nombres de mouvements sont des ordres, pas des unités distinctes ni des hexagones parcourus. Les métriques par phase, pertes et objectifs sont conservées dans summary.json. Le défenseur est actif (tirs et déplacements) mais n’a effectué aucun assaut dans l’essai dédié ; ce n’est pas un test exhaustif des contre-attaques françaises.

## Vérification et limites

Les trois simulations terminent leurs dix tours sans ordre illégal, état invalide ni dépassement du plafond d’actions : **5889/5889 contrôles**. Chaque ordre est appliqué par le moteur réel et l’état est validé après l’ordre. Le rejeu indépendant du scénario dédié jusqu’à la fin T7 reproduit exactement l’état JSON enregistré : **1243/1243 contrôles**, et confirme la traversée du T5. Ce rejeu n’est pas un second choix autonome de l’IA sur une autre graine.

Une première vérification auxiliaire de rejeu comparait des états après normalisation et échouait à la comparaison finale. Le contrôle a été corrigé pour comparer directement les états JSON enregistrés, sans normalisation supplémentaire ; le rejeu complet correspondant est alors exact. La détection des chemins a également été adaptée aux nombres JSON flottants pour reconnaître l’index entier de Wœrth. Ces corrections concernent uniquement le banc de test.

Chaque simulation dure environ 32 à 33 minutes sur ce serveur avec exécutions concurrentes et validation après chaque ordre. Ces durées ne constituent ni une mesure Android ni un comparatif fiable des performances des versions.

Pas de campagne complète de 20 tours, pas de score final de bataille, pas de test physique Android et pas de reproduction de la partie personnelle du joueur. La graine et le style restent uniques ; plusieurs graines et styles seraient nécessaires pour mesurer la fiabilité de la prise. Le scénario dédié n’a pas été exécuté avec la référence V43.10 : le résultat T9 ne prouve donc pas un gain de délai face à cette version.

Aucun nouvel APK : ces essais portent sur la V43.11 déjà publiée. Les règles de charge, riposte, isolement, commandement, ravitaillement et le score 60/20/20 restent inchangés.

## Reproduction

Les scripts run.gd (standard), reference.gd et defended.gd étendent les utilitaires existants du projet. Passer un chemin absolu au script externe et au résultat, utiliser Godot 4.5.1 avec --headless et --path pointant sur prototype_1870, puis --script /chemin/defended.gd -- /tmp/defended.json. XDG_DATA_HOME et XDG_CACHE_HOME doivent pointer vers des répertoires accessibles en écriture. Le script écrit le rapport après chaque phase et un fichier séparé .state.json. Les rapports publiés sont exclusivement issus des scénarios de test ; aucune sauvegarde personnelle téléchargée n’est publiée ici.
