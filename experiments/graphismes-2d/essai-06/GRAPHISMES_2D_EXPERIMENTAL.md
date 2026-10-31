# Essai graphique № 6 — bandeaux et fiche plus lisibles

Version `0.8.43.15-g2d6`, 31 octobre 2026. Branche `v43-graphismes-2d-experimental`, essai précédent conservé au commit source `75c0aae`. Base stable V43.15 `34d8f73`, main inchangée. Aucun remplacement de la version stable.

## Changements visuels

Le titre historique conserve sa typographie. La mention du camp devient plus discrète ; heure et tour sont réunis dans un cartouche avec une horloge. Journal, Aide et Menu reçoivent un petit pictogramme dans leur bouton existant. Dimensions, position, texte et actions des boutons conservés.

La fiche d’unité conserve ses quatre lignes et ses deux colonnes. Nom du régiment un peu plus présent et mesuré avec sa vraie police ; PA en gras, y compris les fractions. Les petits signes de moral, munitions, riposte, commandement et ravitaillement complètent le texte. Vert : état assuré/en ordre ; orange : désorganisation ou liaison seule perdue ; rouge sur les liaisons : double coupure. Le rouge ne signifie pas automatiquement une déroute. Le texte reste toujours la référence.

Les pictogrammes lisent exclusivement les libellés déjà autorisés à l’écran. Aucune déduction à partir d’effectifs, de moral ou de liaisons ennemies cachées. Les détails de commandement/ravitaillement restent accessibles en touchant leurs lignes. Aucune vignette supplémentaire : la place reste réservée aux effectifs et aux informations tactiques.

## Ce qui est conservé

Palette des hexagones V43.15 et illustrations éclaircies de l’essai 5 ; soldats historiques, une/deux silhouettes au seuil de 2 000 hommes connus, grands points de déplacement contrastés, décor et noms. Dans six captures identiques, toute la zone de carte et les 90 bandes de force sont strictement identiques en pixels à l’essai 5.

Bandeaux 92/180 pixels, carte 448 pixels de haut à 1280 × 720. Aucun bouton ajouté/supprimé/renommé, aucune commande déplacée. IA Normal/Difficile, règles, charge 2 PA, ripostes, variante B, 20 tours, score 60/20/20, trois objectifs 3/2/1, renforts et effectifs, QG Raoult, sauvegardes, brouillard et animations intacts. Aucun bouton TIRER.

1 333 fichiers de la base stable identiques ; les cinq fichiers existants modifiés depuis le début des essais restent de présentation/configuration et le badge de version. 116 fonctions sur 128 identiques dans les deux scripts de présentation existants. `refresh()` est inchangée. Nouveau décor isolé dans `war_engine/presentation/hud_details.gd`, quatre petits SVG, aucun shader ou traitement continu.

## Livraison et installation

Installer `1870_V43_Graphismes_2D_Experimental_06.apk` par-dessus l’essai précédent **sans le désinstaller**. Même application « 1870 · Essai graphique 2D », même paquet `org.woerth1870.prototype.graphics2dexp`, même certificat, code Android 6. Les sauvegardes des essais 1 à 5 sont relues/réécrites sans perte ; originaux inchangés. L’application stable et sa partie restent séparées, sans transfert automatique.

Sources complètes du jeu, ressources, tests, documentation et galerie courante fournis. Le ZIP omet les anciennes galeries des essais 1 à 5 pour éviter leur duplication ; elles restent dans l’historique et les anciennes livraisons GitHub. Aucun script, scène ou ressource nécessaire au jeu n’est omis. Caches Godot, compilations et fichiers temporaires exclus.

Galerie avant/après : `captures/graphismes2d6/README.md`. Détail des validations : `TESTS_GRAPHISMES_2D.md`. Fichiers : `FICHIERS_GRAPHISMES_2D.txt`.

## Limites

5 183 assertions finales réussies, APK compilé et signature vérifiée. Captures réelles Godot 4.5.1 sous rendu logiciel Linux ; aucun essai physique ou sur émulateur Android. Les mesures ne garantissent pas la fluidité sur un téléphone particulier. Aucun changement intégré à main avant validation visuelle. Les chevauchements de noms dans les zones très denses restent ceux de l’essai précédent.
