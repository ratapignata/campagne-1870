# Tests réellement exécutés — V36

Moteur principal : **Godot 4.5.1 stable officiel f62fdbde1**. Les tests s'exécutent sous Linux cloud, en mode headless, avec données utilisateur isolées. Aucun essai physique Android ni émulateur. Les sources V35 restent dans une extraction séparée, sans modification de leurs 510 fichiers originaux.

## Référence et ordre de travail

La copie V36 a été créée avant toute correction. Référence V35 : isolement 9/9, liaisons strictes 21/21, UI régimentaire 27/27, compatibilité IA 18/18, release 119/119, armes 33/33, routes/combat 35/35, échanges/assauts 45/45. Le premier lancement UI sans import a échoué sur les ressources non importées ; après import Godot 4.5.1, il a été relancé et a réussi. Ce problème de préparation n'est pas présenté comme un test réussi au premier essai.

Chaque lot a été analysé et testé séparément, puis enregistré dans un commit local. Une dernière revue du lot 1 a ajouté la protection de la sauvegarde de secours contre un principal valide au checksum mais invalide sémantiquement, avec trois assertions et une nouvelle vérification des sauvegardes/UI.

## Dernière exécution de chaque banc de non-régression

**26 bancs réussis, 2 186 assertions réussies, zéro assertion échouée dans cette sélection finale.** Ce total compte des assertions, pas 2 186 scénarios distincts. Les résultats et journaux sont dans `tests/results/0836/non_regression.json` et les fichiers `.log` correspondants. Les contrôles complémentaires de sauvegarde et retraite remplacent les comptes antérieurs de 40 et 41 par 43 et 45.

| Banc | Résultat | Couverture principale |
|---|---:|---|
| `v36/test_saves` | 43/43 | Types, bornes, champs absents, sauvegardes invalides, secours, double coupure/reconnexion |
| `v36/test_los` | 40/40 | Relief, couvert, deux tracés, artillerie au-dessus des amis, brouillard |
| `v36/test_isolation` | 45/45 | Deux réseaux, compteurs, budgets, retraite, reddition, gués, terrains interdits, sauvegardes |
| `v36/test_contract` | 110/110 | Carte 30×20, 81 unités, 50 renforts initiaux, règles figées, 18 tours complets sans actions, sauvegarde V35 réelle |
| `v36/test_ui` | 11/11 | Toucher, second toucher pour tirer, absence de TIRER, glissement/pincement, horloge, flèche Reichshoffen |
| `v36/test_hidden_worlds` | 18/18 | Deux camps et trois difficultés : observations/décisions indépendantes des ennemis cachés |
| `test_strict0833` | 22/22 | Liaisons, budgets, charge interdite, retraite, sauvegarde |
| `test_isolation0835` | 9/9 | Progression d'isolement et remise à zéro, attente V36 adaptée |
| `test_release0830` | 119/119 | Contrôles moteurs des scénarios actuels |
| `test_artillery0823` | 1188/1188 | Portées, géométrie, couverture et comportements d'artillerie |
| `test_revision0830` | 18/18 | Régressions relief et scénario |
| `test_weapons` | 33/33 | Armes, PA et combat |
| `test_combat_routes` | 35/35 | Déplacement, tir, trajectoires, retraite |
| `test_exchange_assault` | 45/45 | Tir, riposte, assaut et accounting |
| `test_formations08` | 39/39 | Formations, coût, conservation et API IA déplacée |
| `test_positions_results` | 34/34 | Aménagement, riposte des canons, import ancien |
| `test_multi_objectives` | 28/28 | Objectifs pondérés, score final 60 %, capture, sauvegarde |
| `test_multi_objectives_ui` | 7/7 | Interface des objectifs |
| `test_cavalry085` | 41/41 | Charge actuelle à 2 PA et restrictions existantes |
| `test_exact_intel087` | 35/35 | Compatibilité des rapports exacts avec la fixture historique appropriée |
| `test_support0820` | 29/29 | Compatibilité des anciens QG et liaisons, fixture historique |
| `test_ai_compat0833` | 18/18 | Observation, décisions légales, difficulté et sauvegarde |
| `test_regimental0835_ui` | 27/27 | Deux camps, scénario de 81 unités, artillerie, sauvegarde/reprise, anciens scénarios |
| `test_river0814 --quick` | 108/108 | Gués, pont, coût, arrêt, sauvegarde et légalité, fixture historique |
| `test_morale_ai` | 43/43 | Moral et quatre batailles historiques réduites avec les deux IA |
| `test_fog086` | 41/41 | Brouillard, masquage, découverte, observation et bataille IA, fixture historique |

Le test contractuel parcourt les 36 demi-tours du scénario à 81 unités et vérifie l'arrivée des renforts ; il s'agit d'une bataille **sans actions**, pas d'un test d'équilibrage avec défense active. Les tests de packs historiques conservent leurs anciennes règles ; le contrat V36 vérifie séparément les règles actuelles verrouillées.

## Lot 1 — détails

États V35 et V36 valides, fichier effectivement produit par le code V35 avant correction, compteurs −999/−1, chaîne `invalid`, booléen, fraction, NaN/infini, limite de PA 100 et budgets impossibles, PA invalides, cohésion/moral/prisonniers/réactions invalides. Champs facultatifs `isolation_turns` et `turn_ap_limit` absents : chargement accepté. Sauvegardes physiques de double coupure et de rétablissement des liaisons, PA réduits mémorisés, secours récupéré malgré un checksum principal correct. Sauvegarde invalide refusée avant écriture. Après récupération, sauvegarde automatique validée sans écraser le secours par l'ancien principal invalide.

Le même format schema 1 est conservé. Les trois empreintes des packs courants sont inchangées.

## Lot 2 — avant/après et géométrie

Le même nouveau banc LOS exécuté contre le moteur original V35 obtenait **31/40**, avec neuf assertions échouées ; contre V36 il obtient **40/40**. Le journal avant correction est inclus.

Fixture explicite : tireur [10,2], cible [10,5], case intermédiaire [10,3], tous en plaine.

| Élévation tireur / intermédiaire / cible | V36 |
|---|---|
| 0 / 0 / 0 | Tir et reconnaissance dégagés |
| 0 / 1 / 0 | Bloqués par le relief |
| 0 / 2 / 0 | Bloqués par le relief |
| 2 / 1 / 2 | Dégagés, la case reste sous le rayon |
| 4 / 1 / 0 | Tir depuis une hauteur dégagé |
| 0 / 1 / 4 | Tir vers une hauteur dégagé |

Les vérifications de tir inversé sont incluses. Bois/village intermédiaires bloquants, recherche reproductible d'un rayon de bord d'hexagone et blocage de chacun des deux tracés, ami interposé, canon élevé tirant au-dessus de cet ami, terrain toujours bloquant au-dessus d'une unité, ennemi masqué et absence de fuite dans l'observation IA. Portées 6/8 conservées.

L'ancien test release a d'abord échoué sur la portée Krupp 8 : une hauteur de la vérification précédente restait dans sa fixture. La hauteur a été remise à zéro avant le test de portée ; **119/119** après correction de la fixture, sans modifier la portée du jeu.

## Lot 3 — détails

Unité normale, commandement seul coupé, ravitaillement seul coupé, double coupure aux constats 1/2/3/4, désorganisation, déroute et retraite progressive. Encerclement par ennemis sans issue : reddition au troisième constat et comptabilité valide. Couloir ouvert : unité vivante en déroute, PA offensifs interdits ; interdiction de charge maintenue malgré son coût de 2 PA. Liaison rétablie avant le troisième constat, sauvegarde/reprise pendant l'isolement, unité en déroute encore ravitaillée, cavalerie prussienne derrière les Français retirant vers ses arrières propres. Au plus deux pas, arêtes légales, destination libre. Poche de terrains interdits : pas de téléportation, reddition. Gué : cavalerie bloquée ; infanterie admise mais arrêtée sur l'autre rive.

Deux attentes V35 ont volontairement changé : la perte du commandement seule ne suffit plus à capturer une unité en déroute, et une barrière verticale séparant les liaisons laisse encore une issue vers l'arrière nord. Le test ne confond plus coupure des réseaux et encerclement total.

## Lot 4 — mesures exécutées

Voir `IA_V36.md` pour les graines, fixtures, effectifs, pertes, captures, déroute, inactivité, distribution et score.

| Vérification | Résultat |
|---|---:|
| A/B : deux IA actives, 18 tours chronologiques, 14 unités | 40/40 |
| C : départ synthétique au tour 12, sept tours joués | 18/18 |
| E : départ synthétique au tour 17, deux tours joués | 8/8 |
| Rejeu exact des trois simulations | 660/660 |
| Diagnostic de l'inactivité de `pru_38` au tour 10 | 258/258 |

Aucune commande IA rejetée. Le diagnostic instrumente seulement une copie en mémoire du script de test ; aucune modification du fichier IA de production. Le brouillard est couvert par les 18 comparaisons de mondes cachés et les tests LOS/reconnaissance. Ces résultats ne sont pas une évaluation complète de l'équilibrage à 81 unités.

## Échecs et tests incomplets à distinguer

Les essais intermédiaires suivants ont échoué puis ont été corrigés et relancés : les attentes anciennes de reddition inconditionnelle, la fixture de portée Krupp, les comparaisons JSON exactes de formation/positions/objectifs/QG, l'assertion ancienne de 20 points pour la moitié des objectifs alors que la règle conservée en donne 30, les fixtures modernes utilisées par des tests historiques de brouillard/rapports/QG/rivière. Les journaux de la sélection finale prouvent les résultats après correction.

Le premier script de mesure IA accédait à une clé d'objectifs inexistante. Ce défaut du nouveau banc a été corrigé **avant** les simulations rapportées ; leurs journaux finaux ne contiennent pas d'erreur de script. Le premier test de flèche comparait des tableaux float/int avec égalité stricte ; les coordonnées sont désormais comparées en entier.

**Tests non terminés / non validés :**

- `test_river0814` sans `--quick`, avant adaptation de sa fixture : quatre attentes anciennes échouées, puis timeout 120 s pendant son lot de simulations. Une bataille facile avait terminé (249 décisions, 90 tirs) ; le lot complet des trois difficultés n'est pas déclaré réussi. La vérification finale porte sur les **108 contrôles rapides**. Les batailles actives V36 sont réalisées séparément.
- `test_cavalry_ui085` : cinq assertions anciennes de migration/scénario/UI échouées, puis attente de rendu et timeout. Banc non remis à jour, non déclaré réussi.
- `test_fog_ui086` et `touch_check` : attente d'un rendu/capture absent en mode headless, timeout 120 s. Aucun résultat de capture visuelle revendiqué. Le nouveau banc tactile V36, sans capture, passe les 11 contrôles indiqués plus haut.
- Test physique Android, essai en émulateur, performance tactile/graphique/audio sur téléphone : **non réalisés**.
- Bataille chronologique active complète à 81 unités : **non réalisée**. Le précédent audit de sept tours prussiens contre défense immobile n'est pas présenté comme un résultat V36.

## Ressources UI et démarrage

L'UI régimentaire initiale réussissait ses 27 assertions mais signalait ObjectDB et deux ressources encore utilisées à la fermeture. Deux investigations en mode verbose ne reproduisaient pas le message ; il revenait dans des fermetures rapides sans verbose. Le banc courant attend désormais 100 ms après la libération des nœuds audio et quitte via un appel différé. Deux répétitions puis les vérifications finales passent sans ces avertissements. Aucun changement de cycle de vie en production n'a été imposé.

Lancement réel de `main.tscn` via `--headless --quit-after 90` : démarrage réussi, code de sortie 0, aucun défaut de script ; **la fermeture forcée avec musique active signale encore ObjectDB et deux ressources audio**. L'inspection verbose identifie `AudioStreamPlaybackOggVorbis`, `OggPacketSequencePlayback` et les ressources de `assets/sounds/slow_world.ogg`. Un essai minimal arrêtant et détachant les flux dans `_exit_tree` ne supprimait pas le message ; il a été retiré, et la dernière version stable conservée. Cette limite reste documentée, elle n'est pas assimilée à une correction globale des fuites du jeu. L'import éditeur réussit. Le lanceur Python livré a aussi été exécuté pour import, sauvegardes et UI.

## APK réellement produit

Export `--export-debug Android` réalisé avec Godot 4.5.1 et ses templates officiels vérifiés. SDK Android 35, build-tools 35.0.1, Java 21. Export natif sans Gradle, armv7/arm64/x86_64. Version `0.8.36`, code `49`, package `org.woerth1870.prototype.v02`, cible SDK 35, minimum 24.

`apksigner verify --verbose --print-certs` : réussite, signatures **v2 et v3**. `zipalign -c -P 16 -v 4` : réussite. `aapt dump badging` confirme version et identifiant. Certificat de développement fourni dans les sources V35 conservé, SHA-256 `57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c`.

ADB échoue dans cet environnement lorsqu'il tente de créer `/home/agent/.android`, non accessible en écriture. Cela intervient lors de la recherche de périphériques après l'export, pas lors de la génération/signature de l'APK. **Aucune installation, aucun lancement Android ni essai sur appareil n'est revendiqué.** Les contrôles de l'APK sont statiques.

## Reproduction

```sh
python3 tests/v36/run_suite.py --godot /chemin/Godot_v4.5.1-stable_linux.x86_64
python3 tests/v36/run_suite.py --godot /chemin/Godot_v4.5.1-stable_linux.x86_64 --ai
```

Le lanceur exige 4.5.1, importe les ressources, isole données utilisateur et caches hors des sources, conserve les journaux et renvoie un échec si une assertion, erreur de script ou erreur Godot survient. Le mode `--ai` ajoute les simulations actives (jusqu'à 900 s chacune), le rejeu et le diagnostic. Les tests historiques de capture incompatibles headless sont exclus explicitement de cette sélection.
