# V43.15 — défense française en Difficile

Base : V43.14 (`3f7f01c`), copie de référence conservée dans les tests. Branche `feature/v43.15-french-defence`. La nouvelle planification s’active uniquement pour la France, en Difficile, sur le prototype courant. L’IA prussienne appréciée et les deux IA en Normal restent inchangées.

## Défense par secteurs

L’infanterie se répartit entre les trois objectifs réellement définis dans la partie. Chaque objectif tenu reçoit une première mission d’infanterie ; le reste est réparti selon sa valeur, la distance, les troupes déjà affectées et les forces ennemies observées. Les objectifs perdus fortement défendus ne provoquent pas une convergence aveugle de toute l’armée.

Des unités restent en réserve derrière les secteurs calmes. Elles redeviennent disponibles pour la première ligne dès qu’un ennemi observé approche à trois hexagones du secteur. La cavalerie reste plutôt en arrière ; elle peut libérer une garnison calme pour l’infanterie et conserve ses opportunités de charge légales.

## Terrain et préparation

Les mouvements valorisent les bois, villages et hauteurs utiles autour des secteurs défendus. Une bonne position de tir protégée n’est abandonnée que pour une amélioration tactique ou une restauration de liaison. Quitter un retranchement a un coût dans la décision. Une unité diminuée peut rechercher une seconde ligne plus sûre.

La France ne reste plus en colonne de marche à l’approche du combat : l’IA prépare sa formation défensive, privilégie la ligne dans le couvert et se retranche sur les positions menacées. Ces actions paient leurs coûts habituels. Elle cherche à exploiter la portée existante du Chassepot à trois hexagones ; aucune portée ni puissance n’est modifiée.

Le premier réglage expérimental favorisait trop le tir avant la préparation et a été rejeté après les essais de franchissement. Le réglage livré remet la formation et l’aménagement des points menacés avant la concentration des tirs.

## Artillerie et contre-attaques

Une batterie française sûre disposant d’une ligne de tir utile peut se mettre en batterie puis y rester pour son prochain tir, au lieu de consommer son activation en attelage/déplacement sans nécessité. Elle conserve le coût français de 3 PA et la portée de 6 hexagones.

Les tirs visent en priorité les approches des objectifs. Une contre-attaque favorable peut reprendre un objectif perdu ; une garnison ne poursuit pas une unité affaiblie en abandonnant son propre point tenu. Les seuils de rapport de forces, réactions, coûts et résultats du moteur restent ceux de V43.14.

## Informations et sauvegardes

Le module reçoit exclusivement l’observation déjà filtrée par le brouillard. Il n’accède pas au moteur réel, aux ennemis cachés, à leurs PA courants ou à leurs liaisons. Il ajoute des priorités de décision, jamais des bonus de dégâts, de moral, de PA, de munitions ou de renseignement.

Aucun nouveau champ de sauvegarde n’est requis. Les missions sont recalculées à chaque décision à partir de l’état autorisé. Les parties anciennes conservent leurs objectifs réels, leurs pertes et leur score. Le journal et le rapport détaillé V43.14 restent disponibles.

## Règles conservées

Carte et scénario identiques ; 95 000 Allemands / 50 unités ; 20 tours ; objectifs Frœschwiller 3, Wœrth 2 et Niederwald 1 dans les nouvelles parties ; score 60/20/20 ; charge 2 PA ; variante B 0,90 ; coûts, formations, terrain, LOS, ripostes, isolement, ravitaillement, renforts et animations inchangés. Aucun bouton TIRER.

Le calendrier prussien un tour plus tôt en Difficile, précédemment autorisé, s’applique toujours : cette version ne le change pas lorsque le joueur choisit la Prusse. Les Français ne reçoivent aucun renfort anticipé.

## Installation

Version Android 0.8.43.15, code 72, même application et même certificat de développement. Installer comme mise à jour sans désinstaller. Choisir une nouvelle partie **Prussiens**, difficulté **Difficile**, pour jouer contre la nouvelle défense française. Une ancienne partie déjà jouée côté prussien en Difficile bénéficie de la planification à sa prochaine décision d’IA.

Les résultats réellement exécutés et leurs limites sont dans TESTS_V43_15.md. Aucun test physique Android.
