# Tests exécutés — essai BD 2

31 octobre 2026, Godot 4.5.1 officiel `f62fdbde1`, Linux / OpenGL Compatibility (llvmpipe). Campagne actuelle : **3 085 assertions réussies**, 179 parcours avec rendu + 2 906 non-régression. Les résultats de l’essai BD 1 ne sont pas comptés comme des tests nouveaux.

## Parcours avec rendu et toucher : 179/179

Six illustrations réparées chargées et comparées aux nouvelles empreintes ; six JPEG d’origine archivés intacts ; six titres et textes révisés affichés. Contrôles tactiles, textes et cadres à 1280 × 606, 1280 × 720, 1520 × 720. Images entières sans déformation, pas de nouveau recadrage. Anciennes phrases tronquées supprimées dans les illustrations, vérification visuelle des captures réelles.

Navigation, passage pendant fondu, retour menu, retour Android simulé, pause/reprise en arrière-plan, véritable intervalle de 30 secondes, séquence automatique accélérée sur les six tableaux. Lecture d’un paragraphe dépassant : indice de défilement, glissement tactile réel, défilement automatique atteignant le bas. Création d’une partie seulement après choix explicite du camp ; difficultés inchangées ; reprise directe et relancement de l’application. État, retour arrière et sauvegarde inchangés pendant la lecture et en abandonnant la BD. Images libérées à la fermeture ; aucune fin déclenchée deux fois.

## Non-régression ciblée

| Suite | Résultat |
| --- | --- |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_feedback12` | 20/20 |
| `v43/test_v4315` | 28/28 |
| `intro_bd/test_resume_direct` | 9/9 |

La reprise est testée dans un processus séparé : slot V43 valide relu, état et fichier identiques, aucune image PNG de la BD chargée lors de Continuer. Anciens formats relus dans les fixtures ; disponibilité, gestes de carte, interface et défense V43.15 vérifiés. Toutes les assertions finales passent ; aucune suite désactivée. Pas de nouveau test complet de bataille, de combat physique sur appareil ou d’émulation Android.

## Intégrité

Comparaison avec l’essai BD 1 : aucun fichier de gameplay, de scène principale, contrôleur principal, IA, plateforme, terrain ou graphisme de jeu modifié. Modifications limitées à l’introduction, images et textes, métadonnées de version, attentes de tests et documentation. Les JPEG ont été déplacés dans le prototype archivé, pas détruits ; leurs six empreintes sont identiques. La fixture originale reste conservée ; une fixture séparée décrit la révision 2 approuvée.

Contrôle avec la stable V43.15 également réussi. Pack SHA-256 inchangé : `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Aucune règle assouplie pour faire passer les tests. Les différences d’images et de textes sont celles demandées par l’utilisateur.

## Histoire et images

Référence consultée : James Wycliffe Headlam, 1899, édition Gutenberg nº 12400 via le miroir GITenberg. Les accès directs essayés aux sites institutionnels et encyclopédiques ont été refusés par le réseau (403), et ne sont pas présentés comme consultés. Voir `SOURCES_HISTORIQUES_BD.md`. Narration révisée en synthèse, sans reprendre les jugements polémiques de cet ouvrage ancien. Pas de nouvelle validation académique ou de précision documentaire revendiquée pour les dessins.

Les illustrations ont été retouchées/recomposées avec l’outil d’image à partir du prototype. Les captures sont réellement rendues par Godot, sans retouche. La première carte rouge générée a été écartée au profit d’un fond géographique neutre pour éviter de suggérer des frontières politiques erronées en 1866.

## APK et archive

APK compilé/signé, `0.8.43.15-bd2`, code 2, même paquet/certificat que BD 1. Signatures v2/v3, métadonnées, contenu ZIP vérifiés. Les six textures réparées de l’APK sont identiques aux textures importées testées ; limite 1280 et compression de source vérifiées. Les paramètres d’import sont normalement retirés des fichiers de remappage exportés par Godot ; les données de texture elles-mêmes ont donc été comparées, sans supposer leur présence dans ces métadonnées réduites.

Originaux JPEG, tests, captures et développement exclus de l’APK. ARMv7/ARM64/x86_64, minimum SDK 24/cible 35. Avertissement connu de la sonde ADB sur son dossier personnel en lecture seule après export ; export et signature réussis. Aucun essai Android physique ou émulateur, aucune affirmation de FPS sur téléphone.

Archive complète extraite et importée dans un dossier indépendant : parcours headless 167/167, reprise directe 9/9, anciennes sauvegardes 63/63 et intégrité avec la stable réussis. Les vérifications de captures et de toucher réel ont été exécutées dans le test avec rendu. Ces répétitions ne sont pas ajoutées aux 3 085 assertions. Code fonctionnel identique, rapports/preuves complétés après vérification.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/intro_bd/test_intro_flow.gd -- /tmp/captures_intro
godot --headless --path . --script res://tests/intro_bd/test_resume_direct.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
```

Créer le dossier de captures et utiliser un nouveau répertoire utilisateur isolé pour le test de parcours, qui commence sans sauvegarde. Preuves détaillées dans la galerie.
