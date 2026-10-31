# Essai graphique № 8 — caractères du bandeau supérieur agrandis

Version `0.8.43.15-g2d8`, 31 octobre 2026, branche `v43-graphismes-2d-experimental`. Essai 7 conservé au commit source `857308c` et dans ses livraisons ; V43.15 stable/main préservées.

## Demande et résultat

Heure et tours : police 20 → 24 (+20 %). Journal, Aide et Menu : 17 → 22 (+29 %), pictogrammes 16 → 18. Les trois boutons s’élargissent horizontalement à 130/110/116 pixels logiques et le cartouche horaire à 332 pixels, sans augmenter la hauteur du bandeau (92 pixels). Camp et cartouche restent séparés. Titre historique conservé.

Même contenu, mêmes callbacks et fonctions. Aucun bouton d’action ajouté. Le bandeau inférieur reste à 180 pixels et la carte à 448 pixels de haut à 1280 × 720. La carte, les pions, leur luminosité, les cadres tactiques, le trajet préparé, les aides tactiles et la fiche de l’essai 7 sont préservés. Huit comparaisons confirment l’identité exacte de tous les pixels sous l’en-tête.

IA Normal/Difficile, combat, charge 2 PA, ripostes, variante B, isolement/reddition, commandement/ravitaillement, 20 tours, score 60/20/20, objectifs/pondérations, effectifs/renforts, QG Raoult, brouillard, sauvegardes et animations inchangés. Aucun bouton TIRER.

## Installation et sources

Installer `1870_V43_Graphismes_2D_Experimental_08.apk` par-dessus l’essai précédent, **sans le désinstaller**, pour conserver sa partie. Même application « 1870 · Essai graphique 2D », même paquet `org.woerth1870.prototype.graphics2dexp`, même certificat, code Android 8. Les sauvegardes des essais 1 à 7 se rechargent/réécrivent sans perte ; les originaux restent intacts. Application stable et sauvegarde stable séparées, sans transfert automatique.

ZIP complet du jeu : scripts, scènes, ressources, tests, rapports et galerie courante. Anciennes galeries 1 à 7 omises pour éviter la duplication ; elles restent dans l’historique et les anciennes livraisons GitHub. Aucun fichier nécessaire au jeu omis ; caches et compilations exclus.

Galerie : `captures/graphismes2d8/README.md`. Tests : `TESTS_GRAPHISMES_2D.md`. Fichiers : `FICHIERS_GRAPHISMES_2D.txt`.

## Vérification et limites

5 971 assertions finales réussies. Trois tailles logiques testées : 1280 × 606, 1280 × 720, 1520 × 720 ; deux camps, deux phases, tours 1 à 20 et affichage final. APK compilé/signature vérifiée. Captures réelles sous Godot 4.5.1 ; aucun test physique ou émulateur Android. Les fenêtres d’aide/journal existantes ne sont pas redessinées dans cette étape. Aucune intégration dans main avant validation visuelle.

Pour une étape ultérieure : réglage de taille du texte dans le menu et filtres du journal. Ce sont des propositions, pas des fonctions ajoutées à cet essai.
