# Essai graphique № 9 — cadre horaire centré

Version `0.8.43.15-g2d9`, 31 octobre 2026. Branche `v43-graphismes-2d-experimental`. Essai 8 conservé au commit source `a6b1e9b` et dans ses livraisons ; stable/main préservées.

Le cadre heure/tours a désormais le même centre vertical que Journal, Aide et Menu : 47 pixels logiques, au lieu de 61. Son centrage est calculé à partir de la position et de la hauteur du bouton Journal. Le cadre reste haut de 36 pixels, les boutons de 50 ; leurs centres coïncident.

Le cadre est légèrement décalé à droite et sa largeur ajustée à 310 pixels pour dégager le titre. Le titre conserve sa police et ses caractères ; seule sa boîte vide est resserrée. Heure/tours restent en 24, Journal/Aide/Menu en 22, avec les mêmes textes, boutons et fonctions. Pas de perte de place pour la carte : bandeau supérieur 92, inférieur 180, carte 448 pixels à 1280 × 720.

Carte, pions, luminosité, fiche, aides tactiles, actions, IA Normal/Difficile, charge 2 PA, ripostes, commandement/ravitaillement, isolement/reddition, 20 tours, score 60/20/20, objectifs/pondérations, effectifs/renforts, variante B, QG Raoult, brouillard, sauvegardes et animations inchangés. Aucun bouton TIRER. Les huit vues comparées ont exactement les mêmes pixels sous l’en-tête que l’essai 8.

Installer `1870_V43_Graphismes_2D_Experimental_09.apk` par-dessus l’essai précédent, **sans le désinstaller**. Même application « 1870 · Essai graphique 2D », même paquet expérimental, même certificat ; code Android 9. Sauvegardes des essais 1 à 8 relues/réécrites sans perte, originaux préservés. Stable et partie stable séparées, sans transfert automatique.

Sources complètes du jeu et galerie courante incluses. Anciennes galeries 1 à 8 non dupliquées dans le ZIP, toujours disponibles dans GitHub/historique. Aucun fichier nécessaire au jeu omis ; caches et compilations exclus. Galerie : `captures/graphismes2d9/README.md`. Tests : `TESTS_GRAPHISMES_2D.md`. Fichiers : `FICHIERS_GRAPHISMES_2D.txt`.

3 369 assertions finales réussies, APK compilé et signature vérifiée. Captures Godot 4.5.1/Linux ; aucun test physique ou émulateur Android. Aucune intégration à main avant validation visuelle.
