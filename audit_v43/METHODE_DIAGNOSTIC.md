# Diagnostic V43 — méthode et périmètre

Date : 21 octobre 2026. Travail sur les sources publiées V43.1 (main GitHub 9c3b9f40e2e5f0bb1c83fa5fc7d9c74323ac94c6). La mise à jour V43.2 ajoute seulement l’export JSON ; les fichiers IA, moteur, scénario, cartes et profils sont identiques à V43.1. Aucun correctif du comportement IA n’est appliqué dans les sources principales.

## Reproduction et limites

Aucune sauvegarde de la partie Android au tour 12 et aucune capture de bataille n’étaient jointes à ce message dans l’environnement. La position du joueur n’est donc pas reproduite. La description « concentration allemande au nord de la Sauer » constitue un signalement, pas une observation vérifiée de cet audit.

Le test chronologique part du scénario V43 original, pas d’un déploiement reconstruit : 95 unités, 95 000 Allemands/50 unités et tous les renforts prévus, carte 30 × 20, règles et brouillard intacts. Graine 430012, difficulté hard, ai_style=0, joueur français. La défense française est le script de test existant tests/v42_lot8/mobile_defence.gd : tirs, déplacements vers objectifs, retraits de formations éprouvées, ralliement et contre-attaques légales. Aucun assaut français ne se produit dans cette campagne : cette politique privilégie les tirs, et sa reconquête de Frœschwiller se fait par mouvement. Ce n’est ni la conduite réelle du joueur ni une preuve statistique d’équilibre.

La copie de diagnostic reprend l’IA tactique et ajoute des données de trace : objectifs, destinations, scores, seuils d’assaut, liaisons, motifs d’attente. Les conditions, valeurs et décisions ne sont pas modifiées. Aux tours 6/9/12/15/18, l’état exact de début de phase prussienne et l’état avant sa fin sont capturés. Les fenêtres sont rejouées avec les commandes réellement enregistrées et comparées sur l’intégralité de l’état. Les mouvements à découverte partielle sont comptés jusqu’à leur extrémité réellement atteinte, pas jusqu’au bout de la flèche prévue.

Une seconde instrumentation décompose les notes de mouvement et dénombre les destinations de progression libres/occupées. La décision de cette copie est comparée à celle du script V43 original et à la commande enregistrée, depuis les mêmes observations autorisées. La mesure temporelle initiale inclut l’observation et l’instrumentation ; les temps comparatifs original/instrumenté sont fournis séparément. Il ne s’agit pas d’une mesure sur smartphone.

## Définitions

- Unité ayant bougé : au moins une commande de mouvement exécutée pendant la phase ; un retour à son point de départ reste compté comme mouvement.
- Unité inactive : unité allemande vivante en début de phase n’ayant reçu aucune commande. Une batterie ayant tiré n’est pas inactive même si elle reste sur place.
- PA inutilisés : somme des PA restants des unités allemandes survivantes avant fin de phase, divisée par 4 (le moteur compte en quarts de PA). Ce n’est pas intégralement du gaspillage : reliquats insuffisants, positions utiles et limitations légales sont distingués.
- Destinations occupées : destinations finales exclues car occupées par un ami. Le transit ordinaire à travers un ami est légal ; ce nombre seul ne prouve pas un blocage de passage.
- Franchissements : arêtes de rivière effectivement traversées, ponts et gués, dans les deux sens. Un même régiment peut être compté plusieurs fois ; les identifiants et directions sont fournis.
- Assaut après artillerie : même cible bombardée plus tôt pendant la phase puis attaquée à l’assaut. Cela mesure une succession observée et ne prouve pas une planification explicite.
- Objectifs : Frœschwiller 3, Elsasshausen 2, Niederwald 1. Wœrth est un passage/secteur de progression, pas un quatrième objectif scoré.

## Tests complémentaires

- Petit combat reproductible : deux unités sur la carte réelle, commandement/brouillard désactivés dans ce seul cas de mécanique ; les ennemis sont explicitement fournis à observation. Force prussienne paramétrée, défenseur français de 700 hommes en village. But : vérifier les seuils IA, sans conclure à un équilibre de campagne.
- Pont de Wœrth : coût et légalité des armes aux tours 3, 4 et 12 ; aucune règle de terrain modifiée.
- Cinq décalages synthétiques de l’horloge sur un déploiement initial identique : décisions aux tours 6/9/12/15/18, signalées comme synthétiques et distinctes de la campagne chronologique.
- Combat réduit de 12 unités à 1 000 hommes chacune, défense française mobile, hard, graine 430012 : 20 tours réellement achevés, 515 contrôles passés. Test tactique réduit, pas bataille des 95 unités.

Les scripts conservent les intitulés hérités V42 de certains runners ; le chemin de pack exécuté est regimental_trial_v43.json. L’empreinte du pack et le manifeste de travail identifient la version réellement testée.
