# Moteur : objectifs multiples — préparation après v0.8.18

## Implémenté

- `pack.objectives` : liste d’objets avec id unique, cell [colonne, ligne], points entier positif, initial_owner (-1, 0, 1), name_key optionnel.
- Compatibilité de `pack.objective` : toujours accepté comme objectif unique.
- Capture au déplacement et à l’avance après assaut. Une unité en déroute ne capture pas. Les captures bloquent l’annulation comme auparavant.
- Chaque objectif conserve son dernier propriétaire lorsque la garnison part. Le score est attribué une seule fois par tour complet, selon sa valeur.
- Le contrôle final vaut une fraction des 40 points selon la valeur détenue. Durée normalisée par la valeur totale × nombre de tours. Pertes conservées selon le barème existant.
- Résultat majeur : avantage en valeur contrôlée sur l’adversaire, marge de score et avantage de pertes requis. Compatible avec l’objectif unique.
- Sauvegarde des propriétaires par identifiant ; reprise des anciens états mono-objectif. Propriétaires manquants/invalides et scores impossibles rejetés.
- Carte : une étoile par objectif. Fiche : nom et propriétaire de l’objectif sélectionné. Résultat : dénominateur réel du score de durée, suppression du « / 6 tours » figé.
- IA : choix d’un objectif accessible selon valeur, distance, contrôle et concentration amie. Champs de déplacement mis en cache pendant une décision. Les trois difficultés gardent leurs profils ; l’entrée reste l’observation filtrée, jamais l’état ennemi caché.
- Le contrôle des objectifs est une information publique, comme dans le prototype précédent ; il ne donne ni identité ni effectif des occupants.
- Pack exact v0.8.18 ajouté aux reprises legacy, avec son empreinte originale : les sauvegardes existantes ne reçoivent pas silencieusement de nouvelles règles de terrain.

## Exécuté avec Godot 4.5.1, mode headless

- test_multi_objectives.gd : 28 contrôles.
- test_multi_objectives_ui.gd : 7 contrôles (fiches, données carte, bilan, sauvegarde originale).
- test_engine.gd : 40/40.
- test_positions_results.gd : 34/34.
- test_ai089.gd : 28/28, dont trois batailles complètes du scénario de régression aux niveaux facile, moyen et difficile. Exécuté avant la mise en cache des champs multi-objectifs ; cas multi-objectifs et vérification IA rapide réexécutés après cette optimisation.

Les tests multi-objectifs couvrent mouvement, assaut, possession évacuée, score de fin de tour, déroute, sauvegarde, corruptions, ancien format, choix du troisième objectif, observation sans ennemi invisible et décisions aux trois niveaux. Le résultat majeur est vérifié des deux points de vue.

## Limites précises

Pas de compilation/export Android ni de test sur téléphone. Le SDK Android n’est pas installé. Les tests de fiches sont sans rendu graphique réel ; pas de validation tactile ni de capture de l’écran Android.

Le pack actif conserve son scénario à un objectif. Le scénario artificiel `development/objectives08/scenario_test.json` sert à l’intégration et n’est pas proposé au joueur. La carte historique, son ordre de bataille et ses positions initiales restent hors du menu. Les poids historiques 3/2/1 sont une proposition de gameplay.

L’ancien module isolé `development/objectives08/objective_rules.gd` reste une référence du simulateur, sans appel dans le moteur. L’implémentation effective est dans war_engine/core/rules_base.gd et engine.gd.

## Exécution

Depuis la racine du projet :
`godot --headless --path . --script tests/test_multi_objectives.gd`
`godot --headless --path . --script tests/test_multi_objectives_ui.gd`

Le projet reste en préparation. Les numéros de version du dernier APK ne constituent pas une nouvelle livraison Android.
