# V43.5 — Contour d’isolement et encerclement complet

Android 0.8.43.5, code 62, Godot 4.5.1. Correction demandée sur les captures du 22 octobre.

## Affichage

Le contour rouge de double coupure a les mêmes dimensions (58 × 60 unités de dessin), position et épaisseurs que le contour vert fluo des membres du QG, à tous les zooms. Force en bas du pion conservée ; numéro d’unité en haut à droite masqué.

## Commandement et ravitaillement

Le calcul strict bloquait les cases adjacentes à tout ennemi non en déroute, même si les six hexagones voisins étaient occupés par des unités adverses actives. Le détour imposé pouvait dépasser le seuil de commandement d’une unité encerclante, malgré une distance au QG autorisée.

Correction limitée et symétrique : un ennemi entouré sur ses SIX cases par des adversaires vivants et non en déroute bloque toujours sa propre case, mais ne projette plus de coupure logistique sur ses voisins. Si une case est libre, occupée par un allié de cet ennemi, ou par un encerclant en déroute, le comportement strict antérieur est conservé. Aucun nouveau droit de mouvement, aucune modification des attaques ou ripostes. La carte de ravitaillement utilise le même calcul que le moteur. Les obstacles d’autres ennemis, les distances au QG, les rivières et les limites de détour restent applicables.

Ce correctif modifie précisément l’effet logistique d’un encerclement complet ; il ne rend pas toutes les unités encerclantes automatiquement commandées ou ravitaillées. Il ne nécessite pas de déplacement artificiel des unités.

Reproduction contrôlée en plaine : ennemi (9,6), six unités adverses autour, QG et source (7,5). L’unité en (10,6) perdait le commandement à cause du détour imposé. Tests miroir des deux camps : 23/25 avant, 25/25 après. Les sauvegardes sont effectivement écrites, rechargées, puis les liaisons recalculées. Un encerclement partiel rétablit l’interférence ; un barrage complet continue de couper les deux liaisons.

La capture fournie affiche la fiche de Raoult et ne permet pas de confirmer les coordonnées exactes, le QG et le motif de coupure du 3e hussards. Sans JSON de cette partie, la reproduction exacte reste impossible : le cas corrigé est une cause confirmée dans un état contrôlé, pas une affirmation sur l’unique cause de ce pion précis.

## Compatibilité

Mêmes sauvegardes V43, même empreinte de scénario et même certificat Android. Installer sans désinstaller. Les liaisons déjà enregistrées sont recalculées lors des actions habituelles ; aucun PA consommé n’est remboursé et aucun événement passé n’est annulé. Pas d’avance des renforts, pas de changement de doctrine IA, charge 2 PA, variante B 0,90, projectile anthracite, 20 tours et score 60/20/20 conservés. L’IA voit naturellement le résultat du calcul logistique corrigé.

## Vérifications exécutées

- Nouveau test encerclement : 25/25.
- Liaisons strictes : 22/22.
- Isolement, retraite, reddition : 45/45.
- Mondes cachés : 18/18.
- Renforts voisins et Raoult : 32/32.
- Interface V43 : 30/30.
- Export de sauvegarde : 28/28.

Total 200/200, aucun échec d’assertion final. La suite interface signale à la fermeture un avertissement ObjectDB et deux ressources restant utilisées ; ceci n’est pas présenté comme une fermeture parfaitement propre. Le premier lanceur sans répertoires XDG configurés a échoué à créer son dossier utilisateur ; les exécutions rapportées utilisent les répertoires isolés accessibles. Une erreur d’indentation intermédiaire a été corrigée avant les tests finaux.

Rendu graphique exécuté pour deux camps et deux zooms ; contour rouge contrôlé visuellement. APK compilé, signature vérifiée. Pas de test physique Android ni de nouvelle simulation complète de bataille.

Fichiers applicatifs : war_engine/core/support.gd, war_engine/presentation/map_view.gd, project.godot, export_presets.cfg, packs/1870/fr.json. Test et preuves : tests/v43/test_enclosed_links.gd, tests/results/0843_5.
