# Essai graphique № 5 — palette de référence V43.15

Version `0.8.43.15-g2d5`, 30 octobre 2026, branche `v43-graphismes-2d-experimental`. Base stable complète V43.15 `34d8f73`. Essai 4 conservé au commit source `285db09` et dans ses APK/ZIP. La version stable et main ne changent pas.

## Demande et résultat

Le joueur souhaite retrouver la clarté de la V43.15 non expérimentale. La comparaison utilise maintenant la vraie base stable, dans les mêmes états et cadrages, avec une galerie à trois colonnes : stable / essai 4 / essai 5.

**Hexagones.** Retour aux couleurs de fond exactes du pack V43.15 : plaine beige clair, cultures ocre doux, forêt vert clair, autres terrains selon leur couleur d’origine. La couche peinte verte qui assombrissait ces couleurs n’est plus dessinée ni préchargée. Les hexagones restent uniformes par type. Relief public, routes, villages, rivière, ponts et limites restent à leur place. La légère surbrillance des déplacements reprend également celle de la stable ; les grands points ivoire à contour sombre sont conservés.

**Pions.** Les couleurs nationales d’origine servent toujours de base, avec un léger modelé du fond. Les illustrations détaillées restent différentes des anciens dessins vectoriels : leurs ombres sont relevées par une sous-couche claire utilisant la transparence du même dessin. Aucun nouveau bitmap ou shader. L’illustration garde son modelé, mais les uniformes et les chevaux/canons sont plus faciles à distinguer. Les pions ne sont pas prétendus identiques pixel par pixel à la stable.

**Décors et interface.** Bois et maisons détaillés conservés, éclaircis dans le même esprit. Noms mieux dégagés, bandeaux, commandes et dispositions des essais précédents conservés. La surimpression du brouillard reste inchangée. Les 90 bandes de force comparées sont identiques en pixels à la stable ; aucun numéro redondant réintroduit.

Sur les six vues mesurées, la moyenne RGB de la carte est proche de celle de V43.15 ; celle des zones de pions est légèrement supérieure. Ce sont des indices numériques de captures, pas une calibration physique d’écran.

## Fonctionnement inchangé

Une silhouette d’infanterie sous 2 000 hommes actuels, deux à partir de 2 000 inclus. Cavalerie, artillerie et QG gardent leur type d’illustration. Pour l’ennemi, seules les valeurs du rapport autorisé sont utilisées ; un intervalle ambigu conserve une silhouette générique. Aucune unité supplémentaire, fusion ou bonus.

IA Normal/Difficile, charge 2 PA, coûts/portées, ripostes, variante B, 20 tours, score 60/20/20, objectifs/poids, effectifs/renforts, commandement/ravitaillement, isolement/reddition, sauvegardes et animations inchangés. Aucun bouton TIRER. Carte 30 × 20 et 95 unités totales de la base. Coordonnées et flèche Reichshoffen conservées.

## Intégrité et fichiers

1 333 fichiers de la base stable restent identiques, dont tous les modules IA, core, plateforme, scènes et packs. 118 fonctions sur 128 restent identiques dans les deux scripts de présentation existants. Les cinq fichiers existants concernés depuis le début des essais restent ceux de présentation/configuration et le seul badge de `fr.json`. Liste exhaustive : `FICHIERS_GRAPHISMES_2D.txt`.

Pack inchangé : SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Aucun champ ajouté aux sauvegardes. Les fixtures écrites par les essais 1 à 4 se rechargent et se réécrivent sans perte, originaux conservés.

Modifications de cette étape : couleurs/rendu dans `graphics2d_art.gd` et `map_view.gd`, version, tests et rapports. Le PNG des illustrations est réutilisé ; l’ancienne planche peinte du sol reste archivée dans les sources mais n’est plus préchargée. Crédits conservés dans `development/graphics2d2`.

Galerie : `captures/graphismes2d5/README.md`. Les scripts Python d’analyse optionnelle requièrent Pillow uniquement pour lire les PNG ; le jeu n’en dépend pas.

## Installation et limites

Installer **1870_V43_Graphismes_2D_Experimental_05.apk par-dessus l’essai précédent, sans désinstaller**, pour conserver sa sauvegarde. Même application **1870 · Essai graphique 2D**, même paquet `org.woerth1870.prototype.graphics2dexp`, même certificat ; code Android 5, version `0.8.43.15-g2d5`.

L’application stable reste séparée avec sa propre partie. Aucun transfert automatique entre les deux applications. Aucune fusion dans main avant validation visuelle.

5 090 assertions finales réussies. Godot 4.5.1, APK compilé/signature vérifiée, API minimum 24/cible 35, ARMv7/ARM64/x86_64. Aucun essai physique ou sur émulateur Android. Les illustrations plus détaillées ne peuvent reproduire exactement la répartition des ombres des anciens symboles ; la palette des hexagones est identique et la luminosité globale proche, avec les différences documentées dans `TESTS_GRAPHISMES_2D.md`. Certains noms restent partiellement recouverts en secteur très dense.
