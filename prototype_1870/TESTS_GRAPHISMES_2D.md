# Tests exécutés — essai 12

31 octobre 2026, Godot 4.5.1 officiel `f62fdbde1`. **5 006 assertions distinctes réussies**, campagne ciblée. Les résultats des essais précédents ne sont pas présentés comme des exécutions nouvelles.

## Suites headless relancées

| Suite | Résultat |
| --- | --- |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_header09` | 795/795 |
| `graphics/test_hud06` | 84/84 |
| `graphics/test_guidance07` | 137/137 |
| `graphics/test_feedback12` | 20/20 |
| `v43/test_v4315` | 28/28 |
| `v43/test_raoult` | 42/42 |
| `v43/test_surrender_journal` | 11/11 |

Total headless : 3 966. Toutes ces suites passent ; aucune désactivée.

## Exécutions avec rendu réel

- Journal et tactile : 990/990, aux tailles 1280 × 606, 1280 × 720, 1520 × 720. Filtres, chargement progressif, textes repliés, défilement tactile, absence de chevauchement et respect des informations cachées.
- Coche et autres marqueurs : 12/12, captures du fantassin à 0,5 PA coché, cavalier encore mobile non coché, canon coché avec riposte prête, puis désorganisation/retranchement/double coupure aux zooms 0,6 / 1 / 2,3.
- Surbrillance : 23/23, dont 20 communs au test headless, donc seulement trois assertions supplémentaires comptées. Capture avant/pendant/après ; déplacement légal réel pour vérifier la dépense de PA ; changements d’effectifs/moral synthétiques ; fin de l’effet, absence de redéclenchement au simple rafraîchissement ou changement d’unité ; aucune alerte sur des informations ennemies inconnues ; état et retour arrière inchangés par l’effet ; reprise/chargement sans effet résiduel.
- Décors et brouillard : 35/35 ; uniformité des matériaux au même emplacement (delta pixel 0 pour les trois terrains de référence), seuil des silhouettes et absence de fuite d’effectifs ennemis par le rendu.

Total distinct : 3 966 + 990 + 12 + 3 + 35 = **5 006**. Les captures sont des images réellement produites par Godot, sans retouche ni maquette générée.

## Comparaison et contrôles visuels

Six situations avant/après construites à partir de la même fixture synthétique T11 : vue générale, engagement, Prussiens, isolement, détail, déplacement. Le cas déplacement démarre d’une nouvelle partie avec graine fixe. Ce ne sont pas de nouvelles parties chronologiques du joueur. Les autres captures montrent un état synthétique de trois unités et la fiche d’un fantassin modifiée pour tester les effets.

Contrôles : force et marqueurs lisibles, positions fixes des états, pions historiques préservés, carte adoucie au dézoom et détaillée de près, objectifs/terrain/routes/ponts/localités conservés, points de déplacement visibles, bandeaux de mêmes dimensions, fiche inchangée hors surbrillance. Journal : fins liserés et icônes colorés, textes/catégories conservés.

## Intégrité et sauvegardes

Code core/IA/plateforme/scènes et toutes les données de bataille identiques à l’essai 11. Logique de disponibilité, modèle de journal, fonctions de combat et animations inchangés. Contrôle automatisé avec la stable V43.15 réussi : 1 333 fichiers originaux identiques ; seuls deux helpers de dessin supplémentaires (`disorder_badge`, `shovel`) sont ajoutés explicitement aux exceptions de présentation. Les contrôles de règles et de moteur ne sont pas assouplis.

Pack de scénario SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Sauvegardes réelles des essais 1 à 9 chargées et réécrites en copie, originaux inchangés : 63/63. Aucun changement de format par rapport aux essais 10 et 11. Pas de nouveau test chronologique complet de bataille.

## Performances observées et limites

Le petit atlas adouci est créé une fois au démarrage, puis réutilisé ; aucun filtrage d’image par frame. Le traitement de surbrillance ne tourne que pendant ses 0,85 seconde. Aucune interrogation du moteur par frame pour cet effet. Pas de changement de calcul de disponibilité/IA.

Mesure de 60 images sous rendu logiciel llvmpipe, scène engagement zoom 1,05 : médiane avant 64,610 ms, après 70,826 ms ; appels de dessin 2 716 puis 2 704 ; mémoire vidéo mesurée 35 811 069 puis 35 650 187 octets. Deux relevés uniques sur CPU cloud, sans maîtrise de la charge de la machine : l’écart temporel ne permet pas de conclure à un gain ni de l’attribuer avec certitude au code. Aucun gain de fluidité Android revendiqué ; confort et performances sur appareil à vérifier. Les mesures détaillées sont jointes.

Une première simplification géométrique des arbres a été écartée après inspection visuelle : le rendu livré conserve les illustrations historiques adoucies. Le premier test de déplacement utilisait le dictionnaire englobant de `reach` au lieu de ses destinations `costs` ; le banc a été corrigé pour exécuter et vérifier un vrai déplacement, puis relancé avec succès. Ces essais initiaux ne sont pas comptés comme réussis.

## APK et archive

APK `0.8.43.15-g2d12`, code 12, paquet expérimental identique, certificat de développement conservé ; signatures v2/v3, métadonnées et contenu ZIP vérifiés. SDK minimum 24/cible 35, ARMv7/ARM64/x86_64. Tests/captures/développement exclus de l’APK. La sonde ADB conserve son avertissement de répertoire personnel en lecture seule après export ; compilation et signature réussies. Aucun test Android physique ou émulateur.

Archive extraite et importée dans un dossier indépendant : surbrillance 20/20, anciennes sauvegardes 63/63, disponibilité 353/353 et intégrité avec le dossier stable réussis. Ces répétitions ne sont pas ajoutées au total. Le ZIP final ne diffère de cette vérification que par les rapports et preuves ajoutés.

## Reproduire

```sh
godot --headless --path . --script res://tests/graphics/test_feedback12.gd
godot --headless --path . --script res://tests/graphics/test_availability10.gd
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/graphics/test_journal10.gd -- /tmp/captures
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/graphics/test_feedback12.gd -- /tmp/captures
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/graphics/capture_comparison.gd -- /tmp/comparaison
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Créer les dossiers de captures et isoler le répertoire utilisateur des tests. Résultats détaillés dans la galerie/preuves.
