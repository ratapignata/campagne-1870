# Raoult — mise à jour V43.1

**V43.1 change désormais la règle d’arrivée**, conformément à la demande du 20 octobre. Voir VERSION_0843_1.md et TESTS_V43_1.md.

Reproduction déterministe : Raoult (qg_fr_Raoult, 250 hommes) est prévu au tour 3 en (15,4). La cavalerie pru_55 peut légalement y entrer au tour 2. Cette case est un village, ce qui explique les quatre charges françaises repoussées dans les essais détaillés dans COMBATS_V43.md.

Dans la V43 initiale, cette occupation reportait l’arrivée du QG ; seul le manque d’information avait été corrigé. Dans la V43.1, si une case voisine libre et praticable existe, Raoult y entre au tour prévu, sans déplacer la cavalerie. Dans le cas réel testé, il entre en (15,3) au tour 3 ; pru_55 demeure en (15,4). La nouvelle position est conservée après sauvegarde/reprise.

Si aucune case voisine n’est disponible, il attend. Aucun empilement, déplacement d’un occupant, arrivée avant calendrier, franchissement non ponté ou immunité supplémentaire n’est ajouté. Une partie V43 déjà retardée avant la mise à jour réessaie au prochain début de tour français.

La règle vaut aussi pour les autres renforts des deux camps du scénario courant. Les packs V42 archivés restent inchangés pour préserver les comparaisons.
