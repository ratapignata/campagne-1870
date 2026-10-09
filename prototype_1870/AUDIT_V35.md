# Audit V35 — 1870 : Frœschwiller-Wœrth

## Périmètre et méthode

Sources : archive `1870_v0.8.35_Sources.zip`, projet `prototype_1870`, version déclarée **0.8.35**. Le dépôt GitHub ne contient toujours que son README ; l'audit porte sur l'archive, extraite séparément dans `/workspace/audit-v35`. Aucune correction V36 n'est implémentée.

Référence normative : prompt maître V35 fourni par l'utilisateur. Les notices historiques de l'archive constituent des éléments à examiner, pas des autorisations de restaurer d'anciennes règles.

Exécution initiale : Godot **4.6.3**, Linux, mode headless. Les contrôles critiques ont ensuite été répétés avec **Godot 4.5.1**, version recommandée par le README, téléchargée depuis la publication officielle et vérifiée avec son SHA512 officiel. Les résultats ne prouvent ni le comportement sur appareil Android ni celui de l'APK fourni, dont le transfert était bloqué. Caches et sauvegardes de test sont isolés sous `/workspace/audit-v35/runtime`. Les sondes supplémentaires sont extérieures aux sources. Les installations d'assets génèrent seulement des caches ; les fichiers de l'archive sont contrôlés par comparaison octet par octet.

Les coûts internes sont des **quarts de PA** : 16 = 4 PA, 12 = 3 PA, 8 = 2 PA, 4 = 1 PA. Une lecture littérale de `ap:16` comme 16 PA serait erronée.

`CONFORME` signifie conforme pour le périmètre contrôlé, pas certification de tous les cas possibles. Les contrôles statiques, essais sur terrain synthétique et tests sur scénario réel sont distingués. `NON TESTÉ` est utilisé lorsqu'une exigence ne peut pas être validée ou qu'un système n'existe pas.

## Tableau de conformité

Les chemins ci-dessous sont relatifs à `prototype_1870`. Abréviations : E = `war_engine/core/engine.gd` ; B = `war_engine/core/rules_base.gd` ; S = `war_engine/core/support.gd` ; I = `war_engine/core/intel.gd` ; UI = `war_engine/presentation/main.gd` ; MV = `war_engine/presentation/map_view.gd` ; P = `packs/1870/regimental_trial.json`.

| Système | Règle attendue V35 | Valeur réellement codée | Fichier / fonction | Test effectué | État |
|---|---|---|---|---|---|
| Version | Préserver V35 | 0.8.35 | project.godot, P | Lecture | CONFORME |
| Android paysage | Priorité tactile, paysage | orientation=0 ; viewport 1280×720 | project.godot | Lecture ; UI headless | CONFORME pour configuration ; appareil NON TESTÉ |
| Carte | 30×20 ; 350 m | 600 cases ; neighbor_distance_m=350 | P/map ; B/_init | test_regimental0835_ui | CONFORME |
| Géographie | Villages, routes, Sauer | Labels, arêtes routières et fluviales présentes ; relief conservé mais show_relief=false | P/map ; MV/_draw | Lecture ; test_revision0830 | CONFORME pour données, précision historique NON TESTÉE |
| Reichshoffen | Flèche décalée d'un hexagone à gauche | location.cell passe de [7,2] à [6,2] ; dessin suit cet ancrage, arrow_cell=[5,0] et road_exit inchangés | P/map ; MV/_draw vers ligne 320 | Comparaison legacy0834 et lecture du dessin | CONFORME statiquement ; rendu sur appareil NON TESTÉ |
| Durée | 18 tours de 30 min, 08–17 h | turns=18, minutes=30, start_hour=8 ; horloge UI reste 16:30 après fin du tour 18 | P/rules ; B/end_side ; UI/refresh | Test UI ; sonde final_clock sous Godot 4.5.1 | CONFORME pour durée ; DIFFÉRENCE pour affichage final |
| Objectifs | Frœschwiller, Elsasshausen, Niederwald | 3 objectifs, poids 3/2/1 | P/objectives ; B/capture_objective | Test UI, simulation | CONFORME |
| Échelle des unités | Principalement régiments | 81 pions, dont QG et artillerie | P/units | Lecture ; test UI | CONFORME pour structure |
| Effectifs historiques | Conserver historiques disponibles | Données déclarées adaptation de test, plusieurs effectifs provisoires | P/units simulation_note | Lecture | DIFFÉRENCE / historique NON TESTÉ |
| PA infanterie | 4 | 16 quarts | B/action_budget ; P/rules.ap | Lecture ; scénarios/tests | CONFORME |
| PA cavalerie | 4, pas 5 | unit_types.cavalry.ap=16 | B/action_budget ; P/unit_types | Lecture ; test UI | CONFORME |
| PA artillerie | 4 | 16 quarts | B/action_budget | Lecture ; test UI | CONFORME |
| PA hors commandement | Vérifier V35, ne pas restaurer arbitrairement 3 | Cmd coupé seul : 3 ; double coupure : 2 au prochain tour | E/support_budget/end_side | test_strict0833, 21 contrôles | CONFORME au fonctionnement existant explicitement demandé à préserver |
| Tir | 2 PA | Infanterie/Krupp 2 ; canon français 3 | P/weapons ; E/fire | Sondes V35 ; test_weapons sur fixture ancienne | DIFFÉRENCE |
| Maximum tirs | 1 actif par tour | Pas de verrou ; deux tirs d'infanterie acceptés | E/fire/fire_status | Sonde TWO_ACTIVE_SHOTS : ok, ok | DIFFÉRENCE |
| Formation | 1 PA ; Ligne, Colonne, Tirailleurs | 4 quarts ; line/column/skirmish | P/rules.formations ; E/change_formation | Lecture ; tests IA/UI | CONFORME pour valeurs ; ancien test formation incomplet |
| Mise en batterie / attelage | 1 PA chacun | deployment_ap=4 | B/toggle_deployment ; E/toggle_deployment | test_weapons ; test UI V35 | CONFORME |
| Assaut adjacent | 3 PA | assault.ap=12 | E/assault_cost/status/assault | test_exchange_assault ; lecture | CONFORME |
| Charge | 3 PA, mouvement spécifique inclus | charge_ap=8 ; seulement ennemi adjacent, avance après choc | P/unit_types.cavalry ; E/assault_status/assault | Sonde charge ; lecture | DIFFÉRENCE |
| Charge terrain | Interdire forêt dense, village, pont, gué | Forêt/village/hex pont autorisés, puissance réduite ; rivière ouverte interdite | E/assault_status/attack_power_against | Sondes : ok sur forest/village/bridge | DIFFÉRENCE |
| Mobilité cavalerie | Découvert 0,5 PA, terrain difficile 2 | Plaine/prairie 0,5 ; forêt 2 ; culture/village 1,5 ; route 0,25 | P/unit_types ; E/movement_cost | Lecture ; test_revision0830 | CONFORME pour plaine/forêt ; autres terrains à valider |
| Aménagement | 4 PA | 8 quarts = 2 PA | P/rules.entrenchment ; E/entrench | Sonde : 2 PA | DIFFÉRENCE |
| Repos / ralliement | Activation entière | Repos hold ; ralliement retire 2 PA, done=false si PA restants | E/rest/hold/rally | Sonde RALLY : 2 PA restent | DIFFÉRENCE pour ralliement |
| Tour fluide / activation | Pas de phases rigides ; unité terminée inactive ; ordre terminer activation rapide | Actions libres, done empêche can_act ; hold termine mais aucun bouton humain dédié retrouvé | B/can_act/hold ; E/end_side ; UI/build | Lecture ; tests combat | CONFORME pour moteur ; DIFFÉRENCE pour ordre UI |
| Fin de tour | Confirmation s'il reste des unités disponibles | confirm_end utilise available_count | UI/confirm_end | Lecture | CONFORME statiquement |
| Déplacement | PA, terrain, occupation, trajet, limite avec validation | Recherche de chemin et aperçu ; confirmation de limite atteignable | B/reach/preview ; E/move ; UI/on_cell | test_combat_routes, test_revision0830 | CONFORME pour ces mécanismes |
| ZOC mouvement | Conserver et contrôler système V35 | ZOC dans liaisons ; pas de coût/arrêt/désengagement ZOC dans step_cost/reach/move | S/strict_networks ; B/step_cost/reach ; E/move | Lecture ; sonde déplacement | DIFFÉRENCE : portée de la règle à préciser |
| Annulation | Pas d'information gratuite après découverte/capture/combat | Verrous discovery/capture/fire/assault etc. | E/move ; B/undo | Tests brouillard et routes | CONFORME pour contrôles exécutés |
| Fiche | PA numériques, Cmd et Ravit distincts | ap_text divise par 4 ; labels distincts | UI/ap_text/refresh/layout_cards | test_regimental0835_ui | CONFORME pour tests headless ; smartphone NON TESTÉ |
| Bouton TIRER | Cible puis bouton de confirmation | Aucun bouton TIRER ; second toucher de cible déclenche fire | UI/build/on_cell/commit_fire | Lecture | DIFFÉRENCE |
| Moral | En ordre, ébranlé, déroute | stable/shaken/routed + cohesion 0–100 | E/apply_losses/rally/retreat | Tests combat/isolement | CONFORME pour états |
| Fatigue | Conserver système V35 influençant performances | Aucun champ ni calcul fatigue trouvé | E/shot_loss/assault_power ; unités | Recherche exhaustive des scripts | NON TESTÉ : non implémenté |
| Qualité / expérience | Auditer caractéristiques réellement utilisées | Aucun coefficient propre qualité/expérience | E/shot_loss/assault_power ; P | Lecture | NON TESTÉ : non implémenté |
| Munitions | Tir consomme, ravitaillement nécessaire | 3 salves/niveau ; niveaux 0/1/2 ; 2 réduit à 0,65, jamais à zéro | E/spend_ammo/ammo_factor/end_side | Tests ravitaillement ; lecture | DIFFÉRENCE : modèle simplifié sans épuisement total |
| Feu défensif | Avant choc, réaction disponible et aptitude | Une réaction ; avant puissance/choc ; peut stopper attaque | E/reaction_status/assault | test_exchange_assault | CONFORME pour ordre ; absence d'épuisement ammo à traiter |
| Artillerie portée | Profils, Krupp jusqu'à 8 | French_rifled 6 ; Krupp 8 | P/weapons ; B/fire_cell_status | test_release0830 + lecture | CONFORME |
| Distance artillerie | Efficacité décroissante | Krupp [1,.95,.85,.72,.59,.45,.35,.25] ; français [1,.9,.72,.52,.32,.18] | P/weapons ; E/shot_loss | Lecture ; tests armes | CONFORME pour coefficients, équilibre NON TESTÉ |
| Artillerie sur amis | Autoriser selon élévation/sécurité | Tir à plat bloqué ; survol si hauteur et marge suffisantes | B/line_status | test_revision0830 | CONFORME pour cas exécutés ; proximité cible NON TESTÉE |
| LOS relief | Relief/bois/villages, bords hex | Deux offsets de ligne ; couvert bloque ; relief ignoré entre terrains découverts | B/line_status ; I/clear | test_revision0830 ; échec hill blocker ancien | DIFFÉRENCE : tolérance plain/open_ground excessive |
| Brouillard / reco | Caché/repéré/identifié ; pertes de contact | Portées 4/4/6 ; niveaux 1/2 ; contacts datés ; exact_adjacent=true divulgue effectif exact avant combat | I/compute/report ; E/refresh_intel | tests fog/intel/hidden_fire ; diagnostics détaillés dans TESTS.md | CONFORME pour mécanismes contrôlés ; anciennes attentes incompatibles |
| IA informations | Aucune position/valeur cachée | Observation nettoyée, ennemis visibles estimés | E/observation ; tactical_ai/choose | test_ai_compat0833 ; sonde V35 deux camps/trois difficultés 18/18 ; lecture | CONFORME pour cas testés ; garantie exhaustive NON TESTÉE |
| Cmd/Ravit | Distincts, liaison, coupure et rétablissement | Deux réseaux, ponts, detours et QG séparés | S/strict_networks/strict_report | test_strict0833 | CONFORME |
| Double coupure | 1 compteur, 2 désorganisation, 3 déroute/reddition ; remise à zéro | Compteur 1/2/3 ; reset dès un lien rétabli | E/advance_isolation/update_support | test_isolation0835 ; sonde prussienne save 8/8 | CONFORME pour compteur |
| Reddition conditionnelle | Selon situation/retraite viable | Tour 3 : reddition systématique ; déroute hors Cmd : immédiate même ravitaillée | E/advance_isolation/resolve_surrenders/retreat | Lecture ; tests isolation/strict | DIFFÉRENCE |
| IA offensive | Avancer/conquérir sans bonus cachés | attacking_side=1 ; urgence, progression, assaut renforcés | tactical_ai/choose/mission_goal ; P/ai | Sept tours complets ; état de test tour 12, cinq premières décisions | CONFORME pour progression constatée ; poursuite chronologique jusqu’à 12 NON TESTÉE |
| IA française | Défense, cohésion, contre-attaque | Branche non offensive ; couverture, réserves, ratios, mêmes règles | tactical_ai/choose ; legacy_ai/target_goal | Lecture ; décisions initiales test_ai0833 | NON TESTÉ pour efficacité sur bataille complète |
| Score | 60 objectifs / 20 pertes / 20 temps | final_control=60, military=20, duration=20 | P/victory ; E/result_for | Lecture ; sonde score | CONFORME pour pondération |
| Niveaux victoire | Cinq niveaux ; seuils adaptés à 60/20/20 | Nul ≤5 ; majeure ≥25 + contrôle supérieur + avantage pertes ≥10% | E/result_for ; P/victory | Sonde tous objectifs, zéro pertes : victoire mineure malgré 80 points d'écart | DIFFÉRENCE à valider avant changement |
| Sauvegarde | Tous états critiques, isolement compris | JSON state+previous, checksum, hash pack, .bak | save_store/read_slot/save_game/load_game ; E/normalize | Test UI V35, sonde isolation physique 8/8 | CONFORME pour états présents ; fatigue inexistante ; validation isolation insuffisante (section C) |
| Compatibilité saves | Ancien scénario conservé / nouvelle partie claire | Sauvegardes anciennes chargées avec anciens packs ; VERSION_0835 demande nouvelle bataille | UI/_ready/saved_scenario ; save_store | Lecture ; test migration diagnostiqué | CONFORME pour stratégie ; lisibilité Android NON TESTÉE |
| Moteur / data pack | Séparer générique et scénario | war_engine générique, valeurs dans packs/1870 | Arborescence, lecture | Statique | CONFORME globalement |
| Multijoueur internet | Ne pas développer maintenant | Pas de système réseau ajouté | Recherche scripts | Statique | CONFORME |

## A — V35 conforme

La carte de 600 cases à 350 m, les 18 tours, le budget de base de 4 PA pour les trois armes, les formations, les coûts d'assaut et de déploiement, les objectifs pondérés 3/2/1, la portée Krupp de 8 hexagones et la pondération 60/20/20 sont présents. Commandement et ravitaillement restent distincts. Le compteur d'isolement et son rétablissement fonctionnent dans les essais contrôlés.

L'essai supplémentaire transpose la cavalerie derrière une barrière ennemie au **camp prussien** et effectue une véritable écriture/relecture de fichier : compteur 1 avant sauvegarde, compteur 2 et ébranlement après reprise, compteur 3 et reddition ensuite. **8/8 contrôles**. Terrain et barrière synthétiques ; cet essai ne représente pas une position historiquement exacte sur la carte réelle. Les états sérialisés sont identiques après reprise ; une comparaison JSON canonique évite de confondre conversions de nombres int/float et perte de données.

### Bilan IA exécuté

La simulation chronologique sous Godot 4.6.3 a terminé **sept tours prussiens** face aux Français immobiles : **186 mouvements, 46 tirs, 11 assauts**, 7 aménagements, 22 changements de formation, 11 mises en batterie, 5 attelages et 5 repos. Frœschwiller est pris au troisième tour, Elsasshausen au sixième et Niederwald au septième. Chaque décision est exécutée légalement, son observation demeure inchangée et l’état est validé après l’action.

La simulation visant initialement douze tours a été interrompue volontairement après environ vingt minutes (code 143), pendant le huitième ; ce run n’est donc **pas terminé**. Les compteurs publiés proviennent du dernier tour entièrement terminé. La progression et les trois captures sont établies ; l’absence de passivité au douzième tour chronologique et l’équilibre face à une défense active ne le sont pas.

Un essai complémentaire Godot 4.5.1 initialise un **état synthétique au tour 12**, avec la carte réelle, les positions d’entrée, les renforts disponibles et un véritable début de tour prussien (budgets et liaisons appliqués). Il vérifie cinq décisions successives légales. Ce n’est ni la continuation de la simulation interrompue, ni la reproduction de votre partie précédente au tour 12, dont aucune sauvegarde n’est fournie. Le résultat détaillé est dans late-turn12.log.

Le contrôle V35 de deux mondes à ennemis cachés différents passe **18/18** sur deux camps et trois difficultés : mêmes observations, mêmes décisions, aucune modification de l’observation. Cette sonde renforce le contrôle existant sur ancienne fixture ; elle ne constitue pas une preuve exhaustive de tous les états IA.

## B — Différences

Chaque proposition ci-dessous reste **non implémentée**.

| Règle attendue | Code V35 / fichier et fonction | Cause probable | Correction proposée |
|---|---|---|---|
| Charge 3 PA | P charge_ap=8 ; E/assault_cost | Règle antérieure encore active | Passer le profil à 12 quarts et actualiser aide/tests, après validation |
| Charge avec mouvement et terrains interdits | E/assault_status demande adjacent ; aucun refus forest/village/bridge ; attack_power applique seulement pénalité | Charge réutilise l'assaut adjacent | Définir trajet spécifique, coûts et interdictions avant codage ; tester départ, trajet et arrivée |
| Aménagement 4 PA | P entrenchment.ap=8 ; E/entrench | Ancienne règle 2 PA toujours testée | 16 quarts ; préserver défense, persistance et annulation |
| Tir 2 PA | P french_rifled.ap=12 ; E/fire | Asymétrie ancienne explicitement couverte par anciens tests | 8 quarts si règle uniforme confirmée ; revoir déploiement + tir |
| Un seul tir actif | E/fire ne mémorise aucun tir actif utilisé | Limitation par PA uniquement | Compteur/verrou actif distinct de reactions, reset et sauvegarde |
| Ralliement activation entière | E/rally soustrait rally_ap=8 sans terminer s'il reste des PA | Ancienne activation libre | Terminer activation après réussite ; vérifier déroute et coût hors Cmd |
| Bouton TIRER | UI/on_cell second toucher confirme ; aucun bouton créé | Interface antérieure | Bouton explicite, sélection seule sans combat ; test tactile anti double touche |
| Fatigue | Aucun champ/calcul | Système attendu absent du projet fourni | Définition validée préalable ; évolution structurelle et sauvegardes à traiter séparément |
| Munitions réellement limitées | E/spend_ammo sature niveau 2 ; E/reaction_status ne teste pas l'épuisement | Abstraction par efficacité, pas stock | Clarifier modèle voulu ; si stock fini validé, gérer actif/réaction/ravitaillement et persistance |
| LOS relief | B/line_status ignore hauteur intermédiaire si endpoints open_ground | Tolérance introduite en ancienne révision et encore testée | Limiter tolérance aux faibles écarts ; harmoniser observation et tir sans tir indirect généralisé |
| Reddition selon situation | E/advance_isolation surrender inconditionnel à 3 ; resolve_surrenders pour routed&&!command_ok | Simplification explicite de VERSION_0835 | Au troisième constat, déroute puis évaluation de retraite/reddition ; valider critères |
| Niveaux adaptés au score territorial | E/result_for conserve avantage pertes de 10% pour victoire majeure | Condition de victoire militaire ancienne toujours active | Choisir seuils V36 après scénarios chiffrés ; ne pas changer silencieusement |
| ZOC mouvement | B/step_cost et E/move n'en appliquent aucune | ZOC utilisées pour réseaux seulement | Confirmer effets voulus avant ajout ; éviter d'inventer une ancienne règle |
| Effectifs historiques | P précise « Effectif et entrée de test, non historiques » | Scénario d'essai | Vérifier sources historiques puis proposer corrections de données ciblées |

La fiche ne possède pas de bouton humain explicite `TIRER`, ni de commande dédiée retrouvée pour simplement terminer l’activation. Le moteur possède `hold`, mais l’interface le réserve au chemin d’exécution IA. À traiter sans ajouter de menus profonds.

L’effet `exact_adjacent=true` divulgue les effectifs exacts à une case avant combat. Cela dépasse la simple estimation d’une unité identifiée et rend les anciens tests après-contact incompatibles ; la règle précise de révélation doit être validée avant toute modification.

L’horloge reste affichée à **16:30** après la fin effective du dix-huitième tour ; la durée de dix-huit demi-heures est bien conservée. Proposition : afficher 17:00 une fois la bataille terminée, sans modifier le nombre de tours.

Le contour QG vert est déjà aminci dans MV/hq_outline (fond max(3,4z), vert max(1.75,2.25z)). Cette lecture ne suffit pas à garantir sa lisibilité sur smartphone.

## C — Bugs réellement constatés

1. **Validation de sauvegarde insuffisante pour l’isolement.** `E/validate` accepte un compteur `isolation_turns=-999` ou une chaîne `"invalid"`, ainsi qu’un `turn_ap_limit=100` quarts. Trois sondes sous Godot 4.5.1 le reproduisent sur un état valide. Le checksum du fichier détecte des altérations accidentelles du payload, mais ne remplace pas la validation sémantique du moteur. Proposition : valider type entier et domaine des nouveaux champs en préservant l’absence de champ des sauvegardes anciennes. Aucun fichier utilisateur corrompu observé.
2. **Ancien test de formation cassé.** `tests/test_formations08.gd:63` appelle `desired_formation` sur `tactical_ai.gd`, qui ne possède plus cette méthode ; elle est dans `legacy_ai.gd`. Erreur d’exécution, test non terminé puis arrêté après 90 s. Ce bug concerne le test, pas une panne démontrée du gameplay.
3. **Nettoyage UI incomplet.** `test_regimental0835_ui` réussit ses 27 contrôles mais Godot signale des instances ObjectDB et deux ressources encore utilisées à la sortie, sous 4.6.3 et 4.5.1. Impact sur Android non mesuré ; ne pas présenter cet avertissement comme une panne de sauvegarde.

**Reichshoffen : pas de bug confirmé.** L’ancrage du texte et de la flèche passe bien de [7,2] à [6,2] entre V34 et V35. `arrow_cell` est inutilisé par le dessin mais inchangé ; `road_exits` reste [5,0]. Le déplacement provient de location.cell, réellement utilisé. Le contrôle visuel sur appareil reste à faire.

Les différences de coûts et restrictions sont démontrées, mais sont classées B pour distinguer désaccord de règles et panne technique.

## D — Code obsolète

- Les fichiers `legacy*.json` sont chargés pour reprendre d'anciennes sauvegardes. Ils ne doivent pas être supprimés ni qualifiés tous d'inutilisés.
- `legacy_ai.gd` demeure utilisé : fallback pour difficultés anciennes et fonctions auxiliaires de l'IA actuelle.
- `UI/_ready` force encore `charge_ap=8` après reprise d'un ancien pack. Cette règle contredit la référence 3 PA et doit être traitée dans le plan de compatibilité.
- Les anciennes fixtures et tests valident parfois deux tirs de Krupp, aménagement 2 PA, artillerie française 3 PA, Krupp limité à 6, seuil militaire de victoire majeure. Ce sont des attentes historiques, pas des preuves de conformité V35.
- `test_artillery0823` attend qu'une hauteur de plaine bloque le tir ; `test_revision0830` vérifie explicitement l'inverse. Échec expliqué par attentes devenues contradictoires.
- Les comparaisons exactes de dictionnaires de l'ancien test de migration échouent, alors que l'import réussit et que les états JSON canoniques sont identiques. Aucun effacement de données démontré dans cet essai. Le même échec est reproduit avec Godot 4.5.1 ; il n’est donc pas limité à 4.6.3.
- Les métadonnées historiques (`historical_status`, `simulation_note`, `historical_unit_id`) servent à qualifier les données ; elles ne sont pas des coefficients de combat.

## E — Risques de régression et limites

- Charge : coût, trajectoire, rivière, terrain, ZOC, feu défensif, avance, annulation et état sauvegardé sont couplés.
- Un tir actif par tour doit rester indépendant de la réaction défensive. Le coût du canon français influence fortement ses possibilités après déploiement.
- Les changements de fatigue ou de munitions impliquent données persistantes, reprise d'anciennes parties, information ennemie et observation IA.
- LOS et brouillard utilisent des règles de relief différentes ; toute correction doit tester les bords d'hexagones et le survol ami sans fuite d'information.
- Le score final associe objectifs finaux et durée ; les seuils de victoire restent militaires. Une correction des seuils exige validation utilisateur.
- La campagne initiale utilise 4.6.3 ; les vérifications critiques sur 4.5.1 confirment les mêmes comportements et les mêmes échecs de migration. Pas de compilation/signature Android, d'essai tactile ou de mesure de fluidité sur appareil.
- L'IA contre Français immobiles peut démontrer une progression mais ne mesure ni équilibre ni aptitude face à un joueur. La défense française ne peut être déclarée validée par ce seul essai.
- L'import headless des assets réussit, avec erreur de sauvegarde des paramètres d'éditeur dans un emplacement non accessible. Les tests moteur/UI s'exécutent ensuite ; ce message ne prouve pas un problème du jeu.
- Les résultats de tests historiques fournis dans l'archive ne sont pas assimilés aux résultats exécutés pendant cet audit.

## F — Proposition V36, cinq priorités maximum

1. **Charge conforme V35** : 3 PA, restrictions de terrain, trajet spécifique à définir ; conserver 4 PA de base.
2. **Actions conformes V35** : limite d'un tir actif, tir français 2 PA, aménagement 4 PA, ralliement terminant l'activation ; bouton TIRER et sauvegarde des nouveaux verrous.
3. **LOS et isolement** : relief effectivement bloquant selon géométrie ; déroute au troisième constat puis reddition conditionnelle ; tester cavalerie isolée et retraite viable.
4. **Objectifs et victoire** : valider les seuils sous 60/20/20, puis mesurer IA offensive/défensive sur situations reproductibles proches du tour 12. Fatigue, stocks de munitions et ZOC nécessitent d'abord une décision de conception.
5. **Sauvegardes et validation** : valider les domaines isolation_turns/turn_ap_limit, conserver le décalage Reichshoffen validé, actualiser les tests obsolètes et vérifier l'UI et la reprise sur appareil Android (Godot 4.5.1 vérifié ici).

Ces groupes proposent un ordre de travail, pas une autorisation de modifier plusieurs systèmes majeurs simultanément. Les sous-changements doivent être livrés séparément avec leurs régressions. Aucune V36 n'a été commencée.

## Annexes

- `TESTS.md` : résultats effectivement exécutés, nombres de contrôles, erreurs et limites.
- `CARACTERISTIQUES.md` : inventaire par catégorie, types, valeurs initiales, visibilité, effet et références.
- `unit-state.json` : état initial des 81 unités tel que produit par le moteur.
- `audit-probes.log`, `isolation-save.log`, `sim-until12.log` : traces de reproduction.
- `test-results.json` et fichiers `.log` : résultats et sorties brutes des suites.

Forces de données, renforts compris : France 45 unités (24 infanterie, 10 cavalerie, 6 artillerie, 5 QG), 45 550 hommes ; Prusse/alliés 36 unités (18 infanterie, 4 cavalerie, 10 artillerie, 4 QG), 44 900 hommes. Tous les dix profils d’artillerie du second camp sont `krupp` (8 cases) ; le moteur dépend du profil d’arme, mais la pertinence historique de cette attribution uniforme n’est pas démontrée. Ces totaux incluent des données déclarées provisoires et ne doivent pas être présentés comme un ordre de bataille historique certifié.
