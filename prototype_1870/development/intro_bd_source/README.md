# Prototype BD animée — Campagne 1870

Projet Godot 4 autonome (orientation paysage) : 6 scènes historiques, illustrations, transitions en fondu, navigation Suivant/Précédent, lecture automatique (9 s par scène), Passer l’introduction.

## Tester
Ouvrir `project.godot` dans Godot 4.3+ puis lancer la scène principale.

## Intégration future
Intégrer `intro.tscn`, `intro.gd` et `assets/` au projet V43, puis connecter le signal `introduction_finished` au menu principal. **Ne pas remplacer la scène principale ni les scripts de combat du jeu existant.** Tester les chemins des ressources et la compatibilité Godot avant fusion.

## Limites
Prototype autonome non testé dans Godot ni sur Android dans cet environnement. Illustrations issues d’une planche de démonstration et recadrées ; les textes sont séparés et éditables. Pas encore de voix, musique ou animations de personnages. Les descriptions historiques sont des résumés de travail à relire avant publication.
