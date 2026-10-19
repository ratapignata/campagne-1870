# v0.8.29 — routes, pont et lisibilité

## Changements
- Les arêtes routières renseignées donnent le coût de route quand elles sont suivies, selon le type d’unité et sa formation. Quitter le tracé utilise le terrain d’arrivée. Une route dessinée sur une traversée non encore pontée ne supprime pas la pénalité de gué et ne permet pas le passage des canons/cavaliers.
- Pont de Wœrth : arête 344–345, ouverture au début du tour 4, 9 h 30. Horaire ADAPTATION GAMEPLAY. Croisillon rouge avant ouverture, état indiqué en touchant une case bordant le pont, bref message à l’ouverture. Même état pour mouvement, commandement, ravitaillement et calculs IA. Route raccordée au tracé existant.
- Les plaines de classe de relief 0 ou 1 n’interceptent plus les tirs par leur altitude. Pas de réduction des dégâts ajoutée. Classe 2 (hauteur marquée), forêts et unités gardent leurs règles. Les cultures restent non bloquantes en elles-mêmes.
- Tir au-dessus d’une unité amie : règle existante vérifiée, canon plus haut et ligne dégagée au-dessus de l’unité. Pas de tir à travers un ami situé au même niveau.
- Nom du QG dans le titre des fiches d’infanterie/cavalerie amies. Taille du texte adaptée aux noms longs ; aucune révélation du QG ennemi. Les rattachements provisoires du scénario restent des adaptations.
- IA : attente entre actions 0,22 → 0,04 seconde ; animations de combat IA à 60 % de leur durée précédente ; calcul de la prochaine décision autorisé pendant l’animation, application après sa fin. Difficultés, scores et informations accessibles inchangés. Pas de mesure sur appareil physique.
- Repère Vers Reichshoffen et flèche orientée vers le bord ouest/nord-ouest dans l’orientation actuelle (nord à gauche).

## Sauvegardes
Nouveaux emplacements save_regimental0829.json, save_classic_v0829.json, save_three_v0829.json. Copies exactes des anciens packs conservées pour recharger les anciennes sauvegardes. Pour appliquer les nouvelles règles de terrain et le nouveau pont, démarrer une nouvelle bataille. Ne pas désinstaller l’application.

## Vérifications
18/18 tests ciblés : coût route/culture infanterie/cavalerie, gué, pont avant/après tour 4 et rechargement, plaine faible relief, hauteur marquée, forêt, ami sur terrain plat, tir en surplomb et cultures. 181/181 tests du scénario régimentaire. 27/27 tests d’interface sans affichage : scénarios, QG dans les titres amis, sauvegardes, sélection et mise en batterie, reprise. Les tests ne constituent ni un test visuel Android ni un match complet d’équilibrage. Les performances réelles et la lisibilité des noms longs restent à tester sur le téléphone.

## Livraison
VersionCode 42, versionName 0.8.29. Même package et certificat que la version précédente. Vérification de signature et d’alignement jointe dans tests/results/0829.
