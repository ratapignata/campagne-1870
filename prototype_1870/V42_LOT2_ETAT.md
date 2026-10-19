# V42 — Lot 2 : projet Godot complet avec scénario expérimental séparé

Le ZIP contient les **sources complètes V41** ainsi que le scénario expérimental `packs/1870/regimental_trial_v42_experimental.json` ajouté sans remplacer `regimental_trial.json`.

## Vérifications statiques réussies
- JSON lisible ; 95 unités et 95 identifiants distincts.
- Français : 45 unités, 45 550 hommes.
- Allemands : 50 unités, 95 000 hommes.
- Coordonnées des unités dans la carte 30 × 20.
- Aucune superposition d'unités arrivant au tour 1.
- Les fichiers du projet V41 sont préservés, y compris les règles et l'IA.

## Limites importantes
- Le scénario expérimental **n'est pas sélectionné automatiquement** par le jeu. Il faut adapter le chargement ou ajouter un sélecteur pour le tester ; la partie principale V41 reste inchangée.
- Les 14 unités allemandes ajoutées sont des unités génériques non authentifiées ; leurs tours d'arrivée sont provisoires.
- Plusieurs unités allemandes ont des effectifs importants (jusqu'à 4 577 hommes), ce qui peut perturber le modèle de combat. **Ne pas valider l'équilibre avant simulations.**
- Aucun test d'exécution Godot, compilation APK, ni test de performance sur Android n'a été réalisé dans cette étape.
- Les cinq améliorations d'interface/animation/IA V42 restent à coder.

## Prochaine étape
1. Ajouter une option de chargement explicite du scénario V42 sans modifier le scénario historique actuel.
2. Tester le chargement, les renforts et les collisions en Godot.
3. Mesurer la puissance de feu et les pertes de gros régiments, ainsi que le temps de tour de l'IA.
4. Vérifier l'ordre de bataille et remplacer les formations génériques avant validation historique.
