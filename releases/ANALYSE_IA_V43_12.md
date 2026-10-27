# IA V43.12 — méthode, comparaison et limites

## Demande et sauvegarde réelle

La sauvegarde fournie est bien exportée de V43.11 : T20 terminé, joueur français, Difficile, style 0. Elle se recharge avec le moteur V43.12. Frœschwiller et Niederwald sont prussiens, Elsasshausen français. Pertes militaires selon le moteur : 30 198 Français / 19 930 Prussiens ; prisonniers : 3 120 / 724 ; résultat français : défaite mineure, score 42,18 contre 56,80. Le fichier original est intact. Le récit du joueur situe la prise de Wœrth vers T10 ; ce fichier final seul ne permet pas de rejouer exactement ses décisions du T8.

Aucune sauvegarde personnelle complète n’est publiée. Les fixtures livrées proviennent uniquement des simulations de test.

## Normal conservé et nouveau Difficile

Le Normal délègue à la copie exacte de l’IA Difficile V43.11, avec ses profils conservés séparément. Ses dates de renforts restent identiques. La parité de décision, l’absence de mutation des observations et la reprise d’un déplacement après attelage sont testées. Le fichier de scénario conserve son empreinte 6a44f0421df5983355ea59792e27ed67a9e9ac89def0c295b8ebdfab2a12574b : unités, effectifs, terrain et règles militaires identiques.

Le nouveau Difficile ajoute deux axes centraux Wœrth–Frœschwiller et deux formations sur l’axe de Gunstett–Albrechtshäuser pour menacer l’aile droite. Il privilégie les tirs préparant ces axes, suit davantage la progression avec les QG et accepte des assauts d’infanterie appuyés plus serrés à partir du T8. Une priorité supplémentaire évite ensuite qu’un simple tir consomme les PA d’un assaut déjà jugé favorable. Ces valeurs classent les décisions ; elles n’augmentent pas la puissance de combat. Les cavaliers gardent leurs critères et leur charge à 2 PA.

Les renforts prussiens gagnent un tour en Difficile, comme demandé et annoncé dans le menu. Le gain mesuré combine cette avance du calendrier et les nouvelles décisions : ce test n’isole pas l’effet de chacun. Les dates françaises, l’isolement et les règles d’occupation restent inchangés.

## Protocole reproductible

Scénario complet V43, 95 unités déclarées et leurs renforts, carte et positions initiales intactes. Graine 18704311, style 0, Godot 4.5.1. Même politique française que la référence V43.11 exécutée le 26 octobre : une infanterie rejoint légalement Wœrth, reste pour tirer, rallier et se retrancher ; la politique tente de regarnir le village s’il est vide. Les autres Français utilisent l’IA défensive de production, avec tirs et manœuvres. Aucun déplacement direct ni ajout d’effectif. Ce n’est pas une reproduction des choix d’un joueur humain.

Une première simulation autonome V43.12 a révélé trop peu d’assauts. L’inspection des classements puis un test sur son véritable état du T9 montrent que des assauts déjà acceptés sont devancés par le tir du même régiment. La correction finale ajoute une priorité de décision uniquement à partir du T8. Les critères d’acceptation restent identiques entre ces deux itérations.

Pour vérifier la correction, le préfixe réellement joué depuis T1 jusqu’à la fin du tour français 8 a été intégralement rejoué par le moteur : 735 ordres, 1 472 contrôles, aucun échec. Le début de partie est identique pour la politique finale, dont cette correction ne s’active qu’à partir du T8. Les décisions finales sont ensuite simulées du tour prussien 8 jusqu’à la fin du T10. Aucun tour, position, PA, état de combat ou renfort n’est remis à zéro. Il s’agit d’une continuation chronologique après rejeu, pas d’un état synthétique créé au T8 ni d’une nouvelle simulation autonome ininterrompue de dix tours après le dernier ajustement.

La référence Normal est le résultat V43.11 Difficile conservé du test précédent ; le Normal V43.12 n’a pas fait l’objet d’une nouvelle campagne autonome de dix tours. Son code/profil et ses dates sont conservés et leur parité est vérifiée par les tests.

## Résultats cumulés jusqu’à la fin T10

| Version / mode | Première occupation de Wœrth | Mouvements PR | Tirs canon PR | Tirs infanterie PR | Assauts PR | Pertes FR / PR |
|---|---:|---:|---:|---:|---:|---:|
| V43.11 Difficile (référence du nouveau Normal) | 9 | 244 | 111 | 79 | 9 | 10902 / 8855 |
| V43.12 Difficile final | 4 | 337 | 90 | 116 | 7 | 10106 / 8428 |

Frœschwiller passe sous contrôle prussien en fin T8 dans la version finale, contre T10 dans la référence. Pendant le tour prussien 8 : quatre assauts et 33 tirs, contre deux assauts et 26 tirs dans la référence.

Fin T10 V43.12 : objectifs {"elsasshausen": 0, "froeschwiller": 1, "niederwald": 1} (0 = français, 1 = prussien). Wœrth : {"id": "pru_41", "side": 1, "strength": 2900}. Prisonniers FR / PR : 6238 / 0. Unités en déroute FR / PR : 2 / 0.

Sur l’ensemble des dix tours : 207 tirs prussiens contre 190, dont 116 tirs d’infanterie contre 79, mais 90 tirs de canon contre 111 et sept assauts contre neuf. Un tir supplémentaire provient d’une escorte de QG. La hausse demandée n’est donc pas uniforme pour chaque type d’action. Le T8 concentre en revanche davantage d’assauts et de tirs. Les prisonniers français passent de 524 à 6 238 dans ce protocole, avec des règles de reddition inchangées : de nombreuses unités sortent du combat autrement que par attrition. Cela modifie aussi les occasions de tir.

Elsasshausen reste français en fin T10 dans la nouvelle variante, alors que les trois objectifs sont prussiens dans la référence. L’avance sur Wœrth et Frœschwiller et le renforcement du flanc ne permettent donc pas de conclure à une supériorité globale à partir du seul contrôle des objectifs au T10. Une bataille entière de 20 tours et plusieurs adversaires restent nécessaires pour juger l’équilibre.

Le secteur de l’aile droite est défini pour la mesure par x >= 19 et y <= 11. Un relevé de début T5 y trouve neuf infanteries, deux cavaleries et deux batteries prussiennes ; voir wing_checkpoint.json pour les coordonnées exactes. En fin T10, 12 unités prussiennes vivantes y sont présentes, contre 1 dans la référence. Cette coupe géographique ne mesure pas, seule, une enveloppe achevée.

Wœrth reste un passage tactique, pas un quatrième objectif de score. La présence est relevée après les ordres et en fin de phase. Les nombres de mouvements et de tirs sont des ordres, pas des unités distinctes. Les variations de tirs, d’assauts et de pertes sont présentées telles que mesurées : les mêmes PA ne peuvent pas financer simultanément tous les types d’action. Une prise plus rapide peut aussi faire disparaître des cibles.

## Interprétation et limites

La prise de Wœrth avant le T8 et l’offensive vers Frœschwiller sont démontrées dans ce protocole, sans capture forcée. La défense française contre-attaque : elle reprend Niederwald pendant sa phase T7, puis les Prussiens le reprennent pendant leur phase T7. Le Normal conserve le comportement apprécié.

Une seule graine et un seul style sont utilisés dans cette comparaison. Le meilleur délai local ne prouve pas un meilleur équilibre global, une enveloppe systématiquement réussie ni une victoire garantie contre un humain. Les pertes et les différences d’actions doivent être lues avec les objectifs et la chronologie. Les durées enregistrées incluent des exécutions serveur concurrentes, du rejeu et des validations ; ce ne sont pas des mesures Android comparables.

Pas de nouvelle bataille complète de 20 tours en V43.12. Aucun essai physique Android. Les prochaines validations utiles sont plusieurs graines/styles, une défense humaine et les performances sur smartphone. Aucun coefficient de dégâts, PA, renseignement caché ou règle de riposte n’a été modifié.
