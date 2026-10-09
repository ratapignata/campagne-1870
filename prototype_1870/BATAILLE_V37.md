# Bataille complète V37

Simulation chronologique exécutée avec Godot 4.5.1 : scénario historique original 30×20, **81 unités déclarées**, deux IA actives, difficulté moyenne, graine **187037**, style 0. Aucun état synthétique au tour 12 ; déploiement, calendrier des renforts, terrain, portées et brouillard originaux.

**18 tours achevés**, 1372 décisions acceptées, 76.65 minutes de calcul cloud. Aucun état invalide ni commande rejetée. 80 unités sont effectivement entrées ; le QG Raoult est resté en attente sur sa case occupée.

| Indicateur | Français | Prussiens |
|---|---:|---:|
| Mouvements | 202 | 245 |
| Tirs actifs | 210 | 208 |
| Assauts | 14 | 16 |
| Pertes au combat | 12970 | 14624 |
| Prisonniers | 0 | 236 |
| Maximum simultané en déroute | 2 | 1 |
| En déroute à la fin | 1 | 0 |
| Score final | 14.95249 | 77.36151 |

Les mouvements et tirs sont les commandes IA acceptées ; les réactions défensives ne sont pas comptées comme tirs actifs. Les pertes et prisonniers sont des hommes, pas des unités. La répartition finale et les relevés de chaque demi-tour figurent dans le JSON.

## Objectifs et résultat

- Frœschwiller : première capture prussienne au tour 6.
- Elsasshausen et Niederwald : captures prussiennes au tour 11.
- Trois objectifs prussiens à la fin, sans reprise enregistrée.
- Victoire prussienne **mineure**. Le score 60/20/20 est conservé ; le critère militaire supplémentaire de victoire majeure n’est pas satisfait (`reason=losses_close`, avantage relatif négatif). Aucun seuil changé.

| Composante | Français | Prussiens |
|---|---:|---:|
| Objectifs finaux (60) | 0.00000 | 60.00000 |
| Pertes adverses (20) | 6.61915 | 5.69484 |
| Durée de contrôle (20) | 8.33333 | 11.66667 |

## Renfort en attente et correction du test

**Le test initial a produit 1 échec sur 1 484 contrôles** : il exigeait que tous les renforts soient entrés. Les autres 1 483 contrôles, dont les validations après chaque commande et la reprise physique finale, ont réussi. Le journal et le rapport initiaux sont conservés sans modification ; le script initial est archivé en texte.

Le QG français Raoult doit entrer au tour 3 en [15,4]. Cette entrée était occupée par `fr_8`, puis, en fin de bataille, par `pru_40`. `engine.gd / arrive_reinforcements` prévoit explicitement qu’une entrée occupée attend, sans téléportation ni déplacement de son occupant. Le moteur n’a pas été modifié. La vérification finale du test publié accepte les renforts entrés ou encore légalement bloqués ; ce prédicat est exécuté dans le rejeu du résultat réel.

Limite du scénario/IA : aucune libération volontaire de cette entrée n’a permis l’arrivée du QG. L’impact sur le commandement doit être évalué avant toute modification du déploiement ou de la doctrine. La simulation porte sur les 81 unités déclarées originales, avec ce renfort effectivement absent du champ de bataille.

## Reproductibilité et limites

`full_battle_report.json` contient toutes les décisions, captures, temps de calcul et mesures par demi-tour. `full_final_save.json` est la sauvegarde physique du résultat. Le rejeu produit la sauvegarde réelle du début du tour 12 et l’analyse des occasions tactiques autorisées.

Temps de décision moyen : 3021.3 ms ; maximum : 10618 ms sur ce cloud. Ces mesures ne sont pas des performances Android.

Aucune modification du moteur, des profils ou des coefficients IA ; aucun bonus caché. Une seule bataille moyenne et une seule graine ne démontrent pas l’équilibrage général. Aucun essai sur appareil ou émulateur. Les observations de progression vers un objectif signalent des occasions possibles, sans conclure automatiquement qu’une réserve aurait dû avancer.

## Rejeu exécuté et inactivité

**2 753 / 2 753 contrôles réussis** : frontières chronologiques, acceptation des 1 372 commandes enregistrées, sauvegarde et reprise exacte du début du tour 12, validation finale, concordance du score et de tous les champs de l’état final avec la sauvegarde physique, attente légale du renfort et comptabilité de toutes les redditions. Le rejeu utilise les commandes effectivement choisies pendant la simulation ; il ne constitue pas une seconde simulation indépendante avec de nouveaux choix IA.

Trois redditions prussiennes : `pru_54` au tour 4 (81 hommes), `reserve_art_11` au tour 6 (89) et `art_pr_Gersdorff0` au tour 14 (66), total 236. Aucune reddition française enregistrée.

À la fin des demi-tours, **331 observations d’unité-tour** présentent une possibilité légale de progression vers un objectif ennemi : 243 françaises (35 unités distinctes) et 88 prussiennes (26 unités distinctes). **Aucune possibilité de tir ou d’assaut légal laissée disponible** dans cette analyse. Les réserves et les missions défensives peuvent justifier certaines immobilités ; cet indicateur ne les qualifie pas automatiquement d’erreurs.

Les unités françaises `fr_25`, `fr_26`, `fr_27`, `fr_29` à `fr_33` apparaissent chacune 12 fois ; `pru_55` apparaît 10 fois. Les positions, PA, objectifs assignés et objectifs vers lesquels une progression était possible sont conservés dans `full_battle_analysis.json`. La cause précise d’une immobilité doit être reproduite et étudiée avant tout changement de coefficients ou de doctrine ; aucun changement IA n’a été réalisé.

Pour reproduire le contrôle détaillé :

```sh
Godot_4.5.1 --headless --path . --script res://tests/v37/test_replay.gd
```

Utiliser un répertoire utilisateur isolé comme dans le lanceur Python pour conserver les sauvegardes du test sans toucher à une partie personnelle.
