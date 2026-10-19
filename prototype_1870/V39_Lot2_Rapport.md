# V39 — Lot 2 : décisions de l’IA

Lot 1 conservé ; nouvelle logique tactique implémentée. Les performances en bataille ne sont pas encore validées à ce stade.

- Priorité accrue aux tirs d’artillerie sur les défenseurs d’objectifs et les cibles proches d’une infanterie encore capable d’agir.
- Conservation des positions de batterie utiles ; recherche d’une ligne de tir et d’une distance de sécurité lors des déplacements.
- Valorisation des mouvements laissant des PA pour tirer et, en Difficile, pour assaillir une position favorable.
- En Difficile : évaluation des masses visibles autour des objectifs, axe commun au groupe de commandement, pénalisation des voies traversant une position ennemie visible, risque adapté au temps restant.
- En Difficile : opportunités de menace des arrières ou d’un QG observé, limitées aux abords des objectifs. Ce sont des estimations géométriques, sans connaissance des liaisons ennemies cachées.
- En Difficile : seuil de décision d’assaut légèrement moins prudent face à une infanterie désorganisée et avec des amis proches. Les formules de résolution, coefficients militaires et seuils de charge de cavalerie ne changent pas.
- Aucun bonus de dégâts, de PA ou de visibilité. Aucun soutien défensif ajouté.

## Tests exécutés
- Godot 4.5.1 : analyse du script sans erreur.
- Test tactique V39 : 30/30 contrôles (préparation de positions défendues, décisions légales, état valide, observation non modifiée, reproductibilité).
- Test des mondes cachés existant : 18/18 contrôles.

Un premier montage de test présentait un objectif libre plus intéressant que la préparation et confondait un QG avec une batterie. Le montage final place réellement deux canons devant des objectifs défendus ; les traces initiales sont conservées.

Le banc du lot 3 est prêt : défense française active V38 Moyen, mêmes déploiements et graines, politiques prussiennes V38/Normal/Difficile, 20 tours, mesures aux tours 6, 11, 15 et 20. Il porte sur un scénario réduit de 14 unités sur la carte originale. Il ne représente pas une validation exhaustive de la campagne à 81 unités.
