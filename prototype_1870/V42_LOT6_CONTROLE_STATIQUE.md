# V42 — Lot 6 : contrôle statique et préparation des essais

**Portée :** vérification du ZIP et du JSON du scénario. Aucune simulation Godot ni exécution Android. Aucun changement des règles ni des scripts de jeu dans ce lot.

## Contrôles automatiques

- OK — ZIP valide
- OK — Projet Godot présent
- OK — Scénario V42 présent
- OK — 45 unités françaises
- OK — 50 unités allemandes
- OK — 45 550 Français
- OK — 95 000 Allemands
- OK — Identifiants uniques
- OK — Aucune superposition au tour 1
- OK — 20 tours
- OK — Score 60/20/20

## Effectifs

- Français : 45 unités  45 550 hommes.
- Allemands : 50 unités  95 000 hommes.
- Plus grosse unité allemande : `pru_36`  4577 hommes.

### Arrivées Français

- Tour 1 : 14 unité(s)
- Tour 3 : 24 unité(s)
- Tour 5 : 7 unité(s)

### Arrivées Allemands

- Tour 1 : 17 unité(s)
- Tour 3 : 2 unité(s)
- Tour 4 : 17 unité(s)
- Tour 5 : 5 unité(s)
- Tour 7 : 5 unité(s)
- Tour 9 : 4 unité(s)

## Réserves de validation

- Les unités allemandes supplémentaires et les horaires de renforts sont **provisoires** ; ils ne constituent pas un ordre de bataille historique validé.
- Le journal V42 Lot 5 affiche le cumul au tour courant, **pas encore un enregistrement des pertes à la fin de chaque tour**.
- Les performances IA, l’équilibre des grosses unités, le rendu des animations, le contour rouge et les interactions tactiles demandent des tests Godot et Android.
- Le contrôle statique ne démontre ni compilation ni jouabilité.

## Plan de validation sous Godot

1. Importer `project.godot` avec la version Godot requise par le projet ; relever toutes les erreurs de parsing.
2. Charger le scénario V42 depuis le menu ; vérifier qu’il n’altère pas les sauvegardes V41.
3. Exécuter les scripts de test présents dans `tests/`, puis simuler 20 tours en Normal et Difficile.
4. Comparer les pertes, l’emploi de l’artillerie et les temps IA aux mêmes états de la V41.
5. Vérifier sur Android les animations de tir, le bouton ravitaillement supprimé, les icônes interactives, les contours rouges et le journal.
6. Revoir les renforts, l’ordre de bataille et la proportion des effectifs par corps à partir de sources historiques avant de qualifier le scénario d’historique.
