# V43.12 — 27 octobre 2026

Android 0.8.43.12, code 69. Base V43.11 conservée sur sa branche ; travail dédié feature/v43.12-normal-hard-offensive.

## Normal : comportement apprécié de la V43.11

Le mode Normal utilise une copie conservée de l’IA Difficile V43.11 et de ses profils. Le transfert conserve les plans de déplacement des batteries, y compris après reprise. Les modifications du nouveau Difficile ne sont pas appliquées au Normal. Son calendrier de renforts reste celui de V43.11. L’ancienne IA moyenne n’est plus le comportement proposé par Normal.

## Nouveau Difficile

Deux formations centrales préparent Wœrth puis progressent vers Frœschwiller après sécurisation du village ; deux formations sont affectées à l’axe de Gunstett–Albrechtshäuser pour appuyer davantage l’aile droite française et rejoindre Niederwald. Ces axes sont des priorités de planification sur la carte publique, pas de nouveaux objectifs de victoire. Les coordonnées et propriétés de la carte ne changent pas.

Priorité accrue aux tirs légaux et aux défenseurs situés sur les axes d’attaque. L’artillerie garde ses règles de tir et de repositionnement et recherche les cibles préparant la progression de l’infanterie. À partir du tour 8, une infanterie suffisamment forte disposant d’au moins deux appuis proches peut accepter un assaut estimé plus serré (rapport après riposte de 1,10 ; 1,15 contre une cible retranchée), sous réserve des critères existants plus favorables contre un ennemi déjà ébranlé. Ce sont des seuils de décision IA : aucune formule de combat, riposte ou charge ne change. Les QG cherchent davantage à suivre leur formation en conservant leur prudence face aux menaces.

Un assaut d’infanterie déjà accepté par ces contrôles reçoit à partir du tour 8 une priorité de décision accrue, pour éviter qu’un simple tir du même régiment consomme les PA nécessaires à l’attaque. La préparation d’artillerie reste prioritaire. Aucun bonus de puissance ou de dégâts.

L’objectif est de mettre la pression sur Wœrth avant ou au tour 8 puis de franchir la Sauer. La légalité des déplacements et la présence adverse restent déterminantes : aucun ordre forcé, franchissement interdit ou capture programmée.

### Renforts prussiens un tour plus tôt en Difficile

| Date V43.11 / Normal | Date Difficile V43.12 | Nombre d’unités |
|---|---|---:|
| 1 | 1 | 17 |
| 3 | 2 | 2 |
| 4 | 3 | 17 |
| 5 | 4 | 5 |
| 7 | 6 | 5 |
| 9 | 8 | 4 |

Cette modification demandée est annoncée au choix de difficulté. Elle concerne les unités prussiennes du scénario V43 en Difficile. Les dates françaises, notamment Raoult, restent identiques. Une arrivée peut toujours être retardée par les règles d’occupation ; l’arrivée adjacente à une entrée ennemie est conservée. Aucun effectif, unité, PA ou dégât supplémentaire.

## Présentation

Projectiles d’infanterie noirs (#080A0C), contour gris discret pour la visibilité, longueur et épaisseur conservées. Fumée, éclairs, impacts, sons et durée restent identiques. Animation du canon conservée.

## Sauvegardes et règles

Le fichier de scénario et son empreinte restent identiques. Les dates initiales restent stockées dans les unités ; la date effective Difficile est calculée à l’arrivée et communiquée à la planification pour les seuls renforts amis. Format JSON inchangé. La sauvegarde personnelle V43.11 terminée au T20 a été relue avec succès, sans modification de l’original ni du résultat.

Une partie ancienne conserve sa difficulté enregistrée : si elle est encore en cours en Difficile, elle utilise désormais le nouveau Difficile, avec les nouvelles dates effectives pour les unités encore en attente. Les unités déjà arrivées ne sont pas recréées. Pour retrouver le comportement V43.11 dès le début, démarrer une nouvelle partie en Normal.

Charge 2 PA, ripostes, isolement, commandement, ravitaillement, variante B 0,90, 20 tours, score 60/20/20, objectifs 3/2/1, 95 000 hommes et 50 unités prussiennes conservés. Pas de bouton TIRER. Les corrections Raoult, interface et export sont conservées.

APK de développement signé avec le certificat précédent. Installer sans désinstaller pour conserver les données locales. Aucun test physique Android annoncé.
