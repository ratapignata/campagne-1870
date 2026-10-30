# Essai graphique 2D № 3 — 0.8.43.15-g2d3

30 octobre 2026. Branche `v43-graphismes-2d-experimental`, base stable complète V43.15 `34d8f73`. Essai 2 conservé au commit source `0f60c78` et dans son APK/ZIP précédemment livrés. Aucun changement de main.

## Améliorations convenues

**Terrains uniformisés.** Un seul matériau fixe et sans miroir pour chaque type : plaine, cultures, forêt, mais aussi prairie et hauteur. Un seul massif forestier est utilisé partout. Teintes et contraste du sol sont adoucis ; le rendu n’alterne plus des variantes selon l’index. L’altitude publique, le brouillard, les routes et les surimpressions tactiques restent visibles et peuvent naturellement modifier l’apparence d’une case. Les maisons gardent leurs variantes. Les routes existantes sont dessinées au-dessus du feuillage pour rester lisibles, sans changer leur trajet ni leurs propriétés.

**Destinations de déplacement.** Points ivoire opaques à contour sombre, plus grands et accompagnés d’une légère surbrillance. La liste de cases admissibles, les conditions d’affichage, la sélection tactile, les chemins et les PA sont inchangés. Les points apparaissent uniquement aux endroits déjà autorisés par le moteur.

**Un ou deux soldats d’infanterie.** Effectif actuel inférieur à 2 000 : une illustration ; à partir de 2 000 inclus : deux illustrations décalées dans le même pion. Passage automatique à une silhouette lorsque les pertes ramènent l’effectif à 1 999. Pas de nouvelle unité, de fusion, de bonus ou d’augmentation du pion. Cavalerie, artillerie et QG gardent leurs illustrations. Le contraste des illustrations prussiennes est relevé. Force, drapeau et états restent au-dessus des dessins ; 90 bandes de force comparées sont identiques en pixels.

**Brouillard respecté.** Pour ses unités, le joueur dispose de l’effectif réel. Pour l’ennemi, le dessin utilise seulement le rapport de reconnaissance : valeur exacte si elle est déjà autorisée, ou deux silhouettes si la borne basse connue atteint 2 000. Un intervalle ambigu conserve une silhouette générique ; celle-ci n’est donc pas une confirmation d’un effectif ennemi inférieur à 2 000. Le rendu ne lit pas l’effectif réel caché pour choisir le nombre de soldats. Les tests de deux mondes aux mêmes renseignements donnent des images identiques malgré des effectifs ou déplacements ennemis masqués différents.

**Localités et bandeaux.** Les noms de villages cherchent une place moins masquée par les pions et étiquettes déjà visibles. Un trait discret rattache un nom décalé à son ancre. Spachbach reste du même côté de la Sauer et la flèche/texte Reichshoffen gardent leur géométrie. Les coordonnées des villages ne changent pas. Le placement est mis en cache d’après la géométrie publique et invalidé au déplacement connu, changement de zoom/caméra ou de partie. Bordures des bandeaux plus discrètes et peaux désactivées plus sombres ; informations, boutons, positions, fonctions et disponibilité identiques.

## Périmètre et fichiers

Modifications de cet essai dans `graphics2d_art.gd` (rendu et placement), `map_view.gd` (appels de dessin), trois peaux SVG et leur générateur, identité de version, tests et rapports. Aucune nouvelle image lourde : les deux planches peintes de l’essai 2 sont réutilisées.

Par rapport à la base stable, seuls cinq fichiers déjà existants changent : `map_view.gd`, `main.gd`, `project.godot`, `export_presets.cfg` et le seul badge de `fr.json`. Les autres modules graphiques sont des ajouts des essais. 1 333 fichiers de la base restent identiques, dont IA, core, plateforme, scènes, carte et packs. 118 fonctions sur 128 dans les deux scripts de présentation existants restent identiques. L’inventaire exhaustif est dans `FICHIERS_GRAPHISMES_2D.txt`.

Les ressources/crédits des planches restent dans `development/graphics2d2`. Les nouveaux tests et fixtures sont dans `tests/graphics`. Comparaisons et preuves : `captures/graphismes2d3`.

## Règles, données et sauvegardes

IA Normal/Difficile, coûts/portées, charge 2 PA, ripostes, variante B, 20 tours, score 60/20/20, trois objectifs/poids, effectifs/renforts, commandement/ravitaillement, isolement/reddition, sauvegardes, brouillard et animations conservés. Aucun bouton TIRER ajouté. Carte 30 × 20 et 95 unités totales de la base. Nouvelles parties : Frœschwiller 3, Wœrth 2, Niederwald 1 ; anciennes dispositions de sauvegarde respectées.

Le pack reste identique : SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Les nouvelles informations graphiques sont calculées au rendu, sans champ ajouté aux sauvegardes. Relecture/réécriture sans perte de fixtures réelles de test produites par les essais 1 et 2, originaux conservés.

## Installation

Installer **1870_V43_Graphismes_2D_Experimental_03.apk par-dessus l’essai précédent, sans le désinstaller**, pour conserver sa sauvegarde. Même application **1870 · Essai graphique 2D**, même paquet `org.woerth1870.prototype.graphics2dexp`, même certificat ; code Android 3, version `0.8.43.15-g2d3`.

L’application reste distincte du jeu stable. Pour retrouver ce dernier, ouvrir le jeu habituel ; sa partie n’est pas transférée automatiquement vers l’essai. Aucune intégration de ces graphismes dans main avant validation visuelle.

Godot 4.5.1, Android minimum API 24/cible 35, ARMv7/ARM64/x86_64, signature de développement vérifiée. Aucun test physique ou sur émulateur Android.

## Vérifications et limites

5 078 assertions finales réussies, six snapshots de commandes identiques et six comparaisons réelles de même état/caméra. Le test dédié vérifie les seuils d’effectif, la confidentialité des renseignements, l’uniformité des trois terrains, les marqueurs contrastés, les étiquettes et les bandes de force. Les animations canon/fusil sont réexécutées sans changer leur code.

Un seul motif répété par terrain est un choix assumé de lisibilité ; il donne un aspect plus régulier à la carte. Le placement de noms améliore les secteurs encombrés sans garantir l’absence de tout recouvrement lorsqu’aucune place proche n’est libre. La taille du texte, les boutons et la surface de carte sont conservés. La fluidité et le confort sur téléphone restent à apprécier. Détails dans `TESTS_GRAPHISMES_2D.md`.
