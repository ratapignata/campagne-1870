# Diagnostic de la sauvegarde T12 reçue le 23 octobre

## Nature de l’état

Export V43.9, tour 12, phase prussienne (side=1), Difficile, style 0, worker IA occupé au moment de l’export. Checksum correct et état valide. Les trois objectifs sont français. Il s’agit d’une capture EN COURS de phase, pas de la preuve que toute l’armée a déjà terminé son tour.

La reprise de test repart de l’état exporté avec une nouvelle décision IA. L’ordre transitoire que calculait Android n’est pas connu et n’est pas reconstitué arbitrairement. Les deux versions partent de la même graine, des mêmes PA, positions et états. Les réactions françaises réelles du moteur restent actives ; aucun nouvel ordre stratégique français n’est joué durant la continuation de la phase prussienne. Ce n’est pas une simulation complète contre une nouvelle défense française active.

## Pourquoi l’unité de Wœrth bloque

Le défenseur fr_7 est en (13,10), 843 hommes, désorganisé. Le fantassin prussien pru_39 est en (13,11), 1 212 hommes, désorganisé ; pru_36 avec 2 900 hommes reste derrière en (13,12).

Tests du vrai moteur sur une copie de la sauvegarde :

1. L’assaut direct de (13,11) vers (13,10) est refusé avec le motif river.
2. Le passage du pont (13,11) → (14,11) est légal, chemin [343,344], et a réellement été exécuté dans cette copie.
3. Au débouché, l’unité n’a plus ni commandement ni ravitaillement.
4. L’assaut reçoit alors le motif isolated ; l’état demeure valide.

L’IA bombarde déjà ce défenseur : sa première décision recalculée est un tir de la batterie Schmidt 2 sur fr_7, comme dans le code original. Il serait faux de dire qu’elle ignore Wœrth ou n’utilise aucun canon. En revanche, elle ne résout pas encore efficacement la séquence neutralisation du verrou, passage et assaut sous liaisons légales. Les unités entassées, les lignes de tir et les limites de commandement rendent cette séquence difficile.

## Anomalie de priorité corrigée

L’unité pru_44 (80e RI fusiliers) estime un assaut contre fr_11 à un rapport de forces de 2,63 pour un seuil de 1,25. L’offre d’assaut vaut 125,8, mais l’offre de ravitaillement vaut 130 : elle refait donc ses munitions au lieu d’exploiter le défenseur faible.

La version livrée retire l’offre de ravitaillement lorsqu’un assaut d’infanterie prussienne en Difficile est légal ET accepté par l’évaluation existante. Elle ne transforme pas un refus en attaque et ne modifie pas le combat. Les autres choix (tir, mouvement, etc.) continuent à être comparés normalement.

## Résultats de continuation jusqu’à la fin de phase

| Mesure | V43.9 de référence | V43.10 |
|---|---:|---:|
| Assauts | 1 | 2 |
| Tirs | 26 | 25 |
| Ordres de mouvement | 19 | 13 |
| Unités ayant bougé par ordre de mouvement | 13 | 9 |
| Unités sans action dans cette continuation | 15 | 17 |
| PA prussiens inutilisés à la fin | 80,5 | 89 |
| Pertes françaises pendant la continuation | 937 | 1 010 |
| Pertes prussiennes pendant la continuation | 200 | 235 |
| Objectifs pris | 0 | 0 |
| Effectif du défenseur de Wœrth après la phase | 759 | 760 |
| Contrôles légalité/état | 114/114 | 100/100 |

La cible faible fr_11 reste à 353 hommes en (17,8) avec la référence. Avec la correction, elle recule en (18,7), désorganisée, avec 220 hommes ; pru_44 occupe (17,8) avec 1 606 hommes. Le second assaut est donc réel et prend une case.

Ce résultat confirme la correction de la priorité locale, PAS une amélioration générale de la mobilité ou une conquête du centre. Les nombres de mouvements et PA inutilisés imposent de poursuivre l’évaluation. Les décisions supplémentaires modifient la suite du générateur de combats : tous les écarts de pertes ne sont pas attribuables à la seule charge ajoutée. Le défenseur de Wœrth reste en place dans les deux versions.

Un plafonnement du bonus de feu des unités groupées a également été essayé puis rejeté : un seul assaut, 24 tirs et 84,5 PA inutilisés, sans amélioration de conquête. Ce changement est absent de la livraison.

## Suite à privilégier

Planifier un barrage et des positions de batterie donnant réellement une ligne de tir sur le verrou observé, puis vérifier les liaisons du groupe qui franchira. Si cela échoue, préparer un axe alternatif légal et dégager ses débouchés plutôt que forcer un assaut à travers la rivière ou ignorer une double coupure. Aucune nouvelle mécanique de combat ni bonus caché n’est proposé.

Le simple remplacement d’un objectif par Wœrth ne rendrait pas légal un assaut actuellement interdit : scénario et planification sont deux décisions distinctes. La fusion ne doit pas servir à contourner l’isolement.
