# Combats V43 — comparaisons exécutées

## Cavalerie : aucune modification des coefficients

Banc synthétique : quatre unités fraîches de 400 cavaliers contre un défenseur de 400, 64 graines (430000–430063), camps inversés, terrain réellement plat ou village. Les pertes, le moral et les retraites sont conservés entre les assauts ; aucun défenseur n’est réinitialisé. Soutien et brouillard désactivés uniquement dans ce banc contrôlé.

4 096 contrôles passent avant la variante B et 4 096 après son intégration, avec champs de combat enregistrés identiques. La même mécanique s’applique aux deux camps, avec résultats identiques à graine égale. En plaine, puissance 640 contre 400 : le premier assaut déloge le défenseur dans les 64 essais de chaque camp. Exemple graine 430000 : 81 pertes au défenseur, 36 à l’attaquant, recul du défenseur. Dans un village, puissance 352 contre 600 : les quatre assauts peuvent être repoussés. Même graine : effectif défenseur 400→368→336→304→272 ; pertes attaquantes 76/70/64/57. Les valeurs ne sont jamais remises à zéro.

Le sabre ne tire pas : aucune riposte de tir n’est consommée. Les pertes de mêlée de l’attaquant sont distinctes d’un tir de réaction. Le budget de réaction reste celui de V42. Aucune fatigue séparée n’existe dans ces règles ; moral et cohésion sont les états suivis. Aucun bonus national caché n’a été trouvé ni ajouté. Le coût de charge demeure 8 quarts de PA, soit 2 PA. Les retraites forcées peuvent consommer le solde de l’activation selon la règle existante.

## Variante B d’infanterie

Puissance d’effectif effective : **1000 × (effectif restant / 1000)^0,90**. Elle remplace le facteur linéaire uniquement dans les puissances de mêlée quand les deux unités sont de l’infanterie. Même formule en attaque et défense, pour les deux camps. À 1 000 hommes, la puissance reste 1 000 ; à 2 900, elle vaut 2 607,103, soit −10,10 %. En dessous de 1 000 hommes, cette normalisation augmente la puissance relative par rapport à la formule linéaire : conséquence explicite de l’ancrage choisi.

Les formations, le terrain, le retranchement, le moral, la variance et les pertes continuent à utiliser leurs coefficients existants. Le moteur calcule la puissance après la volée défensive, avec l’effectif effectivement restant. L’IA emploie la même fonction pour estimer la force après cette volée ; ses coefficients et bonus ne changent pas.

La règle est activée seulement dans le nouveau scénario V43. Les scénarios archivés sans ce paramètre conservent leur formule V42. Tirs d’infanterie, charges de cavalerie, engagements mixtes avec cavalerie, QG et artillerie restent identiques à V42.

## 2 900 contre 1 000 : résultats effectifs

64 graines par cas et version, vrais assauts incluant la riposte initiale. Un moteur V42 de référence inchangé est fourni dans tests/v43/reference_v42_engine.gd. L’attaquant est testé dans les deux camps ; aucune différence numérique entre camps n’apparaît dans ces montages à bout portant.

| Défenseur | Version | Rapport de puissance avant riposte | Pertes moyennes défenseur | Pertes moyennes attaquant | Cases prises / 64 |
|---|---|---:|---:|---:|---:|
| Plaine | V42 | 2,9000 | 356,39 | 161,69 | 64 |
| Plaine | V43 B | 2,6071 | 321,28 | 161,69 | 64 |
| Village retranché | V42 | 1,5467 | 356,39 | 240,69 | 64 |
| Village retranché | V43 B | 1,3905 | 321,28 | 240,69 | 64 |

La réduction ne suffit donc pas à inverser le résultat de ces assauts. Ces montages ne certifient pas l’équilibre d’une bataille complète. Dans ces échantillons, le défenseur recule sans être classé en déroute ; il ne faut pas confondre retrait et déroute.

Le banc variante B réussit 1 701 contrôles : normalisation, symétrie, défense, effectif après riposte, conservation des hommes, tirs inchangés, événements réels des combats mixtes inchangés, anciens scénarios sans variante et migration physique d’une sauvegarde V42 Lot 8 vers V43 et 40 limites de phase du scénario V43 réel à 95 unités sans décisions tactiques, jusqu’au vingtième relevé. Ce dernier contrôle de frontières de tours n’est pas une simulation de bataille.
