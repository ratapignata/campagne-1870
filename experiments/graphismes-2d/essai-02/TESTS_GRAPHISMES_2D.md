# Tests — essai graphique 2D № 2

Exécutés le 30 octobre 2026, Godot **4.5.1 stable officiel**. Tous les dossiers de sauvegarde de test sont isolés. Aucune sauvegarde personnelle du joueur n’a été ouverte ou modifiée.

## Résultats finaux

**5 036 assertions réussies : 2 487 dans les 23 suites existantes, 2 435 dans le contrat graphique, 53 pour le rendu canon, 54 pour le rendu fusil et 7 pour la reprise d’une sauvegarde de l’essai 1.** Aucun échec ni message d’erreur dans les exécutions finales. Les comparaisons d’images/commandes ci-dessous sont supplémentaires, sans gonfler ce total.

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

Sorties exactes : `captures/graphismes2d2/preuves/regression.json`.

## Contrat graphique, input et sauvegarde

`tests/graphics/test_contract.gd` : **2 435/2 435**. Carte 30 × 20 et 95 unités totales de la base, deux planches 1536 × 1024, douze régions d’illustration et douze matériaux bornés, vraie transparence. Sélection de chacun des 600 centres d’hexagone aux quatre zooms 0,42 / 0,72 / 1,05 / 2,3 : 2 400 vérifications. Toucher, glissement, pincement et ancrage de zoom injectés dans Godot, sans modification de l’état moteur. Sauvegarde/relecture complète avec stockage expérimental séparé.

`tests/graphics/test_previous_save.gd` : **7/7**. Fixture synthétique produite par l’essai 1, relue par l’essai 2 ; contenu courant/retour arrière sérialisé conservé, copie de sauvegarde vérifiée et original inchangé. Une première assertion de stricte égalité des conteneurs en mémoire donnait 6/7 : la normalisation existante convertit des clés/types numériques internes, tandis que le JSON réexporté était déjà identique. Le test final compare toutes les valeurs sérialisées avant et après écriture, sans modifier le moteur ni sa normalisation. Cette correction du test ne masque aucune perte de champ : la comparaison du payload complet et l’empreinte de l’original sont exigées.

## Intégrité de la base

`check_source_integrity.py` : **PASS**, référence stable `34d8f73`. 1 333 fichiers identiques ; cinq fichiers existants limités à la présentation et à l’identité de l’application d’essai. IA, core, platform, scènes, géographie et packs de scénarios identiques. Dix fonctions de présentation modifiées sur 128, 118 inchangées. Hash du scénario `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

Les tests existants couvrent notamment Raoult/renforts adjacents, variante B, cavalerie, reddition/journal, lignes de vue et information cachée, liens, sauvegardes/export et dispatch de l’IA française Difficile. Aucune nouvelle campagne T1–T20 n’a été lancée pour cet essai purement graphique.

## Interface et comparaisons réelles

Six snapshots de commandes comparés à la version stable : infanterie, cavalerie, artillerie, QG, double coupure, chemin prévisualisé. **6/6 identiques** pour textes, état visible/désactivé, rectangles, callbacks, filtres de souris, contenu de la fiche et dimensions des bandeaux. Les nouvelles couches de peau ne consomment pas les entrées. Aucun nouveau bouton TIRER.

Cinq paires de PNG 1280 × 720, essai 1 / essai 2 : **5/5 mêmes états sérialisés, focus, zoom, sélection et rectangle de fiche**. **76/76 bandes de force visibles identiques pixel par pixel**, comprenant les mêmes chiffres et marqueurs nationaux dans les régions comparées. Le fond de fiche change volontairement ; il n’est plus déclaré identique en pixels, contrairement au premier essai.

Les images sont issues du viewport Godot sous X11/OpenGL Compatibility, Mesa llvmpipe (LLVM 19.1.7). Fixture commune `tests/fixtures/v4313_t11_simulation.json`. Le cas Prussiens fait avancer la phase de test pour sélectionner ce camp ; le cas isolement injecte un état de double coupure uniquement pour montrer les contours. Pas de capture Android, pas de nouvelle partie du joueur, pas de simulation chronologique de onze tours.

Inspection des vues générale, combat français, prussien, QG et détail : soldats/chevaux/canons distincts, force conservée, relief visuel, cultures/bois/villages différenciés, grille visible, deux noms Sauer et ponts, noms sérif, étoiles et contours tactiques. Les chevauchements anciens de noms et pions en zone dense sont signalés dans le rapport. Deux vues complémentaires aux zooms 0,42 et 2,3 sont également rendues sans erreur.

## Animations

Tests existants rendus dans le vrai viewport logiciel : canon **53/53**, fusil **54/54**. Couleur sombre des projectiles, phases, images distinctes et visibilité sur les terrains/zooms du banc conservées. Les routines de projectile, trajectoire, impact et durée sont inchangées. Les nouveaux dessins des batteries ne changent pas les règles ou les événements de combat.

## Coût de rendu

Vue « engagement », 1280 × 720, zoom 1,05. Deux exécutions successives, sans suite concurrente ; 15 images de chauffe puis 60 redessins forcés par version. Une passe par version, moteur logiciel : mesure globale CPU/rendu/attente, pas un profil GPU Android.

| Mesure | Essai 1 | Essai 2 |
| --- | ---: | ---: |
| Médiane | 73.038 ms | 68.565 ms |
| P95 | 81.375 ms | 84.152 ms |
| Appels de dessin | 3462 | 2844 |
| Mémoire vidéo rapportée | 40179915 octets | 41665170 octets |

Le nombre d’appels baisse avec les illustrations en atlas. Les temps restent proches sur cette machine ; le P95 varie et aucune amélioration universelle de FPS n’est garantie. Le moniteur vidéo augmente de 1 485 255 octets (~1,42 Mio) sur cette vue ; ce n’est pas une mesure du pic global de RAM. Deux textures principales partagées, mipmaps, variantes fixes et petites peaux SVG ; aucun éclairage 3D ou effet de combat supplémentaire.

## APK

Export Android réussi, intégrité ZIP contrôlée, nouvelles planches présentes dans le paquet. Tests, captures et outils de développement exclus. Signature APK v2/v3 vérifiée ; même certificat que l’essai 1. Paquet `org.woerth1870.prototype.graphics2dexp`, version `0.8.43.15-g2d2`, code 2, API minimum 24/cible 35, ARMv7/ARM64/x86_64.

Fichier : `1870_V43_Graphismes_2D_Experimental_02.apk`, **95164173 octets**. SHA-256 : `826c8908e5298fbc7572f4069a8dea767d83a77885e933eaa715ddd22d144f3d`.


L’APK stable conserve le SHA-256 `354cd260e566fd20ac9699711740ebdbbce773a53be9124f62f0bccbe544224b`. La nouvelle identité expérimentale, distincte de la stable, reste la même que dans l’essai 1 pour permettre sa mise à jour sans effacer sa sauvegarde.

Avertissements de banc : V-Sync non prise en charge par le pilote logiciel, commune aux versions. Après l’export réussi/vérifié, le sondage adb de l’environnement signale `/home/agent/.android` en lecture seule ; aucun appareil n’est connecté ni testé. Aucun message d’erreur GLES3 dans les captures finales de cet essai.

## Non réalisés

Installation et utilisation sur téléphone/émulateur Android : **non réalisées**. FPS, chauffe, batterie et lisibilité sur l’appareil du joueur : **non mesurés**. Aucun transfert automatique entre les espaces privés de la stable et de l’essai. Nouvelle campagne complète T1–T20 : **non réalisée**. Validation esthétique et fusion dans main : **en attente de l’avis du joueur**.

## Reproduire

Godot 4.5.1, depuis la racine des sources, avec des dossiers utilisateur de test distincts :

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/graphics/test_contract.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/vers/sources_V43.15
godot --headless --path . --script res://tests/graphics/controls_snapshot.gd -- /tmp/controles.json
```

Pour les captures, utiliser un serveur d’affichage et exactement le même `capture_comparison.gd` sur les sources essai 1 et essai 2, avec deux dossiers de sortie. Les PNG, métriques, empreintes et journaux réels sont livrés dans `captures/graphismes2d2`.
