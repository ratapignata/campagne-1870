# V39 — Modifications depuis V38

## Carte et durée
- Deux inscriptions Sauer en bleu, en police historique italique, orientées selon une ligne de texte lissée suivant la rivière et placées dans la portion visible ; contour clair, taille minimale, marges de sécurité aux zooms élevés.
- Terrain, rivière, ponts et flèche Reichshoffen inchangés.
- Scénarios historiques à 20 tours de 30 minutes (08 h–18 h) ; petits scénarios de 10 tours conservés.
- Affichage et score de durée reliés au nombre de tours effectif ; pondération 60/20/20 conservée.

## Difficulté et sauvegardes
- NORMAL et DIFFICILE seuls dans le menu. Identifiant interne medium conservé pour Normal, avec les paramètres du Moyen V38.
- Anciennes difficultés Facile/Moyen reprises en Normal ; Difficile conservé. L’ancien identifiant legacy est repris en Normal.
- Import des empreintes des scénarios historiques V38. Parties en cours prolongées à 20 tours ; parties déjà terminées conservées avec le dénominateur historique du score.

## IA
- Priorité aux batteries préparant des attaques et aux défenseurs d’objectifs.
- Conservation d’une position de tir utile et recherche de lignes de tir avec distance de sécurité.
- Déplacements d’infanterie valorisés lorsqu’ils permettent encore un tir ou un assaut.
- En Difficile : évaluation des concentrations visibles, axes par groupe de commandement, détours autour des défenses observées, opportunités limitées de menace des arrières/QG et adaptation au temps restant.
- En Difficile : détours tactiques limités et prudence moins paralysante pour une avance soutenue restant ravitaillée ; les pénalités réelles de commandement restent inchangées.
- En Difficile : prise en compte des captures légales hors de l’objectif principal, sans que l’éloignement temporaire de cet axe annule leur intérêt.
- En Difficile : seuil de décision légèrement réduit pour un assaut d’infanterie sur un ennemi désorganisé avec des amis proches ; cela ne change pas la résolution du combat.

## Règles conservées
Charge de cavalerie 2 PA ; aucun bouton Tirer ; aucune riposte ou défense adjacente ajoutée ; armes, effectifs initiaux, coûts, coefficients de combat, renseignement, commandement, ravitaillement, isolement et reddition inchangés.

## Technique
Projet et application 0.8.39, versionCode Android 52. Nouveaux tests et bancs reproductibles. Deux anciens tests d’interface et le contrat de durée adaptés à 20 tours. Les résultats défavorables et les corrections de montage de tests sont conservés.

L’évaluation de la difficulté et ses limites figurent dans V39_Rapport_IA.md. Cette livraison ne vaut pas validation sur téléphone physique.
