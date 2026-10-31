# Tests exécutés — essai 10

Godot 4.5.1 officiel `f62fdbde1`, 31 octobre 2026. **7 494 assertions finales réussies** ; contrôles communs headless/rendu non comptés deux fois. Les 23 suites existantes ont été relancées et passent. Aucun test final échoué ou désactivé.

| Suite | Résultat final |
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
| `v43/test_ui` | 31/31 |
| `v43_export/test_export` | 28/28 |
| `v43_export/test_android_eof` | 9/9 |
| `v43/test_cavalry_village125` | 20/20 |
| `v43/test_rifle_label` | 18/18 |
| `v43/test_v439_presentation` | 102/102 |
| `v43/test_surrender_journal` | 11/11 |
| `v43/test_variant_b` | 1701/1701 |
| `v43/test_raoult` | 42/42 |
| `v43/test_v4315_ui` | 8/8 |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_hud06` | 84/84 |
| `graphics/test_guidance07` | 137/137 |
| `graphics/test_header09` | 795/795 |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_journal10` | 990/990 |
| `graphics/test_check10_ui` | 9/9 |
| `graphics/test_experiment03_render` | 35/35 |
| `v43/test_animation_render` | 53/53 |
| `v43/test_rifle_animation_render` | 54/54 |

## Disponibilité réelle

353 contrôles : infanterie 0,5 PA sans route / avec route ; cavalerie 0,5 en plaine et 0,25 sur route ; formation seule ; transit à travers un ami ; tir seul ; charge seule à 2 PA ; charge interdite en double coupure ; ralliement seul ; retranchement seul ; mise en batterie seule ; batterie à 0,5 PA ; défense réactive toujours légale ; arrêt de gué avec autre action ; phase adverse ; unité explicitement arrêtée ; réouverture d’un passage par un déplacement allié réel ; sauvegarde et reprise d’un budget fractionnaire.

224 de ces contrôles comparent la recherche de mouvement arrêtée au premier endpoint libre avec le `reach` complet inchangé du moteur : quatre types d’unité, sept budgets, huit configurations déterministes de terrains/amis/arrêt de rivière/batterie. Les actions de référence (déplacement, tir, déploiement, retranchement) sont également exécutées dans les états de test. L’état courant et le retour arrière du moteur restent identiques après classification ; aucun ennemi classifié. Des jumeaux avec la même visibilité autorisée et un occupant ennemi inconnu différent donnent les mêmes indicateurs.

UI : compteur égal aux unités ayant une action, Unité suivante saute les coches, unité cochée encore consultable, 0,5 PA conservé, coche effacée si une action redevient possible. Captures réelles : fantassin coché à 0,5 PA, cavalier non coché pouvant avancer, canon coché à 0,5 PA. États synthétiques de trois unités, carte historique conservée ; pas une partie chronologique du joueur.

## Journal et tactile

990 contrôles avec rendu : cinq catégories alimentées par les historiques existants ; pertes/identités/arrivées ennemies inconnues non divulguées ; dates d’arrivée non inventées ; distinction début/fin de tour ; sauvegarde/reprise reconstruisant les mêmes entrées. Tests aux tailles 1280 × 606, 1280 × 720, 1520 × 720. Toucher réel simulé des cinq filtres, absence de chevauchement et de dépassement, lignes repliées dans la fenêtre, défilement par glissement tactile sans ordre de jeu, chargement de lignes anciennes et remise à zéro au changement de filtre. Les filtres ne modifient ni l’état moteur ni le fichier de sauvegarde.

Les capitulations visibles/propres restent nommées, les inconnues cachées et les doublons supprimés ; l’ancien test de reddition est conservé. L’ancien test Raoult confirme que l’entrée reportée, ses coordonnées et son explication restent visibles dans le nouveau journal. Les objectifs actifs et leurs poids restent présents dans son résumé.

Les captures du journal utilisent la fixture synthétique au tour 11 et une reddition de test ajoutée pour vérifier la catégorie. Elles ne décrivent pas une partie réelle nouvelle de l’utilisateur. Une capture de l’ancien journal, dans le même état, est fournie. Aucun photomontage ni maquette générée utilisé comme preuve de fonctionnement.

## Régression et intégrité

Scénario 30 × 20 / 95 unités, quatre PA de base, coûts/portées, charge 2 PA, combats, variante B, ripostes, isolement, liaisons, QG Raoult, renforts, export/sauvegardes, objectifs/score et doctrines IA : suites existantes relancées. Animations canon et balles d’infanterie réellement rendues et contrôlées. Aucune nouvelle simulation complète de bataille ou test physique Android revendiqué.

1 333 fichiers de la stable identiques ; core, IA, plateforme, scènes, données géographiques/règles et ressources historiques inchangés. 108/128 fonctions identiques dans les deux scripts de présentation existants, exceptions UI explicitement vérifiées. Le moteur `actionable/available_count/can_act` n’est pas modifié, donc la nouvelle coche n’influence pas les décisions de l’IA. Pack SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`.

## Performances et mises au point

Classification seule sur CPU cloud, fixture T11 avec 423 combats enregistrés : 30 mesures après cinq chauffes, médiane 10,235 ms, P95 12,285 ms ; état moteur inchangé. Ce n’est pas un benchmark Android. Pas de calcul de disponibilité par image : le déplacement/zoom de carte réutilise les marqueurs calculés. Journal : 40 lignes créées initialement, suite chargée au défilement ; 423 combats testés.

L’essai initial calculait trop de destinations inutiles : la recherche s’arrête maintenant au premier endpoint libre, sans changer les coûts/conditions du moteur ; comparaison de 224 configurations. Les premiers tests ont aussi signalé des liens de route synthétiques non recopiés dans l’instantané et l’explication de Raoult repoussée sous les anciennes entrées ; ces deux cas ont été corrigés puis les suites relancées. Un nom de classe UI en conflit avec Godot a été renommé. Aucun de ces essais initiaux échoués n’est présenté comme un succès.

## APK et archive

Version `0.8.43.15-g2d10`, code Android 10, paquet expérimental séparé, certificat identique, signature v2/v3 et ZIP vérifiés. SDK minimum 24/cible 35, ARMv7/ARM64/x86_64. APK stable V43.15 inchangé. Tests/captures/outils de développement exclus de l’APK. La sonde ADB de l’éditeur conserve son avertissement de répertoire personnel en lecture seule après export ; compilation et signature réussies. Installation, confort et fluidité sur appareil restent non testés ici.

Archive extraite/importée séparément : sauvegardes 63/63, disponibilité 353/353, journal headless 985/985 et intégrité vs dossier stable réussis. Ces répétitions ne sont pas ajoutées aux 7 494 assertions.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/graphics/test_availability10.gd
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_journal10.gd -- /tmp/captures
godot --path . --rendering-method gl_compatibility --script res://tests/graphics/test_check10_ui.gd -- /tmp/captures
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
godot --headless --path . --script res://tests/graphics/measure_availability10.gd -- /tmp/availability.json
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Créer le dossier de captures et utiliser un répertoire utilisateur isolé. Les JSON détaillés de la campagne courante sont dans la galerie/preuves.
