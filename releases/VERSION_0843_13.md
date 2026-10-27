# V43.13 — objectifs et emploi des armes

Android 0.8.43.13, code 70. Travail sur feature/v43.13-woerth-objective-hard-coordination, base V43.12 conservée.

## Objectif à deux points déplacé à Wœrth

Nouvelles parties : Frœschwiller 3, Wœrth 2, Niederwald 1. Elsasshausen conserve son terrain de village, ses routes et son nom, mais ne rapporte plus de points. La carte, la rivière et les règles de franchissement sont identiques. Le score reste 60 % contrôle final, 20 % pertes, 20 % durée de contrôle ; la somme des valeurs reste six.

L’identifiant interne secondaire « elsasshausen » est conservé pour les historiques et propriétaires des sauvegardes ; dans les nouvelles parties sa définition, son nom affiché et son hexagone sont ceux de Wœrth (13,10). Il s’agit bien de déplacer l’objectif comptabilisé, pas seulement de dessiner l’étoile ailleurs.

Les sauvegardes antérieures gardent leur ancienne disposition : Frœschwiller 3, Elsasshausen 2, Niederwald 1. Une métadonnée objective_layout=v4312 conserve cet historique après chargement et réenregistrement, y compris pour les parties terminées. Leurs scores ne sont pas réinterprétés rétroactivement à Wœrth. Pour jouer avec Wœrth à deux points, commencer une nouvelle partie. Le format JSON reste schema 1 ; l’export donne aussi les définitions publiques des objectifs dans export_info.

## Difficile : batteries actives

L’analyse du test V43.12 a trouvé quatre batteries de l’aile droite sans aucun tir. Elles marchaient au-delà des positions utiles ou poursuivaient une mission de pont située dans un autre secteur.

La nouvelle IA met une batterie en position quand elle dispose d’une cible légale utile et d’une sécurité suffisante. Une mission de pont éloignée de son propre axe ne détourne plus une batterie disposant d’un tir. Sans ligne utile, le repositionnement privilégie le soutien de l’infanterie de sa formation plutôt qu’un départ loin devant elle. La retraite sous menace proche reste possible.

Les canons n’obtiennent ni PA, ni portée, ni dégâts supplémentaires ; chaque déploiement, attelage, mouvement et tir utilise l’action ordinaire du moteur.

## Difficile : approche suivie d’assaut

L’infanterie valorise une destination qui laisse réellement les PA nécessaires à un assaut jugé favorable. Une intention d’attaque accompagne ce court mouvement ; au choix suivant, la cible, les PA, la position finale, la phase et le rapport de forces sont revérifiés. Une découverte qui interrompt le mouvement, une cible devenue invisible ou des PA dépensés invalident le plan. Aucun passage forcé ni restauration de PA.

Les assauts d’infanterie appuyés peuvent être engagés dès le tour 4, sous les seuils de décision déjà utilisés en V43.12 à partir du tour 8. Le calcul inclut la riposte estimée ; le combat lui-même ne change pas. L’intention utilise le conteneur de planification déjà utilisé pour les attelages, sans ajout d’action au joueur. Les plans ne sont pas une nouvelle règle de combat.

## Normal et règles conservées

Le Normal conserve l’IA et les profils du Difficile V43.11. Il réagit naturellement aux nouveaux objectifs communs aux deux modes. Le Difficile conserve l’avance d’un tour de ses renforts prussiens déjà annoncée en V43.12 ; aucune avance supplémentaire. Les renforts français et Raoult gardent leurs dates et règles d’entrée.

95 000 hommes et 50 unités allemandes, 20 tours, cavalerie charge 2 PA, variante B 0,90, ripostes, isolement, commandement, ravitaillement, coûts et portées conservés. Balles d’infanterie noires conservées ; aucun bouton TIRER. Les données map, units, weapons et rules sont strictement identiques à V43.12.

Voir TESTS_V43_13.md et COMPARAISON_NORMAL_DIFFICILE_V43_13.md pour les essais réellement exécutés et leurs limites. APK de développement signé avec le même certificat ; aucun essai physique Android. Installer sans désinstaller pour conserver les sauvegardes.
