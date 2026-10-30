# Tests — essai graphique 2D № 3

30 octobre 2026, Godot **4.5.1 stable officiel**, sauvegardes de test isolées. Aucune sauvegarde personnelle du joueur n’a été ouverte.

## Bilan final

**5 078 assertions réussies** : 2 487 dans les 23 suites existantes, 2 435 pour le contrat graphique/tactile, 14 pour les sauvegardes des essais 1/2, 53 pour le rendu canon, 54 pour le rendu fusil et 35 dans le nouveau banc de rendu. Aucun échec dans les exécutions finales. Les comparaisons supplémentaires ci-dessous ne sont pas ajoutées artificiellement au total.

| Suite existante réexécutée | Résultat |
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

Les sorties exactes sont dans `captures/graphismes2d3/preuves/regression.json`.

## Nouveaux contrôles visuels — 35/35

`test_experiment03_render.gd`, vrai viewport X11/OpenGL, et `uniform_board.gd` :

- Seuils 1 / 1 999 / 2 000 / 2 900 ; même règle pour les deux camps.
- Rapports ennemis exacts et estimés : intervalle 1 500–2 000 ou 1 500–2 500 neutre, borne basse 2 000 double ; cavalerie/artillerie/QG non concernés.
- Trois copies rendues de plaine, cultures et forêt à des indices différents, altitude nulle : même matériau, même orientation, forêt identique même lorsqu’une route est signalée au décor. Les tracés routiers sont testés par la carte réelle et dessinés séparément.
- Chaque marqueur possède un centre ivoire opaque et un contour sombre sur les trois terrains.
- Deux images réellement différentes à 1 999/2 000 pour chaque camp, via le renderer de production, avec bandes de force identiques. Banc isolé : unités restantes mises en attente, hauteurs neutralisées ; ce n’est pas une situation de bataille.
- Deux mondes avec le même contact autorisé : effectif réel ennemi 1 999 / 2 000 / 2 500, même image. Déplacement réel masqué avec contact mémorisé fixe : même image et mêmes étiquettes. Les choix graphiques ne révèlent pas la vérité cachée.
- Une étiquette évite une position préférée occupée lorsque de la place existe ; Spachbach garde son côté de rivière.

Première comparaison de textures trop stricte : 33/35, car le rendu GPU de deux copies avait quelques composantes décalées de **1 sur 255** selon la position écran (maximum 34 pixels sur 3 696, mêmes UV/matériaux). Diagnostic effectué sur les pixels. Le test final accepte au maximum un pas de quantification par composante, pas de changement de motif : plaine écart 0, cultures/forêt écart maximal 1. Aucune règle de jeu ni donnée de terrain modifiée pour satisfaire le test.

## Contrat, commandes, sauvegardes et intégrité

`test_contract.gd` : **2 435/2 435**, dont 2 400 sélections des 600 centres d’hexagone aux zooms 0,42 / 0,72 / 1,05 / 2,3 ; toucher/glissement/pincement/ancrage, atlas bornés/transparence, état moteur intact et sauvegarde/relecture.

`test_previous_save.gd` : **14/14** sur les fixtures synthétiques réellement écrites par les essais 1 et 2. Payload courant/retour arrière relu et réécrit à l’identique en JSON, empreintes des originaux conservées. Le format, l’empreinte du pack et `SaveStore` ne changent pas.

`controls_snapshot.gd` : **six états identiques à la stable** pour textes, rectangles, visibilité, désactivation, callbacks, filtres de souris, contenu de fiche et dimensions de bandeaux. Aucun bouton ajouté, renommé ou déplacé.

`check_source_integrity.py` : **PASS**, référence V43.15 `34d8f73`. 1 333 fichiers identiques, cinq fichiers existants limités à présentation/configuration expérimentale. IA, core, plateforme, scènes, packs et géographie identiques. 118 fonctions sur 128 identiques dans les deux scripts de présentation existants. Hash du scénario `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

## Comparaisons réelles

Six paires essai 2/essai 3, 1280 × 720, même état sérialisé, caméra, zoom et sélection. **6/6 états et dispositions identiques ; 90/90 bandes de force identiques pixel par pixel.** Les fonds et illustrations changent volontairement. La scène déplacement est une nouvelle partie française T1 avec graine fixée et 78e RI de 2 000 hommes sélectionné à 4 PA. Les cinq autres utilisent la fixture T11 existante ; ce n’est pas une simulation chronologique T1–T11 ni une sauvegarde du joueur.

Galerie : `captures/graphismes2d3/README.md`. Les figures de seuil et terrains isolés sont rangés séparément dans `banc`. Zooms extrêmes 0,42 et 2,3 rendus sans erreur. Les routines d’animations, phases/couleurs des projectiles et visibilité du banc existant passent : canon **53/53**, fusil **54/54**.

## Coût graphique

Vue engagement, 1280 × 720, zoom 1,05 ; exécutions successives sans tests concurrents, 15 images de chauffe puis 60 redessins forcés. Linux/Mesa llvmpipe : mesure CPU/rendu/attente, pas un profil Android. Après une première mesure plus lente du placement des noms, un cache de géométrie publique a été ajouté et les captures/tests ont été réexécutés.

| Mesure finale | Essai 2 | Essai 3 |
| --- | ---: | ---: |
| Médiane | 66.989 ms | 67.517 ms |
| P95 | 74.357 ms | 78.352 ms |
| Appels de dessin | 2844 | 2852 |
| Mémoire vidéo rapportée | 42189458 octets | 42197234 octets |

Une passe par version, bruit de charge possible ; temps comparables sans garantie de FPS sur téléphone. Cache d’étiquettes limité à la vue courante et fondé uniquement sur positions connues, viewport/caméra et partie. Deux textures partagées réutilisées, aucun éclairage 3D, shader ou nouvelle particule.

## APK et limites

Export Android réussi, intégrité ZIP et signature v2/v3 vérifiées. Paquet `org.woerth1870.prototype.graphics2dexp`, version `0.8.43.15-g2d3`, code 3, même certificat ; API 24/35, ARMv7/ARM64/x86_64. Tests/captures/outils exclus de l’APK.

Fichier `1870_V43_Graphismes_2D_Experimental_03.apk`, 95168269 octets ; SHA-256 `645212a3afcb96ab630974b9b98529eb0858fbd5b5e5e2400028649e21cc11dd`.


Avertissements du banc : V-Sync non disponible sur le pilote logiciel ; après export réussi, sondage adb incapable de créer `/home/agent/.android` en lecture seule. Cela n’invalide pas le paquet signé. Aucun appareil connecté ou testé.

**Non réalisés** : installation et jeu sur téléphone/émulateur, FPS/chauffe/batterie réels, nouvelle bataille complète T1–T20. Les règles et l’IA étant identiques, aucune nouvelle simulation chronologique n’est présentée. Les noms peuvent encore se recouvrir dans une zone sans place libre proche. Validation visuelle utilisateur et intégration à main : en attente.

## Reproduire

Godot 4.5.1 depuis la racine, avec des dossiers de sauvegarde de test distincts :

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/graphics/test_contract.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
# Avec serveur graphique :
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_experiment03_render.gd
```

Le même `capture_comparison.gd` peut être lancé sur les projets essai 2/3 avec deux dossiers de sortie distincts ; il produit six PNG, métriques et empreintes. Les scripts, fixtures, PNG et journaux sont livrés.
