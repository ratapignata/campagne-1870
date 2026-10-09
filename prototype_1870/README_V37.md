# v0.8.37 — validation de la bataille complète

Ouvrir `project.godot` avec **Godot 4.5.1**. V37 reprend le moteur stabilisé de V36 et ajoute une simulation chronologique reproductible du scénario historique de 81 unités, avec les deux IA actives et les renforts réels.

Charge de cavalerie : **2 PA**. Confirmation du tir au second toucher, aucun bouton TIRER. Score **60/20/20**, coûts, portées, durée et doctrines conservés. Données des scénarios et emplacements des sauvegardes inchangés.

Lire `VERSION_0837.md`, `TESTS_V37.md` et `BATAILLE_V37.md` pour les résultats réellement exécutés et les limites.

Pour reproduire la bataille complète (exécution longue) :

```sh
python3 tests/v37/run_full_battle.py --godot /chemin/vers/Godot_4.5.1 --output-dir /tmp/bataille-v37
```

Les journaux et sauvegardes intermédiaires sont écrits hors des sources. `--resume` reprend le dernier point de contrôle avec le même répertoire de résultats. La suite de régression conservée s’exécute avec `python3 tests/v36/run_suite.py --godot /chemin/vers/Godot_4.5.1`.

---

# v0.8.36 — stabilisation

Ouvrir `project.godot` avec **Godot 4.5.1**, puis laisser importer les ressources. Sources de scénario V35 conservées pour les sauvegardes ; application et moteur V36.

Corrections : validation des sauvegardes, lignes de vue géométriques, retraite avant reddition, horloge finale à 17 h 00. Charge à 2 PA, aucun bouton TIRER, score 60/20/20 conservés. IA mesurée sans changement de doctrine.

Lire [VERSION_0836.md](VERSION_0836.md), [TESTS_V36.md](TESTS_V36.md), [IA_V36.md](IA_V36.md) et [FICHIERS_MODIFIES.md](FICHIERS_MODIFIES.md). Les entrées ci-dessous sont l'historique conservé des versions précédentes.

---

# v0.8.27 — drapeau du QG

Symbole central remplacé par un drapeau de 44 × 30 unités de dessin (ancien : 23 × 12), sans mât ni lettres QG. Suppression du petit drapeau inférieur pour les QG des deux camps, en vue amie et contact identifié. Effectif, état et règles conservés. Aide actualisée.

Compilation Godot et export Android ; contrôle du code de dessin. Pas de contrôle visuel sur appareil. Données de scénario et sauvegardes inchangées.

# v0.8.26 — pions français et vérification cultures / liaisons

Force française : fond rouge garance #8f3442 à la place du rectangle sombre. Les contacts français utilisent déjà le bandeau rouge. Les chiffres restent clairs.

Cultures : les trois packs courants ont déjà blocks_fire=false, obstacle_height=0, fire_received=0.85. Pas de changement de règle nécessaire. Texte de terrain et motif de blocage explicités. Le relief d’une case et les unités interposées restent indépendants de son couvert cultivé.

Audit commandement/ravitaillement : calcul en chemins praticables. Un ennemi bloque sa case et ses voisines (sauf corridor ami défendu ; déroute sans ZOC). Les détours restent possibles. Commandement limité à 10 hexagones / 12 cavalerie ; ravitaillement sans plafond, hors routes possible. Cela peut permettre de très longs détours sur 600 cases. Aucune restriction nouvelle introduite. Aucun diagnostic de la partie exacte du joueur sans état de sauvegarde ou capture.

21/21 tests automatisés : détour libre, distance, goulot occupé, ZOC, actualisation après déplacement et annulation, rivière/pont, QG en déroute, encerclement intégral, absence de récupération de munitions si isolé ; pour chacun des trois scénarios, tir à travers cultures, protection de 15 %, blocage distinct du relief. Les coupures testées fonctionnent. Hors commandement : récupération ralentie, pas de perte immédiate de PA. Hors ravitaillement : les stocks disponibles restent utilisables.

APK 0.8.26 code 39, signatures et alignement vérifiés. Pas de test physique Android. Packs et emplacements de sauvegarde inchangés : installer sans désinstaller.

# v0.8.25 — Carte historique : bataille d’essai

Troisième scénario sélectionnable, carte 30×20 entièrement active à 350 m entre centres, importée de l’atelier 11. Trois objectifs Frœschwiller (3), Elsasshausen (2), Niederwald (1), 18 tours. Deux camps et trois difficultés existantes. Forces : 4 infanteries, 1 batterie, 1 cavalerie et 1 QG par camp. Tous les effectifs et déploiements sont fictifs ; les classes de relief restent des adaptations cartographiques. Ceci n’est pas le scénario historique final.

Règles conservées : infanterie à travers la Sauer avec +2 PA et arrêt du mouvement, cavalerie/canons au pont ; aucune réparation. Commandement, approvisionnement, artillerie et affichage de tir inchangés. Chariots fixes raccordés aux routes de leur rive. Raccords de chariots : adaptations de gameplay.

Sauvegarde indépendante save_historical_trial0825.json. Les deux packs et les emplacements précédents restent inchangés. Installer sans désinstaller ; choisir une nouvelle bataille puis Carte historique · Essai. Aucun remplacement automatique de la partie en cours.

Validation : 23/23 contrôles interface sans écran (choix, deux camps, QG/ravitaillement initiaux, artillerie, sauvegarde/reprise/redémarrage, anciens scénarios) ; 68/68 contrôles moteur (connectivité, bords de rivière, une décision IA par difficulté et camp, résultat après 18 tours sans actions). Six décisions initiales IA : environ 0,94–1,70 s sur l’environnement de développement, non représentatif du téléphone. Aucun match complet avec combats simulé pour équilibrage ; aucun test physique Android. Le test UI a signalé deux ressources encore utilisées à la fermeture du banc de test malgré ses assertions réussies.

APK 0.8.25 code 38, package et certificat conservés ; signatures v2/v3 et alignement 16 Ko validés.

Sources cartographiques conservées dans le dossier historique : plan de Wœrth 1874 (dilibri), Kunz 1891 (e-rara), carte Saint-Cyr 1908 (IRCICA). Le fichier development/historical_trial0825/map_candidate.json conserve les statuts et réserves de l’atelier11.


# v0.8.24 — visibilité des tirs

Contour rouge de portée rétabli, cases dégagées conservées et fond des pions ennemis visibles éclairci si le canon peut les viser. Aucun éclairage des contacts anciens ou cachés. Calcul de combat et sauvegardes inchangés.

Contrôles automatiques sans écran ; rendu à confirmer sur téléphone.

# v0.8.23 — zones de tir de l’artillerie

Sélectionner un canon en batterie avec suffisamment de PA éclaire discrètement les cases accessibles au tir. Calcul partagé avec le combat : portée, relief, bois et unités connues. Les cases amies sont exclues. Les règles existantes de tir autorisé au-dessus de troupes amies en contrebas restent respectées. Le contour de portée seul est supprimé pour les canons. Pas de nouveaux marqueurs sur les ennemis.

Le premier appui sélectionne la cible et affiche un éventuel motif de blocage ; le deuxième confirme le tir. Les unités cachées ne changent pas l’éclairage : une interception par un ennemi caché reste possible, selon la règle antérieure. Aucun tir sur case vide n’est ajouté. L’affichage disparaît à la désélection, pendant l’animation ou quand le canon ne peut plus tirer.

Compatibilité : données de scénario strictement identiques à la v0.8.22, mêmes emplacements et empreintes de sauvegarde. Installer par-dessus la version précédente, sans désinstaller. Les deux camps et les deux scénarios restent disponibles.

Validation : 1188/1188 contrôles moteur (concordance cases/tirs pour les deux camps, relief, bois, amis, portée, PA, déroute, brouillard) ; 6/6 contrôles interface automatisés (sélection, deux appuis, mise à jour, désélection) ; 33/33 contrôles armes ; 7/7 contrôles interception cachée. Exécution Godot 4.5.1 sans écran. Aucun test sur appareil Android physique ni contrôle visuel final ; intensité de l’éclairage à confirmer sur téléphone.

APK Android 0.8.23, code 36. Le contenu historique complet n’est pas intégré à cette version.


## Historique

# v0.8.22 — effectifs QG et numéros des pions

Les QG français et prussien passent de 150 à 250 hommes dans les deux scénarios de nouvelles parties. Leurs 4 PA, armements et valeurs de tir restent identiques. L'aide est actualisée. Effectifs d'essai : ADAPTATION GAMEPLAY.

Suppression des petits rectangles sombres derrière le numéro d'identification en haut à droite des pions, pour les unités amies et les contacts ennemis. Les chiffres sont dessinés directement sur le fond de leur camp.

Sauvegardes séparées save_classic_v0822.json et save_three_v0822.json. Les packs v0.8.21 exacts sont conservés avec leurs anciens emplacements : les parties en cours gardent leurs effectifs et pertes, sans ajout rétroactif d'hommes. Nouvelle bataille nécessaire pour les QG de 250 hommes.

Validation : test_hq0822_ui.gd 12/12 headless (fiches, effectifs, commandes, aide, reprise v0.8.21). Les deux packs de l'APK contiennent bien des QG de 250 hommes et les anciens packs sont identiques octet pour octet. Godot 4.5.1 ; version Android 0.8.22, code 35 ; signature v2/v3 et alignement 16 Ko vérifiés, même certificat et package.

Aucun test physique Android ni contrôle visuel du rendu effectué ; contraste des numéros à confirmer sur téléphone. Pas de nouvelle simulation de bataille complète pour ces changements limités.

---
Historique :

# Livraison Android v0.8.21 — chariots et QG séparés

Chariots fixes de ravitaillement reliés au réseau routier. Un QG distinct par camp : escorte de 150 hommes, 4 PA, tir et riposte moins puissants qu’un régiment. En déroute ou détruit, il cesse d’assurer le commandement, sans transfert vers un régiment. Effectifs et puissance sont des valeurs de gameplay d’essai.

Installer en mise à jour sans désinstaller. Commencer une nouvelle bataille pour les nouvelles unités et routes ; les anciennes parties conservent leurs règles. Voir tests/VALIDATION_0821.md pour les tests et limites.

---
Historique :

# Livraison Android v0.8.20 — commandement et ravitaillement

QG stable intégré à un pion, rayon de 10 hexagones (12 pour la cavalerie), coupures et détours, zones arrière marquées de caisses. Toucher Cmd./Ravit. pour une explication. Tir possible ou bloqué annoncé avant confirmation, uniquement par texte.

Installer en mise à jour de la v0.8.19 avec le même package/certificat. Les anciennes parties restent disponibles avec leurs règles ; lancer une nouvelle bataille pour essayer les changements. Les scénarios restent des manœuvres fictives. Voir tests/VALIDATION_0820.md pour les règles, tests et limites Android.

---
Historique des versions précédentes :

# Livraison Android v0.8.19 — essai à trois objectifs

APK compilé et signé. Menu : Essai à trois objectifs ou Classique. Deux camps, trois difficultés, sauvegardes indépendantes et reprise. Scénario fictif sur le secteur du prototype : la carte historique de l’atelier 08.2 n’est pas intégrée. Voir tests/VALIDATION_0819.md pour les tests et limites (pas de test sur appareil Android). Les sections suivantes documentent les étapes précédentes.

# Préparation : moteur à objectifs multiples

Gestion des captures, propriétaires, scores, sauvegardes, IA et fiches intégrée. Tests exécutés avec Godot 4.5.1 : voir tests/VALIDATION_MULTI_OBJECTIVES.md. Le scénario actuel reste à un objectif ; la bataille historique n’est pas encore activée. Aucun nouvel APK exporté. Reprise du pack exact v0.8.18 ajoutée pour préserver ses sauvegardes.

# Modification en préparation - fusion prairie / plaine

Sources modifiées après la v0.8.18, sans nouvel APK compilé. Les nouvelles parties utilisent uniquement Plaine : infanterie 1 PA (0,75 en colonne), cavalerie 0,5 PA, artillerie attelée 1 PA. Aucun bonus de protection, charge de cavalerie sans pénalité propre à la prairie. Aide sans doublon ; alias meadow conservé dans le pack actif avec les mêmes valeurs que plain. Les packs legacy et parties déjà sauvegardées ne sont pas migrés par cette préparation.

---
# Version 0.8.18 — pions français bleu plus clair

Fond des pions français éclairci (#568DB4 au lieu de #274A63), pour infanterie, cavalerie et artillerie, dans les deux camps jouables et les contacts sous brouillard. Repère de propriété français harmonisé. Le rouge garance, les drapeaux, silhouettes et fonds sombres des chiffres restent conservés.
Aucune modification des règles, de la carte ou des sauvegardes. Continuer reprend directement la partie.
Validation : export Godot et signature Android ; changement limité à la palette et aux numéros de version. Rendu sur téléphone à confirmer par le joueur.

---
# Version 0.8.17 — simplification et lisibilité

- Suppression du bouton Repos. Le réapprovisionnement automatique existant reste inchangé : un niveau au prochain tour sans attaque volontaire, avec liaison maintenue et hors déroute. Déplacement et riposte restent permis.
- Bilan après combat dans le bandeau central : pertes ennemies et amies, riposte, changement du moral de votre unité. L’estimation des pertes ennemies est conservée sous brouillard ; aucun état ennemi caché n’est révélé. Le journal conserve les échanges détaillés.
- Suppression du doublon de bilan flottant sur la carte ; animations de combat conservées.
- D de désorganisation dans un médaillon en coin pour préserver la silhouette et la puissance du pion, pour les deux camps.
- Libellé « Munitions » explicite, textes secondaires plus contrastés et légèrement agrandis. Descriptions courtes des formations, explications des obstacles au tir.
- Même moteur, même pack, même format et emplacement de sauvegarde que la 0.8.16 : Continuer reprend directement la partie. Les versions antérieures restent compatibles selon leurs règles.

APK : versionName 0.8.17, versionCode 30 ; package et certificat inchangés.
Tests : voir tests/VALIDATION_0817.md. Pas de test sur téléphone réel dans cet environnement.
Le script development/revision0817/apply.py est une trace non idempotente de modification, pas une commande de compilation.

---
## Historique de la version précédente

# Version 0.8.16 — traversées, relief et annulation

Installer 1870_v0.8.16.apk sans désinstaller l’application. Commencer une nouvelle
partie pour jouer avec la cavalerie à 4 PA et l’annulation simplifiée. Une ancienne
partie conserve son pack et son budget (5 PA pour la cavalerie de la 0.8.15).
Les nouveaux éléments visuels s’appliquent aussi aux anciennes cartes compatibles.

- Cavalerie des deux camps : 4 PA ; charge toujours à 2 PA.
- Annulation du dernier déplacement possible à 0 PA, avec restitution de la
  position, des PA et du droit de se déplacer après une traversée. Pas d’annulation
  après découverte d’informations, capture, combat, formation, déploiement,
  retranchement, ralliement, repos ou fin de tour. Être simplement observé par
  l’ennemi ne bloque plus l’annulation dans les nouvelles parties : le précédent
  comportement pouvait rendre un déplacement ordinaire inexplicablement irréversible.
- Le motif de blocage est enregistré dans la sauvegarde et affiché au toucher
  du bouton grisé. Il ne figure pas dans l’observation transmise à l’IA adverse.
- Flèche bleue au franchissement d’une rivière sur le trajet confirmable. Aucun
  repère permanent, aucun repère sur les ponts ou sur la portion hors budget.
- Ondulations durant 0,65 seconde après une traversée réelle, sans blocage des
  commandes. Aucun effet pour un ennemi caché ; annulé immédiatement lors du retour.
- Courbes brunes discrètes le long des changements de niveau de la carte ; pas
  de nouvelles règles de relief. Les données de terrain restent provisoires.
- Aide actualisée. Save_v0816 indépendant, reprise des sauvegardes précédentes
  avec leurs packs conservés à l’identique.

Validation : moteur, intégration IA, sauvegarde, contrôleurs et géométrie de
l’interface en mode sans affichage. L’environnement de cette révision ne permet
pas d’ouvrir l’affichage virtuel ; les nouveaux effets graphiques n’ont donc pas
été examinés dans une capture rendue. APK signé, non lancé sur téléphone ici.
Voir tests/VALIDATION_0816.md. Les scripts development/revision0816/apply.py sont
un historique d’édition ponctuelle, pas une commande de reconstruction à réexécuter.

## Versions antérieures

# Version 0.8.15 — routes et annulation

Installer 1870_v0.8.15.apk sans désinstaller l’application. Le bouton d’annulation
est corrigé dans les parties anciennes comme nouvelles. Pour la carte corrigée,
commencer une nouvelle partie ; Continuer préserve la carte et les règles de
la partie 0.8.14 en cours. Nouveau fichier de sauvegarde : save_v0815.json.

- Réseau de 36 liaisons routières explicites et 37 cases reliées : plus de raccord
  automatique entre toutes les cases voisines, plus de triangles ni de tronçons
  isolés. Routes reliées aux villages et au pont, courbes plus douces. Les cases
  routières correspondent au tracé et donnent leur coût de déplacement habituel.
- Ajustement de continuité sur la même rive près de Wœrth ; aucun pont ajouté.
  Le tracé est une ADAPTATION GAMEPLAY sur la carte historique encore provisoire.
- Annuler mouvement reste à une place fixe, en haut à droite du panneau central.
  Doré lorsque disponible, grisé avec contour visible lorsque bloqué ; toucher
  le bouton grisé affiche une explication. Repos reste accessible à gauche lorsque
  nécessaire. Restitution des PA et de l’autorisation de déplacement après une
  traversée annulée. Aucune suppression des restrictions liées au brouillard,
  aux combats et aux actions irréversibles.
- Compatible avec les sauvegardes 0.8.14 via leur pack exact legacy0814.json.

Validation : tests tactiles et géométriques du panneau sur deux formats,
franchissement, réseau routier et reprise de sauvegarde. Voir tests/VALIDATION_0815.md.
APK compilé et signé, pas de validation sur téléphone Android physique ici.

## Versions précédentes

# 1870: Frœschwiller–Wœrth — Prototype 0.8.14

## Première bataille jouable sur le secteur de la Sauer

Installer `1870_v0.8.14.apk` sans désinstaller la version précédente. Dans le menu,
choisir Nouvelle partie pour découvrir ce scénario. Continuer permet de reprendre
une ancienne partie avec son ancien pack. Les nouvelles parties utilisent
`save_v0814.json`, séparé des anciennes sauvegardes.

Scénario d’essai fictif : 10 tours, six unités par camp (quatre infanteries,
un canon et une cavalerie), un objectif à conserver près du pont. France et Prusse
jouables, trois difficultés IA. Carte 30×20, secteur actif de 255 cases, nord à gauche.
Les positions, effectifs, objectifs, horaires et règles sont des ADAPTATIONS GAMEPLAY.
La carte de travail est approximative : elle ne constitue pas encore la reconstitution
validée de Frœschwiller-Wœrth. Voir le dossier historique dans development/historical05.

- Infanterie : traversée de toute limite de rivière sans pont pour le coût du
  terrain augmenté de 2 PA. Le déplacement s’arrête sur l’autre rive pour ce tour.
  Les PA restants peuvent servir aux autres actions autorisées ; pas d’assaut
  après cette traversée. L’unité retrouve son déplacement au début de son prochain tour.
- Cavalerie et artillerie : franchissement par le pont uniquement.
- Pont : coût du terrain habituel, sans arrêt supplémentaire.
- Aucune réparation, destruction ni construction de pont. Pas de gestion de convois.
  Commandement et ravitaillement conservent leurs liaisons abstraites existantes.
- Sélection puis destination, deuxième appui sur cette destination pour confirmer.
  Coût et conséquence de la traversée affichés avant validation. Explications dans Aide.
- Les mêmes règles s’appliquent à l’IA. Brouillard, ripostes, assauts, formations,
  retranchement et calcul des résultats conservés.

## Architecture et validation

Le moteur générique utilise `map.river_edges` (frontières entre cases avec attribut
bridge), `map.elevations`, et `rules.river.infantry_extra_ap` en quarts de PA.
Le terrain, les placements et les textes restent dans le pack 1870. Le module
expérimental `edge_navigation.gd` et l’atelier historique 05 restent archivés comme
préparation ; leurs restrictions de passage ne sont pas les règles de cette version.

Godot 4.5 stable, export Android non Gradle, JDK 17, outils Android 35.
Voir `tests/VALIDATION_0814.md`. Tests du moteur et de l’interface sur poste de travail ;
l’installation, le confort et les performances sur téléphone Android réel restent à essayer.

## Historique des versions antérieures

## Préparation historique 05 (2 octobre 2026)

Ajout du module expérimental `edge_navigation.gd`, de données de secteur et de tests. Voir `development/historical05/README.md`. Module non activé dans la bataille ; version Android jouable conservée à 0.8.13.

# 1870: Frœschwiller–Wœrth — Prototype 0.8.13

## Version 0.8.13 — confort et ravitaillement

Installer 1870_v0.8.13.apk sans désinstaller. Les parties sauvegardées 0.8.11/0.8.12
restent accessibles avec leurs règles. Commencer une nouvelle partie pour essayer
le ravitaillement simplifié (save_v0813.json). Les coûts de PA, les résultats et
les dégâts restent inchangés.

- Une unité ravitaillée récupère un palier au début de son tour après un cycle
  sans tir volontaire ni assaut lancé, hors déroute. Ripostes, pertes subies et
  proximité ennemie ne bloquent plus cette récupération si la liaison reste
  ouverte. Une liaison coupée à la frontière d'un tour empêche la recharge lors
  de la reconnexion immédiate. Repos ne recharge pas instantanément.
- Le suivi des attaques volontaires est sauvegardé, séparé du calme utilisé
  pour la cohésion, et masqué dans les renseignements ennemis / observations IA.
- Contour de sélection plus visible et silhouettes des terrains légèrement
  contrastées, sans textures supplémentaires.
- Commandement et ravitaillement gardent chacun leur place et leur couleur :
  états normaux discrets, munitions faibles / liaison coupée en ambre.
- Toucher un bouton grisé affiche sa raison sans exécuter l'action ; fonctionne
  aussi à la souris et dans le choix des formations.
- Compte rendu du point de vue du joueur : pertes infligées / subies, indication
  de la riposte fusil ou canon. Les pertes ennemies restent approximatives sous
  brouillard de guerre ; aucun renseignement caché n'est dévoilé.
- Aide adaptée à la règle active (ancienne ou nouvelle partie).

## Versions précédentes

# 1870: Frœschwiller–Wœrth — Prototype 0.8.12

## Version 0.8.12 — alignement de la fiche

Terrain, PA, formation, commandement, ravitaillement et encerclement partagent
le même bord droit dans le panneau de gauche. Les lignes Cmd. et Ravit. sont
alignées à droite. Les règles et le pack de scénario 0.8.11 sont inchangés,
y compris son empreinte et `save_v0811.json` : la partie peut être continuée.
Installer **1870_v0.8.12.apk** sans désinstaller l'application.

Ravitaillement assuré indique une liaison, pas un stock plein. Les munitions
remontent d'un palier au début du prochain tour après un cycle calme, sans tir,
riposte, assaut ni pertes, hors déroute et sans ennemi adjacent, si la liaison
reste assurée. Le bouton Repos termine l'activation sans recharge instantanée.


## Version 0.8.11 — contact adjacent et lisibilité

- Dans une nouvelle partie, toute unité vivante révèle l'effectif exact d'un ennemi
  observé dans un hexagone adjacent, sans combat ni coût d'identification.
  La règle vaut pour les deux camps et tous les niveaux d'IA.
- Le nombre reste actualisé tant que l'ennemi demeure observé. Dès qu'il sort
  de vue, l'effectif exact et la puissance sont effacés du signalement. Une
  réapparition lointaine ne les restaure pas ; revenir à proximité le permet.
- Un déplacement révélant cette information est irréversible et interrompt le
  trajet, comme toute nouvelle découverte. On ne peut sonder puis annuler.
- Ralliement : 2 PA, même hors commandement. L'isolement réduit toujours de moitié
  la récupération spontanée de cohésion. Pas d'autre bonus de combat.
- Pions : suppression des barres de PA, silhouette d'infanterie agrandie de 10 %,
  cavalier légèrement agrandi, canon redessiné avec tube effilé et roues à rayons,
  contour à coins coupés. Drapeaux, numéro, puissance, D, pelle et coche conservés.
- Bandeaux de même taille : textes des effectifs, PA, moral, formation, armes,
  munitions, liaisons et consignes agrandis de 2 points. « Mun. » abrège Munitions.
- Cavalerie toujours à 5 PA ; charge toujours à 2 PA.
- `save_v0811.json` pour les nouvelles parties. Une partie antérieure garde ses
  règles, son état et ses PA ; les améliorations graphiques s'appliquent à toutes.
  `legacy0810.json` est une copie exacte du pack précédent.

Installer **1870_v0.8.11.apk** sans désinstaller l'ancienne application.
Commencer une nouvelle partie pour tester la reconnaissance adjacente et le
ralliement à 2 PA hors commandement. Ces réglages sont des adaptations de jeu
pour l'exercice fictif ; le scénario historique n'est pas encore intégré.


## Version 0.8.10 — mobilité et lisibilité

- Cavalerie : 5 PA par tour dans les nouvelles parties, pour les deux camps et
  les trois niveaux d'IA. Infanterie et artillerie : 4 PA. Charge : toujours 2 PA.
  Réglage de gameplay à évaluer en partie, sans prétention historique chiffrée.
- Budget configurable par type d'unité (`unit_types.cavalry.ap=20`, quarts de PA).
  Initialisation, renouvellement de tour, ralliement après recul, simulation IA,
  validation des sauvegardes, fiche et barres du pion utilisent ce même budget.
- Fiche gauche : PA en chiffres uniquement ; « En ordre » ; commandement et
  ravitaillement dans une colonne à droite, encerclement en dessous.
  Terrain consulté : coût et protection sur deux lignes distinctes.
- Panneau central : coût du trajet dans le titre, PA restants dans le détail.
  L'annulation dispose d'une zone réservée ; le titre s'adapte à la largeur
  restante. Formation, retranchement, déploiement et repos conservent leurs zones.
- Sauvegarde nouvelle : `save_v0810.json`. `legacy089.json` est une copie exacte
  du pack précédent. Continuer une partie 0.8.9 garde ses PA et règles ; commencer
  une nouvelle partie active les 5 PA. Les corrections visuelles sont communes.

Installer **1870_v0.8.10.apk** par-dessus l'ancienne application, sans désinstaller.
Tests détaillés dans VALIDATION.md. Validation sur appareil Android encore requise.

## Historique des versions — les réglages ci-dessous sont ceux de leur version

## Version 0.8.9 - commandement, ravitaillement et fiche agrandie

Nouvelle partie : exercice fictif de six tours, avec trois niveaux de munitions
uniquement : **Abondantes, Correctes, Faibles**. Aucun niveau Critiques.
Le dossier historique reste une préparation distincte ; ni la carte ni les
régiments historiques ne sont intégrés dans cette version.

- Les deux panneaux inférieurs ont une taille identique : 486 × 168 unités
  d'interface à 1280 × 720, avec agrandissement égal sur écran plus large.
  La fiche gauche était auparavant de 437 × 142. Le pied passe de 154 à 180
  unités de haut : 26 prises sur la carte. Les boutons de formation et d'annulation
  restent distincts et accessibles.
- Commandement : centre abstrait calculé près du groupe principal de chaque
  formation (ici une formation fictive par camp), sans pion de général à déplacer.
  Liaison par un chemin de 4 cases au maximum, 6 pour la cavalerie. Hors liaison,
  ralliement à 3 PA au lieu de 2 ; récupération spontanée de cohésion × 0,5 arrondie.
  Aucun retrait automatique de PA, d'hommes ou de moral.
- Munitions : trois salves par palier, ripostes comprises. Faibles conserve
  la possibilité de tirer avec un facteur 0,65. Les paliers et salves sont abstraits,
  pas des comptes de cartouches. La cavalerie au sabre n'en consomme pas.
- Repos : clôt les actions de l'unité, sans récupération immédiate. Un cycle calme
  (sans tir ni pertes), hors déroute et sans ennemi adjacent permet de récupérer
  un palier au prochain tour si le ravitaillement est assuré. Ne pas tirer permet
  également cette récupération sans utiliser le bouton. Une rupture connue à
  une frontière de tour bloque la récupération ; une liaison tout juste rétablie
  impose d'attendre un nouveau cycle.
- Les liaisons sont relevées au début du tour du camp concerné. Leur fiche reste
  un rapport jusqu'au prochain relevé, pas une sonde sur les ennemis cachés.
  Un bref message signale une rupture ou un rétablissement au début du tour humain.
- Deux accès d'approvisionnement par camp sur son bord arrière, configurés dans
  le pack. Terrain praticable, ponts, ennemis et leurs cases adjacentes pris en
  compte. Une case tenue par un ami permet un corridor défendu ; une unité en
  déroute ne projette pas cette interdiction logistique. Il ne s'agit pas encore
  d'une nouvelle ZOC appliquée aux déplacements tactiques ordinaires.
- Encerclée : aucun chemin sûr vers le bord arrière du camp. Une unité en bon
  ordre qui ne peut reculer après un assaut tient sa place avec seulement 5 points
  de choc de cohésion ; elle n'est pas capturée automatiquement. Une unité déjà
  en déroute sans destination de recul possible peut être capturée. Le recul
  cherche aussi une case libre moins favorable et peut traverser un ami.
  Les prisonniers restent distincts des tués/blessés dans les statistiques.
- L'IA utilise les mêmes réserves et règles. Ses observations contiennent les
  rapports de ses propres unités, jamais les munitions, liaisons ou positions
  cachées de l'adversaire. Elle peut ordonner le repos pour récupérer des munitions.

Installer **1870_v0.8.9.apk** par-dessus l'ancienne application, sans désinstallation.
Même identifiant et même clé de développement ; versionCode 22. Une **Nouvelle
partie** est nécessaire pour les nouvelles règles. **Continuer** reprend d'abord
`save_v089.json`, puis `save_v086.json` avec `legacy088.json`, puis les anciennes
branches 0.8.5 / 0.8.1. Aucun ajout rétroactif de munitions à une bataille ancienne.

Paramètres : `packs/1870/prototype.json` / `rules.support`.
Algorithmes génériques : `war_engine/core/support.gd` et `engine.gd`.
Textes et aide : `packs/1870/fr.json`.
Toutes ces règles constituent des **ADAPTATIONS GAMEPLAY** à évaluer sur téléphone.

## Documentation de référence 0.8.8 (règles et sauvegardes antérieures)


Android, paysage, français. Exercice fictif de six tours sur 30 × 20 hexagones,
huit unités d’infanterie, deux batteries et deux unités de cavalerie. « Campagne 1870 » reste réservé au logo.
La carte et les effectifs ne sont pas encore ceux de la bataille historique.

## Installer

Installer `1870_v0.8.8.apk` par-dessus la version précédente sans la désinstaller.
Paquet `org.woerth1870.prototype.v02`, même clé de développement ; versionCode 21.
Android 7 / API 24 minimum ; ARMv7, ARM64 et x86_64. Aucune permission réseau,
publicité, collecte ou achat intégré. Le prototype 0.1.1 reste indépendant.

Les nouvelles parties utilisent `save_v086.json` et le brouillard de guerre.
Continuer reprend en priorité cette sauvegarde, puis une partie 0.8.5 avec son pack
`legacy085.json` et son fichier `save_v085.json`, puis la branche 0.8.1–0.8.4 avec
`legacy084.json` et `save_v081.json`. Les imports plus anciens restent disponibles.
Les anciennes parties conservent leurs troupes, positions, moral, formations et PA,
ainsi que leur visibilité complète. Seul le coût des prochaines charges y passe
à 2 PA. Choisir Nouvelle partie active le brouillard. Ne pas désinstaller avant mise
à jour ; utiliser Continuer pour garder sa progression.

## Trois difficultés — 0.8.8

Choisir Facile, Moyen ou Difficile avant le camp. Moyen est proposé par défaut.
La difficulté est fixée pour toute la partie, conservée au redémarrage et rappelée
dans le menu et le bilan. Les sauvegardes antérieures conservent leur algorithme
précédent, y compris les parties 0.8.6–0.8.7 avec brouillard. Choisir Nouvelle partie
pour essayer les niveaux. Coûts, dégâts, moral, effectifs et portées sont identiques.

- Facile : priorités plus variables, charges acceptées à des rapports de force
  moins favorables, faible préférence pour le couvert, reconnaissance non planifiée.
- Moyen : objectifs, positions de tir, déploiement des canons, formations,
  ralliement, couverture et reconnaissance près de l’objectif.
- Difficile : pondération accrue du feu défensif, des menaces observées, de la
  protection, des appuis proches et des possibilités de tirer après mouvement.
  Évite davantage les charges mal préparées. Une fois l’objectif acquis, favorise
  des positions d’infanterie proches pour le soutenir sans y masser toute l’armée.

Ces niveaux sont une première heuristique, pas une recherche exhaustive ni une IA
entraînée. Ils ne garantissent pas un taux de victoire précis. Leurs paramètres
sont externalisés dans `packs/1870/ai_profiles.json`. Deux orientations légèrement
différentes (plus directe ou plus sensible aux abris) varient les priorités d’une
nouvelle partie, sans modifier les forces.

L’IA reçoit une copie filtrée de ses observations. Les cellules observées pour
la reconnaissance proviennent uniquement de ses unités ; les contacts ennemis
cachés ne sont pas transmis. Les pertes attendues servent uniquement à classer
les décisions, sans lire la graine réelle ni prévoir le prochain jet de combat.

Les calculs tournent sur un thread séparé. Les commandes reviennent au fil
principal, où les mêmes règles que celles du joueur sont appliquées. Le menu et
la suspension empêchent leur exécution. Commencer une autre partie invalide les
résultats d’un ancien calcul. Un seul calcul peut être actif à la fois.

## Effectif exact après contact — 0.8.7

Un tir entre cases adjacentes, un assaut ou une charge révèle les effectifs exacts
aux deux camps. Le pion affiche la même puissance sur 10 que les unités amies,
calculée sur les survivants ; la fiche affiche le nombre exact d’hommes.
L’information est partagée avec tout le camp et suit les pertes tant que l’ennemi
reste observé. Une simple proximité, une visée ou un tir à distance ne suffit pas.

Dès que l’observation visuelle cesse, puissance et effectif exact sont effacés,
même si une révélation temporaire liée au tir reste active. Le signalement ancien
reste daté à sa dernière position, sans chiffre d’effectif. Une réapparition
rend l’estimation et le ?, jusqu’à un nouvel engagement rapproché.
L’IA reçoit l’effectif exact dans les mêmes conditions. Adaptation de jeu explicite.

La mise à jour reprend les sauvegardes 0.8.6 sans nouvelle partie : champs exacts
optionnels et absence de connaissance rétroactive des anciens engagements.
Le pack de scénario reste byte pour byte identique (révision de données 0.8.6),
afin de conserver son empreinte et `save_v086.json`. Les règles de combat,
les unités, les terrains et les coefficients n’ont pas changé.

## Reconnaissance 0.8.6, complétée en 0.8.7

- Charge montée : **2 PA**, y compris dans les anciennes parties reprises.
  Assaut d’infanterie toujours 3 PA. Le coût s’affiche depuis les règles courantes.
- Dans les nouvelles parties, chaque camp observe avec ses propres unités.
  Infanterie et artillerie : 4 cases ; cavalerie : 6 ; hauteur : +1.
  La géographie est connue ; un voile léger signale les secteurs non observés.
- Visibilité : segment entre hauteurs, relief/bois/bâtiments masquant au passage.
  Une unité dans un bois/village n’est détectable qu’à 2 cases. Les unités amies
  ne constituent pas elles-mêmes des murs d’observation.
- Repéré : type et effectif estimé par intervalles de 250 hommes. Identifié à
  2 cases (1 sous couvert) : nom, état observable et estimation par intervalles de
  100 hommes avant engagement rapproché. Après celui-ci, effectif et puissance
  deviennent exacts selon la règle 0.8.7 ci-dessus. Les PA, la cohésion exacte
  et le budget de riposte restent masqués.
- Un signalement perdu garde son ancienne position et sa date ; sa fiche indique
  explicitement qu’il est ancien. Il ne suit pas la position cachée et ne peut pas
  être attaqué. Observer à nouveau une position vide efface le signalement, sauf
  si le couvert empêche encore de vérifier qu’elle est vide.
- Chemins proposés calculés avec les seuls occupants connus. Le mouvement réel
  vérifie les cases et se termine à la découverte d’une nouvelle information,
  avec le coût réellement parcouru. Pas d’annulation si des informations ennemies
  sont découvertes ou transmises à l’autre camp, ni après capture ou combat.
- Les combattants se révèlent lors d’un tir/assaut/charge jusqu’à la fin du prochain
  tour du camp observateur au maximum. Un déplacement ou recul hors de vue met
  immédiatement fin à cette révélation et laisse un signalement figé. Les trajectoires de retraite ennemies ne sont pas
  animées à travers les secteurs cachés. Le journal conserve les noms connus lors
  du combat et estime les pertes ennemies. Les pertes alliées restent exactes.
- La préparation d’un tir utilise seulement les occupants connus. Si un ennemi
  caché intercepte le tir réel, il en devient la cible, le coût normal est payé et
  il est révélé. Le message indique Tir intercepté. Cette adaptation empêche de
  sonder gratuitement les positions cachées depuis la prévisualisation.
- Le contrôle de l’objectif est public pour les deux camps : adaptation explicite.
  La fin de bataille révèle les forces et les pertes exactes pour le bilan.
- L’IA reçoit une observation filtrée : unités propres et ennemis actuellement
  observés, effectifs et états ennemis limités aux informations disponibles. Ni les
  unités cachées, ni le journal complet, ni la mémoire adverse ne sont transmis.
  Dans cette première étape, elle ne poursuit pas encore les vieux signalements.
- Intelligence et historique des contacts sauvegardés. Le module `core/intel.gd`
  est générique ; les paramètres résident dans `rules.fog` du pack.

Valeurs de visibilité, estimations, révélation au combat et effet du relief :
**ADAPTATION GAMEPLAY** pour l’exercice. Aucune nouvelle donnée historique prétendue.
Les trois niveaux d’IA sont proposés depuis la version 0.8.8 ; pas de fatigue
ni d’unité supplémentaire dans cette version. L’équilibre et la lisibilité restent à essayer
sur un téléphone Android.

## Cavalerie 0.8.5

- Une unité montée de 600 hommes par camp, numéro 6, dans cet exercice fictif.
  Effectifs, placement, uniforme stylisé et coefficients : ADAPTATION GAMEPLAY,
  sans prétention à identifier un régiment historique.
- 4 PA par tour. Coût par case : plaine 0,5 PA ; route 0,25 ; hauteur/pont 1 ;
  village 1,5 ; forêt 2. Rivière infranchissable hors pont. Prise d’objectif et
  annulation du mouvement suivent les règles déjà en place.
- Aucun tir, aucune riposte par tir, aucun retranchement ni formation d’infanterie.
  La cavalerie se défend cependant au contact, subit le moral et peut être ralliée.
- Charge contre un ennemi adjacent, 3 PA. Sélection du cavalier, appui sur l’ennemi,
  second appui sur cette cible ou bouton Charger pour confirmer. Les appuis pendant
  l’animation sont ignorés. Une autre cible remplace la cible préparée.
- Une salve défensive disponible précède le contact et peut arrêter la charge.
  Le contact inflige des pertes aux deux camps ; recul, déroute, reddition si la
  retraite est bloquée et occupation de la position suivent le moteur d’assaut.
- Puissance montée offensive ×1,6 par homme ; malus selon le plus défavorable du
  terrain de départ et d’arrivée : forêt/village ×0,55 ; hauteur ×0,75 ; pont ×0,65.
  Une infanterie en bon ordre reçoit ×1,2 de défense contre la charge, en plus de
  sa formation, de son terrain et de son éventuel retranchement. La cavalerie
  reçoit ×1,2 pertes au tir. Toutes ces valeurs résident dans `unit_types.cavalry`.
- L’IA tient compte des modificateurs de charge et d’une estimation de la salve
  défensive avant de décider. Elle utilise la même observation et les mêmes coûts.
- Pion dessiné en code, cavalier et cheval, drapeau et puissance conservés. Pas
  d’image lourde ajoutée. Animation et son brefs d’assaut réutilisés pour la charge.
  La fiche, l’aide et le journal distinguent la charge des tirs et de l’assaut.
- Calcul de victoire, armes d’infanterie/artillerie et formations inchangés.
  La nouvelle cavalerie entre dans les effectifs initiaux pour le calcul des pertes.

Étapes prévues après la 0.8.5 : brouillard de guerre et reconnaissance, puis trois difficultés
fondées sur les décisions de l’IA. Ni combat démonté ni nouvelle bataille historique
n’ont été ajoutés. Équilibre, durée et lisibilité doivent encore être essayés sur Android.

## Lisibilité 0.8.4

- Pions de même taille et mêmes zones tactiles : bordure contrastée, silhouettes
  d’infanterie redessinées avec contours, fusil plus distinct, canon recentré.
- Chiffre de puissance en caractères gras plus grands, sur une zone sombre réservée.
  Numéro d’unité détaché en haut à droite. Les PA conservent leurs quatre barres.
- D doré plus opaque, pelle mieux contrastée et marque de déroute bordée ; drapeaux
  et rouge garance conservés. Les appuis longs d’aide ne changent pas.
- Villages aux toitures et façades plus nettes ; groupes d’arbres légèrement variés ;
  courbes de relief irrégulières. Aucun ajout de repère de cible ou d’obstacle.
- Dessin vectoriel dans Godot ; détails des arbres réduits à faible zoom. Police
  DejaVu Sans Bold ajoutée, couverte par la licence des polices incluse dans assets.
- Règles, IA, sauvegardes, commandes et carte inchangées. Les variations visuelles
  des terrains sont déterministes et ne consomment pas l’aléatoire des combats.

Dans la 0.8.4, la cavalerie et le brouillard n’étaient pas
intégrés à cette retouche graphique. Le départ en Colonne et les trois formations
restent inchangés pour poursuivre leur essai.

## Correction 0.8.3

Après un mouvement annulable, Se retrancher pouvait recouvrir Formation. Le problème
persistait en sélectionnant une autre unité disposant de tous ses PA : l’annulation
restait disponible et les deux boutons occupaient le même emplacement.

Annuler mouvement passe désormais au-dessus quand les trois commandes sont utiles.
Se retrancher et Formation restent côte à côte, avec leurs zones tactiles distinctes.
Correction reproduite par des appuis tactiles sur les quatre infanteries prussiennes,
à 4 PA et à 2,75 PA après un trajet de deux cases. Changer coûte toujours 1 PA.
Aucune règle, IA ou sauvegarde ne change. Une partie déjà sauvegardée reste compatible.
Les actions de retranchement éventuellement exécutées avant la mise à jour ne sont
pas effacées automatiquement, car elles peuvent avoir été intentionnelles.

## Retouche 0.8.2

Le bouton Formation du bandeau inférieur utilise le jaune doré des actions et
un texte sombre. Sa taille, son emplacement et son comportement sont conservés.
Il devient sombre et désactivé lorsqu’un changement n’est pas possible.
L’indication du camp sous l’étoile de l’objectif est conservée : elle indique le
contrôle persistant, même après le départ de l’unité qui l’a capturé.
Aucune règle de jeu ne change ; le pack de règles et `save_v081.json` sont conservés.

## Retouches 0.8.1

- Bouton « Formation · … » dans la zone centrale du bandeau inférieur, à côté
  des actions tactiques : 226 × 49 au lieu de 135 × 35 en coordonnées d’interface.
- Fiche de gauche : la formation reste affichée comme information, sans petit bouton.
- Toute l’infanterie des deux camps commence gratuitement en Colonne avec ses 4 PA.
  L’artillerie conserve ses états Attelé / En batterie.
- Coût de changement de 1 PA et effets des formations inchangés. Moral, armes et victoire
  inchangés. Départ en Colonne configurable via `rules.formations.initial`.
- Le champ `default` reste Ligne pour la reprise des anciennes sauvegardes sans formation.
- Départ en Colonne de tout le monde : ADAPTATION GAMEPLAY de cet exercice fictif,
  sans prétendre reproduire les positions initiales de la bataille historique.

## Nouveautés 0.8

- Ligne, Colonne, Tirailleurs : choix au milieu du bandeau inférieur ; 1 PA par changement.
- Persistance entre tours et sauvegardes. Pas de nouveau repère sur les pions.
- L’IA utilise les mêmes effets et paie le même coût, sans bonus.
- Krupp : base de pertes 125 → 131 (+4,8 %). Portée et cadence inchangées.
- Moral et victoire inchangés ; fatigue, cavalerie et brouillard non ajoutés.

## Libellé 0.7.3

Le bouton de choix du camp affiche « Jouer la Prusse », en parallèle de « Jouer la France ».
Aucun autre changement de jeu ; sauvegarde et règles identiques à la 0.7.2.

## Retouches d’interface 0.7.2

- Le camp adverse est affiché « Prussiens » dans le choix du camp, l’aide, les messages,
  le journal et le bilan. Abréviation PRU aux endroits qui utilisent encore des lettres.

- Petit drapeau en première ligne de fiche, à la place du suffixe FR/ALL ; nom et
  terrain toujours lisibles. Le tireur indiqué au centre conserve son nom complet.
- « Annuler mouvement » masqué lorsqu’aucune annulation n’est possible ; réapparaît
  après un mouvement annulable et disparaît après utilisation ou combat.
- Appui long de 0,55 s sur le D ou la pelle : bulle temporaire de quatre secondes,
  lisible après avoir retiré le doigt. Si les deux états coexistent, viser la gauche
  pour le D et la droite pour la pelle. Les zones de toucher sont légèrement élargies.
- Un appui long d’aide ne sélectionne, ne désélectionne et ne confirme aucune action.
  Glisser, ajouter un doigt, ouvrir un menu ou interrompre l’application annule le geste.
- Même geste disponible avec une souris ; textes externalisés dans le pack français.
- Moteur, données de règles et sauvegarde 0.7 inchangés ; aucune migration supplémentaire.

## Retouches d’interface 0.7.1

- Nom et terrain occupé sur la première ligne de la fiche, pour les deux camps.
- En ciblant un ennemi, sa fiche s’affiche à gauche ; le tireur reste sélectionné
  pour les ordres et son nom est rappelé au centre. Le second appui confirme le tir.
- Préfixes redondants INF et ART retirés de la fiche ; noms et camps conservés.
- Lettres FR/ALL retirées des pions ; petit drapeau vertical/horizontal et puissance
  synthétique conservés, avec les uniformes et couleurs. Le repère d’objectif reste inchangé.
- Données de combat et fichier de sauvegarde identiques à la 0.7 : aucune conversion
  de partie nécessaire. Le pack de règles reste en version 0.7.0, l’application passe en 0.7.1.

## Nouveautés 0.7

- Suppression du rappel « À vous de jouer » inférieur ; camp actif conservé en haut.
- Tir direct calculé selon les hauteurs relatives ; artillerie pouvant tirer au-dessus
  de troupes amies en contrebas si la ligne conserve une marge suffisante.
- Motif textuel précis en cas de tir impossible : relief, couvert ou unité.
- Aucun repère automatique de cible attaquable ni surlignement d’obstacle.
- Silhouette de canon à deux roues, courbes de niveau, D et pelle mieux séparés.
- Fiche : effectifs et PA côte à côte ; moral/abri, puis arme/portée et riposte.
- « En bon ordre » remplace « Stable » à l’écran ; indicateurs de PA des pions inchangés.
- Victoire majeure exigeant contrôle final, marge de score et avantage militaire.
- Bilan avec motif du degré de victoire et taux de pertes des deux camps.
- Reprise de sauvegarde 0.6, y compris le dernier mouvement annulable.
- Musique et sons conservés, réglables séparément dans le menu.

## Manipulation

Toucher une unité ouvre sa fiche. Retoucher le même pion le désélectionne et efface
les préparations, sans annuler les actions déjà exécutées. Changer librement d’unité
tant qu’il reste des PA. Toucher une destination prépare le chemin ; la retoucher
confirme. Pour un chemin trop long, confirmer sa limite accessible.

Toucher un ennemi le cible ; retoucher le même ennemi déclenche le tir, sans
pronostic de résultat. Contre une cible adjacente, utiliser le bouton Assaut · 3 PA.
Le second appui sur la cible reste un tir. Pincer pour zoomer, glisser pour explorer.
Le menu et l’arrière-plan suspendent les décisions IA. La musique se suspend en
arrière-plan. Les actions déjà appliquées sont sauvegardées avant leur animation.

## Règles — ADAPTATION GAMEPLAY

Toutes les valeurs suivantes sont des réglages de prototype. Elles ne constituent
pas des données historiques. Effectifs : 1 000 hommes par infanterie, 250 par batterie.
Aucun nombre de pièces ni échelle hexagone/mètre n’est prétendu.

**PA.** Quatre par tour ; stockage en quarts de PA (16 = 4 PA). Route 0,5 ; plaine
et pont 1 ; village/hauteur 1,5 ; forêt 2 ; rivière infranchissable. Une unité par case.
La traversée amie est possible pour le mouvement ordinaire, pas pour la retraite.

| Arme | Portée | PA/tir | Base | Facteurs de distance |
|---|---:|---:|---:|---|
| Chassepot | 3 | 2 | 110 | 1 / 0,65 / 0,36 |
| Dreyse | 2 | 2 | 110 | 1 / 0,50 |
| Canon rayé français | 6 | 3 | 100 | 1 / 0,90 / 0,72 / 0,52 / 0,32 / 0,18 |
| Krupp | 6 | 2 | 131 | 1 / 0,95 / 0,85 / 0,72 / 0,59 / 0,45 |

Pertes au tir = base × effectif/initial × distance × protection du terrain ×
aléatoire × moral × cible × réaction × abri × formation du tireur × exposition de la cible, arrondies, minimum 1 et plafonnées aux
survivants. Aléatoire 0,9–1,1. Désorganisé : tir × 0,7. Cible batterie : × 0,42.
Terrain : village × 0,55 ; forêt × 0,65 ; hauteur × 0,85 ; autres × 1.
La ligne directe relie l’élévation du tireur + 0,4 à celle de la cible + 0,4.
Hauteur de terrain : 2 pour une colline, 0 ailleurs ; couvert : forêt + 1,5,
village + 1. Une intersection avec le relief ou le couvert bloque le tir.
L’artillerie peut passer au-dessus d’un ami en contrebas si la ligne dépasse
son élévation + 0,4 + marge 0,2. Une unité ennemie intermédiaire bloque le tir ;
l’infanterie ne tire pas au-dessus des unités. Les deux côtés des limites d’hexagones
sont contrôlés. Même géométrie pour les deux camps et les ripostes. Pas de tir indirect
sur une cible cachée. Ces coefficients sont abstraits, configurables et ne sont pas
une mesure historique en mètres.

**Riposte.** Une par unité et par tour adverse, même à 0 PA. Portée et ligne de tir
requises ; impossible en déroute ou canon attelé. Facteur de tir × 0,65. Le feu
défensif contre l’assaut consomme le même budget. Les salves d’un échange sont
calculées avant leurs pertes et ne déclenchent pas une chaîne de ripostes.
À trois cases, le Chassepot peut tirer sur un Dreyse qui ne peut pas répondre.

**Assaut.** Infanterie adjacente, 3 PA ; feu défensif puis contact. Puissance =
effectif × moral × formation × état d’artillerie × défense de terrain et d’abri pour le défenseur.
Moral : stable 1, désorganisé 0,75, déroute 0,25. Batterie : déployée 0,6, attelée 0,4.
Terrain défensif : village 1,5, forêt 1,3, hauteur 1,2. Aléatoire offensif 0,92–1,08.
Pertes de contact : 9 % de la puissance adverse, majorées de 40 % pour le perdant.
Le perdant peut reculer sans déroute. Le vainqueur avance si la case est libérée.

**Formations — ADAPTATION GAMEPLAY.**

| Formation | Coût mouvement | Tir infligé | Tir reçu | Assaut lancé | Défense au contact |
|---|---:|---:|---:|---:|---:|
| Ligne | × 1 | × 1 | × 1 | × 1 | × 1 |
| Colonne | × 0,75 | × 0,65 | × 1,25 | × 0,90 | × 0,90 |
| Tirailleurs | × 1 | × 0,85 | × 0,80 | × 0,70 | × 0,85 |

Le coût de mouvement est arrondi au quart de PA supérieur. En Colonne : route 0,5 ;
plaine/pont 0,75 ; village/hauteur 1,25 ; forêt 1,5. Rivière infranchissable.
Les facteurs de tir s’appliquent aux ripostes et au feu défensif avant assaut.
Portées inchangées. Terrain et retranchement restent cumulables. Le changement
coûte 1 PA ; impossible en déroute ou sans PA suffisants. Il conserve l’abri,
la cohésion et le budget de riposte, mais efface l’annulation du mouvement précédent.
La formation persiste entre tours et sauvegardes. Les batteries conservent leurs
états Attelé / En batterie. Pas de gestion d’orientation. Le mode Tirailleurs est
une abstraction de dispersion à l’échelle du régiment, pas un nouvel armement.

**Moral.** Cohésion initiale 100. Chaque application de pertes retire
`max(1, arrondi(100 × pertes/effectif initial))`. Sous 65 : désorganisé, donc autour
de 35 % de pertes sans récupération ; les arrondis peuvent légèrement déplacer
ce seuil. Déroute : soit choc de 40 % de l’effectif initial en une application,
soit pertes cumulées ≥ 40 % et cohésion < 40. Les étapes d’un assaut sont séparées.
Un cycle calme sans tir, riposte, assaut ni pertes rend 35 points de cohésion.
Le mouvement ordinaire reste permis. Ralliement : 2 PA, une fois par tour, ennemi
à trois cases minimum ; déroute → désorganisé (48), désorganisé → stable (80).

**Retraite.** Deux pas au plus, en s’éloignant de l’ennemi, sans traverser une case
occupée. PA perdus, batterie attelée. Sans issue admissible, survivants prisonniers.
Une unité en déroute encore menacée fuit au début de son tour.

**Retranchement.** Infanterie ou batterie déployée : 2 PA, un seul niveau sans cumul,
interdit en rivière, sur pont ou en déroute. Tir reçu × 0,75 et défense au contact
× 1,25, en plus du terrain. Tirer ou riposter conserve l’abri. Mouvement, retraite,
déroute, assaut lancé ou changement d’état de batterie le suppriment. Annuler un
mouvement le rétablit. Persiste entre tours et sauvegardes. Pas d’ouvrage transférable.

**Objectif et victoire.** L’objectif reste acquis jusqu’à la capture par une unité
adverse non en déroute. Un point de durée par tour complet pour son propriétaire.
Après six tours, chaque camp reçoit :

- 40 points s’il contrôle l’objectif final ; sinon 0.
- Jusqu’à 20 points de durée : `20 × points de durée / 6`.
- Jusqu’à 40 points militaires : `40 × pertes adverses / effectif adverse initial`.

Pertes militaires = pertes au combat + prisonniers ; survivants en déroute exclus.
Écart entre totaux ≤ 5 : nul. Au-delà : mineur, sauf si le vainqueur réunit :
contrôle de l’objectif final, marge ≥ 25 et avantage net de taux de pertes ≥ 10 points
de pourcentage. Exemple : 20 % de pertes propres contre 30 % adverses. Taux calculés
avec les effectifs initiaux propres à chaque camp, prisonniers inclus. Les valeurs
non arrondies déterminent le résultat ; celui-ci est relatif au camp choisi.
Les objectifs pèsent jusqu’à 60 %, les pertes 40 %. Les seuils sont configurables.
Examiner la carte après bataille permet seulement la consultation ; Résultats rouvre
le bilan détaillé. Exemple fourni par le joueur : 979 pertes françaises, 3 831 allemandes,
durée 1/4, contrôle final français → 79,4 contre 22,5, victoire majeure française.

## Sources, architecture et reproduction

War Engine : `war_engine/core`, `ai`, `platform`, `presentation`. Contenu et réglages :
`packs/1870/prototype.json`, textes : `fr.json`, ressources : `assets/`.
Les clés internes `shaken` restent stables pour les sauvegardes ; l’interface affiche D.
Sources historiques et limites : `HISTOIRE_ARMES.md`. Crédits audio et licences :
`assets/sounds/CREDITS.txt`. Musique et effets sont évocateurs, pas authentifiés 1870.
Les deux scripts `development/make_sounds.py` et `make_ambience.py` sont reproductibles
avec Python, NumPy et FFmpeg ; MP3 sources inclus, exclus de l’APK.

Ouvrir avec Godot 4.5.1. Tests : `godot --headless --path . --script tests/test_*.gd`
(un script à la fois). Interface : `tests/touch_check.gd` avec un affichage graphique.
Export Android : JDK 17, SDK 35, Build Tools 35.0.1 et modèles Godot 4.5.1.
Configurer les chemins SDK/JDK dans l’éditeur. Export :
`godot --headless --path . --export-debug Android ../releases/1870_v0.8.4.apk`.
Conserver la clé `development/prototype-debug.keystore` pour les mises à jour
(alias androiddebugkey, mot de passe android). Ce n’est pas une clé de production.

## Limites

Voir `VALIDATION.md`. Pas de test de cette version sur téléphone physique ni
émulateur Android. Confort, haut-parleur, batterie et performances restent à vérifier
sur appareil. IA simple unique, sans bonus ; toutes les unités sont visibles.
Le scénario historique, la cavalerie, le brouillard, les munitions, la fatigue,
et les trois difficultés IA restent pour les prochaines étapes.
