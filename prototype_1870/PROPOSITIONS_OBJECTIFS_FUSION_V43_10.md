# Avis sur les objectifs et la fusion — aucune règle ajoutée

## Wœrth comme objectif

Wœrth est un passage et un verrou tactique importants. Lui donner un objectif est défendable, mais cela peut concentrer encore davantage le combat près du pont et attribuer des points de durée à une position conquise tôt, sans progrès jusqu’à Frœschwiller.

| Option | Intérêt | Risque |
|---|---|---|
| Remplacer Niederwald (1) par Wœrth (1) | Changement de pondération minimal ; conserve les deux villages majeurs Frœschwiller et Elsasshausen | Moins d’incitation directe à contourner par le bois ; bataille plus centrée sur les villages |
| Remplacer Elsasshausen (2) par Wœrth (2) | Donne un poids élevé au passage et conserve le Niederwald pour l’aile | Retire un enjeu historique important du dispositif français et peut favoriser une occupation précoce du pont |

Je privilégierais d’abord un essai Niederwald → Wœrth à 1 point, en conservant Frœschwiller 3 et Elsasshausen 2. Le Niederwald resterait un terrain défensif important, même sans marqueur de victoire. Ce n’est pas une affirmation que ce scénario soit déjà mieux équilibré.

Avant adoption : comparer les mêmes graines avec défense française active, tours de capture, durée de contrôle, pertes et score final. Garder 60/20/20 et les seuils de victoire. Ne pas modifier les terrains, rivières ou positions pour rendre le nouveau point accessible. Dans V43.10, les trois objectifs d’origine restent intégralement conservés.

## Fusion des unités affaiblies

L’idée est pertinente pour réduire le nombre de très petits détachements, mais elle peut changer fortement le jeu et son ordre de bataille. Les exemples 200 + 200 cavaliers vers une capacité initiale de 400, ou 200 + 800 fantassins vers une capacité initiale de 2 000, sont cohérents avec une limite de capacité. Cette limite seule ne suffit pas à empêcher les abus.

Conditions recommandées pour une future expérimentation : même camp, même arme et unités compatibles, même rattachement de commandement, unités adjacentes, hors du contact immédiat et sans déroute/double coupure. Pas de mélange de cavalerie lourde et légère par simple égalité d’arme générique. Pas de fusion de QG ni de batteries dans un premier essai.

Les deux unités devraient terminer leur activation, sans récupérer de tir ou de riposte. La fusion ne devrait ni rallier gratuitement, ni remplir les munitions, ni supprimer les conséquences de l’isolement. L’unité conservée ne dépasse jamais son effectif initial.

Point technique essentiel : l’unité absorbée ne doit pas être comptée comme détruite ou prisonnière. Le moteur vérifie actuellement, par unité, effectif restant + pertes + prisonniers = effectif initial. Il faudrait tracer explicitement les transferts entrants/sortants et préserver les pertes et le score global, ainsi que les identifiants, sauvegardes et décisions IA. Sans cela, une fusion pourrait créer de fausses pertes ou casser la validation.

Recommandation : traiter le regroupement comme un lot distinct après la stabilisation de l’IA. Aucun bouton de fusion, transfert ou nouvelle règle de PA n’est ajouté à V43.10.
