> Rapport de la V43 initiale du 19 octobre. La mise à jour courante est V43.1 : voir VERSION_0843_1.md et TESTS_V43_1.md. La règle de renfort a changé le 20 octobre.

# Tests V43 — résultats réellement exécutés

## Environnement

Godot 4.5.1.stable.official.f62fdbde1, Linux, Java 21, SDK Android plateforme 35 et build-tools 35.0.0. Exécutables et templates officiels Godot vérifiés par SHA-512 ; archives Android vérifiées avec les empreintes du dépôt Google. Le Godot système 4.6.3 n’a pas été utilisé pour les validations ou l’APK. Données utilisateur isolées par banc, hors des sources.

## Contrôles ciblés finaux

| Banc | Résultat |
|---|---:|
| Raoult : calendrier, parcours prussien réel, arrivée bloquée/libérée, sauvegarde, journal, terrain, symétrie des phases | 42/42 |
| Quatre charges réelles à 95 unités, approches légales et reprise après la deuxième | 28/28 |
| Cavalerie, quatre assauts, 64 graines, deux terrains et camps inversés, après intégration B | 4096/4096 |
| Variante B, combats réels avant/après, tirs et combats mixtes inchangés, sauvegardes, roster et 20 tours | 1701/1701 |
| Interface V43, menu courant, deux difficultés, animation/riposte et migration réelle au redémarrage | 30/30 |
| Rendu réel du projectile Linux X11/OpenGL llvmpipe : dix terrains, quatre zooms, cinq phases | 53/53 |

Total ciblé final : **5 950 contrôles réussis**. La passe de cavalerie avant B (4 096/4 096) est une référence supplémentaire, pas comptée une deuxième fois dans ce total. Les champs enregistrés de ses combats sont identiques après B.

La reprise au démarrage couvre aussi l’ancienne empreinte de sauvegarde Lot 8 avant correction de son libellé, déjà acceptée par V42 ; le fichier source reste intact.

Les 40 frontières de phase sans décisions tactiques qui font partie du banc B vérifient le roster réel de 95 unités et ses 20 relevés ; elles ne sont pas présentées comme une bataille simulée.

## Régressions historiques

22 suites exécutées, résultat final : **22 réussies, 1 672 contrôles**, dont contrat Lot 8 301, effectifs Lot 8 258, contre-attaque/repli 49, interface Lot 8 112, contrat V42 415, interface V42 112, coordination 19, brouillard 18, sauvegardes 43, isolement 45, LOS 40, capture 3, renforts 5, sauvegarde ancienne 5, routes/combat 35, échanges/assauts 45, armes 33, cavalerie 41, isolement 0835 9, objectifs 28, soutien 29 et interface historique 27.

La première passe a échoué uniquement sur l’assertion historique « restart loads trial », qui attendait l’ancien prototype au redémarrage. L’utilisateur demandant explicitement que V43 remplace les autres variantes, cette assertion a été adaptée pour vérifier V43 au redémarrage **et la conservation de la sauvegarde historique**. Toutes les autres assertions de ce test sont conservées. Réexécution finale : 27/27. Le résultat initial et le résultat final sont livrés séparément ; aucun test n’est désactivé.

## Petites campagnes tactiques

Quatre campagnes effectivement achevées avec la variante B, douze unités de 1 000 hommes au départ, implantation synthétique sur la carte réelle, défense française mobile active et IA allemande de production. Il ne s’agit pas de quatre batailles complètes du roster de 95 unités. Graines et conditions initiales sont identiques entre Normal et Difficile.

| Difficulté allemande | Graine | Contrôles | Tours | Score FR / PR |
|---|---:|---:|---:|---:|
| hard | 430001 | 486 / 486 | 20 | 16.44 / 83.77 |
| hard | 430002 | 524 / 524 | 20 | 25.45 / 74.58 |
| medium | 430001 | 394 / 394 | 20 | 27.11 / 74.19 |
| medium | 430002 | 429 / 429 | 20 | 26.56 / 74.13 |

Total : **1 833 contrôles, zéro échec**. Commandes, mouvements, tirs, captures, pertes, décisions de fin de phase et scores sont conservés dans tests/results/0843/tactical. Ces petits échantillons ne certifient ni l’équilibre général ni une supériorité systématique de Difficile. Les coefficients IA restent inchangés.

## Animations

Les cinq captures sont réellement issues du rendu Godot sous Linux, pas d’un dessin reconstruit. Les contrôles lisent les pixels anthracite sur dix terrains, à z=0,42 / 0,72 / 1 / 2,3. Les phases 0,04 / 0,20 / 0,35 / 0,58 / 0,85 montrent l’éclair, la fumée, le trajet et l’impact. Le nom de capture « phase_57 » correspond à 0,58, tronqué lors du nommage ; la phase exacte figure dans le JSON.

Le code de shot_effect ne diffère de V42 que pour la couleur du projectile et son fin liseré. animate_fire, _process et cannon sont identiques à V42. Les durées, la trajectoire, le rayon du cœur, l’éclair, la fumée et l’impact sont donc conservés ; l’infanterie reste jaune. Les sons de tir/riposte et la fin d’animation sont aussi exercés par le test UI V43.

## Correction supplémentaire de compatibilité confirmée

Le contrôle indépendant a reproduit une reprise depuis une copie de secours plus ancienne lorsque le fichier principal portait l’ancienne empreinte de libellé Lot 8 et la copie de secours l’empreinte récente. L’import vérifie maintenant toutes les empreintes compatibles sur le fichier principal **avant** d’essayer sa copie de secours. Le test crée physiquement un fichier principal ancien compatible et une copie de secours valide avec un autre camp, une autre difficulté et une autre graine ; la reprise doit conserver tous les champs du principal. Ce contrôle passe dans les 30 assertions de l’interface V43. Les fichiers V42 d’origine ne sont pas écrasés.

## Échecs de montage et limites conservées

- Le premier test Raoult comparait des coordonnées JSON décimales à des entiers et l’identité interne StringName/String des clés de dictionnaire. Les contrôles utilisent maintenant des coordonnées entières et comparent tous les champs persistés après normalisation JSON ; aucune donnée de sauvegarde n’est ignorée.
- Le premier test UI avait une durée attendue supposée erronée. L’attente a été corrigée d’après la durée V42 existante, y compris le facteur de vitesse du camp IA. Le code d’animation n’a pas changé pour faire passer ce test.
- Le premier banc graphique avait un Control de taille nulle, rognant tout le dessin : ses 40 contrôles de pixels échouaient. Le montage reçoit maintenant une taille réelle de 1600 × 1200 ; la production n’a pas été changée pour contourner cet échec.
- Une première répétition du script d’installation tentait de réécrire le binaire Godot en cours d’utilisation. Il conserve désormais un binaire identique déjà installé ; la répétition corrigée réussit.
- L’export signale qu’adb ne peut créer /home/agent/.android ; compilation et signature réussissent. Aucun appareil n’est connecté. Des avertissements de ressources à la fermeture forcée de certains bancs sont conservés dans les sorties ; aucun plantage d’exécution ni erreur de script n’a été observé dans les passes finales.

## Livraison et contrôles indépendants

APK 0.8.43, code 57, paquet historique, signé avec la clé de développement existante. Vérifications réellement faites : ZIP, signature v2/v3, alignement ZIP 16 Ko, segments ELF 64 bits, métadonnées, licence de police. L’archive originale V42 Lot 8 et son extraction sont inchangées. Terrain, roster, support.gd, intel.gd, rules_base.gd et ai_profiles.json sont identiques à V42 ; les seules fonctions de combat modifiées sont les deux calculs de puissance contextualisés, avec ajout de melee_strength.

L’archive finale a été extraite séparément après le contrôle des anciens libellés Lot 8, importée avec Godot 4.5.1 et testée à nouveau : interface V43 30/30, variante B 1701/1701, sauvegardes 43/43. Tous ses fichiers correspondent aux sources. La preuve archive_verification.json décrit cette vérification avant l’ajout de ce seul compte rendu de livraison ; aucun code de jeu ne change ensuite. La correspondance avec la publication est également contrôlée avant annonce de livraison. Les tests V35–V42 présents ailleurs dans le projet sont des références historiques, pas des tests nouvellement relancés sauf ceux listés ici.

**Non réalisés :** nouvelle bataille intégrale de 95 unités avec B, essai physique Android, installation réelle, fluidité et lisibilité sur téléphone. Le rendu logiciel Linux ne remplace pas ces essais. L’ancienne V42 est préservée ; V43 devient le prototype courant du menu et du dépôt.
