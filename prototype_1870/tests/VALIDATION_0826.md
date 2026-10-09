# v0.8.26 — pions français et vérification cultures / liaisons

Force française : fond rouge garance #8f3442 à la place du rectangle sombre. Les contacts français utilisent déjà le bandeau rouge. Les chiffres restent clairs.

Cultures : les trois packs courants ont déjà blocks_fire=false, obstacle_height=0, fire_received=0.85. Pas de changement de règle nécessaire. Texte de terrain et motif de blocage explicités. Le relief d’une case et les unités interposées restent indépendants de son couvert cultivé.

Audit commandement/ravitaillement : calcul en chemins praticables. Un ennemi bloque sa case et ses voisines (sauf corridor ami défendu ; déroute sans ZOC). Les détours restent possibles. Commandement limité à 10 hexagones / 12 cavalerie ; ravitaillement sans plafond, hors routes possible. Cela peut permettre de très longs détours sur 600 cases. Aucune restriction nouvelle introduite. Aucun diagnostic de la partie exacte du joueur sans état de sauvegarde ou capture.

21/21 tests automatisés : détour libre, distance, goulot occupé, ZOC, actualisation après déplacement et annulation, rivière/pont, QG en déroute, encerclement intégral, absence de récupération de munitions si isolé ; pour chacun des trois scénarios, tir à travers cultures, protection de 15 %, blocage distinct du relief. Les coupures testées fonctionnent. Hors commandement : récupération ralentie, pas de perte immédiate de PA. Hors ravitaillement : les stocks disponibles restent utilisables.

APK 0.8.26 code 39, signatures et alignement vérifiés. Pas de test physique Android. Packs et emplacements de sauvegarde inchangés : installer sans désinstaller.
