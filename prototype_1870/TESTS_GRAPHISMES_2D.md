# Tests — essai graphique 2D V43.15-g2d1

Exécutés le 30 octobre 2026 avec Godot **4.5.1 stable officiel**. Base V43.15 `34d8f73`. Tests isolés dans des dossiers utilisateur dédiés ; la partie installée du joueur n’a pas été ouverte ou écrasée.

## Bilan

**5 033 assertions réussies, aucun échec dans les suites finales.** Il s’agit de 2 487 assertions existantes dans 23 suites, 2 439 contrôles graphiques/gestes/sauvegarde et 107 contrôles de rendu des animations (53 canon + 54 fusil). Les vérifications de comparaison ci-dessous sont supplémentaires ; elles ne sont pas multipliées artificiellement dans ce total.

### Suites V43.15 réexécutées

| Suite | Résultat |
| --- | --- |
| `v43/test_v4315` | 28/28 |
| `v43/test_v4314` | 25/25 |
| `v43/test_v4314_ui` | 14/14 |
| `v43/test_v4313` | 30/30 |
| `v43/test_assault_commitment` | 11/11 |
| `v43/test_v4312` | 247/247 |
| `v43/test_bridge_barrage` | 17/17 |
| `v43/test_assault_before_rest` | 8/8 |
| `test_ai_compat0833` | 18/18 |
| `v36/test_hidden_worlds` | 18/18 |
| `v36/test_isolation` | 45/45 |
| `v43/test_enclosed_links` | 25/25 |
| `v43/test_adjacent_reinforcements` | 32/32 |
| `v43/test_ui` | 30/30 |
| `v43_export/test_export` | 28/28 |
| `v43_export/test_android_eof` | 9/9 |
| `v43/test_cavalry_village125` | 20/20 |
| `v43/test_rifle_label` | 18/18 |
| `v43/test_v439_presentation` | 102/102 |
| `v43/test_surrender_journal` | 11/11 |
| `v43/test_variant_b` | 1701/1701 |
| `v43/test_raoult` | 42/42 |
| `v43/test_v4315_ui` | 8/8 |

Le résultat complet et les sorties exactes figurent dans `captures/graphismes2d/preuves/regression.json`. Aucun avertissement moteur dans ces 23 sorties finales.

### Nouveau contrat graphique

`tests/graphics/test_contract.gd` : **2 439/2 439**.

- Carte 30 × 20 et roster réel de la base (95 unités totales).
- 29 régions bornées dans un atlas unique, filtrage limité à la région, mipmaps générés.
- 2 400 vérifications de sélection : chacun des 600 centres d’hexagone aux zooms 0,42 / 0,72 / 1,05 / 2,3.
- Toucher simple, glissement et pincement synthétiques : sélection exacte, déplacement de caméra sans faux toucher, zoom, point d’ancrage conservé.
- Aucun changement de l’état moteur après préparation de la carte et gestes.
- Sauvegarde/relecture complète de l’état avec le même code et le même format ; stockage de l’application d’essai distinct.

Les gestes sont injectés dans Godot ; ce ne sont pas des essais avec les doigts sur smartphone.

### Intégrité des règles et de la géographie

`tests/graphics/check_source_integrity.py` : **PASS**. Comparaison de tous les fichiers suivis de la base : 1 333 identiques ; cinq fichiers existants changent, uniquement ceux détaillés dans le rapport. IA, core, platform, scènes, données de carte, effectifs et renforts identiques en octets. Dans les deux scripts de présentation concernés, 123 fonctions sur 128 identiques, dont dessin des soldats, calcul des positions, input, brouillard, objectifs et animations.

Le pack identique protège notamment les objectifs/poids 3/2/1, 20 tours, score 60/20/20 et caractéristiques. Les tests existants vérifient en plus Raoult/renforts, charge 2 PA, variante B, ripostes et compatibilité de sauvegarde. Aucune nouvelle simulation IA T1–T20 n’a été lancée pour cet essai visuel.

### Commandes et fiche d’unité

`tests/graphics/controls_snapshot.gd`, exécuté sur les deux versions : **six états identiques** (infanterie, cavalerie, artillerie, QG, isolement et chemin prévisualisé). Comparaison des textes, rectangles, visibilité, désactivation, callbacks et filtres de souris de toutes les commandes, des informations de fiche et des dimensions de bandeaux. Aucun bouton TIRER ajouté.

Cinq paires de captures 1280 × 720 : même état sérialisé, caméra, zoom et sélection ; **5/5 empreintes de l’état identiques et 5/5 rectangles de fiche inférieure gauche identiques pixel par pixel**. La taille de la carte disponible et les positions de commandes restent identiques. Vue générale 0,82 ; combat 1,05 ; Prussiens 1,05 ; isolement 1,0 ; détail 1,55.

### Rendu réellement exécuté

Xorg :43, OpenGL Compatibility, Mesa llvmpipe (LLVM 19.1.7, 256 bits). Captures originales enregistrées depuis le viewport Godot, sans retouche. Fixture publique `tests/fixtures/v4313_t11_simulation.json` commune aux versions ; côté prussien obtenu par changement de camp de test. La vue isolement injecte uniquement un état de présentation de double coupure pour montrer les contours rouges/verts. Il ne s’agit pas de reproduire une sauvegarde du joueur.

Contrôles visuels sur les vues finales : illustrations françaises/prussiennes et forces lisibles, hexagones distincts, deux noms Sauer, ponts visibles, localités, trois étoiles, bois/village/cultures, contours tactiques et zooms. Les chevauchements existants entre pions et noms dans les zones denses sont conservés : aucune réorganisation ou déplacement d’unité pour améliorer artificiellement la capture. À l’échelle minimale, les petites annotations sont naturellement réduites comme auparavant.

Deux rendus complémentaires de l’essai aux zooms 0,42 et 2,3 : captures valides, aucun message d’erreur moteur. Les tests canon et fusil vérifient leurs couleurs, trajectoires/phases et visibilité sur les terrains et zooms du banc existant : **53/53** et **54/54**. Le code des animations n’a pas changé.

Avertissement du pilote logiciel : V-Sync non prise en charge, commun aux versions. Une première tentative de vue très éloignée du témoin stable au zoom 0,72 a donné une image grise et des messages GLES3 `Parameter "pb" is null` ; elle n’est pas utilisée dans les comparaisons. Reprise avec cadrage commun 0,82 : aucune erreur GLES3 dans les captures finales. Ce constat du banc Linux ne démontre pas un défaut sur Android. L’essai seul a également été rendu à 0,42 sans cette erreur.

## Mesure de coût graphique

Même situation « engagement », 1280 × 720, zoom 1,05 ; 15 images de chauffe, puis 60 images avec redessin forcé. Exécutions finales successives, aucun test de régression lancé simultanément. Mesure globale CPU + rendu + attente de fin d’image, **pas un profil GPU Android**. Une passe par version ; bruit de charge de la machine possible.

| Mesure | Base V43.15 | Essai 2D |
| --- | ---: | ---: |
| Médiane | 80.390 ms | 79.862 ms |
| P95 | 138.508 ms | 100.213 ms |
| Appels de dessin | 3385 | 3462 |
| Mémoire vidéo rapportée | 33,570,083 octets | 40,179,915 octets |

Les médianes sont proches dans cette passe ; ne pas en déduire une amélioration de vitesse garantie. Surcoût mémoire rapporté : **6 609 832 octets (~6,30 Mio)**. L’atlas PNG compressé sur disque occupe ~320 Kio ; image 1320 × 965 et mipmaps partagés. Les terrains sont dessinés avec culling écran, un seul atlas, sans éclairage, shader, bruit en temps réel ni particules supplémentaires. Les dessins militaires et calculs d’IA restent inchangés.

## APK

Export Android réussi et signature APK v2/v3 vérifiée par `apksigner`; intégrité ZIP vérifiée ; l’atlas est bien présent et tests/outils de développement exclus du paquet. Android minimum API 24, cible 35, ARMv7/ARM64/x86_64. Paquet `org.woerth1870.prototype.graphics2dexp`, version `0.8.43.15-g2d1`, code 1.

APK : `1870_V43_Graphismes_2D_Experimental_01.apk`, **88 751 120 octets**.

SHA-256 : `676284ee7367715414023b616dc96fb14a242efcb7b51b494df2c0124eefaab4`.

Le processus d’export termine avec succès. Après sa vérification, le sondage adb de l’environnement signale l’impossibilité de créer `/home/agent/.android` en lecture seule ; cela empêche la détection d’appareil par ce sondage, sans invalider le paquet signé. Aucun appareil ni émulateur Android utilisé. L’APK stable V43.15 conserve son SHA-256 `354cd260e566fd20ac9699711740ebdbbce773a53be9124f62f0bccbe544224b`.

## Non réalisés et limites

- Installation, partage de sauvegarde et confort tactile sur appareil Android physique : **non réalisés**.
- FPS, chauffe et consommation sur smartphone : **non mesurés**.
- Nouvelle simulation chronologique complète : **non réalisée**, IA et règles inchangées en octets.
- Import automatique de la partie stable vers l’application d’essai : **absent** ; format compatible mais espaces Android distincts.
- Validation esthétique par le joueur et fusion dans main : **en attente** ; aucune intégration à la version stable.

## Reproduire

Ouvrir les sources avec Godot 4.5.1 et attendre l’import. Puis, dans des dossiers de sauvegarde de test distincts :

```sh
godot --headless --path . --script res://tests/graphics/test_contract.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/vers/sources_V43.15
godot --headless --path . --script res://tests/graphics/controls_snapshot.gd -- /tmp/controles.json
```

Pour les captures, serveur d’affichage requis : utiliser exactement `tests/graphics/capture_comparison.gd` sur le projet stable et le projet d’essai avec deux dossiers de sortie et de sauvegarde distincts. Le script est livré dans l’essai ; son chemin absolu peut être passé au Godot du témoin. Chaque dossier de sortie contient `metrics.json` et cinq PNG. Comparer les empreintes et les captures. Les sources SVG se reconstruisent selon `development/graphics2d/CREDITS.md`.
