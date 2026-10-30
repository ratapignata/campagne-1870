# Tests V43.15 réellement exécutés

Godot 4.5.1 officiel, environnement Linux. L’APK Android est compilé et signé ; aucun essai physique Android.

## Vérifications techniques

**23 suites headless : 2 487/2 487 contrôles réussis.** Le résultat final remplace les premiers essais échoués des deux tests adaptés ; il ne compte pas leurs relances plusieurs fois.

Nouvelle défense : 28/28. Approche dans le bois, préparation puis tir réel ; colonne formant la ligne sous menace ; garnison préparant son retranchement ; PA effectivement dépensés ; batterie stable puis tir français à 3 PA ; maintien du point tenu ; reprise réelle de Wœrth par assaut favorable ; refus d’un assaut désespéré ; affectation aux trois objectifs ; réserves et leur libération face à un ennemi observé ; observation intacte ; politiques prussiennes et Normal identiques au témoin ; sauvegarde/reprise et indépendance vis-à-vis d’un ennemi caché.

Intégration réelle du jeu : 8/8. Partie lancée Prussiens/Difficile, IA française calculée dans le worker de production, ordre exécuté par le véritable répartiteur d’actions, validation et relecture de la sauvegarde automatique avec camp et difficulté conservés.

Les 21 suites antérieures couvrent notamment combats/variante B (1 701), isolement, liaisons, brouillard, renforts, Raoult, cavalerie, coûts, export, interface et rapports. Le test historique « French doctrine unchanged » a été adapté à la nouvelle demande : Normal français reste exactement gelé ; Difficile est maintenant explicitement défensif, sans modifier son observation. Les contrôles prussiens ont été conservés.

Relecture du fichier personnel V43.11 conservé dans le workspace : 3/3, score et anciens objectifs identiques, fichier original inchangé. **Total technique : 2 490/2 490.** Une tentative préalable sur le chemin temporaire de l’ancienne pièce jointe V43.13 a échoué parce que ce fichier n’est plus disponible dans cette instance ; elle ne constitue pas un échec de compatibilité du moteur. Cette dernière pièce jointe n’a donc pas été relue durant V43.15.

Contrôle d’intégrité : onze fichiers de scénario, profils, IA Normal, moteur, réseaux, LOS, sauvegarde et présentation identiques octet pour octet à V43.14 `3f7f01c`. Le témoin IA est une copie exacte de cette version. Aucun changement de carte, d’effectif, d’arme, de règle ou de bonus militaire.

## Carte complète — huit tours chronologiques

Même scénario de 95 unités, 95 000 Allemands, 45 550 Français, mêmes objectifs, graine 18704315 et style 0. Aucun repositionnement de test ni garnison de Wœrth scriptée. Les Français et les Prussiens jouent des décisions de production légales. L’adversaire prussien utilise le témoin offensif V43.14 dans tous les cas ; il adapte ses décisions aux positions réellement rencontrées.

Trois politiques françaises comparées : Normal gelé, ancien Difficile V43.14, nouveau Difficile V43.15. Pour isoler les décisions françaises, le calendrier physique est **Difficile dans les trois cas**, y compris le témoin de politique Normal. Ce n’est donc pas une comparaison globale de deux parties Normal/Difficile ayant des dates de renfort différentes. Le joueur humain déclaré est prussien.

Les témoins ont exécuté T1–T4, enregistré leur état puis repris T5–T8 ; le nouveau Difficile a exécuté T1–T8 sans interruption. Les mêmes graine, état RNG, unités, historiques et règles sont préservés à la reprise. Chaque cas a terminé ses seize phases, jusque début T9. Normal et ancien Difficile produisent ici exactement la même suite d’ordres : leurs mesures sont identiques.

| Mesure | Normal / ancien Difficile | Nouveau Difficile |
|---|---:|---:|
| Tirs de canon français | 10 | 17 |
| Autres tirs actifs français | 79 | 86 |
| Assauts français | 1 | 3 |
| Mouvements français | 123 | 133 |
| Aménagements français commandés | 36 | 33 |
| Infanteries françaises dans un bois/village en fin T8 | 2 | 5 |
| Infanteries françaises retranchées en fin T8 | 10 | 10 |
| Pertes françaises hors prisonniers | 8290 | 9751 |
| Pertes prussiennes hors prisonniers | 6660 | 6648 |
| Prisonniers français | 123 | 12 |
| Prisonniers prussiens | 0 | 159 |
| Contrôle de Frœschwiller en fin T8 | France | France |
| Contrôle de Wœrth en fin T8 | Prusse | Prusse |
| Contrôle de Niederwald en fin T8 | Prusse | France |

Les pertes hors prisonniers ne sont pas un décompte des morts : le moteur ne distingue pas morts et blessés. Les mouvements de repli peuvent eux aussi amener une unité dans le couvert ; la métrique de position finale ne mesure pas à elle seule la qualité tactique.

Chronologie des captures, sans masquer les reprises temporaires :

- normal : T4 Wœrth → Prusse; T6 Niederwald → Prusse
- current : T3 Wœrth → Prusse; T4 Wœrth → France; T4 Wœrth → Prusse

Ces huit tours ne sont **pas une bataille achevée de vingt tours**. Aucun score intermédiaire n’est présenté comme une victoire finale. Une graine/style sur la grande carte ne prouve pas un taux de victoire général ni une meilleure décision à chaque activation.

Temps de décision médian français, cloud partagé : 2307.5 ms témoin / 2446.0 ms nouveau ; maxima 5703 / 4544 ms. Les processus ont tourné en parallèle : ces mesures ne sont pas un benchmark de smartphone Android.

## Franchissement sous supériorité prussienne

État **synthétique au T6**, même carte et mêmes franchissements de la Sauer, un objectif Wœrth, cinq infanteries françaises et une batterie/QG contre huit infanteries prussiennes, deux batteries/deux QG. Forces initiales 8 000 contre 24 200, individus et armes aux valeurs sources. Toutes les unités du cas sont présentes au départ. Il ne s’agit pas d’une nouvelle partie chronologique principale.

Quatre tours complets T6–T9, deux graines et les trois politiques, même adversaire actif :

| Graine et politique | Première prise prussienne | Pertes France | Pertes Prusse |
|---|---:|---:|---:|
| 18704315 normal | T8 | 1549 | 1703 |
| 18704315 current | T8 | 1701 | 2069 |
| 18704316 normal | T8 | 1541 | 1746 |
| 18704316 current | T8 | 1708 | 2074 |

Les deux nouveaux essais ont gardé le même tour de première prise que les témoins, en infligeant environ 19–21 % de pertes supplémentaires aux attaquants, au prix d’environ 10 % de pertes françaises supplémentaires. Il n’est pas affirmé que l’objectif est inexpugnable.

**Contrôles de légalité et d’état des simulations : 6901/6901**, comptés séparément des tests techniques. Aucun ordre illégal, état invalide ou plafond d’actions atteint. Voir les fichiers JSON de `tests/results/0843_15` pour les résultats et décisions de la grande carte.

## Reproduction

```sh
# Partie complète jusqu’à fin T8, politique française courante :
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4315_defence.gd -- current /tmp/current.json 18704315 8
# Témoins : remplacer current par reference ou normal.
# Pour reproduire la reprise : exécuter jusque 4, puis passer 8 et le .state.json comme dernier argument.
# État synthétique de franchissement :
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4315_crossing.gd -- current /tmp/crossing.json 18704315
```

Employer Godot 4.5.1 et des répertoires XDG_CONFIG_HOME, XDG_DATA_HOME et XDG_CACHE_HOME accessibles en écriture. Les simulations peuvent prendre plusieurs dizaines de minutes.

## Corrections pendant le développement et limites

Le premier réglage favorisait trop les tirs depuis la colonne de marche et retardait le retranchement. Le test de franchissement perdait Wœrth au T7 au lieu du T8 témoin. Ce réglage a été rejeté ; formation défensive et préparation du point menacé ont été rétablies en priorité, puis les essais concernés relancés depuis le même départ. Le réglage final n’est pas un mélange de versions pendant la simulation courante.

Un test de batterie initial utilisait un village interposé qui bloquait son tir : la géométrie du cas a été corrigée. Une erreur de variable redéclarée dans le nouveau test a été corrigée. L’ancienne assertion bloquant tout changement de doctrine française a été remplacée par les invariants Normal et prussiens et les nouveaux contrôles de défense ; aucune assertion de combat n’a été assouplie.

L’ancienne suite UI conserve ses avertissements ObjectDB et ressources utilisées à la fermeture malgré ses assertions réussies. Le nouveau test d’intégration français termine sans échec.

APK : 0.8.43.15, code 72, application org.woerth1870.prototype.v02. Signature v2/v3 vérifiée, même certificat SHA-256 `57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c`. Le module français est inclus dans l’APK. L’échec de lancement d’ADB dans un dossier personnel non inscriptible intervient après l’export signé réussi ; aucun appareil n’a été utilisé.

Non réalisés : essai physique Android, nouvelle bataille principale complète T1–T20, validation sur plusieurs graines/styles de la grande carte ou comparaison avec une véritable attaque humaine. Les animations n’ont pas été retestées graphiquement dans cette version ; leur rendu est identique à V43.14 et les tests de présentation existants passent.
