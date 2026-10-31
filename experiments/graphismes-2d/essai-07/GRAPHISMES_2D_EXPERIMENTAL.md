# Essai graphique № 7 — sélection, déplacements et aides tactiles

Version `0.8.43.15-g2d7`, 31 octobre 2026, branche `v43-graphismes-2d-experimental`. Essai 6 conservé au commit source `36a0a83` et dans ses livraisons. V43.15 stable `34d8f73` et main préservées.

## Les six retouches approuvées

1. **Sélection.** Quatre coins ivoire à fond sombre remplacent le contour plein. Ils restent distincts des cadres tactiques rouge/vert, dont la taille et la signification ne changent pas. Une comparaison a confirmé que l’ancien contour masquait trois colonnes de pixels du drapeau d’un pion voisin : ce drapeau est maintenant dégagé.
2. **Déplacements.** Les points ivoire accessibles restent identiques. Le trajet préparé devient bleu-vert, bordé de clair, avec une destination en losange doré cerclé. La partie hors budget reste pointillée et « Limite » reste affichée. La seconde touche confirme toujours le déplacement. Aucun historique de trajet ou nouvel ordre ajouté.
3. **Localités.** Halo ivoire un peu plus clair, adapté au zoom. Police, positions, calcul d’évitement des pions, routes, ponts, rivière et données géographiques inchangés.
4. **Fiche d’unité.** Un trait fin sépare effectifs/PA des états. Lignes, colonnes, dimensions et informations conservées.
5. **Actions indisponibles.** Fond mat et bordure gris-bleu, texte clair lisible. Les actions actives restent contrastées. La désactivation, son explication au toucher et les callbacks sont les mêmes.
6. **Aides tactiles.** Toucher les petits signes de moral, munitions ou riposte ouvre une explication courte. Les signes de commandement/ravitaillement ouvrent les détails existants. Aucun ordre ou sauvegarde déclenché ; informations ennemies inconnues sans cible d’aide ni détail supplémentaire.

## Conservation de la base

Même palette claire V43.15 que dans l’essai 6, mêmes illustrations historiques et règle d’une/deux silhouettes au seuil de 2 000 hommes connus. Aucun éclaircissement supplémentaire, nouveau bitmap, shader ou éclairage. Carte 30 × 20, bandeaux 92/180 pixels et carte de 448 pixels à 1280 × 720. Pas de bouton d’action ajouté, supprimé ou renommé ; retour de l’aide par la navigation habituelle.

IA Normal/Difficile, défense française, combat, charge 2 PA, ripostes, variante B, commandement/ravitaillement, isolement/reddition, 20 tours, score 60/20/20, objectifs 3/2/1, effectifs/renforts, QG Raoult, brouillard, sauvegardes et animations sont conservés. Aucun bouton TIRER.

1 333 fichiers de la base stable identiques ; tous les modules IA/core/plateforme/scènes et données de jeu intacts. 115/128 fonctions identiques dans les deux scripts de présentation existants, exceptions limitées au rendu. `refresh()` inchangée. Les textes d’aide sont isolés dans le décor HUD ; seuls les libellés déjà affichés servent aux nouveaux indicateurs/aides.

## Installation et contenu

Installer `1870_V43_Graphismes_2D_Experimental_07.apk` par-dessus l’essai précédent **sans le désinstaller**. Application « 1870 · Essai graphique 2D », paquet `org.woerth1870.prototype.graphics2dexp`, certificat identique, code Android 7. Les sauvegardes des essais 1 à 6 se relisent et se réécrivent sans perte ; les originaux restent intacts. La stable garde sa propre application et sa partie ; pas de transfert automatique.

Sources complètes du jeu, ressources, tests, rapports et galerie courante. Les anciennes galeries 1 à 6 ne sont pas dupliquées dans le ZIP ; elles restent sur GitHub et dans les anciennes livraisons. Aucun script, scène ou ressource du jeu omis. Caches, compilations et fichiers temporaires exclus.

Galerie : `captures/graphismes2d7/README.md`. Détails : `TESTS_GRAPHISMES_2D.md`. Liste exhaustive : `FICHIERS_GRAPHISMES_2D.txt`.

## Vérification et limites

5 350 assertions finales réussies, huit états/commandes comparés, 121 zones de chiffres de force identiques. APK compilé, signature vérifiée. Captures réelles sous Godot 4.5.1/Linux ; aucun essai physique ou émulateur Android. Les cibles tactiles de la fiche font 44 × 28 pixels logiques, limitées par ses lignes compactes : leur confort sur écran réel reste à apprécier. Les noms peuvent rester partiellement couverts en zone très dense. Aucun changement intégré à main avant validation visuelle.
