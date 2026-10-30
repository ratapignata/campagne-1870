# Essai graphique 2D № 4 — carte et pions éclaircis

Version `0.8.43.15-g2d4`, 30 octobre 2026, branche `v43-graphismes-2d-experimental`. Base stable complète V43.15 `34d8f73`, essai 3 conservé au commit source `1e3f8fe` et dans ses APK/ZIP. Aucune fusion dans main.

## Réponse au retour visuel

La carte et les silhouettes de l’essai 3 paraissaient trop sombres. Cet essai relève la lumière du sol, des bois et des pions tout en gardant l’identité historique et les mêmes motifs.

- Fonds de terrains plus clairs, mélange des textures de sol adouci. Un même matériau par terrain, sans variante ni miroir ; relief public conservé.
- Feuillages plus lumineux et maisons légèrement éclaircies ; mêmes dessins et mêmes positions.
- Fonds des pions éclaircis, surtout la partie basse qui était très sombre. Couleurs nationales conservées. Illustrations françaises et prussiennes plus lumineuses, avec une attention aux uniformes allemands. Deux soldats moins assombris l’un derrière l’autre.
- Aucun filtre global : chiffres, drapeaux, marqueurs d’état, objectifs, textes, points de déplacement, trajectoires et animations ne sont pas blanchis par un post-traitement. Les 90 bandes de force comparées restent identiques pixel par pixel.
- La surimpression du brouillard reste exactement la même, appliquée après le terrain. Elle continue de distinguer les secteurs non observés ; aucun renseignement ennemi supplémentaire n’est affiché.
- Les bandeaux bleu nuit restent inchangés pour préserver le contraste avec la carte claire et la lisibilité des informations.

Les gains sont appliqués aux couleurs de dessin dans `graphics2d_art.gd` et aux fonds dans `map_view.gd`. Les deux images peintes sont réutilisées sans modification. Aucun nouvel éclairage 3D, shader, particule ou couche de post-traitement.

## Tout le reste de l’essai 3 est conservé

Terrains uniformes, points ivoire à contour sombre, placement des noms de localités, silhouettes d’infanterie selon l’effectif actuel : une sous 2 000, deux dès 2 000 inclus. Pour l’ennemi, seules les valeurs déjà connues sont utilisées ; un intervalle ambigu conserve une silhouette générique. Cavalerie, canons et QG gardent leur type d’illustration. Aucun numéro redondant réintroduit.

Carte 30 × 20, 95 unités totales de la base et effectifs/renforts inchangés. IA Normal/Difficile, coûts/portées, charge 2 PA, ripostes, variante B, 20 tours, score 60/20/20, objectifs/poids, commandement/ravitaillement, isolement/reddition, sauvegardes, brouillard et animations conservés. Aucun bouton TIRER ajouté. Coordonnées, routes, Sauer, ponts et flèche Reichshoffen inchangés.

## Intégrité et fichiers

1 333 fichiers de la base stable sont identiques en octets, dont tous les modules IA, core, plateforme, scènes et packs. Dans les deux scripts de présentation déjà présents dans la base, 118 fonctions sur 128 sont identiques. Par rapport à cette base, cinq fichiers existants changent depuis le premier essai : présentation, configuration/version et seul badge de `fr.json`. L’inventaire complet est dans `FICHIERS_GRAPHISMES_2D.txt`.

Pack inchangé : SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Aucun champ ajouté aux sauvegardes. Les sauvegardes synthétiques réellement écrites par les essais 1, 2 et 3 sont relues/réécrites sans perte et sans écraser leurs originaux.

Comparaisons : `captures/graphismes2d4/README.md`. Tests : `TESTS_GRAPHISMES_2D.md`. L’analyse RGB optionnelle utilise Pillow uniquement pour lire les PNG ; le jeu ne dépend pas de Python/Pillow. Crédits des ressources conservés dans `development/graphics2d2`.

## Installation

Installer **1870_V43_Graphismes_2D_Experimental_04.apk par-dessus l’essai précédent, sans désinstaller**, pour conserver sa sauvegarde. Même application **1870 · Essai graphique 2D**, même paquet `org.woerth1870.prototype.graphics2dexp`, même certificat ; code Android 4, version `0.8.43.15-g2d4`.

Le jeu stable reste installé séparément avec sa partie. Aucun transfert automatique entre les espaces des deux applications ; pour retrouver le jeu stable, ouvrir son application habituelle. Aucune intégration graphique dans main avant avis visuel.

Godot 4.5.1 ; Android minimum API 24/cible 35, ARMv7/ARM64/x86_64. APK compilé et signature de développement vérifiée. Aucun essai sur appareil ou émulateur Android.

## Validation et limites

5 085 assertions finales réussies, six snapshots de commandes identiques, six comparaisons de même état/caméra et 90 bandes de force identiques en pixels. L’analyse des PNG confirme une carte et des zones centrales de pions plus claires dans les six cas. Ce sont des indices RGB, pas des mesures de luminosité physique d’un téléphone.

Temps, nombre d’appels et mémoire graphique restent comparables sur le banc logiciel. Le réglage réel de l’écran, sa colorimétrie et le confort en jeu restent à apprécier sur l’appareil du joueur. Les secteurs très denses peuvent toujours recouvrir partiellement certains noms ; cette version ne change pas le placement déjà adopté dans l’essai 3.
