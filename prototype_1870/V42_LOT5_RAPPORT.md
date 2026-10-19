# V42 Lot 5 — Journal des pertes et coordination IA

## Modifications
- Journal : affichage en tête des pertes cumulées depuis le début de la partie, calculées depuis `engine.losses(0/1)`, avec le tour courant. Les pertes adverses restent masquées lorsque le brouillard de guerre est actif, jusqu’à la fin de la partie. Les compteurs évoluent lorsque le journal est rouvert.
- IA : bonus de priorité pour les tirs d’artillerie contre les défenseurs d’objectifs, lorsque des unités d’infanterie amies sont proches. Bonus plus fort en Difficile. L’IA utilisait déjà les fonctions `preparation_value` et `artillery_target_value` : la modification renforce la coordination existante, sans ajouter de triche ni de nouvelle règle de combat.

## Limitations
- Le journal n’affiche pas encore un tableau de pertes cumulées *à la fin de chaque tour passé* : il affiche le cumul au tour courant. Les détails des combats restent dans l’historique existant.
- Les chaînes ajoutées sont en français directement dans le script, sans nouvelle clé de traduction.
- Le moteur Godot et les tests Android ne sont pas disponibles dans cet environnement. Modifications statiques non validées par exécution.
- L’ordre de bataille V42 reste expérimental et non historiquement vérifié.
