# Essai graphique 2D № 2 — version 0.8.43.15-g2d2

30 octobre 2026. Branche `v43-graphismes-2d-experimental`.

## Demande et base conservée

Deuxième essai visuel, inspiré de l’image fournie par le joueur : carte plus naturelle, pions historiquement illustrés, bandeaux haut/bas bleu nuit avec finitions laiton. La photo guide l’apparence ; les données et règles de V43.15 restent la référence.

Base stable complète : `34d8f73ecdce503adc7fc149474653876176af41`. Premier essai conservé au commit source `b43be4a` et dans son ZIP/APK déjà livrés. Aucune intégration de ces graphismes dans la branche principale. La défense française Difficile et l’ossature prussienne de la base restent inchangées.

## Améliorations réalisées

- **Carte** : deux planches de ressources 2D peintes. Prairies avec touffes discrètes, champs ocre/vert, sous-bois, feuillages denses et villages à maisons/toits détaillés. Variantes choisies par index d’hexagone, sans appel au RNG du jeu. Décors limités au polygone de leur hexagone ; grille et surimpressions tactiques restent au-dessus.
- **Sauer et routes** : pinceaux de berge/eau plus riches et reflets statiques. Les mêmes segments et extrémités de rivière sont utilisés ; aucune courbe nouvelle, case de rivière, liaison ou règle de passage ajoutée. Routes sur leurs points existants ; ponts et deux inscriptions Sauer conservés. Le nom des localités utilise une police sérif plus lisible. Flèche et ancre de Reichshoffen conservées.
- **Pions** : illustrations de fantassins, cavaliers et batteries françaises/prussiennes plus détaillées. Fond légèrement ombré et bordure laiton. Même encombrement et mêmes centres ; force, drapeaux, statut, états de tir et contours tactiques sont dessinés après les illustrations. Aucun numéro redondant réintroduit. Les QG conservent leur drapeau et leurs contours.
- **Bandeaux** : habillage bleu nuit et laiton par neuf-tranches et gradients SVG légers. Les informations, dimensions, positions et interactions restent celles du jeu. La fiche inférieure gauche conserve son organisation et son contenu ; sa peau graphique est modernisée à la demande du joueur. Aucun ajout de commande ni de bouton TIRER. Boutons actifs, pressés, survolés, désactivés et focus distincts.

Les nouvelles illustrations militaires sont génériques par arme et camp, sans modification des caractéristiques des régiments. Les PNG originaux sont livrés ; les sources des peaux SVG et le manifeste des régions aussi. Voir `development/graphics2d2/CREDITS.md`.

## Fichiers et portée technique

Cinq fichiers déjà présents dans la base stable changent :

| Fichier | Portée |
| --- | --- |
| `war_engine/presentation/map_view.gd` | Appels du rendu terrain, statique des pions, police des localités et ordre des surimpressions. Aucune modification de l’input, des positions ou du déroulement des animations. |
| `war_engine/presentation/main.gd` | Fabrication des peaux de panneaux/boutons et ligne décorative d’en-tête. Callbacks, disponibilité et disposition inchangés. |
| `project.godot` | Nom/version/dossier de l’application expérimentale ; moteur et dimensions conservés. |
| `export_presets.cfg` | Paquet distinct de la stable, numéro d’APK expérimental et version. |
| `packs/1870/fr.json` | Seulement le badge de version expérimentale. Aucun nom, texte de commande ou donnée d’unité modifié. |

Modules expérimentaux : `graphics2d_art.gd` utilise maintenant les deux planches peintes ; `graphics2d_skin.gd` fournit les peaux de bandeaux et boutons. Ressources nouvelles dans `assets/graphics2d2`, sources/crédits dans `development/graphics2d2`, tests dans `tests/graphics`, comparaisons dans `captures/graphismes2d2`.

L’inventaire exhaustif par rapport à V43.15 est dans `FICHIERS_GRAPHISMES_2D.txt`. Les fichiers `.import` et `.uid` sont des réglages/références nécessaires à Godot, et non des caches. Les sources ZIP excluent caches `.godot`, Git, APK, compilations et temporaires.

## Règles et sauvegardes

1 333 fichiers de la base stable restent identiques en octets, dont tous les modules IA, moteur, plateforme, scènes, packs de scénarios et données de carte. Sur les 128 fonctions des deux scripts de présentation existants, 118 restent identiques ; dix fonctions de rendu/fabrication de peau changent. Les routines de projectile, impacts, durées, sons, input, transformations de caméra et affichage d’état restent identiques.

Carte 30 × 20, 20 tours, charge à 2 PA, coûts/portées, ripostes, variante B, commandement/ravitaillement, isolement/reddition, effectifs, renforts, brouillard et score 60/20/20 conservés. Objectifs de nouvelle partie conservés : Frœschwiller 3, Wœrth 2, Niederwald 1. Les anciennes dispositions de sauvegarde restent respectées.

Hash inchangé du scénario : `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

Même format de sauvegarde, même `SaveStore` et même empreinte de pack. Relecture vérifiée d’une sauvegarde synthétique écrite par l’essai 1, réenregistrement d’une copie et comparaison intégrale du JSON ; original conservé. Les six états d’interface et les 76 bandes de force visibles des comparaisons sont identiques pour leur contenu et fonctionnement.

## Installation

**Installer `1870_V43_Graphismes_2D_Experimental_02.apk` par-dessus l’essai 1, sans le désinstaller.** Paquet expérimental conservé : `org.woerth1870.prototype.graphics2dexp`, code Android 2, version `0.8.43.15-g2d2`, même certificat. La sauvegarde de l’essai 1 peut ainsi rester dans son espace.

L’application s’appelle toujours **1870 · Essai graphique 2D**. Elle reste installable à côté du jeu stable, dont le paquet et les fichiers ne changent pas. Pour retrouver la version stable, ouvrir le jeu habituel. Il n’y a pas de transfert automatique de la partie stable vers l’application expérimentale.

APK Godot 4.5.1 compilé, signature de développement vérifiée, Android minimum API 24/cible 35, ARMv7/ARM64/x86_64. Aucun essai sur appareil ou émulateur Android.

## Évaluation et limites

5 036 assertions finales réussies. Les comparaisons montrent le jeu réellement rendu, avec le même état T11 et la même caméra dans chaque paire. Il ne s’agit pas d’une nouvelle bataille chronologique ni de la reproduction de la photo du joueur.

Deux textures partagées, régions mises en cache, mipmaps, surfaces hors écran écartées, petites peaux SVG réutilisées. Aucun éclairage 3D, shader ou effet de particules ajouté. Sur la vue comparée, les appels de dessin passent de 3 462 à 2 844 ; temps et mémoire détaillés dans le rapport de tests. Le confort et la fluidité sur téléphone restent à apprécier.

Quelques noms de localités restent partiellement recouverts par les pions dans les secteurs très denses, comme dans le témoin. Aucune unité ou localité n’a été déplacée pour arranger les captures. L’apparence vise la direction artistique de la référence tout en conservant la grille et la géographie exactes du jeu.

Aucune fusion dans main avant validation visuelle. Comparaisons : `captures/graphismes2d2/README.md` ; tests et preuves : `TESTS_GRAPHISMES_2D.md`.
