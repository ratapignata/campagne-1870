# 1870 : Frœschwiller-Wœrth — v0.8.38

Base : sources V37 livrées, développées dans une copie et une branche locale distinctes. Godot 4.5.1. Android versionCode 51. APK de test signé avec le même certificat de développement que V37.

## Corrections

- L’artillerie conserve son intention de déplacement entre l’attelage et le mouvement. Le trajet est recalculé depuis la nouvelle observation ; un changement de tour, de camp, de position, de PA ou une destination occupée invalide l’intention. Chaque action conserve son coût et ses contraintes. Une découverte interrompt le mouvement selon les règles existantes.
- Les fiches de commandement à liaisons strictes expliquent les plafonds de 3 PA hors commandement et 2 PA en double coupure, appliqués au début du prochain tour du camp. L’aide indique la déroute au troisième constat et la reddition conditionnée par l’absence de retraite légale. Les scénarios antérieurs conservent leur explication propre.

## Mode difficile

- Les risques de charge après déplacement sont estimés à partir de la cavalerie effectivement observée contre les batteries et QG, des PA de base publics, des terrains, des occupations connues et des règles de déplacement existantes. Les PA, liaisons et munitions réels des ennemis restent inconnus.
- Une batterie ayant un tir utile pénalise les déplacements qui n’améliorent ni le tir futur ni la sécurité, sans interdire une avance tactiquement utile. Le cycle d’attelage/déploiement est pris en compte dans sa décision.
- Une batterie peut préparer son déploiement pour le tour suivant quand son budget permet de déployer maintenant mais pas de tirer immédiatement. Ce point corrige notamment le blocage du canon français hors commandement à 3 PA : déploiement payé ce tour, tir à 3 PA au suivant. Le budget et les restrictions existants restent obligatoires.
- Les canons peuvent préparer les assauts légaux de troupes amies encore disponibles et viser les défenseurs d’objectifs observés. Aucun bonus de combat, tir supplémentaire ou soutien défensif n’est ajouté.
- Le choix des objectifs tient compte des approches immédiatement praticables ; un objectif bloqué peut céder la priorité à une autre approche.
- Le planning reçoit uniquement le calendrier de ses propres renforts. Une entrée occupée par une unité amie peut être dégagée légalement lorsque l’arrivée approche et qu’aucun ennemi observé n’est proche. Il n’existe aucune entrée anticipée, case de remplacement ou téléportation. Les règles et scores de réserve existants sont conservés.

Les fichiers de coefficients des trois difficultés restent exactement ceux de V37. Les nouvelles évaluations tactiques concernent uniquement « difficile ». La correction commune de continuité d’artillerie s’applique aussi aux autres modes.

## Carte et rapport

- « Sauer » est dessiné en bleu, avec DejaVu Serif Italic, sur une Curve2D reconstruite à partir des 59 segments publics de la rivière. L’emplacement utilise uniquement la carte publique, les routes, ponts et noms de lieux. Les unités sont dessinées au-dessus du nom ; aucun placement ne dépend d’un ennemi caché. Licence de la police : assets/fonts/LICENSE.txt.
- Le groupe « Vers Reichshoffen » et sa flèche reçoit un déplacement graphique vertical de sqrt(3) × 34 = 58,889727 unités de carte, soit un hexagone. Orientation, taille, couleur et route conservées. L’ancrage suit désormais la carte et n’est plus collé au bord de l’écran : selon le zoom et le cadrage, il faut faire défiler la carte pour le voir entièrement. La validation sur smartphone reste nécessaire.
- Le rapport final conserve le calcul 60/20/20 du moteur et ajoute les objectifs nommés, la chronologie de leurs captures et les capitulations enregistrées. Le champ facultatif battle_history conserve au maximum 512 événements, est validé, sauvegardé et retiré des observations de l’IA. Une ancienne sauvegarde sans historique charge normalement ; le rapport annonce cette absence sans inventer les événements passés.

## Règles conservées

Charge 2 PA ; aucun bouton TIRER ; confirmation par second toucher ; ripostes intégralement conservées ; infanterie/artillerie/cavalerie 4 PA ; assaut standard 3 PA ; aménagement 2 PA ; canon français 3 PA et portée 6 ; Krupp 2 PA et portée 8 ; score 60/20/20 ; objectifs 3/2/1 ; carte 30 × 20 ; 18 tours de 30 minutes ; mêmes critères de victoire majeure.

Les fichiers JSON des scénarios, les profils de difficulté, rules_base.gd, intel.gd et support.gd ne sont pas modifiés. Aucun développement de nouvelles mécaniques de combat ou de riposte.

## Sauvegardes et limites

Le schéma de sauvegarde, les empreintes des scénarios, l’identifiant Android et le dossier utilisateur sont conservés. Les sauvegardes V35/V36/V37 du scénario correspondant restent acceptées. Le nouveau champ d’historique est facultatif.

L’intention d’artillerie est une mémoire de planification en cours : elle est revalidée à chaque décision et n’est pas enregistrée dans les anciennes sauvegardes. Un redémarrage exactement entre attelage et mouvement peut amener l’IA à reconsidérer sa position ; aucune capacité, aucun PA ni règle n’est restitué.

Le mode difficile utilise un planning local borné, pas une recherche exhaustive de plusieurs tours. Les performances, résultats comparatifs et limites de validation sont détaillés dans TESTS_V38.md. Aucun APK n’a été testé sur appareil physique dans cet environnement.
