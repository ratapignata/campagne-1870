> Rapport de la V43 initiale du 19 octobre. La mise à jour courante est V43.1 : voir VERSION_0843_1.md et TESTS_V43_1.md. La règle de renfort a changé le 20 octobre.

# V43 — prototype courant

Base : V42 Lot 8 finale, conservée à part. Godot 4.5.1 ; Android 0.8.43, code 57. V43 remplace les variantes anciennes dans le menu de jeu, avec seulement Normal et Difficile. Les anciennes sources et sauvegardes restent archivées.

- Raoult : reproduction déterministe ; attente légale sur entrée occupée maintenant expliquée dans le journal et au changement de tour. Position et arrivée inchangées. Voir RAOULT_V43.md pour la distinction entre défaut d’information corrigé et règle conservée.
- Charges : terrain défendu explicite. Résistance du village reproduite ; aucune anomalie de force ou bonus national constatée. Aucun coefficient de cavalerie modifié.
- Variante B : infanterie contre infanterie uniquement, force normalisée 1000 × (effectif / 1000)^0,90, identique pour les deux camps. IA alignée sur cette formule pour sa seule estimation après riposte ; doctrine et coefficients conservés.
- Projectile de canon anthracite avec fin liseré clair pour le contraste ; trajectoire, rayon du cœur, éclair, fumée, impact et durées conservés. Projectile d’infanterie inchangé.
- Nouveau scénario V43 et sauvegarde save_v43.json. Import automatique d’une sauvegarde compatible save_v42_lot8.json, y compris l’ancienne empreinte de libellé déjà supportée par V42, sans modifier l’originale. Le fichier principal compatible est prioritaire sur sa copie de secours, même quand leurs empreintes de libellé diffèrent. Le passé enregistré n’est pas recalculé ; les futurs assauts d’infanterie suivent B. Les sauvegardes des autres anciens scénarios ne sont pas converties arbitrairement vers les 95 unités.

Règles conservées : charge 2 PA, isolement et reddition, ripostes, 20 tours, score 60/20/20, 95 000 Allemands et 50 unités allemandes, absence de bouton TIRER, absence de bonus artificiel IA.

Limites : scénario et renforts toujours expérimentaux historiquement ; aucune garantie d’arrivée sur entrée occupée ; variante B ne rééquilibre pas automatiquement tous les combats. Pas de test physique Android. Les résultats effectivement exécutés figurent dans TESTS_V43.md.
