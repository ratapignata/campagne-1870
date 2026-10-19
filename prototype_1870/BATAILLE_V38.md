# Bataille complète et évaluation V38

## Bataille historique exécutée

Scénario réel inchangé, 81 unités déclarées, France et Prusse moyennes actives, graine 187037, style 0. Dix-huit tours chronologiques terminés ; 80 unités entrées et QG Raoult encore en attente sur son entrée occupée (15,4). Exécution en deux segments avec reprise du checkpoint du tour 4 ; rejeu indépendant intégral des commandes réussi. Aucun test sur téléphone.

| Indicateur | France | Prusse |
|---|---:|---:|
| Mouvements | 197 | 259 |
| Tirs | 240 | 221 |
| Assauts | 9 | 21 |
| Déploiements / attelages | 7 / 2 | 20 / 13 |
| Pertes militaires | 14 563 | 16 888 |
| Prisonniers | 796 | 2 261 |
| Déroute finale / maximum simultané | 0 / 1 | 0 / 2 |
| Objectifs finaux (part sur 60) | 0 | 60 |
| Durée de contrôle (part sur 20) | 10,5556 | 9,4444 |
| Pertes (part sur 20) | 8,5296 | 6,7438 |
| Score final | 19,0852 | 76,1882 |

Victoire mineure prussienne : les critères existants de victoire majeure restent appliqués, notamment l’avantage de pertes insuffisant. La table détaille les composantes retournées par le moteur, dans l’ordre objectifs/durée/pertes.

Frœschwiller capturé par la Prusse au tour 6, repris par la France au tour 7 puis par la Prusse au tour 10. Elsasshausen et Niederwald capturés au tour 12. Les trois objectifs sont prussiens à la fin.

1 434 décisions, 1 547 contrôles sans échec ; rejeu 2 877 contrôles sans échec, état final identique et sauvegarde réelle au tour 12. Temps moteur cumulé : 5 873 secondes, environ 97,9 minutes, sur cloud partagé avec d’autres vérifications ; aucune extrapolation aux performances Android.

## Comparaison de la bataille V37

V37 : 1 372 décisions, mouvements FR/PR 202/245, tirs 210/208, assauts 14/16, pertes 12 970/14 624, prisonniers 0/236, scores 14,95/77,36. Captures prussiennes aux tours 6/11/11. V38 modifie la trajectoire effective via la correction commune d’artillerie : davantage de combats, reprise française de Frœschwiller, conquête finale une demi-heure plus tard pour les deux objectifs secondaires. Préservation des coefficients moyens ne signifie pas identité de toute bataille après correction d’un défaut.

## Comparaison reproductible réduite

Quatorze unités en implantation synthétique sur la vraie carte, sans renforts, dix-huit tours par simulation ; France moyenne fixe. Ces scénarios ne sont pas la bataille historique à 81 unités.

| Mode PR | Graine | Score PR V37 | Score PR V38 final | Actions identiques |
|---|---:|---:|---:|---|
| easy | 187037 | 82.87 | 82.87 | Oui |
| easy | 187038 | 79.79 | 79.79 | Oui |
| medium | 187037 | 45.56 | 45.56 | Oui |
| medium | 187038 | 45.46 | 45.46 | Oui |
| hard | 187037 | 46.76 | 34.07 | Non |
| hard | 187038 | 66.94 | 64.52 | Non |

Le difficile reste irrégulier : victoire française sur 187037 et victoire prussienne sur 187038. Les modes faciles gagnent ici les deux graines ; les moyens font match nul. Il serait incorrect d’annoncer une hiérarchie de difficulté validée. Aucun coefficient ni bonus caché n’a été ajouté pour masquer ce constat.

Avec France difficile contre Prusse moyenne : scores français V37→V38 24,53→9,98 sur 187037 et 14,30→30,18 sur 187038. Les pertes françaises passent respectivement de 4 445 à 2 936 et de 4 462 à 2 919 ; meilleure préservation ne garantit pas la conservation des objectifs.

## Artillerie

Dans les deux simulations prussiennes difficiles, les tirs de batterie passent de 27 à 33 et de 21 à 29. Les déplacements passent de 2 à 1 et de 4 à 2 ; les attelages de 1 à 0 et de 3 à 1. Les tirs contre défenseurs d’objectifs passent de 27 à 33 et de 14 à 29. La batterie française difficile passe de six déplacements à un sur les deux graines, mais demeure à deux tirs : visibilité, liaisons et coordination défensive restent des limites. Le nouveau test ciblé confirme qu’un canon français à 3 PA peut préparer légalement son déploiement puis tirer au tour suivant, sans PA gratuits.

## Décisions discutables et suites proposées

Le rejeu relève 220 observations unité-tour avec une possibilité légale de progression ou d’attaque non utilisée. Ce compteur utilise seulement les informations autorisées ; il peut inclure des réserves légitimes et répéter une unité. Il ne prouve pas 220 erreurs. Les positions, PA, objectifs et attaques possibles figurent dans full_battle_analysis.json.

Les prochaines évaluations devraient isoler la coordination des objectifs, les réserves, la protection des QG et des liaisons, et l’artillerie française. Une modification importante de doctrine nécessitera une nouvelle validation ; aucune nouvelle règle de combat ou riposte n’est proposée ici.

## Capitulations réellement rejouées

Huit événements détaillés, avec tour, camp victime et prisonniers. Données brutes conservées afin de distinguer pertes militaires et capitulations :

```json
[
  {
    "cell": [
      14,
      7
    ],
    "kind": "surrender",
    "name_key": "reg_pru_54",
    "prisoners": 158,
    "serial": 27,
    "side": 1,
    "turn": 4,
    "unit": "pru_54"
  },
  {
    "cell": [
      13,
      5
    ],
    "kind": "surrender",
    "name_key": "reg_reserve_art_11",
    "prisoners": 81,
    "serial": 31,
    "side": 1,
    "turn": 6,
    "unit": "reserve_art_11"
  },
  {
    "cell": [
      12,
      5
    ],
    "kind": "surrender",
    "name_key": "reg_pru_52",
    "prisoners": 203,
    "serial": 39,
    "side": 1,
    "turn": 7,
    "unit": "pru_52"
  },
  {
    "cell": [
      10,
      6
    ],
    "kind": "surrender",
    "name_key": "reg_pru_36",
    "prisoners": 872,
    "serial": 49,
    "side": 1,
    "turn": 10,
    "unit": "pru_36"
  },
  {
    "cell": [
      14,
      5
    ],
    "kind": "surrender",
    "name_key": "reg_fr_6",
    "prisoners": 176,
    "serial": 52,
    "side": 0,
    "turn": 10,
    "unit": "fr_6"
  },
  {
    "cell": [
      18,
      4
    ],
    "kind": "surrender",
    "name_key": "reg_fr_11",
    "prisoners": 259,
    "serial": 53,
    "side": 0,
    "turn": 11,
    "unit": "fr_11"
  },
  {
    "cell": [
      13,
      4
    ],
    "kind": "surrender",
    "name_key": "reg_fr_8",
    "prisoners": 361,
    "serial": 61,
    "side": 0,
    "turn": 12,
    "unit": "fr_8"
  },
  {
    "cell": [
      10,
      4
    ],
    "kind": "surrender",
    "name_key": "reg_pru_43",
    "prisoners": 947,
    "serial": 66,
    "side": 1,
    "turn": 14,
    "unit": "pru_43"
  }
]
```
