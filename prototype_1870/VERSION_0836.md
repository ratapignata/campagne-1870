# 1870 : Frœschwiller-Wœrth — v0.8.36

Développement de stabilisation à partir des sources v0.8.35, sur une copie dédiée. Moteur utilisé : **Godot 4.5.1 stable officiel, f62fdbde1**. Aucun envoi distant. Les 510 fichiers de l'extraction originale V35 ont été comparés à l'archive fournie : aucune différence.

## Règles conservées

4 PA de base pour les trois armes ; charge **2 PA**, assaut standard 3 PA, aménagement 2 PA, canon français 3 PA / portée 6, Krupp 2 PA / portée 8. Aucun bouton « TIRER » : le second toucher de la cible confirme le tir. Aucun nouveau plafond de tirs par tour. Ralliement, terrains de charge, déplacement ordinaire, ZOC, armes, doctrines IA, coefficients d'agressivité et seuils de victoire conservés. Carte 30 × 20, 81 unités déclarées avec leurs renforts, trois objectifs 3/2/1, 18 tours de 30 minutes à partir de 08 h 00. Score 60 % objectifs finaux / 20 % pertes militaires / 20 % durée.

## Lot 1 — sauvegardes

La validation refusait mal des champs coercibles en entier. Le moteur vérifie maintenant leur type avant conversion : entier ou nombre JSON fini exactement entier, jamais chaîne, booléen, fraction, NaN ou infini.

- `isolation_turns` : entier non négatif, au plus le numéro du tour courant, puisqu'une unité ne reçoit qu'un constat par tour de son camp. Le compteur peut dépasser trois pour une unité toujours isolée en retraite.
- `turn_ap_limit` : uniquement un budget produit par les règles du pack. Pour le scénario actuel : 16, 12 ou 8 quarts de PA. Les PA sont non négatifs, au plus le budget de base et, dans les règles strictes, au plus la limite mémorisée.
- Les liaisons peuvent se rétablir au milieu d'un tour sans augmenter les PA : la limite mémorisée n'est donc pas comparée directement aux liaisons instantanées.
- Cohésion entière 0–100, moral appartenant aux trois états existants, réactions bornées par la règle existante, prisonniers/pertes non négatifs et comptabilité des effectifs cohérente. Une unité sans effectif doit avoir zéro PA et être inactive. Aucun nouvel état de moral ni seuil n'est inventé.
- Les compteurs de reddition, indicateurs de liaisons, indicateurs facultatifs et événements de soutien sont contrôlés. Les champs facultatifs absents des anciennes sauvegardes restent acceptés et normalisés.

Le format schema 1, le checksum et les emplacements de sauvegarde restent inchangés. Une tentative de sauvegarde d'un état invalide est refusée avant écriture. La sauvegarde de secours n'est remplacée que par un fichier principal également valide sémantiquement ; récupérer puis sauvegarder un fichier principal corrompu conserve le secours valide.

## Lot 2 — lignes de vue

`line_status` ignorait une hauteur intermédiaire lorsque les terrains des deux extrémités étaient découverts, via les anciennes tolérances de relief. Cette exemption est supprimée. Chaque case intermédiaire est comparée à la hauteur interpolée du rayon, à partir des élévations des extrémités et de la hauteur de visée existante (0,4).

Un helper commun à `rules_base.gd` et `intel.gd` traite le sol et les obstacles de couvert. Les deux variantes de tracé des bords d'hexagones sont maintenues. Le relief peut donc masquer une unité sans interdire systématiquement un tir depuis/vers une hauteur. Les unités amies interposées et les exceptions géométriques d'artillerie restent traitées par les règles de tir existantes. La reconnaissance conserve sa règle de terrain : les pions interposés ne deviennent pas de nouveaux obstacles d'observation.

Les paramètres anciens de tolérance restent dans les fichiers de données, pour conserver leurs empreintes, mais ne dispensent plus le rayon de son contrôle géométrique. Aucun changement de portée ou de dégâts.

## Lot 3 — isolement, retraite, reddition

Les deux réseaux restent distincts. Hors commandement seul : 3 PA ; double coupure : 2 PA. Premier constat : grâce ; deuxième : désorganisation ; troisième et suivants : déroute. Une liaison rétablie remet le compteur à zéro. La double coupure continue d'interdire assaut et charge, même lorsque la charge coûte seulement 2 PA.

La perte du seul commandement n'entraîne plus systématiquement la reddition d'une unité en déroute encore ravitaillée. Avant reddition, le moteur recherche une retraite légale et praticable. Les règles ordinaires de retraite des autres unités sont conservées.

**Interprétation retenue :** pour une unité en déroute hors commandement, la viabilité nécessite un couloir vers l'arrière de son camp, suivant le même principe d'encerclement que les réseaux existants. Les cases ennemies, la ZOC des ennemis non en déroute, les terrains interdits et les arêtes interdites à cette arme ferment ce couloir. Un premier pas peut sortir d'une ZOC ; les pas suivants doivent être sûrs. Une issue simplement locale dans une poche sans liaison aux arrières ne suffit pas. Cette interprétation est plus conservatrice qu'une simple case voisine vide.

La retraite utilise au plus les deux pas existants, peut traverser les amis selon la règle déjà en place, termine sur une case libre et s'arrête après un gué d'infanterie. Cavalerie et canons ne passent pas un gué. Elle progresse vers l'arrière à chaque début de tour du camp : aucune téléportation ni déplacements répétés à chaque rafraîchissement des liaisons. Une unité déjà sur un arrière sûr peut rester sur place. Sans issue viable, les hommes restants deviennent prisonniers, avec un seul événement de reddition.

La déroute conserve les interdictions offensives existantes. Les possibilités de ralliement existantes restent disponibles ; une double coupure persistante réapplique ses conséquences au constat suivant. Les PA restaurés pour permettre le ralliement ne dépassent pas le budget de soutien.

## Lot 4 — évaluation IA

Le code IA et ses profils restent identiques à V35. Une bataille active de 14 unités sur la carte historique a été jouée chronologiquement du tour 1 au tour 18, avec les deux IA et le brouillard de guerre. Deux autres simulations démarrent dans des états **synthétiques**, au tour 12 et au tour 17. Leurs scores de durée ne représentent pas les tours non simulés. Les décisions sont rejouées pour vérifier les résultats et les possibilités tactiques à la fin des tours.

Résultats, scénarios, mesures d'inactivité et diagnostic d'une unité immobile sont dans `IA_V36.md` et `tests/results/0836/`. L'efficacité générale sur une bataille active complète de 81 unités n'est pas démontrée par ces simulations réduites. Aucune correction de doctrine n'est appliquée ; une proposition limitée est documentée.

## Corrections techniques complémentaires

- Horloge de fin : 17 h 00 après le dernier tour, avec le compteur toujours à 18. Début du tour 18 conservé à 16 h 30.
- Ancien test de formation : appel de `desired_formation` dans son module actuel `legacy_ai.gd`, sans restauration d'API obsolète.
- Tests historiques : packs historiques appropriés, comparaisons JSON canoniques après rechargement, unités éliminées correctement inactives et assertion de score alignée sur les 60 % conservés.
- Banc UI courant : laisse 100 ms à la libération asynchrone audio avant fermeture et quitte hors de la coroutine. Les répétitions finales ne signalent plus les deux ressources utilisées à la fermeture. Aucun changement de cycle de vie du jeu en production.
- Aide en français et badge actualisés : géométrie du relief et reddition conditionnelle.
- Application Android : version 0.8.36, code 49 ; identité du package et clé de développement fournies dans V35 conservées.

## Sauvegardes V35

Les trois packs courants (`prototype.json`, `three_objectives.json`, `regimental_trial.json`) restent **strictement identiques octet par octet** à V35. Leurs versions de contenu restent 0.8.35 : l'application et le moteur sont en 0.8.36. Cela préserve les empreintes et les chemins `save_*0835.json`, sans conversion de format ni démarrage forcé d'une nouvelle bataille. Une sauvegarde réellement produite par le code V35 charge dans les tests V36.

Une sauvegarde valide reprend avec les corrections LOS et reddition du moteur V36. Une sauvegarde sémantiquement invalide est refusée ; un secours valide est essayé. Le chargement ne modifie pas le fichier invalide. Les mises à jour Android exigent un certificat compatible avec l'application installée ; ici la clé fournie avec les sources V35 est conservée.

## Livraison et limites

Sources : `1870_v0.8.36_Sources.zip`, sans `.git`, `.godot`, APK, SDK, compilations ni fichiers temporaires. Rapports, fixtures et résultats de tests durables inclus. APK de développement réellement exporté, signature v2/v3 et alignement 16 Ko vérifiés.

**Aucun essai physique Android, aucun essai en émulateur, aucune publication distante.** Une fermeture immédiate par `--quit-after` avec la musique active signale encore deux ressources audio à la sortie ; ce n’est pas présenté comme une fuite corrigée globalement. Les anciens bancs de captures attendent un rendu absent en mode headless ; ils ne constituent pas des tests visuels Android réussis. Le nouveau banc tactile vérifie des événements simulés, y compris le second toucher, le déplacement de caméra et le pincement.
