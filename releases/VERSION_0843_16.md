# V0.8.43.16 — défense française et prévention des encerclements

24 novembre 2026. Branche `v43-16-defense-francaise`, base stable V43.15 `55fca3f4b4ccc7a07ec00c11f7d7e7ebf07d6513`. Version stable V43.15, branche graphique et branche BD préservées.

## Comportement obtenu

L’IA française **Difficile** évalue les liaisons connues, les directions de sortie vers les arrières, les ennemis observés derrière sa ligne et la puissance des forces disponibles. Cette estimation réutilise les fonctions de combat existantes : terrain, formation, moral, retranchement et variante B, sans modifier leurs valeurs. Une ligne solide en forêt ne fuit donc plus sur la seule comparaison des effectifs bruts. Un déplacement hypothétique ne conserve pas fictivement son ancien retranchement dans cette estimation. Elle peut quitter un objectif, un retranchement ou une position de batterie avant une fermeture dangereuse. Le choix privilégie une seconde ligne proche et protégée ; le recul maximal vers le bord de carte n’est plus récompensé en soi. Une double coupure au second constat donne priorité à un repli utile plutôt qu’à un nouveau retranchement. Elle conserve le couvert, la formation défensive et les positions de tir lorsqu’un simple assaut frontal ou une petite incursion de cavalerie ne justifie pas un repli.

Les garnisons d’objectifs encore reliées, non encerclées et disposant d’au moins deux sorties sûres conservent leur position. Les objectifs les plus précieux reçoivent davantage de prudence avant d’être évacués. La garnison de Frœschwiller, objectif de trois points, conserve sa position tant que ses deux liaisons restent effectives et qu’elle n’est pas réellement encerclée. Une garnison menacée conserve ses conséquences normales d’isolement : la seconde constatation peut déclencher le décrochage avant les conséquences de la troisième ; aucune règle de reddition n’est désactivée. Une position dont la sortie est réellement fermée ne reçoit pas de chemin fictif.

Les réserves disponibles peuvent protéger l’entrée de ravitaillement contre une pénétration observée. Le premier défenseur affecté à chaque objectif ne sert pas de réserve de protection des arrières. Les troupes ne suivent pas les déplacements des QG au détriment de leur mission de secteur. Les QG et batteries reconsidèrent leur position sous menace ; le déplacement et les opérations d’attelage conservent leurs vrais coûts. Une connexion coupée pour une cause non observée n’est pas considérée comme magiquement rétablie dans chaque destination hypothétique : la mise à jour réelle du moteur reste décisive.

## Périmètre conservé

Normal français, IA prussienne des deux niveaux et profils inchangés. Aucun bonus de dégâts, PA, moral, renseignements ou renfort. Moteur, combat, ripostes, règles de réseau/isolement/reddition, LOS, carte, terrains, effectifs, renforts, animations et interface identiques à la base. Charge 2 PA, variante B 0,90, 20 tours, score 60/20/20, objectifs 3/2/1 et 95 000 Allemands conservés. Aucun bouton ajouté.

## Sauvegardes et installation

Le scénario conserve exactement l’empreinte SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. Aucun nouveau champ de sauvegarde ni migration. La sauvegarde finale fournie a été relue et réenregistrée vers une copie isolée ; état, score et original préservés.

APK de test `0.8.43.16`, code 73, paquet `org.woerth1870.prototype.v02`, même certificat de développement que V43.15. Mise à jour de l’application stable ; graphismes/BD expérimentaux restent des applications distinctes. Pour comparer le nouveau comportement, commencer une nouvelle partie **Prussiens / Difficile**. Une partie déjà achevée n’est pas réécrite.

Voir `ANALYSE_PARTIE_V43_15.md`, `TESTS_V43_16.md` et les résultats JSON. Aucun essai physique Android.
