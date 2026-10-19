# V39 — Lot 1 : archive intermédiaire

État : lot 1 implémenté ; ne contient pas encore la nouvelle IA des lots 2–3 ni un APK V39.

## Changements
- « Sauer » en bleu renforcé, police historique italique, contour clair et taille minimale de 20 pixels logiques. Deux inscriptions suivant la courbe, choisies près des extrémités de la portion visible. Placement tenant compte des ponts, objectifs, noms de lieux et unités visibles. Si le cadrage est trop serré pour deux noms sans chevauchement, une seule inscription peut être affichée.
- Scénarios historiques passant de 18 à 20 tours, à 30 minutes par tour, de 08 h à 18 h. Les deux petits scénarios de 10 tours restent à 10 tours.
- HUD, écran final et score de durée utilisent la durée du scénario ; pondération 60/20/20 inchangée.
- Deux boutons : NORMAL et DIFFICILE. Normal conserve l’identifiant interne medium et les paramètres exacts de Moyen V38. Facile/Moyen anciens deviennent Normal ; Difficile reste Difficile.
- Import des empreintes exactes des scénarios historiques V38 : une partie en cours continue jusqu’à 20 tours ; une partie déjà terminée reste terminée et conserve son dénominateur de score historique. Les fichiers sauvegardés restent protégés par contrôle d’intégrité et copie de secours.
- Version du projet 0.8.39 et code Android 52 préparés.

## Vérifications réellement exécutées
Godot 4.5.1 stable officiel, environnement headless.
- Lot 1 : 33/33 contrôles, dont tours 18/20, score, sauvegarde/reprise, ancienne sauvegarde réelle, migration Facile vers Normal, deux noms à quatre zooms (.42, .72, 1.18, 2.3), menus et horloge.
- Contrat de règles adapté à 20 tours : 110/110 contrôles.
- Tous les JSON des scénarios lisibles et références de ressources du code principal présentes.
- Comparaison avec les sources V38 : profils IA identiques ; règles de base, ravitaillement, renseignement et déplacement inchangés ; scénarios historiques identiques hors durée et métadonnées d’import ; scripts IA inchangés.
- L’archive ZIP est vérifiée et conserve le projet complet, ses ressources, tests et preuves.

## Limites et suite
Le rendu a été contrôlé géométriquement, pas encore inspecté sur un téléphone ni capturé avec un moteur graphique. Aucune compilation Android à ce stade. Les lots 2 (IA), 3 (simulations) et 4 (livraison finale) restent à réaliser. Les rapports V38 inclus constituent des preuves historiques, pas des tests V39.

Deux erreurs intermédiaires ont été corrigées : parenthèse dans la géométrie et comparaison de types numériques JSON dans le test synthétique de sauvegarde. Les résultats finaux sont dans tests/results/0839/lot1.log et contract.log.
