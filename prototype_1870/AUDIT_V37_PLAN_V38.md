# Audit V37 et plan de développement V38

Audit réalisé avec Godot 4.5.1 officiel, sans modifier les sources V37/V36, sans développement V38, sans opération distante. Tests sur une extraction jetable dans `/tmp/audit-v37/run`; mesures, sondes et résultats séparés. Les 631 fichiers sources V37 ont les mêmes SHA-256 avant/après audit ; dépôt local propre.

## 1. État et authenticité de V37

Sources examinées : `/workspace/v37/prototype_1870`, archive livrée `1870_v0.8.37_Sources.zip`, copie récupérée de GitHub `/workspace/v37/github-verification`. APK réellement disponible : 87 876 685 octets. Application 0.8.37, code Android 50, badge 0.8.37. Commit local des sources : `303550f`; branche publiée `apk-v0.8.37`, commit `fcb782c5bcd5626f77fb394768399aff6cd80447`.

APK SHA-256 : `17d3cde5764840dfd9164e8f80a8fa2aaf2553d6ca97cf84923faf91773459a8`.
ZIP SHA-256 : `7b390e8ed8fd854554ffeecf5c349fb24924005a06c614b8337bfd9f024fd602`.

Comparaison à V36 : **4 fichiers existants modifiés** (`project.godot`, `export_presets.cfg`, `packs/1870/fr.json`, `README.md`) et **48 fichiers ajoutés**, principalement tests, rapports, journaux, données de simulation et UID des nouveaux scripts. **Aucun fichier moteur ou IA modifié**, aucun changement des scénarios/profils. Les corrections sauvegardes/LOS/isolement sont celles de V36, conservées en V37. V37 ajoute surtout la validation de la bataille complète et ses livrables.

Le champ 0.8.35 des packs est délibérément conservé pour les empreintes des sauvegardes ; il ne signifie pas que l’application est V35. Les fichiers VERSION_0837.md, TESTS_V37.md, BATAILLE_V37.md, FICHIERS_MODIFIES_V37.md et les résultats 0837 sont présents. Scène main.tscn, scripts préchargés, polices, images, sons et keystore de développement sont présents. Import Godot réussi. Aucun fichier nécessaire manquant confirmé ; un contrôle textuel signale un préfixe de chemin construit dynamiquement dans un ancien test, pas une ressource absente.

APK debug de test : signatures v2/v3 valides, alignement ZIP 16 Ko, segments ELF 64 bits de Godot et libc++ alignés 16 Ko, Android minimum API 24, cible 35, architectures ARMv7/ARM64/x86_64. SDK, Java et modèles d’export existent dans cet environnement. Pas de recompilation pendant cet audit, ni de test physique ou en émulateur : compatibilité réelle GPU, températures, mémoire et fluidité restent à vérifier sur appareil.

### Règles et fonctionnement

- 4 PA de base ; 3 PA hors commandement ; 2 PA en double coupure, au début du tour de l’unité. Le plafond est figé pour le tour : une coupure au milieu du tour n’en retire pas rétroactivement les PA.
- Charge 2 PA ; assaut standard 3 PA ; aménagement 2 PA ; ralliement historique du scénario 2 PA ; changement de formation 1 PA.
- Canon français : tir 3 PA, portée 6 ; Krupp : tir 2 PA, portée 8 ; mise en batterie/repli 1 PA. Chassepot portée 3, Dreyse 2, tir 2 PA dans ce scénario.
- Aucun bouton TIRER ; second toucher sur la cible confirmé par test tactile automatisé.
- Score 60 % objectifs finaux / 20 % pertes militaires / 20 % durée ; objectifs 3/2/1, carte 30×20, 18 demi-heures. Fin affichée à 17 h 00.
- Ripostes inchangées : budget propre, pas de coût en PA d’activation, conditions existantes de portée/LOS/moral/déploiement et consommation de munitions ; un assaut utilise la même réaction disponible. Aucun soutien défensif nouveau.
- Isolement : compteur au début du tour, désorganisation au deuxième constat, déroute au troisième, retraite légale recherchée avant reddition ; liaison rétablie remet le compteur à zéro. Une déroute hors commandement n’impose pas la reddition si un couloir praticable existe. Le tir/assaut offensif en déroute reste interdit.
- LOS : surface/obstacle comparés à un rayon interpolé ; helper commun tir/reconnaissance, deux tracés de bord conservés, tir en hauteur et survol amical autorisé sous les conditions existantes. Aucun changement pendant l’audit.
- Sauvegardes : validation sémantique avant écriture, checksum/empreinte, primaire et secours, ancien état annulable validé, champs facultatifs compatibles. Tests réussis ; aucun défaut de chargement confirmé dans les cas exécutés.
- Le fichier de scénario indique explicitement ADAPTATION_GAMEPLAY : effectifs, positions, horaires et groupes de batteries provisoires. Le respect des données V37 est vérifié ; une authenticité historique complète de l’ordre de bataille n’est pas démontrée.

### Anomalies confirmées

**A1 — Repli/redéploiement inutile d’artillerie.** Huit enchaînements immédiatement adjacents dans la bataille V37 : `limber` puis `deploy` pour la même batterie, sans mouvement. Sandrart, tours 2/3/8/10/11/12 ; réserve_art_10, tours 9/10. Chaque paire consomme 2 PA, soit 16 PA cumulés pour ces huit épisodes. Exemple : Sandrart reste en [11,14], passe de 4 à 3 à 2 PA, puis tire une seule fois alors qu’elle disposait déjà d’une cible et de 4 PA. Le candidat `limber` porte un trajet, mais `main.gd / apply_ai_decision` et le dispatcher des tests ne l’exécutent pas ; le prochain choix peut redéployer immédiatement. Le chemin prévu n’est pas mémorisé. Défaut de continuité de décision confirmé, pas défaut de coût du moteur.

**A2 — Menace mobile sous-estimée pour les canons.** `tactical_ai.gd / threat` ne compte le danger de contact que pour un ennemi déjà adjacent. Sonde à quatre unités, terrain plat, règles originales : canon français en [4,4], cavalerie prussienne visible en [7,4]. Estimation de menace 0 ; deux pas coûtent 1 PA, la cavalerie dispose encore de 3 PA et peut légalement charger à 2 PA. Les découvertes interrompent correctement le trajet ; il est repris légalement dans le même tour. Cela prouve un angle mort de prévision, pas une victoire certaine de la charge. Les batteries adverses non déployées pouvant déployer/tirer au prochain tour sont aussi absentes de la prévision actuelle ; ce second cas est un constat de code, pas une sonde dynamique distincte.

**A3 — Informations contradictoires dans l’aide.** Le plafond du panneau est correct (sonde 4/4, 3/3, 2/2). `command_effect` omet le plafond et l’ancienne aide support annonce l’absence de perte automatique de PA ; `help_strict0833` explique correctement le −1 PA au prochain tour. `isolation_count` annonce encore une reddition au troisième constat, alors que le helper strict et le moteur permettent la retraite. Corriger les textes conditionnellement au scénario, sans changer les règles ni réécrire l’aide des anciennes variantes.

**A4 — Métadonnée d’annotation trompeuse.** `arrow_cell` est utilisé comme indicateur de présence de flèche ; sa valeur n’est pas utilisée pour la position. Modifier seulement cette valeur ne déplacerait pas la flèche. Le recadrage peut annuler une translation graphique : sonde à zoom initial 0,72, hauteur carte 448, déplacement attendu 42,40 pixels, déplacement obtenu 0 après clamp.

### Comportements discutables, pas erreurs de règle

Le QG Raoult prévu au tour 3 en [15,4] ne rentre pas dans la bataille archivée : case tenue d’abord par fr_8, puis par pru_40 à la fin. L’attente sur entrée occupée est expressément prévue, donc pas de téléportation à ajouter. L’IA ne libère pas cette entrée. Son observation filtre les unités non vivantes/en attente, donc ne contient pas de liste explicite de ses futurs renforts ; une gestion des entrées nécessiterait de lui transmettre ses seuls renforts propres autorisés. Le défaut éventuel est la préparation de l’arrivée, pas la légalité de l’attente.

Le rejeu compte 331 observations d’unité-tour avec progression légale possible, 243 françaises/88 prussiennes ; aucune attaque légale laissée disponible en fin de demi-tour. Ce ne sont pas 331 unités différentes et une réserve défensive n’a pas automatiquement intérêt à avancer. Investigation ciblée avant modification de doctrine.

## 2. Difficultés : code et simulations nouvelles

Même moteur, même budget, mêmes armes ; difficulté uniquement consultée par la politique AI. Pas de bonus de dégâts, de PA ou d’information identifié. Observation assainie ; tests de deux mondes cachés et compatibilité réussis. Une estimation des forces observées ne représente pas leurs données secrètes exactes.

Le facile est moins prudent, sans réserve/soutien pondérés, avec variation déterministe. Le moyen valorise davantage couvert, risque de retour, réserves et liaison. Le difficile reprend le même algorithme glouton, sans recherche supplémentaire ni plan d’attaque commun. Par rapport au moyen : risque de riposte 0,40→0,55, menace 0,55→0,75, couvert 44→50, réserve 16→22, appui 5→9, sécurité liaison 48→90 ; protection QG et concentration locale des tirs ajoutées. Ses seuils d’assaut/charge, progression et coût des armes ne changent pas. Le texte de sélection le décrit d’ailleurs comme « plus prudent ».

**Six simulations nouvelles, chacune 18 tours**, deux graines 187037/187038. Scénario expérimental V36 de 14 unités sur le terrain original 30×20, placement synthétique, arrivées à 1 ; pas la campagne complète de 81 unités. Défense française IA moyenne active maintenue constante ; seule politique prussienne varie. État initial, forces, règle, graine et style 0 identiques à l’intérieur d’une comparaison. Pas de généralisation à la défense française difficile ou à tous les déploiements. Des résultats différents consomment ensuite les tirages de combat dans un ordre différent : la graine contrôle le départ, pas l’identité de chaque échange entre politiques.

| Graine | Niveau prussien | Score PR | Objectifs PR finaux | Mouvements PR | Tirs PR | Assauts PR | Tirs de la batterie PR | Pertes FR/PR | Résultat PR |
|---|---|---:|---:|---:|---:|---:|---:|---|---|
| 187037 | Facile | 82.87 | 3/3 | 73 | 64 | 4 | 15 | 3820/4473 | major_win |
| 187037 | Moyen | 45.56 | 1/3 | 75 | 88 | 2 | 20 | 3579/3466 | draw |
| 187037 | Difficile | 46.76 | 1/3 | 103 | 87 | 4 | 27 | 3619/3279 | draw |
| 187038 | Facile | 79.79 | 3/3 | 69 | 73 | 5 | 20 | 3820/4978 | minor_win |
| 187038 | Moyen | 45.46 | 1/3 | 65 | 86 | 2 | 20 | 3532/3518 | draw |
| 187038 | Difficile | 66.94 | 2/3 | 90 | 97 | 4 | 21 | 3875/3253 | major_win |

Le difficile améliore le résultat du moyen sur ces deux graines et la conservation de ses forces, mais ne domine pas le facile, qui capture les trois objectifs dans les deux cas en acceptant davantage de pertes. L’échelle de défi n’est donc pas calibrée par ces résultats. Deux graines et un dispositif réduit ne suffisent pas à mesurer un taux de victoire général. Aucun changement du moyen conseillé à partir de ces seules expériences.

Recommandation : améliorer en difficile la continuité des plans, la préparation des attaques et l’arbitrage entre objectifs. Ne pas augmenter globalement l’agressivité ; conserver les coefficients moyens et tester toute correction commune par comparaison avant/après.

## 3. Artillerie : fonctionnement et priorités

### Mesures du rejeu complet à 81 unités déclarées

| Actions des batteries | Françaises | Prussiennes |
|---|---:|---:|
| Mouvements | 18 | 63 |
| Mises en batterie | 7 | 23 |
| Replis | 0 | 18 |
| Tirs actifs | 27 | 62 |
| Tirs sur case d’objectif exacte | 5 | 2 |
| Tirs à munitions faibles | 0 | 5 |

Six batteries françaises et dix prussiennes déclarées ; cinq françaises et huit prussiennes tirent au moins une fois. Cibles réelles : FR 22 tirs sur infanterie/5 sur artillerie ; PR 52 sur infanterie/5 cavalerie/5 artillerie. Le type réel de la cible est classé ici pour l’audit ; l’IA ne doit utiliser que le type autorisé par sa reconnaissance. Le chiffre « objectif exact » ne couvre pas tous les défenseurs proches d’un objectif. Ces données proviennent du rejeu de la bataille moyenne V37, pas d’une nouvelle bataille difficile à 81 unités.

Dans les comparaisons réduites : batterie PR facile 15/20 tirs (graines 37/38), moyenne 20/20, difficile 27/21. Au premier cas : mouvements de batterie 6/3/2, replis 2/2/1, tirs sur case d’objectif 11/6/27. Le difficile montre une concentration et une stabilité meilleures dans ce cas, sans preuve qu’il soit toujours supérieur. La batterie française fait seulement 2 à 3 tirs dans ce petit dispositif ; ces positions synthétiques ne suffisent pas à diagnostiquer toute l’artillerie française.

### Mécanismes existants

Le score de tir valorise pertes attendues, pénalité de riposte, cible sur objectif assigné, et proximité d’appuis amis en difficile. Il n’attribue pas de valeur explicite à un QG identifié, à une élimination décisive ou à un bombardement utile à un assaut ami planifié. La concentration en difficile est une heuristique de proximité, pas un objectif de feu partagé mémorisé.

Les emplacements sont évalués avec chemin vers mission, couvert, menace, liaisons, possibilité de tir courante/prochaine et captures. Une batterie ne prépare pas un plan combiné « repli, trajet, déploiement, tir » ; les futurs tirs sont estimés avec un déploiement hypothétique et un plafond de PA, ce qui ne comptabilise pas tout le calendrier des opérations. A1 illustre concrètement cette faiblesse.

Les munitions abstraites sont prises en compte dans les dégâts estimés ; au niveau faible, facteur 0,65. Trois salves, réactions comprises, dégradent un niveau. Il n’existe pas un stock détaillé ni une interdiction de tirer au niveau faible. Rest est considéré pour permettre la récupération existante ; aucun bonus gratuit ni changement de ravitaillement proposé.

### Corrections V38 proposées, non développées

1. **Continuité du repositionnement** : conserver l’intention et son trajet après repli, revalider chaque mouvement, gérer arrêt sur découverte, abandonner un plan devenu illégal ; empêcher les boucles immédiatement contradictoires. Comparer aussi à rester et tirer, en comptant tous les PA et les occasions perdues. Aucun mouvement offert ni coût réduit.
2. **Protection mobile** : estimer pour les seuls ennemis connus la possibilité « mouvement + charge » et « déploiement + tir » ; utiliser un budget nominal estimé, sans consulter leur support/munitions secrets. Prévision conservative, pas certitude ni réaction nouvelle. Cache de portée/mobilité par décision pour limiter le coût.
3. **Cibles utiles** : bonus tactique limité pour défenseur d’objectif pertinent, QG effectivement identifié, élimination plausible, cible gênant une attaque amie imminente. Pondérer rôle/objectif par bénéfice plutôt que masse de pertes seule. Toujours vérifier fire_status.
4. **Préparation** : synchroniser bombardement et infanterie prête à exploiter, grâce aux PA/positions/moral existants. Aucun effet spécial de bombardement ni nouveau soutien défensif.
5. **Stabilité** : un maintien en bonne position doit battre un déplacement de bénéfice marginal après coût de repli/redéploiement. Petit nombre d’emplacements candidats, pas recherche exhaustive.
6. **Gestion du cycle de munitions** : comparer tir utile maintenant et récupération existante, en tenant compte de la liaison et de la situation de l’objectif. Ne pas empêcher par une nouvelle règle les tirs à munitions faibles.

Risques : plus de tirs effectifs prussiens après correction A1, meilleur emploi de la portée Krupp, donc équilibre changé même sans toucher aux armes ; prudence supplémentaire A2 peut aussi réduire la pression. À mesurer conjointement. Le moyen doit rester une référence figée ; priorité au planificateur difficile, corrections communes à valider séparément. Toute projection doit rester bornée pour Android.

## 4. Étude cartographique

### Sauer

La rivière est dessinée depuis 59 frontières d’hexagones. Calcul de leur graphe : une composante, deux extrémités, aucune bifurcation ; chaîne ordonnable sans inventer le tracé. Construire une **Curve2D purement graphique** depuis les extrémités/milieux de ces segments publics, sur un tronçon choisi, sans modifier river_edges, tiles, bridge ou les règles.

Godot 4.5 ne fournit pas un Label suivant automatiquement une courbe. Solution adaptée au MapView actuel : espacement et rotation de chaque glyphe de « Sauer » sur la Curve2D, échantillonnée en distance et tangente, via dessin 2D. PathFollow2D par glyphe est une alternative, mais ajouter des nœuds est peu nécessaire pour cinq lettres. Respecter avances/kerning, retourner à la transformation de dessin normale ensuite.

Bleu cohérent avec le cours d’eau, serif italique discrète ; une police serif grasse existe déjà, pas une serif italique dédiée. Envisager un petit asset libre licencié si nécessaire. Taille minimale lisible à petit zoom, test paysage smartphone, pont/route/objectif et villes exclus. Dessin sous les pions prioritaires ; ne pas déplacer un nom en fonction d’un ennemi caché. La faisabilité est confirmée ; emplacement définitif et lisibilité physique restent à valider visuellement.

### Reichshoffen

Annotation identifiée sans ambiguïté : texte `Vers Reichshoffen`, cell [6,2], marker arrow_cell [5,0] dans regimental_trial.json. Rendu réel : anchor à cell, décalage texte (0,−38)×zoom, flèche verticale descendante de sqrt(3)×34×zoom, couleur de route, recadrage dans la fenêtre. La valeur de arrow_cell n’est pas exploitée.

Un hexagone vertical vaut **58,889727 unités graphiques**, soit **42,4006 pixels à zoom 0,72**. Avec north_left=true, augmenter y de cellule remonte le dessin ; modifier [6,2]→[6,3] serait erroné pour une descente à l’écran. L’audit géométrique sur UI 1280×720 (zone carte hauteur 448) montre que le clamp annule entièrement la translation au zoom initial, et à 0,42 ne laisse que 22,09 pixels sur 24,73 demandés. Aux zooms où l’annotation est hors du champ, le moteur peut la masquer avant de la dessiner.

V38 doit translater **le groupe texte + flèche** dans le repère graphique, conserver orientation, largeur, taille, couleur et route, et traiter le recadrage/marge/panoramique sans annuler ce déplacement. Aucune modification des coordonnées/propriétés de terrain ; éviter de modifier le JSON du scénario afin de conserver son empreinte de sauvegarde. Attention à la marge inférieure : une simple suppression de clamp peut couper la pointe. Pas d’élément terrain/objectif sur cette bordure identifié comme obstacle inévitable, mais non-chevauchement et lisibilité à tous les cadrages ne sont pas certifiés sans contrôle visuel. Aucune capture supplémentaire nécessaire pour identifier les éléments ; vérification visuelle avant livraison indispensable.

## 5. Autres améliorations évaluées

- **Réserves** : le code possède déjà une pondération de réserve autour d’un objectif tenu, hors artillerie/cavalerie, mais pas de mission persistante ni de déclencheur de percée. Ajouter en difficile un déclencheur fondé sur menace connue et objectif accessible ; ne pas transformer toute immobilité en avance obligatoire.
- **Coordination** : objectif partagé et horizon court pour bombardement, progression et assaut, avec mécanismes/PA actuels ; aucune mécanique de riposte/soutien ajoutée.
- **Objectifs** : choix actuel points/(3+coût de chemin), urgence croissante. Pas d’évaluation complète de défendabilité ni d’alternative obligatoire lorsqu’un objectif prioritaire ne produit aucun mouvement acceptable. Comparer quelques objectifs secondaires et leur risque connu, d’abord en difficile.
- **Renforts propres** : transmettre à l’IA ses seules arrivées autorisées, puis préparer une libération légale et sûre d’entrée quand utile. Pas de téléportation, spawn alternatif ou déplacement forcé d’occupant.
- **Rapport final** : UI possède déjà score détaillé, pertes, prisonniers, déroute et statistiques d’actions. Compléter par noms des objectifs/contrôle, unités capitulées et chronologie des captures. Le journal support est limité à 256 événements ; une chronologie complète doit être conservée explicitement et de manière bornée/compatible. Réutiliser result_for, sans second calcul divergent du score.

## 6. Plan V38 soumis à validation

| Lot / priorité | Travail proposé | Complexité | Régression / équilibre | Bénéfice et critères de sortie |
|---|---|---|---|---|
| 1 — P0 | Reproduire A1, réparer continuité de repositionnement ; cohérence de l’aide PA/isolement | Moyenne / faible | Moyen pour IA, faible pour textes | Plus de boucles sans mouvement injustifié ; coûts et brouillard conservés ; 8 épisodes de référence testés |
| 2 — P1 | Protection mobile A2 et choix de positions/cibles d’artillerie en difficile | Moyenne à élevée | Moyen à élevé | Menaces visibles correctement anticipées, bonnes positions conservées, tirs utiles/préparation accrus ; aucune donnée cachée |
| 3 — P1 | Missions coordonnées et alternative d’objectif en difficile | Élevée, bornée | Élevé pour équilibre/performance | Défi supérieur au moyen dans une batterie de scénarios, pas simple agressivité ; moyen inchangé sauf correction explicitement acceptée |
| 4 — P2 | Gestion des entrées de renforts propres et réserves conditionnelles | Moyenne | Moyen à élevé | QG entre si une libération sûre est possible, sans forcer arrivée ; réserves justifiées |
| 5 — P2 | Sauer et translation Reichshoffen | Moyenne / faible à moyenne | Faible pour règles, moyen pour cadrage | Terrain/scénario identiques, delta d’un hexagone réellement mesuré, aucune pointe coupée ; contrôle Android |
| 6 — P3 | Compléter rapport final et historique compatible | Moyenne | Moyen pour sauvegardes | Score inchangé, unités capitulées et captures explicites, ancienne sauvegarde chargeable |
| Transversal | Campagne de référence, profils/performance, tests Android et livraison | Moyenne | Réduit les risques précédents | Suites actuelles, sondes A1/A2, plusieurs graines/style et comparaison 81 unités, essais physiques documentés |

Ordre recommandé : lot 1 isolé, puis artillerie difficile, puis coordination ; cartographie séparée ; réserves/rapport selon budget. Établir référence moyenne et conserver ses coefficients. Décider explicitement si la correction commune de l’exécuteur s’applique au moyen : aucune modification silencieuse de sa doctrine. Ne pas toucher aux règles de riposte, charge 2 PA, bouton de tir, score, portées ou coûts. Ne pas ajouter fatigue/munitions détaillées.

Chaque lot : reproduction, modification minimale après accord, tests, comparaison avant/après, état des performances, rapport, retour arrière si régression. D’abord plusieurs graines sur dispositif réduit ; ensuite des campagnes 81 unités avec conditions identiques et défense active, en tenant compte du temps de calcul. Une meilleure difficulté ne signifie pas une victoire obligatoire sur chaque graine.

## 7. Tests et limites exacts

- Import Godot 4.5.1 : réussi.
- 26 suites disponibles : **2 186 assertions réussies** après relance. Première tentative test_morale_ai : délai 180 s dépassé sous simulations concurrentes, code 124 sans erreur de script ; relance seule avec délai 900 s : réussie. Aucune modification du test.
- Rejeu complet V37 : **2 753/2 753**, tous les champs finaux identiques à la sauvegarde, checkpoint exact du début tour 12 chargé. Les commandes sont celles du fichier publié : ce n’est pas une nouvelle campagne de choix IA à 81 unités.
- Six nouvelles simulations réduites, 18 tours chacune : **5 066/5 066** validations de commande/état/fin de partie. 2 530 décisions acceptées cumulées. Deux graines ; défense FR moyenne identique comme politique ; niveaux PR comparés.
- Sonde affichage PA : **3/3**, chaînes effectives 4/4, 3/3, 2/2.
- Sonde cavalerie/canon : **2/2** pour visibilité et légalité de l’enchaînement ; menace mesurée nulle, anomalie A2. Essai préparatoire interrompu par découverte, puis sonde adaptée à une reprise légale dans le même tour, pas correction de source.
- APK signatures, ZIP alignment et ELF 16 Ko : réussis. Pas de nouveau build ni appareil/émulateur.
- Test complet V37 archivé : 18 tours, 81 déclarés/80 entrés, 1 372 décisions, 418 tirs/30 assauts, victoire PR mineure 77,36151 contre 14,95249 ; Frœschwiller tour 6, Elsasshausen/Niederwald tour 11. Son premier test contient 1 échec/1 484 pour l’hypothèse erronée de tous les renforts entrés. Cette donnée originale n’est ni effacée ni convertie en réussite ; l’attente légale est vérifiée par le rejeu.
- Trois redditions PR archivée/rejouées : pru_54 (tour 4, 81 hommes), reserve_art_11 (tour 6, 89), art_pr_Gersdorff0 (tour 14, 66). Aucune FR dans ce cas.
- Pas de simulation fraîche difficile/facile complète à 81 unités dans cet audit ; pas de preuve statistique d’équilibrage. Performances des comparaisons concurrentes ne servent pas à classer la vitesse des politiques. Les mesures de l’ancienne bataille sont des temps cloud, pas des FPS Android.
- Avertissements de fermeture audio forcée documentés en V36/V37 : connus, pas nouveau défaut reproduit ici ; suites UI actuelles réussies. Aucun crash confirmé pendant les exécutions présentes.

## 8. Recommandation finale

**V37 est une base suffisamment stable pour préparer V38, avec réserves tactiques clairement identifiées.** Le moteur et les règles validées sont conservés et les tests fondamentaux passent. Elle n’est pas une démonstration d’une IA difficile universellement supérieure ni une version entièrement validée sur téléphone. Corriger prioritairement la continuité de l’artillerie et les messages contradictoires, puis améliorer la décision difficile de façon isolée, mesurée et réversible.

Aucun développement V38 n’a commencé. Aucune source, profil, scénario, APK ou fichier de dépôt distant n’a été modifié pendant cet audit. La suite attend l’autorisation explicite de l’utilisateur.

## Pièces et reproduction

Les scripts d’audit sont extérieurs au projet : `compare.gd`, `replay_audit.gd`, `cavalry_probe.gd`, `ui_probe.gd`. Les résultats sont dans `results/`, notamment comparison_summary.json, artillery_cycles.json, river_geometry.json, android_elf.json, regression_summary.json et journaux. Les données de référence publiées restent sous `tests/results/0837/` dans les sources.

Exemple de simulation :

```sh
XDG_DATA_HOME=/tmp/mesure-v37 XDG_CACHE_HOME=/tmp/cache-v37 XDG_CONFIG_HOME=/tmp/config-v37 Godot_4.5.1 --headless --path /chemin/copie-V37/prototype_1870 --script /chemin/audit/compare.gd -- hard 187037
```

Sources déterminantes : tactical_ai.gd (choose/threat/mission_goal), main.gd (refresh/show_link_info/apply_ai_decision/show_result), map_view.gd (world et rendu labels), engine.gd (support_budget/end_side/retreat_route/resolve_surrenders/observation), rules_base.gd (LOS/déploiement), save_store.gd et packs/1870/{ai_profiles,regimental_trial,fr}.json.
